/*  timer.c
 *
 *  This file manages the benchmark timer used by the RTEMS Timing Test
 *  Suite.  Each measured time period is demarcated by calls to
 *  benchmark_timer_initialize() and benchmark_timer_read().  benchmark_timer_read() usually returns
 *  the number of microseconds since benchmark_timer_initialize() exitted.
 *
 *  NOTE: It is important that the timer start/stop overhead be
 *        determined when porting or modifying this code.
 *
 *  COPYRIGHT (c) 2005-2006 Kolja Waschk rtemsdev/ixo.de
 *  Derived from no_cpu/no_bsp/timer/timer.c 1.9,
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id: timer.c,v 1.6 2011/02/09 12:15:05 ralf Exp $
 */

#define TIMER_WRAPS_AFTER_1MS 0

#include <rtems.h>
#include <rtems/btimer.h>
#include <rtems/score/cpu.h>
#include <bsp.h>

#include "nios2.h"
#include "system.h"
#include "altera_avalon_timer_regs.h"

volatile uint32_t Timer_interrupts;
bool benchmark_timer_find_average_overhead;

void timerisr( void )
{
  IOWR_ALTERA_AVALON_TIMER_STATUS (TIMER_0_BASE, 0);
  Timer_interrupts++;
}

void benchmark_timer_initialize( void )
{
  /* Disable timer interrupt, stop timer */

  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_STOP_MSK);

  set_vector((rtems_isr_entry) timerisr, TIMER_0_IRQ, 1);

  /* Enable interrupt processing */

  NIOS2_INT_ENABLE(1 << TIMER_0_IRQ);

#if TIMER_WRAPS_AFTER_1MS
  /* Writing to periodl/h resets the counter and eventually
     stops it. If the timer hasn't been configured with fixed
     period, set it to 1 ms now */

  IOWR_ALTERA_AVALON_TIMER_PERIODH (TIMER_0_BASE, (TIMER_0_FREQ / 1000) >> 16);
  IOWR_ALTERA_AVALON_TIMER_PERIODL (TIMER_0_BASE, (TIMER_FREQ/1000) & 0xFFFF);
#else
  /* Writing to periodl/h resets the counter and eventually
     stops it. Set max period */

  IOWR_ALTERA_AVALON_TIMER_PERIODH (TIMER_0_BASE, 0xFFFF);
  IOWR_ALTERA_AVALON_TIMER_PERIODL (TIMER_0_BASE, 0xFFFF);
#endif

  /* For timers that can be stopped, writing to periodl/h
     also stopped the timer and we have to manually start it. */

  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_ITO_MSK  |
                                    ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |
                                    ALTERA_AVALON_TIMER_CONTROL_START_MSK);

  /* This is the most safe place for resetting the overflow
     counter - just _after_ we reset the timer. Depending
     on the SOPC configuration, the counter may not be
     stoppable and it doesn't make sense to assume that
     there is any "safe" period before resetting. */

  Timer_interrupts = 0;
}

/*
 *  The following controls the behavior of benchmark_timer_read().
 *
 *  AVG_OVEREHAD is the overhead for starting and stopping the timer.  It
 *  is usually deducted from the number returned.
 *
 *  LEAST_VALID is the lowest number this routine should trust.  Numbers
 *  below this are "noise" and zero is returned.
 */

#define AVG_OVERHEAD      2      /* It typically takes 2 microseconds */
                                 /* to start/stop the timer. */

#define LEAST_VALID AVG_OVERHEAD /* Don't trust a value lower than this */

uint32_t benchmark_timer_read( void )
{
  uint32_t timer_wraps;
  uint32_t timer_snap;
  uint32_t timer_ticks;
  uint32_t total;

  /* Hold timer */
  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_STOP_MSK);

  /* Write to request snapshot of timer value */
  IOWR_ALTERA_AVALON_TIMER_SNAPL (TIMER_0_BASE, 0);
  /* Get snapshot */
  timer_snap =
    (IORD_ALTERA_AVALON_TIMER_SNAPH (TIMER_0_BASE) << 16) |
    IORD_ALTERA_AVALON_TIMER_SNAPL (TIMER_0_BASE);
  timer_wraps = Timer_interrupts;

  /* Restart timer */
  IOWR_ALTERA_AVALON_TIMER_CONTROL (TIMER_0_BASE,
                                    ALTERA_AVALON_TIMER_CONTROL_START_MSK);

#if TIMER_WRAPS_AFTER_1MS
  timer_ticks = (TIMER_0_FREQ / 1000) - 1 - timer_snap;
  total = timer_wraps * 1000;
#else
  timer_ticks = 0xFFFFFFFF - timer_snap;
  total = timer_wraps * 0x80000000 / (TIMER_0_FREQ / 2000000L);
#endif
  total += timer_ticks / (TIMER_0_FREQ / 1000000L);

  if(total < LEAST_VALID) return 0;

  if(benchmark_timer_find_average_overhead != TRUE) total-= AVG_OVERHEAD;

  return total;
}

void benchmark_timer_disable_subtracting_average_overhead(bool find_flag)
{
  benchmark_timer_find_average_overhead = find_flag;
}
