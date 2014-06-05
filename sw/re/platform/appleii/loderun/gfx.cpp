#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

#define DO_TITLE
#define DO_TILES
//#define DO_GAMEOVER

uint8_t ram[64*1024];

uint8_t title_data[] =
{
	#include "title.c"
};

uint8_t title_rle_data[] =
{
	#include "title_rle.c"
};
#define RLE_SIZE (sizeof(title_rle_data)/sizeof(uint8_t))

uint8_t tile_data[] =
{
	#include "tiles.c"
};

char *get_char_description (unsigned t)
{
	static char *graphic[] =
	{
		"space", "brick", "solid", "ladder", "rope", "fall-thru", "end ladder",
		"gold",
		"enemy left 0",
		"player right 0",
		"solid square",
		"player left 0", "player left 1", "player left 4", 
		"player climb 0",
		"player dig left",
		"player right 1", "player right 2",
		"player climb 1",
		"player fall left", "player fall right",
		"player swing right 0", "player swing right 1", "player swing right 2", 
		"player swing left 0", "player swing left 1", "player swing left 2", 
		"dig spray 0", "dig spray 1", "dig spray 2", "dig spray 3", 
		"dig brick 0", "dig brick 1", "dig brick 2", "dig brick 3", "dig brick 4", "dig brick 5", 
		"player dig right",
		"dig spray 3", "dig spray 5",
		"enemy right 0", "enemy right 1", "enemy right 2", 
		"enemy left 0", "enemy left 1",
		"enemy swing right 0", "enemy swing right 1", "enemy swing right 2", 
		"enemy swing left 0", "enemy swing left 1", "enemy swing left 2", 
		"enemy climb 0", "enemy climb 1",
		"enemy fall right", "enemy fall left",
		"brick refill 0", "brick refill 1",
		"enemy respawn 0", "enemy respawn 1"
	};
	static char *symbol = ">.()/-<";

	static char ch[64];
		
	strcpy (ch, "'?'");
	if (t < 0x3b)
		strcpy (ch, graphic[t]);
	else if (t < 0x45)
		ch[1] = t - 0x3b + '0';
	else if (t < 0x5f)
		ch[1] = t - 0x45 + 'A';
	else if (t < 0x66)
		ch[1] = symbol[t-0x5f];
	else
		strcpy (ch, "(unknown)");
		
	return (ch);		
}

