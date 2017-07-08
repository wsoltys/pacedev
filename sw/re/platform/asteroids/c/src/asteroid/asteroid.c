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
	uint8_t		coinage;
	// 0 = 1x & 4, 1 = 1x & 3, 2 = 2x & 4, 3 = 2x & 3
	uint8_t		rightCoinMultiplier;
	uint8_t		centreCoinMultiplierAndLives;
	uint8_t		language;
	
} DSW1;		// $2800

typedef struct
{
	uint8_t		globalScale;										// $00
	uint8_t		byte_1;													// $01
	uint8_t		dvg_curr_addr_lsb;							// $02
	uint8_t		dvg_curr_addr_msb;							// $03
	uint8_t		byte_4;													// $04
	uint8_t		byte_5;													// $05
	uint8_t		byte_6;													// $06
	uint8_t		byte_7;													// $07
	uint8_t		byte_8;													// $08
	uint8_t		byte_9;													// $09
	uint8_t		byte_A;													// $0A
	uint8_t		byte_B;													// $0B
	uint8_t		byte_C;													// $0C
	uint8_t		byte_D;													// $0D
	uint8_t		byte_E;													// $0E
	uint8_t		byte_F;													// $0F
	uint8_t		initial_offset;									// $10
	uint8_t		unused1[4];											// $11-$14	
	uint8_t		byte_15;												// $15
	uint8_t		byte_16;												// $16
	uint8_t		byte_17;												// $17
	uint8_t		curPlayer;											// $18
	uint8_t		curPlayer_x2;										// $19
	uint8_t		numPlayersPreviousGame;					// $1A
	uint8_t		byte_1B;												// $1B
	uint8_t		numPlayers;											// $1C
	// High score format (2 bytes)
	// byte 1 - tens (in decimal)
	// byte 2 - thousands (in decimal)
  uint8_t		highScoreTable[10][2];					// $1D-$30
  uint8_t		letterHighScoreEntry;						// $31
  uint8_t		placeP1HighScore;								// $32
  uint8_t		placeP2HighScore;								// $33
  uint8_t		highScoreInitials[10][3];				// $34-$51
  // actual scores are x10
  uint16_t	p1Score;												// $52-$53
  uint16_t	p2Score;												// $54-$55
  uint8_t		numStartingShipsPerGame;				// $56
  uint8_t		numShipsP1;											// $57
  uint8_t		numShipsP2;											// $58
	// Hyperspace flag:
	// - 0x01 = successful
	//   0x80 = unsuccessful (death)
	//   0x00 = not active
  uint8_t		hyperspaceFlag;									// $59
	uint8_t		timer_start_game;								// $5A
	uint8_t		VBLANK_triggered;								// $5B
	uint8_t		fast_timer;											// $5C
	uint8_t		slow_timer;											// $5D
	uint8_t		NMI_count;											// $5E
	uint8_t		rnd1;														// $5F
	uint8_t		rnd2;														// $60
	uint8_t		direction;											// $61
	uint8_t		saucerShotDirection;						// $62
	uint8_t		btn_edge_debounce;							// $63
	uint8_t		ship_thrust_dH;									// $64
	uint8_t		ship_thrust_dV;									// $65
	uint8_t		timerPlayerFireSound;						// $66
	uint8_t		timerSaucerFireSound;						// $67
	uint8_t		timerBonusShipSound;						// $68
	uint8_t		timerExplosionSound;						// $69
	uint8_t		fireSoundFlagPlayer;						// $6A
	uint8_t		fireSoundFlagSaucer;						// $6B
	uint8_t		volFreqThumpSound;							// $6C
	uint8_t		timerThumpSoundOn;							// $6D
	uint8_t		timerThumpSoundOff;							// $6E
	uint8_t		io3200ShadowRegister;						// $6F
	uint8_t		CurrNumCredits;									// $70
	// 4=center_mult, 3..2=right_mult, 1..0=coinage
	uint8_t		coinMultCredits;								// $71
	uint8_t		slamSwitchFlag;									// $72
	uint8_t		totalCoinsForCredits;						// $73
	uint8_t		byte_74;												// $74
	uint8_t		byte_75;												// $75
	uint8_t		byte_76;												// $76
	uint8_t		byte_77;												// $77
	uint8_t		unused2[2];											// $78-$79
	uint8_t		coin_1_inp_length;							// $7A
	uint8_t		coin_2_inp_length;							// $7B
	uint8_t		coin_3_inp_length;							// $7C
	uint8_t		byte_7D;												// $7D
	uint8_t		byte_7E;												// $7E
	uint8_t		unused3;												// $7F
	uint8_t		unused4[128];										// $80-$FF
	
} ZEROPAGE;

#define ASTEROID_SHAPE_MASK			(0x03<<3)
#define ASTERIOD_SIZE_MASK			(0x03<<1)
#define ASTEROID_SIZE_LARGE			(0x02<<1)
#define ASTEROID_SIZE_MEDIUM		(0x01<<1)
#define ASTEROID_SIZE_SMALL			(0x00<<2)

