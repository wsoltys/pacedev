#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#ifdef BUILD_INCLUDE_DEBUG
  #include <rtems.h>
  #include <rtems/libcsupport.h>
  #include <rtems/score/protectedheap.h>
  extern int malloc_info(
    Heap_Information_block *the_info
  );
#endif

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include "system.h"

#include "dbg_helper.h"
#include "os-support.h"

#include "veb.h"

#ifndef BUILD_MINIMAL
#include <stdio.h>
#endif

char *itoah (uint32_t data, int nibbles, char *buf)
{
  static uint8_t* ah = (uint8_t *)"0123456789ABCDEF";
  int i;
    
  data <<= ((8-nibbles)*4);
  
  char *p = buf;
  for (i=0; i<nibbles; i++, data<<=4)
    *(p++) = ah[data>>28];
  *p = 0;
  
  return (buf);
}

char *itoad (uint32_t data, char *buf)
{
  char *p = buf;
  uint32_t divisor = 1000000000;
  
  while (divisor > data)
    divisor /= 10;
  while (divisor)
  {
    uint32_t denom = data/divisor;
    *(p++) = '0'+denom;
    data -= denom * divisor;
    divisor /= 10;
  }
  if (p == buf)
    *(p++) = '0';

  *p = '\0';
  
  return (buf);
}

#ifdef BUILD_INCLUDE_DEBUG
void dump (uint8_t *data, int len)
{
  int i;
	  
  // dump the edid data ram
  for (i=0; i<len; i++)
  {
    if (i%16 == 0) printf (" ");
    printf ("%02X", data[i]);
    if (i%16 == 15) printf ("\n");
  }
  if (i%16 != 0) printf ("\n");
}
#endif

static volatile uint32_t dbg_port_shadow;

static void
dbg_port_write (uint32_t mask, uint32_t data)
{
  // FAARRKKK!!!!!
  #if 0
  os_interrupt_level cpu_sr;
  os_interrupt_disable (cpu_sr);
  dbg_port_shadow &= ~mask;
  dbg_port_shadow |= mask & data;
  IOWR_32DIRECT (DEBUG_PIO_BASE, 0, dbg_port_shadow);
  os_interrupt_enable (cpu_sr);
  #endif
}

void
dbg_port_set_mode (dbg_port_mode mode)
{
  switch (mode)
  {
    case dbg_port_normal:
    default:
      dbg_port_write (0xc0000000, 0x00000000);
      break;
    case dbg_port_uh_mon:
      dbg_port_write (0xc0000000, 0x40000000);
      break;
    case dbg_port_other:
      dbg_port_write (0xc0000000, 0xc0000000);
      break;
  }
}

void
dbg_port_leds_on (uint32_t mask)
{
  dbg_port_write (mask, DBG_PORT_ALL_LEDS);
}

void
dbg_port_leds_off (uint32_t mask)
{
  dbg_port_write (mask, 0);
}

#define USB_DEBUG 0
#if USB_DEBUG
extern int usb_debug;
extern int uhub_debug;
extern int usb_ctrl_debug;
extern int ehcidebug;
extern int bsd_mutex;
extern int bsd_cv;
extern int bsd_callout;
#endif

#define OXU210_ALLOC_DEBUG 1
#if OXU210_ALLOC_DEBUG
void oxu_allocator_debug (void);
#endif

#ifdef BUILD_INCLUDE_DEBUG
void dump_heap_info (void)
{
  Heap_Information_block info;

  malloc_info (&info);

  oxu_allocator_debug ();

  PRINT (0, "Heap Information:\n");
  PRINT (0, "  free=%9ld, %9ld, %9ld\n", 
          info.Free.number, info.Free.largest, info.Free.total);
  PRINT (0, "  used=%9ld, %9ld, %9ld\n", 
          info.Used.number, info.Used.largest, info.Used.total);
}
#endif

#define BUS_DEBUG 0
#if BUS_DEBUG
void print_devclass_list (void);
#endif

void
debug_shell (void)
{
#ifndef BUILD_MINIMAL
  char buf[80];
  setvbuf (stdin, NULL, _IONBF, 0);
  
  while (gets (buf))
  {
#ifdef BUILD_ENABLE_USB
#if USB_DEBUG
    if (strcmp (buf, "on") == 0)
    {
      usb_debug = uhub_debug = usb_ctrl_debug = ehcidebug = bsd_mutex = bsd_cv = bsd_callout = 50;
    }
    if (strcmp (buf, "off") == 0)
    {
      usb_debug = uhub_debug = usb_ctrl_debug = ehcidebug = bsd_mutex = bsd_cv = bsd_callout = 0;
    }
#endif
#if OXU210_ALLOC_DEBUG
    if (strcmp (buf, "oxu") == 0)
    {
      oxu_allocator_debug ();
    }
#endif
#if BUS_DEBUG
    if (strcmp (buf, "dc") == 0)
      print_devclass_list ();
#endif
#endif
  }
  
  printf ("stdin has EOF\n");
#endif
}
