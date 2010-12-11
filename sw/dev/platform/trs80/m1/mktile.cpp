#include <stdio.h>
#include <stdlib.h>

#include "../trs_chars.c"

int main (int argc, char *argv[])
{
  FILE *fp;
  char zero = 0;

  for (int s=0; s<3; s++)
  {
    char buf[64];
    sprintf (buf, "trs80_m1_tile_%d.bin", s);
    fp = fopen (buf, "wb");
    for (int c=0; c<128; c++)
    {
      for (int r=0; r<12; r++)
      {
        fwrite (&trs_char_data[s][c][r], 1, 1, fp);
      }
      for (int r=12; r<16; r++)
        fwrite (&zero, 1, 1, fp);
    }
    fclose (fp);
  }
}
