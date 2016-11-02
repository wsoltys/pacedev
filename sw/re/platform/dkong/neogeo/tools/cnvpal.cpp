#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define MIN(a,b)	(a<=b?a:b)
#define MAX(a,b)	(a>=b?a:b)
	
#define fatalerror	printf
#define logerror		printf

#define BIT(x,n) (((x)>>(n))&1)

typedef unsigned char UINT8;
typedef unsigned short int UINT16;
typedef signed short int INT16;
typedef unsigned long int UINT32;
typedef signed long int INT32;

// from resnet.h/.c

/* Amplifier stage per channel but may be specified globally as default */

#define RES_NET_AMP_USE_GLOBAL		0x0000
#define RES_NET_AMP_NONE			0x0001		//Out0
#define RES_NET_AMP_DARLINGTON		0x0002		//Out1
#define RES_NET_AMP_EMITTER			0x0003		//Out2
#define RES_NET_AMP_CUSTOM			0x0004		//Out3
#define RES_NET_AMP_MASK			0x0007

/* VCC prebuilds - Global */

#define RES_NET_VCC_5V				0x0000
#define RES_NET_VCC_CUSTOM			0x0008
#define RES_NET_VCC_MASK			0x0008

/* VBias prebuils - per channel but may be specified globally as default */

#define RES_NET_VBIAS_USE_GLOBAL	0x0000
#define RES_NET_VBIAS_5V			0x0010
#define RES_NET_VBIAS_TTL			0x0020
#define RES_NET_VBIAS_CUSTOM		0x0030
#define RES_NET_VBIAS_MASK			0x0030

/* Input Voltage levels - Global */

#define RES_NET_VIN_OPEN_COL		0x0000
#define RES_NET_VIN_VCC				0x0100
#define RES_NET_VIN_TTL_OUT			0x0200
#define RES_NET_VIN_CUSTOM			0x0300
#define RES_NET_VIN_MASK			0x0300

// Just invert the signal
#define RES_NET_MONITOR_INVERT		0x1000
// SANYO_EZV20 / Nintendo with inverter circuit
#define RES_NET_MONITOR_SANYO_EZV20	0x2000
// Electrohome G07 Series
// 5.6k input impedance
#define RES_NET_MONITOR_ELECTROHOME_G07	0x3000

#define RES_NET_MONITOR_MASK		0x3000

#define RES_NET_CHAN_RED			0x00
#define RES_NET_CHAN_GREEN			0x01
#define RES_NET_CHAN_BLUE			0x02

typedef struct _res_net_channel_info res_net_channel_info;
struct _res_net_channel_info {
	// per channel options
	UINT32	options;
	// Pullup resistor value in Ohms
	double	rBias;
	// Pulldown resistor value in Ohms
	double	rGnd;
	// Number of inputs connected to resistors
	int		num;
	// Resistor values
	// - Least significant bit first
	double R[8];
	// Minimum output voltage
	// - Applicable if output is routed through a complimentary
	// - darlington circuit
	// - typical value ~ 0.9V
	double	minout;
	// Cutoff output voltage
	// - Applicable if output is routed through 1:1 transistor amplifier
	// - Typical value ~ 0.7V
	double	cut;
	// Voltage at the pullup resistor
	// - Typical voltage ~5V
	double	vBias;
};

typedef struct _res_net_info res_net_info;
struct _res_net_info {
	// global options
	UINT32	options;
	// The three color channels
	res_net_channel_info rgb[3];
	// Supply Voltage
	// - Typical value 5V
	double	vcc;
	// High Level output voltage
	// - TTL : 3.40V
	// - CMOS: 4.95V (@5v vcc)
	double	vOL;
	// Low Level output voltage
	// - TTL : 0.35V
	// - CMOS: 0.05V (@5v vcc)
	double	vOH;
	// Open Collector flag
	UINT8	OpenCol;
};

#define RES_NET_MAX_COMP	3

