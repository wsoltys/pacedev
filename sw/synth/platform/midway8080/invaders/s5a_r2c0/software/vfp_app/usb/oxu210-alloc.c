/*-
 * Copyright (C) 2010 Virtual Logic Pty Ltd
 * All rights reserved.
 *
 * Developed by Chris Johns.
  */

#include "usb.h"
#include "usbdi.h"

#include "usb_core.h"
#include "usb_busdma.h"
#include "usb_process.h"
#include "usb_util.h"

#include "usb_controller.h"
#include "usb_bus.h"
#include "ehci.h"
#include "ehcireg.h"

#include "../veb.h"
#include "../dbg_helper.h"
#include "../oxu210hp.h"

#include <system.h>

#ifdef BUILD_INCLUDE_DEBUG
#define OXU210_ALLOC_DEBUG 1
#define DEBUG_PRINTING     0
#else
#define OXU210_ALLOC_DEBUG 0
#define DEBUG_PRINTING     0
#endif

#if DEBUG_PRINTING
#define DBPRINT(fmt, ...) \
  printf ("%s:" fmt, __FUNCTION__, __VA_ARGS__)
#else
#define DBPRINT(fmt, ...)
#endif

typedef uint32_t oxu210_bm_t;

#define OXU210_MEM_BASE              (OXU210HP_IF_0_BASE + 0xE000UL)
#define OXU210_MEM_SIZE              (72 * 1024)
#define OXU210_MEM_PAGE_SIZE         (4 * 1024)
#define OXU210_MEM_BLOCK_SIZE        (8)
#define OXU210_MEM_BLOCKS            (OXU210_MEM_SIZE / OXU210_MEM_BLOCK_SIZE)
#define OXU210_MEM_BM_BIT_BYTES      (sizeof (oxu210_bm_t))
#define OXU210_MEM_BM_BIT_BYTES_BITS (OXU210_MEM_BM_BIT_BYTES * 8)
#define OXU210_MEM_BM_BIT_MASK       (OXU210_MEM_BM_BIT_BYTES_BITS - 1)
#define OXU210_MEM_BIT_MAP_SIZE      (((OXU210_MEM_BLOCKS - 1) / OXU210_MEM_BM_BIT_BYTES_BITS) + 1)

static struct mtx oxu_lock;
static oxu210_bm_t bit_map[OXU210_MEM_BIT_MAP_SIZE];

void
oxu210_allocator_init (void)
{
  mtx_init (&oxu_lock, "oxu-alloc", 0, 0);
}

static int
oxu210_bits (size_t size)
{
  return ((size - 1) /  OXU210_MEM_BLOCK_SIZE) + 1;
}

static int
oxu210_bit_test (int bit)
{
  int slot = bit / OXU210_MEM_BM_BIT_BYTES_BITS;
  oxu210_bm_t mask = 1 << (bit % OXU210_MEM_BM_BIT_BYTES_BITS);
  return bit_map[slot] & mask ? 1 : 0;
}

static void
oxu210_bit_fiddle (int start, int len, int set)
{
  int         slot = start / OXU210_MEM_BM_BIT_BYTES_BITS;
  oxu210_bm_t mask = 1 << (start % OXU210_MEM_BM_BIT_BYTES_BITS);
  int         end = start + len;
  while (start < end)
  {
    if (set)
      bit_map[slot] |= mask;
    else
      bit_map[slot] &= ~mask;
    ++start;
    mask <<= 1;
    if ((start & OXU210_MEM_BM_BIT_MASK) == 0)
    {
      ++slot;
      mask = 1;
    }
  }
}

void
oxu210_aligned_alloc (void** vaddr,
                      void** paddr,
                      size_t size,
                      size_t alignment,
                      size_t boundary)
{
  int bits = oxu210_bits (size);
  int start = 0;
  int offset = 0;
  int edge = 0;
  int bit = 0;

  *vaddr = *paddr = NULL;

  if (alignment)
    offset = oxu210_bits (alignment);

  if (boundary)
    edge = oxu210_bits (boundary);
  
  DBPRINT ("size=%ld align=%ld, boundary=%ld bits=%d offs=%d edge=%d\n",
           size, alignment, boundary, bits, offset, edge);

  mtx_lock (&oxu_lock);
  
  while ((start + bits) < OXU210_MEM_BLOCKS)
  {
    if (oxu210_bit_test (start + bit))
    {
      if (offset)
        start = (((start + bit + offset - 1) / offset) + 1) * offset;
      else
        start += bit + 1;
      if (edge && ((bits > (edge - (start % edge)))))
        start = (((start + edge - 1) / edge) + 1) * edge;
      bit = 0;
    }
    else
    {
      ++bit;
      if (bit == bits)
      {
        *paddr = (void*) OXU210_MEM_BASE + (start * OXU210_MEM_BLOCK_SIZE);
#if NIOS2_HAS_DATA_CACHE
        *vaddr = (void*) (0x80000000 | ((intptr_t) *paddr));
#else
        *vaddr = *paddr;
#endif
        oxu210_bit_fiddle (start, bits, 1);
        DBPRINT ("addr=%08x start=%d bits=%d\n", *vaddr, start, bits);
        mtx_unlock (&oxu_lock);
        return;
      }
    }
  }
  
  PRINT (0, "oxu-alloc: no memory available\n");
  mtx_unlock (&oxu_lock);
  return;
}

