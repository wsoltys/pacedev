#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void usage (char *argv0)
{
  char *p = strrchr (argv0, ',');
  if (!p) p = argv0;

  fprintf (stderr, "usage %s [-8] [-r] [-f] <filename>[.D64]\n", p);
  fprintf (stderr, "  options:\n");
  fprintf (stderr, "    -8    output 8KB/track binary GCR image (use with -r)\n");
  fprintf (stderr, "    -f    fill non-directory sectors with a pattern\n");
  fprintf (stderr, "    -r    produce raw G64 output (chrisn)\n");
  exit (0);
}

void dump (FILE *fp, unsigned char *buf, int n)
{
  int i;
  char ascii[16+1];

  ascii[16] = '\0';
  for (i=0; i<n; i++)
  {
    if (i%16 == 0) fprintf (fp, "  ");
    fprintf (fp, "0x%02X, ", buf[i]);
    ascii[i%16] = (isprint(buf[i]) ? buf[i] : '.');
    if (i%16 == 15) fprintf (fp, "  // |%16.16s|\n", ascii);
  }
  if (i%16 != 0)
  {
    for (int j=0; j<16-(i%16); j++)
    {
      fprintf (fp, "      ");
      ascii[15-j] = ' ';
    }
    fprintf (fp, "  // |%16.16s|\n", ascii);
  }
}

typedef unsigned char alt_u8;

typedef struct
{
	int motor, frequency;

	int clock;
	double track;

	struct {
		alt_u8 data[(1+2+2+1+256/4+4)*5];
		int sync;
		int ready;
		int ffcount;
	} head;

	struct {
		int pos; /* position  in sector */
		int sector;
		alt_u8 *data;
	} d64;

} CBM_Drive_Emu;
static CBM_Drive_Emu vc1541_static = { 0 }, *vc1541 = &vc1541_static;

static int bin_2_gcr[] =
{
	0xa, 0xb, 0x12, 0x13, 0xe, 0xf, 0x16, 0x17,
	9, 0x19, 0x1a, 0x1b, 0xd, 0x1d, 0x1e, 0x15
};

static void gcr_double_2_gcr(alt_u8 a, alt_u8 b, alt_u8 c, alt_u8 d, alt_u8 *dest)
{
	alt_u8 gcr[8];
	gcr[0]=bin_2_gcr[a>>4];
	gcr[1]=bin_2_gcr[a&0xf];
	gcr[2]=bin_2_gcr[b>>4];
	gcr[3]=bin_2_gcr[b&0xf];
	gcr[4]=bin_2_gcr[c>>4];
	gcr[5]=bin_2_gcr[c&0xf];
	gcr[6]=bin_2_gcr[d>>4];
	gcr[7]=bin_2_gcr[d&0xf];
	dest[0]=(gcr[0]<<3)|(gcr[1]>>2);
	dest[1]=(gcr[1]<<6)|(gcr[2]<<1)|(gcr[3]>>4);
	dest[2]=(gcr[3]<<4)|(gcr[4]>>1);
	dest[3]=(gcr[4]<<7)|(gcr[5]<<2)|(gcr[6]>>3);
	dest[4]=(gcr[6]<<5)|gcr[7];
}

static struct {
	int count;
	int data[4];
} gcr_helper;

static void vc1541_sector_start(void)
{
	gcr_helper.count=0;
}

static void vc1541_sector_data(alt_u8 data, int *pos)
{
	gcr_helper.data[gcr_helper.count++]=data;
	if (gcr_helper.count==4) {
		gcr_double_2_gcr(gcr_helper.data[0], gcr_helper.data[1],
						 gcr_helper.data[2], gcr_helper.data[3],
						 vc1541->head.data+*pos);
		*pos=*pos+5;
		gcr_helper.count=0;
	}
}

static void vc1541_sector_end(int *pos)
{
	//assert(gcr_helper.count==0);
}

#define D64_SECTOR_WRITELEN ((1+2+2+1+256/4+4)*5)

#define D64_MAX_TRACKS 35
int d64_sectors_per_track[D64_MAX_TRACKS] =
{
	21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
	19, 19, 19, 19, 19, 19, 19,
	18, 18, 18, 18, 18, 18,
	17, 17, 17, 17, 17
};
#define D64_MAX_RAW_TRACKS 85
int d64_raw_sectors_per_track[D64_MAX_RAW_TRACKS] =
{
	21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
	21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
	19, 19, 19, 19, 19, 19, 19,
	19, 19, 19, 19, 19, 19, 19,
	18, 18, 18, 18, 18, 18,
	18, 18, 18, 18, 18, 18,
	17, 17, 17, 17, 17,	17, 17, 17, 17, 17,
	17, 17, 17, 17, 17,	17, 17, 17, 17, 17,
	17, 17, 17, 17
};
static int d64_offset[D64_MAX_TRACKS];		   /* offset of begin of track in d64 file */
void cbm_drive_open_helper (void)
{
	int i;

	d64_offset[0] = 0;
	for (i = 1; i <= 35; i++)
		d64_offset[i] = d64_offset[i - 1] + d64_sectors_per_track[i - 1] * 256;
}
int d64_tracksector2offset (int track, int sector)
{
	return d64_offset[track - 1] + sector * 256;
}
#define D64_TRACK_ID1   (d64_tracksector2offset(18,0)+162)
#define D64_TRACK_ID2   (d64_tracksector2offset(18,0)+163)

