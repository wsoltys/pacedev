#include <stdio.h>
#include <stdlib.h>

unsigned char mem[64*1024];

int main (int argc, char *argv[])
{
	FILE *fp;
	unsigned short int load, len;
	
	fp = fopen (argv[1], "rb");
	if (!fp) exit (0);
	fread (&load, sizeof(unsigned short int), 1, fp);
	fread (&len, sizeof(unsigned short int), 1, fp);

	// read into memory
	fread (&mem[load], len, 1, fp);
	
	fclose (fp);
	
	printf ("load = $%04X\n", load);
	printf (" len = $%04X (%d)\n", len, len);
	
	// dump the ram0
	fp = fopen("ram0.bin", "wb");
	fwrite (&mem[0], 0x2000, 1, fp);
	fclose (fp);
	
	// dump the hgr
	fp = fopen("hgr.bin", "wb");
	fwrite (&mem[0x2000], 0x4000, 1, fp);
	fclose (fp);
	
	// dump the ram6
	fp = fopen("ram6.bin", "wb");
	fwrite (&mem[0x6000], 0x2000, 1, fp);
	fclose (fp);
}

