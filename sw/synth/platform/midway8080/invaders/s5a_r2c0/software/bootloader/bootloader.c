/*
 * When setting up the BSP, make sure everything is minimal
 * etc and only include the drivers for Nios and EPCS.
 * Set everything to use "onchip" (=boot) memory. Also
 * set optimization to "size" or at least -O2.
 *
 * To build the bootloader code into the onchip.hex file
 * right hand click the project and select [Make Targets]
 * and then [Build...]. Then select the "mem_init_install"
 * option and click [Build]. Now recompile the Quartus
 * project...
 *
 * To prepare application image create a .elf of the project.
 * Then run the "make_flash_image_script.sh" script to
 * generate a binary image. Now, to convert this file
 * to be suitable for programming into the EPCS device
 * we need to run the following command:
 *   bin2flash --input=projectname.elf.flash.bin
 *             --output=projectname.elf.flash.bin.flash
 *             --location=0x400000
 * The last step is to program this file into the EPCS
 * device using the following command:
 *   nios2-flash-programmer projectname.elf.flash.bin.flash
 *             --base=0x8000   (base address of the EPCS device in SOPC)
 *             --epcs          (This is an EPCS device we want to program)
 *             --device=1      (First device in JTAG chain)
 *             --instance=0    (Which CPU)
 *             --program       (Program the input file given)
 *             --verify        (Optional: Verify the programmed file)
 * If we want to convert from SREC format to Intel HEX format the
 * following command can be used:
 *   nios2-elf-objcopy
 *        --input-target srec
 *        --output-target ihex
 *        myfile.flash
 *        myfile.hex
 * Create the hardware section by converting SOF to FLASH:
 *   sof2flash --input=<hwimage>.sof --output=hwimage.flash --epcs --verbose
 * To do normal boot with software straight after the hardware image:
 *   elf2flash --input=swimage.elf --output=swimage.flash --epcs --after=hwimage.flash --verbose
 */

/*
 *  BSP Properties
 *
 *  Optimization Level: size
 *  Reduced device drivers: Yes
 *  Support C++: No
 *  Small C Library: Yes
 *
 *  BSP Editor:
 *    Main
 *      Settings
 *        Common
 *          enabled_reduced_drivers: Yes
 *          enable_small_c_library: Yes
 *          stderr: none
 *          stdin: none
 *          stdout: none
 *          sys_clk_timer: none
 *          timestamp_timer: none
 *  Drivers
 *    Settings
 *      Advanced
 *        altera_avalon_jtag_uart_driver
 *          enable_small_driver: Yes
 *  Linker Script
 *    Linker Section Mappings
 *      (all set to 'bootloader')
 */

#include <alt_types.h>
#include <sys/alt_irq.h>
#include <sys/alt_cache.h>
#include <sys/alt_sys_init.h>
#include <altera_avalon_spi.h>
#include <altera_avalon_pio_regs.h>
//#include <epcs_commands.h>

// From alt_sys_init.c
//#include "sys/alt_sys_init.h"
//#include "altera_nios2_irq.h"
//#include "altera_avalon_epcs_flash_controller.h"
//#include "altera_avalon_jtag_uart.h"
//#include "altera_avalon_sysid.h"
//#include "altera_avalon_timer.h"
//ALTERA_NIOS2_IRQ_INSTANCE ( NIOS_CPU, nios_cpu);
//ALTERA_AVALON_EPCS_FLASH_CONTROLLER_INSTANCE ( EPCS, epcs);
//ALTERA_AVALON_JTAG_UART_INSTANCE ( JTAG, jtag);
//ALTERA_AVALON_SYSID_INSTANCE ( SYSID, sysid);
//ALTERA_AVALON_TIMER_INSTANCE ( SYSTEM_TIMER, system_timer);


#include "system.h"

#include "ow.h"
#include "m95320.h"

// set to '1' to allow booting on security fail
#define BUILD_DEBUG		0

#define BOOT_TRUE   	1
#define BOOT_FALSE  	0

#define epcs_read 		3

// Size of buffer for processing flash contents
#define BOOT_BUFFER_LENGTH 256


