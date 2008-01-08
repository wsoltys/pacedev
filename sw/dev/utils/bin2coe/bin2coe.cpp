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
  printf ("    -w{8|16|32}  memory width (default=8)\n");
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
	int width = 8;

  *fname = '\0';
  while (--argc) 
	{
    switch (argv[argc][0])
		{
	    case '-' :
	    case '/' :
				switch (tolower(argv[argc][1]))
				{
					case 'w' :
						width = atoi(&argv[argc][2]);
						break;
					default :
						usage (argv[0]);
						break;
				}
    		break;
    	default :
	      strcpy (fname, argv[argc]);
	      break;
    }
  }

	if (width != 8 && width != 16 && width != 32)
		usage (argv[0]);

  if (*fname)
    fp = fopen (fname, "rb");
  if (!fp )
    exit (1);

	printf ("memory_initialization_radix=16;\n");
	printf ("memory_initialization_vector=\n");

  rd = fread (buf, sizeof(unsigned char), width/8, fp);
	bool first_byte = true;
  while (!feof (fp))
	{
		if (!first_byte)
			printf (",\n");
		first_byte = false;
		for (int i=0; i<width/8; i++)
			printf ("%02X", buf[i]);

    rd = fread (buf, sizeof(unsigned char), width/8, fp);
  }
	printf (";\n");

  if (*fname)
    fclose (fp);
}
