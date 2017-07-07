#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

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
#include "asteroid_osd.h"

#pragma pack(1)

typedef struct
{
	uint8_t		timer_start_game;								// $5A
	uint8_t		fast_timer;											// $5C
	uint8_t		slow_timer;											// $5D
	
} ZEROPAGE;

typedef struct
{
	uint8_t		current_number_of_asteroids;		// $02F6
	uint8_t 	asteroid_wave_timer;						// $02FB
	
} PLYR_RAM;

static ZEROPAGE zp;
static PLYR_RAM plyr_ram[2];
static PLYR_RAM *p = &plyr_ram[0];

static void handle_start_end_turn_or_game (void);			// $6885
static void handle_shots (void);											// $69F0
static void handle_saucer (void);											// $6B93
static void handle_fire (void);												// $6CD7
static int8_t handle_high_score_entry (void);					// $6D90
static void handle_hyperspace (void);									// $6E74
static void init_players (void);											// $6ED8
static void init_sound (void);												// $6EFA
static void update_and_render_objects (void);					// $6F57
static void handle_respawn_rot_thrust (void);					// $703F
static void init_wave (void);													// $7168
static void display_C_scores_ships (void);						// $724F
static uint8_t display_high_score_table (void);				// $73C4
static void handle_sounds (void);											// $7555
static void check_high_score (void);									// $765C
static uint8_t update_prng (void);										// $77B5
static void halt_dvg (void);													// $7BC0
static void write_CURx4_cmd (uint8_t x, uint8_t y);		// $7C03
static void reset (void);															// $7CF3

void asteroids2 (void)
{
	start:
		reset ();
		init_sound ();
		init_players ();
	
	game_loop:
		while (1)
		{
			init_wave ();
			
			wave_loop:
				while (1)
				{
					// check self-test
					if (osd_quit ())
						return;
						
					// wait for vblank
					// wait for DVG
					
					if (++zp.fast_timer == 0)
						zp.slow_timer++;
					
					handle_start_end_turn_or_game ();
					check_high_score ();
					if (handle_high_score_entry () < 0)
					{
						if (display_high_score_table () == 0)
						{
							if (zp.timer_start_game != 0)
							{
								handle_fire ();
								handle_hyperspace ();
								handle_respawn_rot_thrust ();
								handle_saucer ();
							}
							update_and_render_objects ();
							handle_shots ();
						}
					}
					display_C_scores_ships ();
					handle_sounds ();
					write_CURx4_cmd (127, 127);
					update_prng ();
					halt_dvg ();
					if (p->asteroid_wave_timer != 0)
						p->asteroid_wave_timer--;
					else
						if (p->current_number_of_asteroids == 0)
							break;
				}
		}
		
}

// $6885
void handle_start_end_turn_or_game (void)
{
	//UNIMPLEMENTED;
}

// $69F0
void handle_shots (void)
{
	//UNIMPLEMENTED;
}

// $6B93
void handle_saucer (void)
{
	//UNIMPLEMENTED;
}

// $6CD7
void handle_fire (void)
{
	//UNIMPLEMENTED;
}

// $6D90
int8_t handle_high_score_entry (void)
{
	//UNIMPLEMENTED;
	
	return (-1);
}

// $6E74
void handle_hyperspace (void)
{
	//UNIMPLEMENTED;
}

// $6ED8
void init_players (void)
{
	//UNIMPLEMENTED;
}

// $6EFA
void init_sound (void)
{
	//UNIMPLEMENTED;
}

// $6F57
void update_and_render_objects (void)
{
	//UNIMPLEMENTED;
}

// $703F
void handle_respawn_rot_thrust (void)
{
	//UNIMPLEMENTED;
}

// $7168
void init_wave (void)
{
	//UNIMPLEMENTED;
}

// $724F
void display_C_scores_ships (void)
{
	//UNIMPLEMENTED;
}

// $73C4
uint8_t display_high_score_table (void)
{
	//UNIMPLEMENTED;
	
	return (0);
}

// $7555
void handle_sounds (void)
{
	//UNIMPLEMENTED;
}

// $765C
void check_high_score (void)
{
	//UNIMPLEMENTED;
}

// $77B5
uint8_t update_prng (void)
{
	//UNIMPLEMENTED;
	return (1);
}

// $7BC0
void halt_dvg (void)
{
	//UNIMPLEMENTED;
}

// $7C03
void write_CURx4_cmd (uint8_t x, uint8_t y)
{
	//UNIMPLEMENTED;
}

// $7CF3
void reset (void)
{
	//UNIMPLEMENTED;
}
