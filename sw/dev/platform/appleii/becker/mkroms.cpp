#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static unsigned char rom[8192+8192];

static int v2bin (char *vfile, char *binfile)
{
	FILE *fpin = fopen (vfile, "rt");
	if (!fpin)
		return (-1);

	FILE *fpout = fopen (binfile, "wb");
	if (!fpout)
		return (-1);

	unsigned char bin[32];

	while (!feof (fpin))
	{
		char buf[256];
		char *p;

		fgets (buf, 256, fpin);
    if (!strncmp(buf, "//", 2))
      continue;
		if (!(p = strstr(buf, ".INIT_")))
			continue;

		p = strstr (buf, "256'h") + 5;
		for (int i=0; i<32; i++)
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

int main (int argc, char *argv[])
{
	// read the rom binaries
	FILE *fpin = fopen ("a2e.cd", "rb");
	if (!fpin)
		exit (0);
	fread (rom, 8192, 1, fpin);
	fclose (fpin);
	fpin = fopen ("a2e.ef", "rb");
	if (!fpin)
		exit (0);
	fread (rom+8192, 8192, 1, fpin);
	fclose (fpin);

	int i;
	for (i=0xC000; i<0x10000; i+= 0x0800)
	{
		char filename[64];
		sprintf (filename, "%02X%s.bin", i>>8, (i==0xC000 ? "I" : ""));
		FILE *fpout = fopen (filename, "wb");
		fwrite (rom+i-0xC000, 0x800, 1, fpout);
		fclose (fpout);		

		sprintf (filename, "rom_%02X%s.v", i>>8, (i==0xC000 ? "I" : ""));
		fpout = fopen (filename, "wt");

		fprintf (fpout,
							"/*****************************************************************************\n"
							"* 2k C1 Internal ROM for APPLE 2E Initialized ALL 0XFF\n"
							"******************************************************************************/\n",
							i>>8);

		fprintf (fpout,
							"  sprom #(\n"
							"  	.init_file		(\"../../../../src/platform/appleii-becker/roms/%02X%s.hex\"),\n"
							"  	.numwords_a		(2048),\n"
							"  	.widthad_a		(11)\n"
							"  ) RAMB16_S9_%02X%s (\n"
							"  	.address			(ADDRESS[10:0]),\n"
							"  	.clock				(PH_2),\n"
							"  	.q						(DOA_%02X%s)\n"
							"  );\n",
							i>>8, (i==0xC000 ? "I" : ""), i>>8, (i==0xC000 ? "I" : ""), i>>8, (i==0xC000 ? "I" : ""));

		fclose (fpout);
	}

	fclose (fpin);

  // create the C0S ROM
  v2bin ("rom_c0s.v", "c0s_tmp.bin");

  // now overlay the disk ROM

	fpin = fopen ("c0s_tmp.bin", "rb");
	if (!fpin)
		exit (0);
	fread (rom, 1, 2048, fpin);
	fclose (fpin);

	fpin = fopen ("disk2_33.rom", "rb");
	if (!fpin)
		exit (0);
	fread (rom+0x600, 1, 256, fpin);
	fclose (fpin);
	
	char filename[64];
	sprintf (filename, "c0s.bin");
	FILE *fpout = fopen (filename, "wb");
	fwrite (rom, 1, 2048, fpout);
	fclose (fpout);		

	sprintf (filename, "rom_c0s_pace.v");
	fpout = fopen (filename, "wt");

	fprintf (fpout,
						"/*****************************************************************************\n"
						"* 2k C1 Slot ROM for APPLE 2E Initialized ALL 0XFF\n"
						"******************************************************************************/\n");

	fprintf (fpout,
						"  sprom #(\n"
						"  	.init_file		(\"../../../../src/platform/appleii-becker/roms/c0s.hex\"),\n"
						"  	.numwords_a		(2048),\n"
						"  	.widthad_a		(11)\n"
						"  ) RAMB16_S9_C0S (\n"
						"  	.address			(ADDRESS[10:0]),\n"
						"  	.clock				(PH_2),\n"
						"  	.q						(DOA_C0S)\n"
						"  );\n");

	fclose (fpout);

  // create the character generator rom
  v2bin ("chargen.v", "chargen.bin");

	sprintf (filename, "chargen_pace.v");
	fpout = fopen (filename, "wt");

	fprintf (fpout,
						"/*****************************************************************************\n"
						"* 2k Character Generator ROM for APPLE 2E Initialized with GLB Apple set\n"
						"******************************************************************************/\n");

	fprintf (fpout,
						"  sprom #(\n"
						"  	.init_file		(\"../../../../src/platform/appleii-becker/roms/chargen.hex\"),\n"
						"  	.numwords_a		(2048),\n"
						"  	.widthad_a		(11)\n"
						"  ) RAMB16_S9_CG (\n"
						"  	.address			(VROM_ADDRESS),\n"
						"  	.clock				(CLK[0]),\n"
						"  	.q						(VRAM_DATA0)\n"
						"  );\n");

	fclose (fpout);

  printf ("Done!\n");
}