static void vc1541_sector_to_gcr(int track, int sector)
{
	int i=0, j, offset, chksum=0;

	if (vc1541->d64.data==NULL) return;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541_sector_start();

	vc1541_sector_data(8, &i);
	chksum= sector^track
		^vc1541->d64.data[D64_TRACK_ID1]^vc1541->d64.data[D64_TRACK_ID2];
	vc1541_sector_data(chksum, &i);
	vc1541_sector_data(sector, &i);
	vc1541_sector_data(track, &i);
	vc1541_sector_data(vc1541->d64.data[D64_TRACK_ID1], &i);
	vc1541_sector_data(vc1541->d64.data[D64_TRACK_ID2], &i);
	vc1541_sector_data(0xf, &i);
	vc1541_sector_data(0xf, &i);
	vc1541_sector_end(&i);

	/* 5 - 10 gcr bytes cap */
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541->head.data[i++]=0xff;
	vc1541_sector_data(0x7, &i);

	chksum=0;
	for (offset=d64_tracksector2offset(track,sector), j=0; j<256; j++) {
		chksum^=vc1541->d64.data[offset];
		vc1541_sector_data(vc1541->d64.data[offset++], &i);
	}
	vc1541_sector_data(chksum, &i);
	vc1541_sector_data(0, &i); /* padding up */
	vc1541_sector_data(0, &i);
	vc1541_sector_end(&i);
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
	gcr_double_2_gcr(0, 0, 0, 0, vc1541->head.data+i);i+=5;
}

unsigned char d64_image[174848];

int main (int argc, char *argv[])
{
  unsigned char sectbuf[512];
  int tracks;
  int raw_disk = 0;
  int fill = 0;
  int eightKB = 0;
  int argc_f = -1;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' :
      case '/' :
        switch (tolower (argv[argc][1]))
        {
          case '8' :
  		      eightKB = 1;
            break;
          case 'f' :
  		      fill = 1;
            break;
          case 'r' :
  		      raw_disk = 1;
            break;
          default :
            usage (argv[0]);
            break;
        }
        break;

      default :
        argc_f = argc;
        break;
    }
  }

  if (argc_f < 0)
    usage (argv[0]);

  cbm_drive_open_helper ();

  FILE *fp = fopen (argv[argc_f], "rb");
  if (!fp) exit (0);

  // read an image for the GCR encoding
  fread (d64_image, 1, 174848, fp);
  fseek (fp, 0, SEEK_SET);
  vc1541->d64.data = d64_image;

  char g64_filename[64];
  char *p;
  strcpy (g64_filename, argv[argc_f]);
  if ((p = strrchr (g64_filename, '.')) != NULL)
    *p = '\0';
  strcat (g64_filename, ".g64.bin");
  FILE *fp_g64 = fopen (g64_filename, "wb");
  FILE *fp_g64_c = fopen ("g64_data.c", "wt");

  printf ("#ifdef _IS_INCLUDED_\n\n");

  // start creating the file

  printf ("//\n// %s\n//\n\n", argv[argc_f]);

  printf ("unsigned char d64_data[] = \n"
          "{\n");

	if(raw_disk)
		tracks = D64_MAX_RAW_TRACKS;
	else
		tracks = D64_MAX_TRACKS;

  if (eightKB)
  {
    unsigned char ff = '\xff';
    // fill an extra track at the start
    for (int i=0; i<8192; i++)
      fwrite (&ff, 1, 1, fp_g64);
  }

  for (int t=0; t<tracks; t++)
  {
  	int sectors_per_track = raw_disk ? d64_raw_sectors_per_track[t] : d64_sectors_per_track[t];
    for (int s=0; s<sectors_per_track; s++)
    {
      printf ("  // TRACK %d, SECTOR %d\n", t+1, s);

      int n;
      
      // If this is a real track, read data from disk
      if((!raw_disk || (t & 1) == 1) && (t < (2*D64_MAX_TRACKS+1))) {
      	memset(vc1541->head.data, 0x00, D64_SECTOR_WRITELEN);
      	n = fread (sectbuf, 1, 256, fp);
        if (fill && (t+1) != 18)
        {
          for (int i=0; i<128; i++)
          {
            sectbuf[i*2] = t+1;
            sectbuf[i*2+1] = s;
          }
        }
	      dump (stdout, (unsigned char *)&sectbuf, n);
	      printf ("\n");
	      vc1541_sector_to_gcr (raw_disk ? t/2 + 1 : t+1, s);
	      
	    // Otherwise generate dummy data
  	  }
      else
      	memset(vc1541->head.data, 0x00, D64_SECTOR_WRITELEN);

      fwrite (vc1541->head.data, 1, D64_SECTOR_WRITELEN, fp_g64);
  
      fprintf (fp_g64_c, "  // TRACK %d, SECTOR %d\n", t+1, s);
      dump (fp_g64_c, (unsigned char *)vc1541->head.data, D64_SECTOR_WRITELEN);
      fprintf (fp_g64_c, "\n");

      // fill end of track on "-8" option
      if (eightKB && s == sectors_per_track-1)
      {
        for (int i=0; i<8192-(sectors_per_track*D64_SECTOR_WRITELEN); i++)
        {
          unsigned char ff = 0xff;
          fwrite (&ff, 1, 1, fp_g64);
        }
      }
    }
  }

  printf ("};\n");

  printf ("\n#endif // _IS_INCLUDED\n");

  if (eightKB)
  {
    unsigned char ff = '\xff';
    // fill an extra track at the start
    for (int i=0; i<(1024*1024)-((tracks+1)*8192); i++)
      fwrite (&ff, 1, 1, fp_g64);
  }

  int n = fread (&sectbuf, 1, 1, fp);
  if (!feof (fp) || n != 0)
    fprintf (stderr, "WARNING: not EOF (%d bytes remain)\n", n);

  fclose (fp_g64_c);
  fclose (fp_g64);
  fclose (fp);

  fprintf (stderr, "Done!\n");
}
