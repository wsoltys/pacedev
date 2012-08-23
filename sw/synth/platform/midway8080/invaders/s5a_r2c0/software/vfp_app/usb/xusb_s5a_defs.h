/*
 * Various bits and pieces need to support the build on the S5A.
 */
#if !defined (USB_S5A_DEFS_H)
#define USB_S5A_DEFS_H

#define _KERNEL 1

#define USB_DEBUG     1
#define USB_REQ_DEBUG 1

/*
 * Mixed up C bits and pieces.
 */
#ifndef NULL
#define NULL ((void*)0)
#endif

#define MIN(x,y) ((x) < (y) ? (x) : (y))

typedef unsigned long u_long;

/*
 * We need uint*_t.
 */
#include "cdefs.h"
#include "stdint.h"

/*
 * Various includes that are needed. Placed here to make adding files simpler.
 */
#include "queue.h"
#include "callout.h"

#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <sys/cdefs.h>
#include <ctype.h>



#endif
