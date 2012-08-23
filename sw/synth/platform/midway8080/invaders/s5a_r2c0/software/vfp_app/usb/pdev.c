/*-
 * Copyright (c) 1998 The NetBSD Foundation, Inc. All rights reserved.
 * Copyright (c) 1998 Lennart Augustsson. All rights reserved.
 * Copyright (c) 2008-2010 Hans Petter Selasky. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Based on the USB hub code.
 */

#include "usb.h"
#include "usbdi.h"
#include "usbdi_util.h"

#define  USB_DEBUG_VAR pdev_debug

#include "usb_core.h"
#include "usb_process.h"
#include "usb_device.h"
#include "usb_request.h"
#include "usb_debug.h"
#include "usb_hub.h"
#include "usb_util.h"
#include "usb_busdma.h"
#include "usb_transfer.h"
#include "usb_dynamic.h"

#include "usb_controller.h"
#include "usb_bus.h"

#include "pdev.h"

#ifdef USB_DEBUG
int pdev_debug = USB_DEBUG_DEFAULT;
#endif

struct pdev_softc {
  device_t            sc_dev;         /* base device */
  struct mtx          sc_mtx;         /* our mutex */
  struct usb_device  *sc_udev;        /* USB device */
  uint8_t             sc_flags;
  char                sc_name[32];
  periph_t*           per;
  pdev_device_event_t event_handler;
};

/* prototypes for type checking: */
static device_probe_t   pdev_probe;
static device_attach_t  pdev_attach;
static device_detach_t  pdev_detach;
static device_suspend_t pdev_suspend;
static device_resume_t  pdev_resume;

/*
 * Driver instance for "peripherals".
 */
static devclass_t pdev_devclass;

static device_method_t pdev_methods[] = {
  DEVMETHOD(device_probe, pdev_probe),
  DEVMETHOD(device_attach, pdev_attach),
  DEVMETHOD(device_detach, pdev_detach),
	DEVMETHOD(device_shutdown, bus_generic_shutdown),
  DEVMETHOD(device_suspend, pdev_suspend),
  DEVMETHOD(device_resume, pdev_resume),

	/* Bus interface */
	DEVMETHOD(bus_print_child, bus_generic_print_child),

  {0, 0}
};

static driver_t pdev_driver = {
  .name = "pdev",
  .methods = pdev_methods,
  .size = sizeof(struct pdev_softc)
};

DRIVER_MODULE(pdev, avalon, pdev_driver, pdev_devclass, NULL, 0);

static device_t
pdev_get_device (void)
{
  return devclass_get_device (pdev_devclass, 1);
}

static struct pdev_softc*
pdev_get_sc (void)
{
  device_t pdev = pdev_get_device ();
  if (!pdev)
    return NULL;
  return device_get_softc (pdev);
}

static int
pdev_probe (device_t dev)
{
  DPRINTF ("\n"); 
  return (BUS_PROBE_DEFAULT);
 }

static int
pdev_attach (device_t dev)
{
  struct pdev_softc *sc = device_get_softc(dev);

  DPRINTF ("\n");

  sc->sc_dev = dev;

  mtx_init (&sc->sc_mtx, "PDEV mutex", NULL, MTX_DEF);

  snprintf (sc->sc_name, sizeof(sc->sc_name), "%s",
            device_get_nameunit(dev));

  return (0);
}

/*
 * Called from process context when the hub is gone.
 * Detach all devices on active ports.
 */
static int
pdev_detach (device_t dev)
{
  struct pdev_softc *sc = device_get_softc (dev);

  DPRINTF ("\n");
  
  mtx_destroy (&sc->sc_mtx);

  return (0);
}

int
pdev_suspend (device_t dev)
{
  DPRINTF ("\n");
  /* Sub-devices are not suspended here! */
  return (0);
}

int
pdev_resume (device_t dev)
{
  DPRINTF ("\n");
  /* Sub-devices are not resumed here! */
  return (0);
}

pdev_device_event_t
pdev_device_event_hook (pdev_device_event_t* event)
{
  struct pdev_softc*  sc;
  pdev_device_event_t old;

  old.handler = NULL;
  old.user    = NULL;
  
  sc = pdev_get_sc ();
  if (!sc)
  {
    DPRINTF ("no pdev found\n");
    return old;
  }

  mtx_lock (&sc->sc_mtx);
  
  old = sc->event_handler;
  sc->event_handler = *event;
  
  mtx_unlock (&sc->sc_mtx);
  
  return old;
}

static void
pdev_invoke_event_handler (pdev_event_t event, periph_t* per)
{
  struct pdev_softc* sc;

  sc = pdev_get_sc ();
  if (!sc)
  {
    DPRINTF ("no pdev found\n");
    return;
  }
  
  mtx_lock (&sc->sc_mtx);
  
  if (sc->event_handler.handler)
    sc->event_handler.handler (event, per, sc->event_handler.user);
  
  mtx_unlock (&sc->sc_mtx);
}

/**
 * @brief Print the name of the device followed by a colon, a space
 * and the result of calling vprintf() with the value of @p fmt and
 * the following arguments.
 *
 * @returns the number of characters printed
 */
