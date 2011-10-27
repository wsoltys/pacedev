#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned char mem[64*1024];

int main (int argc, char *argv[])
{
  // read original dump
  FILE *fp = fopen ("blittest.bin", "rb");
  if (!fp) exit (0);
  fread (mem, 1, 64*1024, fp);
  fclose (fp);

  int i;
  for (i=1; i<=12; i++)
  {
    char name[64];
    sprintf (name, "rom%02d.bin", i);
    fp = fopen (name, "wb");
    if (i < 10)
      fwrite (&mem[(i-1)*0x1000], 1, 0x1000, fp);
    else
      fwrite (&mem[0xD000+(i-10)*0x1000], 1, 0x1000, fp);
    fclose (fp);
  }  

  // vram
  fp = fopen ("vram.bin", "wb");
  memset (&mem[0], 0, 0x8000);
  fwrite (&mem[0], 1, 0x8000, fp);
  fclose (fp);
    
}
