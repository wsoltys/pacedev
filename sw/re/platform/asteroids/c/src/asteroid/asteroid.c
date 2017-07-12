#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

// Notes:
//  Global scale -8..7? not 0..15
//	SVEC X,Y <<= 10

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
	uint16_t	dvg_curr_addr;									// $02-$03
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
	uint8_t		extra_brightness;								// $17
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
	uint8_t		timerStartGame;									// $5A
	uint8_t		VBLANK_triggered;								// $5B
	uint8_t		fastTimer;											// $5C
	uint8_t		slowTimer;											// $5D
	uint8_t		NMI_count;											// $5E
	uint16_t	rnd;														// $5F-$60
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
	union
	{
		struct
		{
			// 0xA0+ = exploding
			// (4:3) = shape (0-3)
			// (2:1) = size (0=small, 1=medium,	2=large)
			uint8_t		asteroid_Sts[27];								// $0200-$021A
			// - 0x00  = in hyperspace?
		 	// - 0x01  = player	alive and active
		 	//- 0xA0+ = player	exploding
			uint8_t		ship_Sts;												// $021B
			// - 0x00  = no saucer
			// - 0x01  = small saucer
			// - 0x02  = large saucer
			// - 0xA0+ = saucer	exploding
			uint8_t		saucer_Sts;											// $021C
			uint8_t		saucerShot_Sts[2];							// $021D-$021E
			uint8_t		shipShot_Sts[4];								// $021F-$0222
		};
		int8_t			object_Status[27+1+1+2+4];
	};
	
	// Horizontal Velocity 0-255 (255-192)=Left, 1-63=Right
	union
	{
		struct
		{
			int8_t		asteroid_Vh[27];								// $0223-$023D
			int8_t		ship_Vh;												// $023E
			int8_t		saucer_Vh;											// $023F
			int8_t		saucerShot_Vh[2];								// $0240-$0241
			int8_t		shipShot_Vh[4];									// $0242-$0245
		};
		int8_t			object_Vh[27+1+1+2+4];
	};
	// Vertical	Velocity 0-255 (255-192)=Down, 1-63=Up
	union
	{
		struct
		{
			int8_t		asteroid_Vv[27];								// $0246-$0260
			int8_t		ship_Vv;												// $0261
			int8_t		saucer_Vv;											// $0262
			int8_t		saucerShot_Vv[2];								// $0264-$0265
			int8_t		shipShot_Vv[4];									// $0266-$0269
		};
		int8_t			object_Vv[27+1+1+2+4];
	};
	// Horiztonal Position High	(0-31) 0=Left, 31=Right
	// Horizontal Position Low (0-255),	0=Left,	255=Right
	union
	{
		struct
		{
			uint16_t	asteroid_Ph[27];								// $0269-$0283,$02AF-$02C9
			uint16_t	ship_Ph;												// $0284,$02CA
			uint16_t	saucer_Ph;											// $0285,$02CB
			uint16_t	saucerShot_Ph[2];								// $0286-$0287,$02CC-$02CD
			uint16_t	shipShot_Ph[4];									// $0288-$028B,$02CE-$02D1
		};
		int8_t			object_Vv[27+1+1+2+4];
	};
	// Vertical	Position High (0-23), 0=Bottom,	23=Top
	// Vertical	Position Low (0-255), 0=Bottom,	255=Top
	union
	{
		struct
		{
			uint16_t	asteroid_Pv[27];								// $028C-$02A6,$02D2-$02EC
			uint16_t	ship_Pv;												// $02A7,$02ED
			uint16_t	saucer_Pv;											// $02A8,$02EE
			uint16_t	saucerShot_Pv[2];								// $02A9-$02AA,$02EF-$02F0
			uint16_t	shipShot_Pv[4];									// $02AB-$02AE,$02F1-$02F4
		};
		int8_t			object_Vv[27+1+1+2+4];
	};

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