int
pdev_device_printf (periph_t* per, const char * fmt, ...)
{
  usbdev_softc_t* sc = per->up.sc;
  va_list         ap;
  int             retval;

  retval = device_print_prettyname (sc->sc_dev);
  va_start (ap, fmt);
  retval += vprintf( fmt, ap);
  va_end (ap);
  return retval;
}

void
pdev_ep_decode (uint8_t  endpointno, uint8_t* ep, uint8_t* ep_dir)
{
  *ep     = endpointno & 0x7f;
  *ep_dir = (endpointno & 0x80) == 0 ? UE_DIR_OUT : UE_DIR_IN;
}

int
pdev_ep_index (uint8_t ep, uint8_t ep_dir)
{
  return ep + (ep_dir == UE_DIR_OUT ? 0 : 1);
}

void
pdev_ep_deindex (int ep_index, uint8_t* ep, uint8_t* ep_dir)
{
  *ep_dir = (ep_index & 1) == 0 ? UE_DIR_OUT : UE_DIR_IN;
  *ep     = ep_index >> 1;
}

periph_ep_ctrl_t*
pdev_ep_control_obtain (periph_t* per, uint8_t ep, uint8_t ep_dir)
{
  int epindex = pdev_ep_index (ep, ep_dir);

  if ((epindex < 0) || (epindex >= USB_EP_MAX))
  {
    DPRINTF ("EP control not found: ep=%d%c\n", ep,
             ep_dir == UE_DIR_IN ? 'I' : 'O');
    return NULL;
  }

  if (per->ep_ctrl[epindex].type == UE_TYPE_ANY)
    return NULL;

  DPRINTFN (30, "epc=%d:%c\n", ep, ep_dir == UE_DIR_IN ? 'I' : 'O');

  mtx_lock (&per->ep_ctrl[epindex].lock);

  return &per->ep_ctrl[epindex];
}

void
pdev_ep_control_release (periph_ep_ctrl_t* epc)
{
  DPRINTFN (30, "epc=%d:%c\n",
            epc->endpoint, epc->direction == UE_DIR_IN ? 'I' : 'O');
  mtx_unlock (&epc->lock);
}

static usb_error_t
pdev_ep_control_open (periph_ep_ctrl_t* epc, uint8_t ep,
                      uint8_t type, uint8_t dir, int max_size)
{
  if (epc->type == UE_TYPE_ANY)
  {
    epc->endpoint  = ep;
    epc->type      = type;
    epc->direction = dir;
    epc->max_size  = max_size;
    epc->xfer_len  = -1;
    epc->buffer = malloc (max_size, M_TEMP, M_WAITOK | M_ZERO);
    if (!epc->buffer)
      return USB_ERR_NOMEM;
    mtx_init (&epc->lock, "EPC", NULL, MTX_DEF);
  }
  return USB_ERR_NORMAL_COMPLETION;
}

static void
pdev_ep_control_close (periph_ep_ctrl_t* epc)
{
  if (epc->type != UE_TYPE_ANY)
  {
    mtx_destroy (&epc->lock);
    free (epc->buffer, 0);
    epc->type = UE_TYPE_ANY;
  }
}

periph_ep_filter_t
pdev_device_ep_filter_hook (periph_t*           per,
                            uint8_t             ep,
                            uint8_t             dir,
                            periph_ep_filter_t* filter)
{
  periph_ep_ctrl_t*  epc;
  periph_ep_filter_t old;

  old.handler = NULL;
  old.user    = NULL;
  
  epc = pdev_ep_control_obtain (per, ep, dir);
  if (epc)
  {
    old = epc->filter;
    epc->filter = *filter;
    pdev_ep_control_release (epc);
  }
  
  return old;
}

int
pdev_check_vendor_product (periph_t* per, uint16_t vendor, uint16_t product)
{
  return ((UGETW (per->down.udev->ddesc.idVendor) == vendor) &&
          (UGETW (per->down.udev->ddesc.idProduct) == product));
}

static void
pdev_dump_downstream (int level, struct usb_device* udev)
{
#if USB_DEBUG
  if (pdev_debug >= level)
  {
    printf ("Config Descriptor size = %ld\n", sizeof (usb_config_descriptor_t));
    printf (" cdesc.bLength = %d\n", udev->cdesc->bLength);
    printf (" cdesc.bDescriptorType = %d\n", udev->cdesc->bDescriptorType);
    printf (" cdesc.wTotalLength = %d\n", (udev->cdesc->wTotalLength[0] << 8) | udev->cdesc->wTotalLength[1]);
    printf (" cdesc.bNumInterface = %d\n", udev->cdesc->bNumInterface);
    printf (" cdesc.bConfigurationValue = %d\n",
            udev->cdesc->bConfigurationValue);
    printf (" cdesc.iConfiguration = %d\n", udev->cdesc->iConfiguration);
    printf (" cdesc.bmAttributes = %02x\n", udev->cdesc->bmAttributes);
    printf (" cdesc.bMaxPower = %dmA\n", udev->cdesc->bMaxPower * 2);
  }
#endif
}

