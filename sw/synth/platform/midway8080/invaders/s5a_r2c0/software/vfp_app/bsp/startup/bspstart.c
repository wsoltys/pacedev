/*
 *  This routine starts the application.  It includes application,
 *  board, and monitor specific initialization and configuration.
 *  The generic CPU dependent initialization has been performed
 *  before this routine is invoked.
 *
 *  COPYRIGHT (c) 2005-2006 Kolja Waschk rtemsdev/ixo.de
 *  Derived from no_cpu/no_bsp/startup/bspstart.c 1.23.
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id: bspstart.c,v 1.7 2008/09/14 21:57:13 joel Exp $
 */

#include <sys/cdefs.h>

#include <rtems.h>
#include <nios2.h>
#include <rtems/score/nios2-utility.h>

/*
 *  bsp_start
 *
 *  This routine does the bulk of the system initialization.
 */

void bsp_start( void )
{
  NIOS2_WRITE_IENABLE (0);
  __asm__ volatile (
    ".globl _Nios2_ISR_Status_mask\n"
    ".globl _Nios2_ISR_Status_bits\n"
    ".set _Nios2_ISR_Status_mask, " __XSTRING(NIOS2_ISR_STATUS_MASK_IIC) "\n"
    ".set _Nios2_ISR_Status_bits, " __XSTRING(NIOS2_ISR_STATUS_BITS_IIC)
  );
}
