#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../../lr/tile_data_c2bpp.c"
#include "../../../lr/tile_data_m2bpp.c"
#include "../../../lr/title_data_c2bpp.c"
#include "../../../lr/title_data_m2bpp.c"

uint8_t vbm[280*192];

uint8_t	zero = 0;

FILE *c1 = fopen ("202-c1.bin", "wb");
FILE *c2 = fopen ("202-c2.bin", "wb");

void do_tiles (unsigned set)
{
	const uint8_t *tile_data[] =
	{
		tile_data_m2bpp,
		tile_data_c2bpp
	};
	
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

void do_title (unsigned set)
{
	const uint8_t *title_data[] =
	{
		title_data_m2bpp,
		title_data_c2bpp
	};
	
	// now do title tiles
	unsigned row = 0;
	unsigned n = 0;
	unsigned v = 0;
	
	while (row < 192)
	{
		unsigned count = title_data[set][n++];
		uint8_t byte = title_data[set][n++];
		
		//if (count == 0)
		//	count = 256;
		while (count--)
		{
			for (unsigned p=0; p<4; p++)
				vbm[v++] = (byte >> (6-p*2)) & 3;
			if (v % 280 == 0)
				row++;
		}
	}
	fprintf (stderr, "title_data_c2bpp=%d, n=%d, v=%d\n", 
						sizeof(title_data_c2bpp), n, v);

	// now make 10x16 tiles
	unsigned t = 0;
	for (unsigned x=0; x<28; x++)
	{
		for (unsigned y=0; y<192/16; y++)
		{
			// 3 1	== 	2 0			4 quadrants
			// 4 2			3	1
			for (unsigned q=0; q<4; q++)
			{
				for (unsigned r=0; r<8; r++)
				{
					unsigned row = (q%2)*8+r;
					uint16_t data = 0;

					uint16_t i = y*16*280 + row*280 + x*10 + (1-(q/2))*5;
										
					// extract 5 pixles for single row of quadrant
					for (unsigned p=0; p<5; p++)
					{
						data <<= 2;
						data |= vbm[i++];
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
			t++;
		}
	}
	fprintf (stderr, "#tiles=%d\n", t);
	
	for (; t<384; t++)
	{
		for (unsigned b=0; b<4*8; b++)
		{
			fwrite (&zero, 1, 1, c1);
			fwrite (&zero, 1, 1, c1);
			fwrite (&zero, 1, 1, c2);
			fwrite (&zero, 1, 1, c2);
		}
	}
}

void do_gameover (unsigned set)
{
  static const uint8_t game_over_frame[][14] =
  {
    { 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0 },     // 1,11
    { 0, 0, 0, 0, 0, 1, 3, 0xA, 1, 0, 0, 0, 0, 0 },   // 2,10
    { 0, 0, 0, 0, 1, 2, 3, 0xA, 2, 1, 0, 0, 0, 0 },   // 3,9
    { 0, 0, 0, 1, 2, 3, 4, 9, 0xA, 2, 1, 0, 0, 0 },   // 4,8
    { 0, 0, 1, 2, 3, 4, 5, 7, 9, 0xA, 2, 1, 0, 0 },   // 5,7
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 2, 1, 0 },   // 6
		{ 0, 0, 0, 0, 0, 1, 0xA, 3, 1, 0, 0, 0, 0, 0 },   // 12,20
    { 0, 0, 0, 0, 1, 2, 0xA, 3, 2, 1, 0, 0, 0, 0 },   // 13,19
    { 0, 0, 0, 1, 2, 0xA, 9, 4, 3, 2, 1, 0, 0, 0 },   // 14,18
    { 0, 0, 1, 2, 0xA, 9, 7, 5, 4, 3, 2, 1, 0, 0 },   // 15, 17
    { 0, 1, 2, 0xA, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 },   // 16
  };

  static const uint8_t go[][26] =
  {
    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00  
    },
    { 0x00, 0x00, 0x15, 0x55, 0x55, 0x55, 0x55, 0x55,  
      0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,  
      0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x50,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x55, 0x50, 0x15, 0x50, 0x15,  
      0x55, 0x50, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50,  
      0x15, 0x01, 0x01, 0x55, 0x50, 0x15, 0x55, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x15,  
      0x50, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50,  
      0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50,  
      0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x50, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x01, 0x01, 0x55, 0x00, 0x15, 0x55, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x01, 0x50, 0x15, 0x50, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x01, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x55, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10,  
      0x15, 0x50, 0x01, 0x00, 0x00, 0x15, 0x01, 0x01,  
      0x00, 0x00  
    },
    { 0x00, 0x01, 0x01, 0x55, 0x50, 0x10, 0x10, 0x10,  
      0x10, 0x10, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50,  
      0x01, 0x00, 0x01, 0x55, 0x50, 0x15, 0x01, 0x01,  
      0x00, 0x00  
    }
  };

  // note that there are 11 frames
  // each frame is 14 scanlines high
  // and 26*4=104 pixels = 6.5=7 NG tiles wide
  // ng requires 11*7=77 tiles
  // or use NG flipping/scaling?

  for (unsigned f=0; f<11; f++)
  {
    // render to virtual bitmap
    uint8_t vbm[8*16*16];

    memset (vbm, 0, 8*16*16);
    for (unsigned l=0; l<14; l++)
    {
      for (unsigned b=0; b<26; b++)
      {
        uint8_t data = go[f][b];
        for (unsigned p=0; p<4; p++)
        {
          vbm[l*8*16+b*4+p] = (data >> 6) & 3;
          data <<= 2;
        }
      }
    }

    // now make 8 tiles
    for (unsigned t=0; t<8; t++)
    {
			// 3 1	== 	2 0			4 quadrants
			// 4 2			3	1
			for (unsigned q=0; q<4; q++)
			{
				for (unsigned r=0; r<8; r++)
				{
					unsigned row = (q%2)*8+r;
					uint16_t data = 0;

					uint16_t i = row*16*8 + t*16 + (1-(q/2))*8;
										
					// extract 8 pixles for single row of quadrant
					for (unsigned p=0; p<8; p++)
					{
						data <<= 2;
						data |= vbm[i++];
					}
					
					// extract bitplanes
					uint8_t plane[2];
					for (unsigned b=0; b<8; b++)
						for (unsigned p=0; p<2; p++)
						{
							plane[p] <<= 1;
							plane[p] |= data & 0x01;
							data >>= 1;
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

  // pad out to 128 tiles
	for (unsigned t=0; t<128-11*8; t++)
	{
		for (unsigned b=0; b<4*8; b++)
		{
			fwrite (&zero, 1, 1, c1);
			fwrite (&zero, 1, 1, c1);
			fwrite (&zero, 1, 1, c2);
			fwrite (&zero, 1, 1, c2);
		}
	}
}

int main (int argc, char *argv[])
{
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

	// do tiles
	for (unsigned set=0; set<2; set++)
	{
		do_tiles (set);
		do_title (set);
    do_gameover (set);
	}
	
	fclose (c1);
	fclose (c2);

  // merge to SPR for CD
  c1 = fopen ("202-c1.bin", "rb");
  c2 = fopen ("202-c2.bin", "rb");
  FILE *spr = fopen ("PB_CHR.SPR", "wb");
  uint16_t w1, w2;
  fread (&w1, 1, 2, c1);
  fread (&w2, 1, 2, c2);
  while (!feof (c1))
  {
  	w1 = (w1 >> 8) | (w1 << 8);
  	w2 = (w2 >> 8) | (w2 << 8);
    fwrite (&w1, 1, 2, spr);
    fwrite (&w2, 1, 2, spr);
    
    fread (&w1, 1, 2, c1);
    fread (&w2, 1, 2, c2);
  }
  fclose (spr);
  fclose (c2);
  fclose (c1);

}
