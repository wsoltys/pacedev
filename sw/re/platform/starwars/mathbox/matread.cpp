
//--------------------------------------------------------
// Star Wars / ESB Matrix Processor Microcode Disassembler
// Version 0.9 by Frank Palazzolo (palazzol@tir.com)
// July 28, 1997
//--------------------------------------------------------

#include <stdio.h>

int main(int, char**)
{
	FILE *fp0, *fp1, *fp2, *fp3;
	
	// Edit filenames here if you want to do ESB

	if (!(fp0 =fopen("starwars.mc0","rb")))
	{
		printf("Cannot open file starwars.mc0\n");
		return 1;
	}
	if (!(fp1 = fopen("starwars.mc1","rb")))
	{
		printf("Cannot open file starwars.mc1\n");
		return 1;
	}	
	if (!(fp2 = fopen("starwars.mc2","rb")))
	{
		printf("Cannot open file starwars.mc2\n");
		return 1;
	}	
	if (!(fp3 = fopen("starwars.mc3","rb")))
	{
		printf("Cannot open file starwars.mc3\n");
		return 1;
	}

	int a;
	unsigned long int d[1024];

	for(a=0;a<1024;a++)
		d[a] = 0;

	// The files had better be >= 1024 long...
	for(a=0;a<1024;a++)
	{
		d[a] += (fgetc(fp3) & 0x0f);
		d[a] += ((fgetc(fp2) & 0x0f) * 16);
		d[a] += ((fgetc(fp1) & 0x0f) * 256);
		d[a] += ((fgetc(fp0) & 0x0f) * 4096);
	}

	fclose(fp0);
	fclose(fp1);
	fclose(fp2);
	fclose(fp3);

	printf("-------------------------------------------------------\n");
	printf("Star Wars / ESB Matrix Processor Microcode Disassembler\n");
	printf("Version 0.8 by Frank Palazzolo (palazzol@tir.com)\n");
	printf("-------------------------------------------------------\n\n");
	printf("PROM Address    PROM Data                    Mnemonics\n\n");
	printf("                Strobes D/I* Address\n\n");
	unsigned int b;
	unsigned long prev_inst = 0x0400;
	
	for(a=0;a<1024;a++)
	{
		if (((prev_inst == 0) || (prev_inst & 0x0400)) && (d[a] != 0) && ((a&3) == 0))
			printf("\nProbable entry point: (MW0 = 0x%02x)\n",a>>2);
		prev_inst = d[a];

		// print the address
		b = 0x200; 
		while (b > 0)
		{
			if (a & b)
				printf("1");
			else
				printf("0");
			b >>= 1;
			if (b == 0x80)
				printf(" ");
			if (b == 0x02)
				printf(" ");
		}
		printf("    ");

		// print the data
		b = 0x8000;
		while (b > 0)
		{
			if (d[a] & b)
				printf("1");
			else
				printf("0");
			b >>= 1;
			if (b == 0x80)
				printf("  ");
			if (b == 0x40)
				printf("  ");
		}
		printf("         ");

		int show_op = (d[a] & 0xe300);
		if (d[a] & 0x8000)
			printf("lda ");
		if (d[a] & 0x4000)
			printf("ldb ");
		if (d[a] & 0x2000)
			printf("ldc ");
		if (d[a] & 0x0200)
			printf("readcc ");
		if (d[a] & 0x0100)
			printf("ldacc ");
		if (show_op)
			if (d[a] & 0x0080)
				printf("(0x%02x)",d[a] & 0x007f);
			else
				printf("(BIC,%c)",(d[a] & 0x0003)+'0');

		if (d[a] & 0x1000)
			if (show_op)
				printf(", clearacc");
			else
			{
				printf("clearacc");
				show_op = 1; // force to print commas...:)
			}
		if (d[a] & 0x0800)
			if (show_op)
				printf(", BIC++");
			else
			{
				printf("BIC++");
				show_op = 1; // force to print commas...:)
			}

		if (d[a] & 0x0400)
			if (show_op)
				printf(", mhalt");
			else
				printf("mhalt");
		printf("\n");

		if ((a & 0xff) == 0xff)
			printf("\n------------Page Boundary-----------\n\n");
		if (d[a] & 1024)
			printf("Exit point\n\n");
	}

	return 0;
}