typedef struct _res_net_decode_info res_net_decode_info;
struct _res_net_decode_info {
	int	numcomp;
	int	start;
	int	end;
	UINT16	offset[3 * RES_NET_MAX_COMP];
	INT16	shift[3 * RES_NET_MAX_COMP];
	UINT16	mask[3 * RES_NET_MAX_COMP];
};


static const res_net_decode_info phoenix_decode_info =
{
	2,      // there may be two proms needed to construct color
	0,      // start at 0
	255,    // end at 255
	//  R,   G,   B,   R,   G,   B
	{   0,   0,   0, 256, 256, 256},        // offsets
	{   0,   2,   1,  -1,   1,   0},        // shifts
	{0x01,0x01,0x01,0x02,0x02,0x02}         // masks
};

static const res_net_info phoenix_net_info =
{
	RES_NET_VCC_5V | RES_NET_VBIAS_5V | RES_NET_VIN_OPEN_COL,
	{
		{ RES_NET_AMP_NONE, 100, 270, 2, { 270, 1 } },
		{ RES_NET_AMP_NONE, 100, 270, 2, { 270, 1 } },
		{ RES_NET_AMP_NONE, 100, 270, 2, { 270, 1 } }
	}
};

// palette.h/.c

typedef struct _palette_t palette_t;
typedef struct _palette_client palette_client;
typedef UINT32 rgb_t;
typedef UINT16 rgb15_t;

#define MAKE_ARGB(a,r,g,b)	((((rgb_t)(a) & 0xff) << 24) | (((rgb_t)(r) & 0xff) << 16) | (((rgb_t)(g) & 0xff) << 8) | ((rgb_t)(b) & 0xff))
#define MAKE_RGB(r,g,b)		(MAKE_ARGB(255,r,g,b))

/* macros to extract components from rgb_t values */
#define RGB_ALPHA(rgb)		(((rgb) >> 24) & 0xff)
#define RGB_RED(rgb)		(((rgb) >> 16) & 0xff)
#define RGB_GREEN(rgb)		(((rgb) >> 8) & 0xff)
#define RGB_BLUE(rgb)		((rgb) & 0xff)

/* common colors */
#define RGB_BLACK			(MAKE_ARGB(255,0,0,0))
#define RGB_WHITE			(MAKE_ARGB(255,255,255,255))

typedef struct _dirty_state dirty_state;
struct _dirty_state
{
	UINT32 *		dirty;						/* bitmap of dirty entries */
	UINT32			mindirty;					/* minimum dirty entry */
	UINT32			maxdirty;					/* minimum dirty entry */
};

struct _palette_client
{
	palette_client *next;						/* pointer to next client */
	palette_t *		palette;					/* reference to the palette */
	dirty_state		live;						/* live dirty state */
	dirty_state		previous;					/* previous dirty state */
};

struct _palette_t
{
	UINT32			refcount;					/* reference count on the palette */
	UINT32			numcolors;					/* number of colors in the palette */
	UINT32			numgroups;					/* number of groups in the palette */

	float			brightness;					/* overall brightness value */
	float			contrast;					/* overall contrast value */
	float			gamma;						/* overall gamma value */
	UINT8			gamma_map[256];				/* gamma map */

	rgb_t *			entry_color;				/* array of raw colors */
	float *			entry_contrast;				/* contrast value for each entry */
	rgb_t *			adjusted_color;				/* array of adjusted colors */
	rgb_t *			adjusted_rgb15;				/* array of adjusted colors as RGB15 */

	float *			group_bright;				/* brightness value for each group */
	float *			group_contrast;				/* contrast value for each group */

	palette_client *client_list;				/* list of clients for this palette */
};

int palette_get_num_colors(palette_t *palette)
{
	return palette->numcolors;
}

rgb_t palette_entry_get_color(palette_t *palette, UINT32 index)
{
	return (index < palette->numcolors) ? palette->entry_color[index] : RGB_BLACK;
}

UINT8 rgb_clamp(INT32 value)
{
	if (value < 0)
		return 0;
	if (value > 255)
		return 255;
	return value;
}

