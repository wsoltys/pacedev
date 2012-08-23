/*-
 * Copyright (c) 2001 M. Warner Losh
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * This code is based on ugen.c and ulpt.c developed by Lennart Augustsson.
 * This code includes software developed by the NetBSD Foundation, Inc. and
 * its contributors.
 */

#include "usb.h"
#include "usbdi.h"

#include "usb_busdma.h"
#include "usb_controller.h"

#include "pdev.h"

#include "../ee_helper.h"
#include "../ts_helper.h"

#define TCZ_VENDOR  (0x14c8)
#define TCZ_PRODUCT (0x0003)

#define TCZ_TOUCHDATA_EP    (1)
#define TCZ_TOUCHDATA_EPDIR (UE_DIR_IN)

typedef struct {
  periph_ep_filter_t old_in1;
} tcz_data_t;

typedef struct {
  uint8_t status;
  uint8_t x[2];
  uint8_t y[2];
} tcz_coord_data_t;

typedef struct {
	uint8_t start;
	uint8_t opcode;
  uint8_t payload[64-2];
} tcz_response_data_t;

#define CDGETW(_v) (((uint16_t) _v[1] << 7) | ((uint16_t) _v[0]))

static periph_ep_resp_t
tcz_touchdata_filter (periph_t*         per,
                      periph_ep_ctrl_t* epc,
                      periph_ep_data_t* epd,
                      void*             user)
{
  // passive if USB not selected
  if (ts_data->type != EE_TS_TYPE_AUTO && ts_data->type != EE_TS_TYPE_USB)
    return periph_ep_send;

  if (*(epd->data) == ':')
  {
  	tcz_response_data_t* cr = (tcz_response_data_t *)(epd->data);

  	switch (cr->opcode)
  	{
  		case 0x49 :
			  //printf ("TCZ RESPONSE: Heartbeat\n");
  			break;
			default :
				printf ("unknown opcode (%02X)\n", cr->opcode);
				break;
  	}
  }
  else
  {
    int hit = TS_HIT_NONE;

  	uint16_t x, y;
    uint16_t hit_x, hit_y;
  	uint8_t touch;

  	tcz_coord_data_t* cd = (tcz_coord_data_t *)(epd->data);
  	x = CDGETW(cd->x); y = CDGETW(cd->y);

    #if 0  	
      //if ((cd->status & (1<<6)) == 0)
    	  printf ("TCZ COORD: status:%02x x=%d y=%d\n",
    	          cd->status, x, y);
   #endif
	          
    // Note : Zytronics coordinates are 1024x768
    //        - Sentinel is expecting 16384x16384
	  x = x << 4;
	  y = y * 16384.0/768.0 + 0.5;

    // - sentinel packets are handled inside
    // - we only need to decide whether to pass up-stream or not
    touch = cd->status & ((1<<7)|(1<<6));
    if ((hit = handle_touch_event (touch, x, y, &hit_x, &hit_y)) != TS_HIT_EGM)
      return (periph_ep_drop);

    // rescale to 1024x768
    hit_x >>= 4;
    hit_y = hit_y * 768.0/16384.0 + 0.5;
    // patch upstream packet
    cd->x[0] = hit_x & 0x7F;
    cd->x[1] = (hit_x >> 7) & 0x7F;
    cd->y[0] = hit_y & 0x7F;
    cd->y[1] = (hit_y >> 7) & 0x7F;
  }
  	
  return periph_ep_send;
}

static void
tcz_event_handler (pdev_event_t event, periph_t* per, void* user)
{
  tcz_data_t* tczd = user;
  switch (event)
  {
    case PDEV_EVENT_ATTACH:
      if (pdev_check_vendor_product (per, TCZ_VENDOR, TCZ_PRODUCT))
      {
        ts_auto_attached = EE_TS_TYPE_USB;
        ts_auto_vendor_id = TCZ_VENDOR;
        ts_auto_product_id = TCZ_PRODUCT;
        return;
      }
      break;
      
    case PDEV_EVENT_DETACH:
      ts_auto_attached = EE_TS_TYPE_NONE;
      pdev_device_ep_filter_hook (per,
                                  TCZ_TOUCHDATA_EP,
                                  TCZ_TOUCHDATA_EPDIR,
                                  &tczd->old_in1);
      pdev_device_event_hook (&per->down.sc->next_device_event);
      free (tczd, 0);
      break;
      
    case PDEV_EVENT_CONFIGURE:
    {
      periph_ep_filter_t filter;
      filter.handler = tcz_touchdata_filter;
      filter.user    = user;

      // always hook the filter
      // because if we switch from serial->USB
      // it will automatically start working
      tczd->old_in1 = pdev_device_ep_filter_hook (per,
                                                  TCZ_TOUCHDATA_EP,
                                                  TCZ_TOUCHDATA_EPDIR,
                                                  &filter);
      return;
    }

    case PDEV_EVENT_RESET:
    case PDEV_EVENT_RESUME:
    case PDEV_EVENT_SUSPEND:
    default:
      break;
  }

  pdev_device_invoke_event_handler (&per->down.sc->next_device_event,
                                    event, per);
}

static int
tcz_probe (device_t dev)
{
  struct usb_attach_arg *uaa = device_get_ivars(dev);

  if (uaa->usb_mode != USB_MODE_HOST)
  {
    return (ENXIO);
  }

  if ((uaa->info.idVendor == TCZ_VENDOR) &&
      (uaa->info.idProduct == TCZ_PRODUCT))
  {
    struct pdev_down_softc* sc;
    pdev_device_event_t     tcz_device_event;

    tcz_device_event.handler = tcz_event_handler;
    tcz_device_event.user    = malloc (sizeof (tcz_data_t),
                                       M_TEMP, M_WAITOK | M_ZERO);

    if (tcz_device_event.user)
    {
      sc = device_get_softc (dev);
      sc->next_device_event = pdev_device_event_hook (&tcz_device_event);
      return 0;
    }
  }

  return ENXIO;
}

static device_method_t tcz_methods[] = {
  DEVMETHOD(device_probe,  tcz_probe),
  DEVMETHOD(device_attach, pdev_attach_down_device),
  DEVMETHOD(device_detach, pdev_detach_down_device),
  {0, 0}
};
static driver_t tcz_driver = {
  .name = "tcz",
  .methods = tcz_methods,
  .size = sizeof(struct pdev_down_softc),
};

static devclass_t tcz_devclass;

DRIVER_MODULE(tcz, uhub, tcz_driver, tcz_devclass, NULL, 0);

#if 0
static pdev_device_event_t device_event_hook;

static void
configure_final (void *dummy)
{
}

SYSINIT(tcz_config, SI_SUB_CONFIGURE, SI_ORDER_ANY, configure_final, NULL);

#endif
