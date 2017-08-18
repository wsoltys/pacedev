;
;	ARCADE ASTEROIDS
; - ported from the original arcade version
; - by tcdev 2017 msmcdoug@gmail.com
; - graphics kindly supplied by Norbert Kehrer
;
				.list		(meb)										; macro expansion binary
       	.area   CODE (ABS,CON)
				.module asteroid
				
.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.inc"

.globl osd_init
.globl osd_reset
.globl osd_start
.globl osd_render_frame

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

; equ for asteroids here

        .org    var_base
        
        .bndry  0x100
dp_base::            						.ds     256        
globalScale 										.equ		0x00
byte_1                          .equ		0x01
dvg_curr_addr_msb               .equ		0x02						; swapped on 6809
dvg_curr_addr_lsb               .equ		0x03						; swapped on 6809
byte_4                          .equ		0x04
byte_5                          .equ		0x05
byte_6                          .equ		0x06
byte_7                          .equ		0x07
byte_8                          .equ		0x08
byte_9                          .equ		0x09
byte_A                          .equ		0x0A
byte_B                          .equ		0x0B
byte_C                          .equ		0x0C
byte_D                          .equ		0x0D
byte_E                          .equ		0x0E
byte_F                          .equ		0x0F
initial_offset                  .equ		0x10
byte_15                         .equ		0x15
byte_16                         .equ		0x16
extra_brightness                .equ		0x17
curPlayer                       .equ		0x18
curPlayer_x2                    .equ		0x19
numPlayersPreviousGame 					.equ		0x1A
byte_1B                         .equ		0x1B
numPlayers                      .equ		0x1C
; High score format (2 bytes)
; byte 1 - tens (in decimal)
; byte 2 - thousands (in decimal)
highScoreTable                  .equ		0x1D
letterHighScoreEntry            .equ		0x31
placeP1HighScore                .equ		0x32
placeP2HighScore                .equ		0x33
highScoreInitials               .equ		0x34
byte_4F                         .equ		0x4F
p1ScoreTens                     .equ		0x52
p1ScoreThousands                .equ		0x53
p2ScoreTens                     .equ		0x54
p2ScoreThousands                .equ		0x55
numStartingShipsPerGame         .equ		0x56
numShipsP1                      .equ		0x57
numShipsP2                      .equ		0x58
; Hyperspace flag 
; - 0x01 = successful
;   0x80 = unsuccessful (death)
;   0x00 = not active
hyperspaceFlag                  .equ		0x59
timerStartGame                  .equ		0x5A
VBLANK_triggered                .equ		0x5B
fastTimer                       .equ		0x5C
slowTimer                       .equ		0x5D
NMI_count                       .equ		0x5E
rnd1                            .equ		0x5F
rnd2                            .equ		0x60
direction                       .equ		0x61
saucerShotDirection             .equ		0x62
btn_edge_debounce               .equ		0x63
ship_thrust_dH                  .equ		0x64
ship_thrust_dV                  .equ		0x65
timerPlayerFireSound            .equ		0x66
timerSaucerFireSound            .equ		0x67
timerBonusShipSound             .equ		0x68
timerExplosionSound             .equ		0x69
fireSoundFlagPlayer             .equ		0x6A
fireSoundFlagSaucer             .equ		0x6B
volFreqThumpSound               .equ		0x6C
timerThumpSoundOn               .equ		0x6D
timerThumpSoundOff              .equ		0x6E
io3200ShadowRegister            .equ		0x6F
CurrNumCredits                  .equ		0x70
; 4=center_mult, 3..2=right_mult, 1..0=coinage
coinMultCredits                 .equ		0x71
slamSwitchFlag                  .equ		0x72
totalCoinsForCredits            .equ		0x73
byte_74                         .equ		0x74
byte_75                         .equ		0x75
byte_76                         .equ		0x76
byte_77                         .equ		0x77
coin_1_inp_length               .equ		0x7A
coin_2_inp_length               .equ		0x7B
coin_3_inp_length               .equ		0x7C
byte_7D                         .equ		0x7D
byte_7E                         .equ		0x7E
byte_80                         .equ		0x80

isr_dp_base::        						.ds     256        

				.bndry	0x100
