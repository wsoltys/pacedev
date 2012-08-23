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
#include "usbdi_util.h"

#define	USB_DEBUG_VAR tc_debug

int	tc_debug = 1;

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

#define	TC_CMD0		0x00
#define	TC_CMD_SET_FREQ	0x01
#define	TC_CMD2		0x02

#define TC_INTR_DT 0
#define TC_N_TRANSFER 1

struct tc_softc {
	struct usb_fifo_sc sc_fifo;
	struct mtx sc_mtx;
	struct usb_callout sc_callout;

	struct usb_device *sc_udev;

   	struct usb_xfer *sc_xfer[TC_N_TRANSFER];

	uint32_t sc_unit;
	uint32_t sc_freq;

	uint8_t	sc_name[16];
	uint8_t	sc_temp[64];
};

/* prototypes */

static device_probe_t tc_probe;
static device_attach_t tc_attach;
static device_detach_t tc_detach;

#if ZERO_WARNINGS
static usb_fifo_ioctl_t tc_ioctl;

static struct usb_fifo_methods tc_fifo_methods = {
	.f_ioctl = &tc_ioctl,
	.basename[0] = "tc",
};

static int	tc_do_req(struct tc_softc *, uint8_t, uint16_t, uint16_t,
		    uint8_t *);
static int	tc_set_freq(struct tc_softc *, void *);
static int	tc_get_freq(struct tc_softc *, void *);
static int	tc_start(struct tc_softc *, void *);
static int	tc_stop(struct tc_softc *, void *);
static int	tc_get_stat(struct tc_softc *, void *);
#endif

devclass_t tc_devclass;

static device_method_t tc_methods[] = {
	DEVMETHOD(device_probe, tc_probe),
	DEVMETHOD(device_attach, tc_attach),
	DEVMETHOD(device_detach, tc_detach),
	{0, 0}
};

static driver_t tc_driver = {
	.name = "tc",
	.methods = tc_methods,
	.size = sizeof(struct tc_softc),
};

DRIVER_MODULE(tc, uhub, tc_driver, tc_devclass, NULL, 0);
MODULE_DEPEND(tc, usb, 1, 1, 1);
MODULE_VERSION(tc, 1);

