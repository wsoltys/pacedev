#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "../../../lr/tile_data_c2bpp.c"
#include "../../../lr/tile_data_m2bpp.c"
#include "../../../lr/title_data_c2bpp.c"
#include "../../../lr/title_data_m2bpp.c"

uint8_t vbm[280*192];

uint8_t	zero = 0;

FILE *c1 = fopen ("202-c1.bin", "wb");
FILE *c2 = fopen ("202-c2.bin", "wb");

void do_fix (void)
{
	// 15*8 = 120 pixels
	// "RETROPORTS" = 10*10 = 100 pixels
	// left/right margin = 10 pixels
	// height = 2*8=16 
	// top/bottom margin = 2/3 pixels
	uint8_t vfl[24][8*15];
	const char *text = "RETROPORTS";

	// render into 1-bit memory
	memset (vfl, 0, 24*8*15);	
	for (int y=0; y<11; y++)
		for (int x=0; x<strlen(text); x++)
		{
			int c = x % 5;
			int r = x / 5;
			int lm = (10*8 - 5*10) / 2;
			
			uint8_t t = toupper(text[x]) - 'A' + 0x45;
			uint32_t data = tile_data_c2bpp[t*11*3+y*3+0];
			data = (data << 8) | tile_data_c2bpp[t*11*3+y*3+1];
			data = (data << 8) | tile_data_c2bpp[t*11*3+y*3+2];
				
			for (int p=0; p<10; p++)
			{
				if (data & (3<<22))
					vfl[2+r*11+y][lm+c*10+p] = 1;
				data <<= 2;
			}
		}
		
	// now patch SFIX ROM
	FILE *fp = fopen ("202-s1.s1", "rb");
	FILE *s1 = fopen ("202-s1.bin", "wb");

	static const uint16_t max_330_mega[2][15] =
	{
		{ 0x05, 0x07, 0x09, 0x0B, 0x0D, 0x0F, 0x15, 0x17, 0x19, 0x1B, 0x1D, 0x1F, 0x5E, 0x60, 0x7D },
		{ 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, 0x40, 0x5F, 0x7C, 0x7E }
	};

	static const uint16_t pro_gear_spec[2][17] =
	{
		{ 0x7F, 0x9A, 0x9C, 0x9E, 0xFF, 0xBB, 0xBD, 0xBF, 0xDA, 0xDC, 0xDE, 0xFA, 0xFC, 0x100, 0x102, 0x104, 0x106 },
		{ 0x99, 0x9B, 0x9D, 0x9F, 0xBA, 0xBC, 0xBE, 0xD9, 0xDB, 0xDD, 0xDF, 0xFB, 0xFD, 0x101, 0x103, 0x105, 0x107 }
	};

	static const uint16_t SNK[3][10] = 
	{
		{ 0x200, 0x201, 0x202, 0x203, 0x204, 0x205, 0x206, 0x207, 0x208, 0x209 },
		{ 0x20A, 0x20B, 0x20C, 0x20D, 0x20E, 0x20F, 0x214, 0x215, 0x216, 0x217 },
		{ 0x218, 0x219, 0x21A, 0x21B, 0x21C, 0x21D, 0x21E, 0x21F, 0x240, 0x25E }
	};

	int n = 0;
	for (int t=0; t<128*1024/32; t++)
	{
		uint32_t buf32[32];

		fread (buf32, 1, 32, fp);

		// render tile 'n'
		if (n<30 && t == SNK[n/10][n%10])
		//if ((n < 30 && t == max_330_mega[n%2][n/2]))
				//n >= 30 && m < 34 && t == pro_gear_spec[m%2][m/2]))
		{
			for (int c=0; c<4; c++)
			{
				for (int r=0; r<8; r++)
				{
					//unsigned x = (n/2)*8+(1-(c/2))*4+(c%2)*2;
					unsigned x = (n%10)*8+(1-(c/2))*4+(c%2)*2;
					// do 2 pixels from each column
					uint8_t data = 0;
					#if 0
						if (vfl[(n%2)*8+r][x+1])
							data |= 0x10;
						if (vfl[(n%2)*8+r][x+0])
							data |= 0x01;
					#else
						if (vfl[(n/10)*8+r][x+1])
							data |= 0x50;
						if (vfl[(n/10)*8+r][x+0])
							data |= 0x05;
					#endif
						
					fwrite (&data, 1, 1, s1);
				}
			}
			n++;
		}
		else
			fwrite (buf32, 1, 32, s1);
	}
	
	fclose (fp);
	fclose (s1);
}

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
        uint8_t data = go[game_over_frame[f][l]][b];
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
					unsigned col = (1-(q/2))*8;

					uint16_t i = row*16*8 + t*16 + col;
					uint16_t data = 0;
										
					// extract 8 pixles for single row of quadrant
					for (unsigned p=0; p<8; p++)
					{
						// original = 14*7=98 pixels wide
						// = 98/16 = 6+2pel tiles wide
						data <<= 2;
						if (vbm[i] == 0 && 
								(t<6 || (t==6 && col<2)) && 
								row < 14)
							data |= 3;
						else
							data |= vbm[i];
						i++;
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

	do_fix ();
	
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