static void
pdev_dump_ep (usb_endpoint_descriptor_t* epd)
{
#if USB_DEBUG
  char tt;
  switch (UE_GET_XFERTYPE (epd->bmAttributes))
  {
    case UE_CONTROL:
      tt = 'C';
      break;
    case UE_ISOCHRONOUS:
      tt = 'i';
      break;
    case UE_BULK:
      tt = 'B';
      break;
    case UE_INTERRUPT:
      tt = 'I';
      break;
    default:
      tt = '?';
      break;
  }
  DPRINTFN (15, "endpoint: DT=%d DIR=%c ADDR=%d TT=%c MS=%d INT=%d\n",
            epd->bDescriptorType,
            UE_GET_DIR (epd->bEndpointAddress) == UE_DIR_IN ? 'I' : 'O',
            UE_GET_ADDR (epd->bEndpointAddress),
            tt, UGETW (epd->wMaxPacketSize), epd->bInterval);
#endif
}

static void
pdev_dump_data (int level, const void* vdata, int len)
{
#if USB_DEBUG
  if (pdev_debug >= level)
  {
    const uint8_t* data = vdata;
    int b;
    int m;
    for (b = 0, m = 0; b < len; ++b, ++m, ++data)
    {
      if (m == 16)
      {
        m = 0;
        printf ("\n");
      }
      if (m == 0)
        printf ("%03d-", b);
      printf ("%02x%c", *data, m == 8 ? '-' : ' ');
    }
    if (m)
      printf ("\n");
  }
#endif
}

static void
pdev_dump_setup (int level, usb_device_request_t* req)
{
#if USB_DEBUG
  DPRINTFN (level, "bmRequestType=%02x bRequest=%d " \
            "wValue=[%02x,%02x] wLength=%d\n",
            req->bmRequestType, req->bRequest,
            req->wValue[0], req->wValue[1], UGETW (req->wLength));
  pdev_dump_data (level, req, sizeof (*req));

#endif
}

static void
pdev_up_ctrl_send_ack (struct periph* per, uint8_t ep)
{
  usb_error_t err = usbdev_queue_xfer (per->up.sc, OXU210_EP_IN_IDX (ep), 0, 0);
  if (err != USB_ERR_NORMAL_COMPLETION)
    pdev_device_printf (per, "error: xfer queue ACK resp:ep=%d:%s\n",
                   ep, usbd_errstr (err));
}

static usb_error_t
pdev_up_ep_send_data (struct periph* per, uint8_t ep, const void* data, int len)
{
  usb_error_t err;
  usbdev_unstall_ep (per->up.sc, ep);
  err = usbdev_queue_xfer (per->up.sc, OXU210_EP_IN_IDX (ep), data, len);
  if (err != USB_ERR_NORMAL_COMPLETION)
    pdev_device_printf (per, "error: xfer queue:ep=%d:%s\n", ep, usbd_errstr (err));
  return err;
}

static void
pdev_up_ep_prime (struct periph* per, uint8_t ep, int len)
{
  if (!usbdev_ep_primed (per->up.sc, OXU210_EP_OUT_IDX (ep)))
  {
    usb_error_t err;
    err = usbdev_queue_xfer (per->up.sc, OXU210_EP_OUT_IDX (ep), 0, len);
#ifdef USB_DEBUG
    if (err != USB_ERR_NORMAL_COMPLETION)
      pdev_device_printf (per, "error: prime endpoint:ep=%d:%s\n",
                     ep, usbd_errstr (err));
#endif
  }
}

static void
pdev_up_ctrl_send_data (struct periph* per, uint8_t ep,
                        const void* data, int len, int max_len)
{
  usb_error_t err;

  if (len > max_len)
    len = max_len;

  err = pdev_up_ep_send_data (per, ep, data, len);
  if (err == USB_ERR_NORMAL_COMPLETION)
    pdev_up_ep_prime (per, ep, OXU210_PTD_BUFSIZE);
}

static void
pdev_up_ep_send (struct periph*    per,
                 periph_ep_ctrl_t* epc,
                 periph_ep_data_t* epd)
{
  usb_error_t err;

  DPRINTFN (11, "ep=%d:%c sending=%d\n", epc->endpoint,
            epc->direction == UE_DIR_IN ? 'I' : 'O', epd->len);
  
  if (epc->type == UE_INTERRUPT)
    usbdev_flush_and_clear_endpoint (per->up.sc,
                                     OXU210_EP_IN_IDX (epc->endpoint));

  if (epd->len > epc->max_size)
    epd->len = epc->max_size;

  err = usbdev_queue_xfer (per->up.sc, OXU210_EP_IN_IDX (epc->endpoint),
                           epd->data, epd->len);
  if (err != USB_ERR_NORMAL_COMPLETION)
    pdev_device_printf (per, "error: ep send:ep=%d:%s\n",
                   epc->endpoint, usbd_errstr (err));
}

