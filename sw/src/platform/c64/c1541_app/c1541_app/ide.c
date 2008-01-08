#include "target.h"

#ifdef USE_OCIDEC

#include <stdio.h>
#include <unistd.h>

#include <altera_avalon_pio_regs.h>
//#include <altera_avalon_performance_counter.h>
#include <sys/alt_irq.h>
#include <sys/alt_dma.h>
#include <sys/alt_cache.h>
#include <alt_types.h>
#include "system.h"

//#include "ram_loader.h"

//#define HAS_PERF

#define EOL "\n"
#define OK 0
#define ERROR -1

#include "ide.h"

//#define VERBOSE
#ifdef VERBOSE
  #define MORE_VERBOSE
#endif

#ifdef __ALTERA_AVALON_DMA
  #define SUPPORT_DMA
#endif

#ifndef DISPLAY
  #define DISPLAY printf
#endif

// each rx_chan_prepare has a limit of 262143 chars (256KB-1)
// - so dma requests have to be chained in requests smaller than 256KB
// DMA_BLOCKS_PER_CHAIN is the number of blocks in a single rx_chan_prepare
// DMA_CHAINS is the number of posted rx_chan_prepare requests per ATA DMA request
//  - max is 3!!!
// DMA_CHAIN_SIZE then is the number of bytes per rx_chan_prepare_request
// DMA_BLOCKS then is the number of blocks requested from the ATA device / DMA command
// DMA_CHUNK_SIZE then is the number of bytes in DMA_BLOCKS

#define DMA_BLOCKS_PER_CHAIN      (256)
// this *MUST* be set to 1 to work for the moment
#define DMA_CHAINS                (1)

#define DMA_CHAIN_SIZE            (DMA_BLOCKS_PER_CHAIN<<9)
#define DMA_BLOCKS                (DMA_CHAINS*DMA_BLOCKS_PER_CHAIN)
#define DMA_CHUNK_SIZE            (DMA_BLOCKS<<9)
#define DMA_CHUNKS(n)             ((n+DMA_CHUNK_SIZE-1)/(DMA_CHUNK_SIZE))

// ATA core registers
#define CTRL                      (0x00<<2)
#define STAT                      (0x01<<2)
#define PCTR                      (0x02<<2)
#define PFTR0                     (0x03<<2)
#define PFTR1                     (0x04<<2)
#define DTR0                      (0x05<<2)
#define DTR1                      (0x06<<2)
#define DTxDB                     (0x0F<<2)
#define DRxDB                     (DTxDB)

#define DMA_DIR_RW                (1<<13)
#define DMA_ENA                   (1<<15)
#define BELEC1                    (1<<9)
#define BELEC0                    (1<<8)

// ATA device registers
#define ATA_REG_DATA              (0x10<<2)           // 40
#define ATA_REG_ERROR             (0x11<<2)           // 44
#define ATA_REG_FEATURE           (ATA_REG_ERROR)
#define ATA_REG_SECT_COUNT        (0x12<<2)           // 48
#define ATA_REG_SECT_NUM          (0x13<<2)           // 4C
#define ATA_REG_CYL_LOW           (0x14<<2)           // 50
#define ATA_REG_CYL_HIGH          (0x15<<2)           // 54
#define ATA_REG_DEV_HEAD          (0x16<<2)           // 58
#define ATA_REG_STATUS            (0x17<<2)           // 5C
#define ATA_REG_COMMAND           (ATA_REG_STATUS)
#define ATA_REG_ALT_STATUS        (0x1E<<2)           // 78

#define DEV_HEAD_LBA              (3<<5)

// ATA status bits
#define ATA_STS_BUSY              (1<<7)
#define ATA_STS_DRDY              (1<<6)
#define ATA_STS_DF                (1<<5)
#define ATA_STS_DSC               (1<<4)
#define ATA_STS_DRQ               (1<<3)
#define ATA_STS_CORR              (1<<2)
#define ATA_STS_IDX               (1<<1)
#define ATA_STS_ERR               (1<<0)