typedef struct
{
	// 0xA0+ = exploding
	// (4:3) = shape (0-3)
	// (2:1) = size (0=small, 1=medium,	2=large)
	uint8_t		p1AsteroidFlag[27];							// $0200-$021A
	// - 0x00  = in hyperspace?
 	// - 0x01  = player	alive and active
 	//- 0xA0+ = player	exploding
	uint8_t		p1PlayerFlag;										// $021B
	// - 0x00  = no saucer
	// - 0x01  = small saucer
	// - 0x02  = large saucer
	// - 0xA0+ = saucer	exploding
	uint8_t		p1SaucerFlag;										// $021C
	uint8_t		saucerShotTimer[2];							// $021D-$021E
	uint8_t		p1TimerShot[4];									// $021F-$0222
	// Horizontal Velocity 0-255 (255-192)=Left, 1-63=Right
	uint8_t		asteroid_Vh[27];								// $0223-$023D
	uint8_t		ship_Vh;												// $023E
	uint8_t		saucer_Vh;											// $023F
	uint8_t		saucerShot_Vh[2];								// $0240-$0241
	uint8_t		shipShot_Vh[4];									// $0242-$0245
	// Vertical	Velocity 0-255 (255-192)=Down, 1-63=Up
	uint8_t		asteroid_Vv[27];								// $0246-$0260
	uint8_t		ship_Vv;												// $0261
	uint8_t		saucer_Vv;											// $0262
	uint8_t		saucerShot_Vv[2];								// $0264-$0265
	uint8_t		shipShot_Vv[4];									// $0266-$0269
	// Horiztonal Position High	(0-31) 0=Left, 31=Right
	// Horizontal Position Low (0-255),	0=Left,	255=Right
	uint16_t	asteroid_Ph[27];								// $0269-$0283,$02AF-$02C9
	uint16_t	ship_Ph;												// $0284,$02CA
	uint16_t	saucer_Ph;											// $0285,$02CB
	uint16_t	saucerShot_Ph[2];								// $0286-$0287,$02CC-$02CD
	uint16_t	shipShot_Ph[4];									// $0288-$028B,$02CE-$02D1
	// Vertical	Position High (0-23), 0=Bottom,	23=Top
	// Vertical	Position Low (0-255), 0=Bottom,	255=Top
	uint16_t	asteroid_Pv[27];								// $028C-$02A6,$02D2-$02EC
	uint16_t	ship_Pv;												// $02A7,$02ED
	uint16_t	saucer_Pv;											// $02A8,$02EE
	uint16_t	saucerShot_Pv[2];								// $02A9-$02AA,$02EF-$02F0
	uint16_t	shotShot_Pv[4];									// $02AB-$02AE,$02F1-$02F4
	uint8_t		startingAsteroidsPerWave;				// $02F5
	uint8_t		currentNumberOfAsteroids;				// $02F6
	uint8_t		saucerCountdownTimer;						// $02F7
	uint8_t		starting_saucerCountdownTimer;	// $02F8
	uint8_t		asteroid_hit_timer;							// $02F9
	uint8_t		shipSpawnTimer;									// $02FA
	uint8_t 	asteroidWaveTimer;							// $02FB
	uint8_t		starting_ThumpCounter;					// $02FC
	uint8_t		numAsteroidsLeftBeforeSaucer;		// $02FD
	uint8_t		unused1[2];											// $02FE-$02FF
	
} PLYR_RAM;

static DSW1 dsw1;
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
static void set_asteroid_velocity (uint8_t i);				// $7203
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
					if (p->asteroidWaveTimer != 0)
						p->asteroidWaveTimer--;
					else
						if (p->currentNumberOfAsteroids == 0)
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
	unsigned i;
	
	p->startingAsteroidsPerWave = 2;
	zp.numStartingShipsPerGame = (dsw1.centreCoinMultiplierAndLives & 1 ? 3 : 4);
	p->p1PlayerFlag = 0;
	p->p1SaucerFlag = 0;
	for (i=0; i<2; i++)
		p->saucerShotTimer[i] = 0;
	for (i=0; i<4; i++)
		p->p1TimerShot[i] = 0;
	zp.p1Score = 0;
	zp.p2Score = 0;
	p->currentNumberOfAsteroids = (uint8_t)-1;
}

// $6EFA
void init_sound (void)
{
	//UNIMPLEMENTED;
	
	// hit some hardware
	
	zp.timerExplosionSound = 0;
	zp.timerPlayerFireSound = 0;
	zp.timerSaucerFireSound = 0;
	zp.timerBonusShipSound = 0;
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
	unsigned int i;
	uint8_t r;
	//UNIMPLEMENTED;
	
	if (p->asteroidWaveTimer == 0)
	{
		if (p->p1SaucerFlag != 0)
			return;
		p->saucer_Vh = 0;
		p->saucer_Vv = 0;
		if (++(p->numAsteroidsLeftBeforeSaucer) > 11)
			p->numAsteroidsLeftBeforeSaucer--;
		p->startingAsteroidsPerWave += 2;
		if (p->startingAsteroidsPerWave > 11)
			p->startingAsteroidsPerWave = 11;
		p->currentNumberOfAsteroids = p->startingAsteroidsPerWave;
		// tmp counter
		zp.byte_8 = p->startingAsteroidsPerWave;

		for (i=0; i<27; i++)
		{
			r = update_prng ();
			r = (r & ASTEROID_SHAPE_MASK) | ASTEROID_SIZE_LARGE;
			p->p1AsteroidFlag[i] = r;
			set_asteroid_velocity (i);
			r = update_prng ();
		}
	}

	// fixme
		p->p1AsteroidFlag[i] = 0;
}

// $7203
void set_asteroid_velocity (uint8_t i)
{
	uint8_t r;
	//UNIMPLEMENTED;

	r = update_prng ();
	r &= 0x8F;
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

	memset (&zp, 0, sizeof(zp));
	memset (plyr_ram, 0, sizeof(plyr_ram));
	// check SelfTest
	// init DVG shared RAM (JP $0402)
	// guessing this just needs to be invalid?
	zp.placeP1HighScore = 0xB0;
	zp.placeP2HighScore = 0xB0;
	// turn on both start lamps
	p = &plyr_ram[0];
	zp.coinMultCredits = 0x03 & dsw1.coinage;
	zp.coinMultCredits |= (dsw1.centreCoinMultiplierAndLives & 2) << 3;
}
