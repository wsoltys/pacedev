
/////////////////////////////////////////////////////////////////////////////////////////////////
// One Wire Interface
/////////////////////////////////////////////////////////////////////////////////////////////////
// Register 0 - Status Register
//    Write to this register to force reset
//    Bit 0 - Busy
//    Bit 1 - No Device
//    Bit 2 - Data
// Register 1 - Read & Write Interface (This register actually activates the engine behind)
// Register 2 - Read the latest data byte received
/////////////////////////////////////////////////////////////////////////////////////////////////


#include <io.h>
#include "ow.h"

#define OW_ROMID_READ    0x33
#define OW_WAIT_IDLE()   while(IORD(ow_base,0)&0x01);

#define CRC8_POLYNOMIAL  0x31


alt_u8 bitreverse(alt_u8 byte)
{
	register alt_u8 result = byte;
	result = ((result & 0x55) << 1) | ((result & 0xAA) >> 1);
	result = ((result & 0x33) << 2) | ((result & 0xCC) >> 2);
	result = ((result & 0x0F) << 4) | ((result & 0xF0) >> 4);
	return(result);
}


alt_u8 ow_crc(alt_u8 * buffer, int length)
{
	register alt_u8 rem = 0;	// Sometimes 0xFF
	register int byte,bit;
	for(byte=0; byte<length; byte++)
	{
		rem = rem ^ bitreverse(buffer[byte]);

		for(bit=0; bit<8; bit++)
		{
			if(rem & 0x80)
				rem = rem << 1 ^ CRC8_POLYNOMIAL;
			else
				rem = rem << 1;
		}
	}
	return(rem);	// Sometimes ^ 0xFF
}



// Read out ROM ID and return non-zero result if any error (0=OK)
int ow_read_romid(alt_u32 ow_base, alt_u8 * romid)
{
	register int i;

	// Issue a reset
	IOWR(ow_base, 0, 0);
	OW_WAIT_IDLE();

	// Check if there is a device present or not
	if(IORD(ow_base, 0) & 0x02)
		return(OW_ERROR_NO_DEVICE);

	// Issue the read ROM ID command
	IOWR(ow_base, 1, OW_ROMID_READ);
	OW_WAIT_IDLE();

	// Read out the 8 bytes response
	for(i=0; i<8; i++)
	{
		IORD(ow_base, 1);				// Initiate a read...
		OW_WAIT_IDLE();
		romid[i] = IORD(ow_base, 2);	// Fetch the data collected
	}

	// Check that the CRC-8 is correct
	if(ow_crc(romid,8) != 00)
		return(OW_CRC_ERROR);

	// Check that not all bytes are 0x00 or 0xFF...
	for(i=0; i<8; i++)
	{
		if((romid[i] != 0x00) && (romid[i] != 0xFF))
			return(OW_RESULT_OK);
	}

	return(OW_DATA_ERROR);
}