#define ATA_ERR_ICRC              (1<<7)
#define ATA_ERR_UNC               (1<<6)
#define ATA_ERR_MC                (1<<5)
#define ATA_ERR_IDNF              (1<<4)
#define ATA_ERR_MCR               (1<<3)
#define ATA_ERR_ABRT              (1<<2)
#define ATA_ERR_TK0NF             (1<<1)
#define ATA_ERR_AMNF              (1<<0)

#define ATA_RD32(addr)            \
  IORD_32DIRECT (((1<<31)|OCIDE3_CONTROLLER_0_PIO_SLAVE_BASE), (addr))
#define ATA_WR32(addr, data)      \
  IOWR_32DIRECT (((1<<31)|OCIDE3_CONTROLLER_0_PIO_SLAVE_BASE), (addr), (data))

#define MEB_RD32(addr)            \
  IORD_32DIRECT (MEB_IF_BASE, (addr))
#define MEB_WR32(addr, data)      \
  IOWR_32DIRECT (MEB_IF_BASE, (addr), (data))

alt_u32 wait_on_busy (void)
{
  alt_u32 status;

  // wait for BUSY to go away
  do
  {
    usleep (1000);
    status = ATA_RD32 (ATA_REG_STATUS);
    //DISPLAY ("(WOB) ATA_REG_STATUS = %lX" EOL, status);

  } while (status & ATA_STS_BUSY);

  return (status);
}

alt_u32 wait_for_device_ready (void)
{
  alt_u32 status;

  // wait for BUSY to go away
  do
  {
    status = wait_on_busy ();
    //DISPLAY ("(WOB) ATA_REG_STATUS = %lX" EOL, status);

  } while ((status & ATA_STS_DRDY) == 0);

  return (status);
}

alt_u32 wait_for_data_ready (void)
{
  alt_u32 status;

  // wait for BUSY to go away
  do
  {
    status = wait_on_busy ();
    //DISPLAY ("(WOB) ATA_REG_STATUS = %lX" EOL, status);

  } while ((status & ATA_STS_DRQ) == 0);

  return (status);
}

int set_device_dma_mode (int device, int mode)
{
  #ifdef VERBOSE
    DISPLAY ("set_device_dma_mode (%X)" EOL, mode);
  #endif

  ATA_WR32 (ATA_REG_DEV_HEAD, DEV_HEAD_LBA|(device<<4));
  wait_for_device_ready ();
  ATA_WR32 (ATA_REG_SECT_COUNT, mode);
  ATA_WR32 (ATA_REG_FEATURE, 0x03);
  ATA_WR32 (ATA_REG_COMMAND, ATA_CMD_SET_FEATURE);
  wait_for_device_ready ();

  alt_u32 status = ATA_RD32 (ATA_REG_STATUS);
  #ifdef VERBOSE
    DISPLAY ("STATUS = $%02X" EOL, (char)status);
  #endif
  if (status & ATA_STS_ERR)
  {
    alt_u32 error = ATA_RD32 (ATA_REG_ERROR);
    DISPLAY ("ERROR = $%02X" EOL, (char)error);
  }
  return (status);
}

static alt_u32 controller_ctrl = 0;

void wr_ctrl_direct (alt_u32 on_mask, alt_u32 off_mask)
{
  controller_ctrl |= on_mask;
  controller_ctrl &= ~off_mask;
  ATA_WR32 (CTRL, controller_ctrl);
}

