

#include <alt_types.h>
#include <altera_avalon_spi.h>
//#include <unistd.h>
#include "m95320.h"


#define CMD_WRSR   0x01
#define CMD_WRITE  0x02
#define CMD_READ   0x03
#define CMD_WRDI   0x04
#define CMD_RDSR   0x05
#define CMD_WREN   0x06



alt_u8 m95320_readbyte(alt_u32 eeprom_base, alt_u16 address)
{
    alt_u8 data;
	alt_u8 command[3];

	command[0] = CMD_READ;
	command[1] = (address >> 8) & 0xFF;
	command[2] = (address     ) & 0xFF;
	alt_avalon_spi_command(eeprom_base, 0, 3, command, 1, &data, 0);

    return(data);
}

/*
void m95320_writebyte(alt_u32 eeprom_base, alt_u16 address, alt_u8 data)
{
	alt_u8 command[4];

	// Send a "Write Enable" command
	command[0] = CMD_WREN;
	alt_avalon_spi_command(eeprom_base, 0, 1, command, 0, NULL, 0);

	// Send the actual write...
	command[0] = CMD_WRITE;
	command[1] = (address >> 8) & 0xFF;
	command[2] = (address     ) & 0xFF;
	command[3] = data;
	alt_avalon_spi_command(eeprom_base, 0, 4, command, 0, NULL, 0);

	usleep(6000);	// Spec says to wait 5ms
}
*/
