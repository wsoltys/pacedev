
#include "usb.h"
#include "usbdi.h"
#include "usbdi_util.h"
#include "usbhid.h"

#define	USB_DEBUG_VAR joy_debug
#include "usb_debug.h"

int	joy_debug = 1;

#define JOY_INTR_DT 0
#define JOY_N_TRANSFER 1

struct joy_softc 
{
	struct mtx sc_mtx;
	struct usb_callout sc_callout;

	struct usb_device *sc_udev;
 	struct usb_xfer *sc_xfer[JOY_N_TRANSFER];

	uint8_t	sc_name[16];
	uint8_t	sc_buf[64];
};

/* prototypes */

static device_probe_t joy_probe;
static device_attach_t joy_attach;
static device_detach_t joy_detach;

extern void joy_event (uint8_t *buf, uint16_t len);

static void
joy_intr_callback(struct usb_xfer *xfer, usb_error_t error)
{
	struct joy_softc *sc = usbd_xfer_softc(xfer);
  //struct ums_info *info = &sc->sc_info[0];
	struct usb_page_cache *pc;
	uint8_t *buf = sc->sc_buf;
	int len;

	usbd_xfer_status(xfer, &len, NULL, NULL, NULL);

  //printf ("state=%d\n", USB_GET_STATE(xfer));

	switch (USB_GET_STATE(xfer)) 
	{
  	case USB_ST_TRANSFERRED:
  		//printf ("sc=%p actlen=%d\n", sc, len);
  		if (len > sizeof(sc->sc_buf)) 
		  {
  			DPRINTFN(6, "truncating large packet to %zu bytes\n",
  			    sizeof(sc->sc_buf));
  			len = sizeof(sc->sc_buf);
  		}
  		if (len == 0)
  			goto tr_setup;
  
  		pc = usbd_xfer_get_frame(xfer, 0);
  		usbd_copy_out(pc, 0, buf, len);
  		#if 0
  		  //if ((buf[0] | buf[1] | buf[2] | buf[3] | buf[4] | buf[5] | buf[6] | buf[7]) != 0)
      		printf("data = %02x %02x %02x %02x "
      			"%02x %02x %02x %02x\n",
      			(len > 0) ? buf[0] : 0, (len > 1) ? buf[1] : 0,
      			(len > 2) ? buf[2] : 0, (len > 3) ? buf[3] : 0,
      			(len > 4) ? buf[4] : 0, (len > 5) ? buf[5] : 0,
      			(len > 6) ? buf[6] : 0, (len > 7) ? buf[7] : 0);
      #endif
      joy_event (buf, len);
      // fall thru
        
  	case USB_ST_SETUP:
      tr_setup:
  			usbd_xfer_set_frame_len(xfer, 0, usbd_xfer_max_len(xfer));
  			usbd_transfer_submit(xfer);
  		break;
  
  	default:			/* Error */
  		if (error != USB_ERR_CANCELLED)
		  {
  			/* try clear stall first */
  			usbd_xfer_set_stall(xfer);
  			goto tr_setup;
  		}
		  break;
	}
}

static const struct usb_config joy_config[JOY_N_TRANSFER] = {

	[JOY_INTR_DT] = {
		.type = UE_INTERRUPT,
		.endpoint = UE_ADDR_ANY,
		.direction = UE_DIR_IN,
		.flags = {.pipe_bof = 1,.short_xfer_ok = 1,},
		.bufsize = 0,	/* use wMaxPacketSize */
		.callback = &joy_intr_callback,
	},
};

static int
joy_probe(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);
	void *d_ptr;
	int error;
	uint16_t d_len;

	if (uaa->usb_mode != USB_MODE_HOST)
		return (ENXIO);

	if (uaa->info.bInterfaceClass != UICLASS_HID)
		return (ENXIO);

	if (usbd_req_get_hid_desc(uaa->device, NULL,
	    &d_ptr, &d_len, M_TEMP, uaa->info.bIfaceIndex))
	  return (ENXIO);

	if (hid_is_collection(d_ptr, d_len,
	    HID_USAGE2(HUP_GENERIC_DESKTOP, HUG_JOYSTICK)))
  {
    printf ("%s() - HUP_GENERIC_DESKTOP:HUG_JOYSTICK detected!\n",
            __FUNCTION__);
		error = BUS_PROBE_GENERIC;
	}
	else
		error = ENXIO;

	free(d_ptr, M_TEMP);

	return (error);
}

static int
joy_attach(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);
	struct joy_softc *sc = device_get_softc(dev);
	int error;

	sc->sc_udev = uaa->device;

	snprintf((char*)sc->sc_name, sizeof(sc->sc_name), "%s",
	    device_get_nameunit(dev));

	mtx_init(&sc->sc_mtx, "joy lock", NULL, MTX_DEF | MTX_RECURSE);

	device_set_usb_desc(dev);

 	usb_callout_init_mtx(&sc->sc_callout, &sc->sc_mtx, 0);

	error = usbd_transfer_setup(uaa->device,
      	    &uaa->info.bIfaceIndex, sc->sc_xfer, joy_config,
      	    JOY_N_TRANSFER, sc, &sc->sc_mtx);

	if (error) {
		DPRINTF("error=%s\n", usbd_errstr(error));
		goto detach;
	}

	usbd_transfer_start(sc->sc_xfer[JOY_INTR_DT]);
	return (0);			/* success */

detach:
	joy_detach(dev);
	return (ENXIO);
}

static int
joy_detach(device_t dev)
{
	struct joy_softc *sc = device_get_softc(dev);

//	usb_fifo_detach(&sc->sc_fifo);

	usbd_transfer_unsetup(sc->sc_xfer, JOY_N_TRANSFER);

	usb_callout_drain(&sc->sc_callout);

	mtx_destroy(&sc->sc_mtx);

	return (0);
}

devclass_t joy_devclass;

static device_method_t joy_methods[] = {
	DEVMETHOD(device_probe, joy_probe),
	DEVMETHOD(device_attach, joy_attach),
	DEVMETHOD(device_detach, joy_detach),
	{0, 0}
};

static driver_t joy_driver = {
	.name = "joy",
	.methods = joy_methods,
	.size = sizeof(struct joy_softc),
};

DRIVER_MODULE(joy, uhub, joy_driver, joy_devclass, NULL, 0);
MODULE_DEPEND(joy, usb, 1, 1, 1);
MODULE_VERSION(joy, 1);