rgb_t adjust_palette_entry(rgb_t entry, float brightness, float contrast, const UINT8 *gamma_map)
{
	int r = rgb_clamp((float)gamma_map[RGB_RED(entry)] * contrast + brightness);
	int g = rgb_clamp((float)gamma_map[RGB_GREEN(entry)] * contrast + brightness);
	int b = rgb_clamp((float)gamma_map[RGB_BLUE(entry)] * contrast + brightness);
	int a = RGB_ALPHA(entry);
	return MAKE_ARGB(a,r,g,b);
}

inline rgb15_t rgb_to_rgb15(rgb_t rgb)
{
	return ((RGB_RED(rgb) >> 3) << 10) | ((RGB_GREEN(rgb) >> 3) << 5) | ((RGB_BLUE(rgb) >> 3) << 0);
}

static void update_adjusted_color(palette_t *palette, UINT32 group, UINT32 index)
{
	UINT32 finalindex = group * palette->numcolors + index;
	palette_client *client;
	rgb_t adjusted;

	/* compute the adjusted value */
	adjusted = adjust_palette_entry(palette->entry_color[index],
				palette->group_bright[group] + palette->brightness,
				palette->group_contrast[group] * palette->entry_contrast[index] * palette->contrast,
				palette->gamma_map);

	/* if not different, ignore */
	if (palette->adjusted_color[finalindex] == adjusted)
		return;

	/* otherwise, modify the adjusted color array */
	palette->adjusted_color[finalindex] = adjusted;
	palette->adjusted_rgb15[finalindex] = rgb_to_rgb15(adjusted);

	/* mark dirty in all clients */
	for (client = palette->client_list; client != NULL; client = client->next)
	{
		client->live.dirty[finalindex / 32] |= 1 << (finalindex % 32);
		client->live.mindirty = MIN(client->live.mindirty, finalindex);
		client->live.maxdirty = MAX(client->live.maxdirty, finalindex);
	}
}

void palette_set_contrast(palette_t *palette, float contrast)
{
	int groupnum, index;

	/* set the global contrast if changed */
	if (palette->contrast == contrast)
		return;
	palette->contrast = contrast;

	/* update across all indices in all groups */
	for (groupnum = 0; groupnum < palette->numgroups; groupnum++)
		for (index = 0; index < palette->numcolors; index++)
			update_adjusted_color(palette, groupnum, index);
}

#define	TTL_VOL			(0.05)


/* Likely, datasheets give a typical value of 3.4V to 3.6V
 * for VOH. Modelling the TTL circuit however backs a value
 * of 4V for typical currents involved in resistor networks.
 */

#define TTL_VOH			(4.0)

