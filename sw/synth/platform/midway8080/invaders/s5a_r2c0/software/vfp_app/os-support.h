/*
 * Wrap the OS.
 */

#ifndef OS_SUPPORT_H
#define OS_SUPPORT_H

typedef enum {
  os_successful,
  os_error,
  os_timeout
} os_error_t;

/*
 * Timeout handler called with the timer mutex locked when
 * a timeout occurs. Return 1 to signal 
 */
typedef void (*os_timeout_t)(void* arg);

/*
 * The type of thread body.
 */
typedef void (*os_thread_body_t)(void* );

/*
 * Timer flags.
 */
#define OS_TIMER_QUEUED            (1 << 0)
#define OS_TIMER_RETURNED_UNLOCKED (1 << 1)

#if !__rtems__
#error "Use an RTEMS tool chain."
#endif

#include <os-support-rtems.h>

#define HIGH_TASK_PRIORITY         (PRIORITY_MAXIMUM - 10)
#define ANIMATE_TASK_PRIORITY      (HIGH_TASK_PRIORITY-0)
#define TIMER_TASK_PRIORITY        (HIGH_TASK_PRIORITY-5)
#define INTRPT_TASK_PRIORITY       (TIMER_TASK_PRIORITY - 10)
#define USB_TASK_PRIORITY          (INTRPT_TASK_PRIORITY - 10)
#define USB_USER_TASK_PRIORITY     (USB_TASK_PRIORITY - 10)
#define SPI_TASK_PRIORITY          (USB_TASK_PRIORITY-15)
#define SYSTEM_BASE_TASK_PRIORITY  (USB_USER_TASK_PRIORITY - 10)

#define THREAD_SC_TASK_STACKSIZE   (16 * 1024)
#define INIT_TASK_STACKSIZE        (32 * 1024)
#define ANIMATE_TASK_STACKSIZE     (32 * 1024)
#define SPI_TASK_STACKSIZE         (32 * 1024)
#define TIMER_TASK_STACKSIZE       (32 * 1024)
#define SYS_BASE_TASK_STACKSIZE    (32 * 1024)
#define USB_TASK_STACKSIZE         (64 * 1024)
#define PDEV_TASK_STACKSIZE        (32 * 1024)
#define EHCI_INTPRT_TASK_STACKSIZE (32 * 1024)

#define OS_TIMER_TICKS_PER_SEC     (100)

/*
 * The timer structure.
 */
typedef struct os_timer {
  unsigned int     flags;
  struct os_timer* next;
  int              ticks;
  int              delta;
  os_mutex_t*      mutex;
  os_timeout_t     timeout;
  void*            arg;
} os_timer_t;

os_error_t os_thread_create (os_thread_t*     thread,
                             os_thread_body_t body,
                             void*            data,
                             int              priority,
                             int              stack_size,
                             void*            extension);
os_error_t os_thread_del_self (void);
os_error_t os_thread_suspend (os_thread_t* thread);
int        os_thread_active_priority (void);
void*      os_thread_active_extension (void);

os_error_t os_mutex_create (os_mutex_t* mutex);
os_error_t os_mutex_del (os_mutex_t* mutex);
os_error_t os_mutex_lock (os_mutex_t* mutex);
os_error_t os_mutex_unlock (os_mutex_t* mutex);
int        os_mutex_own (os_mutex_t* mutex);
int        os_mutex_locked (os_mutex_t* mutex);

os_error_t os_cond_var_create (os_cond_var_t* cond_var);
os_error_t os_cond_var_del (os_cond_var_t* cond_var);
os_error_t os_cond_var_wait (os_cond_var_t* cond_var, os_mutex_t *mutex);
os_error_t os_cond_var_signal (os_cond_var_t* cond_var);
os_error_t os_cond_var_broadcast (os_cond_var_t* cond_var);

os_error_t os_events_create (os_events_t* events, unsigned int preset);
os_error_t os_events_del (os_events_t* events);
os_error_t os_events_receive (os_events_t* events, unsigned int in,
                              unsigned int* out, int timeout);
os_error_t os_events_send (os_events_t* events, os_thread_t* thread);

os_error_t os_timer_create (os_timer_t* timer, os_mutex_t* mutex);
os_error_t os_timer_reset (os_timer_t* timer, int ticks,
                           os_timeout_t timeout, void* arg, int unlock);
os_error_t os_timer_stop (os_timer_t* timer);

int os_start (void);

#endif