// Set the boot image pointer half way up the M25P64 device
// 64 Mbit / 2 = 8 MByte / 2 = 4 MByte = 4 * 1024 * 1024 = 0x400000
#define BOOT_IMAGE_ADDR  ( 0x400000 )		// M25P64
//#define BOOT_IMAGE_ADDR  ( 0x100000 )		// M25P16



// This is the structure of the flash image header
typedef struct
{
  alt_u32 signature;
  alt_u32 version;
  alt_u32 timestamp;
  alt_u32 data_length;
  alt_u32 data_crc;
  alt_u32 res1;
  alt_u32 res2;
  alt_u32 header_crc;
} BOOT_HEADER_TYPE;


// Buffers to hold EEPROM image and ROM ID
alt_u8 eeprom_image[128];
alt_u8 romid[8];

#if 0
int eeprom_check(void)
{
	register int i, pass;

	// Read out the EEPROM image into memory
	for(i=0; i<128; i++)
		eeprom_image[i] = m95320_readbyte(M95320_BASE, i);

	// Check the EEPROM has some content
	if((eeprom_image[0] != 0x00) || (eeprom_image[1] != 'S'))
	{
		// The EEPROM is NOT programmed with sensible content!
		return(0);
	}

	// Check the ROM ID matches
	pass = 1;
	for(i=0; i<8; i++)
	{
		if(romid[i] != eeprom_image[0x20 + i])
		{
			pass = 0;
			break;
		}
	}
	if(pass == 0)
	{
		// Something is programmed but not the correct ROM ID
		// Signal this fact, but then just return to overwrite the EEPROM...
		return(0);
	}

	// Reset the SALSA engine
	salsa_reset();

	// Feed in the ROM ID
	for(i=0; i<8; i++)
		salsa_round(romid[i]);

	// Feed in the first 120 bytes of the EEPROM image
	for(i=0; i<120; i++)
		salsa_round(eeprom_image[i]);

	// Update the hash & Dump it!
	salsa_output();

	// Compare the hash with what is in the eeprom image
	pass = 1;
	for(i=0; i<8; i++)
	{
		if(eeprom_image[120+i] != salsa_result[i])
		{
			pass = 0;
			break;
		}
	}
	if(pass == 0)
	{
		// Something is programmed but not the correct HASH
		// Signal this fact, but then just return to overwrite the EEPROM...
		return(0);
	}

	// If we get to here the image was OK!
	return(1);
}
#endif

//void CopyFromFlash( void * dest, const void * src, size_t num ) __attribute__((always_inline));
void CopyFromFlash( void * dest, const void * src, size_t num )
{
	alt_u8 command[4];

	command[0] = epcs_read;
	command[1] = ((alt_u32)src >> 16) & 0xFF;
	command[2] = ((alt_u32)src >>  8) & 0xFF;
	command[3] = ((alt_u32)src      ) & 0xFF;
	alt_avalon_spi_command(EPCS_SPI_BASE, 0, 4, command, num, dest, 0);
}


alt_u32 FlashCalcCRC32(alt_u8 *flash_addr, int bytes)
{
  alt_u32 crcval = 0xffffffff;
  int i, buf_index, copy_length;
  alt_u8 cval;
  char flash_buffer[BOOT_BUFFER_LENGTH];

  while(bytes != 0)
  {
    copy_length = (BOOT_BUFFER_LENGTH < bytes) ? BOOT_BUFFER_LENGTH : bytes;
    CopyFromFlash(flash_buffer, flash_addr, copy_length);
    for(buf_index = 0; buf_index < copy_length; buf_index++ )
    {
      cval = flash_buffer[buf_index];
      crcval ^= cval;
      for (i = 8; i > 0; i-- )
      {
        crcval = (crcval & 0x00000001) ? ((crcval >> 1) ^ 0xEDB88320) : (crcval >> 1);
      }
      bytes--;
    }
    flash_addr += BOOT_BUFFER_LENGTH;
  }
  return crcval;
}


