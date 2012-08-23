 
#ifndef _S5A_SYSINIT_H_
#define _S5A_SYSINIT_H_

#include "sys/cdefs.h"
#include "sys/queue.h"
#include "sys/kernel.h"

#define SYSINIT_NEED_FREEBSD_CORE \
	SYSINIT_REFERENCE(configure1); \
	SYSINIT_REFERENCE(module); \
	SYSINIT_REFERENCE(kobj); \
	SYSINIT_REFERENCE(linker_kernel); \
	SYSINIT_MODULE_REFERENCE(rootbus); \
	SYSINIT_DRIVER_REFERENCE(avalon, root)

#define SYSINIT_NEED_USB_CORE \
	SYSINIT_DRIVER_REFERENCE(uhub, usbus)

#define SYSINIT_NEED_USB_EHCI \
	SYSINIT_DRIVER_REFERENCE(ehci, avalon); \
	SYSINIT_DRIVER_REFERENCE(usbus, ehci)

#define SYSINIT_NEED_USB_PDEV \
  SYSINIT_DRIVER_REFERENCE(usbdev, pdev)

extern const char *const _bsd_avalon_devices [];

#endif /* _S5A_SYSINIT_H_ */
