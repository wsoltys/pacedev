#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include <sys/ioctl.h>
#include "system.h"

#include "veb.h"
#include "dbg_helper.h"
#include "oxu210hp.h"

#ifndef BUILD_MINIMAL
#include <stdio.h>
#endif

#ifdef BUILD_ENABLE_USB

#define USB_MEMORY_TEST    1
#define USB_LOOP_IN_STATUS 0

int usb_start_bsd_stack (void);

int
init_usb (void)
{
  // init the OXU210HP
  uint32_t data32;

  // Ensure device clocks are running
//  OXU210HP_HOSTIF_WR(R_ClkCtrl_Set, R_ClkCtrl_CE | R_ClkCtrl_SE | R_ClkCtrl_OE);

  // external bytes enables, active-low interrupt
  data32 = HostIfConfig_BE|HostIfConfig_IP|HostIfConfig_DT;
  data32 = (data32 << 16) | data32;
  OXU210HP_HOSTIF_WR(R_HostIfConfig, data32);

  // now reset the chip
  OXU210HP_HOSTIF_WR(R_SoftReset, (1<<0));
  usleep (250000);
  // and re-write host config
  OXU210HP_HOSTIF_WR(R_HostIfConfig, data32);

	// power the USB ports (via GPIO)
	OXU210HP_HOSTIF_WR(R_GPIODataOE, 	OXU210HP_GPIO_SPARE|
																		OXU210HP_GPIO_USB_LOW_EN|
																	 	OXU210HP_GPIO_USB_CLIENT_EN|
																	 	OXU210HP_GPIO_USB_HOST_EN);
	OXU210HP_HOSTIF_WR(R_GPIODataOut, OXU210HP_GPIO_USB_CLIENT_EN|
																		//OXU210HP_GPIO_USB_HOST_EN);
																		OXU210HP_GPIO_SPARE);
  
  PRINT (0, "OX210HP Test ... ");
  
  data32 = OXU210HP_HOSTIF_RD(R_DeviceID);
  if ((data32 & 0xFFFFF0FF) != 0x21000000)
  {
    PRINT (0, "FAILED device-id : %08X\n", OXU210HP_HOSTIF_RD(R_DeviceID));
    return (-1);
  }
  
  // disable read bursting
  OXU210HP_HOSTIF_WR(R_BurstReadCtrl, 0x0000);
  // all (maskable) interrupts disabled
  OXU210HP_HOSTIF_WR(R_ChipIRQEn_Clr, 0xFFFF);
  OXU210HP_HOSTIF_WR(R_ChipIRQStatus, 0xFFFF);

  #define MEM_BYTES   (72*1024)

#if USB_MEMORY_TEST

  volatile uint8_t *mem8 = (uint8_t *)(((1<<31)|OXU210HP_IF_0_BASE)+(MEM_BASE));
  volatile uint16_t *mem16 = (uint16_t *)(((1<<31)|OXU210HP_IF_0_BASE)+(MEM_BASE));
  volatile uint32_t *mem32 = (uint32_t *)(((1<<31)|OXU210HP_IF_0_BASE)+(MEM_BASE));

  int i;
  // test memory
  srand (42);
  for (i=0; i<MEM_BYTES; i+=4)
  { 
    uint32_t r = rand(); r = (r << 16) | rand ();
    OXU210HP_MEM_WR(i, r);
  }
  srand (42);
  for (i=0; i<MEM_BYTES; i+=4)
  {
    uint32_t r = rand(); r = (r << 16) | rand();
    data32 = *(uint32_t *)(mem8+i);
    uint16_t data16_1 = *(uint16_t *)(mem8+i);
    uint16_t data16_2 = *(uint16_t *)(mem8+i+2);
    uint8_t data8_1 = *(uint8_t *)(mem8+i);
    uint8_t data8_2 = *(uint8_t *)(mem8+i+1);
    uint8_t data8_3 = *(uint8_t *)(mem8+i+2);
    uint8_t data8_4 = *(uint8_t *)(mem8+i+3);
    
    if ((data32 != r) || (data16_1 != (r&0xFFFF)) || (data16_2 != (r>>16)) ||
        (data8_1 != (r&0xFF)) || (data8_2 != ((r>>8)&0xFF)) ||
        (data8_3 != ((r>>16)&0xFF)) || (data8_4 != ((r>>24)&0xFF)))
    {
      PRINT (0, "FAILED memory @$%X : r=$%lX 32=$%lX, 16=$%X,%X, 8=$%X,%X,%X,%X\n", 
              i, r, data32, data16_1, data16_2, data8_1, data8_2, data8_3, data8_4);
      break;
    }
  }
  PRINT (0, "PASSED\n");

  *mem32 = 0x00000000;
  *mem8 = 0x12;
  if (*mem32 != 0x00000012) printf ("failed W=8, R=32\n");
  *mem32 = 0x11111111;
  *(mem8+1) = 0x34;
  if (*mem32 != 0x11113411) printf ("failed W=8, R=32\n");
  *mem32 = 0x22222222;
  *(mem8+2) = 0x56;
  if (*mem32 != 0x22562222) printf ("failed W=8, R=32\n");
  *mem32 = 0x33333333;
  *(mem8+3) = 0x78;
  if (*mem32 != 0x78333333) printf ("failed W=8, R=32\n");

  *mem32 = 0x44444444;
  *(mem16) = 0x1122;
  if (*mem32 != 0x44441122) printf ("failed W=16, R=32\n");
  *mem32 = 0x55555555;
  *(mem16+1) = 0x3344;
  if (*mem32 != 0x33445555) printf ("failed W=16, R=32\n");  
#endif

  return usb_start_bsd_stack ();
}
#endif