P1RAM:
; 1-27 Asteroids
; 0xA0+ = exploding
; (4:3) = shape (0-3)
; (2:1) = size (0=small, 1=medium, 2=large)
asteroid_Sts:										.ds		27
; ship_Sts
; - 0x00  = in hyperspace?
; - 0x01  = player alive and active
; - 0xA0+ = player exploding
ship_Sts:												.ds		1
; saucer_Sts
; - 0x00  = no saucer
; - 0x01  = small saucer
; - 0x02  = large saucer
; - 0xA0+ = saucer exploding
saucer_Sts:											.ds		1
saucerShot_Sts:									.ds		1
shipShot_Sts:										.ds		4
; Horizontal Velocity 0-255 (255-192)=Left, 1-63=Right
asteroid_Vh:										.ds		27
ship_Vh:												.ds		1
saucer_Vh:											.ds		1
saucerShot_Vh:									.ds		1
shipShot_Vh:										.ds		4
; Vertical Velocity 0-255 (255-192)=Down, 1-63=Up
asteroid_Vv:										.ds		27
ship_Vv:												.ds		1
saucer_Vv:											.ds		1
saucerShot_Vv:									.ds		1
shipShot_Vv:										.ds		4
; Horiztonal Position High (0-31) 0=Left, 31=Right
asteroid_PHh:										.ds		27
ship_PHh:												.ds		1
saucer_PHh:											.ds		1
saucerShot_PHh:									.ds		1
shipShot_PHh:										.ds		4
; Vertical Position High (0-23), 0=Bottom, 23=Top
asteroid_PHv:										.ds		27
ship_PHv:												.ds		1
saucer_PHv:											.ds		1
saucerShot_PHv:									.ds		1
shipShot_PHv:										.ds		4
; Horizontal Position Low (0-255), 0=Left, 255=Right
asteroid_PLh:										.ds		27
ship_PLh:												.ds		1
saucer_PLh:											.ds		1
saucerShot_PLh:									.ds		1
shipShot_PLh:										.ds		4
; Vertical Position Low (0-255), 0=Bottom, 255=Top
asteroid_PLv:										.ds		27
ship_PLv:												.ds		1
saucer_PLv:											.ds		1
saucerShot_PLv:									.ds		1
shipShot_PLv:										.ds		4
startingAsteroidsPerWave:				.ds		1
currentNumberOfAsteroids:				.ds		1
saucerCountdownTimer:						.ds		1
starting_saucerCountdownTimer:	.ds		1
asteroid_hit_timer:							.ds		1
shipSpawnTimer:									.ds		1
asteroidWaveTimer:							.ds		1
starting_ThumpCounter:					.ds		1
numAsteroidsLeftBeforeSaucer:		.ds		1

				.bndry	0x100
P2RAM:													.ds			0x100

        .org    code_base

				; filler for now
				.asciz	'asteroids2'
        
				.org		0xc000

jmp_osd_init:
				jmp			osd_init

; $2400
leftCoinSwitch::		     				.ds 1
centerCoinSwitch::		     			.ds 1
rightCoinSwitch::		     				.ds 1
p1StartSwitch::		     					.ds 1
p2StartSwitch::		     					.ds 1
thrustSwitch::		     					.ds 1
rotateRightSwitch::		     			.ds 1
rotateLeftSwitch::		     			.ds 1
				
; $2800
coinage::			      						.ds 1
;	0 = 1x & 4, 1 =	1x & 3,	2 = 2x & 4, 3 =	2x & 3
rightCoinMultiplier::	      		.ds 1
centerCoinMultiplierAndLives::  .ds 1
language::		      						.ds 1

; $6800                
asteroids::
				jsr			osd_reset
				jmp			reset
start:
				jsr			osd_start				
				jsr			init_sound
				jsr			init_players
				
game_loop:
				jsr			init_wave
				
wave_loop:

				lda			dvgram+1
				eora		#2																			; JMP $0402<->$0002
				sta			dvgram+1
				
				inc			*fastTimer
				bne			6$
				inc			*slowTimer
6$:			ldb			#>dvgram																; ping-pong DVG	RAM $4000/$4400
				andb		#0x02
				bne			7$
				ldb			#>(dvgram+0x0400)
7$:			lda			#0x02
				sta			*dvg_curr_addr_lsb											; 0x02 (after JMP instruction)
				stb			*dvg_curr_addr_msb											; 0x40/0x44 (ping pong)
				jsr			handle_start_end_turn_or_game
				bcs			start
				
				jsr			display_C_scores_ships

				jsr			update_prng
				jsr			halt_dvg
.ifdef PLATFORM_COCO3
        jsr     osd_render_frame
.endif
				lda			asteroidWaveTimer
				beq			8$
				dec			asteroidWaveTimer
8$:			ora			currentNumberOfAsteroids
				bne			wave_loop
				beq			game_loop

