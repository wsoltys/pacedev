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

#define TCM_VENDOR  (0x0596)
#define TCM_PRODUCT (0x0001)

#define TCM_TOUCHDATA_EP    (1)
#define TCM_TOUCHDATA_EPDIR (UE_DIR_IN)

typedef struct {
  periph_ep_filter_t old_in1;
} tcm_data_t;

typedef struct {
  uint8_t report_id;
  uint8_t loop_counter;
  uint8_t status;
  uint8_t x_compensated[2];
  uint8_t y_compensated[2];
  uint8_t x_raw[2];
  uint8_t y_raw[2];
} tcm_coord_data_r1_t;

#define CDGETW(_v) (((uint16_t) _v[1] << 8) | ((uint16_t) _v[0]))

static periph_ep_resp_t
tcm_touchdata_filter (periph_t*         per,
                      periph_ep_ctrl_t* epc,
                      periph_ep_data_t* epd,
                      void*             user)
{
  // passive if USB not selected
  if (ts_data->type != EE_TS_TYPE_AUTO && ts_data->type != EE_TS_TYPE_USB)
    return periph_ep_send;

  int hit = TS_HIT_NONE;

	uint16_t x, y;
  uint16_t hit_x, hit_y;
	uint8_t touch;

  tcm_coord_data_r1_t* cd = (tcm_coord_data_r1_t*) epd->data;
  #if 0
    printf ("3M COORD R1: id:%d loop-counter:%03d status:%02x x=%d/%d y=%d/%d\n",
            cd->report_id, cd->loop_counter, cd->status,
            CDGETW (cd->x_compensated), CDGETW (cd->x_raw),
            CDGETW (cd->y_compensated), CDGETW (cd->y_raw));
  #endif

  x = CDGETW (cd->x_compensated);
  y = CDGETW (cd->y_compensated);

  // Note : 3M coordinates are:
  //          -8192..+8191 (raw)
  //          0..65535 (compensated/calibrated)
  //        - Sentinel is expecting 0..16383
  x >>= 2;
  y >>= 2;

  // - sentinel packets are handled inside
  // - we only need to decide whether to pass up-stream or not
  touch = cd->status & 0xC0;
  if ((hit = handle_touch_event (touch, x, y, &hit_x, &hit_y)) != TS_HIT_EGM)
    return (periph_ep_drop);

  // rescale to 0..65535 --- WTF???? this is WRONG!!!
  x <<= 2;
  y <<= 2;
  // patch upstream packet
  cd->x_compensated[0] = hit_x & 0xFF;
  cd->x_compensated[1] = (hit_x >> 8) & 0xFF;
  cd->y_compensated[0] = hit_y & 0xFF;
  cd->y_compensated[1] = (hit_y >> 8) & 0xFF;
    
  return periph_ep_send;
}

static void
tcm_event_handler (pdev_event_t event, periph_t* per, void* user)
{
  tcm_data_t* tcmd = user;
  switch (event)
  {
    case PDEV_EVENT_ATTACH:
      if (pdev_check_vendor_product (per, TCM_VENDOR, TCM_PRODUCT))
      {
        //printf ("PDEV_EVENT_ATTACH\n");
        
        ts_auto_attached = EE_TS_TYPE_USB;
        ts_auto_vendor_id = TCM_VENDOR;
        ts_auto_product_id = TCM_PRODUCT;
        return;
      }
      break;
      
    case PDEV_EVENT_DETACH:
      ts_auto_attached = EE_TS_TYPE_NONE;
      pdev_device_ep_filter_hook (per,
                                  TCM_TOUCHDATA_EP,
                                  TCM_TOUCHDATA_EPDIR,
                                  &tcmd->old_in1);
      pdev_device_event_hook (&per->down.sc->next_device_event);
      free (tcmd, 0);
      break;
      
    case PDEV_EVENT_CONFIGURE:
    {
      periph_ep_filter_t filter;
      filter.handler = tcm_touchdata_filter;
      filter.user    = user;
      
      //printf ("PDEV_EVENT_CONFIGURE\n");
        
      // always hook the filter
      // because if we switch from serial->USB
      // it will automatically start working
      tcmd->old_in1 = pdev_device_ep_filter_hook (per,
                                                  TCM_TOUCHDATA_EP,
                                                  TCM_TOUCHDATA_EPDIR,
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
tcm_probe (device_t dev)
{
  struct usb_attach_arg *uaa = device_get_ivars(dev);

  if (uaa->usb_mode != USB_MODE_HOST)
  {
    return (ENXIO);
  }

  if ((uaa->info.idVendor == TCM_VENDOR) &&
      (uaa->info.idProduct == TCM_PRODUCT))
  {
    struct pdev_down_softc* sc;
    pdev_device_event_t     tcm_device_event;

    tcm_device_event.handler = tcm_event_handler;
    tcm_device_event.user    = malloc (sizeof (tcm_data_t),
                                       M_TEMP, M_WAITOK | M_ZERO);

    if (tcm_device_event.user)
    {
      sc = device_get_softc (dev);
      sc->next_device_event = pdev_device_event_hook (&tcm_device_event);
      return 0;
    }
  }

  return ENXIO;
}

static device_method_t tcm_methods[] = {
  DEVMETHOD(device_probe,  tcm_probe),
  DEVMETHOD(device_attach, pdev_attach_down_device),
  DEVMETHOD(device_detach, pdev_detach_down_device),
  {0, 0}
};
static driver_t tcm_driver = {
  .name = "tcm",
  .methods = tcm_methods,
  .size = sizeof(struct pdev_down_softc),
};

static devclass_t tcm_devclass;

DRIVER_MODULE(tcm, uhub, tcm_driver, tcm_devclass, NULL, 0);