static void
pdev_up_ctrl_send_str_unicode (struct periph* per, uint8_t ep,
                               const char* str, int len)
{
  uint8_t  buf[128 + 2];
  int      slen = strlen (str);
  int      blen = (slen * 2) + 2;
  uint8_t* out = buf;
  int      i;

  DPRINTFN (25, "len=%d slen=%d blen=%d s='%s'\n", len, slen, blen, str);

  memset (buf, 0, sizeof (buf));
  
  *out = blen;
  ++out;
  *out = 3;
  ++out;

  for (i = 0; i < ((sizeof (buf) - 2) / 2); ++i, ++str, out += 2)
    *out = *str;

  pdev_up_ctrl_send_data (per, ep, buf, len, blen);
}

static void
pdev_down_sender (void* arg)
{
  periph_t* per = arg;

  while (per->downstream_state == PERIPH_THREAD_RUNNING)
  {
    unsigned int out;
    int          check = 1;

    DPRINTFN (10, "sleeping\n");

    os_events_receive (&per->downstream_wait, 1, &out, 0);
    if (per->downstream_state != PERIPH_THREAD_RUNNING)
      break;
    
    DPRINTFN (10, "running\n");
    
    while (check)
    {
      int e;
      check = 0;
      for (e = 0; e < USB_EP_MAX; ++e)
      {
        periph_ep_ctrl_t* epco;
        uint8_t           ep;
        uint8_t           ep_dir;

        pdev_ep_decode (e, &ep, &ep_dir);

        if (ep_dir == UE_DIR_IN)
          continue;
        
        epco = pdev_ep_control_obtain (per, ep, UE_DIR_OUT);

        if (!epco)
          continue;
        
        DPRINTFN (30, "ep=%d:O xfer_len=%d\n", ep, epco->xfer_len);
        
        if (epco->xfer_len >= 0)
        {
          struct usb_device_request* req;
          usb_error_t                err;
          uint16_t                   sent;
          
          req = (struct usb_device_request*) epco->buffer;
          
          err = usbd_do_request_flags (per->down.udev, NULL, req,
                                       epco->buffer, 0, &sent, 500);
          
          DPRINTFN (30, "ep=%d: request=%s\n", epco->endpoint, usbd_errstr (err));
          
          if (err != USB_ERR_NORMAL_COMPLETION)
          {
#ifdef USB_DEBUG
            DPRINTFN (1, "error: down ep send:ep=%d:%s\n",
                      epco->endpoint, usbd_errstr (err));
#endif
            /*
             * Send an error back up stream using a stall.
             */
            if (err != USB_ERR_TIMEOUT)
              usbdev_stall_ep (per->up.sc, e);
          }
          else
          {
            periph_ep_data_t epd;

            DPRINTFN (30, "ep=%d:I sending up:%d\n", e / 2, sent);

            epd.data = epco->buffer;
            epd.len = sent;

            pdev_dump_data (1, epd.data, epd.len);

            if (epco->endpoint == USB_CONTROL_ENDPOINT)
              pdev_up_ctrl_send_data (per, epco->endpoint,
                                      epd.data, epd.len, epco->max_size);
            else
              pdev_up_ep_send (per, epco, &epd);
          }

          epco->xfer_len = -1;
          check = 1;
        }
        
        pdev_ep_control_release (epco);
      }
    }
  }

  per->downstream_state = PERIPH_THREAD_STOPPED;

  os_thread_del_self ();
}

static int
pdev_down_ep_send_data (struct periph* per,
                        uint8_t        ep_index,
                        void*          data,
                        int            len)
{
  periph_ep_ctrl_t* epc;
  uint8_t           ep;
  uint8_t           ep_dir;
  
  pdev_ep_deindex (ep_index, &ep, &ep_dir);

  DPRINTFN (10, "ep=%d:%c len=%d\n", ep, ep_dir == UE_DIR_IN ? 'I' : 'O', len);
  
  epc = pdev_ep_control_obtain (per, ep, ep_dir);
  if (epc)
  {
    if (len > epc->max_size)
      len = epc->max_size;
    if (ep == USB_CONTROL_ENDPOINT)
    {
      epc->xfer_len = len;
      memcpy (epc->buffer, data, len);
      os_events_send (&per->downstream_wait, &per->downstream_thread);
    }
    else
    {
      if (epc->xfer_len >= 0)
      {
        int e;
        memcpy (epc->buffer, data, len);
        for (e = 0; e < per->down.endpoints; ++e)
        {
          if (per->down.configs[e].endpoint == ep)
          {
            usbd_transfer_start (per->down.xfers[e]);
            break;
          }
        }
      }
    }
    pdev_ep_control_release (epc);
  }

  return 1;
}

