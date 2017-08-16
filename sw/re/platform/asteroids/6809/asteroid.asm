;
;	ARCADE ASTEROIDS
; - ported from the original arcade version
; - by tcdev 2017 msmcdoug@gmail.com
; - graphics kindly supplied by Norbert Kehrer
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

; equ for asteroids here

        .org    var_base
        
        .bndry  0x100
dp_base:            						.ds     256        
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

isr_dp_base:        						.ds     256        

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
P2RAM:					.ds			0x100


; rgb/composite video selected (bit 4)
cmp:                            .ds 1

        .org    code_base

				.asciz	'asteroids2'
        
				.org		0xc000

start_coco:
				orcc		#0x50										; disable interrupts
				lds			#stack

.ifdef PLATFORM_COCO3

; switch in 32KB cartridge
        lda     #COCO|MMUEN|MC3|MC1|MC0 ; 32KB internal ROM
        sta     INIT0
; setup MMU to copy ROM
        lda     #CODE_PG1
        ldx     #MMUTSK1                ; $0000-$7FFF
        ldb     #4
1$:     sta     ,x+
        inca
        decb
        bne     1$                      ; map pages $30-$33
; copy ROM into RAM        
        ldx     #0x8000                 ; start of 32KB ROM
        ldy     #0x0000                 ; destination
2$:     lda     ,x+
        sta     ,y+
        cmpx    #0xff00                 ; done?
        bne     2$                      ; no, loop
; setup MMU mapping for game
        lda     #CODE_PG1
        ldx     #MMUTSK1+4              ; $8000-$FFFF
        ldb     #4
4$:     sta     ,x+
        inca
        decb
        bne     4$                      ; map pages $30-33
        lda     #VRAM_PG
        ldx     #MMUTSK1                ; $0000-
        ldb     #4
5$:     sta     ,x+
        inca
        decb
        bne     5$                      ; map pages $38-$3B        
; switch to all-RAM mode
        sta     RAMMODE        

; check for PAL/NTSC GIME
				lda			#0x3f										; ECB ROM $E000-
				ldx			#MMUTSK1
				sta			,x
				ldb			0x0033									; read BASIC video register mirror
				lda			#VRAM_PG
				sta			,x											; restore page
				stb			pal_detected

display_splash:
				lda			#0x01										; 32 CPL
				sta			VRES
        ldx     #0x400
        lda     #0x60                   ; green space
        eora		#0x40										; inverse (black space)
1$:     sta     ,x+
        cmpx    #0x600
        bne     1$
        ldx     #splash
        ldy     #0x420
				jsr			display_lines
				lda			pal_detected
				ldx			#ntsc_splash
				bita		#8											; pal?
				beq			2$											; no, skip
				ldx			#pal_splash
2$:			ldy			#0x540
   			jsr			display_lines
				ldx			#PIA0

splash_get_key:
				clr			cmp											; flag RGB
2$:			ldb			pal_detected
				lda			#~(1<<2)								; col=2
				bitb		#8											; PAL?
				beq			3$											; no, skip
				clra														; all columns
3$:			sta     2,x											; column strobe
				lda     ,x
				coma														; active high
				bitb		#8											; pal?
				beq			4$											; no, skip
				tsta														; any key hit?
				;beq			2$											; no, loop
				bra			setup_gime_for_game
4$:			bita    #(1<<2)                 ; 'R'?
				bne     5$											; yes, default, exit
        lda     #~(1<<3)								; col=3
				sta			2,x											; column strobe
				lda			,x											; active low
				bita    #(1<<0)                 ; 'C'?
				bne     2$                      ; try again
				ldb     #(1<<4)                 ; flag component
				stb     cmp
5$:     bra			setup_gime_for_game
        
display_lines:        
1$:     ldb     ,x+                     ; read 'attr'
        stb     attr
        lda     ,x                      ; leading null?
        beq     9$
				pshs    y
2$:     lda     ,x+
        beq     3$
        eora    attr
        eora		#0x40										; invert
        sta     ,y+
        bra     2$
3$:     puls    y
        leay    32,y
        bra     1$
9$:			rts
				
setup_gime_for_game:

