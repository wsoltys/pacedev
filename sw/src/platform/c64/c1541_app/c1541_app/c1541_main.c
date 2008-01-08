#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include <altera_avalon_timer_regs.h>
#include <altera_avalon_pio_regs.h>
#include <alt_types.h>
#include <sys/alt_alarm.h>
#include <sys/alt_irq.h>
#include <unistd.h>

#include <system.h>

#include "c1541_gpio.h"
#include "ide.h"

//#define BUILD_READ_FROM_MEMORY
#ifndef BUILD_READ_FROM_MEMORY
  #define BUILD_READ_FROM_CF
  //#define OCIDE_PIO_MODE
  #define DISK_NUMBER     0           // Lode Runner
  //#define DISK_NUMBER     1           // Wizball
  //#define DISK_NUMBER     2           // Impossible Mission
  //#define DISK_NUMBER     3           // Donkey Kong
  //#define DISK_NUMBER     4           // Xevious
#endif

#ifdef BUILD_READ_FROM_MEMORY
  #define _IS_INCLUDED_
  #ifdef BUILD_G64
    #include "g64_data.c"
  #else
    #define BUILD_D64
    #include "d64_data.c"
  #endif
  #define HEAD_DATA_LENGTH (1+2+2+1+256/4+4)*5
#endif

#ifdef BUILD_READ_FROM_CF
  alt_u8 *d64_data;
  #define HEAD_DATA_LENGTH 8192
  static int block = 0;
#endif

typedef struct
{
	int motor, frequency;

	int clock;
	double track;

	struct {
		alt_u8 __attribute__((aligned(4))) data[HEAD_DATA_LENGTH];
		int sync;
		int ready;
		int ffcount;
	} head;

	struct {
		int pos; /* position  in sector */
		int sector;
		alt_u8 *data;
	} d64;

} CBM_Drive_Emu;
static CBM_Drive_Emu vc1541_static = { 0 }, *vc1541 = &vc1541_static;

#ifdef BUILD_READ_FROM_MEMORY

static int bin_2_gcr[] =
{
	0xa, 0xb, 0x12, 0x13, 0xe, 0xf, 0x16, 0x17,
	9, 0x19, 0x1a, 0x1b, 0xd, 0x1d, 0x1e, 0x15
};

static void gcr_double_2_gcr(alt_u8 a, alt_u8 b, alt_u8 c, alt_u8 d, alt_u8 *dest)
{
	alt_u8 gcr[8];
	gcr[0]=bin_2_gcr[a>>4];
	gcr[1]=bin_2_gcr[a&0xf];
	gcr[2]=bin_2_gcr[b>>4];
	gcr[3]=bin_2_gcr[b&0xf];
	gcr[4]=bin_2_gcr[c>>4];
	gcr[5]=bin_2_gcr[c&0xf];
	gcr[6]=bin_2_gcr[d>>4];
	gcr[7]=bin_2_gcr[d&0xf];
	dest[0]=(gcr[0]<<3)|(gcr[1]>>2);
	dest[1]=(gcr[1]<<6)|(gcr[2]<<1)|(gcr[3]>>4);
	dest[2]=(gcr[3]<<4)|(gcr[4]>>1);
	dest[3]=(gcr[4]<<7)|(gcr[5]<<2)|(gcr[6]>>3);
	dest[4]=(gcr[6]<<5)|gcr[7];
}

static struct {
	int count;
	int data[4];
} gcr_helper;

static void vc1541_sector_start(void)
{
	gcr_helper.count=0;
}

static void vc1541_sector_data(alt_u8 data, int *pos)
{
	gcr_helper.data[gcr_helper.count++]=data;
	if (gcr_helper.count==4) {
		gcr_double_2_gcr(gcr_helper.data[0], gcr_helper.data[1],
						 gcr_helper.data[2], gcr_helper.data[3],
						 vc1541->head.data+*pos);
		*pos=*pos+5;
		gcr_helper.count=0;
	}
}

static void vc1541_sector_end(int *pos)
{
	//assert(gcr_helper.count==0);
}

#endif

#define D64_MAX_TRACKS 35
int d64_sectors_per_track[] =
{
	21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
	19, 19, 19, 19, 19, 19, 19,
	18, 18, 18, 18, 18, 18,
	17, 17, 17, 17, 17
};
static int d64_offset[D64_MAX_TRACKS+1];		   /* offset of begin of track in d64 file */
void cbm_drive_open_helper (void)
{
	int i;

	d64_offset[0] = 0;
	for (i = 1; i <= 35; i++)
		d64_offset[i] = d64_offset[i - 1] + d64_sectors_per_track[i - 1] * 256;
}
int d64_tracksector2offset (int track, int sector)
{
	return d64_offset[track - 1] + sector * 256;
}
#define D64_TRACK_ID1   (d64_tracksector2offset(18,0)+162)
#define D64_TRACK_ID2   (d64_tracksector2offset(18,0)+163)