typedef enum
{
	VEC0 = 0,
	VEC1,
	VEC2,
	VEC3,
	VEC4,
	VEC5,
	VEC6,
	VEC7,
	VEC8,
	VEC9,
	CUR,
	HALT,
	JSR,
	RTS,
	JMP,
	SVEC
	
} eDVG_OPCODE;

typedef struct
{
	eDVG_OPCODE		opcode;
	union
	{
		struct
		{
			uint8_t				scale;
			uint8_t				brightness;
			int16_t				x;
			int16_t				y;
		} vec_svec;
		struct
		{
			uint8_t				scale;
			int16_t				x;
			int16_t				y;
		} cur;
		struct
		{
			uint16_t			addr;
		} jsr_jmp;
	};
	
	uint8_t				byte[4];
	uint8_t				len;
	
} DISPLAYLIST_ENTRY;

static DSW1 dsw1 = { 2, 0, 0, 0 };	// 1 COIN 1 CREDIT
static ZEROPAGE zp;
static PLYR_RAM plyr_ram[2];
static PLYR_RAM *p = &plyr_ram[0];
static DISPLAYLIST_ENTRY displaylist[256];

static void handle_start_end_turn_or_game (void);			// $6885
static void handle_shots (void);											// $69F0
static void copy_vector_list_to_avgram (
							uint16_t addr, 
							uint8_t flip_x, 
							uint8_t flip_y
							);																			// $6AD7
static void handle_saucer (void);											// $6B93
static void handle_fire (void);												// $6CD7
static int8_t handle_high_score_entry (void);					// $6D90
static void handle_hyperspace (void);									// $6E74
static void init_players (void);											// $6ED8
static void init_sound (void);												// $6EFA
static void display_extra_ships (
							uint8_t x, 
							uint8_t n
							);																			// $6F3E
static void update_and_render_objects (void);					// $6F57
static void handle_respawn_rot_thrust (void);					// $703F
static void init_wave (void);													// $7168
static void set_asteroid_velocity (
							uint8_t src, 
							uint8_t dst
							);																			// $7203
static int8_t limit_asteroid_velocity (int8_t v);			// $7233
static void display_C_scores_ships (void);						// $724F
static uint8_t display_high_score_table (void);				// $73C4
static void handle_sounds (void);											// $7555
static void check_high_score (void);									// $765C
static void display_numeric (
							uint8_t *buf, 
							uint8_t bytes, 
							int pad);																// $773F
static void display_digit (
							uint8_t digit, 
							int pad
							);																			// $7785
static void display_bright_digit (uint8_t digit);			// $778B
static uint8_t update_prng (void);										// $77B5
static void PrintPackedMsg (uint8_t i);								// $77F6
static void add_chr_fn (
						uint8_t chr,
						uint8_t n
						);																				// $7853
static void halt_dvg (void);													// $7BC0
static void write_JMP_JSR_cmd (
							eDVG_OPCODE opcode, 
							uint16_t addr
							);																			// $7BF0
static void write_JSR_cmd (uint16_t addr);						// $7BFC
static void write_CURx4_cmd (uint8_t x, uint8_t y);		// $7C03
static void write_CUR_cmd (uint16_t x, uint16_t y);		// $7C1C
static void update_dvg_curr_addr (uint8_t inc);				// $7C39
static void set_scale_A_bright_0 (uint8_t a);					// $7CDE 
static void set_scale_A_bright_X (
							uint8_t a, 
							uint8_t x
							);																			// $7CDE 
static void reset (void);															// $7CF3

extern void dvgrom_disassemble_jsr (uint16_t addr);

extern uint16_t dvg_x;
extern uint16_t dvg_y;
extern int8_t dvg_scale;
extern uint16_t dvg_brightness;
extern uint8_t dvgrom[];

