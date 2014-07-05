#include <stdio.h>
#include <stdlib.h>

#include "../../../lr/tile_data_c2bpp.c"
#include "../../../lr/tile_data_m2bpp.c"
#include "../../../lr/title_data_c2bpp.c"
#include "../../../lr/title_data_m2bpp.c"

int main (int argc, char *argv[])
{
	FILE *c1 = fopen ("202-c1.bin", "wb");
	FILE *c2 = fopen ("202-c2.bin", "wb");
	FILE *spr = fopen ("PB_CHR.SPR","wb");

	// copy 1st 256 characters from original file
	FILE *fp1 = fopen ("202-c1.c1", "rb");
	FILE *fp2 = fopen ("202-c2.c1", "rb");
	for (unsigned i=0; i<256*64; i++)
	{
		uint8_t	byte;
		
		fread (&byte, 1, 1, fp1);
		fwrite (&byte, 1, 1, c1);
		fread (&byte, 1, 1, fp2);
		fwrite (&byte, 1, 1, c2);
	}
	fclose (fp1);
	fclose (fp2);

	uint8_t	zero = 0;
		
	for (unsigned t=0; t<0x68; t++)
	{
		// 3 1	== 	2 0			4 quadrants
		// 4 2			3	1
		for (unsigned q=0; q<4; q++)
		{
			for (unsigned r=0; r<8; r++)
			{
				uint16_t i = t*3*11+(q%2)*3*8+r*3+(1-(q/2))*2;
				uint16_t data = 0;

				// extract 16 bits for single row of quadrant
				if ((r < 11-8) || ((q%2) == 0))
				{
					// 1st byte
					data = tile_data_c2bpp[i];
					// 2nd byte
					data <<= 8;
					if (q > 1)
						data |= tile_data_c2bpp[i+1];
				}
				
				// extract bitplanes
				uint8_t plane[2];
				for (unsigned b=0; b<8; b++)
					for (unsigned p=0; p<2; p++)
					{
						plane[p] = (plane[p] << 1) | data & 0x01;
						data >>= 1;
					}

				// write mvs rom files
				fwrite (&plane[0], 1, 1, c1);				
				fwrite (&plane[2], 1, 1, c1);
				fwrite (&zero, 1, 1, c2);
				fwrite (&zero, 1, 1, c2);
			}
		}
	}
	
	fclose (c1);
	fclose (c2);
	fclose (spr);
}
