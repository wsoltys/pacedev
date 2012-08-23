
#include "usb.h"
#include "usbdi.h"

#define	USB_DEBUG_VAR s5a

#include "usb_core.h"
#include "usb_debug.h"
#include "usb_busdma.h"
#include "usb_process.h"
#include "usb_transfer.h"
#include "usb_device.h"
#include "usb_dynamic.h"
#include "usb_hub.h"
#include "usb_util.h"

#include "usb_controller.h"
#include "usb_bus.h"
#include "ehci.h"
#include "ehcireg.h"

#include "s5a-sysinit.h"

/*
 * Set up the required modules.
 */
SYSINIT_NEED_FREEBSD_CORE;
SYSINIT_NEED_USB_CORE;
SYSINIT_NEED_USB_EHCI;
SYSINIT_NEED_USB_PDEV;

const char *const _bsd_avalon_devices [] = {
  "ehci",
  "pdev",
  NULL
};

/* In FreeBSD this is a local function */
void mi_startup(void);

void
usb_start_bsd_stack (void)
{
  printf ("Starting USB stack..\n");
  bsd_wrapper_init ();
  mi_startup ();
}

static int
avalon_probe(device_t dev)
{
	size_t unit = 0;

	for (unit = 0; _bsd_avalon_devices [unit] != NULL; ++unit) {
		device_add_child(dev, _bsd_avalon_devices [unit], unit);
	}

	device_set_desc(dev, "S5A Avalon devices");

	return (0);
}

static device_method_t avalon_methods [] = {
	/* Device interface */
	DEVMETHOD(device_probe,    avalon_probe),
	DEVMETHOD(device_attach,   bus_generic_attach),
	DEVMETHOD(device_detach,   bus_generic_detach),
	DEVMETHOD(device_shutdown, bus_generic_shutdown),
	DEVMETHOD(device_suspend,  bus_generic_suspend),
	DEVMETHOD(device_resume,   bus_generic_resume),

	/* Bus interface */
	DEVMETHOD(bus_print_child, bus_generic_print_child),

	{ 0, 0 }
};

static driver_t avalon_driver = {
	.name = "avalon",
	.methods = avalon_methods,
	.size = 0
};

static devclass_t avalon_devclass;

DRIVER_MODULE(avalon, root, avalon_driver, avalon_devclass, 0, 0);
