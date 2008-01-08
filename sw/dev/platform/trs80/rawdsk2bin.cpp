#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>

#define NUM_TRACKS      40
#define NUM_SECTS       10

void dump (unsigned char *buf, unsigned long int addr, int len)
{
    char ascii[16+1];
    ascii[16] = '\0';

    for (int i=0; i<len; i++)
    {
        if (i%16 == 0) printf ("%04X: ", addr+i);
        printf ("%02X ", buf[i]);
        ascii[i%16] = (isprint(buf[i]) ? buf[i] : '.');
        if (i%16 == 15) printf ("| %16.16s\n", ascii);
    }
}

int main (int argc, char *argv[])
{
  char fname_dsk[128], fname_bin[128];

  if (--argc != 1)
    exit (0);

  sprintf (fname_dsk, "%s.DSK", argv[1]);
  sprintf (fname_bin, "%s.BIN", argv[1]);

	FILE *fp = fopen (fname_dsk, "rb");
	if (!fp) exit (0);

  FILE *fp2 = fopen (fname_bin, "wb");

  // read 1st sector
  unsigned char sector[256];
  for (int t=0; t<NUM_TRACKS; t++)
  {
    // pad each track to 32 sectors
    // makes flash address calcs trivial
    for (int s=0; s<32; s++)
    {
      if (s < NUM_SECTS)
      {
        fread (sector, 1, 256, fp);
        //dump (sector, diskinfo[t][s], 256);
      }
      else
        memset (sector, '\0', 256);

      fwrite (sector, 1, 256, fp2);
    }
  }

  fclose (fp2);

	fclose (fp);

	return (0);
}
