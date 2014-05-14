#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>

int main (int argc, char *argv[])
{
	struct stat	fs;
	int					fd;

	FILE *fp = fopen ("level.dat", "rb");
  if (!fp)
  	exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);

	// expecting 150 sectors
	if (fs.st_size != 150*256)
		exit (0);

	for (int l=0; l<150; l++)
	{
		uint8_t		buf[256];
		
		fread (buf, 1, 256, fp);
		printf ("; level %03d\n\n", l+1);
		for (int r=0; r<16; r++)
		{
			printf ("  .db   ");
			for (int c=0; c<14; c++)
			{
				printf ("0x%02X", buf[r*14+c]);
				if (c < 13)
					printf (", ");
			}
			printf ("\n");
		}
		printf ("\n");
		for (int i=14*16; i<256; i++)
		{
			if (i%14 == 0) printf ("  .db   ");
			printf ("0x%02X", buf[i]);
			if (i%14 != 13 && i<255)
				printf (", ");
			else
				printf ("\n");
		}
		printf ("\n");
	}			
	fclose (fp);
	
	fprintf (stderr, "done!\n");
}
