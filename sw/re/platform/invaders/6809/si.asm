;
;	SPACE INVADERS
; - ported from the original arcade game
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

; *** BUILD OPTIONS
.define BUILD_OPT_DISABLE_DEMO
; *** end of BUILD OPTIONS

; *** derived - do not edit

.ifndef BUILD_OPT_INVALID
  .define GFX_1BPP
.else
  .define GFX_2BPP
.endif

; *** end of derived

; *** INVADERS stuff here
        .org    0x5f00
        
        .bndry  0x100
dp_base:            .ds     256        
z80_b               .equ    0x00
z80_c               .equ    0x01
z80_d               .equ    0x02
z80_e               .equ    0x03
z80_h               .equ    0x04
z80_l               .equ    0x05
z80_a_              .equ    0x06
z80_f_              .equ    0x07
z80_r               .equ    0x08

; rgb/composite video selected (bit 4)
cmp:                            .ds 1

        .org    0x6000
wram    .equ    .                       ; 1KB

; $2000
wait_on_draw:                   .ds   1
                                .ds   1
alien_is_exploding:             .ds   1                
exp_alien_timer:                .ds   1
alien_row:                      .ds   1
alien_frame:                    .ds   1
alien_cur_index:                .ds   1
ref_alien_dyr:                  .ds   1
ref_alien_dxr:                  .ds   1
ref_alien_yr:                   .ds   1
ref_alien_xr:                   .ds   1
alien_pos_msb:                  .ds   1     ; switched for 6809
alien_pos_lsb:                  .ds   1     ; switched for 6809
rack_direction:                 .ds   1
rack_down_delta:                .ds   1
                                .ds   1
; $2010
; '''GameObject0 (Move/draw the player)'''
obj0_timer_msb:                 .ds   1                                
obj0_timer_lsb:                 .ds   1                                
obj0_timer_extra:               .ds   1                                
obj0_handler_msb:               .ds   1     ; switched for 6809        
obj0_handler_lsb:               .ds   1     ; switched for 6809        
player_alive:                   .ds   1                                
exp_animate_timer:              .ds   1                                
exp_animate_cnt:                .ds   1                                
plyr_spr_pic_m:                 .ds   1     ; switched for 6809
plyr_spr_pic_l:                 .ds   1     ; switched for 6809        
player_xr:                      .ds   1     ; switched for 6809        
player_yr:                      .ds   1     ; switched for 6809        
plyr_spr_siz:                   .ds   1                                
next_demo_cmd:                  .ds   1                                
hid_mess_seq:                   .ds   1                                
                                .ds   1
; $2020
; '''GameObject1 (Move/draw the player shot)'''
obj1_timer_msb:                 .ds   1                                
obj1_timer_lsb:                 .ds   1                                
obj1_timer_extra:               .ds   1                                
obj1_handler_msb:               .ds   1     ; switched for 6809        
obj1_handler_lsb:               .ds   1     ; switched for 6809        
plyr_shot_status:               .ds   1                                
blow_up_timer:                  .ds   1                                
obj1_image_msb:                 .ds   1     ; switched for 6809        
obj1_image_lsb:                 .ds   1     ; switched for 6809        
obj1_coor_xr:                   .ds   1     ; switched for 6809        
obj1_coor_yr:                   .ds   1     ; switched for 6809        
obj1_image_size:                .ds   1                                
shot_delta_x:                   .ds   1                                
fire_bounce:                    .ds   1                                
                                .ds   2
; $2030
; '''GameObject2 (Alien rolling-shot)'''
obj2_timer_msb:                 .ds   1                                
obj2_timer_lsb:                 .ds   1                                
obj2_timer_extra:               .ds   1                                
obj2_handler_msb:               .ds   1     ; switched for 6809        
obj2_handler_lsb:               .ds   1     ; switched for 6809        
rol_shot_status:                .ds   1                                
rol_shot_step_cnt:              .ds   1                                
rol_shot_track:                 .ds   1                                
rol_shot_c_fir_msb:             .ds   1     ; switched for 6809        
rol_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
rol_shot_blow_cnt:              .ds   1                                
rol_shot_image_msb:             .ds   1     ; switched for 6809        
rol_shot_image_lsb:             .ds   1     ; switched for 6809        
rol_shot_xr:                    .ds   1     ; switched for 6809        
rol_shot_yr:                    .ds   1     ; switched for 6809        
rol_shot_size:                  .ds   1                                
; $2040
; '''GameObject3 (Alien plunger-shot)'''
obj3_timer_msb:                 .ds   1
obj3_timer_lsb:                 .ds   1
obj3_timer_extra:               .ds   1                                
obj3_handler_msb:               .ds   1     ; switched for 6809        
obj3_handler_lsb:               .ds   1     ; switched for 6809        
plu_shot_status:                .ds   1                                
plu_shot_step_cnt:              .ds   1                                
plu_shot_track:                 .ds   1                                
plu_shot_c_fir_msb:             .ds   1     ; switched for 6809        
plu_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
plu_shot_blow_cnt:              .ds   1                                
plu_shot_image_msb:             .ds   1     ; switched for 6809        
plu_shot_image_lsb:             .ds   1     ; switched for 6809        
plu_shot_xr:                    .ds   1     ; switched for 6809        
plu_shot_yr:                    .ds   1     ; switched for 6809        
plu_shot_size:                  .ds   1                                
; $2050
; '''GameObject4 (Flying saucer OR alien squiggly shot)'''
obj4_timer_msb:                 .ds   1                                
obj4_timer_lsb:                 .ds   1                                
obj4_timer_extra:               .ds   1                                
obj4_handler_msb:               .ds   1     ; switched for 6809        
obj4_handler_lsb:               .ds   1     ; switched for 6809        
squ_shot_status:                .ds   1                                
squ_shot_step_cnt:              .ds   1                                
squ_shot_track:                 .ds   1                                
squ_shot_c_fir_msb:             .ds   1     ; switched for 6809
squ_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
squ_shot_blow_cnt:              .ds   1                                
squ_shot_image_msb:             .ds   1     ; switched for 6809        
squ_shot_image_lsb:             .ds   1     ; switched for 6809        
squ_shot_xr:                    .ds   1     ; switched for 6809        
squ_shot_yr:                    .ds   1     ; switched for 6809        
squ_shot_size:                  .ds   1                                
; $2060
end_of_tasks:                   .ds   1
collision:                      .ds   1
exp_alien_msb:                  .ds   1     ; switched for 6809
exp_alien_lsb:                  .ds   1     ; switched for 6809
exp_alien_xr:                   .ds   1     ; switched for 6809
exp_alien_yr:                   .ds   1     ; switched for 6809
exp_alien_size:                 .ds   1
player_data_msb:                .ds   1
player_ok:                      .ds   1
enable_alien_fire:              .ds   1
alien_fire_delay:               .ds   1
one_alien:                      .ds   1
temp_206C:                      .ds   1
invaded:                        .ds   1
skip_plunger:                   .ds   1
                                .ds   1
; $2070
other_shot_1:                   .ds   1
other_shot_2:                   .ds   1
vblank_status:                  .ds   1
a_shot_status:                  .ds   1
a_shot_step_cnt:                .ds   1
a_shot_track:                   .ds   1
a_shot_c_fir_msb:               .ds   1     ; switched for 6809
a_shot_c_fir_lsb:               .ds   1     ; switched for 6809
a_shot_blow_cnt:                .ds   1
a_shot_image_msb:               .ds   1     ; switched for 6809
a_shot_image_lsb:               .ds   1     ; switched for 6809
alien_shot_xr:                  .ds   1     ; switched for 6809
alien_shot_yr:                  .ds   1     ; switched for 6809
alien_shot_size:                .ds   1
alien_shot_delta:               .ds   1
shot_pic_end:                   .ds   1
; $2080
shot_sync:                      .ds   1
tmp_2081:                       .ds   1
num_aliens:                     .ds   1
saucer_start:                   .ds   1
saucer_active:                  .ds   1
saucer_hit:                     .ds   1
saucer_hit_time:                .ds   1
saucer_pri_loc_msb:             .ds   1     ; switched for 6809
saucer_pri_loc_lsb:             .ds   1     ; switched for 6809
saucer_pri_pic_msb:             .ds   1     ; switched for 6809
saucer_pri_pic_lsb:             .ds   1     ; switched for 6809
saucer_pri_size:                .ds   1
saucer_delta_y:                 .ds   1
sau_score_msb:                  .ds   1     ; switched for 6809
sau_score_lsb:                  .ds   1     ; switched for 6809
shot_count_msb:                 .ds   1     ; switched for 6809
; $2090
shot_count_lsb:                 .ds   1     ; switched for 6809
till_saucer_msb:                .ds   1     ; switched for 6809
till_saucer_lsb:                .ds   1     ; switched for 6809
wait_start_loop:                .ds   1
sound_port_3:                   .ds   1
change_fleet_snd:               .ds   1
fleet_snd_cnt:                  .ds   1
fleet_snd_reload:               .ds   1
sound_port_5:                   .ds   1
extra_hold:                     .ds   1
tilt:                           .ds   1
fleet_snd_hold:                 .ds   1
                                .ds   4
; $20A0
; '''In the ROM mirror copied to RAM this is the image of the alien sprite pulling the upside down Y. The code expects it to be 
; 0030 below the second animation picture at 1BD0. This RAM area must be unused. The copy is wasted. '''
                                .ds   16
; $20B0
                                .ds   16
; ''' End of inialization copy from ROM mirror'''
; $20C0
; ''' Splash screen animation structure '''
isr_delay:                      .ds   1
isr_splash_task:                .ds   1
splash_an_form:                 .ds   1
splash_delta_x:                 .ds   1
splash_delta_y:                 .ds   1
splash_xr:                      .ds   1     ; switched for 6809
splash_yr:                      .ds   1     ; switched for 6809
splash_image_msb:               .ds   1     ; switched for 6809
splash_image_lsb:               .ds   1     ; switched for 6809
splash_image_size:              .ds   1
splash_target_y:                .ds   1
splash_reached:                 .ds   1
splash_im_rest_msb:             .ds   1     ; switched for 6809
splash_im_rest_lsb:             .ds   1     ; switched for 6809
two_players:                    .ds   1
a_shot_reload_rate:             .ds   1
; $20D0
; This is where the alien-sprite-carying-the-Y ...
; ... lives in ROM
                                .ds   16
; $20E0
                                .ds   5
player1_ex:                     .ds   1
player2_ex:                     .ds   1
player1_alive:                  .ds   1
player2_alive:                  .ds   1
suspend_play:                   .ds   1
coin_switch:                    .ds   1
num_coins:                      .ds   1
splash_animate:                 .ds   1
demo_cmd_ptr_msb:               .ds   1     ; switched for 6809
demo_cmd_ptr_lsb:               .ds   1     ; switched for 6809
game_mode:                      .ds   1
; $20F0
                                .ds   1
adjust_score:                   .ds   1
score_delta_msb:                .ds   1     ; switched for 6809
score_delta_lsb:                .ds   1     ; switched for 6809
hi_scor_l:                      .ds   1
hi_scor_m:                      .ds   1
hi_scor_lo_m:                   .ds   1     ; switched for 6809
hi_scor_lo_l:                   .ds   1     ; switched for 6809
p1_scor_l:                      .ds   1
p1_scor_m:                      .ds   1
p1_scor_lo_m:                   .ds   1     ; switched for 6809
p1_scor_lo_l:                   .ds   1     ; switched for 6809
p2_scor_l:                      .ds   1
p2_scor_m:                      .ds   1
p2_scor_lo_m:                   .ds   1     ; switched for 6809
p2_scor_lo_l:                   .ds   1     ; switched for 6809

; $2100
; Player 1 specific data
byte_0_2100:
                                .ds   55    ; Player 1 alien ship indicators (0=dead) 11*5 = 55
                                .ds   11    ; Unused 11 bytes (room for another row of aliens?)
                                .ds   0xB0  ; Player 1 shields remembered between rounds 44 bytes * 4 shields ($B0 bytes)
                                .ds   9     ; Unused 9 bytes
; $21FB                                
p1_ref_alien_dx:                .ds   1     ; Player 1 reference-alien delta X
p1_ref_alien_y:                 .ds   1     ; Player 1 reference-alien Y coordinate
p1_ref_alien_x:                 .ds   1     ; Player 1 reference-alien X coordiante
p1_rack_cnt:                    .ds   1     ; Player 1 rack-count (starts at 0 but get incremented to 1-8)
p1_ships_rem:                   .ds   1     ; Ships remaining after current dies

; $2200
; Player 2 specific data
byte_0_2200:
                                .ds   55
                                .ds   11
                                .ds   0xB0
                                .ds   9
; $22FB                                
p2_ref_alien_dx:                .ds   1
p2_ref_alien_yr:                .ds   1
p2_ref_alien_xr:                .ds   1
p2_rack_cnt:                    .ds   1
p2_ships_rem:                   .ds   1

; $2300
; stack on the original game goes here
; low water-mark around $23DE
        
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

display_splash:

        ldx     #0x400
        lda     #96                     ; green space
1$:     sta     ,x+
        cmpx    #0x600
        bne     1$
        ldx     #splash
        ldy     #0x420
2$:     pshs    y
        ldb     ,x+                     ; read 'attr'
        stb     attr
        lda     ,x                      ; leading null?
        beq     5$
3$:     lda     ,x+
        beq     4$
        eora    attr
        sta     ,y+
        bra     3$
4$:     puls    y
        leay    32,y
        bra     2$
5$:     ldx			#PIA0
        ldb     #0                      ; flag rgb
6$:     lda     #~(1<<2)
				sta     2,x
				lda     ,x
				bita    #(1<<2)                 ; 'R'?
				beq     7$
        lda     #~(1<<3)
				sta			2,x											; column strobe
				lda			,x											; active low
				bita    #(1<<0)                 ; 'C'?
				bne     6$                      ; try again
				ldb     #(1<<4)                 ; flag component
7$:     stb     cmp

setup_gime_for_game:

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			#MMUEN|#IEN|#FEN        ; enable GIME MMU, IRQ, FIRQ
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
				lda			#VBORD                  ; VBLANK IRQ
				sta			IRQENR    							
				lda			#TMR                    ; TMR FIRQ enabled
				sta			FIRQENR   							
				lda			#BP										  ; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	  .ifdef GFX_1BPP				
				lda			#0x68										; 225 scanlines, 32 bytes/row, 2 colours (225x256)
