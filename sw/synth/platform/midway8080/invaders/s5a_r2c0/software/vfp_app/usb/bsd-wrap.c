#include "usb.h"
#include "usbdi.h"

#define	USB_DEBUG_VAR usb_wrap

#include "usb_core.h"
#include "usb_debug.h"
#include "usb_busdma.h"
#include "usb_process.h"
#include "usb_transfer.h"
#include "usb_device.h"
#include "usb_dynamic.h"
#include "usb_hub.h"
#include "usb_util.h"

#include "usb_controller.h"
#include "usb_bus.h"
#include "ehci.h"
#include "ehcireg.h"

#include <stdarg.h>
#include <string.h>
#include <io.h>

#if USB_DEBUG
int usb_wrap    = 1;
int bsd_dma     = 0;
int bsd_kproc   = 0;
int bsd_mutex   = 0;
int bsd_sx      = 0;
int bsd_cv      = 0;
int bsd_callout = 0;
#endif

MALLOC_DEFINE(M_DEVBUF, "devbuf", "device driver memory");
MALLOC_DEFINE(M_TEMP,   "temp",   "misc temporary data buffers");
MALLOC_DEFINE(M_IOV,    "uio",    "user IO memory");
MALLOC_DEFINE(M_USB,    "usb",    "usb memory");
MALLOC_DEFINE(M_USBDEV, "usbdev", "usb device memory");

char sbuf_buffer[2048];
struct sbuf sbuf_handle = { .buf = sbuf_buffer };

int cold;
int hz;

struct mtx malloc_mtx;
struct malloc_type* malloc_type_head;
struct mtx Giant;

void
bsd_wrapper_init (void)
{
  cold = 1;
  hz = os_ticks_per_second ();
  mtx_init (&malloc_mtx, "malloc_mtx", 0, 0);
  mtx_init (&Giant, "Giant", 0, 0);
  M_USB->ks_handle = &oxu210_heap_allocator;
  oxu210_allocator_init ();
}

int
bsd_drop_giant (void)
{
  int count = 0;
  if (mtx_owned (&Giant))
  {
    for (count = 0; mtx_owned (&Giant); ++count)
      mtx_unlock (&Giant);
  }
  return count;
}

void
bsd_pickup_giant (int count)
{
  mtx_assert (&Giant, MA_NOTOWNED);
  if (count > 0)
  {
    while (count--)
      mtx_lock (&Giant);
  }
}

void
malloc_init(void *data)
{
  struct malloc_type* mt = data;
  DPRINTF("%s\n", mt->ks_shortdesc);
	mtx_lock(&malloc_mtx);
  mt->ks_next = malloc_type_head;
  malloc_type_head = mt->ks_next;
	mtx_unlock(&malloc_mtx);
}

void
malloc_uninit(void *data)
{
}

struct malloc_type*
malloc_desc2type(const char *desc)
{
  struct malloc_type* mt = malloc_type_head;
  while (mt)
  {
    if (strcmp (desc, mt->ks_shortdesc) == 0)
      return mt;
    mt = mt->ks_next;
  }
  return NULL;
}

uint32_t
bsd_wrap_ticks (void)
{
  return os_ticks_since_boot ();
}

