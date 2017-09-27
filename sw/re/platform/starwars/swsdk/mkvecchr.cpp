#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint8_t vec_chr_data[] =
{
  0x00,	0x20, 0x50, 0x50, 0x20,	0xC8, 0x20, 0x10,
  0x10,	0x40, 0x20, 0x00, 0x00,	0x00, 0x00, 0x08,
  0x30,	0x20, 0x70, 0x70, 0x10,	0xF8, 0x30, 0xF8,
  0x70,	0x70, 0x00, 0x60, 0x00,	0x00, 0x00, 0x70,
  0x70,	0x20, 0xF0, 0x70, 0xF0,	0xF8, 0xF8, 0x78,
  0x88,	0x70, 0x08, 0x88, 0x80,	0x88, 0x88, 0xF8,
  0xF0,	0x70, 0xF0, 0x70, 0xF8,	0x88, 0x88, 0x88,
  0x88,	0x88, 0xF8, 0x70, 0x80,	0x70, 0x20, 0x00,
  0x00,	0x20, 0x08, 0x20, 0x00,	0x00, 0x00, 0x38,
  0x10,	0x20, 0x44, 0x44, 0x00,	0xFE, 0xFF, 0xFE,
  0x00,	0x70, 0x50, 0x50, 0x78,	0xC8, 0x50, 0x20,
  0x20,	0x20, 0xA8, 0x20, 0x00,	0x00, 0x00, 0x08,
  0x48,	0x60, 0x88, 0x88, 0x30,	0x80, 0x40, 0x08,
  0x88,	0x88, 0x60, 0x60, 0x10,	0x00, 0x40, 0x88,
  0x88,	0x50, 0x48, 0x88, 0x48,	0x80, 0x80, 0x80,
  0x88,	0x20, 0x08, 0x90, 0x80,	0xD8, 0xC8, 0x88,
  0x88,	0x88, 0x88, 0x88, 0xA8,	0x88, 0x88, 0x88,
  0x88,	0x88, 0x08, 0x40, 0x80,	0x08, 0x50, 0x00,
  0x00,	0x70, 0x0C, 0x20, 0x70,	0x70, 0x00, 0x44,
  0x10,	0x70, 0x00, 0x00, 0x6C,	0x82, 0xFF, 0xFE,
  0x00,	0x70, 0x50, 0xF8, 0xA0,	0x10, 0x50, 0x40,
  0x40,	0x10, 0x70, 0x20, 0x00,	0x00, 0x00, 0x10,
  0x48,	0x20, 0x08, 0x08, 0x50,	0xF0, 0x80, 0x10,
  0x88,	0x88, 0x60, 0x00, 0x20,	0x78, 0x20, 0x08,
  0xA8,	0x88, 0x48, 0x80, 0x48,	0x80, 0x80, 0x80,
  0x88,	0x20, 0x08, 0xA0, 0x80,	0xA8, 0xA8, 0x88,
  0x88,	0x88, 0x88, 0x40, 0x20,	0x88, 0x88, 0x88,
  0x50,	0x50, 0x10, 0x40, 0x40,	0x08, 0x88, 0x00,
  0x70,	0xA8, 0x0A, 0x20, 0x88,	0xF8, 0x60, 0xBA,
  0x38,	0x20, 0x00, 0x00, 0x92,	0x82, 0xFF, 0xFE,
  0x00,	0x20, 0x00, 0x50, 0x70,	0x20, 0x60, 0x00,
  0x40,	0x10, 0xA8, 0xF8, 0x00,	0x70, 0x00, 0x20,
  0x48,	0x20, 0x70, 0x30, 0x90,	0x08, 0xF0, 0x20,
  0x70,	0x78, 0x00, 0x60, 0x40,	0x00, 0x10, 0x10,
  0xB8,	0x88, 0x70, 0x80, 0x48,	0xE0, 0xE0, 0x98,
  0xF8,	0x20, 0x08, 0xC0, 0x80,	0xA8, 0x98, 0x88,
  0xF0,	0x88, 0xF0, 0x20, 0x20,	0x88, 0x50, 0xA8,
  0x20,	0x20, 0x20, 0x40, 0x20,	0x08, 0x00, 0x00,
  0xFE,	0x20, 0x08, 0x20, 0x88,	0xF8, 0xF0, 0xA2,
  0x38,	0xF8, 0x82, 0x38, 0x92,	0x82, 0xFF, 0xFE,
  0x00,	0x00, 0x00, 0xF8, 0x70,	0x40, 0xA8, 0x00,
  0x40,	0x10, 0xA8, 0x20, 0x40,	0x00, 0x00, 0x40,
  0x48,	0x20, 0x80, 0x08, 0xF8,	0x08, 0x88, 0x40,
  0x88,	0x08, 0x60, 0x60, 0x20,	0x78, 0x20, 0x20,
  0xB0,	0xF8, 0x48, 0x80, 0x48,	0x80, 0x80, 0x88,
  0x88,	0x20, 0x08, 0xA0, 0x80,	0x88, 0x88, 0x88,
  0x80,	0xA8, 0xA0, 0x10, 0x20,	0x88, 0x50, 0xA8,
  0x50,	0x20, 0x40, 0x40, 0x10,	0x08, 0x00, 0x00,
  0xFE,	0x20, 0x78, 0xA8, 0x88,	0xF8, 0xF0, 0xBA,
  0x7C,	0x20, 0x44, 0x44, 0x6C,	0x82, 0xFF, 0xFE,
  0x00,	0x00, 0x00, 0x50, 0x28,	0x98, 0x90, 0x00,
  0x20,	0x20, 0x00, 0x20, 0x40,	0x00, 0x00, 0x80,
  0x48,	0x20, 0x80, 0x88, 0x10,	0x88, 0x88, 0x80,
  0x88,	0x10, 0x60, 0x20, 0x10,	0x00, 0x40, 0x00,
  0x80,	0x88, 0x48, 0x88, 0x48,	0x80, 0x80, 0x88,
  0x88,	0x20, 0x88, 0x90, 0x88,	0x88, 0x88, 0x88,
  0x80,	0x90, 0x90, 0x88, 0x20,	0x88, 0x20, 0xA8,
  0x88,	0x20, 0x80, 0x40, 0x08,	0x08, 0x00, 0x00,
  0x48,	0x20, 0xF0, 0x70, 0x70,	0x70, 0x60, 0x44,
  0x6C,	0x50, 0x38, 0x82, 0x00,	0x82, 0xFF, 0xFE,
  0x00,	0x20, 0x00, 0x50, 0xF8,	0x98, 0x68, 0x00,
  0x10,	0x40, 0x00, 0x00, 0x80,	0x00, 0x80, 0x80,
  0x30,	0x70, 0xF8, 0x70, 0x10,	0x70, 0x70, 0x80,
  0x70,	0x60, 0x00, 0x40, 0x00,	0x00, 0x00, 0x20,
  0x78,	0x88, 0xF0, 0x70, 0xF0,	0xF8, 0x80, 0x78,
  0x88,	0x70, 0x70, 0x88, 0xF8,	0x88, 0x88, 0xF8,
  0x80,	0x68, 0x88, 0x70, 0x20,	0x70, 0x20, 0x50,
  0x88,	0x20, 0xF8, 0x70, 0x08,	0x70, 0x00, 0xF8,
  0x00,	0x20, 0x60, 0x20, 0x00,	0x00, 0x00, 0x38,
  0x82,	0x88, 0x00, 0x00, 0x00,	0xFE, 0xFF, 0xFE
};

