#include <stdio.h>
#include <stdlib.h>

#include "../../../lr/tile_data_c2bpp.c"
#include "../../../lr/tile_data_m2bpp.c"
#include "../../../lr/title_data_c2bpp.c"
#include "../../../lr/title_data_m2bpp.c"

const uint8_t *tile_data[] =
{
	tile_data_m2bpp,
	tile_data_c2bpp
};

int main (int argc, char *argv[])
{
	FILE *c1 = fopen ("202-c1.bin", "wb");
	FILE *c2 = fopen ("202-c2.bin", "wb");
	FILE *spr = fopen ("PB_CHR.SPR","wb");

	// copy 1st 256 characters from original file
	FILE *fp1 = fopen ("202-c1.c1", "rb");
	FILE *fp2 = fopen ("202-c2.c2", "rb");
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

	for (unsigned set=0; set<2; set++)
	{		
		for (unsigned t=0; t<0x80; t++)
		{
			// 3 1	== 	2 0			4 quadrants
			// 4 2			3	1
			for (unsigned q=0; q<4; q++)
			{
				for (unsigned r=0; r<8; r++)
				{
					unsigned row = (q%2)*8+r;
					uint16_t data = 0;
					
					//if (row==0 || row==4 || row==8 || row==10 || row==12)
					if (t > 0x68 || row==3 || row==5 || row==7 || row==11 || row==15)
						data = 0;
					else
					{
						static unsigned actual_row[] =
						{
							//0, 0, 1, 2, 0, 3, 4, 5, 0, 6, 0, 7, 0, 8, 9, 10
							0, 1, 2, 0, 3, 0, 4, 0, 5, 6, 7, 0, 8, 9, 10, 0
						};
						
						row = actual_row[row];
	
						uint16_t i = t*3*11+3*row;
		
						// extract 10 bits for single row of quadrant
						if (row < 11)
						{
							if (q > 1)
							{
								data = tile_data[set][i];
								data <<= 2;
								data |= tile_data[set][i+1] >> 6;
							}
							else
							{
								data = tile_data[set][i+1] & 0x3f;
								data <<= 4;
								data |= tile_data[set][i+2] >> 4;
								//data <<= 6;
							}
						}
					}
					
					// pixels drawn for a 10-pixel wide sprite
					uint8_t horiz_reduct[] =
					{ 
						1,0,1,1,1,0,1,0,	1,1,1,0,1,0,1,0 
					};
					
					// extract bitplanes
					uint8_t plane[2];
					for (unsigned b=0; b<8; b++)
						for (unsigned p=0; p<2; p++)
						{
							plane[p] <<= 1;
							if (horiz_reduct[15-((q/2)*8+b)] == 1)
							{
								plane[p] |= data & 0x01;
								data >>= 1;
							}
						}
	
					// write mvs rom files
					fwrite (&plane[0], 1, 1, c1);				
					fwrite (&plane[1], 1, 1, c1);
					fwrite (&zero, 1, 1, c2);
					fwrite (&zero, 1, 1, c2);
				}
			}
		}
	}
		
	fclose (c1);
	fclose (c2);
	fclose (spr);
}