int compute_res_net(int inputs, int channel, const res_net_info *di)
{
	double rTotal=0.0;
	double v = 0;
	int i;

	double vBias = di->rgb[channel].vBias;
	double vOH = di->vOH;
	double vOL = di->vOL;
	double minout = di->rgb[channel].minout;
	double cut = di->rgb[channel].cut;
	double vcc = di->vcc;
	double ttlHRes = 0;
	double rGnd = di->rgb[channel].rGnd;
	UINT8  OpenCol = di->OpenCol;

	/* Global options */

	switch (di->options & RES_NET_AMP_MASK)
	{
		case RES_NET_AMP_USE_GLOBAL:
			/* just ignore */
			break;
		case RES_NET_AMP_NONE:
			minout = 0.0;
			cut = 0.0;
			break;
		case RES_NET_AMP_DARLINGTON:
			minout = 0.9;
			cut = 0.0;
			break;
		case RES_NET_AMP_EMITTER:
			minout = 0.0;
			cut = 0.7;
			break;
		case RES_NET_AMP_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown amplifier type");
	}

	switch (di->options & RES_NET_VCC_MASK)
	{
		case RES_NET_VCC_5V:
			vcc = 5.0;
			break;
		case RES_NET_VCC_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown vcc type");
	}

	switch (di->options & RES_NET_VBIAS_MASK)
	{
		case RES_NET_VBIAS_USE_GLOBAL:
			/* just ignore */
			break;
		case RES_NET_VBIAS_5V:
			vBias = 5.0;
			break;
		case RES_NET_VBIAS_TTL:
			vBias = TTL_VOH;
			break;
		case RES_NET_VBIAS_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown vcc type");
	}

	switch (di->options & RES_NET_VIN_MASK)
	{
		case RES_NET_VIN_OPEN_COL:
			OpenCol = 1;
			vOL = TTL_VOL;
			break;
		case RES_NET_VIN_VCC:
			vOL = 0.0;
			vOH = vcc;
			OpenCol = 0;
			break;
		case RES_NET_VIN_TTL_OUT:
			vOL = TTL_VOL;
			vOH = TTL_VOH;
			/* rough estimation from 82s129 (7052) datasheet and from various sources
             * 1.4k / 30
             */
			ttlHRes = 50;
			OpenCol = 0;
			break;
		case RES_NET_VIN_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown vin type");
	}

	/* Per channel options */

	switch (di->rgb[channel].options & RES_NET_AMP_MASK)
	{
		case RES_NET_AMP_USE_GLOBAL:
			/* use global defaults */
			break;
		case RES_NET_AMP_NONE:
			minout = 0.0;
			cut = 0.0;
			break;
		case RES_NET_AMP_DARLINGTON:
			minout = 0.7;
			cut = 0.0;
			break;
		case RES_NET_AMP_EMITTER:
			minout = 0.0;
			cut = 0.7;
			break;
		case RES_NET_AMP_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown amplifier type");
	}

	switch (di->rgb[channel].options & RES_NET_VBIAS_MASK)
	{
		case RES_NET_VBIAS_USE_GLOBAL:
			/* use global defaults */
			break;
		case RES_NET_VBIAS_5V:
			vBias = 5.0;
			break;
		case RES_NET_VBIAS_TTL:
			vBias = TTL_VOH;
			break;
		case RES_NET_VBIAS_CUSTOM:
			/* Fall through */
			break;
		default:
			fatalerror("compute_res_net: Unknown vcc type");
	}

	/* Input impedances */

	switch (di->options & RES_NET_MONITOR_MASK)
	{
		case RES_NET_MONITOR_INVERT:
		case RES_NET_MONITOR_SANYO_EZV20:
			/* Nothing */
			break;
		case RES_NET_MONITOR_ELECTROHOME_G07:
			if (rGnd != 0.0)
				rGnd = rGnd * 5600 / (rGnd + 5600);
			else
				rGnd = 5600;
			break;
	}

	/* compute here - pass a / low inputs */

	for (i=0; i<di->rgb[channel].num; i++)
	{
		int level = ((inputs >> i) & 1);
		if (di->rgb[channel].R[i] != 0.0 && !level)
		{
			if (OpenCol)
			{
				rTotal += 1.0 / di->rgb[channel].R[i];
				v += vOL / di->rgb[channel].R[i];
			}
			else
			{
				rTotal += 1.0 / di->rgb[channel].R[i];
				v += vOL / di->rgb[channel].R[i];
			}
		}
	}

	/* Mix in rbias and rgnd */
	if ( di->rgb[channel].rBias != 0.0 )
	{
		rTotal += 1.0 / di->rgb[channel].rBias;
		v += vBias / di->rgb[channel].rBias;
	}
	if (rGnd != 0.0)
		rTotal += 1.0 / rGnd;

	/* if the resulting voltage after application of all low inputs is
     * greater than vOH, treat high inputs as open collector/high impedance
     * There will be now current into/from the TTL gate
     */

	if ( (di->options & RES_NET_VIN_MASK)==RES_NET_VIN_TTL_OUT)
	{
		if (v / rTotal > vOH)
			OpenCol = 1;
	}

	/* Second pass - high inputs */

	for (i=0; i<di->rgb[channel].num; i++)
	{
		int level = ((inputs >> i) & 1);
		if (di->rgb[channel].R[i] != 0.0 && level)
		{
			if (OpenCol)
			{
				rTotal += 0;
				v += 0;
			}
			else
			{
				rTotal += 1.0 / (di->rgb[channel].R[i] + ttlHRes);
				v += vOH / (di->rgb[channel].R[i] + ttlHRes);
			}
		}
	}

	rTotal = 1.0 / rTotal;
	v *= rTotal;
	v = MAX(minout, v - cut);

	switch (di->options & RES_NET_MONITOR_MASK)
	{
		case RES_NET_MONITOR_INVERT:
			v = vcc - v;
			break;
		case RES_NET_MONITOR_SANYO_EZV20:
			v = vcc - v;
			v = MAX(0, v-0.7);
			v = MIN(v, vcc - 2 * 0.7);
			v = v / (vcc-1.4);
			v = v * vcc;
			break;
		case RES_NET_MONITOR_ELECTROHOME_G07:
			/* Nothing */
			break;
	}

	return (int) (v * 255 / vcc + 0.4);
}

