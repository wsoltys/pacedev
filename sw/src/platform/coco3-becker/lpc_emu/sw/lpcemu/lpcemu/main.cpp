#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"
#include "system.h"

#include "ide.h"
extern "C"
{
#include "integer.h"
#include "ff.h"
#include "diskio.h"
};

#define LPC_RD32(addr)            \
  IORD_32DIRECT (((1<<31)|LPC_SPI_0_BASE), (addr))
#define LPC_WR32(addr, data)      \
  IOWR_32DIRECT (((1<<31)|LPC_SPI_0_BASE), (addr), (data))

#if 0
// bit-bash SPI - not used any more
#define SPI_CLK							    (1<<0)
#define SPI_MISO						    (1<<1)
#define SPI_MOSI						    (1<<2)
#define SPI_SSn							    (1<<3)
#endif

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
// SSPSR
#define BIT_BSY   (1<<4)
// SSPRIS
#define BIT_TXRIS (1<<3)

// OSD packet types
#define PKT_OSD_CTRL            0x01
#define PKT_OSD_VIDEO           0x02
#define PKT_PS2_KEYS            0x03

// OSD control word to the FPGA
#define OSD_CTRL_OSD_ENABLE     (1<<15)
#define OSD_CTRL_BTN_RESET      (1<<11)
#define OSD_CTRL_BTN_PAUSE      (1<<10)
#define OSD_CTRL_BTN_MPISTS     (1<<9)
#define OSD_CTRL_BTN_EASTEREGG  (1<<8)
#define OSD_CTRL_SW_BOINK       (1<<7)
#define OSD_CTRL_SW_DSKSPD      (1<<6)
#define OSD_CTRL_SW_JOYSTK      (1<<5)
#define OSD_CTRL_SW_CARTINT     (1<<4)
#define OSD_CTRL_SW_MPI1        (1<<3)
#define OSD_CTRL_SW_MPI0        (1<<2)
#define OSD_CTRL_SW_CPUSPD1     (1<<1)
#define OSD_CTRL_SW_CPUSPD0     (1<<0)

#define OSD_CTRL_MSK_MPI        (OSD_CTRL_SW_MPI1|OSD_CTRL_SW_MPI0)
#define OSD_CTRL_MPI_SLOT1      (0)
#define OSD_CTRL_MPI_SLOT2      (OSD_CTRL_SW_MPI0)
#define OSD_CTRL_MPI_SLOT3      (OSD_CTRL_SW_MPI1)
#define OSD_CTRL_MPI_SLOT4      (OSD_CTRL_SW_MPI1|OSD_CTRL_SW_MPI0)

#define OSD_CTRL_MSK_CPUSPD     (OSD_CTRL_SW_CPUSPD1|OSD_CTRL_SW_CPUSPD0)
#define OSD_CTRL_CPUSPD_1M78    (0)
#define OSD_CTRL_CPUSPD_4M17    (OSD_CTRL_SW_CPUSPD0)
#define OSD_CTRL_CPUSPD_12M5    (OSD_CTRL_SW_CPUSPD1)
#define OSD_CTRL_CPUSPD_25M0    (OSD_CTRL_SW_CPUSPD1|OSD_CTRL_SW_CPUSPD0)

// OSD keys from the FPGA
#define OSD_KEY_F11             (1<<7)
#define OSD_KEY_F3              (1<<6)
#define OSD_KEY_RIGHT           (1<<5)
#define OSD_KEY_LEFT            (1<<4)
#define OSD_KEY_DOWN            (1<<3)
#define OSD_KEY_UP              (1<<2)
#define OSD_KEY_ENTER           (1<<1)
#define OSD_KEY_ESC             (1<<0)

#define OSD_NAV_KEY_MASK        (OSD_KEY_RIGHT|OSD_KEY_LEFT|OSD_KEY_DOWN|OSD_KEY_UP)

#define RBF_FILENAME            "COCO3.RBF"
//#define RBF_FILENAME            "INVADERS.RBF"

static unsigned char vram[1024];

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

extern "C" void ocide_set_cf_non (alt_u8 flag)
{
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_OUT_BASE, (flag & (1<<0)));
}

