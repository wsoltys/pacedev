#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include "system.h"

#define SB16_RD32(addr)            \
  IORD_32DIRECT (((1<<31)|SB16_AVALON_WRAPPER_0_BASE), (addr))
#define SB16_WR32(addr, data)      \
  IOWR_32DIRECT (((1<<31)|SB16_AVALON_WRAPPER_0_BASE), (addr), (data))

#define REG(x)  ((x)<<2)

inline void wait_dsp_rd (void)
{
  alt_u32 dat;
  do
  {
    dat = SB16_RD32 (REG(0x0E));
  } while ((dat & (1<<7)) == 0);
}

inline void wait_dsp_wr (void)
{
  alt_u32 dat;
  do
  {
    dat = SB16_RD32 (REG(0x0C));
  } while ((dat & (1<<7)) != 0);
}

#define NSIN (int)(2*3.141592564/0.1+0.5)

static alt_u8 sinA[NSIN];
static int nSin;

#include "../../tools/hounds.c"

static void timer_8kHz_interrupt(void *context, alt_u32 id)
{
  // acknowledge timer interrupt
  IOWR (TIMER_8KHZ_BASE, 0, 0);

  static int i = 0;
  static unsigned char *p = dat;
  
  wait_dsp_wr ();
  SB16_WR32 (REG(0x0C), 0x10);
  wait_dsp_wr ();
  SB16_WR32 (REG(0x0C), dat[i]);
  if (++i == DAT_BYTES)
    i = 0;
}

int main (int argc, char* argv[], char* envp[])
{
  alt_u32 dat;
  printf ("PACE Sound Blaster Testbench v0.1\n");
  
  SB16_WR32 (REG(0x06), 1);
  usleep (10000);
  SB16_WR32 (REG(0x06), 0);
  usleep (10000);
  wait_dsp_rd ();
  dat = SB16_RD32 (REG(0x0A));
  printf ("DSP Reset response = $%02X\n", dat&0xFF);

  wait_dsp_wr ();
  SB16_WR32 (REG(0x0C), 0xE1);
  wait_dsp_rd ();
  alt_u8 major_ver = SB16_RD32 (REG(0x0A)) & 0xFF;
  wait_dsp_rd ();
  alt_u8 minor_ver = SB16_RD32 (REG(0x0A)) & 0xFF;
  printf ("DSP Version = %02d.%02d\n", major_ver, minor_ver);

  printf ("Sample size = %d\n", DAT_BYTES);
  
  // pre-calculate sin table
  for (double a=0.0; a<2*3.141592654; a+=0.1)
    sinA[nSin++] = (unsigned int)(128.0 + sin(a)*90.0);

  // register and enable the 100Hz timer interrupt handler
  alt_irq_register(TIMER_8KHZ_IRQ, 0, timer_8kHz_interrupt);
  alt_irq_enable (TIMER_8KHZ_IRQ);
  // enable the interrupt bit in the timer control
  IOWR (TIMER_8KHZ_BASE, 1, (1<<0));

  while (1)
    usleep (1000000);
}