; $6885
handle_start_end_turn_or_game:
        lda     *numPlayers                             ; game active?
        beq     check_freeplay                          ; no, skip
        lda     *timerStartGame                         ; Time before next player starts
        bne     display_current_player                  ; timer running, go
        jmp     handle_end_turn_or_game                 ; game active (playing)

display_current_player:                                                         
        dec     *timerStartGame													; update timer
        jsr     print_PLAYER_N                          ; show current player

loc_6895:
        CLC
        rts

freeplay:                                                                       
        lda     #2																			; Free Credits!
        sta     *CurrNumCredits                         ; Can Only Play A 2 Player Game, So Only Need To Add 2
        bne     check_start                             ; go

check_freeplay:                                                                 
        lda     *coinMultCredits												; DIP Switch Settings Bitmap
        anda    #3                                      ; coinage only. freeplay?
        beq     freeplay                                ; yes, go
        adda    #7                                      ; calc coinage message
        tfr     a,b                                     ; Into B for the offset
        lda     *placeP1HighScore
        anda    *placeP2HighScore
        bpl     check_start
        jsr     PrintPackedMsg                          ; display coinage

check_start:                                                                    
        ldb     *CurrNumCredits													; credits?
        beq     loc_6895                                ; no, return
        ldx     #1                                      ; 1 player
        lda     p1StartSwitch                           ; P1 start pressed?
        bmi     start_game                              ; yes, go
        cmpb    #2                                      ; >=2 credits available?
        bcc     display_push_start                      ; no, exit
        lda     p2StartSwitch                           ; P2 start pressed?
        bpl     display_push_start                      ; no, exit
        lda     *io3200ShadowRegister
        ora     #4                                      ; RAMSEL=1 (P2)
        sta     *io3200ShadowRegister
        ;sta     $3200                                   ; output
        jsr     init_players
        jsr     init_wave
        jsr     init_ship_position_velocity
        lda     *numStartingShipsPerGame
        sta     *numShipsP2
        ldx     #2                                      ; 2 players
        dec     *CurrNumCredits

start_game:
        stx     *numPlayers
        dec     *CurrNumCredits
        lda     *io3200ShadowRegister
        anda    #0xF8                             			; RAMSEL=0 (P1), lamps OFF
        eora    *numPlayers                             ; player lamp ON
        sta     io3200ShadowRegister
        ;sta     $3200                                   ; output
        jsr     init_ship_position_velocity
        lda     #1
        sta     shipSpawnTimer
        sta     P2RAM+0xFA
        lda     #0x92 ; '’'
        sta     starting_saucerCountdownTimer
        sta     P2RAM+0xF8
        sta     P2RAM+0xF7
        sta     saucerCountdownTimer
        lda     #0x7F ; ''
        sta     asteroidWaveTimer
        sta     P2RAM+0xFB
        lda     #5
        sta     numAsteroidsLeftBeforeSaucer
        sta     P2RAM+0xFD
        lda     #0xFF
        sta     *placeP1HighScore                       ; flag no high score
        sta     *placeP2HighScore                       ; flag no high score
        lda     #0x80
        sta     *timerStartGame                         ; init timer
        asla                                            ; A=0
        sta     *curPlayer                              ; init current player
        sta     *curPlayer_x2
        lda     *numStartingShipsPerGame
        sta     *numShipsP1                             ; init number of ships
        lda     #4
        sta     *volFreqThumpSound
        sta     *timerThumpSoundOff                     ; init thump sound
        lda     #48
        sta     starting_ThumpCounter
        sta     P2RAM+0xFC
        ;sta     $3E00                                   ; sound (noise reset)
        rts

; $693B
display_push_start:
				CLC
				rts
				
; $6960
handle_end_turn_or_game:
				CLC
				rts

; $69E2
print_PLAYER_N:
				rts
				
; $6ED8
init_players:
				lda			#2
				sta			startingAsteroidsPerWave
				ldx			#3
				lsr			centerCoinMultiplierAndLives
				bcs			1$
				inx
1$:			stx			*numStartingShipsPerGame
				lda			#0
				ldx			#4																			; 4 flags, 4 timers, 4 score bytes
2$:			sta			ship_Sts,x
				sta			shipShot_Sts,x													; init timer
				sta			byte_4F+2,x															; zero player score
				leax		-1,x																		; next byte
				cmpx		#0
				bpl			2$																			; loop until done
				sta			currentNumberOfAsteroids
				rts
						
; $6EFA
init_sound:
				rts

display_extra_ships:
        beq     9$
        stb     *byte_8
        ldb     #0xE0
        stb     *globalScale
        ldb     #213                                    ; Y coord (x4=852)
        jsr     write_CURx4_cmd

