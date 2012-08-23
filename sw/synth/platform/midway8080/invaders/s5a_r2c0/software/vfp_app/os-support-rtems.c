/*
 * RTEMS Support. Wrap what we need and abstract from the application.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "os-support.h"

#include <rtems/error.h>

#include "veb.h"
#include "dbg_helper.h"

#ifndef OS_PRINTING
#define OS_PRINTING 0
#endif
#if OS_PRINTING
#define OS_PRINT(fmt, ...) \
  printf ("%s:" fmt, __FUNCTION__, __VA_ARGS__)
#else
#define OS_PRINT(fmt, ...)
#endif

#define OS_SC_ERROR(_e) os_sc_error_report (__FUNCTION__, _e)
#define OS_ERRNO_ERROR(_e) os_errno_error_report (__FUNCTION__, _e)

static os_error_t
os_sc_error_report (const char* message, rtems_status_code sc)
{
  if (sc != RTEMS_SUCCESSFUL)
    PRINT (0, "os-error: %s: %s\n", message, rtems_status_text (sc));
  return sc == RTEMS_SUCCESSFUL ? os_successful : os_error;
}

static os_error_t
os_errno_error_report (const char* message, int eno)
{
  if (eno != 0)
    PRINT (0, "os-error: %s: %s\n", message, strerror (eno));
  return eno == 0 ? os_successful : os_error;
}

/*
 * TODO: Move this to a header.
 */
void s5a_watchdog_reset (void);

static pthread_key_t thread_key;

static os_error_t
os_thread_create_thread_key (void)
{
  static bool initialised;
  if (!initialised)
  {
    initialised = true;
    OS_ERRNO_ERROR (pthread_key_create (&thread_key, NULL));
  }
  return os_successful;
}

int os_thread_active_priority (void)
{
  os_thread_t* thread = (os_thread_t*) pthread_getspecific (thread_key);
  return thread->priority;
}

void*
os_thread_active_extension (void)
{
  os_thread_t* thread = (os_thread_t*) pthread_getspecific (thread_key);
  return thread->extension;
}

static void*
os_thread_wrapper (void* arg)
{
  os_thread_t* thread = (os_thread_t*) arg;
  OS_ERRNO_ERROR (pthread_setspecific (thread_key, arg));
  thread->body (thread->data);
  pthread_exit(0);
  return 0;
}

os_error_t
os_thread_create (os_thread_t*     thread,
                  os_thread_body_t body,
                  void*            data,
                  int              priority,
                  int              stack_size,
                  void*            extension)
{
  struct sched_param param;
  pthread_attr_t     attr;
  const bool         realtime = true;

  os_thread_create_thread_key ();

  thread->priority = priority;
  thread->body = body;
  thread->data = data;
  thread->extension = extension;
  
  param.sched_priority = priority;

  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  if (realtime)
  {
    pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    pthread_attr_setschedparam(&attr, &param);
  }
  else
    pthread_attr_setschedpolicy(&attr, SCHED_OTHER);
  pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);

  /*
   * Add this overhead as some POSIX platforms have deep libc calls.
   */
  unsigned long ssize = stack_size + 2048;

  /*
   * If the stack is not the min make it the minimum.
   */
  if (ssize < PTHREAD_STACK_MIN)
    ssize = PTHREAD_STACK_MIN;

  /*
   * Some hosts require the stack size to be page aligned.
   */
  int page_size = getpagesize();
  ssize = (((ssize - 1) / page_size) + 1) * page_size;

  int r = pthread_attr_setstacksize(&attr, ssize);
  
  if (r == 0)
    r = pthread_create(&thread->id, &attr, os_thread_wrapper, thread);

  pthread_attr_destroy(&attr);
  
  return OS_ERRNO_ERROR (r);
}

os_error_t
os_thread_del_self ()
{
  pthread_exit(0);
  return os_successful;
}

os_error_t
os_thread_suspend (os_thread_t* thread)
{
  pthread_detach(thread->id);
  return os_successful;
}

os_error_t
os_mutex_create (os_mutex_t* mutex)
{
  mutex->owner = 0;
  mutex->count = 0;
  pthread_mutexattr_t att;
  pthread_mutexattr_init (&att);
  pthread_mutexattr_settype (&att, PTHREAD_MUTEX_RECURSIVE);
  pthread_mutexattr_setprotocol (&att, PTHREAD_PRIO_INHERIT);
  int r = pthread_mutex_init (&mutex->handle, &att);
  pthread_mutexattr_destroy (&att);
  OS_PRINT ("%p -> %08lx: created\n", mutex, mutex->handle);
  return OS_ERRNO_ERROR (r);
}