; need DP for the FISR				
				lda			#>dp_base
				tfr			a,dp

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			FIRQENR									; ACK any pending GIME fast interrupt
		.ifdef BUILD_OPT_PROFILE
				lda			#MMUEN|#IEN|#FEN        ; enable GIME MMU, IRQ, FIRQ
		.else				
				;lda			#MMUEN|#FEN             ; enable GIME MMU, FIRQ
				lda			#MMUEN             			; enable GIME MMU
		.endif
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
		.ifdef BUILD_OPT_PROFILE
				lda			#VBORD
		.else				
				lda			#0x00										; no VBLANK IRQ
		.endif
				sta			IRQENR    							
				lda			#TMR                    ; TMR FIRQ enabled
				;sta			FIRQENR   							
				lda			#BP										  ; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
				lda			#0x08										; 192 scanlines, 32 bytes/row, 2 colours (256x192)
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#(VRAM_PG<<2)           ; screen at page $38
				sta			VOFFMSB
				lda			#0x00
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							

				ldx			#PALETTE
				ldy     #rgb_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)

  ; configure timer
  ; free-run, ~1/20s, used for RND (LFSR) atm
        lda     #<785
        sta     TMRLSB
        lda     #>785
        sta     TMRMSB

.ifdef BUILD_OPT_PROFILE
  ; install IRQ handler and enable CPU IRQ
				lda			IRQENR									; ACK any pending IRQ in the GIME
        lda     #0x7E                   ; jmp
        sta     0xFEF7
        ldx     #main_isr
        stx     0xFEF8
        clr			*vbl_cnt
        andcc   #~(1<<4)                ; enable IRQ in CPU    
.endif

; install FIRQ handler and enable TMR FIRQ
				;lda			#TMR|HBORD|VBORD        ; TMR FIRQ enabled
				;sta			FIRQENR   							
				lda			FIRQENR									; ACK any pending FIRQ in the GIME
        lda     #0x7E                   ; jmp
        sta     0xFEF4
				;ldx     #prng_fisr              ; address
				;stx     0xFEF5
        ;andcc   #~(1<<6)                ; enable FIRQ in CPU

  ; setup the PIAS for joystick sampling
  
  ; configure joystick axis selection as outputs
  ; and also select left/right joystick
        lda     PIA0+CRA
        ldb     PIA0+CRB
        ora     #(1<<5)|(1<<4)          ; CA2 as output
        orb     #(1<<5)|(1<<4)          ; CB2 as output
.ifdef LEFT_JOYSTICK
        orb     #(1<<3)                 ; CB2=1 left joystick
.else
        andb    #~(1<<3)                ; CB2=0 right joystick
.endif
        sta     PIA0+CRA
        stb     PIA0+CRB
  ; configure comparator as input
        lda     PIA0+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA0+CRA
        lda     PIA0+DDRA
        anda    #~(1<<7)                ; PA7 as input
        sta     PIA0+DDRA
        lda     PIA0+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA0+CRA
  ; configure sound register as outputs
        lda     PIA1+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA1+CRA
        lda     PIA1+DDRA
        ora     #0xfc                   ; PA[7..2] as output
        sta     PIA1+DDRA
        lda     PIA1+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA1+CRA
          
  .ifdef HAS_SOUND				
				lda			PIA1+CRB
				ora			#(1<<5)|(1<<4)					; set CB2 as output
		.ifdef USE_1BIT_SOUND
				anda		~#(1<<3)								; mute (other) sound
		.else
				ora			#(1<<3)									; enable (DAC) sound
		.endif
				sta			PIA1+CRB
				; bit2 sets control/data register
				lda     PIA1+CRB
				anda    #~(1<<2)                ; select DDRB
				sta     PIA1+CRB
				lda     PIA1+DDRB
				ora     #(1<<1)                 ; PB1 output
				sta     PIA1+DDRB
        ; setup for data register				
				lda     PIA1+CRB
				ora     #(1<<2)                 ; select DATAB
				sta     PIA1+CRB
  .endif  ; HAS_SOUND

.endif	; PLATFORM_COCO3
			
        jmp     asteroids
        