extern "C" alt_u8 ocide_get_cf_cd (void)
{
  return (IORD_ALTERA_AVALON_PIO_DATA (PIO_IN_BASE) & (1<<0));
}

void spi_enable (bool enable)
{
  if (enable)
    LPC_WR32 (aSSPCR1, BIT_SSE);
  else
    LPC_WR32 (aSSPCR1, 0);
}
   
#define spi_send8(x)    LPC_WR32 (aSSPDR, (alt_u32)(x))
#define spi_rd8(x)      (alt_u8)LPC_RD32 (aSSPDR)

void spi_wait_not_busy (void)
{
  alt_u8 spi_sts;
  
  // wait for not BUSY, so SSEL is de-asserted
  do
  {
    spi_sts = LPC_RD32 (aSSPSR);
    
  } while ((spi_sts & BIT_BSY) != 0);
}    

unsigned char *v = vram;

void vp (char *str, bool use_inverse=true)
{
  static unsigned char inverse = 0x00;
  
  for (; *str; str++)
  {
    if (*str == '_')
    {
      if (use_inverse)
        inverse ^= 0x80;
    }
    else
      *(v++) = inverse | *str;
  }
}

void vpat (int x, int y, char *str, bool use_inverse=true)
{
  v = vram + (y << 6) + x;
  vp (str, use_inverse);
}

void vp2 (int sel, char *zero, char *one)
{
  vp (zero, sel==0); 
  vp (" "); 
  vp (one, sel==1); 
}

void vp4 (int sel, char *zero, char *one, char *two, char *three)
{
  vp2 (sel, zero, one);
  vp (" ");
  vp2 (sel^(1<<1), two, three); 
}

void show_menu (unsigned short osd_ctrl, int sel=0)
{
  int l = 3;
  int x = 16;
  vpat (x, l++, "   _Boink Speed_ : ", sel==0);
  vp2 ((osd_ctrl & OSD_CTRL_SW_BOINK) >> 7, "_OFF_", "_ON_");
  vpat (x, l++, "    _Disk Speed_ : ", sel==1);
  vp2 ((osd_ctrl & OSD_CTRL_SW_DSKSPD) >> 6, "_OFF_", "_ON_");
  vpat (x, l++, "_Swap Joysticks_ : ", sel==2);
  vp2 ((osd_ctrl & OSD_CTRL_SW_JOYSTK) >> 5, "_OFF_", "_ON_");
  vpat (x, l++, "      _Cart INT_ : ", sel==3);
  vp2 ((osd_ctrl & OSD_CTRL_SW_CARTINT) >> 4, "_OFF_", "_ON_");
  vpat (x, l++, "      _MPI Slot_ : ", sel==4);
  vp4 ((osd_ctrl & OSD_CTRL_MSK_MPI) >> 2, "_1_", "_2_", "_3_", "_4_");
  vpat (x, l++, "     _CPU Speed_ : ", sel==5);
  vp4 ((osd_ctrl & OSD_CTRL_MSK_CPUSPD) >> 0, "_1.78_", "_4.17_", "_12.5_", "_25.0_");
}

void handle_menu_sel (alt_u16 &osd_ctrl, int &sel, alt_u8 key)
{
  int mask[] = 
  {
    OSD_CTRL_SW_BOINK, OSD_CTRL_SW_DSKSPD, OSD_CTRL_SW_JOYSTK, OSD_CTRL_SW_CARTINT,
    OSD_CTRL_MSK_MPI, OSD_CTRL_MSK_CPUSPD
  };
  int shift[] = { 7, 6, 5, 4, 2, 0 };

  int entry = (osd_ctrl & mask[sel]) >> shift[sel];
  int n = (mask[sel] >> shift[sel]);

  if (key & OSD_KEY_UP)
    if (sel != 0)
      sel--;
      
  if (key & OSD_KEY_DOWN)
    if (sel < 5)
      sel++;

  if ((key & (OSD_KEY_LEFT|OSD_KEY_RIGHT)) == 0)
    return;
        
  if (key & OSD_KEY_LEFT)
    if (entry == 0)
      return;
    else
      entry--;
  else 
  if (key & OSD_KEY_RIGHT)
    if (entry == n)
      return;
    else
      entry++;

  osd_ctrl &= ~mask[sel];
  osd_ctrl |= (entry << shift[sel]); 
    
  return;
}

