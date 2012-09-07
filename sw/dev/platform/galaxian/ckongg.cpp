#include <stdio.h>
#include <stdlib.h>

#define BIT(x,n) (((x)>>(n))&1)

unsigned char prom[32];
unsigned char *color_prom = prom;

char b1[32], b2[32], b3[32];

char *int2bin (unsigned val, unsigned bits, char *buf)
{
	int i;	
	for (i=0; i<bits; i++)
	{
		if (val & (1<<(7-i)))
			buf[i] = '1';
		else
			buf[i] = '0';
	}
	buf[i] = '\0';
	
	return (buf);
}

int main (int argc, char *argv[])
{
	FILE *fp = fopen ("ckongg/ckongg/ck_cp.bin", "rb");
	if (!fp) exit (0);
	fread ((void *)color_prom, 1, 32, fp);
	fclose (fp);

	/* first, the character/sprite palette */
	//len = machine.root_device().memregion("proms")->bytes();
	unsigned len = 32;
	unsigned i;
	for (i = 0;i < len;i++)
	{
		int bit0,bit1,bit2,r,g,b;

		/* red component */
		bit0 = BIT(*color_prom,0);
		bit1 = BIT(*color_prom,1);
		bit2 = BIT(*color_prom,2);
		r = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;
		/* green component */
		bit0 = BIT(*color_prom,3);
		bit1 = BIT(*color_prom,4);
		bit2 = BIT(*color_prom,5);
		g = 0x21 * bit0 + 0x47 * bit1 + 0x97 * bit2;
		/* blue component */
		bit0 = BIT(*color_prom,6);
		bit1 = BIT(*color_prom,7);
		b = 0x4f * bit0 + 0xa8 * bit1;

		//palette_set_color_rgb(machine,i,r,g,b);
		if (r!=0 || g!=0 || b!=0)
		{
			printf ("%2d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),",
							i, int2bin(r,6,b1), int2bin(g,6,b2), int2bin(b,6,b3));
			printf ("  -- \"%s\",\"%s\",\"%s\"),\n",
							int2bin(r,8,b1), int2bin(g,8,b2), int2bin(b,8,b3));
		}
		color_prom++;
	}


	//galaxold_init_stars(machine, STARS_COLOR_BASE);


	/* bullets - yellow and white */
	//palette_set_color(machine,BULLETS_COLOR_BASE+0,MAKE_RGB(0xef,0xef,0x00));
	//palette_set_color(machine,BULLETS_COLOR_BASE+1,MAKE_RGB(0xef,0xef,0xef));
}