.ifndef PLATFORM_COCO3
1$:     ldx     #$DA ; 'Ú'
        lda     #$54 ; 'T'                              ; addr=0x54DA
        jsr     write_JSR_cmd                           ; display extra ships?
        dec     byte_8
        bne     1$
.else                                
        lda     #OP_LIFE
     		ldy			*dvg_curr_addr_msb
1$:			sta			,y+
				sta			,y+
        dec     *byte_8
        bne     1$
        sty			*dvg_curr_addr_msb
.endif                                
9$:			rts

; $7168
init_wave:
				ldx			#26																			; 26+1 asteroids
				lda			asteroidWaveTimer
				bne			loc_71DF
				lda			saucer_Sts															; saucer active?
				lbne		locret_71E7															; yes, return
				sta			saucer_Vh
				sta			saucer_Vv																; zero saucer vertical velocity
				inc			numAsteroidsLeftBeforeSaucer
				lda			numAsteroidsLeftBeforeSaucer
				cmpa		#11																			; max value
				bcc			loc_7187																; no, skip
				dec			numAsteroidsLeftBeforeSaucer						; adjust to max

loc_7187:
				lda			startingAsteroidsPerWave
				adda		#2																			; 2 more per wave
				cmpa		#11																			; max number of	asteroids?
				bcc			loc_7193																; OK, skip
				lda			#11																			; limit	to 11

loc_7193:
				sta			currentNumberOfAsteroids
				sta			startingAsteroidsPerWave
				sta			*byte_8																	; store	as temp	counter
				ldy			#28																			; offset to ship

init_next_asteroid:
				jsr			update_prng															; random velocity
				anda		#0x18																		; (4:3)	= rnd shape
				ora			#4																			; (2:1)	= 10b =	large
				sta			P1RAM,X																	; set asteroid status
				jsr			set_asteroid_velocity
				jsr			update_prng															; random position
				lsra
				anda		#0x1F																		; 5 bits of high byte
				bcc			start_bottom
				cmpa		#0x18
				bcc			start_left
				anda		#0x17

start_left:									
				sta			asteroid_PHv,X													; y coord (high	byte)
				lda			#0
				sta			asteroid_PHh,X
				sta			asteroid_PLh,X													; x coord = 0
				beq			loc_71D0

start_bottom:									
				sta			asteroid_PHh,X													; x coord (high	byte)
				lda			#0
				sta			asteroid_PHv,X													; y coord = 0
				sta			asteroid_PLv,X

loc_71D0:									
				leax		-1,x																		; offset for next asteroid
				dec			*byte_8																	; done all asteroids for the wave?
				bne			init_next_asteroid											; no, loop
				lda			#127
				sta			saucerCountdownTimer
				lda			#48
				sta			starting_ThumpCounter

loc_71DF:
				lda			#0

loc_71E1:									
				sta			P1RAM,X																	; flag asteroid	as inactive
				leax		-1,x																		; offset for next asteroid
				cmpx		#0
				bpl			loc_71E1																; loop through remaining entries

locret_71E7:
				rts

; $71E8
init_ship_position_velocity:
				rts
				
; $7203
; Y=source asteroid, X=new asteroid
set_asteroid_velocity:
				jsr			update_prng
				anda		#0x8F
				bpl			1$
				ora			#0xF0
1$:			adda		asteroid_Vh,Y														; source velocity
				jsr			limit_asteroid_velocity
				sta			asteroid_Vh,X														; new velocity
				jsr			update_prng
				jsr			update_prng
				jsr			update_prng
				jsr			update_prng
				anda		#0x8F
				bpl			2$
				ora			#0xF0
2$:			adda		asteroid_Vv,Y														; source velocity
				jsr			limit_asteroid_velocity
				sta			asteroid_Vv,X														; new velocity
				rts

; $7233
limit_asteroid_velocity:
				bpl			2$
				cmpa		#-31
				bcs			1$
				lda			#-31
1$:			cmpa		#-5
				bcc			9$
				lda			#-6
				rts
2$:			cmpa		#6
				bcs			3$
				lda			#6
3$:			cmpa		#32
				bcc			9$
				lda			#31
9$:			rts

; $72F4
display_C_scores_ships:
				lda			#16
				sta			*globalScale
.ifndef PLATFORM_COCO3
				lda			#0x50
				ldx			#0xA4																		; addr = 0x50A4
				;jsr			write_JSR_cmd														; "(C)1979 ATARI INC"
.else
        ldy     *dvg_curr_addr_msb
        ldb     #OP_COPYRIGHT
        stb			,y+
        stb			,y+
        sty     *dvg_curr_addr_msb