int
bsdwrap_pause (const char* s, int _ticks)
{
  /*
   * There is a special case of 0 in the FreeBSD kernel. A zero means
   * no timeout.
   */
  if (_ticks)
  {
    unsigned int usecs = ((_ticks * 1000) / hz) * 1000;
    usleep (usecs);
  }
  return 0;
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR bsd_kproc

int
kproc_kthread_add (void (*func)(void *), void *arg,
                   struct proc **newpp,
                   struct thread **tdptr,
                   int flags, int pages,
                   const char *procname, const char *fmt, ...)
{
  struct proc*   newpp_on_entry = *newpp;
  va_list        ap;
  char           name[KPROC_KTHREAD_NAME_SIZE];
  
  va_start (ap, fmt);

  vsnprintf (name, sizeof (name), fmt, ap);
  
  DPRINTF("%s - %s\n", procname, name);

  if (!*newpp)
  {
    *newpp = malloc (sizeof (struct proc), M_TEMP, M_WAITOK | M_ZERO);
    if (!*newpp)
      return 1;
    memset (*newpp, 0, sizeof (struct proc));
    (*newpp)->name = strdup (procname, M_TEMP);
  }
  *tdptr = malloc (sizeof (struct thread), M_TEMP, M_WAITOK | M_ZERO);
  if (!*tdptr)
  {
    if (newpp_on_entry == NULL)
    {
      free ((*newpp)->name, M_TEMP);
      free (*newpp, M_TEMP);
    }
    return 1;
  }

  memset (*tdptr, 0, sizeof (struct thread));
  (*tdptr)->arg = arg;
  strcpy ((*tdptr)->name, name);

  os_error_t e = os_thread_create (&(*tdptr)->thread,
                                   func, arg, USB_TASK_PRIORITY,
                                   USB_TASK_STACKSIZE, *tdptr);

  if (e != os_successful)
  {
    if (newpp_on_entry == NULL)
    {
      free ((*newpp)->name, M_TEMP);
      free (*newpp, M_TEMP);
    }
    return 1;
  }
  
  va_end (ap);
  return 0;
}

void
kthread_exit (void)
{
  DPRINTF("\n");
  os_thread_del_self ();
}

int
kthread_suspend (struct thread *td, int timo)
{
  DPRINTF("%s\n", td->name);
  os_thread_suspend (&td->thread);
  return 0;
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR bsd_mutex

void
mtx_init(struct mtx *mutex, const char *name, const char *type, int opts)
{
  DPRINTF("%s\n", name);
  memset (mutex, 0, sizeof (struct mtx));
  mutex->initialised = 123456;
  mutex->name = strdup (name, M_TEMP);
  if (os_mutex_create (&mutex->lock_object.mutex) != os_successful)
  {
    printf ("mtx_init: mutex is NULL. Stopping for-ever\n");
    while (1);
  }
}

void
mtx_destroy(struct mtx *mutex)
{
  DPRINTF("%s\n", mutex->name);
  os_mutex_del (&mutex->lock_object.mutex);
  free (mutex->name, M_TEMP);
}

void
mtx_lock(struct mtx *mutex)
{
  DPRINTF("locking %s\n", mutex->name);
  os_mutex_lock (&mutex->lock_object.mutex);
  DPRINTF("%s locked\n", mutex->name);
}

void
mtx_unlock(struct mtx *mutex)
{
  DPRINTF("%s id:%p\n", mutex->name, &mutex->lock_object);
  os_mutex_unlock (&mutex->lock_object.mutex);
}

void
mtx_assert(struct mtx *mutex, int what)
{
  int owned = os_mutex_own (&mutex->lock_object.mutex);
  DPRINTF("%s is %s\n", mutex->name, owned ? "owned" : "not owned");
  switch (what)
  {
    case MA_OWNED:
      if (!owned)
        printf ("mutex panic: %s is not owned\n", mutex->name);
      break;
    case MA_NOTOWNED:
      if (owned)
        printf ("mutex panic: %s is owned\n", mutex->name);
      break;
    default:
      break;
  }
}

int
mtx_initialized(struct mtx *mutex)
{
  int initialised = mutex->initialised == 1234546;
  DPRINTF("%s initaliased: %s\n", mutex->name, initialised ? "yes" : "no");
  return initialised;
}

int
mtx_owned(struct mtx *mutex)
{
  int owned = os_mutex_own (&mutex->lock_object.mutex);
  DPRINTF("%s owned: %s\n", mutex->name, owned ? "yes" : "no");
  return owned;
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR bsd_sx

void
sx_init(struct sx *sx, const char *description)
{
  DPRINTF("%s\n", description);
  memset (sx, 0, sizeof (struct sx));
  sx->desc = strdup (description, M_TEMP);
  if (os_mutex_create (&sx->handle) != os_successful)
  {
    printf ("sx_init: mutex is NULL. Stopping for-ever\n");
    while (1);
  }
}

void
sx_init_flags(struct sx *sx, const char *description, int opts)
{
  sx_init (sx, description);
}

void
sx_destroy(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_del (&sx->handle);
  free (sx->desc, M_TEMP);
}

void
sx_slock(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_lock (&sx->handle);
}

void
sx_sunlock(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_unlock (&sx->handle);
}

void
sx_xlock(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_lock (&sx->handle);
}

void
sx_xunlock(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_unlock (&sx->handle);
}

int
sx_xlocked(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  return os_mutex_own (&sx->handle);
}

void
sx_unlock(struct sx *sx)
{
  DPRINTF("%s\n", sx->desc);
  os_mutex_unlock (&sx->handle);
}

void
sx_assert(struct sx *sx, int what)
{
  DPRINTF("%s\n", sx->desc);
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR bsd_cv

void
cv_init (struct cv *cv, const char *desc)
{
  DPRINTF("%s\n", desc);
  memset (cv, 0, sizeof (struct cv));
  cv->initialised = 123456;
  cv->name = strdup (desc, M_TEMP);
  os_cond_var_create (&cv->handle);
}

void
cv_destroy (struct cv *cv)
{
  DPRINTF("%p: %s\n", cv, cv->name);
  os_cond_var_del (&cv->handle);
  free (cv->name, M_TEMP);
}

void
cv_wait (struct cv *cv, struct mtx* mutex)
{
  int giant_cnt;
  if (mutex == &Giant)
  {
    printf ("mutex is Giant\n");
    mtx_assert(&Giant, MA_OWNED);
  }
  DPRINTF("%p: %s drop Giant\n", cv, cv->name);
  giant_cnt = bsd_drop_giant ();
  DPRINTF("%p: %s IN lock is %p: %s Giant:%d\n",
          cv, cv->name, mutex, mutex->name, giant_cnt);
  os_cond_var_wait (&cv->handle, &mutex->lock_object.mutex);
  DPRINTF("%p: %s OUT\n", cv, cv->name);
  bsd_pickup_giant (giant_cnt);
  DPRINTF("%p: %s Giant picked up\n", cv, cv->name);
}

void
cv_signal (struct cv *cv)
{
  DPRINTF("%p: %s\n", cv, cv->name);
  os_cond_var_signal (&cv->handle);
}

void
cv_broadcast (struct cv *cv)
{
  DPRINTF("%p: %s\n", cv, cv->name);
  os_cond_var_broadcast (&cv->handle);
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR bsd_callout

void
_callout_init_lock(struct callout *co, struct lock_object *lck, int mpsafe)
{
  DPRINTF("\n");
  os_timer_create (&co->handle, &lck->mutex);
}

int
_callout_stop_safe(struct callout *co, int safe)
{
  DPRINTF("\n");
  os_timer_stop (&co->handle);
  return 0;
}

int
callout_reset_on(struct callout *co, int _ticks,
                 void (*func)(void *), void *arg, int cpu)
{
  DPRINTF("ticks=%d func=%p\n", _ticks, func);
  if (_ticks <= 0)
    _ticks = 0;
  return os_timer_reset (&co->handle, _ticks, func, arg,
                         co->c_flags & CALLOUT_RETURNUNLOCKED ? 1 : 0) == os_successful ? 0 : 1;
}

#undef USB_DEBUG_VAR
#define	USB_DEBUG_VAR usb_wrap

void s5a_watchdog_reset (void);

void
panic (const char* fmt, ...)
{
  va_list  ap;
  va_start (ap, fmt);
  vprintf (fmt, ap);
  s5a_watchdog_reset ();
  va_end (ap);
  while (1);
}

int
copystr(const void * kfaddr, void * kdaddr, size_t len, size_t * lencopied)
{
  strncpy (kdaddr, kfaddr, len);
  *lencopied = strnlen (kdaddr, len);
  return 0;
}

int
copyinstr(const void *udaddr, void *kaddr, size_t len, size_t* lencopied)
{
  strncpy (kaddr, udaddr, len);
  *lencopied = strnlen (kaddr, len);
  return 0;
}

int
copyin(const void *udaddr, void *kaddr, size_t len)
{
  memcpy (kaddr, udaddr, len);
  return 0;
}

int
copyout(const void *kaddr, void *udaddr, size_t len)
{
  memcpy (udaddr, kaddr, len);
  return 0;
}

#undef malloc
void* malloc (size_t size);
void*
bsd_malloc (unsigned long size, struct malloc_type *mtp, int flags)
{
  void* p;
  if (mtp->ks_handle)
  {
    s5a_heap_allocator_t* allocator = mtp->ks_handle;
    p = allocator->alloc (size);
  }
  else
    p = malloc (size);
  if (p && (flags & M_ZERO))
    memset (p, 0, size);
  DPRINTFN (10, "[%s] size=%ld @ %p %s\n", mtp->ks_shortdesc,
            size, p, flags & M_ZERO ? "ZERO" : "");
  return p;
}

#undef free
void free(void* p);
void
bsd_free (void* p, struct malloc_type *mtp)
{
  if (p)
  {
    DPRINTFN (10, "[%s] %p\n", mtp->ks_shortdesc, p);
    if (mtp->ks_handle)
    {
      s5a_heap_allocator_t* allocator = mtp->ks_handle;
      allocator->free (p);
    }
    else
      free (p);
  }
}