os_error_t
os_mutex_del (os_mutex_t* mutex)
{
  return OS_ERRNO_ERROR (pthread_mutex_destroy(&mutex->handle));
}

os_error_t
os_mutex_lock (os_mutex_t* mutex)
{
  pthread_t self = pthread_self ();
  OS_PRINT ("%p[%d] (%08lx/%08lx) locking\n",
            mutex, mutex->count, mutex->owner, self);
  int r = pthread_mutex_lock(&mutex->handle);
  mutex->owner = self;
  ++mutex->count;
  OS_PRINT ("%p[%d] locked\n", mutex, mutex->count);
  return OS_ERRNO_ERROR (r);
}

os_error_t
os_mutex_unlock (os_mutex_t* mutex)
{
  OS_PRINT ("%p[%d] (%08lx/%08lx) unlock\n",
            mutex, mutex->count,  mutex->owner, pthread_self ());
  if (mutex->count)
    --mutex->count;
  if (mutex->count == 0)
      mutex->owner = 0;
   return OS_ERRNO_ERROR (pthread_mutex_unlock (&mutex->handle));
}

int
os_mutex_own (os_mutex_t* mutex)
{
  pthread_t self = pthread_self ();
  int owned = mutex->owner == self;
  OS_PRINT ("%p (%08lx/%08lx) own: %s\n",
            mutex, mutex->owner, self, owned ? "yes" : "no");
  return owned;
}

os_error_t
os_cond_var_create (os_cond_var_t* cond_var)
{
  return OS_ERRNO_ERROR (pthread_cond_init (cond_var, NULL));
}

os_error_t
os_cond_var_del (os_cond_var_t* cond_var)
{
  return OS_ERRNO_ERROR (pthread_cond_destroy(cond_var));
}

os_error_t
os_cond_var_wait (os_cond_var_t* cond_var, os_mutex_t* mutex)
{
  pthread_t owner = mutex->owner;
  if (mutex->count)
    --mutex->count;
  if (mutex->count == 0)
      mutex->owner = 0;
  int r = pthread_cond_wait (cond_var, &mutex->handle);
  mutex->owner = owner;
  ++mutex->count;
  return OS_ERRNO_ERROR (r);
}

os_error_t
os_cond_var_signal (os_cond_var_t* cond_var)
{
  return OS_ERRNO_ERROR (pthread_cond_signal(cond_var));
}

os_error_t
os_cond_var_broadcast (os_cond_var_t* cond_var)
{
  return OS_ERRNO_ERROR (pthread_cond_broadcast(cond_var));
}

/*
 * Use the classic API for event because they are faster and work with POSIX
 * thread. For a POSIX solution you need to wrap a condition variable.
 */
os_error_t
os_events_create (os_events_t* events, unsigned int preset)
{
  events->id = 0;
  return os_successful;
}

os_error_t
os_events_del (os_events_t* events)
{
  events->id = 0;
  return os_successful;
}

os_error_t
os_events_receive (os_events_t* events, unsigned int in,
                   unsigned int* out, int timeout)
{
  rtems_status_code sc;
  rtems_event_set   event_out;

  events->id = rtems_task_self ();
  
  sc = rtems_event_receive (RTEMS_EVENT_8,
                            RTEMS_WAIT | RTEMS_EVENT_ANY,
                            TOD_MICROSECONDS_TO_TICKS (timeout),
                            &event_out);

  if ((sc != RTEMS_SUCCESSFUL) && (sc != RTEMS_TIMEOUT))
    return OS_SC_ERROR (sc);
  return sc == RTEMS_TIMEOUT ? os_timeout : os_successful;
}

os_error_t
os_events_send (os_events_t* events, os_thread_t* thread)
{
  return OS_SC_ERROR (rtems_event_send (thread->id, RTEMS_EVENT_8));
}

os_error_t
os_timer_create (os_timer_t* timer, os_mutex_t* mutex)
{
  timer->flags = 0;
  timer->next = NULL;
  timer->mutex = mutex;
  timer->timeout = NULL;
  timer->arg = NULL;
  return os_successful;
}

#define OS_TIMER_OS_TICKS (os_ticks_per_second () / OS_TIMER_TICKS_PER_SEC)

static volatile os_timer_t* os_timer_head;
static os_thread_t timer_thread;