void main (int argc, char *argv[])
{
	FILE *fp;
	struct stat	fs;
	int					fd;
	
	char				buf[1024];
	
	fp = fopen ("0f00.bin", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[0x0f00], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

	fp = fopen ("lr_disk.bin", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[0x6000], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 280, 192, 0, 0);

#ifdef DO_TITLE

	clear_bitmap (screen);

	uint16_t x = 0;
	uint8_t y = 0;
	uint16_t a = 0x0f00;
	
	while (y < 192)
	{
		int8_t byte = ram[a++];
		if (byte == 0)
		{
			y++;
			x = 0;
			continue;
		}
		if (byte > 0)
		{
			x = byte * 7;
			continue;
		}
		for (unsigned i=0; i<7; i++)
		{
			if (byte & (1<<i))
				putpixel (screen, x, y, 15);
			x++;
		}
	}

	// converting to 8-bit
	fp = fopen ("title.c", "wt");
	for (y=0; y<192; y++)
	{
		for (x=0; x<280/8; x++)
		{
			uint8_t byte = 0;
			for (int i=0; i<8; i++)
			{
				if (getpixel (screen, x*8+i, y) != 0)
					byte |= (1<<(7-i));
			}
			fprintf (fp, "0x%02X,", byte);
		}
		fprintf (fp, "\n");
	}
	fclose (fp);
		
	clear_bitmap (screen);
	for (y=0; y<192; y++)
	{
		for (x=0; x<280/8; x++)
		{
			uint8_t byte = title_data[y*35+x];
			
			for (int i=0; i<8; i++)
				if (byte & (1<<(7-i)))
					putpixel (screen, x*8+i, y, 15);
		}
	}

	// now RLE it
	fp = fopen ("title_rle.c", "wt");
	FILE *fp2 = fopen ("title_rle.bin", "wb");

  uint8_t preamble[6] = "\x00\x00\x00\x00\x00";
  uint8_t postamble[6] = "\xFF\x00\x00\x00\x00";

  // write pre-amble to load bank register
  preamble[1] = 0;
  preamble[2] = 2;
  preamble[3] = 0xFF;
  preamble[4] = 0xA2;             			// MMU bank register for $4000
  fwrite (preamble, 1, 5, fp2);
  uint8_t bank[2] = { 0x02, 0x03 };			// 62/3, or $C000 in memory
  fwrite (bank, 1, 2, fp2);

  // write data block
  preamble[1] = 0x11;
  preamble[2] = 0x94;		// $1194 bytes
  preamble[3] = 0x68;
  preamble[4] = 0x00;   // load at $6800
  fwrite (preamble, 1, 5, fp2);
	
	int lc = 0;	
	int n = 0;
	while (n < 280/8*192)
	{
		unsigned cnt = 0;
		uint8_t byte = title_data[n];
		
		while (n<280/8*192 && (byte == title_data[n]) && cnt < 256)
		{
			cnt++;
			n++;
		}
		fprintf (fp, "0x%02X, 0x%02X, ", (uint8_t)cnt, byte);
		uint8_t tmp = (uint8_t)cnt;
		fwrite (&tmp, 1, 1, fp2);
		fwrite (&byte, 1, 1, fp2);
		lc += 2;
		if (lc == 16)
		{
			fprintf (fp, "\n");
			lc = 0;
		}
	}
	fprintf (fp, "\n");
	fclose (fp);

  // write pre-amble to restore bank register
  preamble[1] = 0;
  preamble[2] = 2;
  preamble[3] = 0xFF;
  preamble[4] = 0xA2;             // MMU bank register for $4000
  fwrite (preamble, 1, 5, fp2);
  bank[0] = 0x3A;									// 58, or $4000 in memory
  bank[1] = 0x3B;
  fwrite (bank, 1, 2, fp2);

  fwrite (postamble, 1, 5, fp2);

	fclose (fp2);

	// now show the rle version
	clear_bitmap (screen);
	x = 0;
	y = 0;
	for (n=0; n<RLE_SIZE; n+=2)
	{
		unsigned cnt = title_rle_data[n];
		uint8_t byte = title_rle_data[n+1];
		
		if (cnt == 0)
			cnt+= 256;

		while (cnt--)
		{
			for (int i=0; i<8; i++)
			{
				if (byte & (1<<(7-i)))
					putpixel (screen, x*8+i, y, 15);
			}
			x++;
			if (x == 280/8)
			{
				x = 0;
				y++;
			}
		}
	}

  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  

#endif // DO_TITLE

#ifdef DO_TILES

	fp = fopen ("tiles.c", "wt");
	
	for (uint16_t shift=0; shift<7; shift++)
	{
		clear_bitmap (screen);
		
		for (unsigned t=0; t<0x68; t++)
		{
			uint16_t	sl_tbl = 0xad00;
			uint16_t	data_tbl = 0xa200 +	shift * 0x100;
			
			for (unsigned sl=0; sl<11; sl++)
			{
				uint8_t		data[3];
				
				uint16_t	lu = ram[sl_tbl+t];		// $00-$7F
				uint16_t	lsb = ram[data_tbl+lu];
				uint16_t	msb = ram[data_tbl+0x80+lu];
				uint16_t	a = (msb << 8) | lsb;
				
				data[0] = ram[a];
				data[1] = ram[a+1];
				
				sl_tbl += 0x0068;
				
				lu = ram[sl_tbl+t];							// $00-$7F
				lsb = ram[data_tbl+lu];			
				msb = ram[data_tbl+0x80+lu];			
				a = (msb << 8) | lsb;
				
				data[1] |= ram[a];			
				data[2] = ram[a+1];
	
				sl_tbl += 0x0068;
				
				// render to display
				for (int byte=0; byte<3; byte++)
				{
					for (int bit=0; bit<7; bit++)
					{
						if (data[byte] & (1<<bit))
							putpixel (screen, (t%16)*16+byte*7+bit, 8+(t/16)*16+sl, 15);
					}
				}			
			}
		}
		
		char buf[128];
		sprintf (buf, "shift=%d", shift);
		SS_TEXTOUT_CENTRE (screen, font, buf, 280/2, 192-8, 15);

		if ((shift % 2) == 0)
		{
			fprintf (fp, "// SHIFT = %d\n\n", shift);
			
			for (unsigned t=0; t<0x68; t++)
			{
				//fprintf (fp, "// $%02X\n", t);
				for (unsigned sl=0; sl<11; sl++)
				{
					for (int byte=0; byte<2; byte++)
					{
						uint8_t data = 0;
						for (int bit=0; bit<8; bit++)
						{
							data <<= 1;
							if (getpixel (screen, (t%16)*16+byte*8+bit, 8+(t/16)*16+sl))
								data |= 1;
						}
						fprintf (fp, "0x%02X, ", data);
					}
				}
				
				fprintf (fp, "  // $%02X %s\n", t, get_char_description (t));
			}
			fprintf (fp, "\n");
		}

		
	  //while (!key[KEY_ESC]);	  
	  //while (key[KEY_ESC]);	  
	}

	fclose (fp);
	
	fp = fopen ("tiles.asm", "wt");
	fp2 = fopen ("tiles.bin", "wb");

  uint8_t t_preamble[6] = "\x00\x00\x00\x00\x00";
  uint8_t t_postamble[6] = "\xFF\x00\x00\x00\x00";

  // write pre-amble to load bank register
#if 1  
  t_preamble[1] = 0;
  t_preamble[2] = 2;
  t_preamble[3] = 0xFF;
  t_preamble[4] = 0xA2;             			// MMU bank register for $4000
  fwrite (t_preamble, 1, 5, fp2);
  uint8_t t_bank[2] = { 0x02, 0x03 };			// 60/1, or $8000 in memory
  fwrite (t_bank, 1, 2, fp2);
#endif

  // write data block
  t_preamble[1] = 0x23;
  t_preamble[2] = 0xC0;		// 2*11*4*$68
  t_preamble[3] = 0x40;
  t_preamble[4] = 0x00;   // load at $4000
  fwrite (t_preamble, 1, 5, fp2);

	fprintf (fp, "\ntile_data:\n\n");
	
	for (uint16_t shift=0; shift<8; shift+=2)
	{
		clear_bitmap (screen);

		fprintf (fp, "; SHIFT = %d\n\n", shift);

		uint8_t *d = &tile_data[shift/2*0x68*2*11];
				
		for (unsigned t=0; t<0x68; t++)
		{
			fprintf (fp, "        .db     ");

			for (unsigned sl=0; sl<11; sl++)
			{
				// render to display
				for (int byte=0; byte<2; byte++)
				{
					for (int bit=0; bit<8; bit++)
					{
						if (d[t*2*11+sl*2+byte] & (1<<(7-bit)))
							putpixel (screen, (t%16)*16+byte*8+bit, 8+(t/16)*16+sl, 15);
					}

					fprintf (fp, "0x%02X", d[t*2*11+sl*2+byte]);
					fwrite (&d[t*2*11+sl*2+byte], 1, 1, fp2);
					if (sl*2+byte != 10 && sl*2+byte != 21)
						fprintf (fp, ", ");
					if (sl*2+byte == 10)
						fprintf (fp, "\n        .db     ");						
				}			
			}
			
			fprintf (fp, "  ; $%02X %s\n", t, get_char_description (t));
		}
		fprintf (fp, "\n");
				
		char buf[128];
		sprintf (buf, "shift=%d", shift);
		SS_TEXTOUT_CENTRE (screen, font, buf, 280/2, 192-8, 15);
		
	  //while (!key[KEY_ESC]);	  
	  //while (key[KEY_ESC]);	  
	}

#if 1
  // write pre-amble to restore bank register
  t_preamble[1] = 0;
  t_preamble[2] = 2;
  t_preamble[3] = 0xFF;
  t_preamble[4] = 0xA2;             // MMU bank register for $4000
  fwrite (t_preamble, 1, 5, fp2);
  t_bank[0] = 0x3A;									// 58, or $4000 in memory
  t_bank[1] = 0x3B;
  fwrite (t_bank, 1, 2, fp2);
#endif

  fwrite (t_postamble, 1, 5, fp2);

	fclose (fp);
	fclose (fp2);

#endif // DO_TILES

#ifdef DO_GAMEOVER

	clear_bitmap (screen);

  fp = fopen ("gameover_2bpp.asm", "wt");

  uint8_t game_over[11][13];
    
  int a = 0x8C35;
  for (int l=0; l<11; l++)
  {
    // render original line
    for (int b=0; b<14; b++)
    {
      uint8_t data = ram[a+l*14+b];
      
      for (int i=0; i<7; i++)
      {
        // offset by 6 pixels
        // 3 to fix 88 vs 91 X offset of byte 11 vs 13
        if (data & (1<<i))
          putpixel (screen, 3+b*7+i, l, 15);
      }
    }

    fprintf (fp, "gol%d:%s.db     ", l+1, (l<9 ? "   " : "  "));
    
    // write 8-bit data to asm file    
    for (int b=0; b<13; b++)
    {
      uint8_t data = 0;
      
      for (int i=0; i<8; i++)
      {
        data <<= 1;
        if (getpixel (screen, b*8+i, l))
          data |= 1;
      }
      
      game_over[l][b] = data;
      fprintf (fp, "0x%02X%c ", data, (b == 6 || b == 12 ? ' ' : ','));
      if (b == 6)
        fprintf (fp, "\n        .db     ");
    }
    fprintf (fp, "\n");
  }

  // display 8-bit data
  for (int l=0; l<11; l++)
  {
    for (int b=0; b<13; b++)
    {
      for (int i=0; i<8; i++)
      {
        if (game_over[l][b] & (1<<(7-i)))
          putpixel (screen, b*8+i, 32+l, 15);
      }
    }
  }
  
  fclose (fp);
  
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

#endif // DO_GAMEOVER
	  
  allegro_exit ();

#ifdef DO_TITLE  
  printf ("original=%d\n", a-0x0f00);
  printf ("280/8*192=%d\n", 280/8*192);
  printf ("RLE_SIZE=%d\n", RLE_SIZE);
#endif
}

END_OF_MAIN();