static void dump_displaylist (void)
{
	unsigned i, j;
	char disasm[128], bin[128], *b;
	
	for (i=0; ; i++)
	{
		DISPLAYLIST_ENTRY *dle = &displaylist[i];
		
		if (zp.dvg_curr_addr == i)
			break;

		switch (dle->opcode)
		{
			case VEC0 : case VEC1 : case VEC2 : case VEC3 : case VEC4 :
			case VEC5 : case VEC6 : case VEC7 : case VEC8 : case VEC9 :
				break;

			case CUR :
				sprintf (disasm, "CUR scale=% 1d(/%d) x=%d, y=%d",
									dle->cur.scale, 1<<(9-dle->cur.scale), dle->cur.x, dle->cur.y);
				dvg_x = dle->cur.x;
				dvg_y = dle->cur.y;
				dvg_scale = dle->cur.scale;
				break;
								
			case HALT :
				sprintf (disasm, "HALT");
				break;
								
			case JSR :
				sprintf (disasm, "JSR $%04X", dle->jsr_jmp.addr);
				break;
								
			case RTS :
				break;
								
			case JMP :
				sprintf (disasm, "JUMP $%04X", dle->jsr_jmp.addr);
				break;
								
			case SVEC :
				break;
								
			default :
				break;
		}

		b = bin;		
		for (j=0; j<dle->len; j++)
			b += sprintf (b, "%02X ", dle->byte[j]);

		printf ("%-16.16s %s\n", bin, disasm);

		if (dle->opcode == JSR)
			dvgrom_disassemble_jsr (dle->jsr_jmp.addr);
				
		if (dle->opcode == HALT)
			break;
	}
}

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
					
					if (++zp.fastTimer == 0)
						zp.slowTimer++;

					// ignore ping-pong buffers
					zp.dvg_curr_addr = 1;
					handle_start_end_turn_or_game ();
					check_high_score ();
					if (handle_high_score_entry () < 0)
					{
						if (display_high_score_table () == 0)
						{
							if (zp.timerStartGame != 0)
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
							
					dump_displaylist ();
					break;
				}
				
				break;
		}
}

// $6885
void handle_start_end_turn_or_game (void)
{
	uint8_t msg;
	
	//UNIMPLEMENTED;
	DBGPRINTF_FN;
	
	if (zp.numPlayers == 0)
	{
		if ((msg = zp.coinMultCredits & 3) == 0)
		{
			freeplay:
				zp.CurrNumCredits = 2;
		}
		else
		{
			msg += 7;
			if (zp.placeP1HighScore & zp.placeP2HighScore & (1<<7))
				PrintPackedMsg (msg);
		}
		check_start:
			;
		start_game:
			;
	}
	else
	{
		if (zp.timerStartGame != 0)
		{
		}
	}
}

// $69F0
void handle_shots (void)
{
	//UNIMPLEMENTED;
}

// $6AD7
void copy_vector_list_to_avgram (uint16_t addr, uint8_t flip_x, uint8_t flip_y)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr];

	// and back again
	int offset = (addr - 0x4000) >> 1;
	unsigned i;
		
	for (i=0; ; i++)
	{
		dle->byte[1] = dvgrom[offset+1] ^ flip_y;
		if (dle->byte[1] < 0xF0)
		{
			// end of vec/svec commands
			if (dle->byte[1] >= 0xA0)
				break;

			// is_vec
			dle->byte[0] = dvgrom[offset+0];	// Y
			dle->byte[2] = dvgrom[offset+2];	// X
			dle->byte[3] = (dvgrom[offset+3] ^ flip_x) + zp.extra_brightness;
			offset += 4;
			dle->opcode = (eDVG_OPCODE)(dle->byte[1] >> 4);
			dle->vec_svec.x = 0;
			dle->vec_svec.y = 0;
		}
		else
		{
			is_svec:
				dle->byte[0] = (dvgrom[offset+0] ^ flip_x) + zp.extra_brightness;
			offset += 2;
			dle->opcode = (eDVG_OPCODE)(dle->byte[1] >> 4);
			dle->vec_svec.x = 0;
			dle->vec_svec.y = 0;
		}
	}
	update_dvg_curr_addr (i);
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
	p->ship_Sts = 0;
	p->saucer_Sts = 0;
	for (i=0; i<2; i++)
		p->saucerShot_Sts[i] = 0;
	for (i=0; i<4; i++)
		p->shipShot_Sts[i] = 0;
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

