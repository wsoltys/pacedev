/*  NIOS2 startup code
 *
 *  This is a wrapper for the Alter supplied code.
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

/*
 * Map the Altera sections to the RTEMS expected ones.
 */
     .section set_sysctl_set
     .global  __start_set_sysctl_set	
_alt_partition_set_sysctl_set_start:
__start_set_sysctl_set:

     .section set_sysctl_set
     .global  __stop_set_sysctl_set
_alt_partition_set_sysctl_set_end:	
__stop_set_sysctl_set:
	
     .section set_domain_set
     .global  __start_set_domain_set
_alt_partition_set_domain_set_start:
__start_set_domain_set:

     .section set_domain_set
     .global  __stop_set_domain_set
_alt_partition_set_domain_set_end:
__stop_set_domain_set:
	
     .section set_pseudo_set
     .global  __start_set_pseudo_set
_alt_partition_set_pseudo_set_start:
__start_set_pseudo_set:
	
     .section set_pseudo_set
     .global  __stop_set_pseudo_set
_alt_partition_set_pseudo_set_end:
__stop_set_pseudo_set:

/*
 * Provide the start of memory here.
 */
	
     .section .entry, "xa"
     .global  __alt_data_start
	
     .org     0
__alt_data_start:

/*
 * Explicitly allow the use of r1 (the assembler temporary register)
 * within this code. This register is normally reserved for the use of
 * the assembler.
 */
    .set noat

    .section .bss
    .align 4

__boot_stack_bottom:

    .space 2048

__boot_stack:

#define __alt_stack_pointer __boot_stack
	
    .section .text
    .align 2

    .globl start
    .type start, @function
	
start:
     movhi sp, %hi(__boot_stack)
     ori sp, sp, %lo(__boot_stack)
     movhi r1, %hi(__reset)
     ori   r1, r1, %lo(__reset)
     jmp   r1
	
    .globl alt_main
    .type alt_main, @function
	
alt_main:
    # jump to (shared) boot_card (never comes back)
    movhi   r4, %hi(alt_irq_entry)
    mov     r4, zero
    mov     r5, zero
    mov     r6, zero
    call    boot_card

#include "crt0.S"
