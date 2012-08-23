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

#include "bsd-wrap.h"
#include "oxu210-intr.h"

#include "../os-support.h"
#include "../oxu210hp.h"

#if OXU_DEBUG_LED
#define EHCI_OXU_DEBUG_LED (3)
#endif

#if EHCI_OXU_DEBUG_LED
#include "../dbg_helper.h"
#endif

#ifdef USB_DEBUG
#define OXU210_INTR_DEBUG 1
#define DEBUG_PRINTING    1
#else
#define OXU210_INTR_DEBUG 0
#define DEBUG_PRINTING    0
#endif

#if DEBUG_PRINTING
extern volatile uint32_t Clock_driver_ticks;
#define DBPRINT(fmt, ...) \
  printf ("%s:%ld:" fmt, __FUNCTION__, Clock_driver_ticks, ## __VA_ARGS__)
#else
#define DBPRINT(fmt, ...)
#endif

typedef struct
{
  oxu210_intr_handler handler;
  void*               self;
} oxu210_data;

static os_events_t   isr_wait;
static os_thread_t   isr_thread;
static volatile bool isr_thread_active;
static volatile bool isr_thread_running;
static oxu210_data   isr_data[2];
static rtems_isr_entry previous_isr;

static void
oxu210_intr_master_enable (void)
{
#if EHCI_OXU_DEBUG_LED
  dbg_port_leds_off (DBG_PORT_LED (EHCI_OXU_DEBUG_LED));
#endif
  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Set_ienable(OXU210HP_IF_0_IRQ);
  os_interrupt_enable (level);
}

static void
oxu210_intr_master_disable (void)
{
  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Clear_ienable(OXU210HP_IF_0_IRQ);
  os_interrupt_enable (level);  
#if EHCI_OXU_DEBUG_LED
  dbg_port_leds_on (DBG_PORT_LED (EHCI_OXU_DEBUG_LED));
#endif
}

static void oxu210_intr_high (rtems_vector_number vector)
{
  oxu210_intr_master_disable ();
  os_events_send (&isr_wait, &isr_thread);
}

static void
oxu210_intr_low (void* self)
{
  while (isr_thread_running)
  {
    unsigned int      out;
    volatile uint32_t status;
    oxu210_intr_master_enable ();
    DBPRINT("sleeping\n");
    os_events_receive (&isr_wait, 1, &out, 0);
    DBPRINT("running\n");
    while (isr_thread_running &&
           (status = OXU210HP_HOSTIF_RD (R_ChipIRQStatus)))
    {
      DBPRINT("status: %08lx (%08lx)\n", status, status & (ChipIRQEn_OE | ChipIRQEn_SE));
      if ((status & ChipIRQEn_OE) && isr_data[oxu210_intr_otg].handler)
        isr_data[oxu210_intr_otg].handler (isr_data[oxu210_intr_otg].self);
      if ((status & ChipIRQEn_SE) && isr_data[oxu210_intr_shc].handler)
        isr_data[oxu210_intr_shc].handler (isr_data[oxu210_intr_shc].self);
    }
  }

  isr_thread_active = false;
  os_thread_del_self ();
}

int
oxu210_intr_attach (oxu210_intr_source  source,
                    oxu210_intr_handler handler,
                    void*               self)
{
  uint32_t mask = 0;

  if (((source != oxu210_intr_shc) && (source != oxu210_intr_otg)) ||
      isr_data[source].handler)
    return 1;

  isr_data[source].handler = handler;
  isr_data[source].self = self;

  if (!isr_thread_active)
  {
    isr_thread_active = true;
    
    if (os_events_create (&isr_wait, 0) != os_successful)
    {
      isr_thread_active = false;
      isr_data[source].handler = NULL;
      isr_data[source].self = NULL;
      return 1;
    }

    isr_thread_running = true;
    
    os_error_t e = os_thread_create (&isr_thread,
                                     oxu210_intr_low, NULL,
                                     INTRPT_TASK_PRIORITY,
                                     EHCI_INTPRT_TASK_STACKSIZE, NULL);
    if (e != os_successful)
    {
      isr_thread_running = false;
      isr_thread_active = false;
      os_events_del (&isr_wait);
      isr_data[source].handler = NULL;
      isr_data[source].self = NULL;
      return 1;
    }
    
    /* the register enables interrupts. */
    rtems_interrupt_catch(oxu210_intr_high, OXU210HP_IF_0_IRQ,
                          (rtems_isr_entry *) &previous_isr);
  }

  if (source == oxu210_intr_shc)
    mask |= ChipIRQEn_SE;
  if (source == oxu210_intr_otg)
    mask |= ChipIRQEn_OE;

  OXU210HP_HOSTIF_WR (R_ChipIRQEn_Set, mask);

  return 0;
}

void
oxu210_intr_detach (oxu210_intr_source source)
{
  uint32_t mask = 0;

  if (source == oxu210_intr_shc)
    mask |= ChipIRQEn_SE;
  if (source == oxu210_intr_otg)
    mask |= ChipIRQEn_OE;

  OXU210HP_HOSTIF_WR (R_ChipIRQEn_Clr, mask);

  isr_data[source].handler = NULL;
  isr_data[source].self = NULL;

  if (isr_thread_running && !isr_data[0].handler && !isr_data[1].handler)
  {
    rtems_isr_entry nop;
    oxu210_intr_master_disable ();
    rtems_interrupt_catch(previous_isr, OXU210HP_IF_0_IRQ, &nop);
    isr_thread_running = false;
    while (isr_thread_active)
    {
      isr_thread_running = false;
      os_events_send (&isr_wait, &isr_thread);
      usleep (10000);
    }
    os_events_del (&isr_wait);
  }
}
