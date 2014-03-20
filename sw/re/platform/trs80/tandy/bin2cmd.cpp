#include <ctype.h>
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

static void usage (char *argv0)
{
	fprintf (stderr, "usage: %s -o<addr> -x<addr> <file>[.bin]\n", argv0);
	fprintf (stderr, "  options:\n");
	fprintf (stderr, "    -o<addr>    origin\n");
	fprintf (stderr, "    -x<addr>    execute addr\n");
	
	exit (1);
}

static unsigned ahextol (char *buf)
{
	unsigned val = 0;
	
	for (; *buf; buf++)
		if (isdigit (*buf))
			val = (val << 4) + *buf - '0';
		else if (isalpha (*buf))
			val = (val << 4) + tolower(*buf) - 'a' + 10;
		else break;
		
	return (val);
}

int main (int argc, char *argv[])
{
  FILE    *fpin, *fpout;
  int     i;
  int     len;
  int     blocks;
  int     addr;

	int origin = -1;
	int exec = -1;
	char infile[64] = "";
	char outfile[64];
			
	while (--argc)
	{
		switch (argv[argc][0])
		{
			case '-' :
			case '/' :
				switch (tolower (argv[argc][1]))
				{
					case 'o' :
						origin = ahextol(&argv[argc][2]);
						break;
					case 'x' :
						exec = ahextol(&argv[argc][2]);
						break;
					default :
						usage (argv[0]);
						break;
				}
				break;
			default :
				strcpy (infile, argv[argc]);
				break;					
		}
	}
  
  if (*infile == '\0' || origin == -1 | exec == -1)
    usage (argv[0]);

	strcpy (outfile, infile);
	if (!strrchr (infile, '.'))
		strcat (infile, ".bin");
	if (strrchr (outfile, '.'))
		*strchr (outfile, '.') = '\0';
	strcat (outfile, ".cmd");

	fprintf (stderr, "\"%s\"->\"%s\" o=0x%04X x=0x%04X\n",
						infile, outfile, origin, exec);
	
  if ((fpin = fopen(infile, "rb") ) == NULL )
  {
    fprintf(stderr, "Can't open input file %s\n", infile);
    exit (2);
  }

	// get file size
  if (fseek (fpin,0,SEEK_END))
  {
      fclose(fpin);
      fprintf (stderr, "Couldn't determine size of file\n");
      exit (2);
  }
  len = ftell (fpin);
  fseek (fpin, 0L, SEEK_SET);
  blocks = len / 254;

	// create CMD file
	
  if ((fpout = fopen (outfile, "wb")) == NULL) 
  {
    fprintf (stderr,"Can't open output CMD file %s\n", outfile);
    exit (2);
	}

	char buf[5];
  		
  addr = origin;
  for (i=0; i<len; i++)
  {
  	if ((i%254) == 0) 
  	{
  		// block len = 256, signature, last block len
  		buf[0] = 0; buf[1] = 1; buf[2] = len-i+2;
  		buf[3] = (addr+i) & 0xFF; buf[4] = (addr+i) >> 8;
  		
      fwrite (&buf[1], 1, 1, fpout);	/* Signature byte */
      if (i+254 > len)
        fwrite (&buf[2], 1, 1, fpout);	/* last block length (remainder) */
	    else
        fwrite (&buf[0], 1, 1, fpout);		/* block length (256 bytes) */
    
	    fwrite (&buf[3], 2, 1, fpout);	/* block memory location */
  	}

		fread (buf, 1, 1, fpin);
		fwrite (buf, 1, 1, fpout);
  }

	buf[0] = 2;
	buf[1] = 2;
	buf[2] = exec & 0xFF;
	buf[3] = exec >> 8;
	fwrite (buf, 1, 4, fpout);

  fclose (fpin);
  fclose (fpout);
}