int init_controller_ex (alt_u32 ctrl, int slow_pio_mode, int fast_pio_mode, int dma_mode)
{
  alt_u32 status;
  int dma_type;
  int dma_mode_value;

  // keep a shadow copy
  controller_ctrl = ctrl;

  #ifdef VERBOSE
    DISPLAY ("init_controller_ex()" EOL);
  #endif
  // bring controller out of reset
  ATA_WR32 (CTRL, 1);
  usleep (1000);
  ATA_WR32 (CTRL, ctrl);
  // clear the interrupt
  ATA_WR32 (STAT, 0);

  status = ATA_RD32 (CTRL);
  #ifdef VERBOSE
    DISPLAY ("CTRL = %lX" EOL, status);
  #endif
  status = ATA_RD32 (STAT);
  #ifdef VERBOSE
    DISPLAY ("STAT = %lX" EOL, status);
  #endif

  int rev = (status >> 24) & 0x0F;
  #ifdef VERBOSE
    DISPLAY ("OCIDE-%1lX Rev=%02X (%s)" EOL, 
              (status >> 28), rev, (rev ? "UDMA support" : "MDMA only"));
  #endif

  static alt_u32 slow_pio_timing[] =
  {
    0x0e021304, 0x01021303, 0xC6011301, 0x03010501, 0x00010401
  };

  switch (slow_pio_mode)
  {
    case -1 :
      break;
    case 0 : case 1 : case 2 : case 3 : case 4 :
      ATA_WR32 (PCTR, slow_pio_timing [slow_pio_mode]);
      break;
    default :
      return (ERROR);
      break;
  }
  status = ATA_RD32 (PCTR);

  static alt_u32 fast_pio_timing[] =
  {
    0x17020a04, 0x0c020803, 0x06010601, 0x03010501, 0x00010401
  };

  switch (fast_pio_mode)
  {
    case -1 :
      break;
    case 0 : case 1 : case 2 : case 3 : case 4 :
      ATA_WR32 (PFTR0, fast_pio_timing [fast_pio_mode]);
      ATA_WR32 (PFTR1, fast_pio_timing [fast_pio_mode]);
      break;
    default :
      return (ERROR);
      break;
  }
  status = ATA_RD32 (PFTR0);
  status = ATA_RD32 (PFTR1);

  if (dma_mode != -1)
  {
    dma_type = DMA_TYPE(dma_mode);
    dma_mode_value = DMA_MODE_VALUE(dma_mode);

    if (dma_type == DMA_MODE_MDMA)
    {
      #ifdef VERBOSE
        DISPLAY ("- MDMA mode" EOL);
      #endif
  
      static alt_u32 mdma_timing[] =
      {
        // bit 0 turns on UDMA in v31, benign in v30
        0x0e001000, 0x03000500, 0x01000500, 0x01000400, 0x01000300
      };
    
      switch (dma_mode_value)
      {
        case 0 : case 1 : case 2 : case 3 : case 4 :
          ATA_WR32 (DTR0, mdma_timing [dma_mode_value]);
          ATA_WR32 (DTR1, mdma_timing [dma_mode_value]);
          break;
        default :
          return (ERROR);
          break;
      }
    }
    else
    if (dma_type == DMA_MODE_UDMA)
    {
      // UDMA not supported on rev 0 controller
      if (rev == 0)
        return (ERROR);
  
      #ifdef VERBOSE
        DISPLAY ("- UDMA mode %d" EOL, dma_mode_value);
      #endif
  
      static alt_u32 udma_timing[] =
      {
        // bit 0 turns on UDMA in v31, benign in v30
        0x01000701, 0x01000501, 0x01000301
      };
    
      switch (dma_mode_value)
      {
        case -1 :
          break;
        case 0 : case 1 : case 2 :
          ATA_WR32 (DTR0, udma_timing [dma_mode_value]);
          ATA_WR32 (DTR1, udma_timing [dma_mode_value]);
          break;
        default :
          return (ERROR);
          break;
      }
    }
  }
  status = ATA_RD32 (DTR0);
  status = ATA_RD32 (DTR1);
  
  // select the device
  ATA_WR32 (ATA_REG_DEV_HEAD, DEV_HEAD_LBA);
  wait_for_device_ready ();
  
  status = ATA_RD32 (ATA_REG_STATUS);
  //DISPLAY ("init_controller() - ATA_REG_STATUS = %p" EOL, (void *)status);

  return (OK);
}

