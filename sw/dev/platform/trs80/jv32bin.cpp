#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>

typedef struct {
  unsigned char track;
  unsigned char sector;
  unsigned char flags;
} SectorHeader;

#define NUM_TRACKS      40
#define NUM_SECTS       18
unsigned long int       diskinfo[NUM_TRACKS][NUM_SECTS];

#define JV3_DENSITY     0x80  /* 1=dden, 0=sden */
#define JV3_DAM         0x60  /* data address mark code; see below */
#define JV3_SIDE        0x10  /* 0=side 0, 1=side 1 */
#define JV3_ERROR       0x08  /* 0=ok, 1=CRC error */
#define JV3_NONIBM      0x04  /* 0=normal, 1=short */
#define JV3_SIZE        0x03  /* in used sectors: 0=256,1=128,2=1024,3=512
                                 in free sectors: 0=512,1=1024,2=128,3=256 */

#define JV3_FREE        0xFF  /* in track and sector fields of free sectors */
#define JV3_FREEF       0xFC  /* in flags field, or'd with size code */

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

    int trk = 0;
    unsigned long int sec_mask = 0L;

    unsigned int hdr_size = 2901 * sizeof(SectorHeader) + sizeof(unsigned char);
    printf ("header = %d ($%X) bytes\n", hdr_size, hdr_size);

	for (int i=0; i<2901; i++)
	{
		SectorHeader sh;
		fread (&sh, 1, sizeof(SectorHeader), fp);

        if (trk != 255 && sh.track != trk)
        {
            int secs;
            if (sec_mask == (1<<18)-1)
                secs = 18;
            else
            if (sec_mask == (1<<10)-1)
                secs = 10;
            else
                secs = -1;

            if (secs == -1)
                printf ("trk = %02d, secflag = $%06X\n", trk, sec_mask);
            else
                printf ("trk = %02d, secs = %02d\n", trk, secs);

            sec_mask = 0L;
        }
        trk = sh.track;

		if (sh.track == 255)
			continue;

        if (sh.track < NUM_TRACKS && sh.sector < NUM_SECTS)
            diskinfo[sh.track][sh.sector] = hdr_size + (unsigned long int)i*256L;

        sec_mask |= (1<<(sh.sector));

#if 1
		printf ("TRK=%02d, SEC=%02d, flags=$%02X (",
				sh.track, sh.sector, sh.flags);
		if (sh.flags & JV3_DENSITY) printf ("JV3_DENSITY,");
		if (sh.flags & JV3_DAM) printf ("JV3_DAM (%X),", sh.flags & JV3_DAM);
		if (sh.flags & JV3_SIDE) printf ("JV3_SIDE,");
		if (sh.flags & JV3_ERROR) printf ("JV3_ERROR,");
		if (sh.flags & JV3_NONIBM) printf ("JV3_NONIBM,");
		printf ("%s)\n", (sh.flags ? "\b" : ""));
#endif
	}

    unsigned char wp;
    fread (&wp, 1, 1, fp);
    printf ("wp = $%02X\n", wp);

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
              fseek (fp, diskinfo[t][s], SEEK_SET);
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
