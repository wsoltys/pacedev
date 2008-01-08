#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void usage (char *argv0)
{
  if (strrchr (argv0, '/'))
    argv0 = strrchr (argv0, '/') + 1;

  printf ("usage: %s [options] [input filename]\n", argv0);
  printf ("  options:\n");
  printf ("    (none)\n");
  printf ("  input defaults to stdin\n");
  printf ("  output always to stdout\n");
  exit (0);
}

#define BUFSIZE 1024

int main (int argc, char *argv[])
{
  static unsigned char buf[BUFSIZE];
  FILE *fp = stdin;
  char fname[64];
  int rd;

  *fname = '\0';
  while (--argc) 
	{
    switch (argv[argc][0])
		{
	    case '-' :
	    case '/' :
				usage (argv[0]);
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

	int n = 0;
  rd = fread (buf, sizeof(unsigned char), 32, fp);
  while (!feof (fp))
	{
		printf ("  INIT_%02X => X\"", n);
    for (int i=0; i<rd; i++)
      printf ("%02X", buf[rd-1-i]);
		printf ("\",\n");

    rd = fread (buf, sizeof(unsigned char), 32, fp);
		n++;
  }

  if (*fname)
    fclose (fp);
}
