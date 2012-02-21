#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <system.h>

#define FIFO_STS_PIO_DIRC		(1<<2)
#define FIFO_STS_PIO_STEP		(1<<1)
#define FIFO_STS_PIO_FULL		(1<<0)

volatile alt_u32 fifo_sts_pio_irq = 0;

void fifo_sts_pio_isr (void *context)
{
  fifo_sts_pio_irq |= IORD_ALTERA_AVALON_PIO_EDGE_CAP(FIFO_STS_PIO_BASE);

  // clear all interrupts
  IOWR_ALTERA_AVALON_PIO_EDGE_CAP(FIFO_STS_PIO_BASE, fifo_sts_pio_irq);
}

// @0    22+   $4E
//       12+   $00
//       3     $A1
//       1     $FE
// @38   1     (TRK)
// @39   1     (SIDE)
// @40   1     (SECT)
// @41   1     (LEN)
// @42   2     (CRC)
// @44   22    $4E
//       8     $00
//       3     $A1
//       1     (IDAM) $FB
// @78   256   sector data
// @334  2     (CRC)
// @336  54    $4E
static unsigned char raw_sector_data[] =
{
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0xA1, 0xA1, 0xA1,
  0xFE,
  0x00,         // track
  0x00,         // side
  0x00,         // sector
  0x01,         // sector length
  0x00, 0x00,   // CRC
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0xA1, 0xA1, 0xA1,
  0xFB
              // data
              // CRC
              // $4E
};

extern unsigned char *dat;

int main (int argc, char *argv[])
{
	printf ("S5AR2_C0 Floppy Emulator v0.1!\n");

  // init capture on FIFO PIO
  IOWR_ALTERA_AVALON_PIO_IRQ_MASK(FIFO_STS_PIO_BASE, FIFO_STS_PIO_STEP);
  IOWR_ALTERA_AVALON_PIO_EDGE_CAP(FIFO_STS_PIO_BASE, 0xFF);
  alt_ic_isr_register(FIFO_STS_PIO_IRQ_INTERRUPT_CONTROLLER_ID, FIFO_STS_PIO_IRQ, fifo_sts_pio_isr, 0, 0);
  alt_ic_irq_enable (FIFO_STS_PIO_IRQ_INTERRUPT_CONTROLLER_ID, FIFO_STS_PIO_IRQ);

  alt_u32 track = IORD_ALTERA_AVALON_PIO_DATA (TRACK_PIO_BASE);
  alt_u32 sector = 0;
  unsigned offset = 0;
  alt_u8 byte = 0;
  alt_u16 crc = 0, crc2 = 0;
  alt_u8 *sector_data = 0; //dat;

	while (1)
	{
	  if (fifo_sts_pio_irq & FIFO_STS_PIO_STEP)
	  {
	    // re-read track
	    track = IORD_ALTERA_AVALON_PIO_DATA (TRACK_PIO_BASE);
      printf ("\nTRACK=%ld\n", track);

	    sector = 0;
	    offset = 0;
	    sector_data = 0; //&dat[256*(track*10+sector)];

	    fifo_sts_pio_irq = 0;
	  }

    // check we have room in the FIFO
	  alt_u8 fifo_sts = IORD_ALTERA_AVALON_PIO_DATA (FIFO_STS_PIO_BASE);
	  if (fifo_sts & FIFO_STS_PIO_FULL)
	  {
	    usleep (10);
	    continue;
	  }

    if (offset == 0)
      printf ("%ld", sector);

	  if (offset < 38)
	    byte = raw_sector_data[offset];
	  else if (offset == 38)
	    byte = track;
	  else if (offset == 39)
	    byte = 0x00; // side
	  else if (offset == 40)
	    byte = sector;
	  else if (offset == 41)
	    byte = 0x01; // length
	  else if (offset == 42)
	    byte = crc >> 8;
	  else if (offset == 43)
	    byte = crc & 0xFF;
	  else if (offset < 78)
      byte = raw_sector_data[offset];
	  else if (offset < 334)
	    byte = sector_data[offset-334];
	  else if (offset == 334)
	    byte = crc2 >> 8;
	  else if (offset == 335)
	    byte = crc2 & 0xFF;
	  else if (offset <= 335+22)
	    byte = 0x4E;

    if (offset++ == 335+22)
    {
      if (++sector == 10)
        sector = 0;
      offset = 0;
      sector_data = 0; //&dat[256*(track*10+sector)];
    }

	  IOWR_ALTERA_AVALON_PIO_DATA (FIFO_WR_IF_BASE, byte);
	}

  alt_ic_irq_disable (FIFO_STS_PIO_IRQ_INTERRUPT_CONTROLLER_ID, FIFO_STS_PIO_IRQ);
  alt_ic_isr_register(FIFO_STS_PIO_IRQ_INTERRUPT_CONTROLLER_ID, FIFO_STS_PIO_IRQ, NULL, 0, 0);
}