;				lda			#0x6C										; 225 scanlines, 40 bytes/row, 2 colours (225x320)
	  .else				
				lda			#0x11										; 192 scanlines, 64 bytes/row, 4 colours (256x192)
	  .endif				
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
  ; free-run, max range, used for RND atm
        lda     #<4095
        sta     TMRLSB
        lda     #>4095
        sta     TMRMSB

  ; install FIRQ handler and enable CPU FIRQ
        lda     #0x7E                   ; jmp
        sta     0xFEF4
				ldx     #main_fisr              ; address
				stx     0xFEF5
        andcc   #~(1<<6)                ; enable FIRQ in CPU
  ; install IRQ handler and enable CPU IRQ
        lda     #0x7E                   ; jmp
        sta     0xFEF7
        ldx     #scan_line_224
        stx     0xFEF8
;        andcc   #~(1<<4)                ; enable IRQ in CPU    

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
				ora			#(1<<3)									; enable sound
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
			
				lda			#>dp_base
				tfr			a,dp
				
; don't really understand this,
; but the game pretty much needs RAM to be $00
; yet there's nowhere that clears it
; so let's clear it for now
        ldx     #wram
1$:     clr     ,x+
        cmpx    #wram+1024
        bne     1$
                				
        jmp     start                   ; space invaders
        
rgb_pal:
    ;.db RGB_DARK_BLACK, RGB_DARK_BLUE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_BLACK, RGB_WHITE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_GREEN, RGB_DARK_CYAN, RGB_DARK_YELLOW, RGB_GREY
    .db RGB_BLACK, RGB_BLUE, RGB_RED, RGB_MAGENTA
    .db RGB_GREEN, RGB_CYAN, RGB_YELLOW, RGB_WHITE
cmp_pal:    
    ;.db CMP_DARK_BLACK, CMP_DARK_BLUE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_BLACK, CMP_WHITE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_GREEN, CMP_DARK_CYAN, CMP_DARK_YELLOW, CMP_GREY
    .db CMP_BLACK, CMP_BLUE, CMP_RED, CMP_MAGENTA
    .db CMP_GREEN, CMP_CYAN, CMP_YELLOW, CMP_WHITE


splash:
;       .asciz  "01234567890123456789012345678901"
        .db 0
        .asciz  "`````ARCADE`SPACE`INVADERS"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "``````FOR`THE`TRSmxp`COCOs"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "````j`MONOCHROME`GRAPHICS`j"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`````````hVERSION`pnqi"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````hRiGBohCiOMPOSITE"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0x40
        .asciz  "|WWWnRETROPORTSnBLOGSPOTnCOMnAU~"
        .dw     0


attr:   .ds     1

; $0010
scan_line_224:
        DI                              ; interrupts disabled in the 8080 ISR
        tst     IRQENR                  ; ACK GIME IRQ on the Coco3

        lda     #0x80                   ; Flag that tells objects ...
        sta     vblank_status           ; ... on the lower half of the screen to draw/move
        dec     isr_delay               ; Decrement the general countdown (used for pauses)
        
        ;bsr     check_handle_tilt       ; Check and handle TILT
;       in      a,(INP1)
;       rrca
;       jp      c,loc_0067              ; coin switch
        ldx     #KEYROW
        lda     #~(1<<5)                ; Column 5 (keybd '5')
        sta     2,x
        lda     ,x                      ; Read coin switch
        bita    #(1<<4)                 ; Has a coin been deposited (keybd '5')?
        beq     5$                      ; Yes ... note that switch is closed and continue at 3F with A=1
        tst     coin_switch             ; Switch is now open. Was it closed last time?
        beq     3$                      ; No ... skip registering the credit
; $002D
; Handle bumping credit count        
        lda     num_coins               ; Number of credits in BCD
        cmpa    #0x99                   ; 99 credits already?
        beq     1$                      ; Yes ... ignore this (better than rolling over to 00)
        adda    #1                      ; Bump number of credits
        daa                             ; Make it binary coded decimal
        sta     num_coins               ; New number of credits
        jsr     draw_num_credits        ; Draw credits on screen
1$:     clra                            ; Credit switch ...
2$:     sta     coin_switch             ; ... has opened
; $0042
3$:     tst     suspend_play            ; Are we moving game objects?
        beq     loc_0086                ; No ... out
        tst     game_mode               ; Are we in game mode?
        bne     6$                      ; Yes ... go process game-play things and out
        tst     num_coins               ; Are there any credits (player standing there)?
        bne     4$                      ; Yes ... skip any ISR animations for the splash screens
        jsr     isr_spl_tasks           ; Process ISR tasks for splash screens
        bra     loc_0086                ; out
; $005D
; At this point no game is going and there are credits
4$:     tst     wait_start_loop         ; Are we in the "press start" loop?
        bne     loc_0086                ; Yes ... out
        jmp     wait_for_start          ; Start the "press start" loop
; $0067        
; Mark credit as needing registering
5$:     lda     #1                      ; Remember switch ...
        sta     coin_switch             ; ... state for debounce
        bra     2$                      ; Continue
; $006F
; Main game-play timing loop
6$:     ;bsr     time_fleet_sound        ; Time down fleet sound and sets flag if needs new delay value
loc_0072:
        lda     obj2_timer_extra        ; Use rolling shot's timer to sync ...
        sta     shot_sync               ; ... other two shots
        ;bsr     draw_alien              ; Draw the current alien (or exploding alien)
        ;bsr     run_game_objs           ; Process game objects (including player object)
        ;bsr     time_to_saucer          ; Count down time to saucer

loc_0086:
        EI
        rti

; $017A
get_alien_coords:
; Convert alien index in L to screen bit position in C,L.
; Return alien row index (converts to type) in D.
        clr     *z80_d                  ; Row 0
        tfr     x,d
        tfr     b,a
        ldx     #ref_alien_yr
        ldb     ,x+                     ; Get alien X ...
        stb     *z80_b                  ; ... to B
        ldb     ,x                      ; Get alien y ...
        stb     *z80_c                  ; ... to C
1$:     cmpa    #11                     ; Can we take a full row off of index?
        bmi     2$                      ; No ... we have the row
        sbca    #11                     ; Subtract off 11 (one whole row)
        sta     *z80_e                  ; Hold the new index
        lda     *z80_b                  ; Add ...
        adda    #0x10                   ; ... 16 to bit ...
        sta     *z80_b                  ; ... position Y (1 row in rack)
        lda     *z80_e                  ; Restore tallied index
        inc     *z80_d                  ; Next row
        bra     1$                      ; Keep skipping whole rows
2$:     ldb     *z80_b                  ; We have the LSB (the row)
        stb     *z80_l
3$:     tsta                            ; Are we in the right column?
        bne     4$
        rts                             ; Yes ... X and Y are right
4$:     sta     *z80_e                  ; Hold index
        lda     *z80_c                  ; Add ...
        adda    #0x10                   ; ... 16 to bit ...
        sta     *z80_c                  ; ... position X (1 column in rack)
        lda     *z80_e                  ; Restore index
        deca                            ; We adjusted for 1 column
        bra     3$                      ; Keep moving over column

; $01C0
init_aliens:
; Initialize the 55 aliens from last to 1st. 1 means alive.
        ldx     #byte_0_2100            ; Start of alien structures (this is the last alien)
        ldb     #55                     ; Count to 55 (that's five rows of 11 aliens)
        lda     #1
1$:     sta     ,x+                     ; Bring alien to life. Next alien
        decb                            ; All done?
        bne     1$                      ; No ... keep looping
        rts        

; $01CF
; Draw a 1px line across the player's stash at the bottom of the screen.
draw_bottom_line:
        lda     #1                      ; Bit 1 set ... going to draw a 1-pixel stripe down left side
        ldb     #0xe0                   ; All the way down the screen
        ldx     #vram+2                 ; Screen coordinates (3rd byte from upper left)
        jmp     sub_14CC                ; Draw line down left side 

; $01D9
; HL/X points to descriptor: DX DY XX YY except DX is already loaded in C
; ** Why the "already loaded" part? Why not just load it here?
add_delta:
        leax    1,x                     ; We loaded delta-x already ... skip over it
        ldb     ,x+                     ; Get delta-y
        lda     *z80_c                  ; Add delta-x ...
; note that X,Y are swapped on 6809        
        addb    ,x                      ; Add delta-y to y
        stb     ,x+                     ; Store new y
        adda    ,x                      ; ... to x
        sta     ,x                      ; Store new x
        rts

; $01E4
; Block copy ROM mirror 1B00-1BBF to initialize RAM at 2000-20BF.
copy_ram_mirror:
        ldb     #0xc0
sub_01E6:
        ldy     #byte_0_1B00
        ldx     #wram
        jmp     block_copy

; $01EF
draw_shield_pl1:
        ldx     #byte_0_2100+0x42       ; Player 1 shield buffer (remember between games in multi-player)
        bra     loc_01F8                ; Common draw point
draw_shield_pl2:
        ldx     #byte_0_2200+0x42       ; Player 2 shield buffer (remember between games in multi-player)
loc_01F8:
        ldb     #4                      ; Going to draw 4 shields
        ldy     #shield_image           ; Shield pixel pattern
1$:     pshs    b,y                     ; Hold the start for the next shield
        ldb     #44                     ; 44 bytes to copy
        jsr     block_copy              ; Block copy DE/Y to HL/X (B bytes)
        puls    b,y                     ; Restore start of shield pattern
        decb                            ; Drawn all shields?
        bne     1$                      ; No ... go draw them all
        rts

; $021A
; Copy shields from player 1's data area to screen.
restore_shields_1:
        clra                            ; Zero means restore
        ldy     #byte_0_2100+0x42       ; Player 1 shield buffer (remember between games in multi-player)

; $021E
; A is 1 for screen-to-buffer, 0 for to buffer-to-screen
; HL/X is screen coordinates of first shield. There are 23 rows between shields.
; DE/Y is sprite buffer in memory.
copy_shields:
        sta     tmp_2081                ; Remember copy/restore flag
        ldu     #0x1602                 ; 22 rows, 2 bytes/row (for 1 shield pattern)
        ldx     #vram+0x0406            ; Screen coordinates
        ldb     #4                      ; Four shields to move
1$:     pshs    b                       ; Hold shield count
        stu     *z80_b                  ; B=rows, C=bytes
        lda     tmp_2081                ; Get back copy/restore flag
        bne     4$                      ; Not zero means remember shields
        jsr     restore_shields         ; Restore player's shields
2$:     puls    b
        decb                            ; Have we moved all shields?
        bne     3$
        rts
3$:     leax    0x02e0,x                ; Add 2E0 (23 rows) to get to next shield on screen
        bra     1$        
4$:     jsr     remember_shields        ; Remember player's shields
        bra     2$                      ; Continue with next shield

; $0248
; Process game objects. Each game object has a 16 byte structure. The handler routine for the object
; is at xx03 and xx04 of the structure. The pointer to xx04 is pushed onto the stack before calling
; the handler.
;
; All game objects (except task 0 ... the player) are called at the mid-screen and end-screen renderings.
; Each object decides when to run based on its Y (not rotated) coordinate. If an object is on the lower
; half of the screen then it does its work when the beam is at the top of the screen. If an object is
; on the top of the screen then it does its work when the beam is at the bottom. This keeps the
; object from updating while it is being drawn which would result in an ugly flicker.
;
;
; The player is only processed at the mid-screen interrupt. I am not sure why.
;
; The first three bytes of the structure are used for status and timers.
; 
; If the first byte is FF then the end of the game-task list has been reached.
; If the first byte is FE then the object is skipped.
;
; If the first-two bytes are non-zero then they are treated like a two-byte counter
; and decremented as such. The 2nd byte is the LSB (moves the fastest).
;
; If the first-two bytes are zero then the third byte is treated as an additional counter. It
; is decremented as such.
;
; When all three bytes reach zero the task is executed.
;
; The third-byte-counter was used as a speed-governor for the player's object, but evidently even the slowest
; setting was too slow. It got changed to 0 (fastest possible).
run_game_objs:
        ldx     #obj0_timer_msb         ; First game object (active player)
loc_024B:
        lda     ,x                      ; Have we reached the ...
        cmpa    #0xff                   ; ... end of the object list?
        bne     1$
        rts                             ; Yes ... done
1$:     cmpa    #0xfe                   ; Is object active?
        beq     loc_0281                ; No ... skip it
        leax    1,x
        ldb     ,x                      ; First byte to B
        sta     *z80_c                  ; Hold 1st byte
        ora     ,x                      ; OR 1st and 2nd byte
        pshs    cc
        lda     *z80_c                  ; Restore 1st byte
        puls    cc
        bne     loc_0277                ; If word at xx00,xx02 is non zero then decrement it
loc_025C:
        leax    1,x                     ; xx02
        tst     ,x                      ; Get byte counter. Is it 0?
        bne     loc_0288                ; No ... decrement byte counter at xx02
        leax    1,x                     ; xx03
        ldy     ,x+                     ; Get handler address. xx04
        pshs    x                       ; Remember pointer to MSB XXX LSB on 6809!?!
        exg     x,y                     ; Handler address to HL/X
; this was a dog's breakfast on the 8080
; using PUSH HL, LD HL,$026F, EX (SP),HL        
        ldu     #loc_026F               ; Return address to 026F
        pshs    u                       ; Return address (026F) now on stack. Handler (still) in HL/X.
        pshs    y                       ; Push pointer to data struct (xx04) for handler to use
        jmp     ,x                      ; Run object's code (will return to next line)
loc_026F:        
        puls    x                       ; Restore pointer to xx04
        leax    12,x                    ; Offset to next game task (12+4=16)
        bra     loc_024B                ; Do next game task

; Word at xx00 and xx01 is non-zero. Decrement it and move to next task. 
loc_0277:
        decb
        incb
        bne     1$
        deca
1$:     decb
        stb     ,x
        leax    -1,x
        sta     ,x
        
loc_0281:
        leax    0x10,x                  ; Next object descriptor
        bra     loc_024B                ; Keep processing game objects