#if 0
  #include "../inc/rbfdat.c"
#endif

#define FPGACFG_CONFIGn         (1<<0)
#define FPGACFG_DCLK            (1<<1)
#define FPGACFG_DATA0           (1<<2)
#define FPGACFG_CONFDONE        (1<<3)
#define FPGACFG_STATUSn         (1<<4)

static void ConfigureFPGA (alt_u8 *pRbfdat, alt_u32 bytes)
{
  alt_u8 data = 0;
  
  // pull nCONFIG  low for tCFG=2us min.
  data &= ~FPGACFG_CONFIGn;
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE, data);
  usleep (2);
  data |= FPGACFG_CONFIGn;
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE, data);
  usleep (2);

  // send the bitstream
  for (unsigned i=0; i<bytes; i++, pRbfdat++)
  {
    for (int b=0; b<8; b++)
    {
      // DCLK low, data setup
      data &= ~(FPGACFG_DATA0|FPGACFG_DCLK);
      if (*pRbfdat & (1<<b))
        data |= FPGACFG_DATA0;
      IOWR_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE, data);
      //usleep (1);
      // DCLK high, clock in data
      data |= FPGACFG_DCLK;
      IOWR_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE, data);
      //usleep (1);
    }
  }
  // DCLK low for the final time
  data &= ~FPGACFG_DCLK;
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE, data);

  // check CONFDONE
  data = IORD_ALTERA_AVALON_PIO_DATA (PIO_FPGACFG_BASE);

  printf ("CONFDONE|STATUSn = %02X\n", data & (FPGACFG_CONFDONE|FPGACFG_STATUSn));
}

FRESULT load_file (char *fname, alt_u8 *mem)
{
  FIL       fil;
  FRESULT   fresult;
  WORD      BytesRead;
  
  printf ("Loading \"%s\"...\n", fname);

  if ((fresult = f_open(&fil, fname, FA_READ|FA_OPEN_EXISTING)) != FR_OK)
  {
    printf ("f_open(%s) failed with %d\n", fname, fresult);
    return (fresult);
  }

  while (1)
  {
    BYTE buffer[1024];
    int i;

    fresult = f_read (&fil, (void *)buffer, 1024, &BytesRead);
    if (fresult != FR_OK)
      return (fresult);
    if (BytesRead == 0)
      break;
    for (i=0; i<BytesRead; i++)
      *(mem++) = buffer[i];
  }

  printf ("Done!\n");
  
  return (f_close (&fil));
}

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

#if 0
  // configure FPGA
  printf ("Programming FPGA...\n");
  ConfigureFPGA (rbfdat, RBFDAT_BYTES);
  printf ("Done!\n");
#endif
  
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

#if 0
  // test CF
  if (!init_cf (250000))
  {
    printf ("** CF not detected\n");
    while (1);
  }
  printf (" Compact Flash Media Detected!\n");
  usleep (4000);

  // enable PIO, IORDY, ensure ping-pong is ON
  if (init_controller_ex (0x0092, 0, 0, 0) < 0)
  {
    printf ("** init_controller_ex() failed!\n" );
    while (1);
  }
  usleep (4000);

  identify_device (1);
  usleep (4000);
  
