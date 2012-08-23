/*
 * Various bits and pieces need to support the build on the S5A.
 */
#if !defined (USB_BSD_WRAP_H)
#define USB_BSD_WRAP_H

#ifndef __INT_MAX
# define __INT_MAX 2147483647
#endif
#define INT_MAX __INT_MAX

/*
 * FreeBSD.
 */
#define _LITTLE_ENDIAN   1
#define _BYTE_ORDER      _LITTLE_ENDIAN
#define _KERNEL          1
#define MAXCPU           1

//#define VERBOSE_SYSINIT  1
//#define BUS_DEBUG        1

/*
 * USB.
 */
#ifndef USB_DEBUG_LEVEL
#define USB_DEBUG_LEVEL 0
#endif
#define USB_DEBUG_DEFAULT USB_DEBUG_LEVEL
#if USB_DEBUG_LEVEL
#define USB_DEBUG         1
#define USB_REQ_DEBUG     1
#endif

/*
 * We need uint*_t.
 */
#include <stdint.h>
#include <sys/cdefs.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>

#include "sys/cdefs.h"
#include "sys/types.h"

#include "../os-support.h"

/*
 * Various includes that are needed. Placed here to make adding files simpler.
 */
#include "sys/queue.h"
#include "sys/callout.h"

#include <errno.h>
#include <string.h>
#include <sys/cdefs.h>
#include <ctype.h>
#include <stdarg.h>

/*
 * Low level OS stuff.
 */
#define M_NIOS_HEAP M_DEVBUF

#define PAGE_SHIFT        (12)
#define PAGE_SIZE         (1 << PAGE_SHIFT)
#define PAGE_MASK         (PAGE_SIZE - 1)
#define UMA_SMALLEST_UNIT (PAGE_SIZE / 256)

#define bootverbose (1)

#define KASSERT(_t, _m)

#define WITNESS_WARN(_f, _n, format...)

#define ENOIOCTL 166
/*
 * Avoid pulling unistd.h, stdio.h etc.
 */
int printf(const char *format, ...);
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);
int vprintf(const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);

/*
 * Time.
 */
#ifndef __time_t_defined
typedef _TIME_T_ time_t;
#define __time_t_defined
#endif

uint32_t bsd_wrap_ticks (void);

#define ticks       bsd_wrap_ticks()
#define switchticks (0)
#define hogticks    (INT_MAX)
#define bootticks   ticks

/*
 * Remap strdup to something local.
 */
char* strdup (const char* s);
#define strdup(_s, _f) strdup(_s)

#define bzero(_d, _l) memset(_d, 0, _l)
#define bcopy(_s, _d, _l) memmove((void*)(_d), (void*)(_s), (size_t)(_l)) 

void uio_yield(void);

/*
 * Copy IN/OUT.
 */
int copystr(const void * __restrict kfaddr, void * __restrict kdaddr, size_t len, 
            size_t * __restrict lencopied) __nonnull(1) __nonnull(2);
int copyinstr(const void * __restrict udaddr, void * __restrict kaddr, size_t len,
              size_t * __restrict lencopied) __nonnull(1) __nonnull(2);
int copyin(const void * __restrict udaddr, void * __restrict kaddr,
           size_t len) __nonnull(1) __nonnull(2);
int copyout(const void * __restrict kaddr, void * __restrict udaddr,
            size_t len) __nonnull(1) __nonnull(2);

static inline int
subyte(void *base, int byte)
{
  *((uint8_t*) base) = (uint8_t) byte;
  return 0;
}

/*
 * Panic.
 */
#define BSD_PANIC(_s) panic (_s)
void panic(const char *, ...) __dead2 __printflike(1, 2);

/*
 * Kernel thread support.
 */
#define __FreeBSD_version 800000

#define KPROC_KTHREAD_NAME_SIZE (32)

#define PCPU_GET(_v) (_v)

#define TDP_DEADLKTREAT (1 << 0)

struct proc;

struct thread {
  struct thread* next;
  char           name[KPROC_KTHREAD_NAME_SIZE];
  os_thread_t    thread;
  void*          arg;
  struct proc*   td_proc;
  uint32_t       td_pflags;
};

struct proc {
  char*          name;
  struct thread* head;
};