rgb_t *compute_res_net_all(/*running_machine &machine,*/ const UINT8 *prom, const res_net_decode_info *rdi, const res_net_info *di)
{
	UINT8 r,g,b;
	int i,j,k;
	rgb_t *rgb;

	//rgb = auto_alloc_array(machine, rgb_t, rdi->end - rdi->start + 1);
	rgb = new rgb_t[rdi->end - rdi->start + 1];
	for (i=rdi->start; i<=rdi->end; i++)
	{
		UINT8 t[3] = {0,0,0};
		int s;
		for (j=0;j<rdi->numcomp;j++)
			for (k=0; k<3; k++)
			{
				s = rdi->shift[3*j+k];
				if (s>0)
					t[k] = t[k] | ( (prom[i+rdi->offset[3*j+k]]>>s) & rdi->mask[3*j+k]);
				else
					t[k] = t[k] | ( (prom[i+rdi->offset[3*j+k]]<<(0-s)) & rdi->mask[3*j+k]);
			}
		r = compute_res_net(t[0], RES_NET_CHAN_RED, di);
		g = compute_res_net(t[1], RES_NET_CHAN_GREEN, di);
		b = compute_res_net(t[2], RES_NET_CHAN_BLUE, di);
		rgb[i-rdi->start] = MAKE_RGB(r,g,b);
	}
	return rgb;
}

static const res_net_decode_info m62_tile_decode_info =
{
	1,					/* single PROM per color */
	0x000, 0x0ff,		/* start/end */
	/*  R      G      B */
	{ 0x000, 0x200, 0x400 }, /* offsets */
	{     0,     0,     0 }, /* shifts */
	{  0x0f,  0x0f,  0x0f }  /* masks */
};


static const res_net_decode_info m62_sprite_decode_info =
{
	1,					/* single PROM per color */
	0x000, 0x0ff,		/* start/end */
	/*  R      G      B */
	{ 0x100, 0x300, 0x500 }, /* offsets */
	{     0,     0,     0 }, /* shifts */
	{  0x0f,  0x0f,  0x0f }  /* masks */
};


static void m62_amplify_contrast(palette_t *palette, UINT32 numcolors)
{
	// m62 palette is very dark, so amplify default contrast
	UINT32 i, ymax=1;
	if (!numcolors) numcolors = palette_get_num_colors(palette);

	fprintf (stderr, "%s() numcolors=%d\n", __FUNCTION__, numcolors);
	
	// find maximum brightness
	for (i=0;i < numcolors;i++)
	{
		rgb_t rgb = palette_entry_get_color(palette,i);
		UINT32 y = 299 * RGB_RED(rgb) + 587 * RGB_GREEN(rgb) + 114 * RGB_BLUE(rgb);
		ymax = MAX(ymax, y);
	}

	palette_set_contrast(palette, 255000.0/ymax);
}

#include <memory.h>