int init_controller (alt_u32 ctrl)
{
  return (init_controller_ex (ctrl, -1, -1, -1));
}

char init_cf (alt_u32 _delay)
{
  alt_u32 data;
  alt_u32 delay = (_delay == 0 ? 1000000 : _delay);

  ocide_set_cf_non (1);
  // wait for a bit  
  usleep (delay);

  // re-power the device
  ocide_set_cf_non(0);
  // wait for a bit  
  usleep (delay);

  data = ocide_get_cf_cd ();

  return (data != 0);
}

#define SHOW_INT(label,val)     DISPLAY ("%*.*s = %d" EOL, 60, 60, label, val);
#define SHOW_YESNO(label,val)   DISPLAY ("%*.*s = %s" EOL, 60, 60, label, ((val) ? "yes" : "no"));
#define SHOW_BITS(label,var)                \
  {                                         \
    int b;                                  \
    DISPLAY ("%*.*s = ", 60, 60, label);    \
    if ((var) == 0)                         \
    {                                       \
      DISPLAY ("(none)" EOL);               \
    }                                       \
    else                                    \
    {                                       \
      for (b=0; b<8; b++)                   \
        if ((var) & (1<<b))                 \
          DISPLAY ("%d,", b);               \
      DISPLAY ("\b " EOL);                  \
    }                                       \
  }

void pio_read_512_current (alt_u16 cmd, alt_u16 *buf)
{
  alt_u32 status, data;
  int     i;

  // write the PIO read command
  ATA_WR32 (ATA_REG_COMMAND, cmd);
  usleep (10);
  //usleep (1000);
  
  status = wait_for_data_ready ();
  if (!(status & ATA_STS_DRQ))
    DISPLAY ("error: DRQ not set ($%lX)" EOL, status);
  
  // Clear the interrupt
  ATA_WR32 (STAT, 0x00000000);

  // read device data
  for (i=0; i<256; i++)
  {
    data = ATA_RD32(ATA_REG_DATA);
    buf[i] = (alt_u16)data;
    //buf[i] = ((data << 8) & 0xFF00) | ((data >> 8) & 0xFF);
  }
        
  status = wait_on_busy ();
  //DISPLAY ("device status = $%01X" EOL, status);
}

void pio_read_512 (alt_u16 cmd, alt_u32 block, alt_u16 *buf)
{
  set_rw_params (0, block, 1);
  usleep (4000);
  pio_read_512_current (cmd, buf);
  usleep (4000);
}

void pio_write_512_current (alt_u16 cmd, alt_u16 *buf)
{
	alt_u32 status;
	int		i;

	// write the PIO write command
  ATA_WR32 (ATA_REG_COMMAND, cmd);
	usleep (1000);
	
	// wait for BUSY to go away
  //status = wait_on_busy ();
  status = wait_for_data_ready ();
	if (!(status & ATA_STS_DRQ))
  {
		DISPLAY ("error: DRQ not set ($%01lX)" EOL, status);
  }
	else
	{	
		// Clear the interrupt
    ATA_WR32 (STAT, 0x00000000);
	
		// write a block of data
		for (i=0; i<256; i++)
      ATA_WR32(ATA_REG_DATA, buf[i]);
					
    status = wait_on_busy ();
		//DISPLAY ("device status = $%01X" EOL, status);
	}
}

void pio_write_512 (alt_u16 cmd, alt_u32 block, alt_u16 *buf)
{
  set_rw_params (0, block, 1);
  pio_write_512_current (cmd, buf);
}