static void
pdev_up_event (void* sc, usbdev_event_t evt, int arg)
{
  struct periph* per = sc;
  periph_up_t*   up = &per->up;
  
  switch (evt)
  {
    case EVENT_CONNECT:
      DPRINTFN (5, "event: connect\n");
      break;

    case EVENT_CONFIGURED:
      DPRINTFN (5, "event: configured: %d\n", arg);
      if (arg)
      {
        struct usb_device* udev = per->down.udev;
        struct {
          int in_type;
          int in_max;
          int out_type;
          int out_max;
        } endpoints[USB_EP_MAX / 2];
        int e;
        
        DPRINTFN (10, "event: configured: end points=%d\n", per->down.endpoints);
        
        memset (endpoints, -1, sizeof (endpoints));
        
        /*
         * Create a table of configured endponts.
         */
        for (e = 0; e < udev->endpoints_max; ++e)
        {
          usb_endpoint_descriptor_t* epd = udev->endpoints[e].edesc;
          int ep = UE_GET_ADDR (epd->bEndpointAddress);
          pdev_dump_ep (epd);
          if (ep < (USB_EP_MAX / 2))
          {
            if (UE_GET_DIR (epd->bEndpointAddress) == UE_DIR_IN)
            {
              endpoints[ep].in_type = UE_GET_DIR (epd->bEndpointAddress);
              endpoints[ep].in_max = UGETW (epd->wMaxPacketSize);
            }
            else
            {
              endpoints[ep].out_type = UE_GET_DIR (epd->bEndpointAddress);
              endpoints[ep].out_max = UGETW (epd->wMaxPacketSize);
            }
          }
        }

        /*
         * Program these end points.
         */
        for (e = 0; e < (USB_EP_MAX / 2); ++e)
        {
          if ((endpoints[e].in_max > 0) || (endpoints[e].out_max > 0))
          {
            usbdev_set_ep_enable (up->sc, e,
                                  endpoints[e].in_max, endpoints[e].in_type,
                                  endpoints[e].out_max, endpoints[e].out_type);
            /*
             * If the end point OUT is enabled queue a buffer.
             */
            if (endpoints[e].out_max > 0)
              pdev_up_ep_prime (per, e, endpoints[e].out_max);
          }
        }
        
        per->up.dev_config = 1;
        pdev_invoke_event_handler (PDEV_EVENT_CONFIGURE, per);
        break;
      }
      
      /* drop through if arg is false */
      
    case EVENT_RESET:
      DPRINTFN (10, "event: reset\n");
      per->up.dev_config = 0;     
      usbdev_set_ep_disable_all (up->sc);
      pdev_invoke_event_handler (PDEV_EVENT_RESET, per);
      break;

	case EVENT_SUSPEND:
		if(arg)
    {
			DPRINTFN (10, "suspend\n");
      pdev_invoke_event_handler (PDEV_EVENT_SUSPEND, per);
    }
		else
    {
			DPRINTFN (10, "resume\n");
      pdev_invoke_event_handler (PDEV_EVENT_RESUME, per);
    }
		break;
    
    default:
      break;
  }
}

static int
pdev_up_setup (void* sc, uint8_t ep, usb_device_request_t* req)
{
  struct periph*     per = sc;
  periph_up_t*       up = &per->up;
  periph_down_t*     down = &per->down;
  struct usb_device* udev = down->udev;
  uint16_t           resp_len;

  pdev_dump_setup (13, req);
  
  resp_len = UGETW (req->wLength);
  
  /*
   * Pass all but EP0 requests downstream.
   */
  if (ep == USB_CONTROL_ENDPOINT)
  {
    if (req->bmRequestType == UT_READ_DEVICE)
    {
      const unsigned char usb_string_unicode[] = { 4, 3, 9, 4 };

      switch (req->bRequest)
      {
        case UR_GET_DESCRIPTOR:
          switch (req->wValue[1])
          {
            case UDESC_DEVICE:
              DPRINTFN (12, " udesc: device\n");
              pdev_up_ctrl_send_data (per, ep, &udev->ddesc,
                                      resp_len, sizeof (udev->ddesc));
              return 1;
          
            case UDESC_CONFIG:
              DPRINTFN (12, " udesc: config\n");
              pdev_up_ctrl_send_data (per, ep, udev->cdesc,
                                      resp_len,
                                      UGETW (udev->cdesc->wTotalLength));
              return 1;

            case UDESC_STRING:
              /*
               * Handle 3 strings that are the serial number,
               * manufacturer and product. Make all unicode.
               */
              switch (req->wValue[0])
              {
                case 0:
                  DPRINTFN (12, "unicode string\n");
                  pdev_up_ctrl_send_data (per, ep, usb_string_unicode,
                                          resp_len, sizeof (usb_string_unicode));
                  return 1;
                
                case 1:
                  DPRINTFN (12, "manufacture: %s\n", udev->manufacturer);
                  pdev_up_ctrl_send_str_unicode (per, ep,
                                                 udev->manufacturer, resp_len);
                  return 1;

                case 2:
                  DPRINTFN (12, "product: %s\n", udev->product);
                  pdev_up_ctrl_send_str_unicode (per, ep,
                                                 udev->product, resp_len);
                  return 1;

                case 3:
                  DPRINTFN (12, "serial: %s\n", udev->serial);
                  pdev_up_ctrl_send_str_unicode (per, ep,
                                                 udev->serial, resp_len);
                  return 1;
              
                default:
                  break;
              }
              break;

            default:
              break;
          }
          break;
          
        case UR_GET_CONFIG:
          DPRINTFN (12, "get config\n");
          pdev_up_ctrl_send_data (per, ep, &per->up.dev_config, resp_len, 1);
          return 1;

        default:
          break;
      }
    }
    else if (req->bmRequestType == UT_WRITE_DEVICE)
    {
      switch (req->bRequest)
      {
        case UR_SET_ADDRESS:
          DPRINTFN (12, "set address\n");
          usbdev_set_address (up->sc, req->wValue[0] & 0x7f);
          pdev_up_ctrl_send_ack (per, ep);
          return 1;

        case UR_SET_CONFIG:
          DPRINTFN (12, "set config: %02x:%02x\n",
                    req->wValue[0], req->wValue[1]);
          pdev_up_ctrl_send_ack (per, ep);
          pdev_up_event (per, EVENT_CONFIGURED, UGETB (req->wValue));
          return 1;

        default:
          break;
      }
    }
  }

  return pdev_down_ep_send_data (per, ep, req, sizeof (*req));
}

