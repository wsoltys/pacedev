#include <stdio.h>
#include <stdlib.h>

#define fatalerror	printf
#define logerror		printf

#define BIT(x,n) (((x)>>(n))&1)

typedef unsigned char UINT8;

int VERBOSE = 1;

// from resnet.h/.c

#define MAX_NETS 3
#define MAX_RES_PER_NET 18

#define combine_3_weights(tab,w0,w1,w2)					((int)(((tab)[0]*(w0) + (tab)[1]*(w1) + (tab)[2]*(w2)) + 0.5))
#define combine_2_weights(tab,w0,w1)					((int)(((tab)[0]*(w0) + (tab)[1]*(w1)) + 0.5))

static double compute_resistor_weights(
	int minval, int maxval, double scaler,
	int count_1, const int * resistances_1, double * weights_1, int pulldown_1, int pullup_1,
	int count_2, const int * resistances_2, double * weights_2, int pulldown_2, int pullup_2,
	int count_3, const int * resistances_3, double * weights_3, int pulldown_3, int pullup_3 );

UINT8 color_prom[512+32+32+256];

char b1[32], b2[32], b3[32];

char *int2bin (unsigned val, char *buf)
{
	int i;	
	for (i=0; i<8; i++)
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
	FILE *fp;

	//const UINT8 *color_prom = machine.root_device().memregion("proms")->base();
	const UINT8 *char_pal = color_prom + 0x000;
	const UINT8 *back_pal = color_prom + 0x200;
	const UINT8 *sprite_pal = color_prom + 0x220;
	const UINT8 *sprite_table = color_prom + 0x240;
	static const int resistances_3[3] = { 1000, 470, 220 };
	static const int resistances_2[2]  = { 470, 220 };
	double weights_r[3], weights_g[3], weights_b[3], scale;
	int i;

	fp = fopen ("mpatrol/mpc-4.2a", "rb");
	if (!fp) exit (0);
	fread ((void *)char_pal, 1, 512, fp);
	fclose (fp);
	fp = fopen ("mpatrol/mpc-3.1m", "rb");
	if (!fp) exit (0);
	fread ((void *)back_pal, 1, 32, fp);
	fclose (fp);
	fp = fopen ("mpatrol/mpc-1.1f", "rb");
	if (!fp) exit (0);
	fread ((void *)sprite_pal, 1, 32, fp);
	fclose (fp);


	//machine.colortable = colortable_alloc(machine, 512 + 32 + 32);

	/* compute palette information for characters/backgrounds */
	scale = compute_resistor_weights(0,	255, -1.0,
			3, resistances_3, weights_r, 0, 0,
			3, resistances_3, weights_g, 0, 0,
			2, resistances_2, weights_b, 0, 0);

	printf ("character palette:\n");
	/* character palette */
	for (i = 0; i < 512; i++)
	{
		UINT8 promval = char_pal[i];
		int r = combine_3_weights(weights_r, BIT(promval,0), BIT(promval,1), BIT(promval,2));
		int g = combine_3_weights(weights_g, BIT(promval,3), BIT(promval,4), BIT(promval,5));
		int b = combine_2_weights(weights_b, BIT(promval,6), BIT(promval,7));

		//colortable_palette_set_color(machine.colortable, i, MAKE_RGB(r,g,b));
		//printf ("%03d: %02X,%02X,%02X\n", i, r, g, b);
		if (r!=0 || g!=0 || b!=0)
			printf ("%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n",
							i, int2bin(r,b1), int2bin(g,b2), int2bin(b,b3));
	}

	printf ("background palette:\n");
	/* background palette */
	for (i = 0; i < 32; i++)
	{
		UINT8 promval = back_pal[i];
		int r = combine_3_weights(weights_r, BIT(promval,0), BIT(promval,1), BIT(promval,2));
		int g = combine_3_weights(weights_g, BIT(promval,3), BIT(promval,4), BIT(promval,5));
		int b = combine_2_weights(weights_b, BIT(promval,6), BIT(promval,7));

		//colortable_palette_set_color(machine.colortable, 512+i, MAKE_RGB(r,g,b));
		//printf ("%03d: %02X,%02X,%02X\n", 512+i, r, g, b);
		if (r!=0 || g!=0 || b!=0)
			printf ("%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n",
							i, int2bin(r,b1), int2bin(g,b2), int2bin(b,b3));
	}

	/* compute palette information for sprites */
	compute_resistor_weights(0,	255, scale,
			2, resistances_2, weights_r, 470, 0,
			3, resistances_3, weights_g, 470, 0,
			3, resistances_3, weights_b, 470, 0);

	printf ("sprite palette:\n");
	/* sprite palette */
	for (i = 0; i < 32; i++)
	{
		UINT8 promval = sprite_pal[i];
		int r = combine_2_weights(weights_r, BIT(promval,6), BIT(promval,7));
		int g = combine_3_weights(weights_g, BIT(promval,3), BIT(promval,4), BIT(promval,5));
		int b = combine_3_weights(weights_b, BIT(promval,0), BIT(promval,1), BIT(promval,2));

		//colortable_palette_set_color(machine.colortable, 512 + 32 + i, MAKE_RGB(r,g,b));
		//printf ("%03d: %02X,%02X,%02X\n", 512+32+i, r, g, b);
		if (r!=0 || g!=0 || b!=0)
			printf ("%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n",
							i, int2bin(r,b1), int2bin(g,b2), int2bin(b,b3));
	}

#if 0
	/* character lookup table */
	for (i = 0; i < 512; i++)
		colortable_entry_set_value(machine.colortable, i, i);

	/* sprite lookup table */
	for (i = 0; i < 16 * 4; i++)
	{
		UINT8 promval = sprite_table[(i & 3) | ((i & ~3) << 1)];
		colortable_entry_set_value(machine.colortable, 512 + i, 512 + 32 + promval);
	}

	/* background */
	/* the palette is a 32x8 PROM with many colors repeated. The address of */
	/* the colors to pick is as follows: */
	/* xbb00: mountains */
	/* 0xxbb: hills */
	/* 1xxbb: city */
	colortable_entry_set_value(machine.colortable, 512+16*4+0*4+0, 512);
	colortable_entry_set_value(machine.colortable, 512+16*4+0*4+1, 512+4);
	colortable_entry_set_value(machine.colortable, 512+16*4+0*4+2, 512+8);
	colortable_entry_set_value(machine.colortable, 512+16*4+0*4+3, 512+12);
	colortable_entry_set_value(machine.colortable, 512+16*4+1*4+0, 512);
	colortable_entry_set_value(machine.colortable, 512+16*4+1*4+1, 512+1);
	colortable_entry_set_value(machine.colortable, 512+16*4+1*4+2, 512+2);
	colortable_entry_set_value(machine.colortable, 512+16*4+1*4+3, 512+3);
	colortable_entry_set_value(machine.colortable, 512+16*4+2*4+0, 512);
	colortable_entry_set_value(machine.colortable, 512+16*4+2*4+1, 512+16+1);
	colortable_entry_set_value(machine.colortable, 512+16*4+2*4+2, 512+16+2);
	colortable_entry_set_value(machine.colortable, 512+16*4+2*4+3, 512+16+3);
#endif
}