static void
tc_intr_callback(struct usb_xfer *xfer, usb_error_t error)
{
	struct tc_softc *sc = usbd_xfer_softc(xfer);
//	struct ums_info *info = &sc->sc_info[0];
	struct usb_page_cache *pc;
	uint8_t *buf = sc->sc_temp;
#if ZERO_WARNINGS
	int32_t buttons = 0;
	int32_t buttons_found = 0;
	int32_t dw = 0;
	int32_t dx = 0;
	int32_t dy = 0;
	int32_t dz = 0;
	int32_t dt = 0;
	uint8_t i;
	uint8_t id;
#endif
	int len;

	usbd_xfer_status(xfer, &len, NULL, NULL, NULL);

//	DPRINTF(, "state=%d\n", USB_GET_STATE(xfer));

	switch (USB_GET_STATE(xfer)) {
	case USB_ST_TRANSFERRED:
		DPRINTFN(6, "sc=%p actlen=%d\n", sc, len);
//		printf("sc=%p actlen=%d\n", sc, len);

		if (len > sizeof(sc->sc_temp)) {
			DPRINTFN(6, "truncating large packet to %zu bytes\n",
			    sizeof(sc->sc_temp));
			len = sizeof(sc->sc_temp);
		}
		if (len == 0)
			goto tr_setup;

		pc = usbd_xfer_get_frame(xfer, 0);
		usbd_copy_out(pc, 0, buf, len);
		printf("data = %02x %02x %02x %02x "
			"%02x %02x %02x %02x\n",
			(len > 0) ? buf[0] : 0, (len > 1) ? buf[1] : 0,
			(len > 2) ? buf[2] : 0, (len > 3) ? buf[3] : 0,
			(len > 4) ? buf[4] : 0, (len > 5) ? buf[5] : 0,
			(len > 6) ? buf[6] : 0, (len > 7) ? buf[7] : 0);
#if 0
		DPRINTFN(6, "data = %02x %02x %02x %02x "
		    "%02x %02x %02x %02x\n",
		    (len > 0) ? buf[0] : 0, (len > 1) ? buf[1] : 0,
		    (len > 2) ? buf[2] : 0, (len > 3) ? buf[3] : 0,
		    (len > 4) ? buf[4] : 0, (len > 5) ? buf[5] : 0,
		    (len > 6) ? buf[6] : 0, (len > 7) ? buf[7] : 0);

		if (sc->sc_iid) {
			id = *buf;

			len--;
			buf++;

		} else {
			id = 0;
			if (sc->sc_info[0].sc_flags & UMS_FLAG_SBU) {
				if ((*buf == 0x14) || (*buf == 0x15)) {
					goto tr_setup;
				}
			}
		}

	repeat:
		if ((info->sc_flags & UMS_FLAG_W_AXIS) &&
		    (id == info->sc_iid_w))
			dw += hid_get_data(buf, len, &info->sc_loc_w);

		if ((info->sc_flags & UMS_FLAG_X_AXIS) && 
		    (id == info->sc_iid_x))
			dx += hid_get_data(buf, len, &info->sc_loc_x);

		if ((info->sc_flags & UMS_FLAG_Y_AXIS) &&
		    (id == info->sc_iid_y))
			dy = -hid_get_data(buf, len, &info->sc_loc_y);

		if ((info->sc_flags & UMS_FLAG_Z_AXIS) &&
		    (id == info->sc_iid_z)) {
			int32_t temp;
			temp = hid_get_data(buf, len, &info->sc_loc_z);
			if (info->sc_flags & UMS_FLAG_REVZ)
				temp = -temp;
			dz -= temp;
		}

		if ((info->sc_flags & UMS_FLAG_T_AXIS) &&
		    (id == info->sc_iid_t))
			dt -= hid_get_data(buf, len, &info->sc_loc_t);

		for (i = 0; i < info->sc_buttons; i++) {
			uint32_t mask;
			mask = 1UL << UMS_BUT(i);
			/* check for correct button ID */
			if (id != info->sc_iid_btn[i])
				continue;
			/* check for button pressed */
			if (hid_get_data(buf, len, &info->sc_loc_btn[i]))
				buttons |= mask;
			/* register button mask */
			buttons_found |= mask;
		}

		if (++info != &sc->sc_info[UMS_INFO_MAX])
			goto repeat;

		/* keep old button value(s) for non-detected buttons */
		buttons |= sc->sc_status.button & ~buttons_found;

		if (dx || dy || dz || dt || dw ||
		    (buttons != sc->sc_status.button)) {

			DPRINTFN(6, "x:%d y:%d z:%d t:%d w:%d buttons:0x%08x\n",
			    dx, dy, dz, dt, dw, buttons);

			/* translate T-axis into button presses until further */
			if (dt > 0)
				buttons |= 1UL << 3;
			else if (dt < 0)
				buttons |= 1UL << 4;

			sc->sc_status.button = buttons;
			sc->sc_status.dx += dx;
			sc->sc_status.dy += dy;
			sc->sc_status.dz += dz;
			/*
			 * sc->sc_status.dt += dt;
			 * no way to export this yet
			 */

			/*
		         * The Qtronix keyboard has a built in PS/2
		         * port for a mouse.  The firmware once in a
		         * while posts a spurious button up
		         * event. This event we ignore by doing a
		         * timeout for 50 msecs.  If we receive
		         * dx=dy=dz=buttons=0 before we add the event
		         * to the queue.  In any other case we delete
		         * the timeout event.
		         */
			if ((sc->sc_info[0].sc_flags & UMS_FLAG_SBU) &&
			    (dx == 0) && (dy == 0) && (dz == 0) && (dt == 0) &&
			    (dw == 0) && (buttons == 0)) {

				usb_callout_reset(&sc->sc_callout, hz / 20,
				    &ums_put_queue_timeout, sc);
			} else {

				usb_callout_stop(&sc->sc_callout);

				ums_put_queue(sc, dx, dy, dz, dt, buttons);
			}
		}
#endif
	case USB_ST_SETUP:
tr_setup:
		/* check if we can put more data into the FIFO */
//		if (usb_fifo_put_bytes_max(
//		    sc->sc_fifo.fp[USB_FIFO_RX]) != 0) {
			usbd_xfer_set_frame_len(xfer, 0, usbd_xfer_max_len(xfer));
			usbd_transfer_submit(xfer);
//		}
		break;

	default:			/* Error */
		if (error != USB_ERR_CANCELLED) {
			/* try clear stall first */
			usbd_xfer_set_stall(xfer);
			goto tr_setup;
		}
		break;
	}
}