alt_u32 identify_device (int bVerbose)
{
  alt_u32   blocks;
  alt_u16   buf[256];

  pio_read_512_current (ATA_CMD_IDENTIFY_DEVICE, buf);
  blocks = (alt_u32)buf[1] * (alt_u32)buf[3] * (alt_u32)buf[6];

  if (bVerbose)
  {
    SHOW_YESNO ("removable media device", (buf[0] & (1<<7) ? 1 : 0));
    SHOW_YESNO ("not removable controller/device", (buf[0] & (1<<6) ? 1 : 0));
    SHOW_INT ("number of logical cylinders", buf[1]);
    SHOW_INT ("number of logical heads", buf[3]);
    SHOW_INT ("number of logical sectors per logical track", buf[6]);
    SHOW_INT ("(calculated number of sectors)", (int)blocks);
    SHOW_INT ("(calculated size (MB))", (int)((blocks*512L)/1000000L));
    SHOW_INT ("max READ/WRITE MULTIPLE sectors/int", buf[47]&0xFF);
    DISPLAY ("%*.*s = %s" EOL, 60, 60, "IORDY supported", ((buf[49]&(1<<11)) ? "yes" : "maybe"));
    SHOW_YESNO ("IORDY may be disabled", buf[49]&(1<<11));
    SHOW_YESNO ("LBA supported", buf[49]&(1<<9));
    SHOW_YESNO ("DMA supported", buf[49]&(1<<8));
    SHOW_INT ("(Current) PIO timing mode", buf[51] >> 8);
    //SHOW_INT ("(Current) DMA timing mode", buf[52] >> 8);   // obsolete
    if (buf[53] & (1<<0))
    {
      // words 54-58 are valid
    }
    if (buf[53] & (1<<1))
    {
      // words 64-70 are valid
      SHOW_BITS ("Multiword DMA mode active", buf[63] >> 8);
      SHOW_BITS ("Multiword DMA modes supported", buf[63]);
      SHOW_BITS ("Advanced PIO modes supported", (buf[64]&0x03)<<3);
      SHOW_INT ("Minimum Multiword DMA transfer cycle time", buf[65]);
      SHOW_INT ("Recommended Multiword DMA transfer cycle time", buf[65]);
    }
    SHOW_BITS ("Ultra DMA modes supported", buf[88]&0xFF);
    SHOW_BITS ("Ultra DMA mode selected", buf[88]>>8);
  }

  return (blocks);
}

void set_rw_params (int dev, alt_u32 block, alt_u32 num_blocks)
{
  // set LBA mode
  ATA_WR32 (ATA_REG_DEV_HEAD, DEV_HEAD_LBA|(dev<<4)|((block>>24)&0x0F));
  wait_for_device_ready ();
  ATA_WR32 (ATA_REG_CYL_HIGH, block>>16);
  ATA_WR32 (ATA_REG_CYL_LOW, block>>8);
  ATA_WR32 (ATA_REG_SECT_NUM, block);

  // this will fix everything!!!
  //wr_ctrl_direct (0x0010, 0);

  // sector count is only 8 bits (0=256)
  ATA_WR32 (ATA_REG_SECT_COUNT, (num_blocks&0xFF));
}

#ifdef SUPPORT_DMA

#include <altera_avalon_dma.h>

static char dma_done = 0;

static void rx_done (void *handle, void *data)
{
  dma_done++;
}

static void tx_done (void *handle)
{
  dma_done++;
}

