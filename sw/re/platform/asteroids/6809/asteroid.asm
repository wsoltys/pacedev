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
;.define     PLATFORM_STARWARS

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

STARTING_SHIPS                  .equ    1
.ifndef STARTING_SHIPS
  STARTING_SHIPS                .equ    3
.endif

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
byte_9                          .equ		0xA0            ; need 2 bytes (STX)
byte_A                          .equ		0x0A
byte_B                          .equ		0xA2            ; need 2 bytes (STX)
byte_C                          .equ		0xA4            ; need 2 bytes (STY)
byte_D                          .equ		0xA6            ; need 2 bytes (STX)
byte_E                          .equ		0xA8            ; need 2 bytes (STX)
byte_F                          .equ		0xAD            ; need 2 bytes (STX)
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
saucerShot_Sts:									.ds		2
shipShot_Sts:										.ds		4
; Horizontal Velocity 0-255 (255-192)=Left, 1-63=Right
asteroid_Vh:										.ds		27
ship_Vh:												.ds		1
saucer_Vh:											.ds		1
saucerShot_Vh:									.ds		2
shipShot_Vh:										.ds		4
; Vertical Velocity 0-255 (255-192)=Down, 1-63=Up
asteroid_Vv:										.ds		27
ship_Vv:												.ds		1
saucer_Vv:											.ds		1
saucerShot_Vv:									.ds		2
shipShot_Vv:										.ds		4
; Horiztonal Position High (0-31) 0=Left, 31=Right
asteroid_PHh:										.ds		27
ship_PHh:												.ds		1
saucer_PHh:											.ds		1
saucerShot_PHh:									.ds		2
shipShot_PHh:										.ds		4
; Vertical Position High (0-23), 0=Bottom, 23=Top
asteroid_PHv:										.ds		27
ship_PHv:												.ds		1
saucer_PHv:											.ds		1
saucerShot_PHv:									.ds		2
shipShot_PHv:										.ds		4
; Horizontal Position Low (0-255), 0=Left, 255=Right
asteroid_PLh:										.ds		27
ship_PLh:												.ds		1
saucer_PLh:											.ds		1
saucerShot_PLh:									.ds		2
shipShot_PLh:										.ds		4
; Vertical Position Low (0-255), 0=Bottom, 255=Top
asteroid_PLv:										.ds		27
ship_PLv:												.ds		1
saucer_PLv:											.ds		1
saucerShot_PLv:									.ds		2
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

; $2000
																.ds	1
freq3kHz::			     						.ds	1
halt::			     								.ds	1
hyperspaceSwitch::		     			.ds	1
FireSwitch::		     						.ds	1
diagStep::			     						.ds	1
slamSwitch::		     						.ds	1
selfTest::			     						.ds	1

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

        .org    code_base

				; filler for now
				.asciz	'asteroids2'
        
				.org		0xc000

jmp_osd_init:
				jmp			osd_init

; $6800                
asteroids::
				jsr			osd_reset
				jmp			reset
start:
				jsr			osd_start				
				jsr			init_sound
				jsr			init_players

        ; fudge high score table
        lda     #0x34
        sta     *highScoreTable
        lda     #0x12
        sta     *highScoreTable+1
        lda     #10+0x0D                                ; M
        sta     *highScoreInitials
        sta     *highScoreInitials+1
        lda     #10+0x03                                ; C
        sta     *highScoreInitials+2
				
game_loop:
				jsr			init_wave
				
wave_loop:

				; the arcade checks for SelfTest here
				; the arcade waits for 'VBLANK' here
				; the arcade waits for DVG idle here
								
				lda			dvgram+1
				eora		#2																			; JMP $0402<->$0002
				sta			dvgram+1
				; the arcade starts the DVG here
				inc			*fastTimer
				bne			6$
				inc			*slowTimer
6$:			ldb			#>dvgram																; ping-pong DVG	RAM $4000/$4400
				anda		#0x02
				bne			7$
				ldb			#>(dvgram+0x0400)
7$:			lda			#0x02
				sta			*dvg_curr_addr_lsb											; 0x02 (after JMP instruction)
				stb			*dvg_curr_addr_msb											; 0x40/0x44 (ping pong)
				jsr			handle_start_end_turn_or_game
				bcs			start
				jsr			check_high_score
				jsr			handle_high_score_entry
				bpl			loc_6864
				jsr			display_high_score_table
				bcs			loc_6864
				lda			*timerStartGame
				bne			loc_685E
				jsr			handle_fire
				jsr			handle_hyperspace
				jsr			handle_respawn_rot_thrust
				jsr			handle_saucer
loc_685E:
				jsr			update_and_render_objects
				jsr			handle_collisions
loc_6864:				
				jsr			display_C_scores_ships
				jsr			handle_sounds
				; the arcade centres the beam here
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
        ldb     #1                                      ; 1 player
        lda     p1StartSwitch                           ; P1 start pressed?
        bmi     start_game                              ; yes, go
        cmpb    #2                                      ; >=2 credits available?
        bcs     display_push_start                      ; no, exit
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
        ldb     #2                                      ; 2 players
        dec     *CurrNumCredits

start_game:
        stb     *numPlayers
        dec     *CurrNumCredits
        lda     *io3200ShadowRegister
        anda    #0xF8                             			; RAMSEL=0 (P1), lamps OFF
        eora    *numPlayers                             ; player lamp ON
        sta     *io3200ShadowRegister
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
        lda     *placeP1HighScore
        anda    *placeP1HighScore
        bpl     1$
        lda     *fastTimer
        anda    #0x20																		; display phase?
        bne     1$                                			; no, skip
        ldb     #6                                      ; "PUSH START"
        jsr     PrintPackedMsg
1$:     lda     *fastTimer
        anda    #0x0F
        bne     2$
        ; broken & irrelevant on this platform
        ;lda     #1
        ;cmp     *CurrNumCredits
        ;adc     #1
        ;eor     #1
        ;eor     *io3200ShadowRegister
        ;sta     *io3200ShadowRegister
2$:			CLC
				rts
				
; $6960
handle_end_turn_or_game:
        lda     *fastTimer
        anda    #0x3F
        bne     1$
        lda     starting_ThumpCounter
        cmpa    #8
        beq     1$
        dec     starting_ThumpCounter
1$:     ldb     *curPlayer
        ldx     #dp_base+numShipsP1
        lda     b,x                                     ; any ships left?
        bne     toggle_player                           ; yes, skip
        lda     shipShot_Sts
        ora     shipShot_Sts+1
        ora     shipShot_Sts+2
        ora     shipShot_Sts+3                          ; shot(s) still active?
        bne     toggle_player                           ; yes, skip
        ldb     #7                                      ; "GAME OVER"
        jsr     PrintPackedMsg
        lda     *numPlayers
        cmpa    #2                                      ; 2 player game?
        bcs     toggle_player                           ; no, skip
        jsr     print_PLAYER_N                          ; display player

toggle_player:
        lda     ship_Sts                                ; player alive?
        bne     1$                                      ; yes, skip
        lda     shipSpawnTimer
        cmpa    #0x80
        bne     1$
        lda     #16
        sta     shipSpawnTimer
        ldb     *numPlayers
        lda     *numShipsP1
        ora     *numShipsP2                             ; either play have ships left?
        beq     end_game                                ; no, exit
        jsr     zero_saucer
        decb                                            ; 1 player game?
        beq     1$                                      ; yes, exit
        lda     #0x80
        sta     *timerStartGame
        ldb     *curPlayer
        eorb    #1                                      ; toggler player
        ldx     #dp_base+numShipsP1
        lda     b,x                                     ; other player have any ships left?
        beq     1$                                      ; no, exit
        stb     *curPlayer                              ; update current player
        lda     #4                                      ; RAMSEL
        ; *** bank-switch player RAM
        eora    *io3200ShadowRegister                    ; toggle
        sta     *io3200ShadowRegister
        ;sta     $3200                                   ; output
        aslb                                            ; current player * 2
        stb     *curPlayer_x2
1$:     CLC
        rts

end_game:
        stb     *numPlayersPreviousGame
        lda     #0xFF
        sta     *numPlayers                             ; invalidate
        jsr     init_sound
        lda     *io3200ShadowRegister
        anda    #0xF8                                   ; RAMSEL=0, lamps OFF
        ora     #3                                      ; lamps ON
        sta     *io3200ShadowRegister
				CLC
				rts

; $69E2
print_PLAYER_N:
        ldb     #1                                      ; "PLAYER"
        jsr     PrintPackedMsg
        lda     curPlayer
        inca
        jsr     display_digit_A
				rts

; $69F0
; Handle collisions
; - projectiles are player, saucer, shots
;   - saucers destroyed by player shots only
;   - player destroyed by all other objects
;   - asteroids destroyed by all other objects
handle_collisions:
        ldx     #7                                      ; 8 values to check
chk_projectile:                                                                       
        lda     ship_Sts,X															; object status
        beq     next_projectile                         ; not active, skip
        bpl     handle_active_projectile                ; active, go
next_projectile:                                                                      
        leax		-1,x																		; next projectile
        cmpx		#0
        bpl     chk_projectile                          ; loop 'til done
				rts

handle_active_projectile:                                                             
        ldy     #0x1C																		; target=saucer
       	cmpx    #4                                     	; player shot?
        bcc     chk_collision                     			; yes, go
        leay		-1,y                                    ; target=player
        cmpx    #0                                      ; projectile offset
        bne     chk_collision                      			; projectile not player, go
next_target:        
        leay		-1,y																		; target=asteroid
				cmpy		#0
        bmi     next_projectile													; done all targets, ret
