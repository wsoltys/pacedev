#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "dmk.h"

dmk_header_t    hdr;
unsigned char   trk_hdr[DMK_TKHDR_SIZE];

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
  char fname_dmk[128];
  char fname_rtf[128];
  char fname_dat[128];

  sprintf (fname_dmk, "%s.dmk", argv[1]);
  sprintf (fname_rtf, "%s.rtf", argv[1]);
  sprintf (fname_dat, "%s.dat", argv[1]);

  FILE *fp_dmk = fopen (fname_dmk, "rb");
  if (!fp_dmk) exit (0);
  FILE *fp_rtf = fopen (fname_rtf, "wb");
  if (!fp_rtf) exit (0);
  FILE *fp_dat = fopen (fname_dat, "wt");
  if (!fp_dat) exit (0);

  fread (&hdr, sizeof(dmk_header_t), 1, fp_dmk);
  fprintf (stderr, "writeprot = %d\n", (hdr.writeprot ? 1 : 0));
  fprintf (stderr, "ntracks = %d\n", hdr.ntracks);
  fprintf (stderr, "tracklen = %d\n", hdr.tracklen);
  fprintf (stderr, "options = $%X (", hdr.options);
  fprintf (stderr, "%s", (hdr.options&DMK_SSIDE_OPT ? "SSIDE," : ""));
  fprintf (stderr, "%s", (hdr.options&DMK_SDEN_OPT ? "SDEN," : ""));
  fprintf (stderr, "%s", (hdr.options&DMK_IGNDEN_OPT ? "IGNDEN," : ""));
  fprintf (stderr, "%s", (hdr.options&DMK_RX02_OPT ? "RX02," : ""));
  fprintf (stderr,")\n");
  fprintf (stderr, "mbz = $%ld\n", hdr.mbz);

  unsigned int datalen = hdr.tracklen-DMK_TKHDR_SIZE;
  unsigned char *buf = (unsigned char *)malloc (datalen);
  fprintf (stderr, "datalen = %d\n", datalen);

  int n_trks = 0;
  while (!feof(fp_dmk))
  {
    fread (trk_hdr, 1, DMK_TKHDR_SIZE, fp_dmk);
    if (feof (fp_dmk))
      break;
    fread (buf, 1, datalen, fp_dmk);

    // show some track data
    #if 0
      printf ("Track: %02d\n", n_trks);
      dump (buf, 0, datalen);
      printf ("\n");
    #endif

    fprintf (stderr, "Track: %02d - ", n_trks);
    unsigned short *p_idam = (unsigned short *)trk_hdr;
    int n_idams;
    for (n_idams=0; n_idams<DMK_TKHDR_SIZE/sizeof(unsigned short int); n_idams++)
    {
      if (*p_idam == 0)
        break;

      int offset = (*p_idam & 0x3FFF) - DMK_TKHDR_SIZE;
      fprintf (stderr, "%02d ", *(buf+offset+3));

      p_idam++;
    }
    fprintf (stderr, "(#%d)\n", n_idams);

    // save raw track data (padded) to RTF file
    unsigned char *zero = (unsigned char *)"\0";
    fwrite (buf, 1, datalen, fp_rtf);
    for (int i=0; i<8192-datalen; i++)
      fwrite (zero, 1, 1, fp_rtf);

		// save sram model data file
		for (int i=0; i<datalen; i++)
		{
			fprintf (fp_dat, "%ld ", n_trks*8192+i);
			for (int j=(1<<7); j; j>>=1)
				fprintf (fp_dat, "%c", ((*(buf+i))&j ? '1' : '0'));
			fprintf (fp_dat, " $%08X $%02X\n", n_trks*8192+i, *(buf+i));
		}

    n_trks++;
  }

  fclose (fp_dat);
  fclose (fp_rtf);
  fclose (fp_dmk);

  fprintf (stderr, "Done (DAT,RTF) %d tracks!\n", n_trks);
}