void dma_read_multi (alt_u32 block, alt_u32 num_blocks, char *buffer)
{
  alt_u32 timeout;
  alt_u32 status;
  int     ret;

  #ifdef VERBOSE
    DISPLAY ("dma_read_multi (%ld, %ld, $%p)" EOL, block, num_blocks, buffer);
  #endif

  if (num_blocks > 256)
    return;

  // set direction to read
  controller_ctrl |= DMA_ENA;
  controller_ctrl &= ~DMA_DIR_RW;
  //init_controller (controller_ctrl);
  ATA_WR32 (CTRL, controller_ctrl);

  status = wait_on_busy ();
  set_rw_params (0, block, num_blocks);

  //DMA_reset ();

  // get some dma resources
  alt_dma_rxchan rxchan;
  if ((rxchan = alt_dma_rxchan_open ("/dev/dma_0")) == NULL)
  {
    DISPLAY ("alt_dma_rxchan_open() failed!" EOL);
    return;
  }

  // look at priviledges
  #ifdef MORE_VERBOSE
    alt_avalon_dma_priv *priv = ((alt_avalon_dma_rxchan *)rxchan)->priv;
    DISPLAY ("max_length = %ld" EOL, priv->max_length);
    DISPLAY ("alt_dma_rxchan_depth () = %ld" EOL, alt_dma_rxchan_depth (rxchan));
  #endif

  // 32-bit transfers
  alt_dma_rxchan_ioctl (rxchan, ALT_DMA_SET_MODE_32, 0);
  // do not increment source address
  alt_dma_rxchan_ioctl (rxchan, ALT_DMA_RX_ONLY_ON, (void *)(OCIDE3_CONTROLLER_0_DMA_SLAVE_BASE));

  // issue the DMA command to the device
	ATA_WR32 (ATA_REG_COMMAND, ATA_CMD_READ_DMA_RETRY);

  // need to wait at least 400ns before we read status
  usleep (100);
  // you can't read the status after starting a DMA according to Chris
  //status = ATA_RD32 (ATA_REG_ALT_STATUS);
  //DISPLAY ("ALT_STATUS = $%lX" EOL, status);

  // start a dma transaction
  //DISPLAY ("starting DMA read from device..." EOL);
  dma_done = 0;
  int c;
  for (c=0; c<1; c++)
  {
    #ifdef HAS_PERF
      PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE, 1);
    #endif

    //DISPLAY ("  alt_dma_rxchan_prepare (RXCHAN, $%p, %d...)" EOL,
    //        buffer + c * DMA_CHAIN_SIZE, DMA_CHAIN_SIZE);

    if ((ret = alt_dma_rxchan_prepare ( rxchan, 
                                        (void *)buffer + (c * DMA_CHAIN_SIZE), 
                                        num_blocks<<9, 
                                        rx_done, 
                                        NULL)) < 0)
    {
      DISPLAY ("alt_dma_rxchan_prepare() failed (%d)!" EOL, ret);
      dma_done = DMA_CHAINS;
    }

    // wait for dma to finish
    timeout = 1000;
    while ((dma_done < DMA_CHAINS) && --timeout)
      usleep (100);

    #ifdef HAS_PERF
      PERF_END (PERFORMANCE_COUNTER_0_BASE, 1);
    #endif

    if (timeout == 0)
      DISPLAY ("DMA timeout: block = %ld, dma_done = %d" EOL, block, dma_done);
  }

  // *MUST* turn this off or subsequent TX transfers break
  //DMA_reset ();
  alt_dma_rxchan_ioctl (rxchan, ALT_DMA_RX_ONLY_OFF, NULL);
  alt_dma_rxchan_close (rxchan);

  // disable DMA
  controller_ctrl &= ~DMA_ENA;
  ATA_WR32 (CTRL, controller_ctrl);

  status = ATA_RD32 (ATA_REG_STATUS);
  #ifdef VERBOSE
    DISPLAY ("Status = %02X" EOL, (char)status);
  #endif
  if (status & ATA_STS_ERR)
  {
    alt_u32 error = ATA_RD32 (ATA_REG_ERROR);
    DISPLAY ("ERROR = %02X" EOL, (char)error);
  }
}

void dma_read_512 (alt_u32 block, char *buffer)
{
  dma_read_multi (block, (alt_u32)1, buffer);
}