.endif                                

				lda			#25																			; X coord (x4=100)
				ldb			#219																		; Y coord (x4=876)
				jsr			write_CURx4_cmd
				lda			#0x70																		; scale = 7
				;jsr			set_scale_A_bright_0
				ldx			#0																			; digit	brightness += 0
				lda			*numPlayers
				cmpa		#2																			; 2 players?
				bne			1$																			; no, skip
				lda			*curPlayer															; player 1?
				bne			1$																			; yes, skip
				ldx			#0x20                              			; digit brightness += $20
				lda			ship_Sts
				ora			*hyperspaceFlag
				bne			1$
				lda			shipSpawnTimer
				bmi			1$
				lda			*fastTimer
				anda		#0x10
				beq			2$																			; not every frame
1$:			lda			#p1ScoreTens
				ldb			#2																			; 2 bytes to display
				sec																							; flag no zero padding
				jsr			display_numeric													; display P1 score
				lda			#0
				jsr			display_bright_digit										; display score	units (=0)
2$:			lda			#40																			; X coord (x4=160)
				ldb			*numShipsP1
				jsr			display_extra_ships
				lda			#0
				sta			*globalScale
				lda			#120																		; X coord (x4=480)
				ldb			#219																		; y coord (x4=876)
				jsr			write_CURx4_cmd
				lda			#0x50                              			; scale = 5
				;jsr			set_scale_A_bright_0
				lda			#highScoreTable
				ldb			#2																			; 2 bytes to display
				SEC																							; flag no zero padding
				jsr			display_numeric													; display high score
				lda			#0
				jsr			display_digit_A													; display high score units (=0)
				lda			#0x10
				sta			*globalScale
				lda			#192																		; X coord (x4=768)
				ldb			#219																		; Y coord (x4=876)
				jsr			write_CURx4_cmd
				lda			#0x50                              			; scale = 5
				;jsr			set_scale_A_bright_0
				ldx			#0
				lda			*numPlayers
				cmpa		#1																			; 1 player only?
				beq			9$																			; yes, exit
				bcc			3$
				lda			*curPlayer
				beq			3$
				ldx			#0x20
				lda			ship_Sts
				ora			*hyperspaceFlag
				bne			3$
				lda			shipSpawnTimer
				bmi			3$
				lda			*fastTimer
				anda		#0x10
				beq			4$																			; not every frame
3$:			lda			#p2ScoreTens
				ldb			#2																			; 2 bytes to display
				SEC																							; flag no zero padding
				jsr			display_numeric													; display P2 score
				lda			#0
				jsr			display_bright_digit										; display score	units (=0)
4$:			lda			#207																		; X coord (x4=828)
				ldb			*numShipsP2
				jmp			display_extra_ships
9$:			rts

; $773F
; A=buffer, B=#bytes, X=extra brightness (not used)
display_numeric:
				pshs		cc
				;stx			*extra_brightness												; save extra brightness
				decb																						; #bytes-1
				stb			*byte_16																; offset to last byte
				adda		*byte_16																; buf +	#bytes-1
				sta			*byte_15																; ptr current byte
				ldx			dp_base
				tfr			a,b
				abx																							; X=buffer
				puls		cc
1$:			pshs		cc
				lda			0,X																			; get next byte
				lsra
				lsra
				lsra
				lsra																						; high nibble -> low
				puls		cc
				jsr			display_digit
				lda			*byte_16																; bytes	remaining?
				bne			2$																			; no, skip
				CLC																							; flag padding
2$:			lda			0,X																			; get byte (low	nibble)
				jsr			display_digit
				dec			*byte_15																; ptr current byte
				dec			*byte_16																; done?
				bpl			1$																			; no, loop
				rts

; $7785
display_digit:
				bcc			display_bright_digit										; skip if no pad flagged?
				anda		#0x0F																		; any pad digit?
				beq			loc_77B2																; no, skip

; $778B
display_bright_digit:
				ldb			*extra_brightness												; extra	brightness?
				beq			loc_77B2																; none,	use default routine
				anda		#0x0F
				adda		#1
				pshs		cc
				asla																						; x2
.ifndef PLATFORM_COCO3				
				tay								; word offset
				lda			DVGROM+$6D4,Y				; chr fn
				asl			A					; low address *	2
				sta			byte_B
				lda			DVGROM+$6D5,Y				; chr fn
				rol			A
				and			#$1F					; high address * 2
				ora			#$40 ; '@'                              ; +0x4000
				sta			byte_C
				lda			#0
				sta			byte_8					; flag to flip X
				sta			byte_9					; flag to flip Y
				jsr			copy_vector_list_to_avgram
