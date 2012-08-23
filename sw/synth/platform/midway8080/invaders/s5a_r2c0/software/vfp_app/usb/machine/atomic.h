/**
 * @file
 *
 * @ingroup rtems_bsd_machine
 *
 * @brief TODO.
 */

/*
 * Copyright (c) 2009, 2010 embedded brains GmbH.  All rights reserved.
 *
 *  embedded brains GmbH
 *  Obere Lagerstr. 30
 *  82178 Puchheim
 *  Germany
 *  <nios2@embedded-brains.de>
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution or at
 * http://www.nios2.com/license/LICENSE.
 */

#ifndef _NIOS2_BSD_MACHINE_ATOMIC_H_
#define _NIOS2_BSD_MACHINE_ATOMIC_H_

#include "../../os-support.h"

#define mb() NIOS2_COMPILER_MEMORY_BARRIER()
#define wmb() NIOS2_COMPILER_MEMORY_BARRIER()
#define rmb() NIOS2_COMPILER_MEMORY_BARRIER()

static inline void
atomic_add_int(volatile int *p, int v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p += v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_add_acq_int atomic_add_int
#define atomic_add_rel_int atomic_add_int

static inline void
atomic_subtract_int(volatile int *p, int v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p -= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_subtract_acq_int atomic_subtract_int
#define atomic_subtract_rel_int atomic_subtract_int

static inline void
atomic_set_int(volatile int *p, int v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p |= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_set_acq_int atomic_set_int
#define atomic_set_rel_int atomic_set_int

static inline void
atomic_clear_int(volatile int *p, int v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p &= ~v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_clear_acq_int atomic_clear_int
#define atomic_clear_rel_int atomic_clear_int

static inline int
atomic_cmpset_int(volatile int *p, int cmp, int set)
{
	os_interrupt_level cpu_sr;
	int rv;

	os_interrupt_disable(cpu_sr);
	rv = *p == cmp;
	if (rv) {
		*p = set;
	}
	os_interrupt_enable(cpu_sr);

	return rv;
}

#define atomic_cmpset_acq_int atomic_cmpset_int
#define atomic_cmpset_rel_int atomic_cmpset_int

static inline int
atomic_fetchadd_int(volatile int *p, int v)
{
	os_interrupt_level cpu_sr;
	int tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p += v;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline int
atomic_readandclear_int(volatile int *p)
{
	os_interrupt_level cpu_sr;
	int tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p = 0;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline int
atomic_load_acq_int(volatile int *p)
{
	return *p;
}

static inline void
atomic_store_rel_int(volatile int *p, int v)
{
	*p = v;
}

static inline void
atomic_add_32(volatile uint32_t *p, uint32_t v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p += v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_add_acq_32 atomic_add_32
#define atomic_add_rel_32 atomic_add_32

static inline void
atomic_subtract_32(volatile uint32_t *p, uint32_t v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p -= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_subtract_acq_32 atomic_subtract_32
#define atomic_subtract_rel_32 atomic_subtract_32

static inline void
atomic_set_32(volatile uint32_t *p, uint32_t v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p |= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_set_acq_32 atomic_set_32
#define atomic_set_rel_32 atomic_set_32

static inline void
atomic_clear_32(volatile uint32_t *p, uint32_t v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p &= ~v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_clear_acq_32 atomic_clear_32
#define atomic_clear_rel_32 atomic_clear_32

static inline int
atomic_cmpset_32(volatile uint32_t *p, uint32_t cmp, uint32_t set)
{
	os_interrupt_level cpu_sr;
	int rv;

	os_interrupt_disable(cpu_sr);
	rv = *p == cmp;
	if (rv) {
		*p = set;
	}
	os_interrupt_enable(cpu_sr);

	return rv;
}

#define atomic_cmpset_acq_32 atomic_cmpset_32
#define atomic_cmpset_rel_32 atomic_cmpset_32

static inline uint32_t
atomic_fetchadd_32(volatile uint32_t *p, uint32_t v)
{
	os_interrupt_level cpu_sr;
	uint32_t tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p += v;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline uint32_t
atomic_readandclear_32(volatile uint32_t *p)
{
	os_interrupt_level cpu_sr;
	uint32_t tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p = 0;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline uint32_t
atomic_load_acq_32(volatile uint32_t *p)
{
	return *p;
}

static inline void
atomic_store_rel_32(volatile uint32_t *p, uint32_t v)
{
	*p = v;
}

static inline void
atomic_add_long(volatile long *p, long v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p += v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_add_acq_long atomic_add_long
#define atomic_add_rel_long atomic_add_long

static inline void
atomic_subtract_long(volatile long *p, long v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p -= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_subtract_acq_long atomic_subtract_long
#define atomic_subtract_rel_long atomic_subtract_long

static inline void
atomic_set_long(volatile long *p, long v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p |= v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_set_acq_long atomic_set_long
#define atomic_set_rel_long atomic_set_long

static inline void
atomic_clear_long(volatile long *p, long v)
{
	os_interrupt_level cpu_sr;

	os_interrupt_disable(cpu_sr);
	*p &= ~v;
	os_interrupt_enable(cpu_sr);
}

#define atomic_clear_acq_long atomic_clear_long
#define atomic_clear_rel_long atomic_clear_long

static inline int
atomic_cmpset_long(volatile long *p, long cmp, long set)
{
	os_interrupt_level cpu_sr;
	int rv;

	os_interrupt_disable(cpu_sr);
	rv = *p == cmp;
	if (rv) {
		*p = set;
	}
	os_interrupt_enable(cpu_sr);

	return rv;
}

#define atomic_cmpset_acq_long atomic_cmpset_long
#define atomic_cmpset_rel_long atomic_cmpset_long

static inline long
atomic_fetchadd_long(volatile long *p, long v)
{
	os_interrupt_level cpu_sr;
	long tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p += v;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline long
atomic_readandclear_long(volatile long *p)
{
	os_interrupt_level cpu_sr;
	long tmp;

	os_interrupt_disable(cpu_sr);
	tmp = *p;
	*p = 0;
	os_interrupt_enable(cpu_sr);

	return tmp;
}

static inline long
atomic_load_acq_long(volatile long *p)
{
	return *p;
}

static inline void
atomic_store_rel_long(volatile long *p, long v)
{
	*p = v;
}

#endif /* _NIOS2_BSD_MACHINE_ATOMIC_H_ */
