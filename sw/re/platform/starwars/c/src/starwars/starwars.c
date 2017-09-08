#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

// Notes:
//
//  KNOWN BUGS:
//
// * (none)
//
//

#define DBGPRINTF_FN    DBGPRINTF ("%s():\n", __FUNCTION__)
//#define UNTESTED        DBGPRINTF ("*** %s(): UNTESTED ***\n", __FUNCTION__)
#define UNTESTED        
#define UNIMPLEMENTED   DBGPRINTF ("*** %s(): UNMIPLEMENTED ***\n", __FUNCTION__)
//#define UNIMPLEMENTED   
#define UNIMPLEMENTED_AUDIO

#include "osd_types.h"
#include "starwars_osd.h"

#pragma pack(1)

extern void avgrom_exec (uint16_t addr);

extern int16_t avg_x;
extern int16_t avg_y;
extern int8_t avg_bin;
extern int8_t avg_lin;
extern uint16_t avg_brightness;
extern uint8_t avg_color;
extern uint8_t avg_zstat;
extern uint8_t avg_rom[];

extern void osd_cls (void);
extern void osd_line (int16_t x1, int16_t y1, int16_t x2, int16_t y2, unsigned color);

#define VEC_RANGE		8192
#define ROM_BASE 		0x3000

extern int16_t xmin, xmax, ymin, ymax;

void print_msg_at (uint16_t x, uint16_t y, char *msg)
{
	uint16_t base, offs;

	avg_x = x;
	avg_y = y;
	
	while (*msg)
	{
		offs = 0;
		
		if (isalpha (*msg))
		{
			base = 0x3018;
			offs = toupper(*msg) - 'A';
		}
		else
		if (isdigit (*msg))
		{
			base = 0x3004;
			offs = *msg - '0';
		}
		else if (*msg == ' ') base = 0x3002;
		else if (*msg == '%') base = 0x3056;
		else if (*msg == '@') base = 0x3058;
		else if (*msg == '-') base = 0x305A;
		else
			base = 0x3052;
		
		uint16_t addr = avg_rom[base-ROM_BASE+2*offs] & 0x1F;
		addr = (addr<<8) | avg_rom[base-ROM_BASE+2*offs+1];
		addr <<= 1;
		avgrom_exec (addr);
		
		msg++;
	}
}

void cprint_msg_at (uint16_t y, char *msg)
{
	uint16_t x = VEC_RANGE/2 - strlen(msg)*24;
	
	print_msg_at (x, y, msg);
}

void print_msg (char *msg)
{
	print_msg_at (avg_x, avg_y, msg);
}

void starwars (void)
{
	avg_bin = avg_lin = 0;

	avg_color = 2;
	cprint_msg_at (2500, "STAR WARS EPISODE IV%");	
	cprint_msg_at (2400, "@ 2017 MARK MCDOUGALL AND GREG MILLER");	

	avg_color = 6;
	cprint_msg_at (4700, "1 BITCOIN 1 PLAY");	
	
	//avgrom_exec (0x3002);		// character set
	//avgrom_exec (0x3058);		// '(c)'
	
	avg_x = VEC_RANGE/2;
	avg_y = VEC_RANGE/2;
	avg_bin = avg_lin = 0;

	avg_color = 3;
	avgrom_exec (0x3300);		// crosshairs
	
	//avgrom_exec (0x33C6);		// circle
#if 1
	avg_bin = 0; avg_lin = 0;
	avgrom_exec (0x33E4);		// score_wave
	avgrom_exec (0x3406);		// shield
	avgrom_exec (0x341A);		// upper-right gun
	avgrom_exec (0x34B4);		// lower-right gun
	avgrom_exec (0x3558);		// X-wing nose
	avgrom_exec (0x35CC);		// upper-left gun
	avgrom_exec (0x3666);		// lower-left gun
#endif

#if 0
	avgrom_exec (0x370A);		// ?
	avgrom_exec (0x3710);		// ?
	avgrom_exec (0x3716);		// ?
	avgrom_exec (0x371C);		// ?
	avgrom_exec (0x3722);		// ?
	avgrom_exec (0x3728);		// ?
	avgrom_exec (0x372E);		// ?
	avgrom_exec (0x3734);		// ?
  avgrom_exec (0x373A);		// ?
	avgrom_exec (0x3740);		// ?
	avgrom_exec (0x3746);		// ?
	avgrom_exec (0x374C);		// ?
	avgrom_exec (0x377C);		// ?
#endif
#if 1
	#define DSINI avg_bin=3; avg_x=VEC_RANGE/2+450; avg_y=VEC_RANGE/2+450
	DSINI;
	avgrom_exec (0x3AD0);		// death star outine
	DSINI;
	avgrom_exec (0x3B4C);		// death star equator
	DSINI;
	avgrom_exec (0x3B64);		// death star focus lens outline
	DSINI;
	avgrom_exec (0x3BB4);		// death star focus lens fill
	DSINI;
	avgrom_exec (0x3C0C);		// death star panels
#endif
#if 0
	// self-test routines	
	avgrom_exec (0x3CA0);		// ???
	avgrom_exec (0x3D20);		// ???
	avgrom_exec (0x3D4E);		// ???
	avgrom_exec (0x3DFA);		// self-test???
#endif
#if 0
	avg_bin = avg_lin = 0;
	avgrom_exec (0x3F5C);		// self-test???
#endif

	fprintf (stderr, "(%d,%d)-(%d,%d) == %dx%d\n",
					xmin, ymin, xmax, ymax, xmax-xmin+1, ymax-ymin+1);
}