static void internal_palette_free(palette_t *palette)
{
	/* free per-color data */
	if (palette->entry_color != NULL)
		free(palette->entry_color);
	if (palette->entry_contrast != NULL)
		free(palette->entry_contrast);

	/* free per-group data */
	if (palette->group_bright != NULL)
		free(palette->group_bright);
	if (palette->group_contrast != NULL)
		free(palette->group_contrast);

	/* free adjusted data */
	if (palette->adjusted_color != NULL)
		free(palette->adjusted_color);
	if (palette->adjusted_rgb15 != NULL)
		free(palette->adjusted_rgb15);

	/* and the palette itself */
	free(palette);
}

palette_t *palette_alloc(UINT32 numcolors, UINT32 numgroups)
{
	palette_t *palette;
	UINT32 index;

	/* allocate memory */
	palette = (palette_t *)malloc(sizeof(*palette));
	if (palette == NULL)
		goto error;
	memset(palette, 0, sizeof(*palette));

	/* initialize overall controls */
	palette->brightness = 0.0f;
	palette->contrast = 1.0f;
	palette->gamma = 1.0f;
	for (index = 0; index < 256; index++)
		palette->gamma_map[index] = index;

	/* allocate an array of palette entries and individual contrasts for each */
	palette->entry_color = (rgb_t *)malloc(sizeof(*palette->entry_color) * numcolors);
	palette->entry_contrast = (float *)malloc(sizeof(*palette->entry_contrast) * numcolors);
	if (palette->entry_color == NULL || palette->entry_contrast == NULL)
		goto error;

	/* initialize the entries */
	for (index = 0; index < numcolors; index++)
	{
		palette->entry_color[index] = RGB_BLACK;
		palette->entry_contrast[index] = 1.0f;
	}

	/* allocate an array of brightness and contrast for each group */
	palette->group_bright = (float *)malloc(sizeof(*palette->group_bright) * numgroups);
	palette->group_contrast = (float *)malloc(sizeof(*palette->group_contrast) * numgroups);
	if (palette->group_bright == NULL || palette->group_contrast == NULL)
		goto error;

	/* initialize the entries */
	for (index = 0; index < numgroups; index++)
	{
		palette->group_bright[index] = 0.0f;
		palette->group_contrast[index] = 1.0f;
	}

	/* allocate arrays for the adjusted colors */
	palette->adjusted_color = (rgb_t *)malloc(sizeof(*palette->adjusted_color) * (numcolors * numgroups + 2));
	palette->adjusted_rgb15 = (rgb_t *)malloc(sizeof(*palette->adjusted_rgb15) * (numcolors * numgroups + 2));
	if (palette->adjusted_color == NULL || palette->adjusted_rgb15 == NULL)
		goto error;

	/* initialize the arrays */
	for (index = 0; index < numcolors * numgroups; index++)
	{
		palette->adjusted_color[index] = RGB_BLACK;
		palette->adjusted_rgb15[index] = rgb_to_rgb15(RGB_BLACK);
	}

	/* add black and white as the last two colors */
	palette->adjusted_color[index] = RGB_BLACK;
	palette->adjusted_rgb15[index++] = rgb_to_rgb15(RGB_BLACK);
	palette->adjusted_color[index] = RGB_WHITE;
	palette->adjusted_rgb15[index++] = rgb_to_rgb15(RGB_WHITE);

	/* initialize the remainder of the structure */
	palette->refcount = 1;
	palette->numcolors = numcolors;
	palette->numgroups = numgroups;
	return palette;

error:
	if (palette != NULL)
		internal_palette_free(palette);

	return NULL;
}

void palette_entry_set_color(palette_t *palette, UINT32 index, rgb_t rgb)
{
	int groupnum;

	/* if out of range, or unchanged, ignore */
	if (index >= palette->numcolors || palette->entry_color[index] == rgb)
		return;

	/* set the color */
	palette->entry_color[index] = rgb;

	/* update across all groups */
	for (groupnum = 0; groupnum < palette->numgroups; groupnum++)
		update_adjusted_color(palette, groupnum, index);
}

