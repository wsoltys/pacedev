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
	struct stat	fs;
	int					fd;
	
	char				buf[1024];
	
	FILE *fp = fopen ("0f00.bin", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[0x0f00], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 280, 192, 0, 0);

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

  while (!key[KEY_ESC]);	  
  while (key[KEY_ESC]);	  
  
  allegro_exit ();
  printf ("addr=0x%04X\n", a);
}

END_OF_MAIN();
