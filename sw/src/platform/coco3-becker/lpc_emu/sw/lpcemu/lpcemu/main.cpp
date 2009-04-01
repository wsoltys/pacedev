#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"
#include "system.h"

static void timer_100Hz_interrupt(void *context, alt_u32 id)
{
  // acknowledge timer interrupt
  IOWR (TIMER_100HZ_BASE, 0, 0);

	// update uC/OS timer chain
	//OSTmrSignal ();
}

static void batterylow_interrupt(void *context, alt_u32 id)
{
#if 0
  // acknowledge interrupt (clear edge bit)
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(USER_POWERFAIL_BL_BASE, 0);

	unsigned char bl_n = IORD_ALTERA_AVALON_PIO_DATA (USER_POWERFAIL_BL_BASE);
	if ((bl_n & (1<<0)) == 0)
		bl_irq = 1;
#endif
}

#define SPI_CLK							(1<<0)
#define SPI_MISO						(1<<1)
#define SPI_MOSI						(1<<2)
#define SPI_SSn							(1<<3)

#define FPGACFG_CONFIGn			(1<<0)
#define FPGACFG_DCLK				(1<<1)
#define FPGACFG_DATA0				(1<<2)
#define FPGACFG_CONFDONE		(1<<3)
#define FPGACFG_STATUSn			(1<<4)

#ifdef LPC_SPI_0_NAME

#define aSSPRC0   (0<<2)
#define aSSPCR1   (1<<2)
#define aSSPDR    (2<<2)
#define aSSPSR    (3<<2)
#define aSSPCPSR  (4<<2)
#define aSSPIMSC  (5<<2)
#define aSSPRIS   (6<<2)
#define aSSPMIS   (7<<2)
#define aSSPICR   (8<<2)

// SSPCR1
#define BIT_SSE   (1<<1)

#define LPC_RD32(addr)            \
  IORD_32DIRECT (((1<<31)|LPC_SPI_0_BASE), (addr))
#define LPC_WR32(addr, data)      \
  IOWR_32DIRECT (((1<<31)|LPC_SPI_0_BASE), (addr), (data))

void spi_enable (bool enable)
{
  if (enable)
    LPC_WR32 (aSSPCR1, BIT_SSE);
  else
    LPC_WR32 (aSSPCR1, 0);
}
   
alt_u8 spi_send8 (alt_u8 data)
{
  LPC_WR32 (aSSPDR, (alt_u32)data);
  return (0);
}

#else

void spi_enable (bool enable)
{
}
   
alt_u8 spi_send8 (alt_u8 data)
{
  alt_u8 spi_in = 0;
	alt_u8 spi_out = 0;		// SSEL low
  
	for (int i=0; i<8; i++)
	{
		//setup data, clock hi
		spi_out |= SPI_CLK;
		spi_out &= ~SPI_MOSI;
		if (data & 0x80)
			spi_out |= SPI_MOSI;		
		IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, spi_out);
		usleep (1);

		// clock transition low
		spi_out &= ~SPI_CLK;
		IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, spi_out);
    
    // read data in
    spi_in <<= 1;
    alt_u8 spi_sts = IORD_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE);
    if (spi_sts & SPI_MISO)
      spi_in |= 1;
      
		usleep (1);

		data <<= 1;
	}
  return (spi_in);
}
#endif

int main (int argc, char* argv[], char* envp[])
{
  printf ("PACE LPC2103 Emulator v0.1\n");

	// set DDR for SPI, FPGACFG PIO blocks
	IOWR_ALTERA_AVALON_PIO_DIRECTION (PIO_SPI_BASE,
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT << 3) |
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT << 2) |
		(ALTERA_AVALON_PIO_DIRECTION_INPUT << 1 ) |
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT));

	IOWR_ALTERA_AVALON_PIO_DIRECTION (PIO_FPGACFG_BASE,
		(ALTERA_AVALON_PIO_DIRECTION_INPUT << 4) |
		(ALTERA_AVALON_PIO_DIRECTION_INPUT << 3) |
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT << 2) |
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT << 1) |
		(ALTERA_AVALON_PIO_DIRECTION_OUTPUT << 0));

	// initialise SSEL de-asserted
	IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, SPI_SSn);

#if 0
	// register and enable the 100Hz timer interrupt handler
  alt_irq_register(TIMER_100HZ_IRQ, 0, timer_100Hz_interrupt);
	alt_irq_enable (TIMER_100HZ_IRQ);
  // enable the interrupt bit in the timer control
  IOWR (TIMER_100HZ_BASE, 1, (1<<0));

	// register and enable the battery low interrupt handler
  alt_irq_register(USER_POWERFAIL_BL_IRQ, 0, batterylow_interrupt);
	alt_irq_enable (USER_POWERFAIL_BL_IRQ);
  // clear and then enable the interrupt bit in the PIO control
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(USER_POWERFAIL_BL_BASE, 0);
  IOWR_ALTERA_AVALON_PIO_IRQ_MASK (USER_POWERFAIL_BL_BASE, (1<<0));
#endif

  static char buf[1024];
  //sprintf (buf, "--- Welcome to PACE CoCo3+ (Built: %s %s) ---", __DATE__, __TIME__);
  sprintf (buf, "ABC");

  alt_u8 ps2_keys = 0;

  spi_enable (true);

  alt_u32 spi_sts;
  spi_sts = LPC_RD32 (aSSPSR); printf ("pre %08X\n", spi_sts); 
  usleep (1000000);
    
  while (1)
  {
    alt_u8 spi_in;
    int i;

  	// do a video transfer to the FPGA
  	// assert SSEL
  	IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, 0);
    spi_sts = LPC_RD32 (aSSPSR); printf ("%08X\n", spi_sts); 
  	spi_send8 (0x01);
    spi_sts = LPC_RD32 (aSSPSR); printf ("%08X\n", spi_sts); 
  	for (i=0; i<(int)strlen(buf); i++)
  		spi_send8 (buf[i]);
    //for (; i<1024; i++)
    //  spi_send8 (' ');
  	// de-assert SSEL
  	IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, SPI_SSn);
  
    // do a keyboard transfer from the FPGA
    IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, 0);
    // keybpard packet
    spi_send8 (0x02);
    spi_in = spi_send8 (0x00);    // dummy data to read
    IOWR_ALTERA_AVALON_PIO_DATA (PIO_SPI_BASE, SPI_SSn);

    if (spi_in != ps2_keys)
    {
      ps2_keys = spi_in;  
      printf ("ps2_keys = $%02X\n", ps2_keys);
    }
  
    usleep (1000000);
  }
   
}