.else
				ldy			*dvg_curr_addr_msb
				ldb			#OP_CHR
				sta			,y+
				sta			,y+
				sty			*dvg_curr_addr_msb
.endif				
				puls		cc
				rts

; $77B2
loc_77B2:
				jmp     display_space_digit_A
								
; $77B5
; this is a 16-bit 1-tap LFSR
; - may	or may not be maximal length
;   has	check for zero
update_prng:
				asl			*rnd1
				rol			*rnd2																		; shift	left 16-bit value
				bpl			1$																			; no shift out
				inc			*rnd1																		; shift	into low bit
1$:			lda			*rnd1
				bita		tap																			; tap on output	of bit0
				beq			2$																			; not set, skip
				eora		#1																			; XOR bit0
				sta			*rnd1
2$:			ora			*rnd2																		; check	all 0
				bne			3$																			; no, skip
				inc			*rnd1																		; =1
3$:			lda			*rnd1																		; return low byte
				rts

; $77D1
tap:		.byte		0x02

; $77F6
; B = msg#
PrintPackedMsg:
				pshs		b
        ;lda     language
        ldb			#0																			; english
        andb    #3                                      ; mask off invalid bits
        aslb                                            ; convert to word offset
        lda     #0x10
        sta     *globalScale
        ldx			#msgTablePtrs
        ldx			b,x																			; for this language
        puls		b
        tfr			b,a																			; copy message number
        ldb			b,x																			; offset for message
        abx																							; add message number
        stx			*byte_8
        asla																						; convert msg# to word offset
        ldy			#msgCoords
        ldd			a,y																			; A=X, B=Y
        jsr     write_CURx4_cmd
        lda     #0x70
        ;jsr     set_scale_A_bright_0
				ldu			*byte_8																	; msg ptr
1$:     lda     ,u																			; get message byte
        sta     *byte_B                                 ; temp store
        lsra                                            ; X,7-1
        lsra                                            ; XX,7-2 (XX76543X)
        jsr     inc_msg_ptr_add_chr_fn
        lda     ,u                                   		; get next message byte
        rola                                            ; 7->C
        rol     *byte_B                                 ; 6-0,7
        rola                                            ; 6->C
        lda     *byte_B                                 ; 6-0,7
        rola                                            ; 5-0,7,6
        asla                                            ; 4-0,7,6,5 (XX21076X)
        jsr     add_chr_fn
        lda     ,u                                   		; get same message byte again
        sta     *byte_B                                 ; temp store (XX54321X)
        jsr     inc_msg_ptr_add_chr_fn
        lsr     *byte_B                                 ; end of message?
        bcc     1$                                			; no, loop

loc_7849:
.ifndef PLATFORM_COCO3
        DEY
        JMP     update_dvg_curr_addr
.endif        
				rts

inc_msg_ptr_add_chr_fn:
				leau		1,u

add_chr_fn:
        anda    #0x3E                              			; get character (bits 5-1)
        bne     1$                                			; if not space, skip
        puls		u																				; pop return address
        bra     loc_7849                                ; return, finishing byte pair (3 chars)
1$:     cmpa    #0x0A																		; one of "@_012"?
        bcs     2$                                			; yes, skip
        adda    #0x0E
2$:                                                                       
.ifndef PLATFORM_COCO3
        TAX																							; X = chr*2 (chr fn offset)
        LDA     DVGROM+$6D2,X                           ; chr fn msb
        STA     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        INY
        LDA     DVGROM+$6D3,X                           ; chr fn lsb
        STA     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        INY
        LDX     #0
.else
        ldy			*dvg_curr_addr_msb
        ldb     #OP_CHR
        stb			,y+
        suba    #2                                      ; $6D2 vs $6D4!
        sta			,y+
        sty			*dvg_curr_addr_msb
.endif                                
        rts

msgCoords:
				.byte 100, 182                                  ; "HIGH SCORES"
				.byte 100, 182                                  ; "PLAYER"
				.byte 12, 170                                   ; "YOUR SCORE...TEN BEST"
.ifndef PLATFORM_COCO3
        .byte 12, 162                                   ; "PLEASE...INITIALS"
        .byte 12, 154                                   ; "PUSH ROTATE...LETTER"
        .byte 12, 146                                   ; "PUSH HYPERSPACE...CORRECT"
.else
        .byte 12, 162-4                                 ; "PLEASE...INITIALS"
        .byte 12, 154-8                                 ; "PUSH ROTATE...LETTER"
        .byte 12, 146-12                                ; "PUSH HYPERSPACE...CORRECT"
