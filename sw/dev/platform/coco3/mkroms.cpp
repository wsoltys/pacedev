#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main (int argc, char *argv[])
{
	FILE *fpin = fopen ("coco3.rom", "rb");
	if (!fpin)
		exit (0);

	int i;
	for (i=0x8000; i<0x10000; i+=0x800)
	{
		unsigned char buf[0x800];

		fread (buf, 1, 0x800, fpin);

		char filename[64];
		sprintf (filename, "CC3_%02X_NODSK.bin", i>>8);
		FILE *fpout = fopen (filename, "wb");
		fwrite (buf, 1, 0x800, fpout);
		fclose (fpout);		

		sprintf (filename, "CC3_%02X_NODSK.v", i>>8);
		fpout = fopen (filename, "wt");

		fprintf (fpout,
							"/*****************************************************************************\n"
							"* 2k 0x%02X00 ROM for CoCo3\n"
							"******************************************************************************/\n",
							i>>8);

		fprintf (fpout,
							"  sprom #(\n"
							"  	.init_file		(\"../../../../src/platform/coco3-becker/roms/cc3_%02X_nodsk.hex\"),\n"
							"  	.numwords_a		(2048),\n"
							"  	.widthad_a		(11)\n"
							"  ) RAMB16_S9_%02X (\n"
							"  	.address			(ADDRESS[10:0]),\n"
							"  	.clock				(PH_2),\n"
							"  	.q						(DOA_%02X)\n"
							"  );\n",
							i>>8, i>>8, i>>8);

		fclose (fpout);
	}

	fclose (fpin);

	fpin = fopen ("disk11.rom", "rb");
	if (!fpin)
		exit (0);

	for (i=0xC000; i<0xE000; i+=0x800)
	{
		unsigned char buf[0x800];

		fread (buf, 1, 0x800, fpin);

		char filename[64];
		sprintf (filename, "DSK_%02X.bin", i>>8);
		FILE *fpout = fopen (filename, "wb");
		fwrite (buf, 1, 0x800, fpout);
		fclose (fpout);		

		sprintf (filename, "DSK_%02X.v", i>>8);
		fpout = fopen (filename, "wt");

		fprintf (fpout,
							"/*****************************************************************************\n"
							"* 2k 0x%02X00 DISK ROM for CoCo3\n"
							"******************************************************************************/\n",
							i>>8);

		fprintf (fpout,
							"  sprom #(\n"
							"  	.init_file		(\"../../../../src/platform/coco3-becker/roms/dsk_%02X.hex\"),\n"
							"  	.numwords_a		(2048),\n"
							"  	.widthad_a		(11)\n"
							"  ) RAMB16_S9_D%02X (\n"
							"  	.address			(ADDRESS[10:0]),\n"
							"  	.clock				(PH_2),\n"
							"  	.q						(DOA_D%02X)\n"
							"  );\n",
							i>>8, i>>8, i>>8);

		fclose (fpout);
	}

	fclose (fpin);

	fpin = fopen ("coco3gen.v", "rt");
	if (!fpin)
		exit (0);

	FILE *fpout = fopen ("coco3gen.bin", "wb");
	if (!fpout)
		exit (0);

	unsigned char bin[32];

	while (!feof (fpin))
	{
		char buf[256];
		char *p;

		fgets (buf, 256, fpin);
		if (!(p = strstr(buf, ".INIT_")))
			continue;

		p = strstr (buf, "256'h") + 5;
		for (i=0; i<32; i++)
		{
			unsigned char val = (isdigit(*p) ? *p - '0' : toupper(*p) - 'A' + 10);
			val <<= 4;
			p++;
			val |= (isdigit(*p) ? *p - '0' : toupper(*p) - 'A' + 10);
			p++;
			bin[31-i] = val;
		}

		fwrite (bin, 1, 32, fpout);

	}

	fclose (fpout);
	fclose (fpin);

}
