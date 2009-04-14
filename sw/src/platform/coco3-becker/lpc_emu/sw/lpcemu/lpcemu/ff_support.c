#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define USE_OCIDEC

#include "integer.h"
#include "ff.h"
#include "diskio.h"

#include <alt_types.h>
#include "system.h"
#include "ide.h"

#if defined(USE_OCIDEC) && defined(USE_SDCARD) ||   \
    (!defined(USE_OCIDEC) && !defined(USE_SDCARD))
  #error "Define one (only) of USE_OCIDEC or USE_SDCARD"
#endif

#ifdef USE_OCIDEC
  #ifdef __ALTERA_AVALON_DMA
    #define USE_DMA
  #endif
#endif

#ifdef USE_SDCARD
  #include <io.h>
  #include "SD_Card.h"
#endif

static DSTATUS dstatus = STA_NODISK|STA_NOINIT;

DSTATUS disk_initialize (BYTE Drive)
{
  //printf ("disk_initialize(%d)\n", Drive);

  // default to bad
  dstatus = STA_NODISK|STA_NOINIT;

  #ifdef USE_OCIDEC
  
    if (!init_cf (250000))
      return (dstatus);
    dstatus &= ~STA_NODISK;
  
    usleep (4000);
  
    // enable PIO, IORDY, ensure ping-pong is ON
    if (init_controller_ex (0x0092, 0, 4, 2) < 0)
      return (dstatus);
    dstatus &= ~STA_NOINIT;
  
    usleep (4000);
  
    //identify_device (1);
    set_device_dma_mode (0, 2);
    usleep (4000);
  
  #endif
  
  #ifdef USE_SDCARD
  
    if(SD_card_init())
      return (dstatus);
    dstatus &= ~STA_NODISK;
    dstatus &= ~STA_NOINIT;
  
  #endif // USE_SDCARD

  return (dstatus);
}

DSTATUS disk_status (BYTE Drive)
{
  return (dstatus);
}

DRESULT disk_read (BYTE Drive, BYTE *Buffer, DWORD SectorNumber, BYTE SectorCount)
{
  int s;
  
  //printf ("disk_read (%d, $%p, %ld, %d)\n", Drive, Buffer, SectorNumber, SectorCount);

  if (dstatus)
    return (RES_NOTRDY);

  if (Buffer == 0)
    return (RES_PARERR);
  
  #ifdef USE_OCIDEC

    for (s=0; s<SectorCount; s++)
    {
      #ifndef USE_DMA
        pio_read_512(ATA_CMD_READ_SECTORS, SectorNumber, (alt_u16 *)Buffer);
      #else
        static alt_u8 __attribute__((aligned(4))) SectorBuffer[512];
  
        dma_read_512(SectorNumber, (char *)((1<<31)|(alt_u32)SectorBuffer));
        memcpy (Buffer, ((1<<31)|(alt_u32)SectorBuffer), 512);
        #if 0
          pio_read_512(ATA_CMD_READ_SECTORS, SectorNumber, (alt_u16 *)Buffer);
          if (memcmp (SectorBuffer, Buffer, 512)!= 0)
            printf ("DMA<->PIO mismatch!\n");
          else
            printf ("DMA<->PIO OK!\n");
        #endif
      #endif
  
      Buffer += 512;
      SectorNumber++;
    }
  
  #endif // USE_OCIDEC

  #ifdef USE_SDCARD

    //  for(s=0; s<72; s++) 
    //    SD_read_lba(Buffer,SectorNumber + 31 + s,SectorCount);
  
    SD_read_lba(Buffer,SectorNumber + 247,SectorCount);
  
  #endif // USE_SDCARD

  return (RES_OK);
}
