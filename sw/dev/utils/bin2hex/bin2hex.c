#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 16

void usage (char *argv0)
{
  if (strrchr (argv0, '/'))
    argv0 = strrchr (argv0, '/') + 1;

  printf ("usage: %s [options] [input filename]\n", argv0);
  printf ("  options:\n");
  printf ("    -b<nnnn>  base address (hex)\n");
  printf ("    -t<nnnn>  transfer address (hex)\n");
  printf ("  input defaults to stdin\n");
  printf ("  output always to stdout\n");
  exit (0);
}

unsigned int ahtoi (char *buf)
{
  unsigned int value = 0;

  while (*buf && !isspace(*buf)) {
    value <<= 4;
    if (isdigit (*buf))
      value += (*buf) - '0';
    else
      value += (tolower(*buf)) - 'a' + 10;
    buf++;
  }

  return (value);
}

int main (int argc, char *argv[])
{
  static unsigned char buf[BUFSIZE];
  FILE *fp = stdin;
  char fname[64];
  int rd;
  int i;
  unsigned int base_addr = 0x0000;
  unsigned int xfer_addr = 0x0000;
	bool xfer_spec = false;
  unsigned char CRC;

  *fname = '\0';
  while (--argc) {
    switch (argv[argc][0]) {
    case '-' :
    case '/' :
      switch (tolower (argv[argc][1])) {
      case 'b' :
				base_addr = ahtoi (&argv[argc][2]);
				break;
      case 't' :
				xfer_addr = ahtoi (&argv[argc][2]);
				xfer_spec = true;
				break;
      default :
				usage (argv[0]);
      }
      	break;
    default :
      strcpy (fname, argv[argc]);
      break;
    }
  }

  if (*fname)
    fp = fopen (fname, "rb");
  if (!fp )
    exit (1);

	memset (buf, 0, BUFSIZE);
  rd = fread (buf, sizeof(unsigned char), BUFSIZE, fp);
  while (rd > 0 || !feof (fp)) {

    printf (":%02X%04X00", BUFSIZE, base_addr);
    CRC = BUFSIZE;
    CRC += (base_addr >> 8) & 0xff;
    CRC += base_addr & 0xff;

    for (i=0; i<BUFSIZE; i++) {
      printf ("%02X", buf[i]);
      CRC += buf[i];
    }

    CRC = 0x100 - (CRC & 0xff);
    printf ("%02X\n", CRC);
    base_addr += rd;

		memset (buf, 0, BUFSIZE);
    rd = fread (buf, sizeof(unsigned char), BUFSIZE, fp);
  }

  CRC = (xfer_addr >> 8) & 0xff;
  CRC += xfer_addr & 0xff;
  CRC += 0x03;
  CRC = 0x100 - (CRC & 0xff);
	if (xfer_spec)
  	printf (":00%04X03%02X\n", xfer_addr, CRC);

  printf (":00000001FF\n");

  if (*fname)
    fclose (fp);
}
