#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

static unsigned char hdv_hdr[] =
{
  0x56, 0xCB, 0x11, 0xD5, 0x01, 0x04, 0x00, 0x00,
  0x00, 0x00, 0xFF, 0x00, 0x0C, 0x01, 0x6E, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x03, 0xD4, 0x00, 0x10, 0x01,
  0x54, 0x52, 0x53, 0x38, 0x30, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

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

void usage (char *argv0)
{
  printf ("usage: %s [-b|w] [-U<geom>] [-g<geom>] <infile> [-B|W] [-G<geom>] <outfile> \n", argv0);
  printf ("  options:\n");
  printf ("    -g    source disk geometry (cylinders,heads,sectors)\n");
  printf ("    -b    source is byte data\n");
  printf ("    -w    source is word data\n");
  printf ("    -G    destination disk geometry (cylinders,heads,sectors)\n");
  printf ("    -B    destination is byte data\n");
  printf ("    -W    destination is word data\n");
  printf ("    -U    use disk geometry (cylinders,heads,sectors)\n");
  printf ("  parameters:\n");
  printf ("    <geom> is <c>[,<h>[,<s>]]\n");
  exit (0);
}

int main (int argc, char *argv[])
{
  char  szIn[256], szOut[256];
  
  int nFilespecs = 0;
  int fromByte = -1;
  int toByte = -1;

  unsigned short int zero[256];
  memset ((unsigned char *)zero, 0, 512);

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
    char *p = argv[argc];
    
    switch (argv[argc][0])
    {
      case '/' : case '-' :
        switch (argv[argc][1])
        {
          case 'b' :
            fromByte = 1;
            break;
          case 'B' :
            toByte = 1;
            break;
          case 'g' :
            from_c = atoi(p+2);
            p = strchr(p, '.');
            if (!p) break;
            from_h = atoi(p+1);
            p = strchr(p, '.');
            if (!p) break;
            from_s = atoi(p+1);
            break;
          case 'G' :
            to_c = atoi(p+2);
            p = strchr(p, '.');
            if (!p) break;
            to_h = atoi(p+1);
            p = strchr(p, '.');
            if (!p) break;
            to_s = atoi(p+1);
            break;
          case 'u' :
            use_c = atoi(p+2);
            p = strchr(p, '.');
            if (!p) break;
            use_h = atoi(p+1);
            p = strchr(p, '.');
            if (!p) break;
            use_s = atoi(p+1);
            break;
          case 'w' :
            fromByte = 0;
            break;
          case 'W' :
            toByte = 0;
          default :
            usage (argv[0]);
            break;
        }
        break;
      default :
        if (nFilespecs == 0)
          strcpy (szOut, argv[argc]);
        else if (nFilespecs == 1)
          strcpy (szIn, argv[argc]);
        nFilespecs++;
        break;
    }
  }

#if 0
  {
    FILE *fp = fopen ("hdr.hdv", "rb");
    unsigned char buf[256];
    fread (buf, 1, 256, fp);
    fclose (fp);
    for (int i=0; i<256; i++)
    {
      printf ("0x%02X, ", buf[i]);
      if (i%8 == 7) printf ("\n");
    }
  }
#endif

  if (nFilespecs != 2)
    usage (argv[0]);

  // if width not specified, default to 8 for HDV files
  if (fromByte == -1)
    if (strstr (szIn, ".hdv"))
      fromByte = 1;
    else
      fromByte = 0;

  // if width not specified, default to 8 for HDV files
  if (toByte == -1)
    if (strstr (szOut, ".hdv"))
      toByte = 1;
    else
      toByte = 0;  

  unsigned long from_size = from_c * from_h * from_s * 512L;
  unsigned long to_size = to_c * to_h * to_s * 512L;
  unsigned long use_size = use_c * use_h * use_s * 512L;

  if (fromByte) from_size /= 2;
  if (toByte) to_size /= 2;
  if (fromByte) use_size /= 2;
  
  fprintf (stderr, "from: %-16.16s C,H,S=%d,%d,%d (%ld) (%c)\n", 
            szIn, from_c, from_h, from_s, from_size, (fromByte ? 'b' : 'w'));
  fprintf (stderr, "  to: %-16.16s C,H,S=%d,%d,%d (%ld) (%c)\n", 
            szOut, to_c, to_h, to_s, to_size, (toByte ? 'B' : 'W'));
  fprintf (stderr, " use: %-16.16s C,H,S=%d,%d,%d (%ld)\n", 
            "", use_c, use_h, use_s, use_size);

  if (use_c > from_c || use_c > to_c || use_h > from_h || use_h > to_h || use_s > from_s || use_s > to_s)
  {
    fprintf (stderr, "Invalid parameters!\n");
    exit (0);
  }

  FILE *fpin = fopen (szIn, "rb");
  if (!fpin)
  {
    printf ("error opening input \"%s\"!\n", szIn);
    exit (0);
  }
  
  FILE *fpout = fopen (szOut, "wb");
  if (!fpout)
  {
    printf ("error opening output \"%s\"!\n", szOut);
    exit (0);
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
  if (strstr (szIn, ".hdv"))
    fseek (fpin, 256L, SEEK_CUR);

  // add a header to virtual hard drive images
  if (strstr(szOut, ".hdv"))
    fwrite (hdv_hdr, 1, 256, fpout);
    
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
}
