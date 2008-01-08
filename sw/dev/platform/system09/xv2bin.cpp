#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//#define VERBOSE

typedef unsigned char byte;

static byte rom[2*1024];

void usage (void)
{
  printf ("xv2bin <file>\n");
  exit (0);
}

int ahtoi (char *buf, int len)
{
  int val = 0;
  while (*buf && len--)
  {
    val <<= 4;
    val += (isdigit(*buf) ? *buf-'0' : *buf-'A'+10);
    buf++;
  }

  return (val);
}

int main (int argc, char *argv[])
{
  if (--argc < 1)
    usage ();

  FILE *fp = fopen (argv[1], "rt");
  if (!fp)
    exit (0);

  int lines = 0;

  char buf[256];
  fgets (buf, 256, fp);
  while (!feof (fp))
  {
    while (1)
    {
      char *p, *q;

      if (!(p = strstr (buf, "=>")))
        break;
      if (!(p = strchr (buf, '\"')))
        break;
      p++;
      if (!(q = strchr (p, '\"')))
        break;
      if ((q-p) != 64)
        break;

      for (int i=0; i<(64/2); i++)
      {
        byte b = ahtoi(p, 2);
        #ifdef VERBOSE
          printf ("%02X ", b);
        #endif
        rom[lines*(64/2)+(64/2)-1-i] = b;
        p += 2;
      }
      #ifdef VERBOSE
        printf ("\n");
      #endif

      //printf (buf);
      lines++;

      break;
    }

    fgets (buf, 256, fp);
  }

  fclose (fp);

  fp = fopen ("xv2bin.out", "wb");
  fwrite (rom, 2*1024, 1, fp);
  fclose (fp);

  printf ("lines = %d\n", lines);
  printf ("bytes = %d\n", lines*(64/2));
  printf ("Done!\n");
}