chk_collision:        
        lda     P1RAM,Y																	; target object
        beq     next_target                        			; not active, exit
        bmi     next_target                        			; exploding, exit
        sta     *byte_B                                 ; tmp status
        lda     asteroid_PLh,Y                          ; target PLh
        suba    ship_PLh,X                              ; - projectile PLh
        sta     *byte_8																	; tmp_d_PLh
        lda     asteroid_PHh,Y                          ; target PHh
        sbca    ship_PHh,X                              ; - projectile PHh
        lsra                                            ; /2
        ror     *byte_8                                 ; low byte
        asla
        beq     3$
        bpl     no_collision
        eora    #0xFE
        bne     no_collision
        lda     *byte_8
        coma
        sta     *byte_8
3$:     lda     asteroid_PLv,Y													; target PLv
        suba    ship_PLv,X                              ; - projectile PLv
        sta     *byte_9
        lda     asteroid_PHv,Y                          ; target PHv
        sbca    ship_PHv,X                              ; - projectile PHv
        lsra                                            ; /2
        ror     *byte_9                                 ; low byte
        asla
        beq     4$
        bpl     no_collision
        eora    #0xFE
        bne     no_collision
        lda     *byte_9
        coma
        sta     *byte_9
4$:     lda     #42
        lsr     *byte_B																	; target status
        bcs     5$																			; player or small saucer, go
        lda     #72
        lsr     *byte_B																	; large saucer, med asteroid, go
        bcs     5$
        lda     #132
5$:    	cmpx    #1																			
        bcc     6$                                      ; projectile=saucer/shot, go
        adda    #28																			; projectile=player
6$:     bne     8$																			; projectile=shot, go
        adca    #18
        ldb     saucer_Sts                              ; 6502 used X
        decb
        beq     7$																			; projectile=small saucer, go
        adca    #18
7$:     ldx     #1                                      ; restore offset=saucer
8$:     cmpa    *byte_8
        bcs     no_collision
        cmpa    *byte_9
        bcs     no_collision
        sta     *byte_B
        lsra
        adda    *byte_B
        sta     *byte_B
        lda     *byte_9
        adca    *byte_8
        bcs     no_collision
        cmpa    *byte_B
        bcc     no_collision
        jsr     handle_object_hit
jmp_next_projectile:     
        jmp     next_projectile
no_collision:
        leay		-1,y
				cmpy		#0
        bmi     jmp_next_projectile
        jmp     chk_collision

; $6A9D
clone_asteroid_rnd_shape:
        lda     P1RAM,Y                                 ; asteroid status
        anda    #7                                      ; bits 2-0
        sta     *byte_8
        jsr     update_prng                             ; random asteroid shape
        anda    #0x18                                   ; bits 4-3 only
        ora     *byte_8
        sta     P1RAM,X                                 ; new status
        lda     asteroid_PLh,Y
        sta     asteroid_PLh,X
        lda     asteroid_PHh,Y
        sta     asteroid_PHh,X
        lda     asteroid_PLv,Y
        sta     asteroid_PLv,X
        lda     asteroid_PHv,Y
        sta     asteroid_PHv,X
        lda     asteroid_Vh,Y
        sta     asteroid_Vh,X
        lda     asteroid_Vv,Y
        sta     asteroid_Vv,X
        rts

; $6AD3
copy_vector_list_from_table_to_dvgram:
        ; NO_IMPLEMENTATION_REQD
        rts

; $6AD7
copy_vector_list_to_avgram:
        ; NO_IMPLEMENTATION_REQD
        rts
                
; $6B0F
; X=projectile offset
handle_object_hit:
        cmpx    #1																			; projectile=saucer?
        bne     1$																			; no, skip
        cmpy    #0x1B                                   ; target=player?
        bne     update_projectile_status           			; no, skip
        ldx     #0																			; for saucer hits player...
        ldy     #0x1C                                   ; ...player hits saucer
1$:     cmpx		#0
        bne     update_shot_status											; must be a shot, go
        lda     #129																		; init spawn timer
        sta     shipSpawnTimer
        ldb     *curPlayer
        ldx			#dp_base+numShipsP1
        dec     b,x                            					; dec number of ships
        ldx     #0                                      ; restore projectile=player
update_projectile_status:        
     		lda     #0xA0																		; flag object exploding
        sta     ship_Sts,X
        clra
        sta     ship_Vh,X
        sta     ship_Vv,X                               ; zero object velocity
        cmpy    #0x1B                                   ; target=asteroid?
        bcs     jsr_asteroid_hit                 				; yes, go
        bcc     handle_saucer_hit                       ; target=saucer, go
update_shot_status:
     		clra
        sta     ship_Sts,X                              ; flag shot inactive
        cmpy    #0x1B                                   ; target=player?
        beq     handle_player_hit                       ; yes, go
        bcc     handle_saucer_hit                       ; no (saucer), go
jsr_asteroid_hit:
     		jsr     handle_asteroid_hit

explode_object:                                                               
        lda     P1RAM,Y																	; object status
        anda    #3
        eora    #2
        lsra
        rora
        rora
        ora     #0x3F
        sta     *timerExplosionSound
        lda     #0xA0                              			; flag exploding
        sta     P1RAM,Y                                 ; store
        clra
        sta     asteroid_Vh,Y
        sta     asteroid_Vv,Y                           ; zero object velocity
        rts

handle_player_hit:                                                              
        ldb     *curPlayer
				ldu			#dp_base+numShipsP1
        dec     b,u                            					; lose a ship
        lda     #129                                    ; init spawn timer
        sta     shipSpawnTimer
        bne     explode_object                        	; always

handle_saucer_hit:
        lda     starting_saucerCountdownTimer
        sta     saucerCountdownTimer
        lda     *numPlayers                             ; real game?
        beq     explode_object                        	; no, go
        ldb     *curPlayer_x2
        lda     saucer_Sts
        lsra                                            ; small saucer?
        lda     #0x99                             			; (99+1)*10 = 1,000 pts
        bcs     1$                                			; yes, skip
        lda     #0x20                              			; 20x10 = 200 pts
1$:     jsr     add_A_to_score
        jmp     explode_object
				
; $6B93
handle_saucer:
        lda     *fastTimer
        anda    #3                                      ; time to update?
        beq     loc_6B9A                           			; yes, go
locret_6B99:
     		rts
loc_6B9A:
     		lda     saucer_Sts
        bmi     locret_6B99															; exploding? yes, exit
        beq     handle_new_saucer                       ; no saucer? yes, go
        jmp     handle_existing_saucer                  ; small/large saucer

handle_new_saucer:                                                              
        lda     *numPlayers															; game active?
        beq     1$																			; no, go
        lda     ship_Sts                                ; player active?
        beq     locret_6B99                    					; no, return
        bmi     locret_6B99                             ; exploding? yes, return
1$:     lda     asteroid_hit_timer											; non-zero?
        beq     2$																			; no, skip
        dec     asteroid_hit_timer
2$:     dec     saucerCountdownTimer										; time for saucer?
        bne     locret_6B99                             ; no, exit
        lda     #18
        sta     saucerCountdownTimer                    ; reinit countdown
        lda     asteroid_hit_timer                      ; asteroid hit recently?
        beq     3$																			; no, skip
        lda     currentNumberOfAsteroids
        beq     locret_6B99                             ; no asteroids, return
        cmpa    numAsteroidsLeftBeforeSaucer
        bcc     locret_6B99                             ; too many asteroids, return
3$:     lda     starting_saucerCountdownTimer
        suba    #6
        cmpa    #32
        bcs     4$
        sta     starting_saucerCountdownTimer
4$:     clra
        sta     saucer_PLh
        sta     saucer_PHh
        jsr     update_prng                             ; random position
        lsra
        ror     saucer_PLv
        lsra
        ror     saucer_PLv
        lsra
        ror     saucer_PLv
        cmpa    #24
        bcs     5$
        anda    #23
5$:     sta     saucer_PHv
        ldb     #0x10
        ; 6502 code was BIT rnd2; bvs which simply tests rnd2:6
        lda			*rnd2
        bita		#(1<<6)
        bne			6$
        lda     #0x1F
        sta     saucer_PHh
        lda     #0xFF
        sta     saucer_PLh
        ldb     #0xF0                             			; fixed velocity
6$:     stb     saucer_Vh
        ldb     #2                                      ; large saucer
        lda     starting_saucerCountdownTimer
        bmi     8$
        lda     *curPlayer_x2                           
        ldy     #dp_base+p1ScoreThousands
        lda			a,y																			; p1/p2 score
        cmpa    #0x30                             			; score over 30,000?
        bcc     7$                                			; yes, skip (always small saucer)
        jsr     update_prng
        sta     *byte_8
        lda     starting_saucerCountdownTimer
        lsra
        cmpa    *byte_8
        bcc     8$
7$:     decb
8$:     stb     saucer_Sts
        rts

handle_existing_saucer:
        lda     *fastTimer
        asla
        bne     1$
        jsr     update_prng                             ; random Vv
        anda    #3                                      ; 0-3
        ldx			#saucer_Vv_tbl
        lda			a,x																			; get entry
        sta     saucer_Vv
1$:   	lda     *numPlayers
        beq     2$			                                ; no, skip
        lda     shipSpawnTimer                          ; ship spawning?
        bne     9$                             					; yes, skip
2$:     dec     saucerCountdownTimer
        beq     loc_6C54
9$:     rts

loc_6C54:
        lda     #10
        sta     saucerCountdownTimer
        lda     saucer_Sts
        lsra                                            ; small saucer?
        beq     handle_small_saucer                     ; yes, go
        jsr     update_prng                             ; random shot direction
        jmp     update_shot_direction

