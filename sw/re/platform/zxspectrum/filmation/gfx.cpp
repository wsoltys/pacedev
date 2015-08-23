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

uint8_t ram[64*1024];

void main (int argc, char *argv[])
{
	FILE *fp, *fp2;
	struct stat	fs;
	int					fd;
	
	char				buf[1024];
	
	fp = fopen ("knightlore.sna", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[16384-27], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

	fp = fopen ("knightlore.bin", "wb");
	// write the relevant areas
	fwrite (&ram[0x6108], 0xd8f3-0x6108, 1, fp);
	fclose (fp);

  // parse the map

  unsigned p = 0x6248;
  fprintf (stdout, "X,Y,Z=%03d,%03d,%03d\n",
            ram[p+0], ram[p+1], ram[p+2]);

  p = 0x6251;
  int n = 0;
  while (1)
  {
    fprintf (stdout, "id=%03d\n", ram[p+0]);
    fprintf (stdout, " byte count =%03d\n", ram[p+1]);
    fprintf (stdout, " size=%02d\n", ram[p+2]>>3);
    fprintf (stdout, " attributes =%02d\n", ram[p+2]&0x07);

    unsigned b;
    for (b=0; ram[p+3+b] != 0xff; b++)
    {
      fprintf (stdout, " BG=%03d\n", ram[p+3+b]);
      if (4+b == 1+ram[p+1])
      break;
    }
    if (4+b != 1+ram[p+1])
    {
      unsigned f;
      for (f=0; ; f++)
      {
        fprintf (stdout, " block=%02d\n", ram[p+4+b+f]>>3);
        unsigned count = (ram[p+4+b+f]&0x07)+1;
        fprintf (stdout, " count=%02d\n", count);
        unsigned c;
        for (c=0; c<count; c++, f++)
        {
          unsigned xyz = ram[p+5+b+f];
          fprintf (stdout, "  x,y,z=%02d,%02d,%02d\n",
                    xyz&0x07, (xyz>>3)&0x07, (xyz>>6)&0x03);
        }
        if (5+b+f == 1+ram[p+1])
          break;
      }
    }
    p += 1 + ram[p+1];

    if (++n == 128)
      break;
  }

  exit (0);

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 192, 0, 0);

  PALETTE pal;
  uint8_t r[] = { 0x00, 255>>2,  20>>2, 255>>2 };
  uint8_t g[] = { 0x00, 106>>2, 208>>2, 255>>2 };
  uint8_t b[] = { 0x00,  60>>2, 254>>2, 255>>2 };
  for (int c=0; c<sizeof(r); c++)
  {
    pal[c].r = r[c];
    pal[c].g = g[c];
    pal[c].b = b[c];
  }
	set_palette_range (pal, 0, 3, 1);

	clear_bitmap (screen);

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

  allegro_exit ();
}

END_OF_MAIN();