static int
pdev_up_complete (void* sc, uint8_t ep, oxu210_ptd_t* ptd, ptd_status_t status)
{
  /* struct periph* per = sc; */
  /* periph_up_t*   up = &per->up; */
  /* int            rv = 1; */

  DPRINTFN (15, "ep=%d ptd=%p s=%d\n", ep, ptd, status);
  
  return 1;
}

static void
pdev_down_in_callback (struct usb_xfer* xfer, usb_error_t error)
{
  periph_t*              per = usbd_xfer_softc (xfer);
  struct usb_page_cache* pc;
  periph_ep_ctrl_t*      epc;
  periph_ep_data_t       epd;
  periph_ep_resp_t       epr = periph_ep_send;
  uint8_t                ep;
  uint8_t                ep_dir;
  
  usbd_xfer_status (xfer, &epd.len, NULL, NULL, NULL);

  pdev_ep_decode (xfer->endpointno, &ep, &ep_dir);
  
  DPRINTFN (15, "ep=%d:%c state=%d error=%s len=%d\n",
            ep, ep_dir == UE_DIR_IN ? 'I' : 'O',
            USB_GET_STATE (xfer), usbd_errstr (error), epd.len);

  epc = pdev_ep_control_obtain (per, ep, ep_dir);
  if (epc)
  {
    switch (USB_GET_STATE(xfer))
    {
      case USB_ST_TRANSFERRED:
        if (error == USB_ERR_NORMAL_COMPLETION)
        {
          pc = usbd_xfer_get_frame (xfer, 0);
          if (epd.len > epc->max_size)
            epd.len = epc->max_size;
          epd.data = epc->buffer;
          usbd_copy_out (pc, 0, epd.data, epd.len);
          if (epc->filter.handler)
            epr = epc->filter.handler (per, epc, &epd, epc->filter.user);
          if (epr == periph_ep_send)
            pdev_up_ep_send (per, epc, &epd);
        }
        
        /* drop through */
      
      case USB_ST_SETUP:
        usbd_xfer_set_frame_len (xfer, 0, usbd_xfer_max_len (xfer));
        usbd_transfer_submit (xfer);
        break;

      default:
        /*
         * On any error other than cancelled try and clear a stall first.
         */
        if (error != USB_ERR_CANCELLED)
        {
        usbd_xfer_set_stall (xfer);
        usbd_xfer_set_frame_len (xfer, 0, usbd_xfer_max_len (xfer));
        usbd_transfer_submit (xfer);
        }
        break;
    }

    pdev_ep_control_release (epc);
  }
}

static void
pdev_down_out_callback(struct usb_xfer* xfer, usb_error_t error)
{
  periph_t*         per = usbd_xfer_softc (xfer);
  periph_ep_ctrl_t* epc;
  periph_ep_data_t  epd;
  periph_ep_resp_t  epr = periph_ep_send;
  uint8_t           ep;
  uint8_t           ep_dir;
  
  pdev_ep_decode (xfer->endpointno, &ep, &ep_dir);
  
  DPRINTFN (15, "ep=%d:%c state=%d\n",
            ep, ep_dir == UE_DIR_IN ? 'I' : 'O', USB_GET_STATE (xfer));

  switch (USB_GET_STATE(xfer))
  {
    default:
      /*
       * Error ?
       */
      if (error == USB_ERR_CANCELLED)
        break;
         
      /*
       * Try to clear stall first
       */
      usbd_xfer_set_stall(xfer);

    case USB_ST_SETUP:
    case USB_ST_TRANSFERRED:
      epc = pdev_ep_control_obtain (per, ep, ep_dir);
      if (epc->xfer_len >= 0)
      {
        epd.data = epc->buffer;
        epd.len = epc->xfer_len;
        if (epc->filter.handler)
          epr = epc->filter.handler (per, epc, &epd, epc->filter.user);
        if (epr == periph_ep_send)
        {
          struct usb_page_cache* pc;
          pc = usbd_xfer_get_frame (xfer, 0);
          usbd_copy_in (pc, 0, epd.data, epd.len);
          usbd_xfer_set_frame_len (xfer, 0, epd.len);
          usbd_transfer_submit (xfer);
        }
        epc->xfer_len = -1;
      }
      pdev_ep_control_release (epc);
      break;
  }
}