// $6F3E
void display_extra_ships (uint8_t x, uint8_t n)
{
	if (n == 0)
		return;
	zp.globalScale = 0xE0;				// -2
	write_CURx4_cmd (x, 213);
	do
	{
		write_JSR_cmd (0x54DA);
		
	} while (--n);
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
	int i = 0;
	unsigned int flag;
	uint8_t r;

	//UNIMPLEMENTED;
	
	if (p->asteroidWaveTimer == 0)
	{
		if (p->saucer_Sts != 0)
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

		for (i=27; i>=0; i--)
		{
			r = update_prng ();
			r = (r & ASTEROID_SHAPE_MASK) | ASTEROID_SIZE_LARGE;
			p->asteroid_Sts[i] = r;
			// naughty, 28 is actually PlayerFlag
			set_asteroid_velocity (28, i);
			r = update_prng ();
			flag = r & 1;
			r = (r>>1) & 0x1F;
			if (flag)
			{
				if (r >= 0x18)
					r &= 0x17;
				start_left:
					p->asteroid_Pv[i] = ((uint16_t)r)<<8;
					p->asteroid_Ph[i] = 0;
			}
			else
			{
				start_bottom:
					p->asteroid_Ph[i] = ((uint16_t)r)<<8;
					p->asteroid_Pv[i] = 0;
			}
			if (--zp.byte_8 == 0)
				break;
		}
		p->saucerCountdownTimer = 127;
		p->starting_ThumpCounter = 48;
	}

	// set remaining asteroids to inactive
	for (; i>=0; i--)
		p->asteroid_Sts[i] = 0;
}

// $7203
void set_asteroid_velocity (
	uint8_t src, 
	uint8_t dst
	)
{
	int8_t v;
	//UNIMPLEMENTED;

	v = update_prng ();
	v &= 0x8F;
	if (v < 0)
		v |= 0xF0;
	v += p->object_Vh[src];
	v = limit_asteroid_velocity (v);
	p->asteroid_Vh[dst] = v;
	update_prng ();
	update_prng ();
	update_prng ();
	v = update_prng ();
	v &= 0x8F;
	if (v < 0)
		v |= 0xF0;
	v += p->object_Vv[src];
	v = limit_asteroid_velocity (v);
	p->asteroid_Vv[dst] = v;
}

// $7233
int8_t limit_asteroid_velocity (int8_t v)
{
	if (v < 0)
	{
		if (v < -31)
			v = -31;
		else if (v > -6)
			v = -6;
	}
	else
	{
		if (v < 6)
			v = 6;
		else if (v > 31)
			v = 31;
	}
	
	return (v);
}