loc_0288:
        dec     ,x                      ; Decrement the xx02 counter
        leax    -2,x                    ; Back up to start of game task
        bra     loc_0281                ; Next game task

; Game task 4 when splash screen alien is shooting extra "C" with a squiggly shot
loc_050E:
        puls    x                       ; Ignore the task data pointer passed on stack
; GameObject 4 comes here if processing a squiggly shot
loc_050F:
        ldy     #squ_shot_status        ; Squiggly shot data structure
        lda     #<squiggly_shot_last
        bsr     to_shot_struct          ; Copy squiggly shot to
        lda     plu_shot_step_cnt       ; Get plunger ...
        sta     other_shot_1            ; ... step count
        lda     rol_shot_step_cnt       ; Get rolling ...
        sta     other_shot_2            ; ... step count
        bsr     handle_alien_shot       ; Handle active shot structure
        lda     a_shot_c_fir_lsb        ; LSB of column-firing table pointer
        cmpa    #0x15                   ; Have we processed all entries?
        bcs     1$                      ; No ... don't reset it
        lda     squ_shot_c_fir_lsb      ; Reset the pointer ...
        sta     a_shot_c_fir_lsb        ; ... back to the start of the table
1$:     ldx     #squ_shot_status        ; Squiggly shot data structure
        tst     a_shot_blow_cnt         ; Check to see if squiggly shot is done. 0 means blow-up timer expired
        bne     from_shot_struct        ; If shot is still running, go copy the updated data and out
        
; $053E
; Shot explosion is over. Remove the shot.
        ldy     #byte_0_1B00+0x50       ; Reload
        ldx     #squ_shot_status        ; ... object ...
        ldb     #0x10                   ; ... structure ...
        jsr     block_copy              ; ... from mirror
        ldx     a_shot_c_fir_msb        ; Copy pointer to column-firing table ...
        stx     squ_shot_c_fir_msb      ; ... back to data structure (for next shot)
        rts

; $0550
to_shot_struct:
        sta     shot_pic_end            ; LSB of last byte of last picture in sprite
        ldx     #a_shot_status          ; Destination is the shot-structure
        ldb     #11                     ; 11 bytes
        jmp     block_copy              ; Block copy and out

; $055B
from_shot_struct:
        ldy     #a_shot_status          ; Source is the shot-structure
        ldb     #11                     ; 11 bytes
        jmp     block_copy              ; Block copy and out

; $0563
; Each of the 3 shots copy their data to the 2073 structure (0B bytes) and call this.
; Then they copy back if the shot is still active. Otherwise they copy from the mirror.
;
; The alien "fire rate" is based on the number of steps the other two shots on the screen 
; have made. The smallest number-of-steps is compared to the reload-rate. If it is too
; soon then no shot is made. The reload-rate is based on the player's score. The MSB
; is looked up in a table to get the reload-rate. The smaller the rate the faster the
; aliens fire. Setting rate this way keeps shots from walking on each other.
handle_alien_shot:
        ldx     #a_shot_status          ; Start of active shot structure
        lda     ,x                      ; Get the shot status
        anda    #0x80                   ; Is the shot active?
        bne     loc_05C1                ; Yes ... go move it
        lda     isr_splash_task         ; ISR splash task
        cmpa    #4                      ; Shooting the "C" ?
        pshs    cc
        lda     enable_alien_fire       ; Alien fire enabled flag
        puls    cc
        beq     loc_05B7                ; We are shooting the extra "C" ... just flag it active and out
        tsta                            ; Is alien fire enabled?
        beq     9$                      ; No ... don't start a new shot
        leax    1,x                     ; 2074 step count of current shot
        clr     ,x                      ; clear the step count
; Make sure it isn't too soon to fire another shot
        lda     other_shot_1            ; Get the step count of the 1st "other shot"
        beq     1$                      ; Any steps made? No ... ignore this count
        sta     *z80_b                  ; Shuffle off step count
        lda     a_shot_reload_rate      ; Get the reload rate (based on MSB of score)
        cmpa    *z80_b                  ; Too soon to fire again?
        bcc     9$                      ; Yes ... don't fire
; $0589        
1$:     lda     other_shot_2            ; Get the step count of the 2nd "other shot"
        beq     2$                      ; Any steps made? No steps on any shot ... we are clear to fire
        sta     *z80_b                  ; Shuffle off step count
        lda     a_shot_reload_rate      ; Get the reload rate (based on MSB of score)
        cmpa    *z80_b                  ; Too soon to fire again?
        bcs     2$
9$:     rts                             ; Yes ... don't fire
; $0596
2$:     leax    1,x                     ; 2075
        tst     ,x                      ; Get tracking flag. Does this shot track the player?
        lbeq    loc_061B                ; Yes ... go make a tracking shot
        ldx     a_shot_c_fir_msb        ; Column-firing table
        ldb     ,x+                     ; Get next column to fire from. Bump the ...
        stb     *z80_c
        stx     a_shot_c_fir_msb        ; ... pointer into column table
loc_05A5:        
        jsr     find_in_column          ; Find alien in target column
        bcs     1$
        rts                             ; No alien is alive in target column ... out
1$:     jsr     get_alien_coords        ; Get coordinates of alien (lowest alien in firing column)
        lda     *z80_c                  ; Offset ...
        adda    #7                      ; ... Y by 7
        ldb     *z80_l                  ; Offset ...
        subb    #10                     ; ... X down 10
        std     alien_shot_xr           ; Set shot coordinates below alien
; $05B7        
loc_05B7:
        ldx     #a_shot_status          ; Alien shot status
        lda     ,x                      ; Get the status
        ora     #0x80                   ; Mark this shot ...
        sta     ,x+                     ; ... as actively running. 2074 step count
        inc     ,x                      ; Give this shot 1 step (it just started)
        rts

; $05C1
; Move the alien shot
loc_05C1:
        ldy     #alien_shot_xr          ; Alien-shot Y coordinate
        jsr     comp_y_to_beam          ; Compare to beam position
        bcs     1$
        rts                             ; Not the right ISR for this shot
1$:     leax    1,x                     ; 2073 status
        lda     ,x                      ; Get shot status
        anda    #1                      ; Bit 0 is 1 if blowing up
        bne     shot_blowing_up         ; Go do shot-is-blowing-up sequence
        leax    1,x                     ; 2074 step count
        inc     ,x                      ; Count the steps (used for fire rate)
        jsr     sub_0675                ; Erase shot
        lda     a_shot_image_lsb        ; Get LSB of the image pointer
        adda    #3                      ; Next set of images
        ldx     #shot_pic_end           ; End of image
        cmpa    ,x                      ; Have we reached the end of the set?
        bcs     2$                      ; No ... keep it
        suba    #12                     ; Back up to the 1st image in the set
2$:     sta     a_shot_image_lsb        ; New LSB image pointer
        lda     alien_shot_yr           ; Get shot's Y coordinate
        adda    alien_shot_delta        ; Add delta to shot's coordinate
        sta     alien_shot_yr           ; New shot Y coordinate
        jsr     sub_066C                ; Draw the alien shot
        lda     alien_shot_yr           ; Shot's Y coordinate
        cmpa    #0x15                   ; Still in the active playfield?
        bcs     3$                      ; No ... end it
        tst     collision               ; Did shot collide with something?
        beq     9$                      ; No ... we are done here
        lda     alien_shot_yr           ; Shot's Y coordinate
        cmpa    #0x1e                   ; Is it below player's area?
        bcs     3$                      ; Yes ... end it
        cmpa    #0x27                   ; Is it above player's area?
        bcc     3$                      ; Yes ... end it
        clr     player_alive            ; Flag that player has been struck
; $0612        
3$:     lda     a_shot_status           ; Flag to ...
        ora     #1                      ; ... start shot ...
        sta     a_shot_status           ; ... blowing up
9$:     rts                

; $061B
; Start a shot right over the player
loc_061B:
        lda     player_xr               ; Player's X coordinate
        adda    #8                      ; Center of player
        tfr     d,x
        bsr     find_in_column          ; Find the column
        lda     *z80_c                  ; Get the column right over player
        cmpa    #12                     ; Is it a valid column?
        lbcs    loc_05A5                ; Yes ... use what we found
        lda     #11                     ; Else use ...
        sta     *z80_c                  ; ... as far over as we can
        jmp     loc_05A5

; $062F        
; C contains the target column. Look for a live alien in the column starting with
; the lowest position. Return C=1 if found ... HL/X points to found slot.
find_in_column:
        dec     *z80_c                  ; Column that is firing
        lda     player_data_msb         ; Player's MSB (21xx or 22xx)
        ldb     *z80_c
        tfr     d,x
        lda     #5                      ; 5 rows of aliens
        sta     *z80_d
1$:     tst     ,x                      ; Get alien's status
        SCF                             ; In case not 0
        bne     9$                      ; Alien is alive? Yes ... return
        tfr     x,d                     ; Get the flag pointer LSB
        addb    #11                     ; Jump to same column on next row of rack (+11 aliens per row)
        tfr     d,x                     ; New alien index
        dec     *z80_d                  ; Tested all rows?
        bne     1$                      ; No ... keep looking for a live alien up the rack
9$:     rts                             ; Didn't find a live alien. Return with C=0.

; $0644
; Alien shot is blowing up
shot_blowing_up:
        ldx     #a_shot_blow_cnt        ; Blow up timer
        dec     ,x                      ; Decrement the value
        lda     ,x                      ; Get the value
        cmpa    #3                      ; First tick, 4, we draw the explosion
        bne     1$                      ; After that just wait
        bsr     sub_0675                ; Erase the shot
        ldx     #a_shot_explo           ; Alien shot ...
        stx     a_shot_image_msb        ; ... explosion sprite
        ldx     #alien_shot_xr          ; Alien shot Y
        dec     ,x                      ; Left two for ...
        dec     ,x                      ; ... explosion
        leax    -1,x                    ; Point alien shot X
        dec     ,x                      ; Up two for ...
        dec     ,x                      ; ... explosion
        lda     #6                      ; Alien shot descriptor ...
        sta     alien_shot_size         ; ... size 6
        bra     sub_066C                ; Draw alien shot explosion
; $0667
1$:     tsta                            ; Have we reached 0?
        beq     sub_0675                ; Erase the explosion and out
        rts                             ; No ... keep waiting
; $066C
sub_066C:
        ldx     #a_shot_image_msb       ; Alien shot descriptor
        jsr     read_desc               ; Read 5 byte structure
        jmp     draw_spr_collision      ; Draw shot and out
; $0675
sub_0675:
        ldx     #a_shot_image_msb       ; Alien shot descriptor
        jsr     read_desc               ; Read 5 byte structure
        jmp     erase_shifted           ; Erase the shot and out

loc_067E:
        stx     plu_shot_c_fir_msb      ; From 50B, update ...
        rts                             ; ... column-firing table pointer and out
                        