#ifdef BUILD_READ_FROM_MEMORY
static void vc1541_sector_to_gcr(int track, int sector)
{
	int i=0, j, offset, chksum=0;

  //printf ("sector_to_gcr(%d,%d)\n", track, sector);

	if (vc1541->d64.data==NULL) return;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541_sector_start();

	vc1541_sector_data(8, &i);
	chksum= sector^track
		^vc1541->d64.data[D64_TRACK_ID1]^vc1541->d64.data[D64_TRACK_ID2];
	vc1541_sector_data(chksum, &i);
	vc1541_sector_data(sector, &i);
	vc1541_sector_data(track, &i);
	vc1541_sector_data(vc1541->d64.data[D64_TRACK_ID1], &i);
	vc1541_sector_data(vc1541->d64.data[D64_TRACK_ID2], &i);
	vc1541_sector_data(0xf, &i);
	vc1541_sector_data(0xf, &i);
	vc1541_sector_end(&i);

	/* 5 - 10 gcr bytes cap */
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541_sector_data(0x7, &i);

	chksum=0;
	for (offset=d64_tracksector2offset(track,sector), j=0; j<256; j++) {
		chksum^=vc1541->d64.data[offset];
		vc1541_sector_data(vc1541->d64.data[offset++], &i);
	}
	vc1541_sector_data(chksum, &i);
	vc1541_sector_data(0, &i); /* padding up */
	vc1541_sector_data(0, &i);
	vc1541_sector_end(&i);
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
}
#endif

static alt_u8 gpi, gpo;

void ocide_set_cf_non (alt_u8 flag)
{
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_MECH_IN_BASE, flag ? NON_CF : 0);
}

alt_u8 ocide_get_cf_cd (void)
{
  return ((alt_u8)(IORD_ALTERA_AVALON_PIO_DATA (PIO_MECH_OUT_BASE) & CD_CF));
}

void dump_gpi (alt_u8 gpi)
{
  printf ("MODE=%01d,", (int)(gpi & C1541_MODE ? 1 : 0));
  printf ("STP_OUT=%01d,", (int)(gpi & C1541_STP_OUT ? 1 : 0));
  printf ("STP_IN=%01d,", (int)(gpi & C1541_STP_IN ? 1 : 0));
  printf ("STP=%01d,", (int)C1541_STP_VAL(gpi));
  printf ("MTR=%01d,", (int)(gpi & C1541_MTR ? 1 : 0));
  printf ("FREQ=%01d", (int)C1541_FREQ_VAL(gpi));
  printf ("\n");
}

void dump_gpo (alt_u8 gpo)
{
  printf ("SYNC_n=%01d,", (int)(gpo & C1541_SYNC_n ? 1 : 0));
  printf ("BYTE_n=%01d,", (int)(gpo & C1541_BYTE_n ? 1 : 0));
  printf ("WPS_n=%01d,", (int)(gpo & C1541_WPS_n ? 1 : 0));
  printf ("TR00_SENSE_n=%01d", (int)(gpo & C1541_TR00_SENSE_n ? 1 : 0));
  printf ("\n");
}

void dump (alt_u8 *buffer, int length)
{
  unsigned char ascii[17];
  ascii[16] = '\0';

  int i;
  for (i=0; i<length; i++)
  {
    if (i%16 == 0) printf ("%04X: ", i);
    printf ("%02X ", buffer[i]);
    ascii[i%16] = (isprint(buffer[i]) ? buffer[i] : '.');
    if (i%16 == 15) printf ("| %16.16s\n", ascii);
  }
}

#define TRACK_SIZE(t) (d64_sectors_per_track[(int)t-1]*(1+2+2+1+256/4+4)*5)

