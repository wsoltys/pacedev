#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <ctype.h>
#include <string.h>

#define ROM_BASE 0x3000
#define ROM_SIZE	(4*1024)
uint8_t rom[ROM_SIZE];

#define CMD_VCTR		0x00
#define CMD_HALT		0x20
#define CMD_SVEC		0x40
#define CMD_COLOR		0x60
#define CMD_SCAL		0x70
#define CMD_CNTR		0x80
#define CMD_JSRL		0xA0
#define CMD_RTSL		0xC0
#define CMD_JMPL		0xE0

static const char *sz_cmd_tbl[] = 
{
	"VCTR", "HALT", "SVEC", "COLOR", "CNTR", "JSRL", "RTSL", "JMPL",
	"(UNK)"
};

uint8_t jsrl[ROM_SIZE];
uint16_t jsrl_xref[ROM_SIZE];
uint8_t jmpl[ROM_SIZE];
uint16_t jmpl_xref[ROM_SIZE];
char sz_label[ROM_SIZE][32];

FILE *fpAnnotate;
char *p_annotate;

static uint16_t ahextoi (char *p)
{
	uint16_t value = 0;
	
	while (isalnum (*p))
	{
		value <<= 4;
		if (isdigit (*p))
			value |= *p - '0';
		else
			value |= toupper(*p) - 'A' + 10;
		p++;
	}	
	
	return (value);
}

static uint16_t get_next_annotation (void)
{
	char sz_annotate[256];
	uint16_t addr = 0;
	
	if (fpAnnotate)
	{
		while (1)
		{
			char *p = sz_annotate;
			fgets (sz_annotate, 255, fpAnnotate);
			if (feof (fpAnnotate))
				break;

			if (strlen(sz_annotate))
				sz_annotate[strlen(sz_annotate)-1] = '\0';
				
			while (isspace (*p)) p++;
			if (*p == ';')
				continue;
			if (*p == '@')
			{
				addr = ahextoi (p+1);
				while (!isspace (*p)) p++;
				while (isspace (*p)) p++;
				p_annotate = p;
				break;
			}
		}
	}

	return (addr);
}

