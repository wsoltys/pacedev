#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>

void usage (char *argv0)
{
  if (strrchr (argv0, '/'))
    argv0 = strrchr (argv0, '/') + 1;

  printf ("usage: %s [options] [input filename]\n", argv0);
  printf ("  options:\n");
  printf ("  input defaults to stdin\n");
  printf ("  output always to stdout\n");
  exit (0);
}

int main (int argc, char *argv[])
{
  FILE *fp = stdin;
  char fname[64];

  *fname = '\0';
  while (--argc) {
    switch (argv[argc][0]) {
    case '-' :
    case '/' :
      switch (tolower (argv[argc][1])) {
      case 'b' :
				//base_addr = ahtoi (&argv[argc][2]);
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

	setmode (fileno (stdout), O_BINARY);

  static unsigned char buf[2];
  int rd;
  rd = fread (buf, sizeof(unsigned char), 2, fp);
  while (rd > 0 || !feof (fp)) 
  {
  	fwrite (&buf[1], 1, 1, stdout);
  	fwrite (&buf[0], 1, 1, stdout);
  	
    rd = fread (buf, sizeof(unsigned char), 2, fp);
	}
	
}