void dma_write_multi (alt_u32 block, alt_u32 num_blocks, char *buffer)
{
  alt_u32 timeout;
  alt_u32 status;
  int     ret;

  #ifdef VERBOSE
    DISPLAY ("dma_write_multi (%ld, %ld, $%p)" EOL, block, num_blocks, buffer);
  #endif

  if (num_blocks > 256)
    return;

  // set direction to write
  controller_ctrl |= DMA_ENA | DMA_DIR_RW;
  ATA_WR32 (CTRL, controller_ctrl);

  status = wait_on_busy ();
	set_rw_params (0, block, num_blocks);

  //DMA_reset ();

  // get some dma resources
  alt_dma_txchan txchan;
  if ((txchan = alt_dma_txchan_open ("/dev/dma_0")) == NULL)
  {
    DISPLAY ("alt_dma_txchan_open() failed!" EOL);
    return;
  }

  // look at priviledges
  #ifdef MORE_VERBOSE
    alt_avalon_dma_priv *priv = ((alt_avalon_dma_txchan *)txchan)->priv;
    DISPLAY ("max_length = %ld" EOL, priv->max_length);
    DISPLAY ("alt_dma_txchan_space () = %d" EOL, alt_dma_txchan_space (txchan));
  #endif

  // 32-bit transfers
  alt_dma_txchan_ioctl (txchan, ALT_DMA_SET_MODE_32, 0);
  // do not increment destination address
  alt_dma_txchan_ioctl (txchan, ALT_DMA_TX_ONLY_ON, (void *)(OCIDE3_CONTROLLER_0_DMA_SLAVE_BASE));

  // issue the DMA command to the device
	ATA_WR32 (ATA_REG_COMMAND, ATA_CMD_WRITE_DMA_RETRY);

  // need to wait at least 400ns before we read status
  usleep (100);

  // you can't read the status after starting a DMA according to Chris
  //status = ATA_RD32 (ATA_REG_ALT_STATUS);
  //DISPLAY ("ALT_STATUS = $%lX" EOL, status);

  // start a dma transaction
  //DISPLAY ("starting DMA write to device..." EOL);
  dma_done = 0;
  int c;
  for (c=0; c<1; c++)
  {
    #ifdef HAS_PERF
      PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE, 2);
    #endif

    //DISPLAY ("  alt_dma_txchan_send (TXCHAN, $%p, %d...)" EOL,
    //        buffer + c * DMA_CHAIN_SIZE, DMA_CHAIN_SIZE);

    if ((ret = alt_dma_txchan_send ( txchan, 
                                     (void *)buffer + (c * DMA_CHAIN_SIZE),
                                     num_blocks<<9, 
                                     tx_done, 
                                     NULL)) < 0)
    {
      DISPLAY ("alt_dma_txchan_send() failed (%d)!" EOL, ret);
      dma_done = DMA_CHAINS;
    }

    // wait for dma to finish
    timeout = 1000;
    while ((dma_done < DMA_CHAINS) && --timeout)
      usleep (100);

    #ifdef HAS_PERF
      PERF_END (PERFORMANCE_COUNTER_0_BASE, 2);
    #endif

    status = wait_on_busy ();
    if (status & ATA_STS_ERR)
      DISPLAY ("* WARNING: ATA device reports ERR" EOL);

    if (timeout == 0)
      DISPLAY ("DMA timeout: block = %ld, dma_done = %d" EOL, block, dma_done);
  }

  // *MUST* turn this off or subsequent RX transfers break
  //DMA_reset ();
  alt_dma_txchan_ioctl (txchan, ALT_DMA_TX_ONLY_OFF, NULL);
  alt_dma_txchan_close (txchan);

  // disable DMA
  controller_ctrl &= ~DMA_ENA;
  ATA_WR32 (CTRL, controller_ctrl);

  status = ATA_RD32 (ATA_REG_STATUS);
  #ifdef VERBOSE
    DISPLAY ("Status = %02X" EOL, (char)status);
  #endif
  if (status & ATA_STS_ERR)
  {
    alt_u32 error = ATA_RD32 (ATA_REG_ERROR);
    DISPLAY ("ERROR = %02X" EOL, (char)error);
  }
}

void dma_write_512 (alt_u32 block, char *buffer)
{
  dma_write_multi (block, 1, buffer);
}

#endif // SUPPORT_DMA

#endif // USE_OCIDEC
