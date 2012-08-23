/* $FreeBSD: src/sys/dev/usb/usb_freebsd.h,v 1.3 2010/10/22 20:13:45 hselasky Exp $ */
/*-
 * Copyright (c) 2008 Hans Petter Selasky. All rights reserved.
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
 * Including this file is mandatory for all USB related c-files in the kernel.
 */

#ifndef _USB_S5A_H_
#define	_USB_S5A_H_

/* Default USB configuration */
#define	USB_HAVE_UGEN         0
#define	USB_HAVE_DEVCTL       0
#define	USB_HAVE_BUSDMA       1
#define	USB_HAVE_COMPAT_LINUX 0
#define	USB_HAVE_USER_IO      0
#define	USB_HAVE_MBUF         0
#define	USB_HAVE_TT_SUPPORT   1
#define	USB_HAVE_POWERD       1
#define	USB_HAVE_MSCTEST      0

#define	USB_TD_GET_PROC(td) (td)->td_proc
#define	USB_PROC_GET_GID(td) (td)->p_pgid

#define	USB_HOST_ALIGN    8		/* bytes, must be power of two */
#define	USB_FS_ISOC_UFRAME_MAX 4	/* exclusive unit */
#define	USB_BUS_MAX 2			/* units */
#define	USB_MAX_DEVICES 8		/* units */
#define	USB_IFACE_MAX 32		/* units */
#define	USB_FIFO_MAX 128		/* units */

#define	USB_MAX_FS_ISOC_FRAMES_PER_XFER (120)	/* units */
#define	USB_MAX_HS_ISOC_FRAMES_PER_XFER (8*120)	/* units */

#define	USB_HUB_MAX_DEPTH	5
#define	USB_EP0_BUFSIZE		1024	/* bytes */

typedef uint32_t usb_timeout_t;		/* milliseconds */
typedef uint32_t usb_frlength_t;	/* bytes */
typedef uint32_t usb_frcount_t;		/* units */
typedef uint32_t usb_size_t;		/* bytes */
typedef uint32_t usb_ticks_t;		/* system defined */
typedef uint16_t usb_power_mask_t;	/* see "USB_HW_POWER_XXX" */

device_attach_t oxu_ehci_attach;
device_detach_t oxu_ehci_detach;
device_shutdown_t oxu_ehci_shutdown;
device_suspend_t oxu_ehci_suspend;
device_resume_t oxu_ehci_resume;

extern driver_t ehci_driver;

extern int trace_reads;
extern int trace_writes;

/*
 * FIXME: Needs a separate header file.
 */
typedef struct
{
  void* (*alloc)(size_t );
  void  (*free)(void* );
} s5a_heap_allocator_t;

void oxu210_allocator_init (void);
void oxu210_aligned_alloc (void** vaddr, void** paddr,
                           size_t size, size_t alignment, size_t boundary);
void oxu210_free (void* addr, size_t size);

extern s5a_heap_allocator_t oxu210_heap_allocator;

#endif	/* _USB_S5A_H_ */
