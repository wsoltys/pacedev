#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main (int argc, char *argv[])
{
	FILE *fp = fopen ("dkong.bin", "rb");
	if (!fp) 
	{
		fprintf (stderr, "unable to open input file!\n");
		exit (1);
	}
	FILE *fp2 = fopen ("dkascii.bin", "wb");
	
	uint8_t	byte;
	
	fread (&byte, 1, 1, fp);
	while (!feof (fp))
	{
		fread (&byte, 1, 1, fp);
		byte += 0x30;
		fwrite (&byte, 1, 1, fp2);
	}
	
	fclose (fp2);
	fclose (fp);
}