static usb_error_t
pdev_setup_pipes (periph_t* per)
{
  periph_down_t*       down = &per->down;
  struct usb_device*   udev = down->udev;
  struct usb_endpoint* uep;
  struct usb_endpoint* uep_end;
  struct usb_config*   config;
  periph_ep_ctrl_t*    epc;
  usb_error_t          err;
  int                  e;

  down->endpoints = udev->endpoints_max;
  down->configs = malloc (sizeof (struct usb_config) * down->endpoints,
                          M_TEMP, M_WAITOK | M_ZERO);
  if (!down->configs)
    return USB_ERR_NOMEM;

  /*
   * Need to set up the control end point controls.
   */
  epc = &per->ep_ctrl[pdev_ep_index (0, UE_DIR_OUT)];
  err = pdev_ep_control_open (epc, 0, UE_CONTROL, UE_DIR_OUT, 64);
  if (err != USB_ERR_NORMAL_COMPLETION)
  {
    DPRINTFN (0, "epc[0:O] open failed: %s\n", usbd_errstr (err));
    goto error_cleanup;
  }
  
  epc = &per->ep_ctrl[pdev_ep_index (0, UE_DIR_IN)];
  err = pdev_ep_control_open (epc, 0, UE_CONTROL, UE_DIR_IN, 64);
  if (err != USB_ERR_NORMAL_COMPLETION)
  {
    DPRINTFN (0, "epc[0:I] open failed: %s\n", usbd_errstr (err));
    goto error_cleanup;
  }

  uep     = udev->endpoints;
  uep_end = uep + udev->endpoints_max;
  config  = down->configs;
  
  for (; uep != uep_end; ++uep, ++config)
  {
    struct usb_endpoint_descriptor* epd;
    uint8_t                         ep;
    uint8_t                         ep_dir;

    epd    = uep->edesc;
    ep     = UE_GET_ADDR (epd->bEndpointAddress);
    ep_dir = UE_GET_DIR (epd->bEndpointAddress);

    epc = &per->ep_ctrl[pdev_ep_index (ep, ep_dir)];
    err = pdev_ep_control_open (epc, ep,
                                UE_GET_XFERTYPE (epd->bmAttributes),
                                ep_dir,
                                UGETW (epd->wMaxPacketSize));
    if (err != USB_ERR_NORMAL_COMPLETION)
    {
      DPRINTFN (0, "epc[%d:%c] open failed: %s\n", ep, ep_dir, usbd_errstr (err));
      goto error_cleanup;
    }

    config->type      = UE_GET_XFERTYPE (epd->bmAttributes);
    config->endpoint  = ep;
    config->direction = ep_dir;
    config->bufsize   = UGETW (epd->wMaxPacketSize);
    config->if_index  = uep->iface_index;
    
    if (config->direction == UE_DIR_IN)
      config->callback = pdev_down_in_callback;
    else
      config->callback = pdev_down_out_callback;

    config->flags.short_xfer_ok = 1;

    pdev_dump_ep (epd);
  }

  DPRINTFN (10, "setup downstream endpoints: %d\n", down->endpoints);
  
  err = usbd_transfer_setup (udev,
                             &down->iface_index, down->xfers, down->configs,
                             down->endpoints, per, down->mtx); 
  if (err != USB_ERR_NORMAL_COMPLETION)
  {
    DPRINTFN (0, "transfer setup failed: %s\n", usbd_errstr (err));
    goto error_cleanup;
  }

  DPRINTFN (10, "start downstream IN endpoints: %d\n", down->endpoints);

  for (e = 0; e < down->endpoints; ++e)
  {
    if ((down->configs[e].direction == UE_DIR_IN) ||
        (down->configs[e].direction == UE_DIR_ANY))
      usbd_transfer_start (down->xfers[e]);
  }

  return err;

error_cleanup:
  
  for (e = 0; e < USB_EP_MAX; ++e)
    pdev_ep_control_close (&per->ep_ctrl[e]);
  free (down->configs, 0);
  down->configs = NULL;

  return err;
}

int
pdev_attach_up_device (periph_t* per)
{
  struct pdev_softc* sc;
  device_t           pdev;
  int                error;

  pdev_dump_downstream (1, per->down.udev);
  
  pdev = pdev_get_device ();
  if (!pdev)
  {
    DPRINTF("no pdev found\n");
    return ENXIO;
  }

  sc = device_get_softc(pdev);
  sc->per = per;
  
  per->up.dev = device_add_child (pdev, "usbdev", 0);
  if (!per->up.dev)
    return ENXIO;
  
  device_set_ivars (per->up.dev, &per->udev_handlers);
  error = device_probe_and_attach (per->up.dev);
  if (error != 0)
  {
    device_delete_child (pdev, per->up.dev);
    return error;
  }

  per->up.sc = device_get_softc (per->up.dev);
  
  return 0;
}

