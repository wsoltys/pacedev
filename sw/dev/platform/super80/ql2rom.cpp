#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char 			uint8_t;
typedef unsigned short int 	uint16_t;

static uint8_t	buf[64*1024];

void usage (char *exe)
{
	printf ("usage: %s <infile>[.bin]\n", exe);
	
	exit (0);
}

int main (int argc, char *argv[])
{
	char	infile[128] = "";
	char	outfile[128] = "";
	
	while (--argc)
	{
		switch (argv[argc][0])
		{
			case '/' :
			case '-' :
				break;
				
			default :
				strcpy (infile, argv[argc]);
				break;
		}
	}

	if (*infile == 0)
		usage (argv[0]);
		
	strcpy (outfile, infile);
		
	if (!strchr (infile, '.'))
		strcat (infile, ".bin");

	char *p = NULL;
	if ((p = strchr (outfile, '.')))
		*p = '\0';
	strcat (outfile, ".rom");

	fprintf (stderr, "\"%s\"->\"%s\"\n",
						infile, outfile);

	FILE *fpin = fopen (infile, "rb");
	if (!fpin)
		exit (0);
		
	FILE *fpout = fopen (outfile, "wb");
	if (!fpout)
		exit (0);

	char image_name[128];
	char c;
	unsigned i = 0;
	fseek (fpin, 7, SEEK_SET);
	while ((c = fgetc (fpin)) != 0x1A)
	{
		if (feof (fpin))
		{
			fprintf (stderr, "ERROR: unexpected EOF!\n");
			exit (0);
		}
		if (c == '\0')
			continue;
			
		image_name[i++] = c;
	}
	image_name[i] = '\0';

	uint16_t	start, end, exec;
	
	fread (&exec, sizeof(uint16_t), 1, fpin);
	fread (&start, sizeof(uint16_t), 1, fpin);
	fread (&end, sizeof(uint16_t), 1, fpin);
		
	fprintf (stderr, "Image name = \"%s\"\n",
						image_name);
	fprintf (stderr, "$%04X-$%04X $%04X (len=%d)\n",
						start, end, exec, end-start+1);

	uint16_t bytes = fread(&buf[start], 1, end-start+1, fpin);
	
	if (bytes < (end-start+1))
		fprintf (stderr, "WARNING: read %d\%d bytes!\n",
							bytes, end-start+1);

	//fwrite (&buf[start], 1, bytes, fpout);
	memset (buf, '\0', 64*1024);
	fwrite (buf, 1, end+1, fpout);

	bytes = fread (buf, 64*1024, 1, fpin);
	if (bytes || !feof (fpin))
		fprintf (stderr, "WARNING: %d extra data bytes at end of file!\n", bytes);
			
	fclose (fpout);
	fclose (fpin);		
}