static const struct usb_config tc_config[TC_N_TRANSFER] = {

	[TC_INTR_DT] = {
		.type = UE_INTERRUPT,
		.endpoint = UE_ADDR_ANY,
		.direction = UE_DIR_IN,
		.flags = {.pipe_bof = 1,.short_xfer_ok = 1,},
		.bufsize = 0,	/* use wMaxPacketSize */
		.callback = &tc_intr_callback,
	},
};

static int
tc_probe(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);

	if (uaa->usb_mode != USB_MODE_HOST) {
		return (ENXIO);
	}
	if ((uaa->info.idVendor == 0x06a3) &&
	    (uaa->info.idProduct == 0x0836)) {
		return (0);
	}
	if ((uaa->info.idVendor == 0x0596) &&
		(uaa->info.idProduct == 0x0001)) {
		return (0);
	}
	return (ENXIO);
}

static int
tc_attach(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);
	struct tc_softc *sc = device_get_softc(dev);
	int error;

	sc->sc_udev = uaa->device;
	sc->sc_unit = device_get_unit(dev);

	snprintf((char*)sc->sc_name, sizeof(sc->sc_name), "%s",
	    device_get_nameunit(dev));

	mtx_init(&sc->sc_mtx, "tc lock", NULL, MTX_DEF | MTX_RECURSE);

	device_set_usb_desc(dev);

   	usb_callout_init_mtx(&sc->sc_callout, &sc->sc_mtx, 0);

	error = usbd_transfer_setup(uaa->device,
	    &uaa->info.bIfaceIndex, sc->sc_xfer, tc_config,
	    TC_N_TRANSFER, sc, &sc->sc_mtx);

	if (error) {
		DPRINTF("error=%s\n", usbd_errstr(error));
		goto detach;
	}

//	error = usb_fifo_attach(uaa->device, sc, &sc->sc_mtx,
//	    &tc_fifo_methods, &sc->sc_fifo,
//	    device_get_unit(dev), 0 - 1, uaa->info.bIfaceIndex,
//	    UID_ROOT, GID_OPERATOR, 0644);
	if (error) {
		goto detach;
	}

	usbd_transfer_start(sc->sc_xfer[TC_INTR_DT]);
	return (0);			/* success */

detach:
	tc_detach(dev);
	return (ENXIO);
}

static int
tc_detach(device_t dev)
{
	struct tc_softc *sc = device_get_softc(dev);

//	usb_fifo_detach(&sc->sc_fifo);

	usbd_transfer_unsetup(sc->sc_xfer, TC_N_TRANSFER);

	usb_callout_drain(&sc->sc_callout);

	mtx_destroy(&sc->sc_mtx);

	return (0);
}

