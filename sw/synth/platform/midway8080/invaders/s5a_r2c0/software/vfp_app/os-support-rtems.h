/*
 * RTEMS Support.
 */

#ifndef OS_SUPPORT_RTEMS_H
#define OS_SUPPORT_RTEMS_H

#include <stdint.h>
#include <rtems.h>
#include <pthread.h>

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
 * Make a struct to hold the TCB holding the semaphore.
 */
typedef struct 
{
  pthread_mutex_t handle;
  pthread_t       owner;
  int             count;
} os_mutex_t;
 
/*
 * A condition variable.
 */
typedef pthread_cond_t os_cond_var_t;

/*
 * An event.
 */
typedef struct 
{
  rtems_id id;
} os_events_t;
 
/*
 * A thread.
 */
typedef struct
{
  pthread_t        id;
  int              priority;
  os_thread_body_t body;
  void*            data;
  void*            extension;
} os_thread_t; 

/*
 * Critical section support.
 */
#define os_interrupt_level         rtems_interrupt_level
#define os_interrupt_disable(_l)   rtems_interrupt_disable(_l)
#define os_interrupt_enable(_l)    rtems_interrupt_enable(_l)

/*
 * Yield in RTEMS is wake now.
 */
#define os_yield() rtems_task_wake_after (0)

/*
 * Ticks since boot.
 */
#define os_ticks_since_boot() rtems_clock_get_ticks_since_boot()

/*
 * Ticks per second.
 */
#define os_ticks_per_second() rtems_clock_get_ticks_per_second()

#endif
