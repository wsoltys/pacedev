/*
 * Use SYS_CLK as system clock
 *
 * Copyright (c) 2005-2006 Kolja Waschk, rtemsdev/ixo.de
 *
 *  $Id: clock.c,v 1.3 2008/09/30 06:19:21 ralf Exp $
 */

#include <rtems.h>

#include <bsp.h>
#include <system.h>
#include <altera_avalon_timer_regs.h>

/*
 * Periodic interval timer interrupt handler
 */
#define Clock_driver_support_at_tick() \
  do { IOWR_ALTERA_AVALON_TIMER_STATUS (TIMER_0_BASE, 0); } while(0)

/*
 * Attach clock interrupt handler
 */
#define Clock_driver_support_install_isr(_new, _old) \
  do { _old = (rtems_isr_entry)set_vector(_new, CLOCK_VECTOR, 1); } while(0)


/*
 * Turn off the clock
 */
#define Clock_driver_support_shutdown_hardware() \
  do { IOWR_ALTERA_AVALON_TIMER_CONTROL ( \
          TIMER_0_BASE, ALTERA_AVALON_TIMER_CONTROL_STOP_MSK); } while(0)

/*
 * Set up the clock hardware
 */
void Clock_driver_support_initialize_hardware(void)
{
  uint32_t period;

  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_STOP_MSK);

  period = ((TIMER_0_FREQ / 1000000L) *
            rtems_configuration_get_microseconds_per_tick()) - 1;

  IOWR_ALTERA_AVALON_TIMER_PERIODH (TIMER_0_BASE, (period >> 16));
  IOWR_ALTERA_AVALON_TIMER_PERIODL (TIMER_0_BASE, (period & 0xFFFF));

  /* set to free running mode */

  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_ITO_MSK  |
                                    ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |
                                    ALTERA_AVALON_TIMER_CONTROL_START_MSK);

  Nios2_Set_ienable(TIMER_0_IRQ);
}

#define CLOCK_VECTOR TIMER_0_IRQ

#include "clockdrv_shell.h"

