#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

unsigned char rom[64*1024];

int main (int argc, char *argv[])
{
  char buf[64];

  for (int i=0; i<9; i++)
  {
    sprintf (buf, "j%d.bin", i+1);
    //printf ("%s\n", buf);
    FILE *fp = fopen (buf, "rb");
    if (!fp) exit (0);
    fread (rom, 1, 0x1000, fp);
    fclose (fp);

    // write the output file
    sprintf (buf, "bank%d.bin", i);
    fp = fopen (buf, "wb");
    if (!fp) exit (0);

    unsigned char preamble[6] = "\x00\x00\x00\x00\x00";
    unsigned char postamble[6] = "\xFF\x00\x00\x00\x00";

    // write pre-amble to load bank register
    preamble[1] = 0;
    preamble[2] = 1;
    preamble[3] = 0xFF;
    preamble[4] = 0xA2;             // bank for $4000
    fwrite (preamble, 1, 5, fp);
    unsigned char bank = i;
    fwrite (&bank, 1, 1, fp);
        
    // write data block
    preamble[1] = 0x10;
    preamble[2] = 0x00;
    preamble[3] = 0x40;
    preamble[4] = 0x00;              // load at $4000
    fwrite (preamble, 1, 5, fp);
    fwrite (rom, 1, 0x1000, fp);

    // write pre-amble to restore bank register
    preamble[1] = 0;
    preamble[2] = 1;
    preamble[3] = 0xFF;
    preamble[4] = 0xA2;             // bank for $4000
    fwrite (preamble, 1, 5, fp);
    bank = 0x3A;
    fwrite (&bank, 1, 1, fp);

    fwrite (postamble, 1, 5, fp);

    fclose (fp);
  }

  printf ("Done!\n");
}
