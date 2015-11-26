#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

uint8_t ram[256*1024];

int main (int argc, char *argv[])
{
  FILE *fp;
  
  fp = fopen ("Monster Max (E).gb", "rb");
  fread (ram, 1, 256*1024, fp);
  fclose (fp);
  
  for (unsigned i=0; i<16; i++)
  {
    char fname[64];
    
    if (i == 0)
      sprintf (fname, "monstermax.bin");
    else
      sprintf (fname, "bank%02d.bin", i);
    fp = fopen (fname, "wb");
    fwrite (&ram[i*16*1024], 1, 16*1024, fp);
    fclose (fp);
  }
}
