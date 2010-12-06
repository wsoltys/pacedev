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
  int fromByte = 0;
  int toByte = 0;

  unsigned short int zero[256];
  memset ((unsigned char *)zero, 0, 512);

#if 0

  FILE *fpout = fopen ("hdd_repaired.bin", "wb");
  FILE *fpin;

  // use the 1st partition from the pre-image
  fpin = fopen ("ldos_8bit_980.8.32_5x170.bin", "rb");
  for (int i=0; i<1*170*8*32; i++)
  {
    unsigned char buf[512];
    fread (buf, 2, 256, fpin);
    for (int j=0; j<256; j++)
    {
      fwrite (&buf[j], 1, 1, fpout);
      fwrite (&zero, 1, 1, fpout);
    }
  }
  fclose (fpin);

  // now use the rest from the new image
  fpin = fopen ("hdd_pb.bin", "rb");
  fseek (fpin, 1*170*8*32L, SEEK_SET);
  for (int i=0; i<4*170*8*32; i++)
  {
    unsigned char buf[512];
    fread (buf, 2, 256, fpin);
    fwrite (buf, 2, 256, fpout);
  }
  fclose (fpin);

  fclose (fpout);

#else

  //FILE *fpin = fopen ("trs80cf.dsk", "rb");
  //FILE *fpout = fopen ("trs80cf_mmc.bin", "wb");

  FILE *fpin = fopen ("hdd_pb.hdv", "rb");
  FILE *fpout = fopen ("hdd_pb.bin", "wb");

  int from_c = 980; //3884;
  int from_h = 8; //16;
  int from_s = 32; //63;

  int to_c = 980;
  int to_h = 8; //16;
  int to_s = 32;

  int use_c = 5*170;
  int use_h = 8;
  int use_s = 32;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '/' : case '-' :
        switch (tolower(argv[argc][1]))
        {
          case 'b' :
            fromByte = 1;
            break;
          case 'B' :
            toByte = 1;
            break;
          default :
            break;
        }
        break;
      default :
        break;
    }
  }

  unsigned long from_size = from_c * from_h * from_s * 512L;
  unsigned long to_size = to_c * to_h * to_s * 512L;
  unsigned long use_size = use_c * use_h * use_s * 512L;

  if (fromByte) from_size /= 2;
  if (toByte) to_size /= 2;

  fprintf (stderr, "from: C,H,S=%d,%d,%d (%ld) (%c)\n", from_c, from_h, from_s, from_size, (fromByte ? 'b' : 'w'));
  fprintf (stderr, "  to: C,H,S=%d,%d,%d (%ld) (%c)\n", to_c, to_h, to_s, to_size, (toByte ? 'B' : 'W'));
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
        unsigned char buf[512];

        // read sector
        if (fromByte)
        {
          for (int i=0; i<256; i++)
          {
            fread (&buf[i<<1], 1, 1, fpin);
            buf[(i<<1)+1] = 0;
          }
        }
        else
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
  // skip header on virtual hard drive images
  fseek (fpin, 256L, SEEK_CUR);

  // now copy...
  for (int c=0; c<max_c; c++)
  {
    for (int h=0; h<max_h; h++)
    {
      for (int s=0; s<max_s; s++)
      {
        unsigned char buf[512];

        // read sector
        if (c < from_c && h < from_h && s < from_s)
        {
          if (fromByte)
          {
            for (int i=0; i<256; i++)
            {
              fread (&buf[i<<1], 1, 1, fpin);
              buf[(i<<1)+1] = 0;
            }
          }
          else
            fread (buf, 2, 256, fpin);
        }

        // do we need to copy it?
        if (c < use_c && h < use_h && s < use_s)
        {
          if (toByte)
          {
            // only write every 2nd byte
            for (int i=0; i<256; i++)
              fwrite (&buf[i<<1], 1, 1, fpout);
          }
          else
            fwrite (buf, (toByte ? 1 : 2), 256, fpout);
        }
        else
        if (c < to_c && h < to_h && s < to_s)
          fwrite (zero, (toByte ? 1 : 2), 256, fpout);
      }
    }
  }

  fclose (fpout);
  fclose (fpin);

#endif
}