.endif                                
        .byte 100, 198                                  ; "PUSH START"
        .byte 100, 157                                  ; "GAME OVER"
        .byte 80, 57                                    ; "1 COIN 2 PLAYS"
        .byte 80, 57                                    ; "1 COIN 1 PLAY"
        .byte 80, 57                                    ; "2 COINS 1 PLAY"

; Offset into Vector ROM for message tables
msgTablePtrs:
				.word english_msg_offset_tbl										; English
        .word 0x788F                                    ; German
        .word 0x7946                                    ; French
        .word 0x79F3                                    ; Spanish
				
; $7BC0
halt_dvg:
.ifndef PLATFORM_COCO3
        LDA     #$B0 ; '°'
.else
        lda     #OP_HALT
.endif
        ldy     *dvg_curr_addr_msb
        sta			,y+
        sta			,y+
        sty			*dvg_curr_addr_msb
        rts

; $7BCB
display_space_digit_A:
        bcc     display_digit_A
        anda    #0x0F                                   ; numeric only
        beq     loc_7BD6                                ; space, skip

; $7BD1
; A = character
display_digit_A:
        anda    #0x0F                                   ; numeric only
        adda   	#1                                      ; convert to char code
loc_7BD6:
        pshs		cc
        asla																						; x2 (word offset)
.ifndef PLATFORM_COCO3
        ldy     #0
        tax
        lda     DVGROM+$6D4,X                           ; chr fn msb
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        lda     DVGROM+$6D5,X                           ; chr fn lsb
        iny
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        jsr     update_dvg_curr_addr
.else
				ldy			*dvg_curr_addr_msb
        ldb     #OP_CHR
        stb     ,y+
        sta			,y+
        sty			*dvg_curr_addr_msb
.endif                                
        puls		cc
        rts

; $7C03
; A=X coord, B=Y coord
write_CURx4_cmd:
				clr			*byte_5
				clr			*byte_7
				asla
				rol			*byte_5
				asla
				rol			*byte_5																	; X*4 (msb)
				sta			*byte_4																	; X*4 (lsb)
				aslb
				rol			*byte_7
				aslb
				rol			*byte_7																	; Y*4 (msb)
				stb			*byte_6																	; Y*4 (lsb)
				ldx			#dp_base+4

write_CUR_cmd:
				lda			2,X																			; @$6 =	Y*4 (lsb)
				ldb			#0
				ldy			*dvg_curr_addr_msb
				sta			1,y																			; store	in avg ram
				incb
				lda			3,X																			; @$7 =	Y*4 (msb)
				anda		#0x0F																		; clear	command	nibble
.ifndef PLATFORM_COCO3
        ORA     #$A0 ; ' '                              ; CUR command
.else
        ora     #OP_CUR
.endif
				sta			0,y																			; store	in avg ram
				incb
				lda			0,X																			; @$4 =	X*4 (lsb)
				sta			3,y																			; store	in avg ram
				incb
				lda			1,X																			; @$5 =	X*4 (msb)
				anda		#0x0F																		; clear	scale nibble
				ora			*globalScale														; global scale
				sta			2,y																			; store	in avg ram

; $7C39
; B=#bytes
update_dvg_curr_addr:
				SEC
				adcb		*dvg_curr_addr_lsb
				stb			*dvg_curr_addr_lsb
				bcc			9$
				inc			*dvg_curr_addr_msb
9$:			rts				
				
; $7CF3
reset:
				ldx			#0x100
				lda			#0
1$:			leax		-1,x
				sta			P1RAM+0x100,x														; clear P2 RAM
				sta			P1RAM,x																	; clear P1 RAM
				;sta			$100,x
				sta			dp_base,x																; clear DP
				cmpx		#0
				bne			1$
				; check for service mode here - not supported												
				lda			#1
				sta			dvgram
				lda			#0xE2
				sta			dvgram+1																; JMP $0402
.ifndef PLATFORM_COCO3
				LDA     #$B0 ; '°'                              ; HALT
.else
				lda			#OP_HALT
.endif
        sta     dvgram+3
        lda			#0xB0
        sta     *placeP1HighScore
        sta     *placeP2HighScore
        lda     #3
        sta     *io3200ShadowRegister
        ;sta     $3200                                   ; Turn on player 1 & 2 start lamps
        anda    coinage                                 ; coinage only
        sta     *coinMultCredits
        lda     rightCoinMultiplier
        anda    #3                                      ; multiplier bits only
        asla
        asla                                            ; -> bits 3..2
        ora     *coinMultCredits
        sta     *coinMultCredits
        lda     centerCoinMultiplierAndLives
        anda    #2                                      ; multiplier bit only
        asla
        asla
        asla                                            ; -> bit 4
        ora     *coinMultCredits
        sta     *coinMultCredits
				jmp			start
				