handle_small_saucer:
        lda     saucer_Vh
        cmpa    #0x80
        rora
        sta     *byte_C
        lda     ship_PLh
        suba    saucer_PLh
        sta     *byte_B
        lda     ship_PHh
        sbca    saucer_PHh
        asl     *byte_B
        rola
        asl     *byte_B
        rola
        suba    *byte_C
        ldb     saucer_Vv
        cmpb    #0x80
        rorb
        stb     *byte_C
        ldb     ship_PLv
        subb    saucer_PLv
        stb     *byte_B
        ldb     ship_PHv
        sbcb    saucer_PHv
        asl     *byte_B
        rolb
        asl     *byte_B
        rolb
        subb    *byte_C
        jsr     loc_76F0
        sta     *saucerShotDirection
        jsr     update_prng
        ldb     *curPlayer_x2
        ldx     #dp_base+p1ScoreThousands
        ldb			b,x
        cmpb    #0x35                              			; score over 35,000?
        ldb     #0
        bcs     1$                                			; no, skip
        incb
1$:     ldx			#unk_6CCF
				anda    b,x
        bpl     2$
        ldx			#unk_6CD1
        ora     b,x
2$:     adda    *saucerShotDirection

update_shot_direction:
        sta     *saucerShotDirection
        ldy     #3
        ldx     #1
        stx     *byte_E
        jmp     find_free_shot_slot

unk_6CCF:                       
				.BYTE 0x8F, 0x87
unk_6CD1:                       
				.BYTE 0x70, 0x78
saucer_Vv_tbl:                  
				.byte 	0xF0, 0x00, 0x00, 0x10

; $6CD7
handle_fire:
				lda     *numPlayers				     									; game active?
				beq     locret_6CFC  														; no, exit
				asl     FireSwitch				     									; fire button to C
				ror     *btn_edge_debounce			     						; shift into bit 7
				lda     *btn_edge_debounce
				anda    #0xC0                                   ; bits 7,6 only
				cmpa    #0x80                                   ; bit 7=1,6=0?
				bne     locret_6CFC															; no, exit
				lda     shipSpawnTimer			     								; ship spawning?
				bne     locret_6CFC															; yes, exit
				ldx			#0																			; offset=player
				ldy     #3					     												; offset shot0 timer - 1
				sty     *byte_E
				ldy     #7					     												; offset shot3 timer

; $6CF2
find_free_shot_slot:                                                            
        lda     ship_Sts,Y															; get shot timer
        beq     new_shot_fired                          ; not active, go
        leay		-1,y                                    ; next shot timer
        cmpy    *byte_E                                 ; done all shot timers?
        bne     find_free_shot_slot                     ; no, loop
locret_6CFC:
        rts

; $6CFD
; X=offset player/saucer, Y=offset shot
new_shot_fired:
				stx			*byte_D																	; offset player/saucer
				lda	    #18
				sta	    ship_Sts,y				                      ; init shot timer
				lda     dp_base+direction,x                     ; ship/saucer direction
				jsr	    cos_A																		; h component
				asra
				sta	    *byte_9
				adda    ship_Vh,x				                        ; add Vh ship/saucer
				bmi	    1$
				cmpa    #112					                          ; less than 112?
				bcs	    2$				                              ; yes, skip
				lda	    #111					                          ; max =	111
				bra	    2$
1$:		  cmpa    #-111                                   ; less than -111?
				bcc	    2$				                              ; yes, skip
				lda	    #-111					                          ; min = -111
2$:			sta	    ship_Vh,Y                               ; update shot Vh
				lda     dp_base+direction,x				              ; ship/saucer direction
				jsr	    sin_A																		; v component
				asra
				sta	    *byte_C
				adda	  ship_Vv,x																; add Vv ship/saucer
				bmi	    3$
				cmpa	  #112					                          ; less than 112?
				bcs	    4$				                              ; no, skip
				lda	    #111					                          ; min =	111
				bne	    4$
3$:			cmpa	  #-111                                   ; less than -111?
				bcc	    4$				                              ; no, skip
				lda	    #-111					                          ; min = -111
4$:			sta	    ship_Vv,Y                               ; update shot Vv
				ldx	    #0
				lda	    *byte_9
				bpl	    5$
				leax    -1,x
5$:			stx	    *byte_8
				ldx	    *byte_D
				asra
				adda	  *byte_9
				adda	  ship_PLh,X				                      ; ship/saucer Ph
				sta	    ship_PLh,Y				                      ; update shot Ph
				lda	    *byte_8
				adca	  ship_PHh,X				                      ; ship/saucer Ph
				sta	    ship_PHh,Y				                      ; update shot Ph
				ldx	    #0                                      
				lda	    *byte_C                                 
				bpl	    6$                                      
				leax    -1,x                                    
6$:			tfr			x,d                                     
				stb	    *byte_B                                 
				ldx	    *byte_D                                 
				asra                                            
				adda	  *byte_C                                 
				adda	  ship_PLv,X				                      ; ship/saucer Pv
				sta	    ship_PLv,Y				                      ; update shot Pv
				lda	    *byte_B                                 
				adca	  ship_PHv,X				                      ; ship/saucer Pv
				sta	    ship_PHv,Y				                      ; update shot Pv
				lda	    #0x80
				sta	    dp_base+timerPlayerFireSound,X
				rts
				
; $6D90
handle_high_score_entry:
        lda     *placeP1HighScore
        anda    *placeP2HighScore
        bpl     high_score_entry
				rts

; $6D97
high_score_entry:
        lda     *numPlayersPreviousGame
        lsra
        beq     2$
        ldb     #1                                      ; "PLAYER"
        jsr     PrintPackedMsg
        lda     #2
        ldb     *placeP2HighScore
        bpl     1$
        deca
1$:     sta     *curPlayer
        ldb     *fastTimer
        andb    #0x10
        bne     2$
        jsr     display_digit_A
2$:     lsr     *curPlayer
        jsr     set_RAMSEL_for_player
        ldb     #2                                      ; "YOUR SCORE IS ONE OF THE TEN BEST"
        jsr     PrintPackedMsg
        ldb     #3                                      ; "PLEASE ENTER YOUR INITIALS"
        jsr     PrintPackedMsg
        ldb     #4                                      ; "PUSH ROTATE TO SELECT LETTER"
        jsr     PrintPackedMsg
        ldb     #5                                      ; "PUSH HYPERSPACE WHEN LETTER IS CORRECT"
        jsr     PrintPackedMsg
        lda     #0x20
        sta     *globalScale
        lda     #100
        ldb     #57
        jsr     write_CURx4_cmd
        lda     #0x70
        ;jsr     set_scale_A_bright_0
        ldb     *curPlayer
        ldx     #dp_base+placeP1HighScore
        ldb     b,x
        stb     *byte_B
        tfr     b,a
        adda    *letterHighScoreEntry
        sta     *byte_C
        jsr     display_initial
        ldb     *byte_B
        incb
        jsr     display_initial
        ldb     *byte_B
        incb
        incb
        jsr     display_initial
        lda     hyperspaceSwitch                        ; read hyperspace button
        rola                                            ; shift into C
        rol     *btn_edge_debounce                      ; shift into bit0
        lda     *btn_edge_debounce
        anda    #0x1F                                   ; low 5 bits
        cmpa    #7                                      ; 00111?
        bne     5$                                      ; no, exit
        inc     *letterHighScoreEntry
        lda     *letterHighScoreEntry
        cmpa    #3
        bcs     4$
        ldb     *curPlayer
        lda     #0xFF
        ldx     #dp_base+placeP1HighScore
        sta     b,x
3$:     ldb     #0
        stb     *curPlayer
        stb     *letterHighScoreEntry
        ldb     #0xF0
        stb     *slowTimer
        jmp     set_RAMSEL_for_player
        
4$:     inc     *byte_C
        ldb     *byte_C
        lda     #0xF4
        sta     *slowTimer
        lda     #0x0B
        ldx     #dp_base+highScoreInitials
        sta     b,x
5$:     lda     *slowTimer
        bne     6$
        lda     #0xFF
        sta     *placeP1HighScore
        sta     *placeP2HighScore
        bra     3$
6$:     lda     *fastTimer
        anda    #7
        bne     13$
        lda     rotateLeftSwitch
        bpl     7$
        lda     #1
        bne     8$
7$:     lda     rotateRightSwitch
        bpl     13$
        lda     #0xFF
8$:     ldb     *byte_C
        ldx     #dp_base+highScoreInitials
        adda    b,x
        bmi     10$
        cmpa    #0x0B
        bcc     11$
        cmpa    #1
        beq     9$
        lda     #0
        bra     12$
9$:     lda     #0x0B
        bne     12$
10$:    lda     #0x24
11$:    cmpa    #0x25
        bcs     12$
        lda     #0
12$:    sta     b,x
13$:    lda     #0
        rts
        
; $6E74
handle_hyperspace:
        lda     *numPlayers
        beq     9$                                      ; not a real game, exit
        lda     ship_Sts
        bmi     9$                                      ; exploding, exit
        lda     shipSpawnTimer
        bne     9$
        lda     hyperspaceSwitch                        ; button pressed?
        bpl     9$                                      ; no, exit
        lda     #0                                      ; flag hyperspace?
        sta     ship_Sts
        sta     ship_Vh
        sta     ship_Vv                                 ; zero ship velocity
        lda     #48
        sta     shipSpawnTimer
        jsr     update_prng                             ; random horizontal position
        anda    #0x1F
        cmpa    #29
        bcs     1$
        lda     #28                                     ; max=28
1$:     cmpa    #3
        bcc     2$
        lda     #3                                      ; min=3
2$:     sta     ship_PHh                                ; 3-28
        ldb     #5
