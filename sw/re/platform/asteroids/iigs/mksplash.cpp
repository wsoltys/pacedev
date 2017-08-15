#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <string.h>
#include <ctype.h>

uint8_t vram[1024];

uint8_t text[1024];
uint8_t flags[24];
#define F_INVERT	(1<<0)

int printat (int x, int y, const char *str)
{
	memcpy ((char *)(vram+y*40+x), str, strlen(str));
}

int cprintat (int y, const char *str)
{
	return (printat ((40-strlen(str))/2, y, str));
}

int main (int argc, char *argv[])
{
	memset (vram, ' ', 1024);
	for (unsigned r=0; r<24; r++)
		flags[r] = 0;
		
	// display on the screen
	
	unsigned r = 1;
	
	cprintat (r, "ARCADE ASTEROIDS");
	r += 2;
	cprintat (r, "FOR THE APPLE IIGS");
	r += 3;
	cprintat (r, "PRE-ALPHA DEBUG 1");
	r += 3;
	cprintat (r++, "THIS SOFTWARE COMPRISES THE ORIGINAL");
	cprintat (r++, "ASTEROIDS ARCADE ROM CODE ADAPTED AND");
	cprintat (r++, "RE-ASSEMBLED FOR THE APPLE IIGS.");
	r++;
	cprintat (r++, "BITMAP GRAPHICS KINDLY SUPPLIED BY");
	cprintat (r++, "NORBERT KEHRER");
	cprintat (r++, "(ATARI 800XL ASTEROIDS EMULATOR)");
	r++;	
	cprintat (r++, "   <5>     =  INSERT COIN");
	cprintat (r++, "   <1>     =  1P START   ");
	cprintat (r++, "<JOYSTK1>  =  CONTROLS   ");

	cprintat (21, "WWW.RETROPORTS.BLOGSPOT.COM.AU");
	flags[21] = F_INVERT;
	
	for (unsigned r=0; r<24; r++)
	{
		printf ("|");
		for (unsigned c=0; c<40; c++)
		{
			printf ("%c", vram[r*40+c]);
		}
		printf ("|\n");
	}

	for (unsigned r=0; r<24; r++)
	{
		for (unsigned c=0; c<40; c++)
		{
			uint8_t b = vram[r*40+c];

			if ((flags[r] & F_INVERT) == 0)			
				b |= 0x80;
				
			if (r < 8)
				text[r*0x80+c] = b;
			else
			if (r < 16)
				text[(r-8)*0x80+0x28+c] = b;
			else
				text[(r-16)*0x80+0x50+c] = b;
		}
	}

	FILE *fp = fopen ("splash.bin", "wb");
	fwrite (text, 1, 1024, fp);
	if (!fp) exit (0);

	fclose (fp);		
}
