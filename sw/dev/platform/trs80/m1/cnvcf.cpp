#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int isblank_s (unsigned short int *buf)
{
  for (int i=0; i<256; i++)
    if (buf[i] != 0)
      return (0);

  return (1);
}

void dump (unsigned short int *buf)
{
  char ascii[17];
  ascii[17] = '\0';

  for (int i=0; i<256; i++)
  {
    fprintf (stderr, "%04X ", buf[i]);
    sprintf (&ascii[(i%8)<<1], "%c", (isprint(buf[i]>>8) ? buf[i]>>8 : '.'));
    sprintf (&ascii[((i%8)<<1)+1], "%c", (isprint(buf[i]&0xFF) ? buf[i]&0xFF : '.'));
    if (i%8 == 7) printf ("| %s\n", ascii);
  }
}

int main (int argc, char *argv[])
{
  FILE *fpin = fopen ("trs80cf.dsk", "rb");
  FILE *fpout = fopen ("trs80cf_mmc.bin", "wb");

  int from_c = 3884;
  int from_h = 16;
  int from_s = 63;

  int to_c = 980;
  int to_h = 16;
  int to_s = 32;

  int use_c = 5*170;
  int use_h = 8;
  int use_s = 32;

  unsigned long from_size = from_c * from_h * from_s * 512L;
  unsigned long to_size = to_c * to_h * to_s * 512L;
  unsigned long use_size = use_c * use_h * use_s * 512L;

  fprintf (stderr, "from: C,H,S=%d,%d,%d (%ld)\n", from_c, from_h, from_s, from_size);
  fprintf (stderr, "  to: C,H,S=%d,%d,%d (%ld)\n", to_c, to_h, to_s, to_size);
  fprintf (stderr, " use: C,H,S=%d,%d,%d (%ld)\n", use_c, use_h, use_s, use_size);

  if (use_c > from_c || use_c > to_c || use_h > from_h || use_h > to_h || use_s > from_s || use_s > to_s)
  {
    fprintf (stderr, "Invalid parameters!\n");
  }

  int max_c = (from_c > to_c ? from_c : to_c);
  int max_h = (from_h > to_h ? from_h : to_h);
  int max_s = (from_s > to_s ? from_s : to_s);

#if 0
  // check the source for data where we're not expecting it
  for (int c=0; c<from_c; c++)
  {
    for (int h=0; h<from_h; h++)
    {
      for (int s=0; s<from_s; s++)
      {
        unsigned short int buf[256];

        // read sector
        fread (buf, 2, 256, fpin);

        // are we interested?
        if (c >= use_c || h >= use_h || s >= use_s)
          if (!isblank_s(buf))
          {
            unsigned offset = (c*from_h*from_s + h*from_s + s) * 512L;

            fprintf (stderr, "unexpected data in C,H,S=%d,%d,%d\n", c, h, s);
            fprintf (stderr, "file offset = %ld ($%lX) lba=%ld\n", offset, offset, offset/512);
            dump (buf);
            exit (0);
          }
      }
    }
  }
#endif

  fseek (fpin, 0L, SEEK_SET);
  unsigned short int zero[256];
  memset ((unsigned char *)zero, 0, 512);

  // now copy...
  for (int c=0; c<max_c; c++)
  {
    for (int h=0; h<max_h; h++)
    {
      for (int s=0; s<max_s; s++)
      {
        unsigned short int buf[256];

        // read sector
        if (c < from_c && h < from_h && s < from_s)
          fread (buf, 2, 256, fpin);

        // do we need to copy it?
        if (c < use_c && h < use_h && s < use_s)
          fwrite (buf, 2, 256, fpout);
        else
        if (c < to_c && h < to_h && s < to_s)
          fwrite (zero, 2, 256, fpout);
      }
    }
  }

  fclose (fpout);
  fclose (fpin);
}