#endif

  // file-system code
  while (1)
  {
    static FATFS  fatfs;
    DIR           dir;
    FILINFO       finfo;
    FRESULT       fresult;

    // enable FatFs module
    if (f_mount (0, &fatfs) != FR_OK)
    {
      printf ("f_mount(0) failed!\n");
      break;
    }

#if 0
    if ((fresult = f_opendir (&dir, "/")) != FR_OK)
    {
      printf ("f_opendir() returned %d\n", fresult);
      break;
    }

    while (f_readdir (&dir, &finfo) == FR_OK && finfo.fname[0])
    {
      printf ("%s, %ld\n", finfo.fname, finfo.fsize);
    }
#endif
    if (f_stat (RBF_FILENAME, &finfo) != FR_OK)
      break;
    printf ("%s, %ld\n", finfo.fname, finfo.fsize);

    alt_u8 *rbfdat = (alt_u8 *)malloc (finfo.fsize);
    load_file (RBF_FILENAME, rbfdat);

    printf ("Programming FPGA...\n");
    ConfigureFPGA (rbfdat, finfo.fsize);
    printf ("Done!\n");

    break;
  }

  sprintf ((char *)vram, "   --- PACE CoCo3+ OSD Menu (Built: %s %s) ---", __DATE__, __TIME__);
  int l = strlen((char *)vram);
  memset (vram+l, ' ', 1024-l);

  alt_u16 osd_ctrl = OSD_CTRL_MPI_SLOT4 | OSD_CTRL_CPUSPD_1M78;
  alt_u16 osd_ctrl_t = osd_ctrl;
  alt_u8 ps2_keys = 0;
  alt_u16 osd_ctrl_i = 0;
    

  int menu_sel = 0;
  
  show_menu (osd_ctrl, menu_sel);
  
  spi_enable (true);
  while (1)
  {
    alt_u16 spi_in;
    int i;

    // do a control packet transfer
    spi_send8 (PKT_OSD_CTRL);
    spi_send8 (osd_ctrl>>8);
    spi_send8 (osd_ctrl&0xFF);
    spi_wait_not_busy ();

    spi_rd8 ();
    spi_in = spi_rd8 ();
    spi_in = (spi_in << 8) | spi_rd8 ();
    #if 0
      if (spi_in != osd_ctrl_i)
        printf ("osd_ctrl_i = $%04X\n", spi_in);
    #endif
    osd_ctrl_i = spi_in;
    
  	// do a video transfer to the FPGA
  	spi_send8 (PKT_OSD_VIDEO);
    for (i=0; i<1024;)
    {
      if (LPC_RD32 (aSSPRIS) & BIT_TXRIS)  // half empty
        for (int j=0; j<8; j++)
          spi_send8 (vram[i++]);
    }
    spi_wait_not_busy ();

    // flush the rx fifo
    for (i=0; i<16; i++)
      spi_rd8 ();

    // do a keyboard transfer from the FPGA
    // keyboard packet
    spi_send8 (PKT_PS2_KEYS);
    spi_send8 (0x00);         // dummy data for read
    spi_wait_not_busy ();
    
    // keys are in the 2nd byte in the FIFO
    spi_in = spi_rd8 ();
    spi_in = spi_rd8 ();

    // toggle OSD_ENABLE on F11 keypress
    if ((spi_in & OSD_KEY_F11) != 0 && (ps2_keys & OSD_KEY_F11) == 0)
    {
      osd_ctrl ^= OSD_CTRL_OSD_ENABLE;
      // latch a temp copy to play with 
      osd_ctrl_t = osd_ctrl;
    }

    // handle menu navigation, settings    
    alt_u8 press = (spi_in & ~ps2_keys) & OSD_NAV_KEY_MASK; 
    if (press != 0)
      handle_menu_sel (osd_ctrl_t, menu_sel, press);

#if 0
    // on ENTER, when OSD enabled, save changes
    if ((spi_in & OSD_KEY_ENTER) != 0 && (ps2_keys & OSD_KEY_ENTER) == 0)
      if (osd_ctrl & OSD_CTRL_OSD_ENABLE)
#endif      
        osd_ctrl = osd_ctrl_t;
    
    // handle reset button on F3 keypress
    osd_ctrl &= ~(OSD_CTRL_BTN_RESET);
    if ((osd_ctrl & OSD_CTRL_OSD_ENABLE) && (spi_in & OSD_KEY_F3))
    {
      // also disable OSD
      //osd_ctrl &= ~OSD_CTRL_OSD_ENABLE;
      osd_ctrl |= OSD_CTRL_BTN_RESET;
    }

    if (spi_in != ps2_keys)
    {
      //printf ("ps2_keys = $%02X\n", ps2_keys);
      show_menu (osd_ctrl_t, menu_sel);
    }

    ps2_keys = spi_in;  
  }
   
}
