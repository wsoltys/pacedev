#include <stdio.h>
#include <stdlib.h>

static unsigned char rom[16*1024];

int main (int argc, char *argv[])
{
  // MAIN
  
  FILE *fp = fopen ("main.bin", "rb");
  fread (rom, 16*1024, 1, fp);
  fclose (fp);

  for (int i=0; i<16*1024; i++)
    if (rom[i] < 10)
      rom[i] += '0';
    else
      rom[i] += 'A' - 10;
      
  fp = fopen ("main.asc", "wb");
  fwrite (rom, 16*1024, 1, fp);
  fclose (fp);

  // SUB
  
  fp = fopen ("sub.bin", "rb");
  fread (rom, 8*1024, 1, fp);
  fclose (fp);

  for (int i=0; i<8*1024; i++)
    if (rom[i] < 10)
      rom[i] += '0';
    else
      rom[i] += 'A' - 10;
      
  fp = fopen ("sub.asc", "wb");
  fwrite (rom, 8*1024, 1, fp);
  fclose (fp);

  // SUB2
  
  fp = fopen ("sub2.bin", "rb");
  fread (rom, 4*1024, 1, fp);
  fclose (fp);

  for (int i=0; i<4*1024; i++)
    if (rom[i] < 10)
      rom[i] += '0';
    else
      rom[i] += 'A' - 10;
      
  fp = fopen ("sub2.asc", "wb");
  fwrite (rom, 4*1024, 1, fp);
  fclose (fp);

}