3$:     jsr     update_prng                             ; random vertical position
        decb
        bne     3$
        anda    #0x1F
        incb                                            ; =1 (successful)
        cmpa    #24
        bcs     4$
        anda    #7
        asla
        adca    #4
        cmpa    currentNumberOfAsteroids
        bcs     4$
        ldb     #0x80                                   ; flag unsuccessful (death)
4$:     cmpa    #21
        bcs     5$
        lda     #20                                     ; max=20
5$:     cmpa    #3
        bcc     6$
        lda     #3                                      ; min=3
6$:     sta     ship_PHv                                ; 3-20
        stb     *hyperspaceFlag
9$:		  rts
																
; $6ED8
init_players:
				lda			#2
				sta			startingAsteroidsPerWave
				ldb			#STARTING_SHIPS
				; the original code did LSR on the hardware (dip) location
				; - of course if we do that on our RAM shadow, it'll change
				; - so load it into A first
				lda			centerCoinMultiplierAndLives
				lsra
				bcs			1$
				incb
1$:			stb			*numStartingShipsPerGame
				lda			#0
				ldx			#4																			; 4 flags, 4 timers, 4 score bytes
2$:			sta			ship_Sts,x
				sta			shipShot_Sts,x
				sta			dp_base+byte_4F+2,x
				leax    -1,x
				cmpx    #0
				bpl			2$																			; loop until done
				sta			currentNumberOfAsteroids
				rts
						
; $6EFA
init_sound:
        ; UNIMPLEMENTED
				rts

; $6F1A
; B=offset into initials
display_initial:
        ldy     #dp_base+highScoreInitials
        lda     b,y                                     ; get initial
        asla                                            ; convert to char code
        bne     display_char_code_A                     ; no, display
        ldb     *placeP1HighScore
        andb    *placeP2HighScore                       ; entered as <space>?
        bmi     display_char_code_A                     ; yes, display
.ifdef PLATFORM_COCO3
				lda			#(38<<1)																; underscore
				jmp			display_char_code_A
.else
        LDA     #$72 ; 'r'                              ; brightness=7, S=0, X=2
        LDX     #$F8 ; 'ø'                              ; cmd=SVEC, s=-ve, Y=0
        JSR     write_AX_to_avgram
        LDA     #1                                      ; brightness=0, S=0, X=0
        LDX     #$F8 ; 'ø'                              ; cmd=SVEC, s=-ve, Y=0
        JMP     write_AX_to_avgram
.endif
        
; $6F35
display_char_code_A:
.ifdef PLATFORM_COCO3
     		ldy			*dvg_curr_addr_msb
				ldb			#OP_CHR
        stb     ,y+
        sta     ,y+
				sty     *dvg_curr_addr_msb
.else
        LDX     DVGROM+$6D5,Y                           ; chr fn
        LDA     DVGROM+$6D4,Y                           ; chr fn
        JMP     write_AX_to_avgram
.endif                                
        rts
        
; $6F3E
display_extra_ships:
        beq     9$
        stb     *byte_8
        ldb     #0xE0
        stb     *globalScale
        ldb     #213                                    ; Y coord (x4=852)
        jsr     write_CURx4_cmd

.ifdef PLATFORM_COCO3
        lda     #OP_LIFE
     		ldy			*dvg_curr_addr_msb
1$:			sta			,y+
				sta			,y+
        dec     *byte_8
        bne     1$
        sty			*dvg_curr_addr_msb
.else
1$:     ldx     #$DA ; 'Ú'
        lda     #$54 ; 'T'                              ; addr=0x54DA
        jsr     write_JSR_cmd                           ; display extra ships?
        dec     byte_8
        bne     1$
.endif                                
9$:			rts

; $6F57
update_and_render_objects:
        ldx     #34                                     ; 34 objects to update
loc_6F59:                                               ; get entry
        lda     P1RAM,X
        bne     handle_object_entry                     ; non-zero entry, handle it
next_object:                                            
        leax		-1,x
        cmpx		#0																			; next value
        bpl     loc_6F59                                ; loop 'til done
				rts
				
handle_object_entry:                                                            
        bpl     object_ok																; status < 128, go
        nega
        lsra
        lsra
        lsra
        lsra
        cmpx    #0x1B                                   ; playerFlag?
        bne     1$                                			; no, skip
        lda     *fastTimer
        anda    #1
        lsra
        beq     2$																			; always
1$:     sec
2$:     adca    P1RAM,X
        bmi     6$
        cmpx    #0x1B                                   ; playerFlag?
        beq     4$                                			; yes, go
        bcc     5$
        dec     currentNumberOfAsteroids
        bne     3$
        lda     #0x7F
        sta     asteroidWaveTimer
3$:     lda     #0
        sta     P1RAM,X
        beq     next_object															; always
4$:     jsr     init_ship_position_velocity
        jmp     3$
5$:     lda     starting_saucerCountdownTimer
        sta     saucerCountdownTimer
        bne     3$
6$:     sta     P1RAM,X
        anda    #0xF0
        adda    #0x10
        cmpx    #0x1B                                   ; PlayerFlag?
        bne     7$                                			; no, skip
        lda     #0
7$:     tfr			a,b
        lda     asteroid_PLh,X
        sta     *byte_4
        lda     asteroid_PHh,X
        sta     *byte_5
        lda     asteroid_PLv,X
        sta     *byte_6
        lda     asteroid_PHv,X
        sta     *byte_7
        jmp     jsr_display_object

; $6FC7
object_ok:
				ldb			#0
				lda			asteroid_Vh,X														; object Vh
				bpl			1$																			; +ve, skip
				decb
1$:			adda		asteroid_PLh,X													; object Ph += Vh
				sta			asteroid_PLh,X
				sta			*byte_4
				adcb		asteroid_PHh,X													; object Ph += Vh
				cmpb		#32																			; max?
				bcs			2$																			; no, skip
				andb		#31																			; max=31
				cmpx		#0x1C																		; SaucerFlag?
				bne			2$																			; no, go
				jsr			zero_saucer
				jmp			next_object
2$:			stb			asteroid_PHh,X
				stb			*byte_5
				ldb			#0
				lda			asteroid_Vv,X														; object Vv
				bpl			3$																			; +ve, skip
				ldb			#0xFF
3$:			adda		asteroid_PLv,X													; object Pv += Vv
				sta			asteroid_PLv,X
				sta			*byte_6
				adcb		asteroid_PHv,X													; object Pv += Vv
				cmpb		#24																			; max?
				bcs			5$																			; no, skip
				beq			4$
				ldb			#23																			; max=23
				bra			5$																			; (always)
4$:			ldb			#0
5$:			stb			asteroid_PHv,X
				stb			*byte_7
				lda			P1RAM,X																	; object status
				ldb			#0xE0																		; scale (-2)
				lsra																						; status bit 0
				bcs			jsr_display_object											; b0=1,	go
				ldb			#0xF0																		; scale (-1)
				lsra																						; status bit 1
				bcs			jsr_display_object											; b1=1,	go
				ldb			#0																			; scale (0)

; $7027
jsr_display_object:
        jsr     display_object
        jmp     next_object

; $702D
zero_saucer:
        lda     starting_saucerCountdownTimer
        sta     saucerCountdownTimer
        lda     #0
        sta     saucer_Sts
        sta     saucer_Vh
        sta     saucer_Vv
        rts

; $703F
handle_respawn_rot_thrust:
				lda			*numPlayers
				beq			locret_7085
				lda			ship_Sts
				bmi			locret_7085															; exploding - exit
				lda			shipSpawnTimer
				beq			check_rot_left
				dec			shipSpawnTimer													; still	spawning?
				bne			locret_7085															; yes, exit
				ldb			*hyperspaceFlag
				bmi			loc_706F																; unsuccessful - go
				bne			end_hyperspace													; successful - go
				jsr			check_near_objs_and_extend_spawn				; objects too close?
				bne			loc_7081																; yes, exit
				ldb			saucer_Sts
				beq			end_hyperspace													; no saucer - go
				ldb			#2
				stb			shipSpawnTimer
				rts

end_hyperspace:									
				lda			#1																			; flag alive and active
				sta			ship_Sts
				bra			loc_7081																; always go
            		
loc_706F:														
				lda			#0xA0																		; flag exploding
				sta			ship_Sts
				ldb			#0x3E
				stb			*timerExplosionSound
				ldb			*curPlayer
				ldx			#dp_base+numShipsP1
				dec			b,x																			; dec number of	ships
				lda			#129
				sta			shipSpawnTimer
            		
loc_7081:											
				lda			#0																			; flag inactive
				sta			*hyperspaceFlag

locret_7085:
				rts

; $7086
check_rot_left:
				lda			rotateLeftSwitch
				bpl			check_rot_right													; no, skip
				lda			#3
				bne			update_dir															; always go

check_rot_right:																				
				lda			rotateRightSwitch												; right	button?
				bpl			check_thrust														; no, skip
				lda			#0xFD																		; -3
            		
update_dir: 		
				adda		*direction															; calc direction
				sta			*direction															; update

check_thrust:
				lda			*fastTimer
				lsra
				bcs			locret_7085															; exit
				lda			thrustSwitch														; thrust button?
				bpl			3$																			; no, go
				lda			#0x80
				;sta			$3C03																		; sound	(ship thrust)
				ldb			#0																			; ??=0
				lda			*direction
				jsr			cos_A
				bpl			1$
				decb 																						; ??=-1
1$:			asla
				adda		*ship_thrust_dH													; add COS term to dH
				exg			a,b																			; B=new dH, A=0/-1
				adca		ship_Vh																	; if cos<0 Vh--
				jsr			limit_thrust
				sta			ship_Vh
				stb			*ship_thrust_dH
				ldb			#0
				lda			*direction
				jsr			sin_A
				bpl			2$
				decb