#define FACTOR 4

static int write_run (int state, int run)
{
#if 0
  while (run--)
    fprintf (stdout, "%c", (state ? '#' : ' '));
#endif
	//printf ("        SVEC %d,%d,%d\n", run*FACTOR, -run, (state ? 7 : 0));
	if (state) state = 7;
	printf ("        .dw 0x%04X\n", ((state&0x07)<<13) | ((run*FACTOR)&0x1FFF));
}
 
int main (int argc, char *argv[])
{
  int l, c, b;
  const int n = 0x6f+1-0x20;  // # chars
  int maxruns = 0;
  
  for (l=0; l<7; l++)
  {
    for (c=0x20; c<=0x6f; c++)
    {
    	// what are we doing
    	//printf ("; line=%d, chr=$%02X\n", l, c);
    	printf ("lin%d_chr%02X:\n", l, c);
      // data byte for char
      uint8_t d = vec_chr_data[l*n+c-0x20];
      
      // each bit
      int state = -1;
      int run = 0;
      int nruns = 0;
      for (b=0; b<8; b++)
      {
        int bit = (d & (1<<(7-b)) ? 1 : 0);
        if (bit != state)
        {
          if (b != 0)
          {
            write_run (state, run);
            nruns++;
          }
          state = bit;
          run = 1;
        }
        else
          run++;
      }
      write_run (state, run);
      nruns++;
      
      if (nruns > maxruns)
      	maxruns = nruns;
      	
      while (nruns++ < 8)
      	//printf ("        RTSL\n");
      	printf ("        .dw 0\n");
      printf ("\n");
    }
    
    fprintf (stdout, "\n");
  }
  
  fprintf (stderr, "maxruns=%d\n", maxruns);
}