int ValidateFlashImage(void *image_ptr)
{
  BOOT_HEADER_TYPE header  __attribute__((aligned(4)));

  CopyFromFlash(&header, image_ptr, 32);

  // Check the signature first
  if( header.signature == 0xA5A5A5A5 )
  {
    // Signature is good, validate the header CRC
    if( header.header_crc != FlashCalcCRC32( (alt_u8*)image_ptr, 28) )
    {
      // Header CRC is not valid
      return BOOT_FALSE;
    }
    else
    {
      // Header CRC is valid, now validate the data CRC
      if ( header.data_crc == FlashCalcCRC32( image_ptr + 32, header.data_length) )
      {
        // Data CRC validates, the image is good
        return BOOT_TRUE;
      }
      else
      {
        // Data CRC is not valid
        return BOOT_FALSE;
      }
    }
  }
  else
  {
    // Bad signature
    return BOOT_FALSE;
  }
}


alt_u32 LoadFlashImage (void *image)
{
  alt_u8 *  next_flash_byte;
  alt_u32   length;
  alt_u32   address;

  // Point to data after the header
  next_flash_byte = (alt_u8 *)image + 32;

  // Get the first 4 bytes of the boot record, which should be a length record
  CopyFromFlash( (void*)(&length), (void*)(next_flash_byte), (size_t)(4) );
  next_flash_byte += 4;

  // Now loop until we get jump record, or a halt record
  while( (length != 0) && (length != 0xFFFFFFFF) )
  {
    // Get the next 4 bytes of the boot record, which should be an address
    // record
    CopyFromFlash( (void*)(&address), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;

    // Copy the next "length" bytes to "address"
    CopyFromFlash( (void*)(address), (void*)(next_flash_byte), (size_t)(length) );
    next_flash_byte += length;

    // Get the next 4 bytes of the boot record, which now should be another
    // length record
    CopyFromFlash( (void*)(&length), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;
  }

  // "length" was read as either 0x0 or 0xFFFFFFFF, which means we are done
  // copying.
  if( length == 0xFFFFFFFF )
  {
    // We read a HALT record, so return a -1
    return -1;
  }
  else // length == 0x0
  {
    // We got a jump record, so read the next 4 bytes for the entry address
    CopyFromFlash( (void*)(&address), (void*)(next_flash_byte), (size_t)(4) );
    next_flash_byte += 4;

    // Return the entry point address
    return address;
  }
}


void my_sys_init( void )
{
    //ALTERA_AVALON_TIMER_INIT ( SYSTEM_TIMER, system_timer);
    //ALTERA_AVALON_EPCS_FLASH_CONTROLLER_INIT ( EPCS, epcs);
    //ALTERA_AVALON_JTAG_UART_INIT ( JTAG, jtag);
    //ALTERA_AVALON_SYSID_INIT ( SYSID, sysid);
}


//int main (void) __attribute__((weak, noreturn, alias ("alt_main")));
//int alt_main(void)
int main(void)
{
	alt_u32 ok = 0;

  void (*entry_point)(void);

  // System init
  alt_irq_init(ALT_IRQ_BASE);

  //alt_sys_init();
  my_sys_init();

	// turn on ALL the leds
	IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, (3<<30)|0x3F);

  // wait for power rails to stabilise
	usleep (500000);

	ok = (ow_read_romid(ONE_WIRE_INTERFACE_0_BASE, romid) == OW_RESULT_OK ? 1 : 0);
		while (!ok && !BUILD_DEBUG);

#if 0
	ok &= (eeprom_check() != 0 ? 1 : 0);
		while (!ok && !BUILD_DEBUG);
#endif

	// set a flag in the FPGA to say security check is OK
	// - this is for debugging only, so we can boot on
	//   uninitialised boards (and know they're uninitialised)
	//IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, (3<<30)|(ok<<29));
	
  // Check if there is a flash image present...
  if(ValidateFlashImage((void *)BOOT_IMAGE_ADDR) == BOOT_TRUE)
  {
	IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, (3<<30)|(ok<<29));

	// Disable interrupts as we may be overwriting the exception table
    alt_irq_disable_all();

    entry_point = (void (*)(void)) LoadFlashImage((void *) BOOT_IMAGE_ADDR);

    // Check if we got an entry point to jump to...
    if( entry_point >= 0 )
    {
	  alt_irq_disable_all ();
	  alt_dcache_flush_all ();
	  alt_icache_flush_all ();

	  entry_point();
    }
    else
    {
      // No entry point => Die...
      while(1) ;
    }
  }

  // If we didn't find an application to boot => Hang forever!
  while(1)
  {
	usleep (250000);
	IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, 0);
	usleep (250000);
	IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, 0x3F);
  }
}