int main (int argc, char *argv[])
{
	FILE *fp;
	const char *sz_cmd;
	
	fp = fopen ("136021.105", "rb");
	if (!fp) exit (0);
	fread (rom, sizeof(uint8_t), ROM_SIZE, fp);
	fclose (fp);

	fp = fopen ("avgrom.c", "wt");
	if (!fp) exit (0);
	fprintf (fp, "uint8_t avg_rom[] =\n{\n");
	for (unsigned i=0; i<ROM_SIZE/16; i++)
	{
		if ((i%16)==0)
			fprintf (fp, "  // $%04X\n", ROM_BASE+i*16);
		fprintf (fp, "  ");
		for (unsigned j=0; j<16; j++)
			fprintf (fp, "0x%02X, ", rom[i*16+j]);		
		fprintf (fp, "\n");
		if ((i%16)==15)
			fprintf (fp, "\n");
	}
	fprintf (fp, "};\n");
	fclose (fp);
	
	uint16_t a = 0;
	char sz_operand[256];

	// pass 0
	// scan annotate.conf for labels
	memset (sz_label, 0, ROM_SIZE*32);
	fpAnnotate = fopen ("annotate.conf", "rt");
	while (1)
	{
		uint16_t addr;
		if ((addr = get_next_annotation ()) == 0)
			break;
		if (*(p_annotate++) != '=')
			continue;
		while (isspace(*p_annotate)) p_annotate++;
		strcpy (sz_label[addr-ROM_BASE], p_annotate);
	}		
	fclose (fpAnnotate);
	
	// pass 1
	// build a table of subroutines, jumps
	// update labels
	memset (jsrl, 0, ROM_SIZE);
	a = 2;
	while (a < ROM_SIZE)
	{
		uint16_t addr;
		uint16_t l = 2;
		
		switch (rom[a] & 0xE0)
		{
			case CMD_VCTR :
				l = 4;
				break;
			case CMD_JSRL :
				addr = ((((uint16_t)(rom[a]&0x1F))<<8)|rom[a+1])<<1;
				if (addr < 0x3000 || addr > 0x3FFF)
					fprintf (stderr, "* WARNING: @%04X JSRL operand = %04X\n", ROM_BASE+a, addr);
				else
				{
					jsrl[addr-ROM_BASE]++;
					jsrl_xref[addr-ROM_BASE] = a;
					if (*sz_label[addr-ROM_BASE] == 0 ||
						!strcmp (sz_label[addr-ROM_BASE], "loc_"))
						sprintf (sz_label[addr-ROM_BASE], "sub_%04X", addr);
				}
				break;
			case CMD_JMPL :
				addr = ((((uint16_t)(rom[a]&0x1F))<<8)|rom[a+1])<<1;
				if (addr < 0x3000 || addr > 0x3FFF)
					fprintf (stderr, "* WARNING: @%04X JMPL operand = %04X\n", ROM_BASE+a, addr);
				else
				{
					jmpl[addr-ROM_BASE]++;
					jmpl_xref[addr-ROM_BASE] = a;
					if (*sz_label[addr-ROM_BASE] == 0)
						sprintf (sz_label[addr-ROM_BASE], "loc_%04X", addr);
				}
				break;
				
			default :
				break;
		}
		
		a += l;
	}

	fpAnnotate = fopen ("annotate.conf", "rt");
	uint16_t annotate_addr = get_next_annotation ();

	a = 2;
	while (a < ROM_SIZE)
	{
		uint16_t l = 2;
		uint16_t addr;
		int16_t dX, dY, Z;
		uint8_t color, zstat;
		uint8_t bin, lin;
						
		sz_cmd = sz_cmd_tbl[rom[a]>>5];
		sprintf (sz_operand, "");
		
		switch (rom[a] & 0xE0)
		{
			case CMD_VCTR :
				dY = (((uint16_t)rom[a] << 8) | rom[a+1]) & 0x1FFF;
				if (dY & (1<<12)) dY |= 0xF000;
				Z = rom[a+2] >> 5;
				dX = (((uint16_t)rom[a+2] << 8) | rom[a+3]) & 0x1FFF;
				if (dX & (1<<12)) dX |= 0xF000;
				dX /= 2; dY /= 2;
				sprintf (sz_operand, "dX=% 4d, dY=% 4d, Z=%1d", dX, dY, Z);
				l = 4;
				break;
			case CMD_HALT :
				break;
			case CMD_SVEC :
				dY = rom[a] & 0x1F; if (dY & (1<<4)) dY |= 0xFFF0;
				Z = rom[a+1] >> 5;
				dX = rom[a+1] & 0x1F; if (dX & (1<<4)) dX |= 0xFFF0;
				sprintf (sz_operand, "dX=% 4d, dY=% 4d, Z=%1d", dX, dY, Z);
				break;
			case CMD_COLOR :
				switch (rom[a] & 0xF0)
				{
					case CMD_COLOR :
						color = rom[a] & 0x07;
						zstat = rom[a+1] & 0xFF;
						sprintf (sz_operand, "C=%d, Z=%d", color, zstat);
						break;
					case CMD_SCAL :
						sz_cmd = "SCAL";
						bin = rom[a] & 0x07;
						lin = rom[a+1];
						sprintf (sz_operand, "BIN=%d, LIN=%d", bin, lin);
						break;
					default :
						sz_cmd = sz_cmd_tbl[8];
						break;
				}
				break;
			case CMD_CNTR :
				break;
			case CMD_JSRL :
				addr = ((((uint16_t)(rom[a]&0x1F))<<8)|rom[a+1])<<1;
				if (addr < 0x3000 || addr > 0x3fff || sz_label[addr-ROM_BASE] == 0)
					sprintf (sz_operand, "unk_%X", addr);
				else
					sprintf (sz_operand, "%s", sz_label[addr-ROM_BASE]);
				break;
			case CMD_RTSL :
				break;
			case CMD_JMPL :
				addr = ((((uint16_t)(rom[a]&0x1F))<<8)|rom[a+1])<<1;
				if (addr < 0x3000 || addr > 0x3fff || sz_label[addr-ROM_BASE] == 0)
					sprintf (sz_operand, "unk_%X", addr);
				else
					sprintf (sz_operand, "%s", sz_label[addr-ROM_BASE]);
				break;
			default :
				sz_cmd = sz_cmd_tbl[8];
				break;
		}
		
		char tbuf[1024];
		unsigned i;

		// skip label, already scanned
		if (annotate_addr == ROM_BASE+a && *p_annotate == '=')
			annotate_addr = get_next_annotation ();

		if (*sz_label[a] || jsrl[a])
		{
			if (*sz_label[a])
				sprintf (tbuf, "%s:", sz_label[a]);
			else if (jsrl[a])
				sprintf (tbuf, "sub_%04X:", ROM_BASE+a);
			fprintf (stdout, "\n%04X:       %-32.32s                  (XREF:%04X)\n", 
								ROM_BASE+a, tbuf, 
								(jsrl[a] ? ROM_BASE+jsrl_xref[a] : ROM_BASE+jmpl_xref[a]));
		}
		
		fprintf (stdout, "%04X: ", ROM_BASE+a);
		for (i=0; i<4; i++)
			if (i<l)
					fprintf (stdout, "%02X ", rom[a+i]);
			else
					fprintf (stdout, "   ");
		sprintf (tbuf, "    %-8.8s  %s", sz_cmd, sz_operand);
		fprintf (stdout, "%-48.48s%s\n", tbuf,
							(ROM_BASE+a == annotate_addr ? p_annotate : ""));

		while (ROM_BASE+a == annotate_addr)
			annotate_addr = get_next_annotation ();
								
		a += l;
	}
	
	if (fpAnnotate)
		fclose (fpAnnotate);
}