// $724F
void display_C_scores_ships (void)
{
	//UNIMPLEMENTED;

	DBGPRINTF ("%s()\n", __FUNCTION__);
	
	zp.globalScale = 0x10;				// 1
	write_JSR_cmd (0x50A4);
	write_CURx4_cmd (25, 219);
	set_scale_A_bright_0 (0x70);
	zp.extra_brightness = 0;
	if ((zp.numPlayers != 2 ||
				zp.curPlayer != 0 ||
				// this depends on order of evaluation!
				((zp.extra_brightness = 0x20) && ((p->ship_Sts | zp.hyperspaceFlag) != 0)) ||
				((int8_t)p->shipSpawnTimer < 0) && (zp.fastTimer & 0x10) != 0))
	{
		display_numeric ((uint8_t *)&zp.p1Score, 2, 1);
		display_bright_digit (0);
	}
	display_extra_ships (40, 3);
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

// $773F
void display_numeric (uint8_t *buf, uint8_t bytes, int pad)
{
	signed int n = bytes - 1;

	DBGPRINTF ("%s($%02X,$%02X,%d,%d)\n", __FUNCTION__, 
							*buf, *(buf+1), bytes, pad);
	
	do
	{
		uint8_t digit = *(buf+n);
		display_digit (digit>>4, pad);
		if (n == 0)
			pad = 0;
		display_digit (digit, pad);
		
	} while (--n >= 0);
}

// $7785
void display_digit (uint8_t digit, int pad)
{
	DBGPRINTF ("%s(%d,%d)\n", __FUNCTION__, digit, pad);
	
	if (pad == 0)
		display_bright_digit (digit);
	digit &= 0x0f;
	if (digit == 0)
		display_bright_digit (digit);	// fixme
	else
		display_bright_digit (digit);
}

// $778B
void display_bright_digit (uint8_t digit)
{
	int offset;
	uint16_t addr;
	
	DBGPRINTF ("%s(%d)\n", __FUNCTION__, digit);

	if (1 || zp.extra_brightness == 0)
		;
	else
	{
		digit &= 0x0f;
		digit++;				// char code
		offset = 0x6D4 + (digit<<1);
		addr = 0x4000 + ((uint16_t)dvgrom[offset] << 1) + (((uint16_t)dvgrom[offset+1] << 9) & 0x1F00);
		copy_vector_list_to_avgram (addr, 0, 0);
	}	
}

// $77B5
uint8_t update_prng (void)
{
	uint8_t r;
	
	// rnd2 is high byte, rnd1 is low byte
	zp.rnd <<= 1;
	if (zp.rnd & (1<<15))
		zp.rnd |= (1<<0);
	if (zp.rnd & 2)
		zp.rnd ^= (1<<0);
	r = (uint8_t)((zp.rnd >> 8) | zp.rnd);
	if (r == 0)
		r++;
	
	return (r);
}

// $77F6
void PrintPackedMsg (uint8_t i)
{
	static char *msg[] =
	{
		"HIGH SCORES",
		"PLAYER",
		"YOUR SCORE IS ON OF THE TEN BEST",
		"PLEASE ENTER YOUR INITIALS",
		"PUSH ROTATE TO SELECT LETTER",
		"PUSH HYPERSPACE WHEN LETTER IS CORRECT",
		"PUSH START",
		"GAME OVER",
		"1 COIN 2 PLAYS",
		"1 COIN 1 PLAY",
		"2 COINS 1 PLAY"
	};
	
	typedef struct 
	{
		uint8_t x;
		uint8_t y;

	} MSG_COORDS;
	
	static MSG_COORDS coord[] =
	{
		{ 100, 182 },
		{ 100, 182 },
		{  12, 170 },
		{  12, 162 },
		{  12, 154 },
		{  12, 146 },
		{ 100, 198 },
		{ 100, 157 },
		{  80,  57 },
		{  80,  57 },
		{  80,  57 }
	};
	
	unsigned j = 0;
	
	//DBGPRINTF ("%s(%d)=@%d,%d,\"%s\"\n", __FUNCTION__, 
	//						i, coord[i].x, coord[i].y, msg[i]);
	
	// ignore language for now
	zp.globalScale = 0x10;			// 1
	write_CURx4_cmd (coord[i].x, coord[i].y);
	set_scale_A_bright_0 (0x70);
	for (; msg[i][j]; j++)
		add_chr_fn (msg[i][j], j);
	update_dvg_curr_addr (j);
}

// $7853
void add_chr_fn (uint8_t chr, uint8_t n)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr+n];
	unsigned offset;

	//DBGPRINTF ("%s('%c')\n", __FUNCTION__, chr);
		
	// convert to 'asteroids' character set
	if (chr == ' ')
		chr = 0;
	else if (isdigit (chr))
		chr = 1 + chr - '0';
	else if (isalpha (chr))
		chr = 11 + toupper(chr) - 'A';
	else
		chr = 0;
		
	// add JSR to display list
	offset = 0x6D4 + (chr<<1);
	dle->opcode = dvgrom[offset+1] >> 4;
	dle->jsr_jmp.addr = 0x4000 | (((((uint16_t)dvgrom[offset+1] & 0x0f) << 8) | dvgrom[offset])<<1);
	dle->byte[0] = dvgrom[offset];
	dle->byte[1] = dvgrom[offset+1];
	dle->len = 2;
}