int
pdev_detach_up_device (periph_t* per)
{
  if (per->up.dev)
  {
    device_t pdev;
  
    pdev = devclass_get_device (pdev_devclass, 1);
    if (!pdev) {
      DPRINTF("no pdev found\n");
      return ENXIO;
    }
  
    device_detach (per->up.dev);
    device_delete_child (pdev, per->up.dev);
  }
  return 0;
}

static periph_t*
pdev_attach_generic (periph_down_t* down)
{
  periph_t*   per;
  int         err;
  usb_error_t uerr;
  int         e;

  per = malloc (sizeof (periph_t), M_TEMP, M_WAITOK | M_ZERO);
  if (!per)
    return NULL;
  
  per->name = down->udev->product;
  
  per->udev_handlers.sc       = per;
  per->udev_handlers.event    = pdev_up_event;
  per->udev_handlers.setup    = pdev_up_setup;
  per->udev_handlers.complete = pdev_up_complete;
  
  per->down.udev        = down->udev;
  per->down.sc          = down->sc;
  per->down.mtx         = down->mtx;
  per->down.iface_index = down->iface_index;

  for (e = 0; e < USB_EP_MAX; ++e)
  {
    per->ep_ctrl[e].type = UE_TYPE_ANY;
    per->ep_ctrl[e].xfer_len = -1;
  }

  if (os_events_create (&per->downstream_wait, 0) != os_successful)
  {
    free (per, 0);
    return NULL;
  }
    
  per->downstream_state = PERIPH_THREAD_RUNNING;
  os_error_t oe = os_thread_create (&per->downstream_thread,
                                    pdev_down_sender,
                                    per, USB_USER_TASK_PRIORITY,
                                    PDEV_TASK_STACKSIZE, NULL);
  if (oe != os_successful)
  {
    per->downstream_state = PERIPH_THREAD_STOPPED;
    free (per, 0);
    return NULL;
  }

  /*
   * Send the attach event before the up stream device has connected so
   * any filters can be hooked.
   */
  pdev_invoke_event_handler (PDEV_EVENT_ATTACH, per);
  
  err = pdev_attach_up_device (per);
  if (err != 0)
  {
    free (per, 0);
    return NULL;
  }

  uerr = pdev_setup_pipes (per);
  if (uerr != USB_ERR_NORMAL_COMPLETION)
  {
    pdev_detach_up_device (per);
    free (per, 0);
    return NULL;
  }

  return per;
}

static void
pdev_detach_generic (periph_t* per)
{
  periph_down_t* down = &per->down;

  /*
   * Detach up stream first.
   */
  pdev_detach_up_device (per);

  /*
   * Send the detach event after the up stream device has detached so
   * any filters can be unhooked.
   */
  pdev_invoke_event_handler (PDEV_EVENT_DETACH, per);

  /*
   * Stop the down stream thread and then close the end point controls.
   */
  per->downstream_state = PERIPH_THREAD_STOPPING;
  while (per->downstream_state == PERIPH_THREAD_STOPPING)
  {
    os_events_send (&per->downstream_wait, &per->downstream_thread);
    usleep (100000);
  }
  if (down->configs)
  {
    int e;
    for (e = 0; e < USB_EP_MAX; ++e)
    {
      usbd_transfer_drain (down->xfers[e]);
      pdev_ep_control_close (&per->ep_ctrl[e]);
    }
    usbd_transfer_unsetup (down->xfers, down->endpoints);
    free (down->configs, 0);
  }

  free (per, 0);
}

int
pdev_attach_down_device (device_t dev)
{
  struct usb_attach_arg*  uaa = device_get_ivars(dev);
  struct pdev_down_softc* sc = device_get_softc(dev);
  periph_down_t           down;

  sc->sc_udev = uaa->device;
  sc->sc_unit = device_get_unit(dev);

  snprintf ((char*) sc->sc_name, sizeof(sc->sc_name), "%s",
            device_get_nameunit(dev));

  mtx_init (&sc->sc_mtx, "tc lock", NULL, MTX_DEF | MTX_RECURSE);

  mtx_lock (&sc->sc_mtx);
  
  device_set_usb_desc (dev);

  usb_callout_init_mtx (&sc->sc_callout, &sc->sc_mtx, 0);

  down.udev        = uaa->device;
  down.sc          = sc;
  down.mtx         = &sc->sc_mtx;
  down.iface_index = uaa->info.bIfaceIndex;
  
  sc->per = pdev_attach_generic (&down);
  if (!sc->per) {
    DPRINTF("pdev attach device failed\n");
    goto detach;
  }

  mtx_unlock (&sc->sc_mtx);
  return (0);      /* success */

detach:
  mtx_unlock (&sc->sc_mtx);
  pdev_attach_down_device (dev);
  return (ENXIO);
}

int
pdev_detach_down_device (device_t dev)
{
  struct pdev_down_softc *sc = device_get_softc(dev);

  if (sc->per)
    pdev_detach_generic (sc->per);
  
  usb_callout_drain(&sc->sc_callout);

  mtx_destroy(&sc->sc_mtx);

  return (0);
}