static UINT8 color_prom[7*256+512];

char b1[32], b2[32], b3[32];

char *int2bin_ex (unsigned val, unsigned bits, char *buf)
{
	int i;	
	for (i=0; i<bits; i++)
	{
		if (val & (1<<(bits-1-i)))
			buf[i] = '1';
		else
			buf[i] = '0';
	}
	buf[i] = '\0';
	
	return (buf);
}

char *int2bin (unsigned val, char *buf)
{
	return (int2bin_ex (val, 8, buf));
}

UINT8 sprite_prom[32];

	#define VARIANT "phoenix"
	char *prom_file[] = 
	{
    "mmi6301.ic40",
    "mmi6301.ic41"
	};
	#define MOST_COMMON		0x030303

int main (int argc, char *argv[])
{
	FILE *fp;

	UINT8 *p = color_prom;
	for (unsigned f=0; f<sizeof(prom_file)/sizeof(char *); f++)
	{
		char filename[64];
		
		sprintf (filename, "%s/%s", VARIANT, prom_file[f]);
		fp = fopen (filename, "rb");
		if (!fp) exit (0);
		fread ((void *)p, 1, 256, fp);
		fclose (fp);
		p += 256;
	}

	fprintf (stderr, "Computing...\n");

	printf ("\nTile palette:\n");

	int i;
	
	palette_t *tile_palette = palette_alloc(256, 1);
	rgb_t *rgb;

	rgb = compute_res_net_all(/*machine(),*/ color_prom, &phoenix_decode_info, &phoenix_net_info);
	/* native order */
	for (i=0;i<256;i++)
	{
		int col;
		col = ((i << 3 ) & 0x18) | ((i>>2) & 0x07) | (i & 0x60);
		//palette_set_color(machine(),i,rgb[col]);
		palette_entry_set_color(tile_palette, i, rgb[col]);
	}
	//palette_set_colors(/*machine,*/ 0x000, rgb, 0x100);
	//for (unsigned i=0; i<tile_palette->numcolors; i++)
	//	palette_entry_set_color(tile_palette, i, rgb[i]);

	//palette_normalize_range(machine().palette, 0, 255, 0, 255);
	//auto_free(machine(), rgb);

	for (unsigned i=0; i<tile_palette->numcolors; i++)
	{
    unsigned r, g, b;
		unsigned pe = 0;

		//if ((tile_palette->adjusted_color[i] & 0xFFFFFF) != MOST_COMMON)
		#if 0
			printf ("%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),  -- %06X\n",
							i, 
							int2bin(RGB_RED(tile_palette->adjusted_color[i]),b1), 
							int2bin(RGB_GREEN(tile_palette->adjusted_color[i]),b2), 
							int2bin(RGB_BLUE(tile_palette->adjusted_color[i]),b3),
							tile_palette->adjusted_color[i] & 0xFFFFFF);
			printf ("-- others => X\"%06X\"\n", MOST_COMMON);
		#endif

		// neogeo palette entry
		// D R0 G0 B0 R4 R3 R2 R1 G4 G3 G2 G1 B4 B3 B2 B1
		//unsigned pe = 0;
		// 5 bits of colour only

		r = RGB_RED(tile_palette->adjusted_color[i]);
		g = RGB_GREEN(tile_palette->adjusted_color[i]);
		b = RGB_BLUE(tile_palette->adjusted_color[i]);
		printf ("0x%02X, 0x%02X, 0x%02X,\n", r, g, b);
		r >>= 3; b >>=3; g >>= 3;
		pe |= (r&(1<<0)) << 14;
		pe |= (g&(1<<0)) << 13;
		pe |= (b&(1<<0)) << 12;
		pe |= (r&0x1E) << 7;
		pe |= (g&0x1E) << 3;
		pe |= (b&0x1E) >> 1;
    //printf ("0x%04X, ", pe);
    //if (i%4 == 3) printf ("\n");
  }
    
	fprintf (stderr, "Done!\n");
}