// $7BC0
void halt_dvg (void)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr];

	dle->opcode = HALT;
	
	dle->byte[0] = 0xB0;
	dle->byte[1] = 0xB0;
	dle->len = 2;

	update_dvg_curr_addr (1);	
}

// $7BF0
void write_JMP_JSR_cmd (eDVG_OPCODE opcode, uint16_t addr)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr];

	dle->opcode = opcode;
	dle->jsr_jmp.addr = addr;
	
	// convert to word address
	addr >>= 1;
	dle->byte[1] = (opcode << 4) | ((addr >> 8) & 0x0F);
	dle->byte[0] = addr & 0xFF;
	dle->len = 2;
	
	update_dvg_curr_addr (1);
}

// $7BFC
void write_JSR_cmd (uint16_t addr)
{
	write_JMP_JSR_cmd (JSR, addr);
}

// $7C03
void write_CURx4_cmd (uint8_t x, uint8_t y)
{
	//DBGPRINTF ("%s (%d,%d):\n", __FUNCTION__, x, y);

	write_CUR_cmd ((uint16_t)x*4, (uint16_t)y*4);
}

// $7C1C
void write_CUR_cmd (uint16_t x, uint16_t y)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr];

	//DBGPRINTF ("%s (%d,%d):\n", __FUNCTION__, x, y);
	
	dle->byte[0] = x & 0xFF;
	dle->byte[1] = ((x >> 8) & 0x0F) | 0xA0;
	dle->byte[2] = y & 0xFF;
	dle->byte[3] = ((y >> 8) & 0x0F) | zp.globalScale;
	dle->len = 4;
	
	dle->opcode = CUR;
	dle->cur.y = y;
	dle->cur.x = x;
	dle->cur.scale = dle->byte[3] >> 4;

	update_dvg_curr_addr (1);	
}

// $7C39
void update_dvg_curr_addr (uint8_t inc)
{
	zp.dvg_curr_addr += inc;
}

// $7CDE 
void set_scale_A_bright_0 (uint8_t a)
{
	set_scale_A_bright_X (a, 0);
}

// $7CDE 
void set_scale_A_bright_X (uint8_t a, uint8_t x)
{
	DISPLAYLIST_ENTRY *dle = &displaylist[zp.dvg_curr_addr];

	dle->byte[1] = a;
	dle->byte[0] = 0;
	dle->byte[2] = 0;
	dle->byte[3] = x;
	
	dle->opcode = (eDVG_OPCODE)(a>>4);
	dle->vec_svec.scale = (uint8_t)dle->opcode;
	dle->vec_svec.brightness = x>>4;
	dle->vec_svec.x = 0;
	dle->vec_svec.y = 0;
	
	update_dvg_curr_addr (1);
}

// $7CF3
void reset (void)
{
	//UNIMPLEMENTED;

	memset (&zp, 0, sizeof(zp));
	memset (plyr_ram, 0, sizeof(plyr_ram));
	
	// check SelfTest
	
	// init DVG shared RAM (JP $0402)
	displaylist[0].opcode = JMP;
	displaylist[0].jsr_jmp.addr = 0x0402;
	memcpy (displaylist[0].byte, "\x01\xE2", 2);
	displaylist[0].len = 2;
	// and add a HALT
	displaylist[1].opcode = HALT;
	displaylist[1].byte[0] = 0xB0;
	displaylist[1].len = 2;
		
	// guessing this just needs to be invalid?
	zp.placeP1HighScore = 0xB0;
	zp.placeP2HighScore = 0xB0;
	// turn on both start lamps
	p = &plyr_ram[0];
	zp.coinMultCredits = 0x03 & dsw1.coinage;
	zp.coinMultCredits |= (dsw1.centreCoinMultiplierAndLives & 2) << 3;
}