void
oxu210_free (void* addr, size_t size)
{
  mtx_lock (&oxu_lock);
  DBPRINT ("addr=%08x, size=%d\n", addr, size);
  addr = (void*) (((intptr_t) addr) & ~0x80000000);
  if (addr)
  {
    int start = (((intptr_t) addr) - OXU210_MEM_BASE) / OXU210_MEM_BLOCK_SIZE;
    int bits  = oxu210_bits (size);
    DBPRINT ("addr=%08x, start=%d bits=%d\n", addr, start, bits);
    oxu210_bit_fiddle (start, bits, 0);
  }
  mtx_unlock (&oxu_lock);
}

#define OXU210_MALLOC_SLOTS (128)

typedef struct
{
  void*  addr;
  size_t size;
} oxu210_malloc_slot;

static oxu210_malloc_slot malloc_slot[OXU210_MALLOC_SLOTS];

void*
oxu210_heap_alloc (size_t size)
{
  oxu210_malloc_slot* slot = &malloc_slot[0];
  int                 s;
  mtx_lock (&oxu_lock);
  for (s = 0; s < OXU210_MALLOC_SLOTS; ++slot, ++s)
  {
    if (slot->size == 0)
    {
      void* paddr;
      oxu210_aligned_alloc (&slot->addr, &paddr, size, 0, 0);
      if (slot->addr)
        slot->size = size;
      mtx_unlock (&oxu_lock);
      return slot->addr;
    }
  }
  PRINT (0, "oxu-alloc: no slots\n");
  mtx_unlock (&oxu_lock);
  return NULL;
}

void
oxu210_heap_free (void* p)
{
  oxu210_malloc_slot* slot = &malloc_slot[0];
  int                 s;
  mtx_lock (&oxu_lock);
  for (s = 0; s < OXU210_MALLOC_SLOTS; ++slot, ++s)
  {
    if (slot->addr == p)
    {
      oxu210_free (slot->addr, slot->size);
      slot->size = 0;
      break;
    }
  }
  mtx_unlock (&oxu_lock);
}

s5a_heap_allocator_t oxu210_heap_allocator =
{
  .alloc = oxu210_heap_alloc,
  .free  = oxu210_heap_free
};

#if OXU210_ALLOC_DEBUG
void oxu_allocator_debug (void)
{
  int bits_used = 0;
  int slots_used = 0;
  int i;
  mtx_lock (&oxu_lock);
  for (i = 0; i < OXU210_MEM_BLOCKS; ++i)
    if (oxu210_bit_test (i))
      ++bits_used;
  for (i = 0; i < OXU210_MALLOC_SLOTS; ++i)
    if (malloc_slot[i].size != 0)
      ++slots_used;
  printf ("OXU210 allocator: blocks=%d%% (%d/%d) slots=%d%% (%d/%d)\n",
          (bits_used * 100) / OXU210_MEM_BLOCKS, bits_used, OXU210_MEM_BLOCKS,
          (slots_used * 100) / OXU210_MALLOC_SLOTS, slots_used, OXU210_MALLOC_SLOTS);
#if 0
  printf ("Bits:");
  for (i = 0; i < OXU210_MEM_BLOCKS; ++i)
  {
    if ((i % 64) == 0)
      printf ("\n%4d", i);
    if ((i % 8) == 0)
      printf (" ");
    printf ("%c", oxu210_bit_test (i) ? 'x' : '.');
  }
  printf ("Bit map:");
  for (i = 0; i < OXU210_MEM_BIT_MAP_SIZE; ++i)
  {
    if ((i % 8) == 0)
      printf ("\n%4d", i);
    printf ("%c%08lx", ((i % 8) != 0) && ((i % 4) == 0) ? '-' : ' ', bit_map[i]);
  }
  printf ("\nend\n");
#endif
  mtx_unlock (&oxu_lock);
}
#endif
