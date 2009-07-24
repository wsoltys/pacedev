#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

//#define USE_WIN32API

#ifdef USE_WIN32API
  #include <winbase.h>
#else
  #define DEVICE_NAME   "\\\\.\\S5LpcIo"  
  //#define DEVICE_NAME   "\\DosDevices\\S5LpcIo"  
#endif

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

void main (int argc, char *argv[])
{
  printf ("JAMMA v0.1\n");
  
#ifdef USE_WIN32API
  printf ("(WIN32API build)\n");
  HANDLE hPortIo = CreateFile("\\\\.\\S5LpcIo",
                GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ, 
                NULL, OPEN_EXISTING, 0, NULL);
  if (hPortIo == INVALID_HANDLE_VALUE)
#else
  printf ("(unistd build)\n");
  int fd = open (DEVICE_NAME, _O_RDWR|_O_BINARY);
  if (fd == -1)
#endif
  {
    printf ("error: unable to open device (%d)\n", errno);
    exit (0);
  }

  printf ("Initialising allegro...\n");
  
	allegro_init ();
	install_keyboard ();

	//set_color_depth (8);
	//set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

  static unsigned char jamma_n_r[4] = { 0xff, 0xff, 0xff, 0xff };
  static unsigned char jamma_n[4];

  while (1)
  {
    memset (jamma_n, '\xff', 4);

    // Player 1
    if (key[KEY_5]) jamma_n[0] &= ~(1<<0);
    if (key[KEY_1]) jamma_n[0] &= ~(1<<1);
    if (key[KEY_UP]) jamma_n[0] &= ~(1<<2);
    if (key[KEY_DOWN]) jamma_n[0] &= ~(1<<3);
    if (key[KEY_LEFT]) jamma_n[0] &= ~(1<<4);
    if (key[KEY_RIGHT]) jamma_n[0] &= ~(1<<5);

    // Player 1 buttons
    if (key[KEY_LCONTROL]) jamma_n[1] &= ~(1<<0);
    if (key[KEY_ALT]) jamma_n[1] &= ~(1<<1);

    // Player 1
    if (key[KEY_6]) jamma_n[2] &= ~(1<<0);
    if (key[KEY_2]) jamma_n[2] &= ~(1<<1);

    // Player 2 buttons

    if (memcmp (jamma_n, jamma_n_r, 4))
    {
      for (int i=0; i<4; i++)
        for (int b=0; b<7; b++)
          printf ("%d", (jamma_n[i] >> b)&0x01);
      printf ("\n");
    }

    if (key[KEY_ESC]) break;

    memcpy (jamma_n_r, jamma_n, 4);
  }
  
#ifdef USE_WIN32API
  CloseHandle (hPortIo);
#else
  close (fd);
#endif
}

END_OF_MAIN();
