/*  bsp.h
 *
 *  This include file contains all board IO definitions.
 *
 *  XXX : put yours in here
 *
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id: bsp.h,v 1.7 2009/03/03 00:10:56 joel Exp $
 */

#ifndef _BSP_H
#define _BSP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <bspopts.h>

#include <rtems.h>
#include <rtems/console.h>
#include <rtems/clockdrv.h>

#include <system.h>
#include <nios2.h>

#include <rtems/score/nios2-utility.h>

/*
 * A local function to manage interrupts.
 */
static inline void Nios2_Set_ienable(uint32_t mask)
{
  _Nios2_Set_ctlreg_ienable(_Nios2_Get_ctlreg_ienable() | (1 << mask));
}

/*
 * A local function to manage interrupts.
 */
static inline void Nios2_Clear_ienable(uint32_t mask)
{
  _Nios2_Set_ctlreg_ienable(_Nios2_Get_ctlreg_ienable() & ~(1 << mask));
}

/*
 *  Simple spin delay in microsecond units for device drivers.
 *  This is very dependent on the clock speed of the target.
 */

#define rtems_bsp_delay( microseconds ) \
  { \
  }

/* ============================================ */

#define NIOS2_BYPASS_CACHE ((uint32_t)0x80000000ul)
#define NIOS2_IO_BASE(x) ( (void*) ((uint32_t)x | NIOS2_BYPASS_CACHE ) )
#define NIOS2_INT_ENABLE(x) do{ __builtin_wrctl(3,__builtin_rdctl(3)|x);}while(0)
#define NIOS2_IRQ_ENABLE(x) do {__builtin_wrctl(3,__builtin_rdctl(3)|x);} while(0)

/* ============================================ */

/* functions */

rtems_isr_entry set_vector(                     /* returns old vector */
  rtems_isr_entry     handler,                  /* isr routine        */
  rtems_vector_number vector,                   /* vector number      */
  int                 type                      /* RTEMS or RAW intr  */
);

/* ============================================ */

/* RAM/ROM addresses */

extern char __alt_data_start[];
extern char __alt_data_end[];
extern char __alt_heap_start[];
extern char __alt_heap_limit[];

#define RamBase       __alt_data_start
#define RamSize       (__alt_data_end - __alt_data_start)
#define WorkAreaBase  __alt_heap_start
#define HeapSize      BSP_BOOTCARD_HEAP_SIZE_DEFAULT

#ifdef __cplusplus
}
#endif

#endif
/* end of include file */