2$:			asla
				adda		*ship_thrust_dV
				exg			a,b																			; B=dV, A=0/-1
				adca		ship_Vv
				jsr			limit_thrust
				sta			ship_Vv
				stb			*ship_thrust_dV
				rts
3$:			lda			#0
				;sta			$3C03																		; sound	(ship thrust)
				lda			ship_Vh
				ora			*ship_thrust_dH
				beq			5$
				lda			ship_Vh
				asla
				ldb			#0xFF
				CLC
				coma
				bmi			4$
				incb
				SEC
4$:			adca		*ship_thrust_dH
				sta			*ship_thrust_dH
				adcb		ship_Vh
				stb			ship_Vh
5$:			lda			*ship_thrust_dV
				ora			ship_Vv
				beq			7$
				lda			ship_Vv
				asla
				ldb			#0xFF
				CLC
				coma
				bmi			6$
				SEC
				incb 		
6$:			adca		*ship_thrust_dV
				sta			*ship_thrust_dV
				adcb		ship_Vv
				stb			ship_Vv
7$:			rts

; $7125
; A=Velocity, B=dVelocity
limit_thrust:
        bmi     1$
        cmpa    #64
        bcs     2$
        ldb     #0xFF
        lda     #63
        rts
1$:     cmpa    #192
        bcc     2$
        ldb     #1
        lda     #192
2$:     rts

; $7139
check_near_objs_and_extend_spawn:
				ldx			#28																			; 29 objects to	check
1$:			lda			P1RAM,x																	; get object status
				beq			3$																			; not active, skip
				lda			asteroid_PHh,x
				suba		ship_PHh
				cmpa		#4																			; object, ship PHh within 4?
				bcs			2$																			; yes, go
				cmpa		#0xFC
				bcs			3$																			; no, skip
2$:			lda			asteroid_PHv,x
				suba		ship_PHv
				cmpa		#4																			; object, ship PHv within 4?
				bcs			extend_spawn														; yes, go
				cmpa		#0xFC
				bcc			extend_spawn														; yes, go
3$:			leax		-1,x
				cmpx		#0
				bpl			1$																			; loop thru all	objects
				clrb																						; B=0, set Z flag
				rts

extend_spawn:									
				inc			shipSpawnTimer													; reset	Z flag
				rts
				
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
				bcs			loc_7187																; no, skip
				dec			numAsteroidsLeftBeforeSaucer						; adjust to max

loc_7187:
				lda			startingAsteroidsPerWave
				adda		#2																			; 2 more per wave
				cmpa		#11																			; max number of	asteroids?
				bcs			loc_7193																; OK, skip
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
				bcs			start_left
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
        lda     #0x60
        sta     ship_PLh
        sta     ship_PLv
        lda     #0
        sta     ship_Vh
        sta     ship_Vv                                 ; zero ship velocity
        lda     #0x10
        sta     ship_PHh                                ; x=$1060 = 4192
        lda     #0xC
        sta     ship_PHv                                ; y=$0C60 = 3168
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
				bcc			1$
				lda			#-31
1$:			cmpa		#-5
				bcs			9$
				lda			#-6
				rts
2$:			cmpa		#6
				bcc			3$
				lda			#6
3$:			cmpa		#32
				bcs			9$
				lda			#31
9$:			rts

; $724F
display_C_scores_ships:
				lda			#16
				sta			*globalScale
.ifdef PLATFORM_COCO3
        ldy     *dvg_curr_addr_msb
        ldb     #OP_COPYRIGHT
        stb			,y+
        stb			,y+
        sty     *dvg_curr_addr_msb
.else
				lda			#0x50
				ldx			#0xA4																		; addr = 0x50A4
				;jsr			write_JSR_cmd														; "(C)1979 ATARI INC"
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

; $72FE
; B = scale ($E0/$F0/$00)
display_object:
        stb     *globalScale
        stx     *byte_D                                 ; object offset (from P1RAM)
        lda     *byte_5                                 ; object_PHh
        lsra
        ror     *byte_4                                 ; object_PLh
        lsra
        ror     *byte_4
        lsra
        ror     *byte_4
        sta     *byte_5                                 ; object_Ph /= 8
        lda     *byte_7                                 ; object_PHv
        adda     #4
        lsra
        ror     *byte_6                                 ; object_PLv
        lsra
        ror     *byte_6
        lsra
        ror     *byte_6
        sta     *byte_7                                 ; object_PLv = (object_PLv+1024)/8
        ldx     #dp_base+4                              ; base of temp coordinates
        jsr     write_CUR_cmd
        lda     #0x70
        suba    globalScale
        cmpa    #0xA0
        bcc     2$
1$:     pshs		a
        lda     #0x90
        ;jsr     set_scale_A_bright_0
        puls		a
        suba    #0x10
        cmpa    #0xA0
        bcs     1$
2$:     ;jsr     set_scale_A_bright_0
        ldx     *byte_D                                 ; restore object offset
        lda     P1RAM,X                                 ; object status (again)
        bpl     display_shot_ship_asteroid_or_saucer
        cmpx    #0x1B                                   ; PlayerFlag?
        beq     loc_7355                                ; yes, go
        anda    #0x0C                                   ; status (3:2)
        lsra                                            ; status (3:2)->(2:1)
.ifdef PLATFORM_COCO3                                
        ldy     *dvg_curr_addr_msb
        ldb     #OP_SHRAPNEL
        stb			,y+
        sta			,y+
        sty			*dvg_curr_addr_msb
.else
        TAY                                             ; pattern = word offset
        LDA     DVGROM+$F8,Y                            ; shrapnel table address LSB
        LDX     DVGROM+$F9,Y                            ; shrapnel table address MSB
.endif                                
        bra     loc_7370                                ; always

loc_7355:
        jsr     display_exploding_ship
        ldx     *byte_D                                 ; restore object offset
				rts

display_shot_ship_asteroid_or_saucer:
        cmpx    #0x1B																		; PlayerFlag?
        beq     display_ship                            ; yes, go
        cmpx    #0x1C                                   ; SaucerFlag?
        beq     display_saucer                          ; yes, go
        bcc     display_shot                            ; shot, go
.ifdef PLATFORM_COCO3
        ldy     *dvg_curr_addr_msb
        ldb     #OP_ASTEROID
        stb			,y+
        sta			,y+
        sty			*dvg_curr_addr_msb
loc_7370:
.else
        AND     #$18                                    ; status (4:3)
        LSR     A
        LSR     A                                       ; status (4:3)->(2:1)
        TAY                                             ; = word offset
        LDA     DVGROM+$1DE,Y                           ; asteroid table address LSB
        LDX     DVGROM+$1DF,Y                           ; asteroid table address MSB

loc_7370:                                                                       
        JSR     write_AX_to_avgram											; writes JSR instruction
.endif                                
				ldx			*byte_D
				rts

; $7376
display_ship:
				jsr			calc_ship_and_render
				ldx			*byte_D
				rts

; $737C
display_saucer:
.ifdef PLATFORM_COCO3
        ldy     *dvg_curr_addr_msb
        ldb     #OP_SAUCER
        stb			,y+
        sta			,y+
        sty     *dvg_curr_addr_msb
.else
        lda     DVGROM+$250
        ldx     DVGROM+$251                             ; saucer table address MSB
.endif                                
        bra			loc_7370                                ; always

; $7384
display_shot:
.ifdef PLATFORM_COCO3
        ldy     *dvg_curr_addr_msb
        ldb     #OP_SHOT
        stb			,y+
        clr			,y+
        sty     *dvg_curr_addr_msb
.else
; missing        
.endif
				ldx			*byte_D                                 ; restore object offset
				lda     *fastTimer
				anda    #3                                      ; time to dec?
				bne     1$                                      ; no, skip
				dec     P1RAM,x
1$:			rts

; $7397
; A=score, B=curPlayer_x2
add_A_to_score:
				ldu			#dp_base+p1ScoreTens
				adda		b,u
				daa
				sta			b,u
        bcc     1$
        ldu			#dp_base+p1ScoreThousands
        lda     b,u
        adca    #0
        daa
        sta     b,u
        anda    #0x0F                                   ; another 10,000?
        bne     1$                                			; no, skip
        lda     #0xB0
        sta     *timerBonusShipSound
        ldb     *curPlayer
        ldu			#dp_base+numShipsP1
        inc     b,u                            					; extra ship!
1$:     rts

; $73B2
set_RAMSEL_for_player:
        ; IMPLEMENTATION_NOT_REQD
        rts
        
; $73C4
display_high_score_table:
        lda     *numPlayers                             ; game active?
        beq     2$                                      ; no, skip
1$:     CLC                                             ; flag game active
        rts
2$:     lda     *slowTimer
        anda    #4
        bne     1$
        lda     *highScoreTable
        ora     *highScoreTable+1
        beq     1$
        ldb     #0                                      ; "HIGH SCORES"
        jsr     PrintPackedMsg
        ldb     #0
        stb     *initial_offset                         ; offset into initials
        ldx     #0
        lda     #1
        sta     *globalScale
        lda     #167                                    ; starting Y coord (x4=668)
        sta     *byte_E
        lda     #16
        sta     *globalScale

