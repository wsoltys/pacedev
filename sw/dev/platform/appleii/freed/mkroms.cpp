#include <stdio.h>
#include <stdlib.h>

unsigned char rom[20*1024];

int main (int argc, char *argv[])
{
	FILE *fp = fopen ("myflash.rom", "rb");
	fread (rom, 1, 20*1024, fp);
	fclose (fp);

	fp = fopen ("c6.bin", "wb");
	fwrite (rom+0x600, 1, 256, fp);
	fclose (fp);

	fp = fopen ("d0.bin", "wb");
	fwrite (rom+0x2000, 1, 0x1000, fp);
	fclose (fp);
	fp = fopen ("e0.bin", "wb");
	fwrite (rom+0x3000, 1, 0x1000, fp);
	fclose (fp);
	fp = fopen ("f0.bin", "wb");
	fwrite (rom+0x4000, 1, 0x1000, fp);
	fclose (fp);

}