#if ZERO_WARNINGS
static int
tc_do_req(struct tc_softc *sc, uint8_t request,
    uint16_t value, uint16_t index, uint8_t *retbuf)
{
	int error;

	struct usb_device_request req;
	uint8_t buf[1];

	req.bmRequestType = UT_READ_VENDOR_DEVICE;
	req.bRequest = request;
	USETW(req.wValue, value);
	USETW(req.wIndex, index);
	USETW(req.wLength, 1);

	error = usbd_do_request(sc->sc_udev, NULL, &req, buf);

	if (retbuf) {
		*retbuf = buf[0];
	}
	if (error) {
		return (ENXIO);
	}
	return (0);
}

static int
tc_set_freq(struct tc_softc *sc, void *addr)
{
	int freq = *(int *)addr;

	/*
	 * Freq now is in Hz.  We need to convert it to the frequency
	 * that the radio wants.  This frequency is 10.7MHz above
	 * the actual frequency.  We then need to convert to
	 * units of 12.5kHz.  We add one to the IFM to make rounding
	 * easier.
	 */
	mtx_lock(&sc->sc_mtx);
	sc->sc_freq = freq;
	mtx_unlock(&sc->sc_mtx);

	freq = (freq + 10700001) / 12500;

	/* This appears to set the frequency */
	if (tc_do_req(sc, TC_CMD_SET_FREQ,
	    freq >> 8, freq, NULL) != 0) {
		return (EIO);
	}
	/* Not sure what this does */
	if (tc_do_req(sc, TC_CMD0,
	    0x96, 0xb7, NULL) != 0) {
		return (EIO);
	}
	return (0);
}

static int
tc_get_freq(struct tc_softc *sc, void *addr)
{
	int *valp = (int *)addr;

	mtx_lock(&sc->sc_mtx);
	*valp = sc->sc_freq;
	mtx_unlock(&sc->sc_mtx);
	return (0);
}

static int
tc_start(struct tc_softc *sc, void *addr)
{
	uint8_t ret;

	if (tc_do_req(sc, TC_CMD0,
	    0x00, 0xc7, &ret)) {
		return (EIO);
	}
	if (tc_do_req(sc, TC_CMD2,
	    0x01, 0x00, &ret)) {
		return (EIO);
	}
	if (ret & 0x1) {
		return (EIO);
	}
	return (0);
}

static int
tc_stop(struct tc_softc *sc, void *addr)
{
	if (tc_do_req(sc, TC_CMD0,
	    0x16, 0x1C, NULL)) {
		return (EIO);
	}
	if (tc_do_req(sc, TC_CMD2,
	    0x00, 0x00, NULL)) {
		return (EIO);
	}
	return (0);
}

static int
tc_get_stat(struct tc_softc *sc, void *addr)
{
	uint8_t ret;

	/*
	 * Note, there's a 240ms settle time before the status
	 * will be valid, so sleep that amount.
	 */
	usb_pause_mtx(NULL, hz / 4);

	if (tc_do_req(sc, TC_CMD0,
	    0x00, 0x24, &ret)) {
		return (EIO);
	}
	*(int *)addr = ret;

	return (0);
}


static int
tc_ioctl(struct usb_fifo *fifo, u_long cmd, void *addr,
    int fflags)
{
//	struct tc_softc *sc = usb_fifo_softc(fifo);
	int error = 0;

#if 0
	if ((fflags & (FWRITE | FREAD)) != (FWRITE | FREAD)) {
		return (EACCES);
	}

	switch (cmd) {
	case FM_SET_FREQ:
		error = tc_set_freq(sc, addr);
		break;
	case FM_GET_FREQ:
		error = tc_get_freq(sc, addr);
		break;
	case FM_START:
		error = tc_start(sc, addr);
		break;
	case FM_STOP:
		error = tc_stop(sc, addr);
		break;
	case FM_GET_STAT:
		error = tc_get_stat(sc, addr);
		break;
	default:
		error = ENOTTY;
		break;
	}
#endif

	return (error);
}

#endif