; $0682
game_obj_4:
; Game object 4: Flying Saucer OR squiggly shot
;
; This task is shared by the squiggly-shot and the flying saucer. The saucer waits until the 
; squiggly-shot is over before it begins.
        puls    x                       ; Pull data pointer from the stack (not going to use it)
        lda     shot_sync               ; Sync flag (copied from GO-2's timer value)
        cmpa    #2                      ; Are GO-2 and GO-3 idle?
        beq     1$
        rts                             ; No ... only one at a time
1$:     ldx     #saucer_start           ; Time-till-saucer flag
        tst     ,x                      ; Is it time for a saucer?
        lbeq    loc_050F                ; No ... go process squiggly shot
; lots more code *** FIXME
        rts        

; $0765
; Wait for player 1 start button press
wait_for_start:
        lda     #1                      ; Tell ISR that we ...
        sta     wait_start_loop         ; ... have started to wait
        lds     #stack                  ; Reset stack
        EI
        jsr     loc_1979                ; Suspend game tasks
        jsr     clear_playfield         ; Clear center window
        ldx     #vram+0x0C13            ; Screen coordinates
        ldy     #message_push           ; "PRESS"
        ldb     #4                      ; Message length
        jsr     print_message           ; Print it
loc_077F:        
        ldx     #vram+0x0410            ; Screen coordinates
        ldb     #20                     ; Message length
        lda     num_coins               ; Number of credits
        deca                            ; Set flags
        lbne    loc_0857                ; Take 1 or 2 player start
        ldy     #message_1_only         ; "ONLY 1PLAYER BUTTON "
        jsr     print_message           ; Print message
;       in      a,(inp1)
;       and     $04
;       jp      z,$077f
        ldx     #KEYROW                 ; assuming HL/X is 'free'
        lda     #~(1<<1)
        sta     2,x
        lda     ,x                      ; Read coin switch
        bita    #(1<<4)                 ; 1Player start button? (keybd '1')
        bne     loc_077F                ; No ... wait for button or credit

; $0798
; START NEW GAME
new_game:
; 1 Player start
        ldb     #0x99                   ; Essentially a -1 for DAA
        clra                            ; Clear two player flag
; $079B
; 2 player start sequence enters here with a=1 and B=98 (-2)
loc_079B:
        sta     two_players             ; Set flag for 1 or 2 players
        lda     num_coins               ; Number of credits
        stb     *z80_b
        adda    *z80_b                  ; Take away credits
        daa                             ; Convert back to DAA
        sta     num_coins               ; New credit count
        jsr     draw_num_credits        ; Display number of credits
        ldx     #0                      ; Score of 0000
        stx     p1_scor_l               ; Clear player-1 score
        stx     p2_scor_l               ; Clear player-2 score
        jsr     sub_1925                ; Print player-1 score
        jsr     sub_192B                ; Print player-2 score
        ;bsr     disable_game_tasks      ; Disable game tasks
        ldd     #0x0101                 ; Two bytes 1, 1
        sta     game_mode               ; 20EF=1 ... game mode
        std     player1_alive           ; 20E7 and 20E8 both one ... players 1 and 2 are alive
        std     player1_ex              ; Extra-ship is available for player-1 and player-2
        jsr     draw_status             ; Print scores and credits
        jsr     draw_shield_pl1         ; Draw shields for player-1
        jsr     draw_shield_pl2         ; Draw shields for player-2
        jsr     get_ships_per_cred      ; Get number of ships from DIP settings
        sta     p1_ships_rem            ; Player-1 ships
        sta     p2_ships_rem            ; Player-2 ships
        ;bsr     sub_00D7                ; Set player-1 and player-2 alien racks going right
        clra
        sta     p1_rack_cnt             ; Player 1 is on first rack of aliens
        sta     p2_rack_cnt             ; Player 2 is on first rack of aliens
        jsr     init_aliens             ; Initialize 55 aliens for player 1
        ;bsr     init_aliens_p2          ; Initialize 55 aliens for player 2
        ldx     #vram+0x1478            ; Screen coordinates for lower-left alien
        stx     p1_ref_alien_y          ; Initialize reference alien for player 1
        stx     p2_ref_alien_yr         ; Initialize reference alien for player 2
        jsr     copy_ram_mirror         ; Copy ROM mirror to RAM (2000 - 20C0)
        jsr     remove_ship             ; Initialize ship hold indicator
; $07F9
        bsr     prompt_player           ; Prompt with "PLAY PLAYER "
        jsr     clear_playfield         ; Clear the playfield
        clra
        sta     isr_splash_task         ; Disable isr splash-task animation
        jsr     draw_bottom_line        ; Draw line across screen under player
        lda     player_data_msb         ; Current player
        rora                            ; Right bit tells all
        bcs     loc_0872                ; Go do player 1
; $080E
        ;bsr     restore_shields_2       ; Restore shields for player 2
        jsr     draw_bottom_line        ; Draw line across screen under player
loc_0814:        
        ;bsr     init_rack               ; Initialize alien rack for current player
        ;bsr     enable_game_tasks       ; Enable game tasks in ISR
        ldb     #0x20                   ; Enable ...
        jsr     sound_bits_3_on         ; ... sound amplifier

; $081F
; GAME LOOP
1$:     jsr     plr_fire_or_demo        ; Initiate player shot if button pressed
        jsr     plyr_shot_and_bump      ; Collision detect player's shot and rack-bump
        ;bsr     count_aliens            ; Count aliens (count to 2082)
        jsr     adjust_score            ; Adjust score (and print) if there is an adjustment
        tst     num_aliens              ; Number of live aliens. All aliens gone?
        ;beq     loc_09EF                ; Yes ... end of turn
        jsr     a_shot_reload_rate      ; Update alien-shot-rate based on player's score
        ;bsr     sub_0935                ; Check (and handle) extra ship award
        ;bsr     speed_shots             ; Adjust alien shot speed
        ;bsr     shot_sound              ; Shot sound on or off with 2025
        jsr     sub_0A59                ; Check if player is hit
        beq     2$                      ; No hit ... jump handler
        ldb     #0x04                   ; Player hit sound
        jsr     sound_bits_3_on         ; Make explosion sound
2$:     ;bsr     fleet_delay_ex_ship     ; Extra-ship sound timer, set fleet-delay, play fleet movement sound
;       out     (watchdog),a
        ;bsr     ctrl_saucer_sound       ; Control saucer sound
        bra     1$                      ; Continue game loop

; $0857
; Test for 1 or 2 player start button press
loc_0857:
        ldy     #message_b_1_or_2       ; "1 OR 2PLAYERS BUTTON"
        bsr     print_message           ; Print message
        ldb     #0x98                   ; -2 (take away 2 credits)
;       in      a,(inp1)
;       rrca
;       rrca
;       jp      c,$086D                 ; 2 player button pressed ... do it
;       rrca
;       jp      c,new_game              ; One player start ... do it
        ldx     #KEYROW                 ; assuming HL/X is 'free'
        lda     #~(1<<2)                ; Column 2 ('2')
        sta     2,x
        lda     ,x                      ; Read player controls
        bita    #(1<<4)                 ; 2 player button pressed? (keybd '2')
        beq     loc_086D                ; Yes ... do it
        lda     #~(1<<1)                ; Column 1 ('1')
        sta     2,x
        lda     ,x                      ; Read player controls
        bita    #(1<<4)                 ; One player start? (keybd '1')
        lbeq    new_game                ; Yes ... do it
        jmp     loc_077F                ; Keep waiting on credit or button

; $086D
; 2 PLAYER START
loc_086D:
        lda     #1                      ; Flag 2 player game
        jmp     loc_079B                ; Continue normal startup

; $0872
loc_0872:
        jsr     restore_shields_1       ; Restore shields for player 1
        bra     loc_0814                ; Continue in game loop

; $0878
        ldb     ref_alien_dxr           ; Alien deltaY
        ldy     ref_alien_yr            ; Alien coordinates
        bra     get_al_ref_ptr          ; HL/X is 21FC or 22FC and out

; $0886     
get_al_ref_ptr:
        lda     player_data_msb         ; Player data MSB (21 or 22)
        ldb     #0xfc                   ; 21FC or 22FC ... alien coordinates
        tfr     d,x
        rts

; $088D
; Print "PLAY PLAYER " and blink score for 2 seconds.
prompt_player:
        ldx     #vram+0x0711            ; Screen coordinates
        ldy     #message_p1             ; Message "PLAY PLAYER<1>"
        ldb     #14                     ; 14 bytes in message
        bsr     print_message           ; Print the message
        lda     player_data_msb         ; Get the player number
        rora                            ; C will be set for player 1
        lda     #0x1c                   ; The "2" character
        ldx     #vram+0x1311            ; Replace the "<1>" with "<2">
        bcs     1$
        bsr     draw_char               ; If player 2 ... change the message
1$:     lda     #176                    ; Delay of 176 (roughly 2 seconds)
        sta     isr_delay               ; Set the ISR delay value
2$:     lda     isr_delay               ; Get the ISR delay value
        bne     3$
        rts                             ; Has the 2 second delay expired? Yes ... done
3$:     anda    #4                      ; Every 4 ISRs ...
        bne     4$                      ; ... flash the player's score
        ;bsr     sub_09CA                ; Get the score descriptor for the active player
        jsr     draw_score              ; Draw the score
        bra     2$                      ; Back to the top of the wait loop
4$:     ldb     #32                     ; 32 rows (4 characters * 8 bytes each)
        ldx     #vram+0x031c            ; Player-1 score on the screen
        lda     player_data_msb         ; Get the player number
        rora                            ; C will be set for player 1
        bcs     5$                      ; We have the right score coordinates
        ldx     #vram+0x151c            ; Use coordinates for player-2's score
5$:     jsr     clear_small_sprite      ; Clear a one byte sprite at HL/X
        bra     2$                      ; Back to the top of the wait loop
                
; $08D1
get_ships_per_cred:
; Get number of ships from DIP settings
        lda     #3                      ; fixed for now
        rts
        
; $08F3
; Print a message on the screen
; HL/X = coordinates
; DE/Y = message buffer
; C/B = length
print_message:
        lda     ,y+                     ; get character
        pshs    b,y
        bsr     draw_char
        puls    b,y
        decb
        bne     print_message
        rts

; $08FF
; Get pointer to 8 byte sprite number in A and
; draw sprite on screen at HL/X
draw_char:
        ldy     #loc_1E00
        ldb     #8
        mul                             ; D=offset
        leay    d,y                     ; ptr data
        ldb     #8
; hit watchdog
        jmp     draw_simp_sprite

; $092E
; Get number of ships for active player
sub_092E:
        jsr     get_player_data_ptr     ; HL/X points to player data
        tfr     x,d
        ldb     #0xff                   ; last byte
        tfr     d,x
        lda     ,x                      ; Get number of ships
        rts

; $097C
alien_score_value:
        ldx     #alien_scores           ; Table for scores for hitting alien
        cmpa    #2                      ; 0 or 1 (lower two rows) ...
        bcs     9$                      ; ... return HL points to value 10
        leax    1,x                     ; next value
        cmpa    #4                      ; 2 or 3 (middle two rows) ...
        bcs     9$                      ; ... return HL points to value 20
        leax    1,x                     ; Top row return HL points to value 30
9$:     rts        

; $09AD
; Print 4 digits in Y @X
print_4_digits:
        tfr     y,d
        pshs    b
        bsr     draw_hex_byte
        puls    a

; $09B2        
; Display 2 digits in A to screen at HL/X
draw_hex_byte:
        pshs    a
        lsra
        lsra
        lsra
        lsra                            ; MSN
        bsr     sub_09C5                ; to screen @X
        puls    a
        anda    #0x0f                   ; LSN
        bsr     sub_09C5                ; to screen @X
        rts

; $09C5
sub_09C5:
        adda    #0x1A                   ; convert to digit char
        bra     draw_char

; $09D6
; Clear center window of screen
clear_playfield:
        ldx     #vram+2
1$:     clr     ,x+
        tfr     x,d
        andb    #0x1f
        cmpb    #0x1c
        bcs     2$
        leax    6,x
2$:     cmpa    #0x40
        bcs     1$
        rts
             
; $0A59
; Check to see if player is hit
sub_0A59:
        lda     player_alive
        cmpa    #0xff
        rts

; $0A5F
; Start the hit-alien sound and flag the adjustment for the score.
; B contains the row, which determines the score value.
score_for_alien:
        tst     game_mode
        beq     1$
        stb     *z80_c
        ldb     #8
        jsr     sound_bits_3_on
        ldb     *z80_c
        tfr     b,a
        bsr     alien_score_value
        lda     ,x
        clr     score_delta_msb
        sta     score_delta_lsb
        lda     #1
        sta     -1,x
1$:     ldx     #exp_alien_msb
        rts

; $0A80
; Start the ISR moving the sprite. Return when done.
animate:
        lda     #(1<<1)                 ; Start simple linear ...
        sta     isr_splash_task         ; ... sprite animation (splash)
1$:        
;       out     (watchdog),a
        tst     splash_reached          ; Has the sprite reached target?
        beq     1$                      ; No ... wait
        clr     isr_splash_task         ; Stop ISR animation
        rts
                
; $0A93
; Print message from DE/Y to screen at HL/X (length in B) with a
; delay between letters.
print_message_del:
        lda     ,y+
        pshs    b,y
        jsr     draw_char
        puls    b,y
        lda     #7                      ; Delay between letters
        sta     isr_delay
1$:     lda     isr_delay
        deca                            ; Is it 1?
        bne     1$        
        decb
        bne     print_message_del
        rts

; $0AAB
splash_squiggly:
        ldx     #obj4_timer_msb         ; Pointer to game-object 4 timer
        jmp     loc_024B                ; Process squiggly-shot in demo mode
        
; $0AB1
one_sec_delay:
        lda     #0x40                   ; Delay of 64 (tad over 1 sec)
        bra     wait_on_delay           ; Do delay

; $0AB6
two_sec_delay:
        lda     #0x80                   ; Delay of 128 (tad over 2 sec)
        bra     wait_on_delay           ; Do delay

; $0ABB
splash_demo:
        puls    x                       ; Drop the call to ABF and ...
        jmp     loc_0072                ; ... do a demo game loop without sound

; $0ABF
; Different types of splash tasks managed by ISR in splash screens. The ISR
; calls this if in splash-mode. These may have been bit flags to allow all 3 
; at the same time. Maybe it is just easier to do a switch with a rotate-to-carry.
isr_spl_tasks:
        lda     isr_splash_task         ; Get the ISR task number
        rora                            ; In demo play mode?
        bcs     splash_demo             ; 1: Yes ... go do game play (without sound)
        rora                            ; Moving little alien from point A to B?
        lbcs    splash_sprite           ; 2: Yes ... go move little alien from point A to B
        rora                            ; Shooting extra "C" with squiggly shot?
        bcs     splash_squiggly         ; 4: Yes ... go shoot extra "C" in splash
        rts

; $0ACF
; Message to center of screen.
; Only used in one place for "SPACE  INVADERS"
sub_0ACF:
        ldx     #vram+0x714             ; Near center of screen
        ldb     #15                     ; 15 bytes in message
        bra     print_message_del       ; Print and out

; $0AD7
; Wait on ISR counter to reach 0
wait_on_delay:
        sta     isr_delay               ; Delay counter
1$:     tst     isr_delay               ; Get current delay. Zero yet?
        bne     1$                      ; No ... wait on it
        rts

; $0AE2
; Init the splash-animation block
ini_splash_ani:
        ldx     #splash_an_form         ; The splash-animation descriptor
        ldb     #12                     ; 12 bytes
        jmp     block_copy              ; Block copy DE to descriptor
        
; $0AEA
; After initialization ... splash screens
loc_0AEA:
        clra
;       out     (sound1),a
;       out     (sound2),a
        jsr     sub_1982                ; Turn off ISR splash-task
        EI
        bsr     one_sec_delay        
        ldx     #vram+0x0C17            ; Screen coordinates (middle near top)
        ldb     #4                      ; 4 characters in "PLAY"
        tst     splash_animate          ; Splash screen type
        lbne    loc_0BE8                ; Not 0 ... do "normal" PLAY
        ldy     #message_play_UY        ; "PLAy" with an upside down 'Y' for splash screen
        bsr     print_message_del
        ldy     #message_invaders       ; "SPACE  INVADERS"
loc_0B0B:
        bsr     sub_0ACF                ; Print to middle-ish of screen
        bsr     one_sec_delay
        jsr     draw_adv_table          ; Draw "SCORE ADVANCE TABLE" with print delay
        bsr     two_sec_delay
        tst     splash_animate
        bne     loc_0B4A                ; Not 0 ... no animations
; $0B1E        
; Animate small alien replacing upside-down Y with correct Y
        ldy     #byte_0_1A95            ; Animate sprite from Y=FE to Y=9E step -1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (small alien)
        ldy     #byte_0_1BB0            ; Animate sprite from Y=98 to Y=FF step 1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (alien pulling upside down Y)
        bsr     one_sec_delay           ; One second delay
        ldy     #byte_0_1FC9            ; Animate sprite from Y=FF to Y=97 step 1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (alien pushing Y)
        bsr     one_sec_delay           ; One second delay
        ldx     #vram+0x0fb7            ; Where the splash alien ends up
        ldb     #10                     ; 10 rows
        jsr     clear_small_sprite      ; Clear a one byte sprite at HL
        jsr     two_sec_delay           ; Two second delay

; Play demo
loc_0B4A:  
        jsr     clear_playfield
        tst     p1_ships_rem            ; Number of ships for player-1. If non zero ...
        bne     1$                      ; ... keep it (counts down between demos)
        jsr     get_ships_per_cred      ; Get number of ships from DIP settings
        sta     p1_ships_rem            ; Reset number of ships for player-1
        jsr     remove_ship             ; Remove a ship from stash and update indicators
        
1$:     jsr     copy_ram_mirror         ; Block copy ROM mirror to initialize RAM
        jsr     init_aliens             ; Initialize all player 1 aliens
        jsr     draw_shield_pl1         ; Draw shields for player 1 (to buffer)
        jsr     restore_shields_1       ; Restore shields for player 1 (to screen)
        lda     #(1<<0)                 ; ISR splash-task ...
        sta     isr_splash_task         ; ... playing demo
        jsr     draw_bottom_line

.ifndef BUILD_OPT_DISABLE_DEMO
2$:     jsr     plr_fire_or_demo        ; In demo ... process demo movement and always fire
        jsr     loc_0BF1                ; Check player shot and aliens bumping edges of screen and hidden message
; watchdog
        jsr     sub_0A59                ; Has demo player been hit?
        beq     2$                      ; No ... continue game
        clr     plyr_shot_status        ; Remove player shot from activity
3$:     jsr     sub_0A59                ; Wait for demo player ...
        bne     3$                      ; ... to stop exploding
.endif

; Credit information
        clr     isr_splash_task         ; Turn off splash animation
        jsr     one_sec_delay
        jsr     sub_1988                ; Jump straight to clear-play-field
        ldb     #12                     ; Message size
        ldx     #vram+0x0811            ; Screen coordinates
        ldy     #message_coin           ; "INSERT  COIN"
        jsr     print_message           ; Print message
        lda     splash_animate          ; Do splash animations?
        bne     4$                      ; Not 0 ... not on this screen
        ldx     #vram+0x0f11            ; Screen coordinates
        lda     #2                      ; Character "C"
        jsr     draw_char               ; Put an extra "C" for "CCOIN" on the screen
4$:     ldu     #credit_table           ; "<1 OR 2 PLAYERS>  "
        jsr     read_pri_struct         ; Load the screen,pointer
        jsr     sub_184C                ; Print the message
; display coin info on demo screen is a dipswitch option
;       in      a,(inp2)
;       rlca
;       jp      c,$0BC3
        leau    0,u                     ; "*1 PLAYER  1 COIN "
        jsr     loc_183A                ; Load the descriptor
; $0BC3        
        jsr     two_sec_delay           ; Print TWO descriptors worth ???
        tst     splash_animate          ; Doing splash animation?
        bne     5$                      ; Not 0 ... not on this screen
        ldy     #byte_0_1FD5            ; Animation for small alien to line up with extra "C"
        jsr     ini_splash_ani          ; Copy the animation block
        jsr     animate                 ; Wait for the animation to complete
        jsr     sub_189E                ; Animate alien shot to extra "C"
5$:     lda     splash_animate
        eora    #1                      ; Toggle the splash screen animation for next time
        sta     splash_animate
        jsr     clear_playfield         ; Clear play field
        jmp     loc_18DF                ; Keep splashing
        
; $0BE8
loc_0BE8:
        ldy     #message_play_Y         ; "PLAY" with normal 'Y'
        jsr     print_message_del       ; Print it
        jmp     loc_0B0B                ; Continue with splash (HL/X will be pointing to next message)

loc_0BF1:
        jsr     plyr_shot_and_bump      ; Check if player is shot and aliens bumping the edge of screen
        jmp     check_hidden_mes        ; Check for hidden-message display sequence

message_corp:
;       "TAITO COP"
        .db 0x13, 0, 8, 0x13, 0xE, 0x26, 2, 0xE, 0xF    

; $1424
; Clear a sprite from the screen (standard pixel number descriptor).
; ** We clear 2 bytes even though the draw-simple only draws one.
erase_simple_sprite:
        bsr     cnvt_pix_number
1$:     pshs    x
        clr     ,x+
        clr     ,x+
        puls    x
        leax    32,x
        decb
        bne     1$
        rts

; $1439
; Display character to screen
; HL/X = screen coordinates
; DE/Y = character data
; B = number of rows
draw_simp_sprite:
        lda     ,y+
        sta     ,x
        leax    32,x
        decb
        bne     draw_simp_sprite
        rts

; $1452
; Erases a shifted sprite from screen (like for player's explosion)
erase_shifted:
        bsr     cnvt_pix_number         ; Convert pixel number in HL to coorinates with shift
1$:     pshs    x   
        lda     ,y+                     ; Get picture value. Next in image
;       out     (shft_data),a
;       in      a,(shft_in)
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        clra                            ; Shift register over ...
;       out     (shft_data),a
;       in      a,(shft_in)
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        puls    x
        leax    32,x                    ; Add 32 to next row
        decb                            ; All rows done?
        bne     1$                      ; No ... erase all
        rts                

; $1474
; Convert pixel number in HL to screen coordinate and shift amount.
; HL gets screen coordinate.
; Hardware shift-register gets amount.
cnvt_pix_number:
        pshs    b
        tfr     x,d
        andb    #7                      ; *** FIX ME
;       out     (shftamt),a
        puls    b
        jmp     conv_to_scr        

; $147C
; In a multi-player game the player's shields are block-copied to and from RAM between turns.
; HL/X = screen pointer
; DE/Y = memory buffer
; B = number of rows
; C = number of columns
remember_shields:
        pshs    x
1$:     ldb     *z80_c
2$:     lda     ,x+                     ; From screen
        sta     ,y+                     ; To buffer
        decb
        bne     2$
        puls    x                       ; Original start
        leax    32,x                    ; Bump X by one screen row
        dec     *z80_b                  ; Row counter
        bne     1$
        rts

; $1491
draw_spr_collision:
        bsr     cnvt_pix_number         ; Convert pixel number to coord and shift
        clr     collision               ; Clear the collision-detection flag
1$:     pshs    b,x   
        lda     ,y+                     ; Get byte. Next in pixel pattern
;       out     (shft_data),a
;       in      a,(shft_in)
        tfr     a,b                     ; B is destructive copy
        andb    ,x                      ; Any bits from pixel collide with bits on screen?
        beq     2$                      ; No ... leave flag alone
        ldb     #1                      ; Yes ... set ...
        stb     collision               ; ... collision flag
2$:     ora     ,x                      ; OR it onto the screen
        sta     ,x+                     ; Store new screen value. Next byte on screen
        clra                            ; Write zero ...
;       out     (shft_data),a
;       in      a,(shft_in)
        tfr     a,b                     ; B is destructive copy
        andb    ,x                      ; Any bits from pixel collide with bits on screen?
        beq     3$                      ; No ... leave flag alone
        ldb     #1                      ; Yes ... set ...
        stb     collision               ; Yes ... set collision flag
3$:     ora     ,x                      ; OR it onto the screen
        sta     ,x                      ; Store new screen pattern
        puls    b,x
        leax    32,x                    ; Add 32 to get to next row
        decb                            ; All done?
        bne     1$                      ; No ... do all rows
        rts                

; $14CB
clear_small_sprite:
; Clear a one byte sprite at HL/X. B=number of rows.
        clra
sub_14CC:
1$:     sta     ,x
        leax    32,x
        decb
        bne     1$
        rts

; $14D8
; The player's shot hit something (or is being removed from play) 
player_shot_hit:
        lda     plyr_shot_status        ; Player shot flag
        cmpa    #5                      ; Alien explosion in progress?
        beq     9$                      ; Yes ... ignore this function
        cmpa    #2                      ; Normal movement?
        bne     9$                      ; No ... out
        ldb     obj1_coor_yr            ; Get Yr coordinate of player shot
        cmpb    #0xd8                   ; Compare to 216 (40 from Top-rotated)
        bcc     loc_1530                ; Yr is within 40 from top initiate miss-explosion (shot flag 3)
        tst     alien_is_exploding      ; Is an alien blowing up?
        bne     1$
9$:     rts                             ; No ... out
1$:     cmpb    #0xce                   ; Compare to 206 (50 from rotated top)
        lbcc    loc_1579                ; Yr is within 50 from top? Yes ... saucer must be hit
        addb    #6                      ; Offset to coordinate for wider "explosion" picture
        stb     *z80_b
        lda     ref_alien_yr            ; Ref alien Y coordinate
; If the lower 4 rows are all empty then the reference alien's Y coordinate will wrap around from 0 to F8.
; At this point the top row of aliens is in the shields and we will assume that everything is within
; the rack.
        cmpa    #0x90                   ; This is true if ...
        bcc     code_bug_1              ; ... aliens are down in the shields
        cmpa    *z80_b                  ; Compare to shot's coordinate
        bcc     loc_1530                ; Outside the rack-square ... do miss explosion

; $1504
; We get here if the player's shot hit something within the rack area (a shot or an alien).
; Find the alien that is (or would be) where the shot hit. If there is no alien alive at the row/column
; then the player hit an alien missile. If there is an alien then explode the alien.
;
; There is a code bug here, but it is extremely subtle. The algorithm for finding the row/column in the
; rack works by adding 16 to the reference coordinates (X for column, Y for row) until it passes or equals
; the target coordinates. This works great as long as the target point is within the alien's rack area.
; If the reference point is far to the right, the column number will be greater than 11, which messes
; up the column/row-to-pointer math.
;
; The entire rack of aliens is based on the lower left alien. Imagine all aliens are dead except the
; upper left. It wiggles down the screen and enters the players shields on the lower left where it begins
; to eat them. Imagine the player is under his own shields on the right side of the screen and fires a
; shot into his own shield.
;
; The alien is in the rack on row 4 (rows are numbered from bottom up starting with 0). The shot hits
; the shields below the alien's Y coordinate and gets correctly assigned to row 3. The alien is in the rack
; at column 0 (columns are numbered from left to right starting with 0). The shot hits the shields far to
; the right of the alien's X coordinate. The algorithm says it is in column 11. But 0-10 are the only
; correct values.
;
; The column/row-to-pointer math works by multiplying the row by 11 and adding the column. For the alien 
; that is 11*4 + 0 = 44. For the shot that is 11*3 +11 = 44. The game thinks the shot hit the alien.
code_bug_1:        
        stb     *z80_l                  ; L now holds the shot coordinate (adjusted)
        bsr     find_row                ; Look up row number to B
        lda     obj1_coor_xr            ; Player's shot's Xr coordinate ...
        sta     *z80_h                  ; ... to H
        bsr     find_column             ; Get alien's coordinate
        stx     exp_alien_xr            ; Put it in the exploding-alien descriptor
        lda     #5                      ; Flag alien explosion ...
        sta     plyr_shot_status        ; ... in progress
        bsr     get_alien_stat_ptr      ; Get descriptor for alien
        tst     ,x                      ; Is alien alive
        beq     loc_1530                ; No ... must have been an alien shot
        clr     ,x                      ; Make alien invader dead
        jsr     score_for_alien         ; Makes alien explosion sound and adjust score
        jsr     read_desc               ; Load 5 byte sprite descriptor
        jsr     draw_sprite             ; Draw explosion sprite on screen
        lda     #0x10                   ; Initiate alien-explosion
        sta     exp_alien_timer         ; ... timer to 16
        rts

; $1530
; Player shot leaving playfield, hitting shield, or hitting an alien shot
loc_1530:
        lda     #3                      ; Mark ...
        sta     plyr_shot_status        ; ... player shot hit something other than alien
        bra     loc_154A                ; Finish up

; $1538
; Time down the alien explosion. Remove when done.
a_explode_time:
        dec     exp_alien_timer         ; Decrement alien explosion timer
        beq     1$
        rts                             ; Not done  ... out
1$:     ldx     exp_alien_xr            ; Pixel pointer for exploding alien
        ldb     #0x10                   ; 16 row pixel
        jsr     erase_simple_sprite     ; Clear the explosion sprite from the screen

loc_1545:        
        lda     #4                      ; 4 means that ...
        sta     plyr_shot_status        ; ... alien has exploded (remove from active duty)

loc_154A:
        clr     alien_is_exploding      ; Turn off alien-is-blowing-up flag
        ldb     #0xf7                   ; Turn off ...
        jmp     sound_bits_3_off        ; ... alien exploding sound

; $1554
; Count number of 16s needed to bring reference (in A) up to target (in H).
; If the reference starts out beyond the target then we add 16s as long as
; the reference has a signed bit. But these aren't signed quantities. This
; doesn't make any sense. This counting algorithm produces questionable 
; results if the reference is beyond the target.
cnt_16s:
        clr     *z80_c
        cmpa    *z80_h
        bcs     1$
        bsr     wrap_ref
1$:     cmpa    *z80_h
        bcs     2$
        rts
2$:     adda    #16
        inc     *z80_c
        bra     1$                

; $1562
find_row:
; L contains a Yr coordinate. Find the row number within the rack that corresponds
; to the Yr coordinate. Return the row coordinate in L and the row number in C.
        lda     ref_alien_yr
        ldb     *z80_l
        stb     *z80_h
        bsr     cnt_16s
        ldb     *z80_c
        decb
        sbca    #16
        sta     *z80_l
        rts

; $1562
; H contains a Xr coordinate. Find the column number within the rack that corresponds
; to the Xr coordinate. Return the column coordinate in H and the column number in C.
find_column:
        lda     ref_alien_xr
        bsr     cnt_16s
        sbca    #16
        sta     *z80_h
        rts

loc_1579:
        lda     #1
        sta     saucer_hit
        bra     loc_1545

; $1581
; B is row number. C is column number (starts at 1). 
; Return pointer to alien-status flag for current player.
get_alien_stat_ptr:
        lda     #11                     ; 
        mul                             ; row*11
        addb    *z80_c                  ; Add row offset to column offset
        decb                            ; -1
        lda     player_data_msb         ; Set MSB of HL/D with active player indicator
        tfr     d,x                     ; ->X
        rts

; $1590
; This is called if the reference point is greater than the target point. I believe the goal is to
; wrap the reference back around until it is lower than the target point. But the algorithm simply adds
; until the sign bit of the the reference is 0. If the target is 2 and the reference is 238 then this
; algorithm moves the reference 238+16=244 then 244+16=4. Then the algorithm stops. But the reference is
; STILL greater than the target.
;
; Also imagine that the target is 20 and the reference is 40. The algorithm adds 40+16=56, which is not
; negative, so it stops there.
;
; I think the intended code is "JP NC" instead of "JP M", but even that doesn't make sense.
wrap_ref:
        inc     *z80_c
        adda    #16
        bmi     wrap_ref
        rts

; $1597
; When rack bumps the edge of the screen then the direction flips and the rack
; drops 8 pixels. The deltaX and deltaY values are changed here. Interestingly
; if there is only one alien left then the right value is 3 instead of the 
; usual 2. The left direction is always -2.
rack_bump:
        tst     rack_direction          ; Get rack direction, Moving right?
        bne     3$                      ; No ... handle moving left
        ldx     #vram+0x1AA4            ; Line down the right edge of playfield
        bsr     sub_15C5                ; Check line down the edge
        bcc     2$                      ; Nothing is there ... return
        ldb     #-2                     ; Delta X of -2
        lda     #1                      ; Rack now moving right
1$:     sta     rack_direction          ; Set new rack direction
        stb     ref_alien_dxr           ; Set new delta X
        lda     rack_down_delta         ; Set delta Y ...
        sta     ref_alien_dyr           ; ... to drop rack by 8
2$:     rts
; $15B7
3$:     ldx     #vram+0x0124            ; Line down the left edge of playfield
        bsr     sub_15C5                ; Check line down the edge
        bcc     2$                      ; Nothing is there ... return
        jsr     sub_18F1                ; Get moving-right delta X value of 2 (3 if just one alien left)
        clra                            ; Rack now moving left
        bra     1$                      ; Set rack direction

; $15C5
sub_15C5:
        ldb     #23                     ; Checking 23 bytes in a line up the screen from near the bottom
1$:     tst     ,x                      ; Is screen memory empty?
        bne     loc_166B                ; No ... set carry flag and out
        leax    1,x                     ; Next byte on screen
        decb                            ; All column done?
        bne     1$                      ; No ... keep looking
        rts
                
; $15D3
; Draw sprite at [DE/Y] to screen at pixel position in HL/X
; The hardware shift register is used in converting pixel positions
; to screen coordinates.
draw_sprite:
        jsr     cnvt_pix_number
        pshs    x
1$:     pshs    x
        lda     ,y+
;       out     (shft_data),a
;       in      a,(shft_in)
        sta     ,x+
        clra
;       out     (shft_data),a
;       in      a,(shft_in)
        sta     ,x
        puls    x
        leax    32,x
        decb
        bne     1$                        
        puls    x
        rts
        
; $1611
get_player_data_ptr:
; Set HL/X with 2100 if player 1 is active or 2200 if player 2 is active
        clrb
        lda     player_data_msb
        tfr     d,x
        rts

; $1618
plr_fire_or_demo:
; Initiate player fire if button is pressed.
; Demo commands are parsed here if in demo mode
        lda     player_alive            ; Is there an active player?
        cmpa    #0xff                   ; FF = alive
        bne     9$                      ; Player has been shot - no firing
1$:     ldd     obj0_timer_msb          ; Player task timer active?
        bne     9$                      ; No ... no firing till player object starts <<---???
        tst     plyr_shot_status        ; Does the player have a shot on the screen?
        bne     9$                      ; Yes ... ignore
        tst     game_mode               ; Are we in game mode?
        bne     loc_1652                ; No ... in demo mode ... constant firing in demo
        tst     fire_bounce             ; Is fire button being held down?
        bne     loc_1648                ; Yes ... wait for bounce
        bsr     read_inputs             ; Read active player controls
        anda    #0x10                   ; Fire-button pressed?
        beq     9$                      ; No ... out
        lda     #1                      ; Flag
        sta     plyr_shot_status        ; Flag shot active
        sta     fire_bounce             ; Flag that fire button is down
9$:     rts        

loc_1648:
        bsr     read_inputs             ; Read active player controls
        anda    #0x10                   ; Fire-button pressed?
        bne     9$                      ; Yes ... ignore
        sta     fire_bounce             ; Else ... clear flag
9$:     rts

; Handle demo (constant fire, parse demo commands)        
loc_1652:
        lda     #1                      ; Demo fires ...
        sta     plyr_shot_status        ; ... constantly
        ldx     demo_cmd_ptr_msb        ; Demo command buffer
        leax    1,x                     ; Next position
        cmpx    #demo_commands+10       ; Buffer from 1F74 to 1F7E (was CP $7E)
        bne     1$
        ldx     #demo_commands          ; ... overflow
1$:     stx     demo_cmd_ptr_msb        ; Next demo command
        lda     ,x                      ; Get next command
        sta     next_demo_cmd           ; Set command for movement
        rts        

; $166B
loc_166B:
        SCF
        rts

; $17C0
; Read control inputs for active player
read_inputs:
        lda     player_data_msb         ; Get active player
; this is only going to work if the offsets within memory
; are preserved on this port
; original $2100,$220 -> 6809 $6100,$6200        
        rora                            ; Test player
        bcc     1$
; read player 1 inputs
        clra
        rts
1$:
; read player 2 inputs                
        clra
        rts

; $1815
; Draw "SCORE ADVANCE TABLE"
draw_adv_table:
        ldx     #vram+0x0410            ; 0x410 is 1040 rotCol=32, rotRow=16
        ldy     #message_adv            ; "*SCORE ADVANCE TABLE*"
        ldb     #21                     ; 21 bytes in message
        jsr     print_message
        lda     #10                     ; 10 bytes in every "=xx POINTS" string
        sta     temp_206C
        ldu     #word_0_1DBE
1$:     bsr     read_pri_struct         ; Get X=coordinate, Y=message
        bcs     2$                      ; Move on if done
        bsr     sub_1844                ; draw 16-byte sprite
        bra     1$                      ; Do all in table
        rts
; $1834
        jsr     one_sec_delay
2$:     ldu     #word_0_1DCF
loc_183A:
1$:     bsr     read_pri_struct         ; Get X=coordinate, Y=message
        bcc     2$                      ; continue of not done
        rts
2$:     bsr     sub_184C                ; Print Message
        bra     1$                      ; Do all in table
; $1844
sub_1844:
        ldb     #16
        jsr     draw_simp_sprite
        rts

; $184C
sub_184C:
        ldb     temp_206C
        jsr     print_message_del
        rts
        
; $1856
read_pri_struct:
; Read a 4-byte print-structure pointed to by BC/U
; HL/X=Screen coordiante, DE/Y=pointer to message
; If the first byte is FF then return with C=1.
        lda     ,u
        cmpa    #0xff
        SCF
        bne     1$
        rts
1$:     ldx     ,u++                    ; screen coordinate
        ldy     ,u++                    ; message address
        CCF
        rts        

; $1868
; Moves a sprite up or down in splash mode. Interrupt moves the sprite. When it reaches
; Y value in 20CA the flag at 20CB is raised. The image flips between two pictures every
; 4 movements.      
splash_sprite:
        ldx     #splash_an_form         ; Descriptor
        inc     ,x+                     ; Change image, Point to delta-x
        lda     ,x                      ; Get delta-x
        sta     *z80_c
        jsr     add_delta               ; Add delta-X and delta-Y to X and Y
        stb     *z80_b                  ; Current y coordinate
        lda     splash_target_y         ; Has sprite reached ...
        cmpa    *z80_b                  ; ... target coordinate?
        beq     2$                      ; Yes ... flag and out
        lda     splash_an_form          ; Image number
        ldx     splash_im_rest_msb      ; Image
        anda    #4                      ; Watching bit 3 for flip delay
        bne     1$                      ; Did bit 3 go to 0? No ... keep current image
        leax    48,x                    ; 16*3 ... use other image form
1$:     stx     splash_image_msb        ; Image to descriptor structure
        ldx     #splash_xr              ; X,Y,Image descriptor (x,y swapped for 6809)
        jsr     read_desc               ; Read sprite descriptor
        exg     x,y                     ; Image to DE/Y, position to HL/X
        jmp     draw_sprite             ; Draw the sprite

; $1898
2$:     lda     #1
        sta     splash_reached
        rts

; $189E
;Animate alien shot to extra "C" in splash
sub_189E:
        ldx     #obj4_timer_msb
        ldy     #byte_0_1BC0
        ldb     #16
        jsr     block_copy
        lda     #2
        sta     shot_sync
        lda     #0xff
        sta     alien_shot_delta
        lda     #(1<<2)
        sta     isr_splash_task
1$:     lda     squ_shot_status
        anda    #1
        beq     1$
2$:     lda     squ_shot_status
        anda    #1
        bne     1$
        ldx     #vram+0x0f11
        lda     #0x26
        jsr     draw_char
        jmp     two_sec_delay
        
; $18D4                
start:
        lds     #stack
        ldb     #0
        jsr     sub_01E6                ; copy ROM to RAM
        jsr     draw_status

; $18DF
loc_18DF:
        lda     #8
        sta     a_shot_reload_rate
        jmp     loc_0AEA                ; splash animation

; $18E7
; Get player-alive flag for OTHER player
sub_18E7:
        lda     player_data_msb
        ldx     #player1_alive
; this only works if msb is odd for p1, even for p2
        lsra
        bcc     9$
        leax    1,x
9$:     rts        

; $18F1
; If there is one alien left then the right motion is 3 instead of 2. That's
; why the timing is hard to hit after the change.
sub_18F1:
        ldb     #2
        lda     num_aliens
        deca
        bne     9$
        incb
9$:     rts
        
; $18FA
sound_bits_3_on:
;       ld      a,(soundport3)
;       or      b
;       ld      (soundport3),a
;       out     (sound),a
        rts

; $190A
plyr_shot_and_bump:
        jsr     player_shot_hit         ; Player's shot collision detection
        jmp     rack_bump               ; Change alien deltaX and deltaY when rack bumps edges
                                
; $1982
sub_1982:
        sta     isr_splash_task
        rts

; $191A
; Print score header " SCORE<1> HI-SCORE SCORE<2> "
draw_score_head:
        ldb     #0x1c                   ; 28 bytes in message
        ldx     #vram+0x1e
        ldy     #message_score
        jmp     print_message

; $1925
sub_1925:
        ldx     #p1_scor_l              ; Player 1 score descriptor
        bra     draw_score

sub_192B:        
; $192B        
        ldx     #p2_scor_l              ; Player 2 score descriptor
        bra     draw_score

; $1931
; Print score.
; HL/X = descriptor
draw_score:
        ldy     ,x++                    ; value
        ldx     ,x++                    ; coordinate
        jmp     print_4_digits

; $193C
; Print message "CREDIT "
sub_193C:
        ldb     #7                      ; 7 bytes in message
        ldx     #vram+0x1101            ; Screen coordinates
        ldy     #message_credit         ; Message = "CREDIT "
        jmp     print_message           ; Print message

; $1947
draw_num_credits:
; Display number of credits on screen
        lda     num_coins               ; Number of credits
        ldx     #vram+0x1801            ; Screen coordinates
        jmp     draw_hex_byte           ; Character to screen
                
; $1950
print_hi_score:
        ldx     #hi_scor_l              ; Hi Score descriptor
        bra     draw_score              ; Print Hi-Score
                
; $1956
; Print scores (with header) and credits (with label)
draw_status:
        jsr     clear_screen            ; Clear the screen
        bsr     draw_score_head         ; Print score header
        bsr     sub_1925                ; Print player 1 score
        bsr     sub_192B                ; Print player 2 score
        bsr     print_hi_score          ; Print hi score
        bsr     sub_193C                ; Print credit table
        bra     draw_num_credits        ; Number of credits

; $1979
loc_1979:
        bsr     disable_game_tasks      ; Disable ISR game tasks
        bsr     draw_num_credits        ; Display number of credits on screen
        bra     sub_193C                ; Print message "CREDIT"
        
; $199A
; There is a hidden message "TAITO COP" (with no "R") in the game. It can only be 
; displayed in the demonstration game during the splash screens. You must enter
; 2 seqences of buttons. Timing is not critical. As long as you eventually get all
; the buttons up/down in the correct pattern then the game will register the
; sequence.
;
; 1st: 2start(down) 1start(up)   1fire(down) 1left(down) 1right(down)
; 2nd: 2start(up)   1start(down) 1fire(down) 1left(down) 1right(up)
;
; Unfortunately MAME does not deliver the simultaneous button presses correctly. You can see the message in
; MAME by changing 19A6 to 02 and 19B1 to 02. Then the 2start(down) is the only sequence. 
check_hidden_mes:
        tst     hid_mess_seq            ; Has the 1st "hidden-message" sequence been registered?
        bne     2$                      ; Yes ... go look for the 2nd sequence
;       in      a,(inp1)                ; Get player inputs
;        lda     #0x72                   ; *** fudge
        anda    #0x76                   ; 0111_0110 Keep 2Pstart, 1Pstart, 1Pshot, 1Pleft, 1Pright
        suba    #0x72                   ; 0111_0010 1st sequence: 2Pstart, 1Pshot, 1Pleft, 1Pright
        beq     1$                      
        rts                             ; Not first sequence ... out
1$:     inca                            ; Flag that 1st sequence ...
        sta     hid_mess_seq            ; ... has been entered
2$:
;       in      a,(inp1)                ; Check inputs for 2nd sequence
;        lda     #0x34                   ; *** fudge
        anda    #0x76                   ; 0111_0110 Keep 2Pstart, 1Pstart, 1Pshot, 1Pleft, 1Pright
        cmpa    #0x34                   ; 0011_0100 2nd sequence: 1Pstart, 1Pshot, 1Pleft 
        beq     3$
        rts                             ; If not second sequence ignore
3$:     ldx     #vram+0x0A1B            ; Screen coordinates
        ldy     #message_corp           ; Message = "TAITO COP" (no R)
        ldb     #9                      ; Message length
        jmp     print_message           ; Print message and out
                
; $1988
sub_1988:
        jmp     clear_playfield         ; Clear playfield and out

; $19D1
; Enable ISR game tasks 
enable_game_tasks:
        lda     #1                      ; Set ISR ...
loc_19D3:        
        sta     suspend_play            ; ... game tasks enabled
        rts
        
; $19D7
; Disable ISR game tasks
; Clear 20E9 flag
disable_game_tasks:
        clra                            ; Clear ISR game tasks flag
        bra     loc_19D3                ; Save a byte (the RET)

; $19DC
sound_bits_3_off:
; Turn off bit in sound port
;       ld      a,(soundport3)
;       and     b
;       ld      (soundport3),a
;       out     (sound1),a
        rts

; $19E6
draw_num_ships:
; Show ships remaining in hold for the player
        ldx     #vram+0x0301
        tsta
        beq     2$
; Draw line of ships
1$:     ldy     #player_sprite
        ldb     #16
        sta     *z80_c
        jsr     draw_simp_sprite
        lda     *z80_c
        deca
        bne     1$
; Clear remainder of line        
2$:     ldb     #16
        jsr     clear_small_sprite
        tfr     x,d
        cmpa    #>vram+0x11
        bne     2$
        rts

; $1A06
; The ISRs set the upper bit of 2072 based on where the beam is. This is compared to the
; upper bit of an object's Y coordinate to decide whic ISR should handle it. When the
; beam passes the halfway point (or near it ... at scanline 96), the upper bit is cleared.
; When the beam reaches the end of the screen the upper bit is set.
;
; The task then runs in the ISR if the Y coordiante bit matches the 2072 flag. Objects that
; are at the top of the screen (upper bit of Y clear) run in the mid-screen ISR when
; the beam has moved to the bottom of the screen. Objects that are at the bottom of the screen
; (upper bit of Y set) run in the end-screen ISR when the beam is moving back to the top.
;
; The pointer to the object's Y coordinate is passed in DE. CF is set if the upper bits are
; the same (the calling ISR should execute the task).
comp_y_to_beam:
        ldx     #vblank_status          ; Get the beam position status
        lda     ,y                      ; Get the task structure flag
        anda    #0x80                   ; Only upper bits count
        eora    ,x                      ; XOR them together
        bne     9$                      ; Not the same (CF cleared)
        SCF                             ; Set the CF if the same
9$:     rts
        
; $1A32
block_copy:
        lda     ,y+
        sta     ,x+
        decb
        bne     block_copy
        rts

; $1A3B
; Load 5 bytes sprite descriptor from [HL]
read_desc:
        ldy     ,x++                    ; Sprite picture
        ldu     ,x++                    ; Screen location
        ldb     ,x                      ; Number of bytes in sprite
        tfr     u,x
        rts

; $1A47
; The screen is organized as one-bit-per-pixel.
; In: HL/X contains pixel number (bbbbbbbbbbbbbppp)
; Convert from pixel number to screen coordinates (without shift)
; Shift HL right 3 bits (clearing the top 2 bits)
; and set the third bit from the left.
conv_to_scr:
        pshs    b
        tfr     x,d
        lsra
        rorb
        lsra
        rorb
        lsra
; the original code OR'd H with $20, effectively setting the base @$2000
; but the screen starts at $2400, so we need to subtract the difference
        rorb                            ; D/=8
        suba    #0x04
        tfr     d,x                     ; Back to HL/X
        puls    b
        rts
        
; $1A5C
clear_screen:
        ldx     #vram
1$:     clr     ,x+
        cmpx    #(vram+0x1C00+32)
        bne     1$
        rts

; $1A69
; Logically OR the player's shields back onto the playfield
; DE/Y = sprite
; HL/X = screen
; C = bytes per row
; B = number of rows
restore_shields:
1$:     pshs    x
        ldb     *z80_c
2$:     lda     ,y+                     ; From sprite
        ora     ,x                      ; OR with screen
        sta     ,x+                     ; Back to screen
        decb
        bne     2$
        puls    x                       ; Original start
        leax    32,x                    ; Bump X by one screen row
        dec     *z80_b                  ; Row counter
        bne     1$
        rts

; $1A95
byte_0_1A95:
        .db 0                           ; Image form (increments each draw)
        .db 0                           ; Delta X
        .db 0xFF                        ; Delta Y is -1
        .db 0xFE                        ; Y starting coordinate (swapped for 6809)
        .db 0xB8                        ; X coordinate (swapped for 6809)
        .dw alien_spr_a+0x20            ; Base image (small alien)
        .db 0x10                        ; Size of image (16 bytes)
        .db 0x9E                        ; Target Y coordinate
        .db 0                           ; Reached Y flag
        .dw alien_spr_a+0x20            ; Base image (small alien)

; $1AA6
message_g_over:
; "GAME OVER PLAYER< >"
        .db 6, 0, 0xC, 4, 0x26, 0xE, 0x15, 4, 0x11, 0x26, 0x26
        .db 0xF, 0xB, 0, 0x18, 4, 0x11, 0x24, 0x26, 0x25

; $1ABA
message_b_1_or_2:
; "1 OR 2PLAYERS BUTTON"
        .db 0x1B, 0x26, 0xE, 0x11, 0x26, 0x1C, 0xF, 0xB, 0, 0x18
        .db 4, 0x11, 0x12, 0x26, 1, 0x14, 0x13, 0x13, 0xE, 0xD
        .db 0x26

; $1ACF
message_1_only:
;       "ONLY 1PLAYER BUTTON"
        .db 0xE,0xD,0xB,0x18,0x26,0x1B,0xF,0xB
        .db 0,0x18,4,0x11,0x26,0x26,1,0x14
        .db 0x13,0x13,0xE,0xD,0x26

; $1A7F
remove_ship:
; Remove a ship from the players stash and update the
; hold indicators on the screen.
        jsr     sub_092E                ; Get last byte from player data
        bne     1$
        rts
1$:     pshs    a                       ; Preserve number remaining
        deca                            ; Remove a ship from the stash
        sta     ,x                      ; New number of ships
        jsr     draw_num_ships
        puls    a                       ; Restore number
        ldx     #vram+0x0101
        anda    #0x0f                   ; Make sure it is a digit
        jmp     sub_09C5                ; Print number remaining

; $1AE4
message_score:
;       " SCORE<1> HI-SCORE SCORE<2>"
        .db 0x26,0x12,2,0xE,0x11,4,0x24,0x1B,0x25,0x26,7,8,0x3F
        .db 0x12,2,0xE,0x11,4,0x26,0x12,2,0xE,0x11,4,0x24,0x1C
        .db 0x25,0x26

; this is mainly for debugging
        .bndry  0x100
        
;-------------------------- RAM initialization -----------------------------
; Copied to RAM (2000) C0 bytes as initialization.
; See the description of RAM at the top of this file for the details on this data.
byte_0_1B00:    .db 1,0,0,0x10,0,0,0,0
                .db 2,0x78,0x38,0x78,0x38,0,0xF8,0
                
                .db 0,0x80,0,0x8E,2,0xFF,5,0xC
                .db 0x60,0x1C,0x20,0x30,0x10,1,0,0
                
                .db 0,0,0,0xBB,3,0,0x10,0x90
                .db 0x1C,0x28,0x30,1,4,0,0xFF,0xFF
                
                .db 0,0,2,0x76,4,0,0,0
                .db 0,0,4,0xEE,0x1C,0,0,3
                
                .db 0,0,0,0xB6,4,0,0,1
                .db 0,0x1D,4,0xE2,0x1C,0,0,3

; $1B50->$2050
; GameObject4 (Flying saucer OR alien squiggly shot)     
; - this possibly isn't used, because it gets overwritten
; - with data from $1BC0 (see below)           
                .dw 0x0000              ; obj4Timer
                .db 0                   ; obj4TimerExtra
                .dw game_obj_4          ; obj4TimerHandler
                .db 0                   ; squShotStatus
                .db 0                   ; squShotStepCnt
                .db 1                   ; squShotTrack
                .dw col_fire_table+6    ; squShotCFir
                .db 4                   ; squShotBlowCnt
                .dw squiggly_shot       ; squShotImage
                .db 0                   ; squShotXr (swapped for 6809)
                .db 0                   ; squShotYr (swapped for 6809)
                .db 3                   ; squShotSize

; $1B60->$2060
                .db 0xFF,0,0xC0,0x1C,0,0,0x10
                .db >byte_0_2100
                .db 1,0,0x30,0,0x12,0,0,0
                
; These don't need to be copied over to RAM (see 1BA0 below).
; $1B70
message_p1: 
; "PLAY PLAYER<1>"
        .db 0xF,0xB,0,0x18,0x26,0xF,0xB,0
        .db 0x18,4,0x11,0x24,0x1B,0x25,0xFC
        .db 0

        .db    1
        .db 0xFF
        .db 0xFF
ufo_init_data:
        .db 0                                           ; ufo visible flag
        .db    0
        .db    0
        .db 32                                          ; countdown after ufo hit
        .dw unk_0_1D64                                  ; ufo bitmap address
        .dw vram+0x5D0                                  ; ufo screen loc
        .db 24                                          ; ufo bitmap size
        .db    2
        .db 0x54 ; T
        .db 0x1D
        .dw 0x800                                       ; ptr to code - of which b0 determines which side ufo appears
        .db    0
        .db    6
        .db    0
        .db    0
        .db    1
        .db 0x40 ; @
        .db    0
        .db    1
        .db    0
        .db    0
        .db 0x10
        .db 0x9E ; ×
        .db    0
        .db 0x20
        .db 0x1C

; $1BA0
alien_spr_CYA:
; Alien sprite type C pulling upside down Y
        .db 0x00, 0xC0, 0x20, 0x1E, 0x28, 0xC8, 0x10, 0x58
        .db 0xBC, 0x16, 0x3F, 0x3F, 0x16, 0xBC, 0x58, 0x00

byte_0_1BB0:    
        .db 0                           ; image form            
        .db 0                           ; delta x               
        .db 1                           ; delta y               
        .db 0x98                        ; y starting coordinate (swapped for 6809)
        .db 0xB8                        ; x coordinate (swapped for 6809)
        .dw alien_spr_CYA               ; Base image
        .db 0x10                        ; size of image         
        .db 0xFF                        ; target y coordinate   
        .db 0                           ; reached flag          
        .dw alien_spr_CYA               ; Base image

        .db    0, 0, 0, 0

; sqiggly shot descriptor
; gets copied to $2050 ($6050) overwriting value from init
byte_0_1BC0:
; *** DO WE NEED TO REVERSE BYTES HERE???
        .db 0x00, 0x10                  ; obj4Timer
        .db 0                           ; obj4TimerExtra  
        .dw game_obj_4                  ; obj4TimerHandler
        .db 0                           ; squShotStatus   
        .db 0                           ; squShotStepCnt  
        .db 0                           ; squShotTrack    
        .dw 0x0000                      ; squShotCFir     
        .db 7                           ; squShotBlowCnt  
        .dw squiggly_shot               ; squShotImage    
        .db 0x9B                        ; squShotXr (swapped for 6809)
        .db 0xC8                        ; squShotYr (swapped for 6809)      
        .db 3                           ; squShotSize     

; $1BD0
alien_spr_CYB:
; Alien sprite C pulling upside down Y. Note the difference between this and the first picture
; above. The Y is closer to the ship. This gives the effect of the Y kind of "sticking" in the
; animation.
        .db 0x00, 0x00, 0xC0, 0x20, 0x1E, 0x28, 0xD0, 0x98
        .db 0x5C, 0xB6, 0x5F, 0x5F, 0xB6, 0x5C, 0x98, 0x00

; $1BE0
; More RAM initialization copied by 18D9
        .db 0, 0, 0, 0, 0, 0
        .db 0, 0, 0, 1, 0, 0, 1, 0x74, 0x1F, 0, 0x80, 0, 0, 0

; hi score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x2F, 
        .dw vram+0x0b1c
; p1 score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x27, 
        .dw vram+0x031c
; p2 score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x39
        .dw vram+0x151c

; $1C00
alien_spr_a:    
        .db 0x00, 0x00, 0x9C, 0x9E, 0x5E, 0x76, 0x37, 0x5F
        .db 0x5F, 0x37, 0x76, 0x5E, 0x9E, 0x9C, 0x00, 0x00
        .db 0x00, 0x00, 0x00, 0x1E, 0xB8, 0x7D, 0x36, 0x3C
        .db 0x3C, 0x3C, 0x36, 0x7D, 0xB8, 0x1E, 0x00, 0x00
        .db 0x00, 0x00, 0x00, 0x00, 0x98, 0x5C, 0xB6, 0x5F
        .db 0x5F, 0xB6, 0x5C, 0x98, 0x00, 0x00, 0x00, 0x00
; $1C30        
alien_spr_b:        
        .db 0x00, 0x00, 0x1C, 0x5E, 0xFE, 0xB6, 0x37, 0x5F
        .db 0x5F, 0x37, 0xB6, 0xFE, 0x5E, 0x1C, 0x00, 0x00
        .db 0x00, 0x00, 0x00, 0x70, 0x18, 0x7D, 0xB6, 0xBC
        .db 0x3C, 0xBC, 0xB6, 0x7D, 0x18, 0x70, 0x00, 0x00
        .db 0x00, 0x00, 0x00, 0x00, 0x58, 0xBC, 0x16, 0x3F
        .db 0x3F, 0x16, 0xBC, 0x58, 0x00, 0x00, 0x00, 0x00
; $1C60        
player_sprite:           
        .db 0x00, 0x00, 0xF0, 0xF8, 0xF8, 0xF8, 0xF8, 0xFE
        .db 0xFF, 0xFE, 0xF8, 0xF8, 0xF8, 0xF8, 0xF0, 0x00
; $1C70        
plr_blow_up_sprites:    
        .db 0x00, 0x20, 0x80, 0xC8, 0xC0, 0xE0, 0xCD, 0xF0
        .db 0xF4, 0xC0, 0xF4, 0x92, 0x20, 0xC0, 0x00, 0x80
; $1C80
        .db 0x02, 0x10, 0xA0, 0xC5, 0x50, 0xC0, 0xDA, 0xF0
        .db 0xE4, 0xE4, 0xD0, 0xD2, 0x02, 0x21, 0x88, 0x12
; $1C90
player_shot_spr:        
        .db  0xF
; $1C91
shot_exploding:        
        .db 0x99, 0x3C, 0x7E, 0x3D, 0xBC, 0x3E, 0x7C, 0x99
; $1C99        
message_10_pts:
;       "=10 POINTS"
        .db 0x27, 0x1B, 0x1A, 0x26, 0xF, 0xE, 8, 0xD, 0x13, 0x12

; $1CA3
; "SCORE ADVANCE TABLE"
message_adv:
        .db 0x28 ; (
        .db 0x12, 2, 0xE, 0x11, 4, 0x26, 0, 3, 0x15, 0, 0xD, 2
        .db 4, 0x26, 0x13, 0, 1, 0xB, 4
        .db 0x28 ; (

; $1CD0
squiggly_shot:
        .db 0x22, 0x55, 0x08
        .db 0x11, 0x2A, 0x44
        .db 0x08, 0x55, 0x22
squiggly_shot_last:
        .db 0x44, 0x2A, 0x11

; $1CDC
a_shot_explo:
        .db 0x52, 0xA8, 0x7D, 0xFC, 0x7A, 0xA4

; $1CFA
message_play_UY:
        .db 0xF, 0xB, 0, 0x29           ; "PLAY" with inverted Y

; $1D00
; This table decides which column a shot will fall from. The column number is read from the
; table (1-11) and the pointer increases for the shot type. For instance, the "squiggly" shot
; will fall from columns in this order: 0B, 01, 06, 03. If you play the game you'll see that
; order.
;
; The "plunger" shot uses index 00-0F (inclusive)
; The "squiggly" shot uses index 06-14 (inclusive)
; The "rolling" shot targets the player
col_fire_table:
        .db 1, 7, 1, 1, 1, 4, 0xB, 1
        .db 6, 3, 1, 1, 0xB, 9, 2, 8
        .db 2, 0xB, 4, 7, 0xA

; $1D20
shield_image:
        .db 0xFF, 0xF0, 0xFF, 0xF8, 0xFF, 0xFC, 0xFF, 0xFE
        .db 0xFF, 0xFF, 0x3F, 0xFF, 0x1F, 0xFF, 0x0F, 0xFF
        .db 0x0F, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF
        .db 0x0F, 0xFF, 0x0F, 0xFF, 0x1F, 0xFF, 0x3F, 0xFF
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0xFF, 0xFC
        .db 0xFF, 0xF8, 0xFF, 0xF0

unk_0_1D64:
        .db 0, 0, 0, 0

; $1D68
sprite_saucer:
        .db 0x20, 0x30, 0x78, 0xEC, 0x7C, 0x3E, 0x2E, 0x7E
        .db 0x7E, 0x2E, 0x3E, 0x7C, 0xEC, 0x78, 0x30, 0x20
        .db 0, 0, 0, 0

; $1D7C
sprite_saucer_exp:
byte_0_1D7C:    
        .db 0, 0x22, 0, 0xA5, 0x40, 8, 0x98, 0x3D, 0xB6, 0x3C
        .db 0x36, 0x1D, 0x10, 0x48, 0x62, 0xB6, 0x1D, 0x98, 8
        .db 0x42, 0x90, 8, 0, 0

alien_scores:
;       Score table for hitting alien type
        .db 0x10                        ; Bottom 2 rows     
        .db 0x20                        ; Middle row
        .db 0x30                        ; Highest row

; $1DAB
message_play_Y:
;       "PLAY" with normal Y
        .db 0xF, 0xB, 0, 0x18           

; $1DAF        
message_invaders:
;       "SPACE  INVADERS"
        .db 0x12, 0xF, 0, 2, 4, 0x26, 0x26 
        .db 8, 0xD, 0x15, 0, 3, 4, 0x11, 0x12

; score table graphics info
word_0_1DBE:    
        .dw vram+0x080E
        .dw sprite_saucer               ; ptr ufo bitmap
        .dw vram+0x080C
        .dw alien_spr_a+0x20            ; ptr 30 pt invader bitmap
        .dw vram+0x080A
        .dw alien_spr_b+0x10            ; ptr 20 pt invader bitmap
        .dw vram+0x0808
        .dw alien_spr_a                 ; ptr 10 pt invader bitmap
        .db 0xFF

; score table text info
word_0_1DCF:    
        .dw vram+0x0A0E
        .dw message_myst                ; "=? MYSTERY"
        .dw vram+0x0A0C
        .dw message_30_pts              ; "=30 POINTS"
        .dw vram+0x0A0A
        .dw message_20_pts              ; "=20 POINTS"
        .dw vram+0x0A08
        .dw message_10_pts              ; "=10 POINTS"
        .db 0xFF

; $1DE0
message_myst:
; "=? MYSTERY"
        .db 0x27, 0x38, 0x26, 0xC, 0x18, 0x12, 0x13, 4, 0x11, 0x18

; $1DEA
message_30_pts:
; "=30 POINTS"
        .db 0x27, 0x1D, 0x1A, 0x26, 0xF, 0xE, 8, 0xD, 0x13, 0x12

; $1DF4
message_20_pts:
; "=20 POINTS"
        .db 0x27, 0x1C, 0x1A, 0x26, 0xF, 0xE, 8, 0xD, 0x13, 0x12

; Ran out of space here. The "=10" message is up at 1C99. That keeps
; the font table firmly at 1E00.
        .db 0, 0                        ; Padding to put font table at 1E00

loc_1E00:   
        .db 0x00, 0xF8, 0x24, 0x22, 0x24, 0xF8, 0x00, 0x00  ; "A"
        .db 0x00, 0xFE, 0x92, 0x92, 0x92, 0x6C, 0x00, 0x00  ; "B"
        .db 0x00, 0x7C, 0x82, 0x82, 0x82, 0x44, 0x00, 0x00  ; "C"
        .db 0x00, 0xFE, 0x82, 0x82, 0x82, 0x7C, 0x00, 0x00  ; "D"
        .db 0x00, 0xFE, 0x92, 0x92, 0x92, 0x82, 0x00, 0x00  ; "E"
        .db 0x00, 0xFE, 0x12, 0x12, 0x12, 0x02, 0x00, 0x00  ; "F"
        .db 0x00, 0x7C, 0x82, 0x82, 0xA2, 0xE2, 0x00, 0x00  ; "G"
        .db 0x00, 0xFE, 0x10, 0x10, 0x10, 0xFE, 0x00, 0x00  ; "H"
        .db 0x00, 0x00, 0x82, 0xFE, 0x82, 0x00, 0x00, 0x00  ; "I"
        .db 0x00, 0x40, 0x80, 0x80, 0x80, 0x7E, 0x00, 0x00  ; "J"
        .db 0x00, 0xFE, 0x10, 0x28, 0x44, 0x82, 0x00, 0x00  ; "K"
        .db 0x00, 0xFE, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00  ; "L"
        .db 0x00, 0xFE, 0x04, 0x18, 0x04, 0xFE, 0x00, 0x00  ; "M"
        .db 0x00, 0xFE, 0x08, 0x10, 0x20, 0xFE, 0x00, 0x00  ; "N"
        .db 0x00, 0x7C, 0x82, 0x82, 0x82, 0x7C, 0x00, 0x00  ; "O"
        .db 0x00, 0xFE, 0x12, 0x12, 0x12, 0x0C, 0x00, 0x00  ; "P"
        .db 0x00, 0x7C, 0x82, 0xA2, 0x42, 0xBC, 0x00, 0x00  ; "Q"
        .db 0x00, 0xFE, 0x12, 0x32, 0x52, 0x8C, 0x00, 0x00  ; "R"
        .db 0x00, 0x4C, 0x92, 0x92, 0x92, 0x64, 0x00, 0x00  ; "S"
        .db 0x00, 0x02, 0x02, 0xFE, 0x02, 0x02, 0x00, 0x00  ; "T"
        .db 0x00, 0x7E, 0x80, 0x80, 0x80, 0x7E, 0x00, 0x00  ; "U"
        .db 0x00, 0x3E, 0x40, 0x80, 0x40, 0x3E, 0x00, 0x00  ; "V"
        .db 0x00, 0xFE, 0x40, 0x30, 0x40, 0xFE, 0x00, 0x00  ; "W"
        .db 0x00, 0xC6, 0x28, 0x10, 0x28, 0xC6, 0x00, 0x00  ; "X"
        .db 0x00, 0x06, 0x08, 0xF0, 0x08, 0x06, 0x00, 0x00  ; "Y"
        .db 0x00, 0xC2, 0xA2, 0x92, 0x8A, 0x86, 0x00, 0x00  ; "Z"
        .db 0x00, 0x7C, 0xA2, 0x92, 0x8A, 0x7C, 0x00, 0x00  ; "0"
        .db 0x00, 0x00, 0x84, 0xFE, 0x80, 0x00, 0x00, 0x00  ; "1"
        .db 0x00, 0xC4, 0xA2, 0x92, 0x92, 0x8C, 0x00, 0x00  ; "2"
        .db 0x00, 0x42, 0x82, 0x92, 0x9A, 0x66, 0x00, 0x00  ; "3"
        .db 0x00, 0x30, 0x28, 0x24, 0xFE, 0x20, 0x00, 0x00  ; "4"
        .db 0x00, 0x4E, 0x8A, 0x8A, 0x8A, 0x72, 0x00, 0x00  ; "5"
        .db 0x00, 0x78, 0x94, 0x92, 0x92, 0x62, 0x00, 0x00  ; "6"
        .db 0x00, 0x02, 0xE2, 0x12, 0x0A, 0x06, 0x00, 0x00  ; "7"
        .db 0x00, 0x6C, 0x92, 0x92, 0x92, 0x6C, 0x00, 0x00  ; "8"
        .db 0x00, 0x8C, 0x92, 0x92, 0x52, 0x3C, 0x00, 0x00  ; "9"
        .db 0x00, 0x10, 0x28, 0x44, 0x82, 0x00, 0x00, 0x00  ; "<"
        .db 0x00, 0x00, 0x82, 0x44, 0x28, 0x10, 0x00, 0x00  ; ">"
        .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; " "
        .db 0x00, 0x28, 0x28, 0x28, 0x28, 0x28, 0x00, 0x00  ; "="
        .db 0x00, 0x44, 0x28, 0xFE, 0x28, 0x44, 0x00, 0x00  ; "*"
        .db 0x00, 0xC0, 0x20, 0x1E, 0x20, 0xC0, 0x00, 0x00  ; "Ý"

; $1F50        
message_p1_or_2:   
;       "<1 OR 2 PLAYERS>"
        .db 0x24 ; $
        .db 0x1B, 0x26, 0xE, 0x11, 0x26, 0x1C, 0x26, 0xF, 0xB
        .db 0, 0x18, 4, 0x11, 0x12
        .db 0x25 ; %
        .db 0x26 ; &
        .db 0x26 ; &

; $1F62        
message_1_coin:
;       "1 PLAYER  1 COIN"
        .db 0x28 ; (
        .db 0x1B, 0x26, 0xF, 0xB, 0, 0x18, 4, 0x11, 0x26, 0x26 
        .db 0x1B, 0x26, 2, 0xE, 8, 0xD, 0x26

; $1F74
demo_commands:
;       (1=Right, 2=Left)
        .db 1, 1, 0, 0, 1, 0, 2, 1, 0, 2, 1, 0         ; simulated controller reads
        
; $1F80
alien_spr_CA:        
        .db 0x06, 0x08, 0xF0, 0x08, 0x06, 0x0C, 0x18, 0x58  ; "Y"
        .db 0xBC, 0x16, 0x3F, 0x3F, 0x16, 0xBC, 0x58, 0x00  ; " "

; $1F90        
message_coin:  
;       "INSERT  COIN"           
        .db 8, 0xD, 0x12, 4, 0x11, 0x13, 0x26, 0x26, 2, 0xE, 8
        .db 0xD

; $1F9C
credit_table:     
        .dw vram+0x60D                  ; screen loc
        .dw message_p1_or_2             ; "<1 OR 2 PLAYERS>
        .dw vram+0x60A                  ; screen loc
        .dw message_1_coin              ; "*1 PLAYER 1  COIN"
        .dw vram+0x607                  ; screen loc
        .dw message_2_coins             ; "*2 PLAYERS 2 COINS"
        .db 0xFF

; $1FA9        
message_credit:
;       "CREDIT "
        .db 2, 0x11, 4, 3, 8, 0x13, 0x26

; $1FB0        
alien_spr_CB:        
        .db 0x00, 0x06, 0x08, 0xF0, 0x08, 0x06, 0x1C, 0x98  ; "Y"
        .db 0x5C, 0xB6, 0x5F, 0x5F, 0xB6, 0x5C, 0x98, 0x00  ; " "
        
; $1FC0        
        .db 0x00, 0x04, 0x02, 0xB2, 0x0A, 0x04, 0x00, 0x00  ; "?"
        .db 0

; $1FC9        
byte_0_1FC9:
; Splash screen animation structure 3
        .db 0                           ; image form
        .db 0                           ; delta x
        .db 0xFF                        ; delta y
        .db 0xFF                        ; y starting coordinate (swapped for 6809)
        .db 0xB8                        ; x coordinate (swapped or 6809)
        .dw alien_spr_CA
        .db 0x10                        ; size of image
        .db 0x97                        ; target y coordinate
        .db 0                           ; reached y flag
        .dw alien_spr_CA

; $1FD5                
byte_0_1FD5:
; Splash screen animation structure 4
        .db 0                           ; image form
        .db 0                           ; delta x
        .db 1                           ; delta y
        .db 0x22                        ; y starting coordinate (swapped for 6809)
        .db 0xD0                        ; x coordinate (swapped for 6809)
        .dw alien_spr_a+0x20
        .db 0x10                        ; size of image
        .db 0x94                        ; target y coordinate
        .db 0                           ; reached flag
        .dw alien_spr_a+0x20

; $1FE1
message_2_coins:
;       "*2 PLAYERS 2 COINS"
        .db 0x28, 0x1C, 0x26, 0xF, 0xB, 0, 0x18, 4, 0x11, 0x12 
        .db 0x26, 0x1C, 0x26, 2, 0xE, 8, 0xD, 0x12

; $1FF3        
message_push:
;       "PUSH " (with space on the end)            
        .db 0xF, 0x14, 0x12, 7, 0x26

; $1FF8
        .db 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00  ; "-"

main_fisr:
; temp hack - should do LFSR or something
; and also tune frequency
        tst     FIRQENR                 ; ACK FIRQ
        inc     *z80_r
        rti

vram_dump:
        
				.end		start_coco