display_hs_entry:
        lda     dp_base+highScoreTable,X
        ora     dp_base+highScoreTable+1,X              ; end of table?
        beq     9$                                      ; yes, exit
        stx     *byte_F                                 ; entry counter (x2)
        lda     #95                                     ; x coord (x4=380)
        ldb     *byte_E                                 ; y coord
        jsr     write_CURx4_cmd
        lda     #0x40                                   ; S=4
        ;jsr     set_scale_A_bright_0
        ldd     *byte_F                                 ; entry counter (x2)
        tfr     b,a
        lsra                                            ; x1
        adda    #1
        daa
        sta     *byte_D                                 ; number buffer for printing
        lda     #byte_D                                 ; ptr number buffer
        SEC                                             ; flag no zero padding
        ldb     #1                                      ; 1 byte to print
        ldx     #0                                      ; extra brightness
        jsr     display_numeric                         ; display entry no.
.ifdef PLATFORM_COCO3
        lda			#(37<<1)																; period
.else
        LDA     #$40 ; '@'                              ; S=4
        TAX                                             ; Brightness=4
        JSR     set_scale_A_bright_X                    ; displays a dot???
        LDY     #0                                      ; <space>
.endif                                
        jsr     display_char_code_A
        ldd     *byte_F                                 ; entry counter (x2)
        tfr     b,a
        adda    #highScoreTable                         ; get ptr entry (score)
        ldb     #2                                      ; 2 bytes to print
        SEC                                             ; flag no zero padding
        ldx     #0                                      ; extra brightness
        jsr     display_numeric                         ; display score
        lda     #0
        jsr     display_digit_A
        lda     #0                                      ; <space>
        jsr     display_char_code_A
        ldb     *initial_offset                         ; get 1st initial
        jsr     display_initial
        inc     *initial_offset
        ldb     *initial_offset                         ; get 2nd initial
        jsr     display_initial
        inc     *initial_offset
        ldb     *initial_offset                         ; get 3rd initial
        jsr     display_initial
        inc     *initial_offset
        lda     *byte_E                                 ; y coord
        suba    #8                                      ; adjust for next line
        sta     *byte_E                                 ; update
        ldx     *byte_F                                 ; entry counter (x2)
        leax    2,x
        cmpx    #20                                     ; done all 10 entries?
        bcs     display_hs_entry                        ; no, loop
9$:     SEC
				rts

; $745A
get_inactive_asteroid_cnt:
        ldx     #26                                     ; 27 asteroids

get_inactive_object_cnt:
        lda     P1RAM,X                                 ; get object status
        beq     1$                             					; zero, exit
        leax		-1,x                                    ; next object
        cmpx		#0
        bpl     get_inactive_object_cnt                 ; loop thru table
1$:     rts
				
; $7465
display_exploding_ship:
        lda     ship_Sts
        cmpa    #0xA2                                   ; 2 frames past exploding?
        bcc     render_explosion
        ldx     #10                                     ; (5+1) entries

init_piece_tbl:
        lda     ship_explosion_pieces_velocity,x        ; piece velocity X
        lsra
        lsra
        lsra
        lsra                                            ; high->low nibble
        adda    #0xF8                                   ; -8
        eora    #0xF8
        sta     dp_base+byte_7E,x
        lda     ship_explosion_pieces_velocity+1,x      ; piece velocity Y
        lsra
        lsra
        lsra
        lsra                                            ; high->low nibble
        adda    #0xF8                                   ; -8
        eora    #0xF8
        sta     dp_base+byte_80+0x0A,x
        leax    -2,x
        cmpx    #0
        bpl     init_piece_tbl

render_explosion:
        ldb     ship_Sts
        eorb    #0xFF
        andb    #0x70
        lsrb
        lsrb
        lsrb                                            ; num pieces left (x2)
        clra
        tfr     d,x
        
render_piece:
        stx     *byte_9                                 ; piece number
        ldb     #0
        lda     ship_explosion_pieces_velocity,x        ; piece velocity X
        bpl     1$
        decb
1$:     adda    dp_base+byte_7D,x                       ; + piece X (low byte)
        sta     dp_base+byte_7D,X                       ; update
        tfr     b,a                                     ; 0/-1
        adca    dp_base+byte_7E,x                       ; + piece X (high byte)
        sta     dp_base+byte_7E,x                       ; update
        sta     *byte_4                                 ; piece X (high byte)
        stb     *byte_5                                 ; 0/-1
        ldb     #0
        lda     ship_explosion_pieces_velocity+1,x      ; piece velocity Y
        bpl     2$
        decb