#define PROC_LOCK(_p)
#define PROC_UNLOCK(_p)

#define RFHIGHPID 0

int kproc_kthread_add(void (*)(void *), void *,
                      struct proc **,
                      struct thread **,
                      int flags, int pages,
                      const char *procname, const char *, ...);
void kthread_exit(void);
int kthread_suspend(struct thread *, int);

#define thread_lock(_td)
#define thread_unlock(_td)
#define sched_prio(_td, _p)

#define psignal(_p, _s)

extern struct proc *usbproc;

#define curthread os_thread_active_extension ()

/*
 * See if any thread wants to run.
 */
#define mi_switch(_d, _t) os_yield ()

/*
 * Delays. The DELAY call takes a usec timo and pause takes ticks.
 */
#define DELAY(_u) usleep (_u)
#undef pause
#define pause(_s, _t) bsdwrap_pause(_s, _t)
int bsdwrap_pause(const char* s, int _ticks);

/*
 * Malloc shuffle.
 */
#define malloc(_s, _t, _f) bsd_malloc (_s, _t, _f)
#define free(_p, _t)       bsd_free (_p, _t)

/*
 * Lock object support.
 */
struct lock_object {
  os_mutex_t mutex;
};

/*
 * Mutex support.
 */
#define MTX_DEF     (1 << 0)
#define MTX_RECURSE (1 << 1)
#define MA_OWNED    0
#define MA_NOTOWNED 1

struct mtx {
  int                 initialised;
  char*               name;
   struct lock_object lock_object;
};

#define MTX_DECL_INIT(_m, _n) \
  struct mtx _m = { .initialised = 123456, .name = _n }

void mtx_init(struct mtx *mutex, const char *name, const char *type, int opts);
void mtx_destroy(struct mtx *mutex);
void mtx_lock(struct mtx *mutex);
void mtx_unlock(struct mtx *mutex);
void mtx_assert(struct mtx *mutex, int what);
int mtx_initialized(struct mtx *mutex);
int mtx_owned(struct mtx *mutex);

extern struct mtx malloc_mtx;

extern struct mtx Giant;
#define GIANT_REQUIRED
#define DROP_GIANT()   mtx_unlock (&Giant)
#define PICKUP_GIANT() mtx_lock (&Giant)

struct sx {
  char*      desc;
  os_mutex_t handle;
};

#define SA_LOCKED  0
#define SA_XLOCKED 0
#define SX_LOCKED  0
#define SX_XLOCKED 0
#define SX_DUPOK   0
void sx_init(struct sx *sx, const char *description);
void sx_init_flags(struct sx *sx, const char *description, int opts);
void sx_destroy(struct sx *sx);
void sx_unlock(struct sx *sx);
void sx_slock(struct sx *sx);
void sx_sunlock(struct sx *sx);
void sx_xlock(struct sx *sx);
void sx_xunlock(struct sx *sx);
int  sx_xlocked(struct sx *sx);
void sx_assert(struct sx *sx, int what);

struct cv {
  int           initialised;
  char*         name;
  os_cond_var_t handle;
};

void cv_init (struct cv *cvp, const char *desc);
void cv_destroy (struct cv *cvp);
void cv_wait (struct cv *cvp, struct mtx* lock);
int  cv_wait_sig(struct cv *cvp, struct mtx* lock);
void cv_signal (struct cv *cvp);
void cv_broadcast (struct cv *cvp);

/*
 * Sbuf for safe string formatting.
 */
struct sbuf {
  char* buf;
};
extern struct sbuf sbuf_handle;
extern char sbuf_buffer[2048];
#define sbuf_new_auto()             &sbuf_handle
#define sbuf_printf(_sb, format...) sprintf(_sb->buf, format)
#define sbuf_finish(_sb)
#define sbuf_data(_sb)              (_sb->buf)
#define sbuf_delete(_sb)

/*
 * Cold start.
 */
extern int cold;

/*
 * USB Hooks that are stubbed.
 */
#define usb_iface_is_cdrom(_a1, _a2) (1)
#define root_mount_rel(_r)
#define root_mount_hold(_r)          NULL

/*
 * Initialise any global variables provided by the system.
 */
void bsd_wrapper_init (void);

#endif
