#ifndef __IDE_H__
#define __IDE_H__

// ATA commands
#define ATA_CMD_READ_SECTORS      0x20
#define ATA_CMD_WRITE_SECTORS     0x30
#define ATA_CMD_READ_DMA_RETRY    0xC8
//#define ATA_CMD_READ_DMA          0xC9      // obsolete
#define ATA_CMD_WRITE_DMA_RETRY   0xCA
//#define ATA_CMD_WRITE_DMA         0xCB      // obsolete
#define ATA_CMD_IDENTIFY_DEVICE   0xEC
#define ATA_CMD_SET_FEATURE       0xEF

#define DMA_MODE_MDMA             0x20
#define DMA_MODE_UDMA             0x40

#define UDMA_MODE(x)              (DMA_MODE_MDMA|(x))
#define MDMA_MODE(x)              (DMA_MODE_UDMA|(x))
#define DMA_TYPE(x)               ((x)&0xF8)
#define DMA_MODE_VALUE(x)         ((x)&0x07)

#ifdef __cplusplus
extern "C"
{
#endif
  
// wait routines
alt_u32 wait_on_busy (void);
alt_u32 wait_for_device_ready (void);
alt_u32 wait_for_data_ready (void);

// initialisation routines
int init_controller_ex (alt_u32 ctrl, int slow_pio_mode, int fast_pio_mode, int dma_mode);
int init_controller (alt_u32 ctrl);
char init_cf (alt_u32 _delay);
int set_device_dma_mode (int device, int mode);

// pio routines
void pio_read_512_current (alt_u16 cmd, alt_u16 *buf);
void pio_read_512 (alt_u16 cmd, alt_u32 block, alt_u16 *buf);
void pio_write_512_current (alt_u16 cmd, alt_u16 *buf);
void pio_write_512 (alt_u16 cmd, alt_u32 block, alt_u16 *buf);
alt_u32 identify_device (int bVerbose);
void set_rw_params (int dev, alt_u32 block, alt_u32 num_blocks);

// dma routines
void dma_read_multi (alt_u32 block, alt_u32 num_blocks, char *buffer);
void dma_read_512 (alt_u32 block, char *buffer);
void dma_write_multi (alt_u32 block, alt_u32 num_blocks, char *buffer);
void dma_write_512 (alt_u32 block, char *buffer);

// routines to be provided by the platform
void ocide_set_cf_non (alt_u8 flag);
alt_u8 ocide_get_cf_cd (void);          // 0 = not present

#ifdef __cplusplus
};
#endif

#endif