.ifdef BUILD_OPT_PROFILE
main_isr:
				tst			IRQENR									; ACk IRQ
				tst			*vbl_cnt								; 60 frames?
				bne			8$											; no, skip
				lda			#60-1										; reset VBLANK count
				sta			*vbl_cnt
				tfr			dp,a
				ldb			#frame_cnt
				tfr			d,x											; address of value
				ldy			#vidbuf+224/8+39*32			; (224,39)
				ldb			#1
				jsr			print_BCD_number
				ldd			#0x20E0									; (224,32)
				jsr			calc_vram_addr					; ->Y
				jsr			calc_vidbuf_addr_x
				ldu			#0x0802									; 8 lines, 2 bytes
				lda			#>isr_dp_base           ; blit_to_screen is not reentrant
				tfr			a,dp
				jsr			blit_to_screen
				lda			#>dp_base
				tfr			a,dp
				clr			*frame_cnt
				bra			9$
8$:			dec			*vbl_cnt
9$:     rti
.endif

.ifdef PLATFORM_COCO3
english_msg_offset_tbl:
        .byte 0x0B, 0x13, 0x19, 0x2F, 0x41, 0x55, 0x6F, 0x77, 0x7D, 0x87, 0x91
english_msg_tbl:                                
        .byte 0x63, 0x56, 0x60, 0x6E, 0x3C, 0xEC, 0x4D
        .byte 0xC0, 0xA4, 0x0A, 0xEA, 0x6C, 0x08, 0x00, 0xEC, 0xF2, 0xB0, 0x6E, 0x3C, 0xEC, 0x48, 0x5A, 0xB8
        .byte 0x66, 0x92, 0x42, 0x9A, 0x82, 0xC3, 0x12, 0x0E, 0x12, 0x90, 0x4C, 0x4D, 0xF1, 0xA4, 0x12, 0x2D
        .byte 0xD2, 0x0A, 0x64, 0xC2, 0x6C, 0x0F, 0x66, 0xCD, 0x82, 0x6C, 0x9A, 0xC3, 0x4A, 0x85, 0xC0, 0xA6
        .byte 0x6E, 0x60, 0x6C, 0x9E, 0x0A, 0xC2, 0x42, 0xC4, 0xC2, 0xBA, 0x60, 0x49, 0xF0, 0x0C, 0x12, 0xC6
        .byte 0x12, 0xB0, 0x00, 0xA6, 0x6E, 0x60, 0x58, 0xED, 0x12, 0xB5, 0xE8, 0x29, 0xD2, 0x0E, 0xD8, 0x4C
        .byte 0x82, 0x82, 0x70, 0xC2, 0x6C, 0x0B, 0x6E, 0x09, 0xE6, 0xB5, 0x92, 0x3E, 0x00, 0xA6, 0x6E, 0x60
        .byte 0x6E, 0xC1, 0x6C, 0xC0, 0x00, 0x59, 0x62, 0x48, 0x66, 0xD2, 0x6D, 0x18, 0x4E, 0x9B, 0x64, 0x09
        .byte 0x02, 0xA4, 0x0A, 0xED, 0xC0, 0x18, 0x4E, 0x9B, 0x64, 0x08, 0xC2, 0xA4, 0x0A, 0xE8, 0x00, 0x20
        .byte 0x4E, 0x9B, 0x64, 0xB8, 0x46, 0x0D, 0x20, 0x2F, 0x40
sine_tbl:
        .byte 0x00, 0x03, 0x06, 0x09, 0x0C, 0x10, 0x13
        .byte 0x16, 0x19, 0x1C, 0x1F, 0x22, 0x25, 0x28, 0x2B, 0x2E, 0x31, 0x33, 0x36, 0x39, 0x3C, 0x3F, 0x41
        .byte 0x44, 0x47, 0x49, 0x4C, 0x4E, 0x51, 0x53, 0x55, 0x58, 0x5A, 0x5C, 0x5E, 0x60, 0x62, 0x64, 0x66
        .byte 0x68, 0x6A, 0x6B, 0x6D, 0x6F, 0x70, 0x71, 0x73, 0x74, 0x75, 0x76, 0x78, 0x79, 0x7A, 0x7A, 0x7B
        .byte 0x7C, 0x7D, 0x7D, 0x7E, 0x7E, 0x7E, 0x7F, 0x7F, 0x7F, 0x7F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.endif

				.end		jmp_osd_init
