/*-
 * Copyright (C) 2010 Virtual Logic Pty Ltd
 * All rights reserved.
 *
 * Developed by Chris Johns.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of MARVELL nor the names of contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <io.h>
#include <system.h>

#include "usb.h"
#include "usbdi.h"

#include "usb_core.h"
#include "usb_busdma.h"
#include "usb_process.h"
#include "usb_util.h"

#include "usb_controller.h"
#include "usb_bus.h"
#include "ehci.h"
#include "ehcireg.h"

#include "s5a-sysinit.h"

#include "oxu210-intr.h"

#include "../oxu210hp.h"

#define  EHCI_HC_DEVSTR "Oxford USB 2.0 controller"

/*
 * EHCI HC regs start at this offset within USB range
 */
#define OXU210_USB_EHCI_OFST      (OXU210HP_IF_0_BASE + SPH_BASE + 0x100)

int
ehci_oxu_suspend(device_t self)
{
  ehci_softc_t *sc = device_get_softc(self);
  int err;

  err = bus_generic_suspend(self);
  if (err)
    return (err);
  ehci_suspend(sc);
  return (0);
}

int
ehci_oxu_resume(device_t self)
{
  ehci_softc_t *sc = device_get_softc(self);

  ehci_resume(sc);

  bus_generic_resume(self);

  return (0);
}

int
ehci_oxu_shutdown(device_t self)
{
  ehci_softc_t *sc = device_get_softc(self);
  int err;

  err = bus_generic_shutdown(self);
  if (err)
    return (err);
  ehci_shutdown(sc);

  return (0);
}

int
ehci_oxu_probe(device_t self)
{
  return (BUS_PROBE_DEFAULT);
}

int ehci_oxu_detach(device_t self);

int
ehci_oxu_attach(device_t self)
{
  ehci_softc_t *sc = device_get_softc(self);
  int err;

#if EHCI_OXU_DEBUG_LEDS
  dbg_port_set_mode (dbg_port_uh_mon);
#endif
  
  /* initialise some bus fields */
  sc->sc_bus.parent = self;
  sc->sc_bus.devices = sc->sc_devices;
  sc->sc_bus.devices_max = EHCI_MAX_DEVICES;
  sc->sc_io_tag = 0U;
  sc->sc_io_hdl = OXU210_USB_EHCI_OFST;
  sc->sc_io_size = 0x00020000;

  sc->sc_flags |= (EHCI_SCFLG_SETMODE |
                   EHCI_SCFLG_TT | EHCI_SCFLG_FORCESPEED |
                   EHCI_SCFLG_NORESTERM |
                   EHCI_SCFLG_SETFRSZ);

  /* get all DMA memory */
  if (usb_bus_mem_alloc_all(&sc->sc_bus,
                            USB_GET_DMA_TAG(self), &ehci_iterate_hw_softc)) {
    return (ENOMEM);
  }

  sc->sc_bus.bdev = device_add_child(self, "usbus", -1);
  if (!sc->sc_bus.bdev) {
    device_printf(self, "Could not add USB device\n");
    goto error;
  }

  device_set_ivars(sc->sc_bus.bdev, &sc->sc_bus);
  device_set_desc(sc->sc_bus.bdev, EHCI_HC_DEVSTR);

  err = oxu210_intr_attach (oxu210_intr_shc,
                            (oxu210_intr_handler) ehci_interrupt,
                            sc);
  if (err) {
    device_printf(self, "USB EHCI intr attach error\n");
    goto error;
  }

  err = ehci_init(sc);
  if (!err) {
    err = device_probe_and_attach(sc->sc_bus.bdev);
  }
  if (err) {
    device_printf(self, "USB init failed err=%d\n", err);
    goto error;
  }
  return (0);

error:
  ehci_oxu_detach(self);
  return (ENXIO);
}

int
ehci_oxu_detach(device_t self)
{
  ehci_softc_t *sc = device_get_softc(self);
  device_t bdev;

  if (sc->sc_bus.bdev) {
    bdev = sc->sc_bus.bdev;
    device_detach(bdev);
    device_delete_child(self, bdev);
  }
  /* during module unload there are lots of children leftover */
  device_delete_all_children(self);

  oxu210_intr_detach (oxu210_intr_shc);
  
  ehci_detach(sc);

  usb_bus_mem_free_all(&sc->sc_bus, &ehci_iterate_hw_softc);

  return (0);
}

device_method_t ehci_methods[] = {
  /* Device interface */
  DEVMETHOD(device_probe,    ehci_oxu_probe),
  DEVMETHOD(device_attach,   ehci_oxu_attach),
  DEVMETHOD(device_detach,   ehci_oxu_detach),
  DEVMETHOD(device_suspend,  ehci_oxu_suspend),
  DEVMETHOD(device_resume,   ehci_oxu_resume),
  DEVMETHOD(device_shutdown, ehci_oxu_shutdown),

  /* Bus interface */
  DEVMETHOD(bus_print_child, bus_generic_print_child),

  {0, 0}
};

driver_t ehci_driver = {
  "ehci",
  ehci_methods,
  sizeof(ehci_softc_t),
};

static devclass_t ehci_devclass;

DRIVER_MODULE(ehci, avalon, ehci_driver, ehci_devclass, 0, 0);
MODULE_DEPEND(ehci, usb, 1, 1, 1);