int main()
{
  printf("C1541 NIOS Emulation v0.3\n");
  printf("- FIFO, H/W STP, OCIDE(DMA)\n");

  alt_u8 old_gpi;

  // init drive signals and reset
  gpo = C1541_RESET | C1541_WPS_n;
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_GPO_BASE, gpo);
  usleep (1000);
  gpo &= ~C1541_RESET;
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_GPO_BASE, gpo);

  #ifdef BUILD_READ_FROM_CF
    d64_data = (alt_u8 *)vc1541->head.data;
  #endif

  cbm_drive_open_helper ();
  vc1541->d64.data = d64_data;
	vc1541->track = 1.0;
	vc1541->d64.pos = 0;

  #ifdef BUILD_READ_FROM_MEMORY
    // initialise 1st sector
  	vc1541_sector_to_gcr ((int)vc1541->track, vc1541->d64.sector);
  #endif

  #ifdef BUILD_READ_FROM_CF
    // initialise the OCIDE controller
    if (!init_cf (250000))
      exit (0);
    usleep (4000);
    if (init_controller_ex (0x0092, 0, 4, 2) < 0)
      exit (0);
    usleep (4000);
    set_device_dma_mode (0, 2);
    usleep (4000);

    //identify_device (1);

    // read the 1st block into memory
    block = DISK_NUMBER*2048 + 32;
    vc1541->d64.sector = 0;
    #ifdef OCIDE_PIO_MODE
      pio_read_512 (ATA_CMD_READ_SECTORS, block+vc1541->d64.sector, (alt_u16 *)(vc1541->d64.data));
    #else
      dma_read_512 (block+vc1541->d64.sector, (char *)(vc1541->d64.data));
    #endif
  #endif

  old_gpi = IORD_ALTERA_AVALON_PIO_DATA (PIO_GPI_BASE);
  dump_gpi(old_gpi);

  while (1)
  {
    // read stepper inputs
    gpi = IORD_ALTERA_AVALON_PIO_DATA (PIO_GPI_BASE);

    if ((gpi & C1541_STP_IN) != (old_gpi & C1541_STP_IN))
    {
      //dump_gpi (gpi);
      if (vc1541->track < 35.0)
      {
        vc1541->track += 0.5;
        vc1541->d64.sector = 0; // or -1?
        vc1541->d64.pos = 511;
        block += 16;
        printf ("\nt=%.1lf\n", vc1541->track);
      }
    }
    if ((gpi & C1541_STP_OUT) != (old_gpi & C1541_STP_OUT))
    {
      //dump_gpi (gpi);
      if (vc1541->track > 1.0)
      {
        vc1541->track -= 0.5;
        vc1541->d64.sector = 0; // or -1?
        vc1541->d64.pos = 511;
        block -= 16;
        printf ("\nt=%.1lf\n", vc1541->track);
      }
    }

    old_gpi = gpi;

    // read fifo inputs
    alt_u16 fifo_gpi = IORD_ALTERA_AVALON_PIO_DATA (PIO_FIFO_BASE);
    if ((fifo_gpi & FIFO_WRFULL) == 0)
    {    
      IOWR_ALTERA_AVALON_PIO_DATA (PIO_DO_BASE, vc1541->head.data[vc1541->d64.pos]);
      IOWR_ALTERA_AVALON_PIO_DATA (PIO_FIFO_BASE, FIFO_WRREQ);
      IOWR_ALTERA_AVALON_PIO_DATA (PIO_FIFO_BASE, 0);

      // get next byte for FIFO

      #ifdef BUILD_READ_FROM_MEMORY
      	if(++(vc1541->d64.pos) >= sizeof(vc1541->head.data))
        {
      		if (++(vc1541->d64.sector) >= d64_sectors_per_track[(int)vc1541->track-1])
          {
      			vc1541->d64.sector = 0;
      		}
    		  vc1541_sector_to_gcr ((int)vc1541->track, vc1541->d64.sector);
      		vc1541->d64.pos = 0;
      	}
      #endif

      #ifdef BUILD_READ_FROM_CF
        (vc1541->d64.pos)++;
        if (vc1541->d64.pos > 511)
        {
          (vc1541->d64.sector)++;
          vc1541->d64.pos = 0;
          printf ("r=%d,", block+vc1541->d64.sector);
          #ifdef OCIDE_PIO_MODE
            pio_read_512 (ATA_CMD_READ_SECTORS, block+vc1541->d64.sector, (alt_u16 *)(vc1541->d64.data));
          #else
            dma_read_512 (block+vc1541->d64.sector, (char *)(vc1541->d64.data));
          #endif
        }
        else 
        if ((vc1541->d64.sector << 9) + vc1541->d64.pos >= TRACK_SIZE(vc1541->track))
        {
          vc1541->d64.sector = 0;
          vc1541->d64.pos = 0;
          printf ("end\nr=%d,", block+vc1541->d64.sector);
          #ifdef OCIDE_PIO_MODE
            pio_read_512 (ATA_CMD_READ_SECTORS, block+vc1541->d64.sector, (alt_u16 *)(vc1541->d64.data));
          #else
            dma_read_512 (block+vc1541->d64.sector, (char *)(vc1541->d64.data));
          #endif
        }
      #endif
    }
  }

  return 0;
}