rgb_pal:
    .db RGB_DARK_BLACK, RGB_DARK_BLUE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_GREEN, RGB_DARK_CYAN, RGB_DARK_YELLOW, RGB_GREY
    .db RGB_BLACK, RGB_BLUE, RGB_RED, RGB_MAGENTA
    .db RGB_GREEN, RGB_CYAN, RGB_YELLOW, RGB_WHITE
cmp_pal:    
    .db CMP_DARK_BLACK, CMP_DARK_BLUE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_GREEN, CMP_DARK_CYAN, CMP_DARK_YELLOW, CMP_GREY
    .db CMP_BLACK, CMP_BLUE, CMP_RED, CMP_MAGENTA
    .db CMP_GREEN, CMP_CYAN, CMP_YELLOW, CMP_WHITE


splash:
;       .asciz  "01234567890123456789012345678901"
        .db 0
        .asciz  "````ARCADE`ASTEROIDS`hREVri"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "``````FOR`THE`TRSmxp`COCOs"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```GRAPHICS`BY`NORBERT`KEHRER"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```hPREmRELEASE`VERSION`pnqi"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0x40
        .asciz  "|WWWnRETROPORTSnBLOGSPOTnCOMnAU~"
        .dw     0

ntsc_splash:
        .db 0
;        .asciz  "`````````NTSC`DETECTED"
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````hRiGBohCiOMPOSITE"
        .dw     0

pal_splash:
        .db 0
;        .asciz  "``````PAL`MACHINE`DETECTED"
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````m`PRESS`ANY`KEY`m"
        .dw     0

pal_detected:
				.ds			1
attr:   .ds     1

; $2800
coinage:			      						.ds 1
;	0 = 1x & 4, 1 =	1x & 3,	2 = 2x & 4, 3 =	2x & 3
rightCoinMultiplier:	      		.ds 1
centerCoinMultiplierAndLives:   .ds 1
language:			      						.ds 1

; $6800                
asteroids:
				jsr			coco_reset
				jmp			reset
start:
				jsr			coco_start				
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
				
				jsr			display_C_scores_ships

				jsr			update_prng
				jsr			halt_dvg
				lda			asteroidWaveTimer
				beq			8$
				dec			asteroidWaveTimer
8$:			ora			currentNumberOfAsteroids
				bne			wave_loop
				beq			game_loop

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
				lda			#0x50
				ldx			#0xA4																		; addr = 0x50A4
				;jsr			write_JSR_cmd														; "(C)1979 ATARI INC"
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
				ldy			#2																			; 2 bytes to display
				sec																							; flag no zero padding
				;jsr			display_numeric													; display P1 score
				lda			#0
				;jsr			display_bright_digit										; display score	units (=0)
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
				ldy			#2																			; 2 bytes to display
				SEC																							; flag no zero padding
				;jsr			display_numeric													; display high score
				lda			#0
				;jsr			display_digit_A													; display high score units (=0)
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
				ldy			#2																			; 2 bytes to display
				SEC																							; flag no zero padding
				;jsr			display_numeric													; display P2 score
				lda			#0
				;jsr			display_bright_digit										; display score	units (=0)
4$:			lda			#207																		; X coord (x4=828)
				ldb			*numShipsP2
				jmp			display_extra_ships
9$:			rts
				
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
				ldx			#4

write_CUR_cmd:
				lda			2,X																			; @$6 =	Y*4 (lsb)
				ldb			#0
				ldy			*dvg_curr_addr_msb
				sta			b,y																			; store	in avg ram
				incb
				lda			3,X																			; @$7 =	Y*4 (msb)
				anda		#0x0F																		; clear	command	nibble
				ora			#0xA0                              			; CUR command
				sta			b,y																			; store	in avg ram
				incb
				lda			0,X																			; @$4 =	X*4 (lsb)
				sta			b,y																			; store	in avg ram
				incb
				lda			1,X																			; @$5 =	X*4 (msb)
				anda		#0x0F																		; clear	scale nibble
				ora			*globalScale														; global scale
				sta			b,y																			; store	in avg ram

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
				
coco_reset:
				lda			#0x02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts
				
coco_start:
				rts
								
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

				.end		start_coco