2$:     adda    dp_base+byte_80+9,x                     ; + piece Y (low byte)
        sta     dp_base+byte_80+9,x                     ; update
        tfr     b,a                                     ; 0/-1
        adca    dp_base+byte_80+0x0A,x                  ; + piece Y (high byte)
        sta     dp_base+byte_80+0x0A,x                  ; update
        sta     *byte_6                                 ; piece Y (high byte)
        stb     *byte_7                                 ; 0/-1
        ldy     *dvg_curr_addr_msb
        sty     *byte_B
        ; Norbert patches the code to call his routine
        ; - which uses byte_9 (piece #) to store byte_4, byte_6
        ;	 in a table, and then jumps to calc_and_goto_piece_position
.ifdef PLATFORM_COCO3
        ; we have X/byte_9 is the piece number
        ; byte_4 and byte_6 are X,Y coords (MSB) respectively
        ; CUR will be the ship position
        ; - note we have to offset by (+8,+8)
        lda     #OP_EXPLODINGSHIP
        sta     ,y+
        ldd     *byte_9                                 ; piece index
        stb     ,y+
        lda     *byte_4                                 ; X offset
        ldb     *byte_6                                 ; Y offset
        std     ,y++
        sty     *dvg_curr_addr_msb
.else
        jsr     calc_and_goto_piece_position
        ldy     byte_9
        lda     DVGROM+$E0,Y                            ; wrecked ship table address LSB
        ldx     DVGROM+$E1,Y                            ; wrecked ship table address MSB
        jsr     write_AX_to_avgram
        ldy     byte_9
        lda     DVGROM+$E1,Y                            ; wrecked ship table address MSB
        eor     #4
        tax
        lda     DVGROM+$E0,Y                            ; wrecked ship table address LSB
        and     #$F
        eor     #4
        jsr     write_AX_to_avgram
        ldy     #$FF

goto_ship_origin:
        iny
        lda     (byte_B),Y
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        iny
        lda     (byte_B),Y
        eor     #4
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        cpy     #3
        bcc     loc_74F1
        jsr     update_dvg_curr_addr
.endif        
        ldx     *byte_9
        leax    -2,x
        cmpx    #0
        bpl     render_piece
				rts

; $750B
calc_ship_and_render:
        ;ldb     #0                                      ; default positive delta
        clr     *extra_brightness
        ;ldb     #0                                      ; default positive delta
        lda     *direction
.ifdef PLATFORM_COCO3                                
				ldy			*dvg_curr_addr_msb
        ldb			thrustSwitch
        bpl			1$
        ldb			*fastTimer
        andb		#4
        beq			1$
        ldb			#OP_SHIP_THRUST
        bra			2$
1$:     ldb     #OP_SHIP
2$:     stb     ,y+
				sta			,y+
        sty     *dvg_curr_addr_msb
.else
        BPL     loc_751B                                ; positive, skip
        LDY     #4                                      ; flag negative delta
        TXA                                             ; 0
        SEC
        SBC     direction

loc_751B:                                                                       ; ABS(direction)
        STA     byte_8
        BIT     byte_8
        BMI     loc_7523                                ; b7=1
        BVC     loc_752A                                ; b6=0

loc_7523:                                                                       ; flag negative delta
        LDX     #4
        LDA     #$80 ; '€'
        SEC
        SBC     byte_8

loc_752A:                                                                       ; flag for flip X
        STX     byte_8
        STY     byte_9                                  ; flag for flip Y
        LSR     A
        AND     #$FE ; 'þ'
        TAY
        LDA     DVGROM+$26E,Y                           ; ship table address LSB
        LDX     DVGROM+$26F,Y                           ; ship table address MSB
        JSR     copy_vector_list_from_table_to_dvgram
        LDA     thrustSwitch                            ; thrust?
        BPL     locret_7554                             ; no, exit
        LDA     fastTimer
        AND     #4                                      ; time to display thrust?
        BEQ     locret_7554                             ; no, exit
        INY
        INY                                             ; Y=2???
        SEC
        LDX     byte_C
        TYA
        ADC     byte_B
        BCC     loc_7551
        INX                                             ; BC+=2

loc_7551:
		    JSR     copy_vector_list_from_table_to_dvgram
.endif                                
locret_7554:
				rts
				
; $7555
handle_sounds:
        ; UNIMPLEMENTED
				rts

; $755A
update_sounds:
        ; UNIMPLEMENTED
        rts
        
; $75CD
update_player_saucer_sound:
        ; UNIMPLEMENTED
        rts
        
; $75EC
; X=offset to object that hit asteroid, Y=offset to asteroid
; - potentially adds 2 more asteroids to the table
;   but note that the original asteroid object entry remains
handle_asteroid_hit:
        stx     *byte_D                                 ; save object index
        lda     #80
        sta     asteroid_hit_timer
        lda     P1RAM,Y                                 ; asteroid status
        anda    #0x78                              			; bits 6-3 only
        sta     *byte_E
        lda     P1RAM,Y                                 ; asteroid status
        anda    #7                                      ; bits 2-0 only
        lsra                                           	; next size down
        tfr			a,b                                     ; asteroid size
        beq     1$                                			; small, skip
        ora     *byte_E
1$:     sta     P1RAM,Y																	; update asteroid status
        lda     *numPlayers                             ; real game?
        beq     handle_asteroid_split                   ; no, skip
        cmpx		#0																			; object index
        beq     add_asteroid_score                      ; ship!
        cmpx    #4                                      ; player shot?
        bcs     handle_asteroid_split                   ; no, skip score

add_asteroid_score:                                                             
        ldx     #asteroid_score_tbl
        lda     b,x										                  ; score for this asteroid size
        ldb     *curPlayer_x2                           ; offset to score for player
        CLC
        jsr     add_A_to_score                          ; add asteroid score

handle_asteroid_split:                                                          
        tst     P1RAM,Y																	; asteroid status
        beq     1$                                			; small, no split, exit
        jsr     get_inactive_asteroid_cnt               ; X = empty slot
        bmi     1$                                			; no slots, exit
        inc     currentNumberOfAsteroids                ; add another asteroid
        jsr     clone_asteroid_rnd_shape
        jsr     set_asteroid_velocity
        lda     asteroid_Vh,X
        anda    #0x1F
        asla                                            ; twice as fast
        eora    asteroid_PLh,X
        sta     asteroid_PLh,X
        jsr     get_inactive_object_cnt                 ; any slots left?
        bmi     1$                                			; no, exit
        inc     currentNumberOfAsteroids                ; add another asteroid
        jsr     clone_asteroid_rnd_shape
        jsr     set_asteroid_velocity
        lda     asteroid_Vv,X
        anda    #0x1F
        asla                                            ; twice as fast
        eora    asteroid_PLv,X
        sta     asteroid_PLv,X
1$:     ldx     *byte_D                                 ; restore object index
        rts

asteroid_score_tbl:
        .byte 	0x10                                    ; 100pts (small asteroid)
        .byte   5                                       ; 50pts (medium asteroid)
        .byte   2                                       ; 20pts (large asteroid)
				
; $765C
check_high_score:
        lda     *numPlayers                             ; game active?
        bpl     locret_7698                             ; yes, skip
        ldx     #2                                      ; 2 players to check
        sta     *slowTimer
        sta     *placeP1HighScore
        sta     *placeP2HighScore
loc_7668:
        ldy     #0
1$:     lda     dp_base+highScoreTable,Y
        cmpa    dp_base+p1ScoreTens,X
        lda     dp_base+highScoreTable+1,Y
        sbca    dp_base+p1ScoreThousands,X
        bcs     insert_score_in_table                   ; high score here, exit
        leay    2,y                                     ; next high score entry
        cmpy    #20                                     ; done all 10 entries (20 bytes)?
        bcs     1$                                      ; no, loop

loc_767C:
        leax    -2,x                                    ; set to player 1
        cmpx    #0
        bpl     loc_7668                                ; loop for player 1
        lda     *placeP2HighScore
        bmi     2$
        cmpa    *placeP1HighScore
        bcs     2$
        adda    #3
        cmpa    #30
        bcs     1$
        lda     #0xFF
1$:     sta     *placeP2HighScore
2$:     lda     #0
        sta     *numPlayers                             ; flag game over
        sta     *letterHighScoreEntry
locret_7698:
				rts

; $7699
insert_score_in_table:
        stx     *byte_B
        sty     *byte_C                                 ; high score entry offset
        tfr     x,d
        lsrb                                            ; 0=p1, 1=p2
        tfr     d,x
        tfr     y,d
        lsrb                                            ; high score entry index
        addb    *(byte_C+1)                             ; high score index * 3
        std     *byte_D                                 ; offset into initials table?
        stb     dp_base+placeP1HighScore,X
        ldx     #27                                     ; offset of 10th initials
        ldy     #18
1$:     cmpx    *byte_D                                 ; entry we're after?
        beq     2$                                      ; yes, exit
        lda     dp_base+letterHighScoreEntry,X
        sta     dp_base+highScoreInitials,X
        lda     dp_base+placeP1HighScore,X
        sta     dp_base+highScoreInitials+1,X
        lda     dp_base+placeP2HighScore,X
        sta     dp_base+highScoreInitials+2,X
        lda     dp_base+byte_1B,Y
        sta     dp_base+highScoreTable,Y
        lda     dp_base+numPlayers,Y
        sta     dp_base+highScoreTable+1,Y              ; shift entry down
        leay    -2,y                                    ; next high score entry
        leax    -3,x                                    ; next initials entry
        bne     1$                                      ; not done, loop
2$:     lda     #0x0B
        sta     dp_base+highScoreInitials,X
        lda     #0
        sta     dp_base+highScoreInitials+1,X
        sta     dp_base+highScoreInitials+2,X
        lda     #0xF0
        sta     *slowTimer
        ldx     *byte_B                                 ; player 1/2
        ldy     *byte_C                                 ; high score entry offset
        lda     dp_base+p1ScoreThousands,X
        sta     dp_base+highScoreTable+1,Y
        lda     dp_base+p1ScoreTens,X
        sta     dp_base+highScoreTable,Y                ; copy score into high score table
        ldy     #0
        jmp     loc_767C                                ; continue with next entry

; $76F0
; A=?(X), B=?(Y)
; called from handle_small_saucer
loc_76F0:
				exg			a,b																			; swap???
				tsta
				bpl			1$
				nega
				jsr			1$
				nega
				rts
1$:			exg			a,b																			; swap 'em back
				tsta
				bpl			2$
				nega
				jsr			2$
				eora		#0x80
				nega
				rts
2$:			sta			*byte_C
				tfr			b,a
				cmpa		*byte_C
				beq			3$
				bcs			4$
				ldb			*byte_C
				sta			*byte_C
				tfr			b,a
				jsr			4$
				suba		#0x40
				nega
				rts
3$:			lda			#0x20
				rts
4$:			jsr			sub_776C                                ; A=offset
				ldu			#unk_772F
				lda			a,u
				rts 		

unk_772F:			
				.byte		0, 2, 5, 7, 0x0A, 0x0C, 0x0F
				.byte 	0x11, 0x13, 0x15, 0x17, 0x19, 0x1A, 0x1C, 0x1D, 0x1F
												
; $773F
; A=buffer, B=#bytes, X=extra brightness (not used)
display_numeric:
				pshs		cc
				;stx			*extra_brightness												; save extra brightness
				decb																						; #bytes-1
				stb			*byte_16																; offset to last byte
				adda		*byte_16																; buf +	#bytes-1
				;sta			*byte_15																; ptr current byte
				tfr     a,b
				tfr     dp,a
				tfr     d,u                                     ; U=buffer
				puls		cc
1$:			pshs		cc
				lda			0,u																			; get next byte
				lsra
				lsra
				lsra
				lsra																						; high nibble -> low
				puls		cc
				jsr			display_digit
				lda			*byte_16																; bytes	remaining?
				bne			2$																			; no, skip
				CLC																							; flag padding
2$:			lda			0,u																			; get byte (low	nibble)
				jsr			display_digit
				leau		-1,u																		; ptr current byte
				dec			*byte_16																; done?
				bpl			1$																			; no, loop
				rts

; $776C
sub_776C:
				clr			*byte_B
				ldb			#4
1$:			rol			*byte_B
				rola
				cmpa		*byte_C
				bcs			2$
				sbca		*byte_C
2$:			decb
				bne			1$
				lda			*byte_B
				rola
				anda		#0x0F
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
.ifdef PLATFORM_COCO3				
				ldy			*dvg_curr_addr_msb
				ldb			#OP_CHR
				stb			,y+
				sta			,y+
				sty			*dvg_curr_addr_msb
.else
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

; $77D2
cos_A:
        adda    #64                                     ; (0-127)=up, (128-255)=down

sin_A:
        bpl     1$                                			; up? go
        anda    #0x7F                              			; mask off up/down
        jsr     1$
        nega
        rts
1$:     cmpa    #65                                     ; left/right?
        bcs     2$                                			; right, go
        eora    #0x7F                              			; toggle up/down
        inca
2$:     
.ifdef PLATFORM_COCO3
				ldu			#sine_tbl
				lda			a,u
.else
        LDA     DVGROM+$7B9,X                           ; sine table
.endif                                
        rts

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
.ifdef PLATFORM_COCO3
        ldy			*dvg_curr_addr_msb
        ldb     #OP_CHR
        stb			,y+
        suba    #2                                      ; $6D2 vs $6D4!
        sta			,y+
        sty			*dvg_curr_addr_msb
.else
        TAX																							; X = chr*2 (chr fn offset)
        LDA     DVGROM+$6D2,X                           ; chr fn msb
        STA     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        INY
        LDA     DVGROM+$6D3,X                           ; chr fn lsb
        STA     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        INY
        LDX     #0
.endif                                
        rts

msgCoords:
				.byte 100, 182                                  ; "HIGH SCORES"
				.byte 100, 182                                  ; "PLAYER"
				.byte 12, 170                                   ; "YOUR SCORE...TEN BEST"
.ifdef PLATFORM_COCO3_NOT_REQD
        .byte 12, 162-4                                 ; "PLEASE...INITIALS"
        .byte 12, 154-8                                 ; "PUSH ROTATE...LETTER"
        .byte 12, 146-12                                ; "PUSH HYPERSPACE...CORRECT"
.else
        .byte 12, 162                                   ; "PLEASE...INITIALS"
        .byte 12, 154                                   ; "PUSH ROTATE...LETTER"
        .byte 12, 146                                   ; "PUSH HYPERSPACE...CORRECT"
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

; $7A93
handle_coin_switches:
        ; IMPLEMENTATION_NOT_REQD
        rts
        				
; $7B65
NMI:
        ; IMPLEMENTATION_NOT_REQD
        rts
        				
; $7BC0
halt_dvg:
.ifdef PLATFORM_COCO3
        lda     #OP_HALT
.else
        LDA     #$B0 ; '°'
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
.ifdef PLATFORM_COCO3
				ldy			*dvg_curr_addr_msb
        ldb     #OP_CHR
        stb     ,y+
        sta			,y+
        sty			*dvg_curr_addr_msb
.else
        ldy     #0
        tax
        lda     DVGROM+$6D4,X                           ; chr fn msb
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        lda     DVGROM+$6D5,X                           ; chr fn lsb
        iny
        sta     (dvg_curr_addr_lsb),Y                   ; store in avg ram
        jsr     update_dvg_curr_addr
.endif                                
        puls		cc
        rts

; $7BFC
write_JSR_cmd:
        ; IMPLEMENTATION_NOT_REQD
        rts
        
; $7C03
; A=X coord, B=Y coord
write_CURx4_cmd:
.ifdef PLATFORM_COCO3
				subb		#28
.endif				
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
.ifdef PLATFORM_COCO3
        ora     #OP_CUR
.else
        ORA     #$A0 ; ' '                              ; CUR command
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

; $7C49
calc_and_goto_piece_position:
        ; this code is relevant only to vector systems
        ; and is completely untested
        ; - so don't run it for now...
        rts
				lda	    *byte_5					                        ; piece	X 0/-1
				cmpa    #0x80                                   ; positive?
				bcs	    2$                                      ; yes, skip
				eora    #0xFF                                   ; negate
				sta	    *byte_5					                        ; piece	X sign
				lda	    *byte_4					                        ; piece	X (high	byte)
				eora	  #0xFF
				adca	  #0					                            ; negate
				sta	    *byte_4					                        ; update
				bcc	    1$
				inc	    *byte_5
1$:			SEC
2$:			rol     *byte_8
				lda	    *byte_7					                        ; piece	Y 0/-1
				cmpa	  #0x80                                   ; positive?
				bcs	    4$				                              ; yes, skip
				eora	  #0xFF					                          ; negate
				sta	    *byte_7					                        ; piece	Y sign
				lda	    *byte_6					                        ; piece	Y (high	byte)
				eora	  #0xFF
				adca	  #0					                            ; negate
				sta	    *byte_6					                        ; update
				bcc	    3$
				inc	    *byte_7
3$:			SEC
4$:		  rol	    *byte_8
				lda	    *byte_5					                        ; piece	X sign
				ora	    *byte_7					                        ; piece	Y sign
				beq	    5$                                      ; both 0, skip
				ldx	    #0
				cmpa	  #2
				bcc	    no_shift_xy
				ldy	    #1					                            ; shift	X,Y by 1
				bne	    shift_xy
5$:		  ldy	    #2                                      ; shift	X,Y by 2
				ldx	    #9
				lda	    *byte_4					                        ; piece	X (high	byte)
				ora	    *byte_6					                        ; piece	Y (high	byte)
				beq	    no_shift_xy				                      ; both 0, skip
				bmi	    shift_xy
6$:			leay    1,y
				asla
				bpl	    6$

shift_xy:									
        tfr     y,x                                     ; copy shift count
				lda	    *byte_5					                        ; piece	X sign

shift_loop:
				asl	    *byte_4
				rola					                                  ; shift	X up 1 bit
				asl	    *byte_6
				rol	    *byte_7					                        ; shift	Y up 1 bit
				leay    -1,y                                    ; done shifting?
				bne	    shift_loop				                      ; no, loop
				sta	    *byte_5					                        ; Xs,X[9..8]

no_shift_xy:
        tfr     x,d
        tfr     b,a                                     ; A=shift count
				SEC
				sbca	  #0x0A
				eora	  #0xFF					                          ; negate
				asla
				ror	    *byte_8
				rola
				ror	    *byte_8
				rola
				asla
				sta	    *byte_8					                        ; VCTR opcode ($00-$90)
				ldy	    #0
				lda	    *byte_6					                        ; Y[7..0]
				sta	    (dvg_curr_addr_lsb),Y			              ; store	in avg ram
				lda	    *byte_8					                        ; VCTR opcode,Ys
				anda	  #0xF4
				ora	    *byte_7					                        ; Y[9..8]
				leay    1,y
				sta	    (dvg_curr_addr_lsb),Y			              ; store	in avg ram
				lda	    *byte_4					                        ; piece	X (high	byte)
				leay    1,y
				sta	    (dvg_curr_addr_lsb),Y			              ; store	in avg ram
				lda	    *byte_8					                        ; VCTR opcode,Xs
				anda	  #2					                            ; Xs (bit1)
				asla					                                  ; adjust for VCTR instruction
				ora	    *byte_1					                        ; always 0???
				ora	    *byte_5					                        ; Xs,X[9..8]
				leay    1,y
				sta	    (dvg_curr_addr_lsb),Y			              ; store	in avg ram
				jmp	    update_dvg_curr_addr
        				
; $7CDE
set_scale_A_bright_0:
        ; IMPLEMENTATION_NOT_REQD
        rts
        				
; $7CE0
set_scale_A_bright_X:
        ; IMPLEMENTATION_NOT_REQD
        rts
        				
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
.ifdef PLATFORM_COCO3
				lda			#OP_HALT
        sta     dvgram+2
.else
				LDA     #$B0 ; '°'                              ; HALT
        STA     dvgram+3
.endif
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

; $7D45
write_AX_to_avgram:
        ; IMPLEMENTATION_NOT_REQD
        rts
        				
; $7D50
ServiceMode:
        ; IMPLEMENTATION_NOT_REQD
        rts

; $7FF5
rightCoinMultiplierTable:       
        .byte 1, 4, 5, 6
        				
				
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

; on the arcade hardware
; the following data is stored in the AVGROM
; which is accessible by the 6502

.ifdef PLATFORM_COCO3
ship_explosion_pieces_velocity:
        .byte 0xD8, 0x1E                ; (-40,  30)
        .byte 0x32, 0xEC                ; ( 50, -20)
        .byte 0x00, 0xC4                ; (  0, -60)
        .byte 0x3C, 0x14                ; ( 60,  20)
        .byte 0x0A, 0x46                ; ( 10,  70)
        .byte 0xD8, 0xD8                ; (-40, -40)
english_msg_offset_tbl:
        .byte 0x0B, 0x13, 0x19, 0x2F, 0x41, 0x55, 0x6F, 0x77, 0x7D, 0x87, 0x91
english_msg_tbl:
				; "HIGH SCORES"
        .byte 0x63, 0x56, 0x60, 0x6E, 0x3C, 0xEC, 0x4D, 0xC0
				; ???
        .byte 0xA4, 0x0A, 0xEA, 0x6C, 0x08, 0x00
				; "YOUR SCORE IS ONE OF THE TEN BEST"
        .byte 0xEC, 0xF2, 0xB0, 0x6E, 0x3C, 0xEC, 0x48, 0x5A, 0xB8, 0x66, 0x92, 0x42, 0x9A, 0x82, 0xC3, 0x12
        .byte 0x0E, 0x12, 0x90, 0x4C, 0x4D, 0xF1
				; "PLEASE ENTER YOUR INITIALS"
        .byte 0xA4, 0x12, 0x2D, 0xD2, 0x0A, 0x64, 0xC2, 0x6C, 0x0F, 0x66, 0xCD, 0x82, 0x6C, 0x9A, 0xC3, 0x4A
        .byte 0x85, 0xC0
				; "PUSH ROTATE TO SELECT LETTER"
        .byte 0xA6, 0x6E, 0x60, 0x6C, 0x9E, 0x0A, 0xC2, 0x42, 0xC4, 0xC2, 0xBA, 0x60, 0x49, 0xF0, 0x0C, 0x12
        .byte 0xC6, 0x12, 0xB0, 0x00
				; "PUSH HYPERSPACE WHEN LETTER IS CORRECT"
        .byte 0xA6, 0x6E, 0x60, 0x58, 0xED, 0x12, 0xB5, 0xE8, 0x29, 0xD2, 0x0E, 0xD8, 0x4C, 0x82, 0x82, 0x70
        .byte 0xC2, 0x6C, 0x0B, 0x6E, 0x09, 0xE6, 0xB5, 0x92, 0x3E, 0x00
				; "PUSH START"
        .byte 0xA6, 0x6E, 0x60, 0x6E, 0xC1, 0x6C, 0xC0, 0x00
				; "GAME OVER"
        .byte 0x59, 0x62, 0x48, 0x66, 0xD2, 0x6D
        ; "1 COIN 2 PLAYS"
        .byte 0x18, 0x4E, 0x9B, 0x64, 0x09, 0x02, 0xA4, 0x0A, 0xED, 0xC0
        ; "1 COIN 1 PLAY"
        .byte 0x18, 0x4E, 0x9B, 0x64, 0x08, 0xC2, 0xA4, 0x0A, 0xE8, 0x00
        ; "2 COINS 1 PLAY"
        .byte 0x20, 0x4E, 0x9B, 0x64, 0xB8, 0x46, 0x0D, 0x20, 0x2F, 0x40
sine_tbl:
        .byte 0x00, 0x03, 0x06, 0x09, 0x0C, 0x10, 0x13, 0x16, 0x19, 0x1C, 0x1F, 0x22, 0x25, 0x28, 0x2B, 0x2E
        .byte 0x31, 0x33, 0x36, 0x39, 0x3C, 0x3F, 0x41, 0x44, 0x47, 0x49, 0x4C, 0x4E, 0x51, 0x53, 0x55, 0x58
        .byte 0x5A, 0x5C, 0x5E, 0x60, 0x62, 0x64, 0x66, 0x68, 0x6A, 0x6B, 0x6D, 0x6F, 0x70, 0x71, 0x73, 0x74
        .byte 0x75, 0x76, 0x78, 0x79, 0x7A, 0x7A, 0x7B, 0x7C, 0x7D, 0x7D, 0x7E, 0x7E, 0x7E, 0x7F, 0x7F, 0x7F
        .byte 0x7F
.endif
				.end		jmp_osd_init