static void
os_timer_task (void* arg)
{
  rtems_interval ticks = OS_TIMER_OS_TICKS;
  while (1)
  {
    os_interrupt_level cpu_sr;
    os_interrupt_disable (cpu_sr);
    if (os_timer_head)
    {
      os_timer_t* timer = (os_timer_t*) os_timer_head;
      if (timer->delta)
        --timer->delta;
      if (timer->delta == 0)
      {
        os_timer_head = timer->next;
        timer->next = NULL;
        timer->flags &= ~OS_TIMER_QUEUED;
        os_interrupt_enable (cpu_sr);
        if (timer->timeout)
        {
          if (timer->mutex)
            os_mutex_lock (timer->mutex);
          timer->timeout (timer->arg);
          if (timer->mutex &&
              ((timer->flags & OS_TIMER_RETURNED_UNLOCKED) == 0))
            os_mutex_unlock (timer->mutex);
        }
        os_interrupt_disable (cpu_sr);
      }
    }
    os_interrupt_enable (cpu_sr);
    rtems_task_wake_after(ticks);
  }
}

os_error_t
os_timer_reset (os_timer_t* timer, int _ticks,
                os_timeout_t timeout, void* arg, int returns_unlocked)
{
  if (timeout)
  {
    os_timer_t**       prev = (os_timer_t**) &os_timer_head;
    os_timer_t*        node;
    os_interrupt_level cpu_sr;
    
    os_timer_stop (timer);

    _ticks /= OS_TIMER_OS_TICKS;
    if (_ticks <= 0)
      _ticks = 1;
    
    timer->next = NULL;
    timer->ticks = _ticks;
    timer->timeout = timeout;
    timer->arg = arg;
    if (returns_unlocked)
      timer->flags |= OS_TIMER_RETURNED_UNLOCKED;

    os_interrupt_disable (cpu_sr);

    node = (os_timer_t*) os_timer_head;
    while (node)
    {
      if ((_ticks - node->delta) <= 0)
      {
        node->delta -= _ticks;
        break;
      }
      _ticks -= node->delta;
      prev = &node->next;
      node = node->next;
    }

    timer->flags |= OS_TIMER_QUEUED;
    timer->delta = _ticks;
    timer->next = *prev;
    *prev = timer;

    os_interrupt_enable (cpu_sr);
  }
  
  return os_successful;
}

os_error_t
os_timer_stop (os_timer_t* timer)
{
  os_timer_t**       prev = (os_timer_t**) &os_timer_head;
  os_timer_t*        node;
  os_interrupt_level cpu_sr;
  
  os_interrupt_disable (cpu_sr);

  if ((timer->flags & OS_TIMER_QUEUED) != 0)
  {
    node = (os_timer_t*) os_timer_head;
    while (node)
    {
      if (node == timer)
      {
        if (timer->next)
          timer->next->delta += timer->delta;
        *prev = timer->next;
        timer->flags = 0;
        timer->next = NULL;
        break;
      }
      prev = &node->next;
      node = node->next;
    }
  }
  
  os_interrupt_enable (cpu_sr);
  return os_successful;
}

#if OS_SUPPORT_TIMER_TESTS
static void
os_support_test_timer (void* data)
{
}

static void
os_support_test (void)
{
  os_mutex_t m;
  os_timer_t t[5];
  int        i;

  os_mutex_create (&m);
  
  for (i = 0; i < 5; i++)
    os_timer_create (&t[i], &m);

  os_timer_reset (&t[0],  50, os_support_test_timer, &t[0], 0);
  os_timer_stop (&t[0]);

  os_timer_reset (&t[0],  50, os_support_test_timer, &t[0], 0);
  os_timer_reset (&t[0], 100, os_support_test_timer, &t[0], 0);
  os_timer_stop (&t[0]);

  for (i = 0; i < 4; i++)
    os_timer_reset (&t[i], (50 * i) + 50, os_support_test_timer, &t[1], 0);
  
  os_timer_reset (&t[4], 120, os_support_test_timer, &t[4], 0);
  
  os_timer_stop (&t[1]);
  os_timer_stop (&t[0]);
  os_timer_stop (&t[3]);
  os_timer_stop (&t[2]);
  os_timer_stop (&t[4]);
}
#endif

int
os_start (void)
{
  os_thread_create (&timer_thread, os_timer_task, NULL,
                    TIMER_TASK_PRIORITY, TIMER_TASK_STACKSIZE, NULL);    
  return 0;
}