double compute_resistor_weights(
	int minval, int maxval, double scaler,
	int count_1, const int * resistances_1, double * weights_1, int pulldown_1, int pullup_1,
	int count_2, const int * resistances_2, double * weights_2, int pulldown_2, int pullup_2,
	int count_3, const int * resistances_3, double * weights_3, int pulldown_3, int pullup_3 )
{

	int networks_no;

	int rescount[MAX_NETS];		/* number of resistors in each of the nets */
	double r[MAX_NETS][MAX_RES_PER_NET];		/* resistances */
	double w[MAX_NETS][MAX_RES_PER_NET];		/* calulated weights */
	double ws[MAX_NETS][MAX_RES_PER_NET];	/* calulated, scaled weights */
	int r_pd[MAX_NETS];			/* pulldown resistances */
	int r_pu[MAX_NETS];			/* pullup resistances */

	double max_out[MAX_NETS];
	double * out[MAX_NETS];

	int i,j,n;
	double scale;
	double max;

	/* parse input parameters */

	networks_no = 0;
	for (n = 0; n < MAX_NETS; n++)
	{
		int count, pd, pu;
		const int * resistances;
		double * weights;

		switch(n){
		case 0:
				count		= count_1;
				resistances	= resistances_1;
				weights		= weights_1;
				pd			= pulldown_1;
				pu			= pullup_1;
				break;
		case 1:
				count		= count_2;
				resistances	= resistances_2;
				weights		= weights_2;
				pd			= pulldown_2;
				pu			= pullup_2;
				break;
		case 2:
		default:
				count		= count_3;
				resistances	= resistances_3;
				weights		= weights_3;
				pd			= pulldown_3;
				pu			= pullup_3;
				break;
		}

		/* parameters validity check */
		if (count > MAX_RES_PER_NET)
			fatalerror("compute_resistor_weights(): too many resistors in net #%i. The maximum allowed is %i, the number requested was: %i\n",n, MAX_RES_PER_NET, count);


		if (count > 0)
		{
			rescount[networks_no] = count;
			for (i=0; i < count; i++)
			{
				r[networks_no][i] = 1.0 * resistances[i];
			}
			out[networks_no] = weights;
			r_pd[networks_no] = pd;
			r_pu[networks_no] = pu;
			networks_no++;
		}
	}
	if (networks_no < 1)
		fatalerror("compute_resistor_weights(): no input data\n");

	/* calculate outputs for all given networks */
	for( i = 0; i < networks_no; i++ )
	{
		double R0, R1, Vout, dst;

		/* of n resistors */
		for(n = 0; n < rescount[i]; n++)
		{
			R0 = ( r_pd[i] == 0 ) ? 1.0/1e12 : 1.0/r_pd[i];
			R1 = ( r_pu[i] == 0 ) ? 1.0/1e12 : 1.0/r_pu[i];

			for( j = 0; j < rescount[i]; j++ )
			{
				if( j==n )	/* only one resistance in the network connected to Vcc */
				{
					if (r[i][j] != 0.0)
						R1 += 1.0/r[i][j];
				}
				else
					if (r[i][j] != 0.0)
						R0 += 1.0/r[i][j];
			}

			/* now determine the voltage */
			R0 = 1.0/R0;
			R1 = 1.0/R1;
			Vout = (maxval - minval) * R0 / (R1 + R0) + minval;

			/* and convert it to a destination value */
			dst = (Vout < minval) ? minval : (Vout > maxval) ? maxval : Vout;

			w[i][n] = dst;
		}
	}

	/* calculate maximum outputs for all given networks */
	j = 0;
	max = 0.0;
	for( i = 0; i < networks_no; i++ )
	{
		double sum = 0.0;

		/* of n resistors */
		for( n = 0; n < rescount[i]; n++ )
			sum += w[i][n];	/* maximum output, ie when each resistance is connected to Vcc */

		max_out[i] = sum;
		if (max < sum)
		{
			max = sum;
			j = i;
		}
	}


	if (scaler < 0.0)	/* use autoscale ? */
		/* calculate the output scaler according to the network with the greatest output */
		scale = ((double)maxval) / max_out[j];
	else				/* use scaler provided on entry */
		scale = scaler;

	/* calculate scaled output and fill the output table(s)*/
	for(i = 0; i < networks_no;i++)
	{
		for (n = 0; n < rescount[i]; n++)
		{
			ws[i][n] = w[i][n]*scale;	/* scale the result */
			(out[i])[n] = ws[i][n];		/* fill the output table */
		}
	}

/* debug code */
if (VERBOSE)
{
	logerror("compute_resistor_weights():  scaler = %15.10f\n",scale);
	logerror("min val :%i  max val:%i  Total number of networks :%i\n", minval, maxval, networks_no );

	for(i = 0; i < networks_no;i++)
	{
		double sum = 0.0;

		logerror(" Network no.%i=>  resistances: %i", i, rescount[i] );
		if (r_pu[i] != 0)
			logerror(", pullup resistor: %i Ohms",r_pu[i]);
		if (r_pd[i] != 0)
			logerror(", pulldown resistor: %i Ohms",r_pd[i]);
		logerror("\n  maximum output of this network:%10.5f (scaled to %15.10f)\n", max_out[i], max_out[i]*scale );
		for (n = 0; n < rescount[i]; n++)
		{
			logerror("   res %2i:%9.1f Ohms  weight=%10.5f (scaled = %15.10f)\n", n, r[i][n], w[i][n], ws[i][n] );
			sum += ws[i][n];
		}
		logerror("                              sum of scaled weights = %15.10f\n", sum  );
	}
}
/* debug end */

	return (scale);

}
