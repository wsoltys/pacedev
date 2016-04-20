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
player_yr:                      .ds   1                                
player_xr:                      .ds   1                                
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
obj1_coor_yr:                   .ds   1                                
obj1_coor_xr:                   .ds   1                                
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
rol_shot_yr:                    .ds   1                                
rol_shot_xr:                    .ds   1                                
rol_shot_size:                  .ds   1                                
; $2040
; '''GameObject3 (Alien plunger-shot)'''
obj3_timer_msb:                 .ds   1     ; switched for 6809        
obj3_timer_lsb:                 .ds   1     ; switched for 6809        
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
plu_shot_yr:                    .ds   1                                
plu_shot_xr:                    .ds   1                                
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
squ_shot_yr:                    .ds   1                                
squ_shot_xr:                    .ds   1                                
squ_shot_size:                  .ds   1                                
; $2060
end_of_tasks:                   .ds   1
collision:                      .ds   1
exp_alien_msb:                  .ds   1     ; switched for 6809
exp_alien_lsb:                  .ds   1     ; switched for 6809
exp_alien_yr:                   .ds   1
exp_alien_xr:                   .ds   1
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
alien_shot_yr:                  .ds   1
alien_shot_xr:                  .ds   1
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
splash_yr:                      .ds   1
splash_xr:                      .ds   1
splash_image_msb:               .ds   1     ; switched for 6809
splash_image_lsb:               .ds   1     ; switched for 6809
splash_image_size:              .ds   1
splash_target_y:                .ds   1
splash_reached:                 .ds   1
splash_image_rest_msb:          .ds   1     ; switched for 6809
splash_image_rest_lsb:          .ds   1     ; switched for 6809
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
p2_ref_alien_y:                 .ds   1
p2_ref_alien_x:                 .ds   1
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
        ldx     #vbord_isr
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

vbord_isr:
        tst     IRQENR                  ; ACK IRQ
        dec     isr_delay
        rti

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
        lda     #2                      ; Start simple linear ...
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

; $0AB1
one_sec_delay:
        lda     #0x40
        bra     wait_on_delay

; $0AB1
two_sec_delay:
        lda     #0x80
        bra     wait_on_delay

; $0ACF
; Message to center of screen.
; Only used in one place for "SPACE  INVADERS"
sub_0ACF:
        ldx     #vram+0x714             ; Near center of screen
        ldb     #15                     ; 15 bytes in message
        bra     print_message_del

; $0AD7
; Wait on ISR counter to reach 0
wait_on_delay:
        sta     isr_delay
1$:     tst     isr_delay
        bne     1$
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
        lda     #1                      ; ISR splash-task ...
        sta     isr_splash_task         ; ... playing demo
        jsr     draw_bottom_line

2$:     jsr     plr_fire_or_demo        ; In demo ... process demo movement and always fire
        jsr     loc_0BF1                ; Check player shot and aliens bumping edges of screen and hidden message
; watchdog
        jsr     sub_0A59                ; Has demo player been hit?
        beq     2$                      ; No ... continue game
        clr     plyr_shot_status        ; Remove player shot from activity
3$:     jsr     sub_0A59                ; Wait for demo player ...
        bne     3$                      ; ... to stop exploding

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

; $1474
; Convert pixel number in HL to screen coordinate and shift amount.
; HL gets screen coordinate.
; Hardware shift-register gets amount.
cnvt_pix_number:
        lda     *z80_l
        anda    #7
;       out     (shftamt),a
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
        stx     exp_alien_yr            ; Put it in the exploding-alien descriptor
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
1$:     ldx     exp_alien_yr            ; Pixel pointer for exploding alien
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
        lda     #4
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
sub_193C:
        ldb     #7                      ; 7 bytes in message
        ldx     #vram+0x1101
        ldy     #message_credit
        jmp     print_message

; $1947
draw_num_credits:
        lda     num_coins
        ldx     #0x1801
        jmp     draw_hex_byte
                
; $1950
print_hi_score:
        ldx     #hi_scor_l              ; Hi Score descriptor
        bra     draw_score
                
; $1956
; Print scores (with header) and credits (with label)
draw_status:
        bsr     clear_screen
        bsr     draw_score_head
        bsr     sub_1925                ; print player 1 score
        bsr     sub_192B                ; print player 2 score
        bsr     print_hi_score
        bsr     sub_193C                ; print credit table
        bra     draw_num_credits

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
        rorb                            ; D/=8
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
        bsr     draw_num_ships
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
                .db 0,0,0,0x82,6,0,0,1
                .db 6,0x1D,4,0xD0,0x1C,0,0,3
; $1B60->$2060
                .db 0xFF,0,0xC0,0x1C,0,0,0x10
                .db >byte_0_2100
                .db 1,0,0x30,0,0x12,0,0,0
                
; These don't need to be copied over to RAM (see 1BA0 below).
message_p1: 
; "PLAY PLAYER<1>"
        .db 0xF,0xB,0,0x18,0x26,0xF,0xB,0
        .db 0x18,4,0x11,0x24,0x1B,0x25,0xFC,0
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
        .db 0,3,4,0x78,0x14,0x13,8,0x1A
        .db 0x3D,0x68,0xFC,0xFC,0x68,0x3D,0x1A,0
byte_0_1BB0:    
        .db 0, 0, 1, 0xB8, 0x98, 0xA0, 0x1B, 0x10, 0xFF, 0, 0xA0 ; inverted-y animation pt.2 data
        .db 0x1B
        .db    0
        .db    0
        .db    0
        .db    0
byte_0_1BC0:    
        .db 0, 0x10, 0, 0xE, 5, 0, 0, 0, 0, 0, 7, 0xD0, 0x1C, 0xC8 ; initialised only at startup
        .db 0x9B, 3
; $1BD0
alien_spr_CYB:
        .db 0, 0, 3, 4, 0x78, 0x14, 0xB, 0x19, 0x3A, 0x6D
        .db 0xFA, 0xFA, 0x6D, 0x3A, 0x19, 0, 0, 0, 0, 0, 0, 0
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

; $1CFA
message_play_UY:
        .db 0xF, 0xB, 0, 0x29           ; "PLAY" with inverted Y

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
        .db    0

; $1FC9        
byte_0_1FC9:
; Splash screen animation structure 3
        .db 0                           ; image form
        .db 0                           ; delta x
        .db 0xFF                        ; delta y
        .db 0xB8                        ; x coordinate
        .db 0xFF                        ; y starting coordinate
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
        .db 0xD0                        ; x coordinate
        .db 0x22                        ; y starting coordinate
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
