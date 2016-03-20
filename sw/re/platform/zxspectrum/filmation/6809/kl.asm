;
;	KNIGHT LORE
; - ported from the original ZX Spectrum version
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

; *** BUILD OPTIONS
;.define BUILD_OPT_ALWAYS_RENDER_ALL
;.define BUILD_OPT_NO_Z_ORDER
;.define BUILD_OPT_NO_TRANSFORM
.define BUILD_OPT_ALMOST_INVINCIBLE
; *** end of BUILD OPTIONS

        .org    code_base-#0x800
        
        .bndry  0x100
dp_base:            .ds     256        
z80_b               .equ    0x00
z80_c               .equ    0x01
z80_d               .equ    0x02
z80_e               .equ    0x03
z80_h               .equ    0x04
z80_l               .equ    0x05
width               .equ    0x08
height              .equ    0x09
lines               .equ    0x0a
bytes               .equ    0x0b
offset              .equ    0x0c
screen              .equ    0x0d
y_lim               .equ    0x0e
x_lim               .equ    0x0f
tmp_word            .equ    0x10
depth               .equ    0x12

; *** KNIGHT-LORE stuff here
MAX_OBJS            .equ    40
MAX_DRAW            .equ    48
CAULDRON_SCREEN     .equ    136
; standard is 5     
NO_LIVES            .equ    5
; *** the standard 4 locations
START_LOC           .equ    47
;START_LOC           .equ    68
;START_LOC           .equ    179         ; chest to the west
;START_LOC           .equ    143
; *** extra one for debugging
;START_LOC           .equ    0x2e

; inputs            
INP_LEFT            .equ    1<<0
INP_RIGHT           .equ    1<<1
INP_FORWARD         .equ    1<<2
INP_JUMP            .equ    1<<3
INP_PICKUP_DROP     .equ    1<<4
; flags7            
FLAG_VFLIP          .equ    1<<7
FLAG_HFLIP          .equ    1<<6
FLAG_WIPE           .equ    1<<5
FLAG_DRAW           .equ    1<<4
FLAG_AUTO_ADJ       .equ    1<<3        ; for arches
FLAG_MOVEABLE       .equ    1<<2        ; (sic)
FLAG_IGNORE_3D      .equ    1<<1        ; ignore for 3D calcs
FLAG_NEAR_ARCH      .equ    1<<0
; flags12
MASK_ENTERING_SCRN  .equ    0xF0
FLAG_JUMPING        .equ    1<<3
FLAG_Z_OOB          .equ    1<<2
FLAG_Y_OOB          .equ    1<<1
FLAG_X_OOB          .equ    1<<0
; flags13           
FLAG_FATAL_HIT_YOU  .equ    1<<7        ; deadly if it hits you
FLAG_DEAD           .equ    1<<6        ; player
FLAG_FATAL_YOU_HIT  .equ    1<<5        ; deadly if you hit it
FLAG_TRIGGERED      .equ    1<<3        ; dropping, collapsing block
FLAG_UP             .equ    1<<2        ; bouncing ball
FLAG_DROPPING       .equ    1<<2        ; spiked ball
FLAG_NORTH          .equ    1<<1        ; NS fire
FLAG_EAST           .equ    1<<0        ; EW fire, EW guard
FLAG_JUST_DROPPED   .equ    1<<0        ; special objects
MASK_DIR            .equ    0x03        ; NSEW guard & wizard
MASK_LOOK_CNT       .equ    0x0F        ; player (top, look around cnt)
MASK_TURN_DELAY     .equ    0x07        ; player (bottom)

seed_1:                         .ds 1
                                .ds 1
seed_2:                         .ds 2
; bit   3 : directional
; bit 2-1 : 00=keybd, 01=kempston, 10=cursor, 11=i/f-ii
user_input_method:              .ds 1
seed_3:                         .ds 1
tmp_input_method:               .ds 1
                                .ds 1
;
; variables from here are zeroed each game
;
objs_wiped_cnt:                 .ds 1
tmp_SP:                         .ds 2
room_size_X:                    .ds 1
room_size_Y:                    .ds 1
curr_room_attrib:               .ds 1
room_size_Z:                    .ds 1
portcullis_moving:              .ds 1
portcullis_move_cnt:            .ds 1
transform_flag_graphic:         .ds 1
not_1st_screen:                 .ds 1
pickup_drop_pressed:            .ds 1
objects_carried_changed:        .ds 1
; b5=???
; b4=pickup/drop
; b3=jump
; b2=forward
; b1=right
; b0=left
user_input:                     .ds 1
tmp_attrib:                     .ds 1
render_status_info:             .ds 1
suppress_border:                .ds 1
days:                           .ds 1
lives:                          .ds 1
objects_put_in_cauldron:        .ds 1
fire_seed:                      .ds 1
ball_bounce_height:             .ds 1
rendered_objs_cnt:              .ds 1
is_spike_ball_dropping:         .ds 1
disable_spike_ball_drop:        .ds 1
tmp_dZ:                         .ds 1
tmp_bouncing_ball_dZ:           .ds 1
all_objs_in_cauldron:           .ds 1
obj_dropping_into_cauldron:     .ds 1
rising_blocks_z:                .ds 1
num_scrns_visited:              .ds 1
gfxbase_8x8:                    .ds 2
percent_msw:                    .ds 1
percent_lsw:                    .ds 1
tmp_objects_to_draw:            .ds 2
render_obj_1:                   .ds 2
render_obj_2:                   .ds 2
audio_played:                   .ds 1
directional:                    .ds 1
cant_drop:                      .ds 1
                                .ds 4
inventory:                      .ds 4
objects_carried:                .ds 7
unk_5BE3:                       .ds 1
unk_5BE4:                       .ds 1
                                .ds 2
end_of_objects_carried:         .ds 1
;
; table of bits (flags) denoting room has been visited
; - used only in ratings calculations
;
scrn_visited:                   .ds 32
;
; table of objects (40 max)
; - 00,01 player sprites (00=bottom, 01=top)
; - 02,03 special object sprites
; - 04-39 background, then foreground
;
; +0 graphic_no.
; +1 x (center)
; +2 y (center)
; +3 z (bottom)
; +4 width (X radius)
; +5 depth (Y radius)
; +6 height
; +7 flags
;    - 7=vflip sprite
;    - 6=hflip sprite
;    - 5=wipe
;    - 4=draw
;    - 3=auto-adjust near arches (player only)
;    - 2=moveable
;    - 1=ignore in 3D calculations
;    - 0=is near arch (player only)
; +8 screen
; +9 dX
; +10 dY
; +11 dZ
; +12 counter and flags
;     - 7-4=counter when entering screen
;     - 3=jumping
;     - 2=Z out-of-bounds
;     - 1=Y out-of-bounds
;     - 0=X out-of-bounds
; +13 per-object info/flags
;     - direction and counters for looking, turning
;     - 7=deadly if object hits player
;     - 6=dead
;     - 5=deadly if player hits object
;     - 4=(not used)
;     - 3=triggered (dropping, collapsing blocks)
;     - 2=up (bouncing ball), dropping (spiked ball)
;     - 1=north (NS fire)
;     - 0=east (WE fire, EW guard), just dropped (spec objs)
; +14 d_x_adj
; +15 d_y_adj
; +16-17 ptr object table entry or tmp player graphic_no
; +18 pixel X adjustment
; +19 pixel Y adjustment
; +20-23 unused
; +24 sprite data width (bytes)
; +25 sprite data height (lines)
; +26 pixel X
; +27 pixel Y
; +28 old sprite data width (bytes)
; +29 old sprite data height (lines)
; +30 old pixel X
; +31 old pixel Y
;
graphic_objs_tbl:               .ds 32
                                .ds 32
special_objs_here:              .ds 32
byte_5C68:                      .ds 32
other_objs_here:                .ds 32
                                .ds (MAX_OBJS-4)*32
; end of data
eod                   .equ    .
				
; end of 'SCRATCH'

font                  .equ    data_base+0x0000
room_size_tbl         .equ    data_base+0x0140
location_tbl          .equ    data_base+0x0149
eolt                  .equ    data_base+0x0ac9
block_type_tbl        .equ    data_base+0x0ba0
background_type_tbl   .equ    data_base+0x0eba
special_objs_tbl      .equ    data_base+0x0eea
eosot                 .equ    data_base+0x100a
sprite_tbl            .equ    data_base+0x4ce0
reverse_tbl           .equ    0xcf00
shift_tbl             .equ    0xd000

				              .org		code_base

; Spectrum Palette for Coco3
; - spectrum format : B=1, R=2, G=4
; -     coco format : RGBRGB

ATTR_BLACK      .equ  0
ATTR_BLUE       .equ  1
ATTR_RED        .equ  2
ATTR_MAGENTA    .equ  3
ATTR_GREEN      .equ  4
ATTR_CYAN       .equ  5
ATTR_YELLOW     .equ  6
ATTR_WHITE      .equ  7

speccy_pal:
;       black, blue, red, magenta, green, cyan, yellow, grey/white
.ifdef GFX_RGB
    .db 0x00<<0, 0x01<<0, 0x04<<0, 0x05<<0, 0x02<<0, 0x03<<0, 0x06<<0, 0x07<<0
    .db 0x00*9, 0x01*9, 0x04*9, 0x05*9, 0x02*9, 0x03*9, 0x06*9, 0x07*9
.else
    .db 0, 12, 7, 9, 3, 29, 4, 32
    .db 0, 28, 23, 41, 17, 61, 51, 63
.endif

osd_set_palette:
        anda    #7
        ldu     #speccy_pal+8           ; bright
        lda     a,u
        sta     PALETTE+1
        rts
				
start_coco:
				orcc		#0x50										; disable interrupts
				lds			#stack

.ifdef PLATFORM_COCO3

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
.ifndef CARTRIDGE				
				lda			#0x60										; enable GIME MMU,IRQ
				sta			INIT0     							
.endif				
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#0x00										; no FIRQ enabled
				sta			FIRQENR   							
				lda			#0x80										; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	  .ifdef GFX_1BPP				
				lda			#0x08										; 192 scanlines, 32 bytes/row, 2 colours (256x192)
	  .else				
				lda			#0x1A										; 192 scanlines, 128 bytes/row, 4 colours (256x192)
	  .endif				
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
.if 0				
				lda			#(VIDEOPAGE<<2)         ; screen at page $30
				sta			VOFFMSB
				lda			#0x00
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
.endif				
				ldx			#PALETTE
				ldy     #speccy_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)
        sta     RAMMODE
        
  ; configure MMU
        lda     #DATA_PG1
        ldx     #(MMUTSK1+4)            ; $8000-
        ldb     #3
  mmumap: 
        sta     ,x+
        inca
        decb
        bne     mmumap                  ; map pages $34-$36

  ; configure timer
  ; free-run, max range, used for RND atm
        lda     #<4095
        sta     TMRLSB
        lda     #>4095
        sta     TMRMSB

  .ifdef HAS_SOUND				

				lda			0xff23
				ora			#(1<<5)|(1<<4)					; set CB2 as output
				ora			#(1<<3)									; enable sound
				sta			0xff23

    .ifdef USE_1BIT_SOUND				
				; bit2 sets control/data register
				lda     0xff23                  ; CRB
				anda    #~(1<<2)                ; control register
				sta     0xff23                  ; CRB
				lda     0xff22                  ; DDRB
				ora     #(1<<1)                 ; PB1 output
				sta     0xff22                  ; DDRB
        ; setup for data register				
				lda     0xff23                  ; CRB
				ora     #(1<<2)                 ; data register
				sta     0xff23                  ; CRB
    .endif  ; USE_1BIT_SOUND

    .ifdef USE_DAC_SOUND
				; bit2 sets control/data register
				lda     0xff21                  ; CRA
				anda    #~(1<<2)                ; control register
				sta     0xff21                  ; CRA
				lda     0xff20                  ; DDRA
				ora     #0xfc                   ; PA2-7 outputs
				sta     0xff20                  ; DDRA
        ; setup for data register				
				lda     0xff21                  ; CRA
				ora     #(1<<2)                 ; data register
				sta     0xff21                  ; CRA
    .endif  ; USE_DAC_SOUND

  .endif  ; HAS_SOUND
												
.endif	; PLATFORM_COCO3
			
				lda			#>dp_base
				tfr			a,dp

start:
        ldx     #seed_1
        ldy     #eod-#seed_1
        lda     0x5c78                  ; random memory location
        pshs    a
        jsr     clr_mem
        puls    a
        sta     seed_1
        bra     main
        
start_menu:        
        ldx     #objs_wiped_cnt
        ldy     #eod-#objs_wiped_cnt
        jsr     clr_mem
        
main:
        jsr     build_lookup_tbls
        clra
        sta     not_1st_screen
        sta     flags12_1
        lda     #NO_LIVES
        sta     lives
        ldu     #seed_1
        lda     seed_2
        adda    ,u
        sta     seed_1
        jsr     clear_scrn
        jsr     do_menu_selection
        jsr     play_audio
        jsr     shuffle_objects_required
        jsr     init_start_location
        jsr     init_sun
        jsr     init_special_objects
        
player_dies:
        jsr     lose_life
        
game_loop:                
        jsr     build_screen_objects

onscreen_loop:
        lda     seed_2
        sta     fire_seed
        ldx     #graphic_objs_tbl

update_sprite_loop:
        lds     #stack
        inc     fire_seed
        ldu     #ret_from_tbl_jp
        pshs    u
        jsr     save_2d_info

jump_to_upd_object:
        ldb     0,x                     ; graphic_no
        ldu     #upd_sprite_jmp_tbl

; B=entry index, U=table
jump_to_tbl_entry:
        clra
        aslb
        rola                            ; word offset
        jmp     [d,u]                   ; go

ret_from_tbl_jp:
; Z80   ld      a,r
        lda     TMRLSB                  ; temp hack
        adda    seed_3
        sta     seed_3
        leax    32,x                    ; next object
        cmpx    #eod                    ; done?
        bhs     loc_B000
        bra     update_sprite_loop
        
loc_B000:
; the original Z80 code does a 16-bit increment:
;       ld      hl, (seed_2)
;       inc     hl
;       ld      (seed_2),hl
; but the high-order byte is not accessed anywhere else
; so to get the same behaviour on the 6809, we (need to)
; do an 8-bit increment at this address
        inc     seed_2
        lda     seed_3
        adda    ,u
        sta     seed_3
        tfr     u,d
        adda    seed_3
        sta     seed_3
        addb    seed_3
        stb     seed_3
        lda     #1
        sta     not_1st_screen
        jsr     handle_pause
        jsr     init_cauldron_bubbles
        jsr     list_objects_to_draw
        jsr     render_dynamic_objects
        tst     rising_blocks_z
        beq     1$
        jsr     audio_B454
1$:     lda     rendered_objs_cnt
        nega
        adda    #6
        bmi     no_delay
        beq     no_delay
        tfr     a,b

game_delay:
        ldx     #0x0500
2$:
        leax    -1,x
        bne     2$
        decb
        bne     game_delay

no_delay:
        tst     render_status_info
        beq     1$
        clr     render_status_info
        jsr     fill_attr
        jsr     display_objects
        jsr     colour_panel
        jsr     colour_sun_moon
        jsr     display_panel
        ldx     #sun_moon_scratchpad
        jsr     display_sun_moon_frame
        jsr     display_day
        jsr     print_days
        jsr     print_lives_gfx
        jsr     print_lives
;
; added for Coco3 port
        lda     curr_room_attrib
        jsr     osd_set_palette
;
        jsr     update_screen
        jsr     reset_objs_wipe_flag

1$:     clr     rising_blocks_z
        ldx     #graphic_objs_tbl
        lda     0,x                     ; graphic_no (bottom)
        ora     0x20,x                  ; graphic_no (top)
        lbeq    player_dies
        jmp     onscreen_loop
        
reset_objs_wipe_flag:
        ldb     #MAX_OBJS
        ldu     #graphic_objs_tbl+7
1$:     lda     ,u
        anda    #~FLAG_WIPE
        sta     ,u
        leau    32,u
        decb
        bne     1$
        rts

upd_sprite_jmp_tbl:
        .dw no_update
        .dw no_update                   ; (unused)
        .dw upd_2_4                     ; stone arch (near side)
        .dw upd_3_5                     ; stone arch (far side)
        .dw upd_2_4                     ; tree arch (near side)
        .dw upd_3_5                     ; tree arch (far side)
        .dw upd_6_7                     ; rock
        .dw upd_6_7                     ; block
        .dw upd_8                       ; portcullis (stationary)
        .dw upd_9                       ; portcullis (moving)
        .dw upd_10                      ; bricks
        .dw upd_11                      ; more bricks
        .dw upd_12_to_15                ; even more bricks
        .dw upd_12_to_15                ;   "
        .dw upd_12_to_15                ;   "
        .dw upd_12_to_15                ;   "
        .dw upd_16_to_21_24_to_29       ; human legs
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_22                      ; gargoyle
        .dw upd_23                      ; spikes
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_16_to_21_24_to_29
        .dw upd_30_31_158_159           ; guard (moving NSEW) (top half)
        .dw upd_30_31_158_159           ;   "
        .dw upd_32_to_47                ; player (top half)
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_32_to_47
        .dw upd_48_to_53_56_to_61       ;   wulf legs
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_54                      ; block (moving EW)
        .dw upd_55                      ; block (moving NS)
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_48_to_53_56_to_61
        .dw upd_62                      ; another block
        .dw upd_63                      ; spiked ball
        .dw upd_64_to_79                ; player (wulf top half)
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_64_to_79
        .dw upd_80_to_83                ; ghost
        .dw upd_80_to_83                ;   "
        .dw upd_80_to_83                ;   "
        .dw upd_80_to_83                ;   "
        .dw upd_84                      ; table
        .dw upd_85                      ; chest
        .dw upd_86_87                   ; fire (EW)
        .dw upd_86_87                   ; fire (EW)
        .dw upd_88_to_90                ; sun
        .dw upd_88_to_90                ; moon
        .dw upd_88_to_90                ; frame (left)
        .dw upd_91                      ; block (dropping)
        .dw upd_92_to_95                ; human/wulf transform
        .dw upd_92_to_95
        .dw upd_92_to_95
        .dw upd_92_to_95
        .dw upd_96_to_102               ; diamond
        .dw upd_96_to_102               ; poison
        .dw upd_96_to_102               ; boot
        .dw upd_96_to_102               ; chalice
        .dw upd_96_to_102               ; cup
        .dw upd_96_to_102               ; bottle
        .dw upd_96_to_102               ; crystal ball
        .dw upd_103                     ; extra life
        .dw upd_104_to_110              ; special object (diamond)
        .dw upd_104_to_110              ;   " (poison)
        .dw upd_104_to_110              ;   " (boot)
        .dw upd_104_to_110              ;   " (chalice)
        .dw upd_104_to_110              ;   " (cup)
        .dw upd_104_to_110              ;   " (bottle)
        .dw upd_104_to_110              ;   " (crytsal ball)
        .dw upd_111                     ; sparkles
        .dw upd_112_to_118_184          ; death sparkles
        .dw upd_112_to_118_184          ;   "
        .dw upd_112_to_118_184          ;   "
        .dw upd_112_to_118_184          ;   "
        .dw upd_112_to_118_184          ;   "
        .dw upd_112_to_118_184          ;   "
        .dw upd_112_to_118_184          ;   "
        .dw upd_119                     ; last death sparkle
        .dw upd_120_to_126              ; player appears sparkles
        .dw upd_120_to_126              ;   "
        .dw upd_120_to_126              ;   "
        .dw upd_120_to_126              ;   "
        .dw upd_120_to_126              ;   "
        .dw upd_120_to_126              ;   "
        .dw upd_120_to_126              ;   "
        .dw upd_127                     ; last player appears sparkle
        .dw upd_128_to_130              ; tree wall
        .dw upd_128_to_130              ;   "
        .dw upd_128_to_130              ;   "
        .dw upd_131_to_133              ; sparkles in the cauldron room at end of game
        .dw upd_131_to_133              ;   "
        .dw upd_131_to_133              ;   "
        .dw no_update
        .dw no_update
        .dw no_update
        .dw no_update
        .dw no_update
        .dw no_update
        .dw no_update
        .dw upd_141                     ; cauldron (bottom)
        .dw upd_142                     ; cauldron (top)
        .dw upd_143                     ; block (collapsing)
        .dw upd_144_to_149_152_to_157   ; guard & wizard (bottom half)
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_150_151                 ; guard (EW) (top half)
        .dw upd_150_151                 ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_144_to_149_152_to_157   ;   "
        .dw upd_30_31_158_159           ; wizard (top half)
        .dw upd_30_31_158_159           ;   "
        .dw upd_160_to_163              ; cauldron bubbles
        .dw upd_160_to_163              ;   "
        .dw upd_160_to_163              ;   "
        .dw upd_160_to_163              ;   "
        .dw upd_164_to_167              ; repel spell
        .dw upd_164_to_167              ;   "
        .dw upd_164_to_167              ;   "
        .dw upd_164_to_167              ;   "
        .dw upd_168_to_175              ; diamond
        .dw upd_168_to_175              ; poison
        .dw upd_168_to_175              ; boot
        .dw upd_168_to_175              ; chalice
        .dw upd_168_to_175              ; cup
        .dw upd_168_to_175              ; bottle
        .dw upd_168_to_175              ; crystal ball
        .dw upd_168_to_175              ; extra life
        .dw upd_176_177                 ; fire (stationary) (not used)
        .dw upd_176_177                 ; fire (stationary) (not used)
        .dw upd_178_179                 ; ball up/down
        .dw upd_178_179                 ; ball up/down
        .dw upd_180_181                 ; fire (NS)
        .dw upd_180_181                 ; fire (NS)
        .dw upd_182_183                 ; ball (bouncing around)
        .dw upd_182_183                 ;   "
        .dw upd_112_to_118_184          ; death sparkles
        .dw upd_185_187                 ; last obj in cauldron sparkle
        .dw no_update
        .dw upd_185_187                 ; last obj in cauldron sparkle

start_game_tune:
game_over_tune:
game_complete_tune:
menu_tune:

play_audio_wait_key:

play_audio_untl_keypress:
        rts

play_audio:
        bra     end_audio
        
end_audio:
        rts

audio_B3E9:
        rts

audio_B403:
        rts

audio_B419:
        rts

audio_B441:
        rts

audio_B451:
        rts

audio_B454:
        rts

audio_B472:
        rts
        
audio_B4BB:
        rts

audio_B4C1:
        rts

do_any_objs_intersect:
; may need to preserve other registers
        pshs    y
        ldy     #graphic_objs_tbl
        ldb     #MAX_OBJS
        clr     *z80_c
        clr     *z80_l
        clr     *z80_h
        lda     7,x                     ; flags7
        ora     #FLAG_IGNORE_3D
        sta     7,x
1$:     bsr     is_object_not_ignored
        beq     3$
        jsr     do_objs_intersect_on_x
        bcc     3$
        jsr     do_objs_intersect_on_y
        bcc     3$
        jsr     do_objs_intersect_on_z
        bcc     3$
2$:     puls    y
        lda     7,x                     ; flags7
        anda    #~FLAG_IGNORE_3D
        sta     7,x
        rts
3$:     leay    32,y
        decb
        bne     1$
        andcc   #0xfe                   ; clear carry
        bra     2$

is_object_not_ignored:
        tst     0,y                     ; graphic no
        beq     9$
        lda     7,y                     ; flags7
        coma
        anda    #FLAG_IGNORE_3D
9$:     rts

shuffle_objects_required:
        lda     seed_1
        anda    #3
        ora     #4
        sta     *z80_c                  ; rnd(4-7)
1$:     ldb     #13                     ; 13 swaps
        ldy     #objects_required
        lda     0,y
        sta     *z80_e
2$:     lda     1,y
        sta     ,y+
        decb
        bne     2$
        lda     *z80_e
        sta     0,y
        dec     *z80_c
        bne     1$
        rts

; sparkles from the blocks in the cauldron room
; at the end of the game
upd_131_to_133:
        rts

dec_dZ_wipe_and_draw:
        jsr     dec_dZ_and_update_XYZ
        jmp     set_wipe_and_draw_flags

; A=column (active low)
; returns A=row data (active high)
read_port:
				ldx			#PIA0
				sta			2,x											; column strobe
				lda			,x											; active low
				coma                            ; active high
        rts
        
; ball (bouncing around)
; - bounces towards wulf
; - bounces away from sabreman
upd_182_183:
        rts

; block (dropping)
upd_91:
        jsr     upd_6_7
        lda     13,x                    ; flags13
        bita    #FLAG_TRIGGERED
        bne     1$
        rts
1$:     anda    #~FLAG_TRIGGERED
        sta     13,x                    ; flags13
        clr     11,x                    ; dZ=0
        jsr     dec_dZ_and_update_XYZ
        lda     12,x                    ; flags12
        bita    #FLAG_Z_OOB
        bne     1$
        jsr     audio_B451
        jmp     set_wipe_and_draw_flags

; collapsing block
upd_143:
        jsr     upd_6_7
        lda     13,x                    ; flags13
        bita    #FLAG_TRIGGERED
        bne     1$
        rts
1$:     lda     #184                    ; sparkles
        sta     0,x                     ; graphic_no
        jsr     upd_112_to_118_184

; block (moving NS)
upd_55:
        rts

; block (moving EW)
upd_54:
        rts

; guard and wizard (bottom half)
upd_144_to_149_152_to_157:
        rts

; guard (EW)
upd_150_151:
        rts

set_guard_wizard_sprite:
        rts

; gargoyle
upd_22:
        bsr     set_both_deadly_flags
        jmp     adj_m7_m12
        rts

; spiked ball
upd_63:
        rts

spiked_ball_drop:
draw_spiked_ball:
        jmp     set_wipe_and_draw_flags

; spikes
upd_23:
        bsr     set_both_deadly_flags
        jmp     upd_6_7

; fire (moving EW)
upd_86_87:
        rts

; fire (moving NS)
upd_180_181:
        jmp     set_wipe_and_draw_flags

; fire (stationary) (not used)
upd_176_177:

set_deadly_wipe_and_draw_flags:
        bsr     set_both_deadly_flags
        jmp     set_wipe_and_draw_flags

set_both_deadly_flags:
.ifndef BUILD_OPT_ALMOST_INVINCIBLE
        lda     13,x                    ; flags13
        ora     #FLAG_FATAL_HIT_YOU|FLAG_FATAL_YOU_HIT
        sta     13,x                    ; flags13
.endif        
        rts

; ball up/down
upd_178_179:
loc_B892:
        bra     set_deadly_wipe_and_draw_flags                                                                                        
ball_up:        
        bra     loc_B892

init_cauldron_bubbles:
        jmp     adj_m4_m12

; even more sparkles (showing next object required)
upd_160_to_163:
        jmp     set_wipe_and_draw_flags

; special objs when 1st being put into cauldron
upd_168_to_175:
        rts

; repel spell
upd_164_to_167:
        rts

upd_111:
        lda     #1                      ; invalid
        sta     0,x                     ; graphic_no
        jmp     audio_B467_wipe_and_draw

move_towards_plyr:

toggle_next_prev_sprite:        

next_graphic_no_mod_4:

save_graphic_no:

; cauldron (bottom)
upd_141:
        jmp     upd_88_to_90

; cauldron (top)
upd_142: 
        jmp     set_pixel_adj

; guard and wizard (top half)
upd_30_31_158_159:
        bra     set_deadly_wipe_and_draw_flags

move_guard_wizard_NSEW:
        jmp     jump_to_tbl_entry

guard_NSEW_tbl: 

guard_W:

next_guard_dir:

guard_N:
        bra     next_guard_dir

guard_E:
        bra     next_guard_dir

guard_S:
        bra     next_guard_dir

game_over:
        tst     all_objs_in_cauldron
        bne     game_complete_msg
        jsr     clear_scrn_buffer
        jsr     clear_scrn
        ldy     #gameover_xy
        ldx     #gameover_text
        ldb     #6
        jsr     display_text_list
        ldy     #vidbuf+0x0fef
        ldx     #days
        ldb     #1
        jsr     print_BCD_number
;
        jsr     print_border
        jsr     update_screen
1$:     clra
        jsr     read_port
        beq     1$
;
        bsr     wait_for_key_release        
        jmp     start_menu

wait_for_key_release:
        pshs  x
        ldx   #0
1$:     clra
        jsr   read_port
        beq   9$
        leax  -1,x
        bne   1$
9$:     puls  x
        rts
        
game_complete_msg:

gameover_colours:
        .db 0x47, 0x46, 0x45, 0x45, 0x43, 0x44
gameover_xy:    
        .db 0x58, 0x9F, 0x50, 0x7F, 0x30, 0x6F
        .db 0x40, 0x5F, 0x30, 0x4F, 0x48, 0x37

gameover_text:
          ; "GAME  OVER"
        .db 0x10, 0xA, 0x16, 0xE, 0x26, 0x26, 0x18, 0x1F, 0xE
        .db 0x9B
        ; "TIME    DAYS"
        .db 0x1D, 0x12, 0x16, 0xE, 0x26, 0x26, 0x26, 0x26, 0xD
        .db 0xA, 0x22, 0x9C
        ; "PERCENTAGE OF QUEST"
        .db 0x19, 0xE, 0x1B, 0xC, 0xE, 0x17, 0x1D, 0xA, 0x10, 0xE
        .db 0x26, 0x18, 0xF, 0x26, 0x1A, 0x1E, 0xE, 0x1C, 0x9D
        ; "COMPLETED     %"
        .db 0xC, 0x18, 0x16, 0x19, 0x15, 0xE, 0x1D, 0xE, 0xD, 0x26
        .db 0x26, 0x26, 0x26, 0x26, 0xA7
        ; "CHARMS COLLECTED"
        .db 0xC, 0x11, 0xA, 0x1B, 0x16, 0x1C, 0x26, 0xC, 0x18
        .db 0x15, 0x15, 0xE, 0xC, 0x1D, 0xE, 0xD, 0x26, 0x26, 0xA6
        ; "OVERALL RATING"
        .db 0x18, 0x1F, 0xE, 0x1B, 0xA, 0x15, 0x15, 0x26, 0x1B
        .db 0xA, 0x1D, 0x12, 0x17, 0x90

calc_and_display_percent:

count_screens:
        bra     print_BCD_number
        
print_days:
        ldy     #vidbuf+0xef            ; (120,7)
        ldx     #days
        ldb     #1
        bsr     print_BCD_number
; attribute        
        rts
                
print_lives_gfx:
        ldx     #sprite_scratchpad
        lda     #0x8c
        sta     0,x                     ; graphic_no
        clr     7,x                     ; flags7
        lda     #16
        sta     26,x                    ; pixel_x
        lda     #32
        sta     27,x                    ; pixel_y
        jsr     print_sprite
; attribute stuff
        rts
        
print_lives:
        ldx     #lives
        ldb     #1
        ldy     #vidbuf+0x4e4
        bra     print_BCD_number
        
print_BCD_number:
        ldu     #font
        stu     gfxbase_8x8
print_BCD_msd:        
        lda     ,x                      ; get digit pair
        lsra
        lsra
        lsra
        lsra                            ; shift to low nibble
        pshs    b
        jsr     print_8x8
        puls    b
print_BCD_lsd:
        lda     ,x+                     ; get digit pair
        anda    #0x0f                   ; low nibble
        pshs    b
        jsr     print_8x8
        puls    b
        decb                            ; done all pairs?
        bne     print_BCD_msd           ; no, loop
        rts
        
display_day:
        ldu     #day_font
        stu     gfxbase_8x8
        ldx     #day_txt
        ldd     #0xf70
        jmp     print_text
        
day_txt:
        .db 0, 0, 1, 2, 0x83
day_font:
        .db 6, 7, 6, 6, 6, 6, 6, 0xF
        .db 0, 1, 0x82, 0xC6, 0x64, 0x6C, 0x6D, 0xC6
        .db 0xC8, 0xC6, 0xE1, 0x60, 0x60, 0xE0, 0x64, 0x63
        .db 0x60, 0x60, 0x60, 0xE0, 0x60, 0x40, 0xC0, 0x80

do_menu_selection:
        clr     suppress_border
        ldx     #menu_colours
        ldb     #8
1$:     lda     ,x
        anda    #0x7f
        sta     ,x+
        decb
        bne     1$
        jsr     clear_scrn_buffer
        jsr     display_menu
        bsr     flash_menu
        
menu_loop:
        jsr     display_menu
        
check_for_start_game:
				lda			#~(1<<0)								; 0-7
				jsr     read_port
				bita		#(1<<4)									; <0>?
				beq     1$                      ; no, skip
				rts
1$:     inc     seed_1
        bsr     flash_menu
        bra     menu_loop        

flash_menu:
        rts

menu_colours:   
        .db 0x43, 0xC4, 0x44, 0x44, 0x44, 0x45, 0x47, 0x47
menu_xy:
        .db 88, 159, 48, 143, 48, 127, 48, 111, 48, 95, 48, 79
        .db 48, 63, 80, 39
menu_text:
; "KNIGHT LORE"
        .db 0x14, 0x17, 0x12, 0x10, 0x11, 0x1D, 0x26, 0x15, 0x18
        .db 0x1B, 0x8E
; "1 KEYBOARD"
        .db 1, 0x26, 0x14, 0xE, 0x22, 0xB, 0x18, 0xA, 0x1B, 0x8D
; "2 KEMPSTON JOYSTICK"
        .db 2, 0x26, 0x14, 0xE, 0x16, 0x19, 0x1C, 0x1D, 0x18, 0x17
        .db 0x26, 0x13, 0x18, 0x22, 0x1C, 0x1D, 0x12, 0xC, 0x94
; "3 CURSOR   JOYSTICK"
        .db 3, 0x26, 0xC, 0x1E, 0x1B, 0x1C, 0x18, 0x1B, 0x26, 0x26
        .db 0x26, 0x13, 0x18, 0x22, 0x1C, 0x1D, 0x12, 0xC, 0x94
; "4 INTERFACE II"
        .db 4, 0x26, 0x12, 0x17, 0x1D, 0xE, 0x1B, 0xF, 0xA, 0xC
        .db 0xE, 0x26, 0x12, 0x92
; "5 DIRECTIONAL CONTROL"
        .db 5, 0x26, 0xD, 0x12, 0x1B, 0xE, 0xC, 0x1D, 0x12, 0x18
        .db 0x17, 0xA, 0x15, 0x26, 0xC, 0x18, 0x17, 0x1D, 0x1B
        .db 0x18, 0x95
; "0 START GAME"
        .db 0, 0x26, 0x1C, 0x1D, 0xA, 0x1B, 0x1D, 0x26, 0x10, 0xA
        .db 0x16, 0x8E
; "(c) 1984 A.C.G."
        .db 0x25, 0x26, 1, 9, 8, 4, 0x26, 0xA, 0x24, 0xC, 0x24
        .db 0x10, 0xA4

; D=x,y X=str
print_text_single_colour:
        ldu     #font
        stu     gfxbase_8x8
        jsr     calc_vidbuf_addr        ; ->U
        tfr     u,y
        bra     loc_BE56
        
print_text_std_font:

print_text:
        jsr     calc_vidbuf_addr        ; ->U
        tfr     u,y
        lda     ,x+                     ; attribute
loc_BE56:
;       bsr     calc_attrib_addr
8$:     lda     ,x+                     ; character
        bita    #(1<<7)                 ; last one?
        bne     9$                      ; yes, skip
        bsr     print_8x8
        bra     8$
9$:     anda    #0x7f
        bsr     print_8x8
        rts

; A=chr, Y=addr
print_8x8:
        pshs    y
        ldb     #8
        mul                             ; offset into font
        ldu     gfxbase_8x8
        leau    d,u                     ; ptr font data
        ldb     #8                      ; 8 lines to print
1$:     lda     ,u+                     ; read font data
        sta     ,y                      ; write to vidbuf
        leay    -32,y                   ; next line
        decb                            ; done all lines?
        bne     1$                      ; no, loop
        puls    y                       ; vidbuf addr
        leay    1,y                     ; inc for next char
        rts

toggle_selected:
        rts

display_menu:
;        ldx     #menu_colours
; added for Coco3 port
        lda     #ATTR_WHITE
        jsr     osd_set_palette
;
        ldy     #menu_xy
        ldx     #menu_text
        ldb     #8
display_text_list:
        pshs    b
        ldb     ,y+                     ; x
        lda     ,y+                     ; y
        pshs    y
        bsr     print_text_single_colour
        puls    y
        puls    b
        decb                            ; done all strings?
        bne     display_text_list       ; no loop
        lda     suppress_border
        bne     1$
        inca
        sta     suppress_border
        jsr     print_border
        jmp     update_screen
1$:     rts        

; U=dx,dy B=num        
multiple_print_sprite:
        pshs    b
        pshs    y,u
        jsr     print_sprite
        puls    y,u
        tfr     y,d
        addb    26,x
        stb     26,x
        adda    27,x
        sta     27,x
        puls    b
        decb
        bne     multiple_print_sprite
        rts

; player appear sparkles
upd_120_to_126:
        jsr     adj_m4_m12
        lda     seed_2
        coma
        anda    #1
        beq     1$
        rts
1$:     inc     0,x                     ; graphic_no
        jsr     audio_B419
        jmp     set_wipe_and_draw_flags

; last player appears sparkle
upd_127:
        jsr     adj_m4_m12
        lda     13,x                    ; flags13
        anda    #~FLAG_DEAD
        sta     13,x
        lda     16,x                    ; stored graphic_no
        sta     0,x                     ; graphic_no
        jmp     jump_to_upd_object

init_death_sparkles:
        lda     #112                    ; sparkles
        sta     0,x                     ; graphic_no
        lda     7,x                     ; flags7
        ora     #FLAG_IGNORE_3D
        bra     loc_BF31

; death sparkles
upd_112_to_118_184:
        jsr     adj_m4_m12
        inc     0,x                     ; graphic_no

loc_BF31:
        jsr     audio_B403
        jmp     set_wipe_and_draw_flags

; sparkles (object in cauldron)
upd_185_187:

; last death sparkle
upd_119:
        jsr     adj_m4_m12
        jmp     upd_111

display_objects_carried:
        tst     objects_carried_changed
        bne     1$
        rts
1$:     clr     objects_carried_changed

; this routine puts a pixel on the panel!
display_objects:
        pshs    x
        ldb     #3
        ldu     #objects_carried

display_object:
        ldx     #sprite_scratchpad
        pshs    b
        pshs    u
        negb
        addb    #3
        aslb
        aslb
        aslb
        stb     *z80_c
        aslb
        addb    *z80_c
        addb    #16                     ; (~b+3)*24+16
        stb     26,x                    ; pixel_x
        clr     27,x                    ; pixel_y
        lda     27,x                    ; pixel_y
        jsr     calc_vidbuf_addr        ; ->U
        tfr     u,y                     ; addr
        ldu     #0x1803                 ; lines, bytes
        clra
        jsr     fill_window
        lda     [,s]                    ; graphic_no (ptr on stack)
        beq     1$
        sta     0,x                     ; graphic_no
        jsr     print_sprite
1$:     ldb     26,x                    ; pixel_x
        lda     27,x                    ; pixel_y
        jsr     calc_vram_addr          ; ->U
        tfr     u,y                     ; dest (vram)
        jsr     calc_vidbuf_addr        ; ->U
        tfr     u,x                     ; src (vidbuf)
        ldu     #0x1803                 ; lines/bytes
        jsr     blit_to_screen
; code to set attribute of object        
; - not currently supported
        ldb     [,s]                    ; graphic_no (ptr on stack)
        andb    #0x0f
        ldu     #object_attributes
        lda     b,u                     ; attribute
; - sets attribute here
        puls    u
        puls    b
        leau    4,u
        decb
        bne     display_object
        puls    x        
        rts

object_attributes:
        ; diamond, poison, boot, challice, cup, bottle, globe, idol
        ; red, magenta, green, cyan, yellow, white, red, white
        .db 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x42, 0x47

sprite_scratchpad:
        .ds 32

chk_pickup_drop:
        lda     user_input
        anda    #INP_PICKUP_DROP
        rts

handle_pickup_drop:
        tst     pickup_drop_pressed
        lbne    loc_C0A9
        bsr     chk_pickup_drop
        lbeq    ret_pickup_drop
        jsr     chk_plyr_OOB
        lbcc    ret_pickup_drop
        lda     12,x                    ; flags12
        bita    #FLAG_JUMPING
        lbne    ret_pickup_drop
        bita    #FLAG_Z_OOB
        beq     ret_pickup_drop
        pshs    b                       ; user_input
        clr     cant_drop
        lda     3,x                     ; Z
        sta     *z80_b
        adda    #12                     ; +12
        sta     3,x                     ; Z+12
        jsr     do_any_objs_intersect
        pshs    cc
        lda     *z80_b
        sta     3,x                     ; restore Z
        puls    cc
        bcc     1$
        lda     #1
        sta     cant_drop
1$:     ; sound
        lda     #1
        sta     pickup_drop_pressed
        sta     objects_carried_changed
        ldb     #2
        lda     4,x                     ; width
        sta     *width
        adda    #4
        sta     4,x                     ; width+4
        lda     5,x                     ; depth
        sta     *depth
        adda    #4
        sta     5,x                     ; depth+4
        lda     6,x                     ; height
        sta     *height
        adda    #4
        sta     6,x                     ; height+4
        ldy     #special_objs_here
2$:     jsr     can_pickup_spec_obj
        lbcs    pickup_object
        leay    32,y
        decb
        bne     2$
        bsr     chk_pickup_drop
        beq     done_pickup_drop
        ldb     #2
        lda     8,x                     ; scrn
        cmpa    #CAULDRON_SCREEN
        bne     3$
        ldb     #1
3$:     ldy     #special_objs_here
4$:     tst     0,y                     ; graphic_no
        beq     loc_C0B2
        leay    32,y
        decb
        bne     4$

done_pickup_drop:
        ldd     *width
        sta     5,x                     ; width
        stb     6,x                     ; height
        lda     *depth
        sta     4,x                     ; depth
        puls    b                       ; user_input
ret_pickup_drop:
        rts

loc_C0A9:
        jsr     chk_pickup_drop
        bne     9$
        clr     pickup_drop_pressed
9$:     rts

loc_C0B2:
        ldu     #unk_5BE4
        lda     ,u+
        beq     adjust_carried
        tst     cant_drop
        bne     done_pickup_drop
        ldb     -1,u
        stb     0,y                     ; graphic_no
        lda     8,x                     ; scrn
        cmpa    #CAULDRON_SCREEN
        bne     1$
        lda     3,x                     ; Z
        cmpa    #152
        bcs     1$
        orb     #(1<<3)
        stb     0,y                     ; graphic_no
        lda     #1
        sta     obj_dropping_into_cauldron
1$:     pshs    x,y
        leax    1,x
        leay    1,y
        ldb     #3
2$:     lda     ,x+
        sta     ,y+
        decb
        bne     2$
        puls    x,y
        lda     3,x                     ; Z
        adda    #12                     ; +12
        sta     3,x                     ; Z+=12
        lda     0x23,x                  ; Z (top half)
        adda    #12                     ; +12
        sta     0x23,x                  ; Z+=12 (top half)
        exg     x,y
        jsr     calc_pixel_XY
        exg     x,y

drop_object:
        lda     #5
        sta     4,y                     ; width
        sta     5,y                     ; depth
        lda     #12
        sta     6,y                     ; height
        lda     ,u+
        sta     7,y                     ; flags7
        lda     8,x                     ; scrn
        sta     8,y                     ; scrn
        ldd     ,u++
        std     16,y                    ; ptr special object
        lda     13,y                    ; flags13
        ora     #FLAG_JUST_DROPPED
        sta     13,y                    ; flags13

adjust_carried:
        ldy     #unk_5BE4
        ldb     #12
1$:     lda     ,-y
        sta     4,y
        decb
        bne     1$        
;        ldy     #inventory
        ldb     #4
        jsr     zero_Y
        jmp     done_pickup_drop

pickup_object:
        ldu     #inventory
        clr     disable_spike_ball_drop
        lda     0,y                     ; graphic_no
        sta     ,u+
        lda     7,y                     ; flags7
        sta     ,u+
        ldd     16,y
        clr     [16,y]                  ; zap special_objs_tbl.graphic_no
        std     ,u++                    ; store ptr
        jsr     set_wipe_and_draw_Y
        lda     #1
        sta     0,y                     ; graphic_no
        ldu     #unk_5BE4               ; object_carried[2].graphic_no
        lda     ,u+
        beq     adjust_carried
        sta     0,y                     ; graphic_no
        bra     drop_object

can_pickup_spec_obj:
        lda     0,y                     ; graphic_no
        suba    #0x60
        cmpa    #7
        bcs     is_on_or_near_obj
        rts

is_on_or_near_obj:
        clr     *z80_c
        clr     *z80_l
        clr     *z80_h
        jsr     do_objs_intersect_on_x
        bcc     1$
        jsr     do_objs_intersect_on_y
        bcc     1$
        lda     3,x                     ; Z
        suba    #4
        sta     3,x                     ; Z-=4
        jsr     do_objs_intersect_on_z
        pshs    cc
        lda     3,x                     ; Z
        adda    #4
        sta     3,x                     ; Z+=4
        puls    cc
1$:     rts

is_obj_moving:
        lda     9,x                     ; dX
        ora     10,x                    ; dY
        ora     11,x                    ; dZ
        rts

; extra life
upd_103:
        jmp     dec_dZ_upd_XYZ_wipe_if_moving
        
; special objects being put in cauldron
upd_104_to_110:
audio_B467_wipe_and_draw:
        jmp     set_wipe_and_draw_flags
        
centre_of_room:
add_obj_to_cauldron:        
        jmp     upd_111
        
ret_next_obj_required:
        lda     objects_put_in_cauldron
        ldu     objects_required
        leau    a,u
        rts
        
objects_required:
        .db 0, 1, 2, 3, 4, 5, 6, 3
        .db 5, 0, 6, 1, 2, 4

; special objects
upd_96_to_102:
        jsr     adj_m4_m12
        jsr     dec_dZ_and_update_XYZ
        lda     13,x                    ; flags13
        bita    #FLAG_JUST_DROPPED
        bne     1$
        bsr     is_obj_moving
        bne     1$
        rts
1$:     lda     13,x                    ; flags13
        anda    #~FLAG_JUST_DROPPED
        sta     13,x
        jsr     clear_dX_dY
        bra     audio_B467_wipe_and_draw
        
cycle_colours_with_sound:
cycle_attribute_mem:

no_update:
        rts

prepare_final_animation:
        rts
        
chk_and_init_transform:
.ifndef BUILD_OPT_NO_TRANSFORM
        tst     transform_flag_graphic
        beq     9$
        lda     12,x                    ; flags12
        bita    #MASK_ENTERING_SCRN
        bne     9$
        bita    #FLAG_JUMPING
        bne     9$
        leas    2,s                     ; return to caller
        lda     0,x                     ; graphic_no
        sta     transform_flag_graphic
        lda     #8
        sta     16,x                    ; transform count
        pshs    x
        leax    32,x
        lda     #1
        sta     0,x
        jsr     set_wipe_and_draw_flags
        puls    x
        jsr     upd_11                
        bra     rand_legs_sprite
.endif        
9$:     rts

; human/wulf transform
upd_92_to_95:
        jsr     upd_11
        lda     13,x                    ; flags13
        bita    #FLAG_DEAD
        beq     1$
        tst     all_objs_in_cauldron
        bne     1$
        jmp     init_death_sparkles
1$:     lda     seed_2
        anda    #3
        beq     2$
        rts
2$:     jsr     audio_B472
        dec     16,x                    ; copy of graphic_no
        beq     loc_C377        
        
rand_legs_sprite:
;       ld      a,r
        lda     TMRLSB                  ; temp hack
        sta     *z80_c
        lda     seed_3
        adda    *z80_c
        anda    #3
        ora     #92
        cmpa    0,x                     ; graphic_no
        bne     3$
        eora    #1
3$:     sta     0,x                     ; graphic_no
        lda     7,x                     ; flags7
        eora    #FLAG_HFLIP
        sta     7,x                     ; flags7
        jmp     set_wipe_and_draw_flags

loc_C377:
        lda     transform_flag_graphic
        eora    #0x20
        sta     0,x                     ; graphic_no
        adda    #0x10
        sta     0x20,x                  ; graphic_no (top half)
        clr     transform_flag_graphic
        jsr     adj_m6_m12
        lda     0,x                     ; graphic_no
        bita    #(1<<5)
        beq     4$
        dec     19,x                    ; dY_adj
4$:     jmp     set_wipe_and_draw_flags
                
print_sun_moon:
        lda     seed_2
        anda    #7
        beq     1$
        rts
1$:     ldx     #sun_moon_scratchpad
        inc     26,x                  ; pixel_x

display_sun_moon_frame:
        tst     all_objs_in_cauldron
        beq     1$
        rts
1$:     lda     26,x                  ; pixel_x
        cmpa    #225
        beq     toggle_day_night
        lda     26,x                  ; pixel_x
        adda    #16
        ldu     #sun_moon_yoff
        rora
        rora
        anda    #0x0f
        lda     a,u                   ; get entry
        sta     27,x                  ; pixel_y
display_frame:
        ldu     #0x1f06               ; 31 lines, 6 bytes
        ldy     #vidbuf+0x17          ; (184,0)
        pshs    u
        pshs    y
        clra
        jsr     fill_window
        jsr     print_sprite
        ldx     #sprite_scratchpad
        clr     7,x                   ; flags7
        lda     #0x5a
        sta     0,x                   ; graphic_no
        lda     #184
        sta     26,x                  ; pixel_x
        clr     27,x                  ; pixel_y
        jsr     print_sprite
        lda     #208
        sta     26,x                  ; pixel_x
        lda     #0xba
        sta     0,x                   ; graphic_no
        jsr     print_sprite
        puls    x                     ; vidbuf addr (src)
        puls    u                     ; lines,bytes
        ldy     #coco_vram+0x17F7     ; (184,0) (dest)
        jmp     blit_to_screen

toggle_day_night:
        lda     0,x                   ; graphic_no
        eora    #1                    ; toggle sun/moon
        sta     0,x
        jsr     colour_sun_moon
        lda     #176
        sta     26,x                  ; pixel_x
        lda     #1
        sta     transform_flag_graphic
        lda     sun_moon_scratchpad
        anda    #1
        beq     inc_days
        rts
inc_days:
        ldu     #days
        lda     ,u
        adda    #1                      ; can't use INCA for DAA
        daa
        sta     ,u
        cmpa    #64
        lbeq    game_over
        jsr     print_days
        ldd     #0x0078                 ; (120,0)
        pshs    x
        bsr     blit_2x8
        puls    x
        bra     display_frame
                
blit_2x8:
        jsr     calc_vram_addr;         ; ->U
        tfr     u,y
        jsr     calc_vidbuf_addr        ; ->U
        tfr     u,x                     ; vidbuf (src)
        ldu     #0x0802                 ; 8 lines, 2 bytes        
        jmp     blit_to_screen

sun_moon_yoff:  
        .db 5, 6, 7, 8, 9, 0xA, 0xA, 9, 8, 7, 6, 5, 5

sun_moon_scratchpad:
        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

init_sun:
        ldx     #sun_moon_scratchpad
        lda     #0x58
        sta     0,x                   ; graphic no
        lda     #176
        sta     26,x                  ; pixel_x
        lda     #9
        sta     27,x                  ; pixel_y
        rts
        
init_special_objects:
        ldu     #special_objs_tbl
        lda     seed_1
        sta     *z80_e
;       ld      a,r
        lda     TMRLSB                ; temp hack
        adda    *z80_e
        sta     *z80_e
init_obj_loop:
        lda     *z80_e
        anda    #7
        ora     #0x60                 ; graphic_no
        sta     ,u+
        inc     *z80_e
        ldb     #4                    ; 4 bytes to copy
1$:     lda     ,u+                   ; start x/y/z/scrn
        sta     3,u                   ; curr x/y/z/scrn
        decb
        bne     1$
        leau    4,u                   ; next special obj
        cmpu    #eosot                ; end of table
        bne     init_obj_loop
        rts

; block
upd_62:
        bsr     upd_6_7
        jsr     clear_dX_dY
        jsr     audio_B3E9
        jmp     dec_dZ_wipe_and_draw

; chest
upd_85:
        bsr     upd_6_7
        jsr     dec_dZ_and_update_XYZ
        jsr     is_obj_moving
        bne     1$
        rts
1$:     jmp     audio_B467_wipe_and_draw

; table
upd_84:
        bsr     upd_6_7

dec_dZ_upd_XYZ_wipe_if_moving:
        jsr     dec_dZ_and_update_XYZ
        jsr     is_obj_moving
        bne     1$
        rts
1$:     jsr     clear_dX_dY
        jmp     audio_B467_wipe_and_draw

; tree wall
upd_128_to_130:
        ldd     #0xfef8                 ; -2,-8
        bra     jp_set_pixel_adj

adj_m4_m12:
        ldd     #0xfcf4                 ; -4,-12
        bra     jp_set_pixel_adj

adj_m6_m12:
        ldd     #0xfaf4                 ; -6,-12
        bra     jp_set_pixel_adj

jp_set_pixel_adj:
        jmp     set_pixel_adj

; rock and block
upd_6_7:
        ldd     #0xf8f0                 ; -8,-16
        bra     jp_set_pixel_adj

; bricks
upd_10:
        ldd     #0xffec                 ; -1,-20
        bra     jp_set_pixel_adj

; bricks
upd_11:
        ldd     #0xfef4                 ; -2,-12
        bra     jp_set_pixel_adj

; bricks
upd_12_to_15:
        ldd     #0xfcf8                 ; -4,-8
        bra     jp_set_pixel_adj

adj_m8_m12:
        ldd     #0xf8f4                 ; -8,-12
        bra     jp_set_pixel_adj

adj_m7_m12:
        ldd     #0xf9f4                 ; -7,12
        bra     jp_set_pixel_adj

adj_m12_m12:
        ldd     #0xf4f4                 ; -12,-12
        bra     jp_set_pixel_adj

upd_88_to_90:
        ldd     #0xf4f0                 ; -12, -16
        bra     jp_set_pixel_adj

adj_p7_m12:
        ldd     #0x7f4                  ; +7,-12
        bra     jp_set_pixel_adj

adj_p3_m12:
        ldd     #0x3f4                  ; +3,-12
        bra     jp_set_pixel_adj

; U=lines,bytes Y=dest, A=byte
fill_window:
        stu     *lines
        ldb     *lines
1$:     pshs    b,y
        ldb     *bytes
2$:     sta     ,y+
        decb
        bne     2$
        puls    b,y
        leay    32,y
        decb
        bne     1$
        rts

find_special_objs_here:
        ldy     #special_objs_here
        ldu     #special_objs_tbl
1$:     tst     0,u                     ; graphic_no
        beq     2$
        lda     8,u                     ; scrn
        cmpa    8,x                     ; current screen
        bne     2$
        pshs    u
        lda     ,u+                     ; graphic_no
        sta     ,y+                     ; graphic_no
        leau    4,u
        lda     ,u+                     ; curr_x
        sta     ,y+                     ; X
        lda     ,u+                     ; curr_y
        sta     ,y+                     ; Y
        lda     ,u+                     ; curr_Z
        sta     ,y+                     ; Z
        lda     #5
        sta     ,y+                     ; width
        sta     ,y+                     ; depth
        lda     #12
        sta     ,y+                     ; height
        lda     #FLAG_DRAW|FLAG_MOVEABLE
        sta     ,y+                     ; flags7
        lda     ,u                      ; curr_scrn
        sta     ,y+                     ; scrn
        ldb     #7
        jsr     zero_Y                  ; zero bytes 8-15
        puls    u                       ; ptr special_objs_tbl
        stu     ,y++                    ; store in bytes 16-17
        ldb     #14
        jsr     zero_Y
2$:     leau    9,u                     ; next entry
        cmpu    #eosot
        blt     1$
3$:     cmpy    #other_objs_here
        beq     9$
        ldb     #32
        jsr     zero_Y
        bra     3$
9$:     rts

update_special_objs:
        rts

; ghost
upd_80_to_83:
        jmp     set_deadly_wipe_and_draw_flags
        
calc_ghost_sprite:
set_ghost_hflip:
        rts

clr_ghost_hflip:        
        rts

get_delta_from_tbl:
        rts

delta_tbl:        

; portcullis (static)
upd_8:
init_portcullis_down:

set_wipe_and_draw_flags:
        lda     7,x                     ; flags7
        ora     #FLAG_WIPE|FLAG_DRAW
        sta     7,x                     ; flags7
        jmp     set_draw_objs_overlapped
        
set_wipe_and_draw_Y:
        pshs    x,y
        tfr     y,x
        bsr     set_wipe_and_draw_flags
        puls    x,y
        rts

init_portcullis_up:

; portcullis (moving)
upd_9:
stop_portcullis:
        bra     set_wipe_and_draw_flags
        
move_portcullis_up:        
        bra     stop_portcullis

dec_dZ_and_update_XYZ:
        dec     11,x                    ; dZ--
        jsr     adj_for_out_of_bounds

add_dXYZ:
        lda     1,x                     ; X
        adda    9,x                     ; X+dX
        sta     1,x
        lda     2,x                     ; Y
        adda    10,x                    ; Y+dY
        sta     2,x
        lda     3,x                     ; Z
        adda    11,x                    ; Z+dZ
        sta     3,x
        rts
        
; arch (far side)
upd_3_5:
        lda     7,x                     ; flags7
        bita    #FLAG_HFLIP             ; hflip?
        bne     adj_3_5_hflip
        ldd     #0xfdf7                 ; -3,-9

; A=y_adj, B=x_adj
set_pixel_adj:
        stb     18,x                    ; x_adj
        sta     19,x                    ; y_adj
        rts
        
adj_3_5_hflip:
        ldd     #0xfef9                 ; -2,-7
        bra     set_pixel_adj

adj_m3_p1:
        ldd     #0xfd01                 ; -3,+1
        bra     loc_C74C

; arch (near side)
upd_2_4:
        lda     7,x                     ; flags7
        bita    #FLAG_HFLIP             ; hflip?
        bne     adj_2_4_hflip
        lda     0,x                     ; graphic_no
        cmpa    #4                      ; tree arch?
        beq     adj_m3_p1               ; yes, go
        ldd     #0xfdf9                 ; -3,-7
loc_C74C:
        bsr     set_pixel_adj
        lda     2,x                     ; Y
        adda    #13                     ; Y+13
        sta     10,x                    ; centre_y
        lda     1,x                     ; X
        sta     9,x                     ; centre_x
        ldu     #0x60f                  ; +6,+15
loc_C760:
        lda     3,x                     ; Z
        sta     11,x                    ; centre_z
        bsr     chk_plyr_spec_near_arch
        bra     loc_C785

adj_2_4_hflip:
        ldd     #0xfeef                 ; -2,-17
        bsr     set_pixel_adj
        lda     1,x                     ; X
        suba    #13                     ; X-13
        sta     9,x                     ; centre_x
        lda     2,x                     ; Y
        sta     10,x                    ; centre_y
        ldu     #0xf06                  ; +15,+6
        bra     loc_C760
loc_C785:
        ldu     #0xf0f                  ; +15,+15
        ldy     #graphic_objs_tbl
        ldb     #4
loc_C791:
        pshs    b
        tst     0,y                     ; graphic_no
        beq     loc_C7D6
        lda     7,y                     ; flags7
        bita    #FLAG_AUTO_ADJ
        beq     loc_C7D6
        stu     *y_lim                  ; & x_lim
        bsr     is_near_to
        bcc     loc_C7D6
        ldu     #adj_arch_tbl
        jmp     lookup_plyr_dXY

adj_arch_tbl:
        .dw     adj_ew
        .dw     adj_ew
        .dw     adj_ns
        .dw     adj_ns

adj_ew:
        lda     10,x                    ; dY
        cmpa    2,y                     ; Y
        beq     loc_C7D5
        pshs    cc
        lda     #1
        puls    cc
        bcc     1$
        nega
1$:     sta     15,y                    ; dY_adj
        bra     loc_C7D5        
        
adj_ns:
        lda     9,x                     ; dX
        cmpa    1,y                     ;X
        beq     loc_C7D5
        pshs    cc
        lda     #1
        puls    cc
        bcc     1$
        nega
1$:     sta     14,y                    ; dX_adj
loc_C7D5:
loc_C7D6:
        leay    32,y
        puls    b
        decb
        bne     loc_C791
        rts
       
; U=x,y limits
chk_plyr_spec_near_arch:
        ldy     #graphic_objs_tbl
        ldb     #4
1$:     tst     0,y                     ; graphic_no
        beq     2$
        lda     7,y                     ; flags7
        bita    #FLAG_AUTO_ADJ
        beq     2$
        stu     *y_lim                  ; & x_lim
        bsr     is_near_to
        bcc     2$
        lda     7,y                     ; flags7
        ora     #FLAG_NEAR_ARCH
        sta     7,y                     ; flags7
2$:     leay    32,y
        decb
        bne     1$
        rts

is_near_to:
        lda     9,x                     ; dX
        suba    1,y                     ; -X
        bcc     1$
        nega
1$:     cmpa    *x_lim
        bcc     9$
        lda     10,x                    ; dY
        suba    2,y                     ; -Y
        bcc     2$
        nega
2$:     cmpa    *y_lim
        bcc     9$
        lda     11,x                    ; dZ
        suba    3,y                     ; -Z
        bcc     3$
        nega
3$:     cmpa    #4
9$:     rts

; sabreman legs
upd_16_to_21_24_to_29:
        jsr     adj_m6_m12
        bra     upd_player_bottom

; wulf legs
upd_48_to_53_56_to_61:
        jsr     adj_m7_m12

upd_player_bottom:
        lda     13,x                    ; flags13
        bita    #FLAG_DEAD              ; dead?
        beq     1$                      ; no, skip
        tst     all_objs_in_cauldron
        bne     1$
        lda     0x2d,x                  ; flags13 (top half)
        ora     #FLAG_DEAD
        sta     0x2d,x
        jmp     init_death_sparkles
 1$:    jsr     chk_and_init_transform
        jsr     check_user_input
        jsr     handle_pickup_drop
        bsr     handle_left_right
        jsr     handle_jump
        jsr     handle_forward
        bsr     chk_plyr_OOB
        bcc     plyr_OOB
loc_C855:
        lda     0x27,x                  ; flags7 (top half)
        ora     #FLAG_IGNORE_3D
        sta     0x27,x
        jsr     move_player
        lda     0x27,x                  ; flags7 (top half)
        anda    #~FLAG_IGNORE_3D
        sta     0x27,x
        lda     12,x                    ; flags12
        suba    #0x10                   ; entering room?
        bcs     2$                      ; no, skip
        sta     12,x                    ; counter dec'd
2$:     jmp     set_wipe_and_draw_flags

; when walking through arches
plyr_OOB:
        tst     11,x                    ; dZ
        bmi     loc_C855                ; <0
        clr     11,x                    ; dZ=0
        bra     loc_C855

chk_plyr_OOB:
        lda     room_size_X
        suba    4,x                     ; width
        sta     *z80_l
        lda     room_size_Y
        suba    5,x                     ; depth
        sta     *z80_h
        lda     1,x                     ; X
        suba    #128
        bpl     1$
        nega
1$:     cmpa    *z80_l
        bcc     9$
        lda     2,x                     ; Y
        suba    #128
        bpl     2$
        nega
2$:     cmpa    *z80_h
9$:     rts
         
handle_left_right:
; directional stuff
        bra     left_right_non_directional
        rts

left_right_non_directional:
        lda     13,x                    ; flags13
        anda    #7                      ; too soon to turn (again)?
        beq     1$                      ; no, go
        dec     13,x                    ; flags13 - dec turn counter
        rts
1$:     bitb    #INP_LEFT|INP_RIGHT
        beq     9$                      ; no, exit
        lda     12,x                    ; flags12
        anda    #MASK_ENTERING_SCRN
        bne     9$
        lda     12,x                    ; flags12
        anda    #FLAG_JUMPING
        bne     9$
        bitb    #INP_FORWARD
        bne     2$
        pshs    b
        jsr     audio_B4C1
        puls    b
2$:     lda     13,x                    ; flags13
        ora     #2                      ; init turn delay counter
        sta     13,x                    ; flags13
        bitb    #INP_RIGHT
        bne     5$
        lda     7,x                     ; flags7
        bita    #FLAG_HFLIP
        bne     4$
3$:     lda     0,x                     ; graphic_no
        eora    #8
        sta     0,x                     ; graphic_no
4$:     lda     7,x                     ; flags7
        eora    #FLAG_HFLIP
        sta     7,x                     ; flags7
        lda     0,x                     ; graphic_no
        adda    #0x10
        sta     0x20,x                  ; graphic_no (top half)
9$:     rts

5$:     lda     7,x                     ; flags7
        bita    #FLAG_HFLIP
        bne     3$
        bra     4$

handle_jump:
        bitb    #INP_JUMP               ; jump pressed?
        beq     9$                      ; no, exit
        lda     12,x                    ; flags12
        bita    #MASK_ENTERING_SCRN     ; entering screen?
        bne     9$                      ; yes, exit
        bita    #FLAG_JUMPING           ; already jumping?
        bne     9$                      ; yes, exit
        lda     11,x                    ; dZ
        inca
        bmi     9$
        lda     12,x                    ; flags12
        ora     #FLAG_JUMPING           ; flag as jumping
        sta     12,x                    ; flags12
        lda     #8
        sta     11,x                    ; dZ=8
        pshs    b
        jsr     audio_B441
        puls    b
9$:     rts

handle_forward:
        lda     12,x                    ; flags12
        bita    #MASK_ENTERING_SCRN     ; entering screen?
        bne     1$                      ; yes, skip
        bita    #FLAG_JUMPING           ; already jumping?
        bne     1$
        bitb    #INP_FORWARD
        beq     loc_C994
1$:     pshs    b
        jsr     audio_B4BB
        puls    b

animate_guard_wizard_legs:
        lda     0,x                     ; graphic_no
        sta     *z80_e
        inca                            ; next sprite
        anda    #7
        cmpa    #6                      ; wrap?
        bne     2$                      ; no, skip
        clra
2$:     
        sta     *z80_d
        lda     *z80_e                  ; old graphic
        anda    #0xf8                   ; get base
        ora     *z80_d                  ; new graphic
        sta     0,x                     ; graphic_no
        rts

loc_C994:
        lda     0,x                     ; graphic_no
        anda    #7
        cmpa    #2
        beq     9$
        cmpa    #4
        bne     animate_guard_wizard_legs
9$:     rts
        
move_player:
        tst     obj_dropping_into_cauldron
        beq     1$
        lda     #2
        sta     11,x                    ; dZ=2
1$:     lda     12,x                    ; flags12
        bita    #FLAG_JUMPING           ; already jumping?
        bne     2$
        anda    #MASK_ENTERING_SCRN
        bne     2$
        bitb    #INP_FORWARD
        beq     3$
2$:     pshs    b
        bsr     calc_plyr_dXY
        puls    b
3$:     lda     11,x                    ; dZ
        bmi     4$
        bitb    #INP_JUMP
        bne     5$
4$:     deca
5$:     deca
        sta     11,x                    ; dZ
        sta     tmp_dZ
        adda    #2
;       call M,audio_B451
        jsr     adj_for_out_of_bounds
        jsr     handle_exit_screen
        jsr     add_dXYZ
        lda     12,x                    ; flags12
        bita    #FLAG_Z_OOB
        beq     clear_dX_dY
        lda     tmp_dZ
        bpl     clear_dX_dY
        lda     12,x                    ; flags12
        anda    #~FLAG_JUMPING
        sta     12,x                    ; flags12

clear_dX_dY:
        clra
        sta     9,x                     ; dX=0
        sta     10,x                    ; dY=0
        rts

calc_plyr_dXY:
        lda     9,x                     ; dX
        adda    14,x                    ; dX_adjust
        sta     9,x                     ; dX
        lda     10,x                    ; dY
        adda    15,x                    ; dY_adjust
        sta     10,x                    ; dY
        clra
        sta     14,x                    ; dX_adjust
        sta     15,x                    ; dY_adjust
        ldu     #off_CA32

lookup_plyr_dXY:
        bsr     get_sprite_dir          ; ->A
        tfr     a,b
        jmp     jump_to_tbl_entry

get_sprite_dir:
        lda     7,x                     ; flags7
        rora
        rora
        anda    #0x10                   ; hflip
        sta     *z80_l
        lda     0,x                     ; graphic_no
        anda    #8
        ora     *z80_l
        rora
        rora
        rora
        anda    #3
        rts
        
off_CA32:
        .dw     move_plyr_W             ; dX-=3
        .dw     move_plyr_E             ; dX+=3
        .dw     move_plyr_N             ; dY+=3
        .dw     move_plyr_S             ; dY-=3

move_plyr_W:
        lda     9,x                     ; dX
        adda    #-3
loc_CA3F:
        sta     9,x                     ; dX
        rts

move_plyr_E:
        lda     9,x                     ; dX
        adda    #3
        bra     loc_CA3F

move_plyr_N:
        lda     10,x                    ; dY
        adda    #3
loc_CA4F:
        sta     10,x                    ; dY
        rts

move_plyr_S:
        lda     10,x                    ; dY
        adda    #-3
        bra     loc_CA4F

adj_dZ_for_out_of_bounds:
        lda     room_size_Z
        sta     *z80_d
1$:     lda     3,x                     ; Z
        adda    *z80_h                  ; Z+dZ
        cmpa    *z80_d                  ; >= room height?
        bcc     9$                      ; yes, exit
        lda     12,x                    ; flags12
        ora     #FLAG_Z_OOB
        sta     12,x                    ; flags12
        lda     *z80_h                  ; dZ
        bsr     adj_d_for_out_of_bounds
        sta     *z80_h                  ; new dZ
        bne     1$                      ; check again
9$:     rts

handle_exit_screen:
        lda     12,x                    ; flags12
        bita    #MASK_ENTERING_SCRN
        bne     9$
        lda     7,x                     ; flags7
        bita    #FLAG_NEAR_ARCH
        beq     9$
        anda    #~FLAG_NEAR_ARCH
        sta     7,x                     ; flags7
        ldu     #screen_move_tbl
        jmp     lookup_plyr_dXY
9$:     rts
        
adj_d_for_out_of_bounds:
        tsta
        beq     9$
        bpl     1$
        inca
        inca
1$:     deca
9$:     rts
        
screen_move_tbl:
        .dw     screen_west
        .dw     screen_east
        .dw     screen_north
        .dw     screen_south

screen_west:
        lda     #128
        suba    room_size_X
        sta     *z80_l
        lda     1,x                     ; X
        adda    9,x                     ; +dX
        adda    4,x                     ; +width
        cmpa    *z80_l
        bcs     1$
        rts
1$:     clr     1,x                     ; X=0
        lda     8,x                     ; screen
        sta     *z80_l
        deca                            ; screen to the west

screen_e_w:
        anda    #0x0f
        sta     *z80_h
        lda     *z80_l
        anda    #0xf0
        ora     *z80_h

exit_screen:        
        sta     8,x                     ; screen
        lda     12,x                    ; flags12
        ora     #0x30                   ; init room enter cntr
        sta     12,x                    ; flags12
        lda     0,x                     ; graphic_no
        suba    #0x10
        cmpa    #0x40                   ; wulf?
        bcs     1$                      ; wtf?
        rts
1$:     leas    4,s
        tfr     x,u
        ldy     #plyr_spr_1_scratchpad
        ldb     #64
2$:     lda     ,u+
        sta     ,y+
        decb
        bne     2$
        lda     plyr_spr_1_scratchpad
        sta     byte_D171
        lda     plyr_spr_1_scratchpad
        sta     byte_D191
        lda     #120                    ; sparkles
        sta     plyr_spr_1_scratchpad
        sta     plyr_spr_2_scratchpad
        jmp     game_loop

screen_east:
        lda     room_size_X
        adda    #128
        sta     *z80_l
        lda     1,x                     ; X
        adda    9,x                     ; +dX
        suba    4,x                     ; -width
        cmpa    *z80_l
        bcc     1$
        rts
1$:     lda     #-1
        sta     1,x                     ; X=-1
        lda     8,x                     ; screen
        sta     *z80_l
        inca
        bra     screen_e_w
        
screen_north:
        lda     room_size_Y
        adda    #128
        sta     *z80_h
        lda     2,x                     ; Y
        adda    10,x                    ; +dY
        suba    5,x                     ; -depth
        cmpa    *z80_h
        bcc     1$
        rts
1$:     lda     #-1
        sta     2,x                     ; Y=-1
        lda     8,x                     ; screen
        adda    #16
        bra     exit_screen
        
screen_south:
        lda     #128
        suba    room_size_Y
        sta     *z80_h
        lda     2,x                     ; Y
        adda    10,x                    ; +dY
        adda    5,x                     ; +depth
        cmpa    *z80_h
        bcs     1$
        rts
1$:     clr     2,x                     ; Y=0
        lda     8,x
        suba    #16
        jmp     exit_screen
                
adj_for_out_of_bounds:
        lda     7,x                     ; flags7
        bita    #FLAG_IGNORE_3D
        beq     1$
        rts
1$:     ora     #FLAG_IGNORE_3D
        sta     7,x                     ; flags7
        lda     12,x                    ; flags12
        anda    #0xf8                   ; clear X,Y,Z OOB
        sta     12,x                    ; flags12
        clr     *z80_l                  ; new dY
        clr     *z80_c                  ; new dX
        lda     11,x                    ; dZ
        sta     *z80_h                  ; new dZ
        beq     2$
        jsr     adj_dZ_for_out_of_bounds
        lda     *z80_h                  ; new dZ
        beq     2$
        jsr     adj_dZ_for_obj_intersect
2$:
        lda     9,x                     ; dX
        sta     *z80_c                  ; new dX
        tsta
        beq     3$
        jsr     adj_dX_for_out_of_bounds
        lda     *z80_c                  ; new dX
        beq     3$
        bsr     adj_dX_for_obj_intersect
3$:
        lda     10,x                    ; dY
        sta     *z80_l                  ; new dY
        tsta
        beq     4$
        jsr     adj_dY_for_out_of_bounds
        lda     *z80_l                  ; new dY
        beq     4$
        bsr     adj_dY_for_obj_intersect
4$:
        lda     *z80_c                  ; new dX
        sta     9,x                     ; dX
        lda     *z80_l                  ; new dY
        sta     10,x                    ; dY
        lda     *z80_h                  ; new dZ
        sta     11,x                    ; dZ
        lda     7,x                     ; flags7
        anda    #~FLAG_IGNORE_3D
        sta     7,x                     ; flags7
        rts

adj_dX_for_obj_intersect:
        ldy     #graphic_objs_tbl
        ldb     #MAX_OBJS
1$:     jsr     is_object_not_ignored
        beq     4$
        jsr     do_objs_intersect_on_y
        bcc     4$
        jsr     do_objs_intersect_on_z
        bcc     4$
2$:     jsr     do_objs_intersect_on_x
        bcc     4$
        lda     12,x                    ; flags12
        ora     #FLAG_X_OOB
        sta     12,x                    ; flags12
        lda     13,x                    ; flags13
        lsra                            ; 7->6
        anda    #FLAG_DEAD
        ora     13,y                    ; flags13
        sta     13,y                    ; flags13
        lsla                            ; 5->6
        anda    #FLAG_DEAD
        ora     13,x                    ; flags13
        sta     13,x                    ; flags13
        lda     7,y                     ; flags7
        bita    #FLAG_MOVEABLE
        beq     3$
        lda     9,x                     ; dX
        sta     9,y                     ; dX
3$:     lda     *z80_c                  ; new dX
        jsr     adj_d_for_out_of_bounds
        sta     *z80_c                  ; new dX
        beq     9$
        bra     2$
4$:     leay    32,y
        decb
        bne     1$
9$:     rts
        
adj_dY_for_obj_intersect:                
        ldy     #graphic_objs_tbl
        ldb     #MAX_OBJS
1$:     jsr     is_object_not_ignored
        beq     4$
        jsr     do_objs_intersect_on_x
        bcc     4$
        jsr     do_objs_intersect_on_z
        bcc     4$
2$:     jsr     do_objs_intersect_on_y
        bcc     4$
        lda     12,x                    ; flags12
        ora     #FLAG_Y_OOB
        sta     12,x                    ; flags12
        lda     13,x                    ; flags13
        lsra                            ; 7->6
        anda    #FLAG_DEAD
        ora     13,y                    ; flags13
        sta     13,y                    ; flags13
        lsla                            ; 5->6
        anda    #FLAG_DEAD
        ora     13,x                    ; flags13
        sta     13,x                    ; flags13
        lda     7,y                     ; flags7
        bita    #FLAG_MOVEABLE
        beq     3$
        lda     10,x                    ; dY
        sta     10,y                    ; dY
3$:     lda     *z80_l                  ; new dY
        jsr     adj_d_for_out_of_bounds
        sta     *z80_l                  ; new dY
        beq     9$
        bra     2$
4$:     leay    32,y
        decb
        bne     1$
9$:     rts

adj_dZ_for_obj_intersect:
        ldy     #graphic_objs_tbl
        ldb     #MAX_OBJS
1$:     jsr     is_object_not_ignored
        beq     5$
        bsr     do_objs_intersect_on_x
        bcc     5$
        bsr     do_objs_intersect_on_y
        bcc     5$
2$:     bsr     do_objs_intersect_on_z
        bcc     5$
        lda     12,x                    ; flags12
        ora     #FLAG_Z_OOB
        sta     12,x                    ; flags12
        lda     13,x                    ; flags13
        lsra                            ; 7->6
        anda    #FLAG_DEAD
        ora     13,y                    ; flags13
        ora     #FLAG_TRIGGERED
        sta     13,y                    ; flags13
        lsla                            ; 5->6
        anda    #FLAG_DEAD
        ora     13,x                    ; flags13
        sta     13,x                    ; flags13
;       set     3, 13(iy)               ; see 6 lines above
        lda     7,y                     ; flags7
        bita    #FLAG_MOVEABLE
        beq     4$
        tst     9,x                     ; dX=0?
        bne     3$
        lda     9,y                     ; dX2
        sta     9,x                     ; dX1
3$:     tst     10,x                    ; dY=0?
        bne     4$
        lda     10,y                    ; dY2
        sta     10,x                    ; dY1
4$:     lda     *z80_h                  ; new dZ
        jsr     adj_d_for_out_of_bounds
        sta     *z80_h                  ; new dZ
        beq     9$
        bra     2$
5$:     leay    32,y
        decb
        bne     1$
9$:     rts
        
do_objs_intersect_on_x:
        lda     4,x                     ; w1
        adda    4,y                     ; +w2
        sta     *z80_d                  ; (w1+w2)
        lda     1,x                     ; x1
        adda    *z80_c                  ; +dX
        suba    1,y                     ; -x2
        bpl     1$
        nega
1$:     suba  *z80_d
        rts

do_objs_intersect_on_y:
        lda     5,x                     ; d1
        adda    5,y                     ; +d2
        sta     *z80_d                  ; (d1+d2)
        lda     2,x                     ; d1
        adda    *z80_l                  ; +dY
        suba    2,y                     ; -d2
        bpl     1$
        nega
1$:     suba  *z80_d
        rts
                        
do_objs_intersect_on_z:
; optimise?
        pshs    b
        lda     3,x                     ; z1
        adda    *z80_h                  ; +dZ
        suba    3,y                     ; -z2
        bpl     2$
        nega
        ldb     6,x                     ; h1
1$:     stb     *z80_d
        suba    *z80_d
        puls    b
        rts
2$:     ldb     6,y                     ; h2
        bra     1$

adj_dX_for_out_of_bounds:
        lda     12,x                    ; flags12
        anda    #MASK_ENTERING_SCRN
        bne     dX_ok
        lda     7,x                     ; flags7
        bita    #FLAG_NEAR_ARCH
        bne     dX_ok
1$:     lda     1,x                     ; X
        adda    *z80_c                  ; +dX
        suba    #128
        bcc     2$
        nega
2$:     adda    4,x                     ; +width
        cmpa    room_size_X             ; < room width?
        bcs     dX_ok
        lda     12,x                    ; flags12
        ora     #FLAG_X_OOB
        sta     12,x                    ; flags12
        lda     *z80_c
        jsr     adj_d_for_out_of_bounds
        sta     *z80_c
        bne     1$
dX_ok:
        rts

adj_dY_for_out_of_bounds:
        lda     12,x                    ; flags12
        anda    #MASK_ENTERING_SCRN
        bne     dY_ok
        lda     7,x                     ; flags7
        bita    #FLAG_NEAR_ARCH
        bne     dY_ok
1$:     lda     2,x                     ; Y
        adda    *z80_l                  ; +dY
        suba    #128
        bcc     2$
        nega
2$:     adda    5,x                     ; +height
        cmpa    room_size_Y             ; < room width?
        bcs     dY_ok
        lda     12,x                    ; flags12
        ora     #FLAG_Y_OOB
        sta     12,x                    ; flags12
        lda     *z80_l
        jsr     adj_d_for_out_of_bounds
        sta     *z80_l
        bne     1$
dY_ok:
        rts

calc_2d_info:
        jsr     calc_pixel_XY
        jsr     flip_sprite             ; ->U
        lda     26,x                    ; pixel_x
        anda    #7                      ; bit offset
        ldb     ,u+                     ; sprite width
        tsta
        beq     1$
        incb
1$:     andb    #0x0f                   ; new width
        stb     24,x                    ; data_width_bytes
        ldb     ,u                      ; sprite height
        stb     25,x                    ; data_height_lines
        rts

set_draw_objs_overlapped:
        ldy     #graphic_objs_tbl
        bsr     calc_2d_info
        ldb     #MAX_OBJS
        lda     26,x                    ; pixel_x
        lsra
        lsra
        lsra
        sta     *z80_l
        lda     30,x                    ; old_pixel_x
        lsra
        lsra
        lsra
        sta     *z80_h
        cmpa    *z80_l
        bcs     1$
        lda     *z80_l
1$:     sta     *z80_e                  ; left-most byte
        lda     *z80_l                  ; byte addr
        adda    24,x                    ; +data_width_bytes
        sta     *z80_l
        lda     *z80_h                  ; old byte addr
        adda    28,x                    ; +old_data_width_bytes
        cmpa    *z80_l
        bcc     2$
        lda     *z80_l
2$:     suba    *z80_e
        sta     *z80_d                  ; old & new width
        lda     27,x                    ; pixel_y
        cmpa    31,x                    ; old_pixel_y
        bcs     3$
        lda     31,x
3$:     sta     *z80_l                  ; top-most
        lda     27,x                    ; pixel_y
        adda    25,x                    ; +data_height_lines
        sta     *z80_h
        lda     31,x                    ; old_pixel_y
        adda    29,x                    ; +old_data_height_lines
        cmpa    *z80_h
        bcc     4$
        lda     *z80_h
4$:     suba    *z80_l
        sta     *z80_h                  ; old & new height

test_overlap_obj:
        tst     0,y                     ; graphic_no
        beq     3$
        lda     7,y                     ; flags7
        bita    #FLAG_DRAW
        bne     3$
        lda     26,y                    ; pixel_x
        lsra
        lsra
        lsra
        suba    *z80_e
        bcs     4$
        cmpa    *z80_d
1$:     bcc     3$
        lda     27,y                    ; pixel_y
        suba    *z80_l
        bcs     5$
        cmpa    *z80_h
2$:     bcc     3$
        lda     7,y                     ; flags7
        ora     #FLAG_DRAW
        sta     7,y
3$:     leay    32,y
        decb
        bne     test_overlap_obj
        rts

4$:     nega
        cmpa    24,y                    ; data_width_bytes
        bra     1$

5$:     nega
        cmpa    25,y                    ; data_height_lines
        bra     2$

; player (human top half)
upd_32_to_47:
        jsr     adj_m8_m12
        bra     upd_player_top

; player (wulf top half)
upd_64_to_79:
        jsr     adj_m12_m12

; copies most information from bottom half object
; handles randomly looking around
upd_player_top:
        tst     all_objs_in_cauldron
        bne     1$
        lda     13,x                    ; flags13
        bita    #FLAG_DEAD
        lbne    init_death_sparkles
1$:     tfr     x,y
        leay    -32,y                   ; bottom half
        ldb     #1
2$:     lda     b,y
        sta     b,x
        incb
        cmpb    #8
        bne     2$                      ; copy x,y,z,w,d,h,flags
        clr     6,x                     ; height
        lda     7,x                     ; flags7
        ora     #FLAG_IGNORE_3D
        sta     7,x                     ; flags7
        lda     13,x                    ; flags13
        anda    #MASK_LOOK_CNT
        beq     3$
        dec     13,x                    ; dec counter
        bra     loc_CE27
3$:     lda     seed_3
        cmpa    #2
        bcs     loc_CE33
        cmpa    #-2
        bcc     loc_CE40
        lda     0,y                     ; graphic_no (bottom)

set_top_sprite:
        adda    #16
        sta     0,x                     ; graphic_no
loc_CE27:
        lda     3,y                     ; Z (bottom)
        adda    #12
        sta     3,x                     ; Z (top)
        jsr     set_draw_objs_overlapped
        rts

loc_CE33:
        lda     0,y                     ; graphic_no (bottom)
        anda    #0xf8
        ora     #6
loc_CE3A:
        ldb     #8
        stb     13,x                    ; look for 8 iterations
        bra     set_top_sprite

loc_CE40:
        lda     0,y                     ; grahic_no (bottom)
        anda    #0xf8
        ora     #7
        bra     loc_CE3A
        
save_2d_info:
        lda     24,x                    ; data_width_bytes
        sta     28,x                    ; old_data_width_bytes
        lda     25,x                    ; data_height_lines
        sta     29,x                    ; old_data_height_lines
        lda     26,x                    ; pixel_x
        sta     30,x                    ; old_pixel_x
        lda     27,x                    ; pixel_y
        sta     31,x                    ; old_pixel_y
        rts
        
list_objects_to_draw:
        pshs    x
        ldb     #MAX_OBJS
        ldx     #graphic_objs_tbl
        ldy     #objects_to_draw
        clr     *z80_c
1$:     lda     0,x                     ; graphic_no
        beq     2$                      ; null
.ifndef BUILD_OPT_ALWAYS_RENDER_ALL      
        lda     7,x                     ; flags7
        bita    #FLAG_DRAW
        beq     2$                      ; not set
.endif
        lda     *z80_c
        sta     ,y+                     ; store object index
2$:     inc     *z80_c
        leax    32,x                    ; next object
        decb
        bne     1$
        lda     #0xff
        sta     ,y                      ; end of list
        puls    x
        rts

objects_to_draw:
        .ds MAX_DRAW

calc_display_order_and_render:
        clr     rendered_objs_cnt
        pshs    x,y
process_remaining_objs:
        ldu     #objects_to_draw
1$:     lda     ,u+
        cmpa    #0xff
        lbeq    render_done
        bita    #(1<<7)                 ; already rendered?
        bne     1$                      ; yes, loop
        jsr     get_ptr_object          ; ->X
.ifndef BUILD_OPT_NO_Z_ORDER
        stu     render_obj_1
loc_CEDB:
        lda     ,u+
        cmpa    #0xff
        lbeq    render_obj_no1
        bita    #(1<<7)                 ; already rendered?
        bne     loc_CEDB                ; yes, loop
        tfr     x,y
        jsr     get_ptr_object          ; ->X
        stu     render_obj_2
        exg     x,y                     ; Y=obj2
        sty     *tmp_word
        cmpx    *tmp_word               ; same object?
        beq     loc_CEDB                ; yes, loop
        clrb
        lda     3,y                     ; z2
        adda    6,y                     ; +h2
        sta     *z80_l                  ; (z2+h2)
        lda     3,x                     ; z1
        suba    *z80_l                  ; -(z2+h2)
        bcc     2$
        lda     3,x                     ; z1
        adda    6,x                     ; +h1
        sta     *z80_l                  ; (z1+h1)
        lda     3,y                     ; z2
        suba    *z80_l                  ; -(z1+h1)
        bcs     1$
        incb
1$:     incb
2$:     lda     2,y                     ; y2
        adda    5,y                     ; +d2
        sta     *z80_l                  ; (y2+d2)
        lda     2,x                     ; y1
        suba    5,x                     ; -d2
        suba    *z80_l                  ; -(y2+d2)
        bcc     4$
        lda     2,x                     ; y1
        adda    5,x                     ; +d1
        sta     *z80_l                  ; (y1+d1)
        lda     2,y                     ; y2
        suba    5,y                     ; -d2
        suba    *z80_l                  ; -(y1+d1)
        bcs     3$
        addb    #3
3$:     addb    #3
4$:     lda     1,y                     ; x2
        adda    4,y                     ; +w2
        sta     *z80_l                  ; (x2+w2)
        lda     1,x                     ; x1
        suba    4,x                     ; -w1
        suba    *z80_l                  ; -(x2+w2)
        bcc     6$
        lda     1,x                     ; x1
        adda    4,x                     ; +w1
        sta     *z80_l                  ; (x1+w1)
        lda     1,y                     ; x2
        suba    4,y                     ; -w2
        suba    *z80_l                  ; -(x1+w1)
        bcs     5$
        addb    #9
5$:     addb    #9
6$:     pshs    u
        ldu     #off_CF69
        jmp     jump_to_tbl_entry

off_CF69:
        .dw continue_1
        .dw continue_1
        .dw continue_1
        .dw d_3467121516
        .dw d_3467121516
        .dw continue_1
        .dw d_3467121516
        .dw d_3467121516
        .dw continue_1
        .dw continue_1
        .dw continue_2
        .dw continue_2
        .dw d_3467121516
        .dw objs_coincide
        .dw continue_2
        .dw d_3467121516
        .dw d_3467121516
        .dw continue_1
        .dw continue_1
        .dw continue_2
        .dw continue_2
        .dw continue_1
        .dw continue_2
        .dw continue_2
        .dw continue_1
        .dw continue_1
        .dw continue_1

continue_1:
        puls    u
        jmp     loc_CEDB

continue_2:
        puls    u
        jmp     loc_CEDB
        
d_3467121516:
        puls    u
        ldu     render_obj_2
        lda     -1,u
        sta     *z80_c
        ldu     #render_list
1$:     lda     ,u
        cmpa    #0xff                   ; empty entry?
        beq     2$                      ; yes, exit
        cmpa    *z80_c                  ; already listed?
        beq     3$                      ; yes, go
        leau    1,u                     ; next entry
        bra     1$                      ; loop
2$:     lda     *z80_c                  ; index
        sta     ,u+                     ; add to list
        lda     #0xff                   ; flag next empty
        sta     ,u
        tfr     y,x                     ; obj2->obj1
        ldu     render_obj_2
        stu     render_obj_1
        ldu     #objects_to_draw
        jmp     loc_CEDB                ; go again
3$:     ldu     #objects_to_draw
4$:     lda     ,u+
        cmpa    #0xff                   ; end of list?
        lbeq    process_remaining_objs  ; no, loop
        cmpa    *z80_c                  ; what we're looking for?
        bne     4$                      ; no, loop
        tfr     y,x                     ; obj2->obj1
        bra     render_obj

objs_coincide:
        puls    u
        ldb     #187                    ; sparkles
        lda     0,x                     ; graphic_no
        suba    #0x60
        cmpa    #7
        bcc     1$
        stb     0,x                     ; graphic_no (sparkles)
1$:     lda     0,y                     ; graphic_no
        suba    #0x60
        cmpa    #7
        bcc     2$
        stb     0,y                     ; graphic_no (sparkles)
2$:     jmp     loc_CEDB


render_obj_no1:
        ldu     render_obj_1
.endif ; BUILD_OPT_NO_Z_ORDER

render_obj:
        lda     -1,u
        ora     #(1<<7)                 ; flag as rendered
        sta     -1,u
        lda     #0xff
        sta     render_list
        inc     rendered_objs_cnt
        jsr     calc_pixel_XY_and_render
        jmp     process_remaining_objs
render_done:
        puls    x,y
        rts

render_list:
        .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

; returns B=input
check_user_input:
        pshs    x
        clrb
        lda     all_objs_in_cauldron
        ora     obj_dropping_into_cauldron
        bne     finished_input
; some non-keyboard stuff
keyboard:
        lda     #~(1<<2)
        jsr     read_port
        bita    #(1<<3)                 ; 'Z'?
        beq     1$                      ; no, skip
        orb     #INP_LEFT
1$:     lda     #~(1<<0)
        jsr     read_port
        bita    #(1<<3)                 ; 'X'?
        beq     2$                      ; no, skip
        orb     #INP_RIGHT
2$:     lda     #~(1<<1)
        jsr     read_port
        bita    #(1<<0)                 ; 'A'?
        beq     3$                      ; no, skip
        orb     #INP_FORWARD
3$:     bita    #(1<<2)                 ; 'Q'?
        beq     4$                      ; no, skip
        orb     #INP_JUMP
4$:     bita    #(1<<4)                 ; '1'?
        beq     finished_input
        orb     #INP_PICKUP_DROP
finished_input:
        stb     user_input
        puls    x
        rts
        
lose_life:
        ldu     #plyr_spr_1_scratchpad
        ldy     #graphic_objs_tbl
        tfr     y,x
        ldb     #64
1$:     lda     ,u+
        sta     ,y+
        decb
        bne     1$
        clr     transform_flag_graphic
        dec     lives
        lbmi    game_over
        lda     sun_moon_scratchpad
        rora
        rora
        rora
        rora                            ; extra ROR for 6809
        anda    #0x20                   ; day/night
        sta     *z80_c
        lda     16,x                    ; plyr graphic no
        anda    #0x1f
        adda    *z80_c
        sta     16,x
        lda     0x30,x
        anda    #0x0f
        adda    *z80_c
        adda    #32
        sta     0x30,x
        rts                

plyr_spr_1_scratchpad:
        .db 0, 0, 0, 0, 0, 0, 0, 0
start_loc_1:
        .db 0, 0, 0, 0
flags12_1:
        .db 0, 0, 0, 0
byte_D171:
        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

plyr_spr_2_scratchpad:
        .db 0, 0, 0, 0, 0, 0, 0, 0
start_loc_2:
        .db 0, 0, 0, 0, 0, 0, 0, 0
byte_D191:
        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

plyr_spr_init_data:
        .db 0x78, 0x80, 0x80, 0x80, 5, 5, 0x17, 0x1C
        .db 0x78, 0x80, 0x80, 0x8C, 5, 5, 0, 0x1E

init_start_location:
        ldx     #plyr_spr_init_data
        ldy     #plyr_spr_1_scratchpad
        ldb     #8
1$:     lda     ,x+
        sta     ,y+
        decb
        bne     1$
        ldy     #plyr_spr_2_scratchpad
        ldb     #8
2$:     lda     ,x+
        sta     ,y+
        decb
        bne     2$
        lda     #18                     ; graphic_no
        sta     byte_D171
        lda     #34                     ; graphic_no
        sta     plyr_spr_2_scratchpad+16
        lda     seed_1
        anda    #3
        ldu     #start_locations
        lda     a,u                     ; get entry
.ifdef START_LOC
        lda     #START_LOC              ; override
.endif
        sta     start_loc_1
        sta     start_loc_2
        rts

start_locations:
        .db 0x2F, 0x44, 0xB3, 0x8F

build_screen_objects:
        tst     not_1st_screen
        beq     1$
        jsr     update_special_objs
1$:     pshs    x
        jsr     clear_scrn_buffer
        puls    x
        jsr     retrieve_screen
        jsr     find_special_objs_here
        jsr     adjust_plyr_xyz_for_room_size
        clra
        sta     portcullis_moving
        sta     portcullis_move_cnt
        sta     ball_bounce_height
        sta     is_spike_ball_dropping
        lda     #1
        sta     render_status_info
        lda     graphic_objs_tbl+8      ; current screen
        anda    #1
        sta     disable_spike_ball_drop
        bsr     flag_room_visited
        rts

flag_room_visited:
        rts

transfer_sprite:
        lda     ,u+
        sta     0,x                     ; graphic no
        lda     ,u+
        sta     7,x                     ; flags7
        lda     ,u+
        sta     26,x                    ; pixel_x
        lda     ,u+
        sta     27,x                    ; pixel_y
        rts

transfer_sprite_and_print:
        bsr     transfer_sprite
        pshs    u
        jsr     print_sprite
        puls    u
        rts

display_panel:
        ldx     #sprite_scratchpad
        ldu     #panel_data
        bsr     transfer_sprite
        ldy     #0xf810                 ; x+=16, y-=8
        ldb     #5
        jsr     multiple_print_sprite
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite
        ldy     #0x0810                 ; x+=16, y+=8
        ldb     #5
        jsr     multiple_print_sprite
        bsr     transfer_sprite_and_print
        bra     transfer_sprite_and_print

panel_data:
        .db 0x86, 0, 0x10, 0x34
        .db 0x87, 0, 0xF0, 0
        .db 0x88, 0, 0x90, 4
        .db 0x86, 0x40, 0xA0, 0x14
        .db 0x87, 0x40, 0, 0
        .db 0x88, 0x40, 0x60, 4

print_border:
        ldx     #sprite_scratchpad
        ldu     #border_data
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite
        ldy     #0x0008                 ; x+=8, y+=0
        ldb     #24
        jsr     multiple_print_sprite
        bsr     transfer_sprite
        ldb     #24
        jsr     multiple_print_sprite
        bsr     transfer_sprite
        ldy     #0x0100                 ; x+=0, y+=16
        ldb     #128
        jsr     multiple_print_sprite
        jsr     transfer_sprite
        ldb     #128
        jmp     multiple_print_sprite
                
border_data:
        .db 0x89, 0, 0, 0xA0
        .db 0x89, 0x40, 0xE0, 0xA0
        .db 0x89, 0xC0, 0xE0, 0
        .db 0x89, 0x80, 0, 0
        .db 0x8B, 0, 0x20, 0xA8
        .db 0x8B, 0, 0x20, 0
        .db 0x8A, 0, 0, 0x20
        .db 0x8A, 0, 0xE8, 0x20

colour_panel:
        ;jmp     fill_window
        rts

colour_sun_moon:
        ;jmp     fill_window
        rts

adjust_plyr_xyz_for_room_size:
        lda     room_size_X
        suba    #2
        sta     *z80_l
        lda     room_size_Y
        suba    #2
        sta     *z80_h
        lda     1,x                     ; X
        beq     enter_arch_e
        inca
        beq     enter_arch_w
        lda     2,x                     ; Y
        beq     enter_arch_n
        inca
        beq     enter_arch_s
        rts                                                        

enter_arch_s:
        ldb     #200
        bsr     adjust_plyr_Z_for_arch
        lda     #128        
        suba    *z80_h                  ; -(room_size_Y-2)
        suba    5,x                     ; -depth
adjust_plyr_y:
        sta     2,x                     ; Y
copy_spr_1_xy_2:
        lda     7,x                     ; flags7
        ora     #FLAG_DRAW
        sta     7,x                     ; flags7
        lda     0x27,x                  ; flags7 (top half)
        ora     #FLAG_DRAW
        sta     0x27,x                  ; flags7 (top half)
        lda     1,x                     ; X
        sta     0x21,x                  ; X (to half)
        lda     2,x                     ; Y
        sta     0x22,x                  ; Y (top half)
        rts

enter_arch_n:
        ldb     #81
        bsr     adjust_plyr_Z_for_arch
        lda     *z80_h                  ; room_size_Y-2
        adda    #128                    ; +128
        adda    5,x                     ; +depth
        bra     adjust_plyr_y

enter_arch_w:
        ldb     #174
        bsr     adjust_plyr_Z_for_arch
        lda     #128
        suba    *z80_l                  ; -(room_size_X-2)
        suba    4,x                     ; -width        
adjust_plyr_x:
        sta     1,x                     ; X
        bra     copy_spr_1_xy_2

enter_arch_e:
        ldb     #55
        bsr     adjust_plyr_Z_for_arch
        lda     *z80_l                  ; room_size_X-2
        adda    #128                    ; +128
        adda    4,x                     ; +width
        bra     adjust_plyr_x

adjust_plyr_Z_for_arch:
        stb     *z80_c                  ; offset
        ldy     #other_objs_here
        ldb     #4
1$:     lda     0,y                     ; graphic_no
        cmpa    #6                      ; arch?
        bcc     9$                      ; no, return
        lda     1,y                     ; X
        adda    2,y                     ; +Y
        cmpa    *z80_c                  ; offset
        beq     adj_plyr_Z
        leay    64,y
        decb
        bne     1$
9$:     rts

adj_plyr_Z:
        lda     3,y                     ; Z
        sta     3,x                     ; plyr Z (bottom)
        adda    #12
        sta     0x23,x                  ; plyr Z (top)
        rts

; A=index
; return in X
; *** optimise???
get_ptr_object:
        anda    #0x7f
        ldb     #32
        mul
        ldx     #graphic_objs_tbl
        leax    d,x
        rts

retrieve_screen:
        lda     8,x
        sta     *screen
        pshs    x
        ldy     #other_objs_here
        ldu     #location_tbl

find_screen:
        lda     ,u+                     ; location id
        cmpa    *screen                 ; same as player?
        beq     found_screen
        lda     ,u                      ; #bytes
        leau    a,u                     ; next location
        cmpu    #eolt                   ; end of table?
        blt     find_screen
        tfr     u,y

zero_end_of_graphic_objs_tbl:
        cmpy    #eod
        beq     9$
        ldb     #32
        jsr     zero_Y
        bra     zero_end_of_graphic_objs_tbl
9$:     puls    x
        rts

found_screen:
        ldb     ,u+                     ; #bytes
        lda     ,u                      ; attributes
        anda    #7
        ora     #0x40                   ; bright
        sta     curr_room_attrib
        lda     ,u+                     ; attributes
        pshs    u                       ; location data
        rora
        rora
        rora
        anda    #0x1f                   ; room size
        sta     *z80_c
        adda    *z80_c
        adda    *z80_c                  ; x3
        ldu     #room_size_tbl
        leau    a,u                     ; ptr entry
        lda     ,u+
        sta     room_size_X
        lda     ,u+
        sta     room_size_Y
        lda     ,u
        sta     room_size_Z
        decb
        decb
        puls    u                       ; location data
next_bg_obj:
        lda     ,u+                     ; background type
        cmpa    #0xff                   ; done all bkgnd?
        beq     find_fg_objs            ; yes, go
        ldx     #background_type_tbl
        asla                            ; word offset
        ldx     a,x
next_bg_obj_sprite:
        pshs    b                       ; bytes left
        ldb     #8
1$:     lda     ,x+                     ; byte from object
        sta     ,y+                     ; copy to graphic_objs_tbl
        decb
        bne     1$
        lda     *screen                 ; current screen
        sta     ,y+                     ; set object screen
        ldb     #23
        jsr     zero_Y
        puls    b                       ; bytes left
        tst     ,x                      ; done object?
        bne     next_bg_obj_sprite      ; no, loop
        decb                            ; any bytes left?
        bne     next_bg_obj             ; yes, loop
        bra     zero_end_of_graphic_objs_tbl

find_fg_objs:
;        jmp     zero_end_of_graphic_objs_tbl
        decb                            ; adjust for $FF
next_fg_obj:                                                    
        lda     ,u                      ; block/count
        anda    #7                      ; count-1
        inca
        sta     *z80_c                  ; count
        lda     ,u+                     ; block/count
        decb                            ; adjust byte count
        pshs    a
        lda     ,u+                     ; location (x/y/z)
        sta     *z80_d
        puls    a
        lsra
        lsra
        anda    #0x3e                   ; block x2
        ldx     #block_type_tbl
        ldx     a,x                     ; ptr object
next_fg_obj_in_count:
        pshs    x                       ; ptr block type data
next_fg_obj_sprite:
        lda     ,x+
        sta     0,y                     ; graphic_no
        lda     ,x+
        sta     4,y                     ; width
        lda     ,x+
        sta     5,y                     ; depth
        lda     ,x+
        sta     6,y                     ; height
        lda     ,x+
        sta     7,y                     ; flags
        lda     *screen                 ; screen
        sta     8,y                     ; screen
        lda     ,x                      ; offsets
        lsla
        lsla
        lsla
        anda    #8                      ; x1 in bit3
        sta     *z80_e
        lda     *z80_d                  ; location (x/y/z)
        lsla
        lsla
        lsla
        lsla
        anda    #0x70                   ; x*16
        adda    *z80_e                  ; x*16+x1*8
        adda    #72                     ; x*16+x1*8+72
        sta     1,y                     ; X
        lda     ,x                      ; offsets
        lsla
        lsla
        anda    #8                      ; y1 in bit3
        sta     *z80_e
        lda     *z80_d                  ; location (x/y/z)
        lsla
        anda    #0x70                   ; y*16
        adda    *z80_e                  ; y*16+y1*8
        adda    #72                     ; y*16+y1*8+72
        sta     2,y                     ; Y
        lda     *z80_d                  ; location (x/y/z)
; I think we can do better than the Z80 code here
        lsra
        lsra
        lsra
        anda    #0x18                   ; z*8
        sta     *z80_e
        lsra                            ; z*4
        adda    *z80_e                  ; z*12
        adda    ,x+                     ; z*12+z1*4+junk
        anda    #0xfc                   ; z*12+z1*4
        sta     *z80_e
        lda     room_size_Z
        adda    *z80_e
        sta     3,y                     ; Z
        leay    9,y                     ; skip to dX
        pshs    b
        ldb     #23
1$:     clr     ,y+
        decb
        bne     1$
        puls    b
        tst     ,x                      ; next entry
        lbne    next_fg_obj_sprite
        puls    x                       ; ptr block type data
        decb                            ; bytes remaining
        beq     loc_D4EA
        dec     *z80_c
        lbeq    next_fg_obj
        lda     ,u+                     ; next location (x/y/z)
        sta     *z80_d
        jmp     next_fg_obj_in_count

loc_D4EA:
        jmp     zero_end_of_graphic_objs_tbl

;add_HL_A:
;        rts

;HL_equals_DE_x_A:
;        rts
        
zero_Y:
        clr     ,y+
        decb
        bne     zero_Y
        rts

fill_DE:
        rts

handle_pause:
        lda     #~(1<<7)
        jsr     read_port
        bita    #(1<<3)
        bne     debounce_space_press
        rts
debounce_space_press:
        lda     #~(1<<7)
        jsr     read_port
        bita    #(1<<3)
        bne     debounce_space_press
wait_for_space:
        lda     #~(1<<7)
        jsr     read_port
        bita    #(1<<3)
        beq     wait_for_space
debounce_space_release:
        lda     #~(1<<7)
        jsr     read_port
        bita    #(1<<3)
        bne     debounce_space_release
        rts

clr_mem:
        clra
clr_byte:
        sta     ,x+
        leay    -1,y
        bne     clr_byte
        rts

clr_bitmap_memory:
        ldx     #coco_vram
        ldy     #0x1800
        bra     clr_mem
        
clr_attribute_memory:
        bra     clr_byte
        
fill_attr:
; nothing to do on the coco
        rts

clear_scrn:
;       bsr     clr_attribute_memory
        bra     clr_bitmap_memory

clear_scrn_buffer:
        ldy     #0x1800
        ldx     #vidbuf
        bra     clr_mem
                                                                                
update_screen:
        pshs    b,x,y
        ldx     #vidbuf+0x1800-32
        ldy     #coco_vram
        ldb     #192
1$:     pshs    b
        ldb     #32
2$:     lda     ,x                      ; source byte (vidbuf)
        clr     ,x+                     ; clear vidbuf
        sta     ,y+                     ; destination (vram)
        decb
        bne     2$
        leax    -64,x
        puls    b
        decb
        bne     1$
        puls    b,x,y
        rts

render_dynamic_objects:
        clr     objs_wiped_cnt
        pshs    x
        tst     render_status_info
        lbne    loc_D653
        ldu     #objects_to_draw
        stu     tmp_objects_to_draw
wipe_next_object:
        ldu     tmp_objects_to_draw
        lda     ,u+
        stu     tmp_objects_to_draw
        cmpa    #0xff                   ; end of list?
        lbeq    loc_D653                ; yes, exit
        jsr     get_ptr_object          ; ->X
        lda     7,x                     ; flags7
        bita    #FLAG_WIPE
        beq     wipe_next_object
        anda    #~FLAG_WIPE
        sta     7,x                     ; flags7
        lda     26,x                    ; pixel_x
        suba    30,x                    ; old_pixel_x
        lbcs    loc_D649
        lda     30,x                    ; old_pixel_x
        sta     *z80_c                  ; left-most pixel
loc_D5DB:
        lda     30,x                    ; old_pixel_x
        lsra
        lsra
        lsra                            ; byte
        adda    28,x                    ; old_data_width_bytes
        sta     *z80_e
        lda     26,x                    ; pixel_x
        lsra
        lsra
        lsra                            ; byte
        adda    24,x                    ; data_width_bytes
        cmpa    *z80_e
        bcs     1$
        sta     *z80_e
1$:     lda     *z80_c
        lsra
        lsra
        lsra                            ; old/pixel_x byte offset
        sta     *z80_b
        lda     *z80_e
        suba    *z80_b
        sta     *z80_h                  ; number of bytes to wipe
        lda     27,x                    ; pixel_y
        suba    31,x                    ; < old_pixel_y?
        bcs     loc_D64E                ; yes
        lda     31,x                    ; old_pixel_y
        sta     *z80_b                  ; lowest y
loc_D60B:
        lda     31,x                    ; old_pixel_y
        adda    29,x                    ; data_height_lines
        sta     *z80_e
        lda     27,x
        adda    25,x
        cmpa    *z80_e
        bcc     2$
        lda     *z80_e
2$:     suba    *z80_b
        sta     *z80_l
        lda     *z80_b
        cmpa    #192                    ; off bottom of screen?
        lbcc    wipe_next_object        ; yes, skip
        adda    *z80_l
        suba    #192
        bcs     3$
        nega
        adda    *z80_l
        sta     *z80_l                  ; number of lines to wipe
3$:     lda     *z80_b                  ; Y (lowest)
        ldb     *z80_c                  ; X (left-most)
        jsr     calc_vram_addr          ; ->U
        tfr     u,y
        jsr     calc_vidbuf_addr        ; ->U
        inc     objs_wiped_cnt
        ldb     *z80_h                  ; bytes
        lda     *z80_l                  ; lines
        pshs    u,y,d
        tfr     u,y                     ; dest
        tfr     d,u                     ; lines/bytes
        clra
        jsr     fill_window
        jmp     wipe_next_object

loc_D649:
        ldb     26,x                    ; pixel_x
        stb     *z80_c
        jmp     loc_D5DB

loc_D64E:
        ldb     27,x                    ; pixel_y
        stb     *z80_b
        bra     loc_D60B

loc_D653:
        jsr     calc_display_order_and_render
        jsr     print_sun_moon
        jsr     display_objects_carried
        lda     objs_wiped_cnt
        adda    rendered_objs_cnt
        sta     rendered_objs_cnt
4$:     tst     objs_wiped_cnt
        beq     9$
        dec     objs_wiped_cnt
        puls    u                       ; lines/bytes
        puls    y                       ; dest (vram)
        puls    x                       ; src (vidbuf)
        bsr     blit_to_screen
        bra     4$
9$:     puls    x
        rts

; X=src, y=dst, U=lines,bytes
blit_to_screen:
        stu     *lines
        ldb     *lines
1$:     pshs    b,x,y
        ldb     *bytes
2$:     lda     ,x+
        sta     ,y+
        decb
        bne     2$
        puls    b,x,y
        leax    32,x
        leay    -32,y
        decb
        bne     1$
        rts        

build_lookup_tbls:
; first is table of bit-reversed values
        ldx     #reverse_tbl+0x80
        clrb
        stb     *z80_c                  ; index
1$:     pshs    b                       ; counter
        lda     *z80_c                  ; get index
        rola
        rorb
        rola
        rorb
        rola
        rorb
        rola
        rorb
        rola
        rorb
        rola
        rorb
        rola
        rorb
        rola
        rorb
        lda     *z80_c
        inc     *z80_c
        stb     a,x                     ; reversed
        puls    b
        decb                            ; done 256?
        bne     1$                      ; no loop
; 2nd is table of shifted values (2 bytes)
; - 1st run seeds low values
        ldb     #0
        clr     *z80_c
2$:     lda     *z80_c
        ldx     #shift_tbl+0x80
        sta     a,x
        leax    0x100,x
        clr     a,x
        inc     *z80_c
        decb
        bne     2$
; next 7 runs shift the previous entries
        ldb     #7
        ldu     #shift_tbl+0x80
3$:     pshs    b
        ldb     #0
        clr     *z80_c
4$:     pshs    b
        lda     *z80_c
        tfr     u,x                     ; base for this shift
        ldb     a,x                     ; byte #1
        pshs    b
        leax    0x100,x
        ldb     a,x                     ; byte #2
        puls    a
        lsra
        rorb
        pshs    d                       ; b then a
        lda     *z80_c
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #1 shifted
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #2 shifted
        inc     *z80_c
        puls    b
        decb
        bne     4$
        leau    0x200,u                 ; base for next shift
        puls    b
        decb
        bne     3$
        rts

calc_pixel_XY:
        lda     1,x                     ; X
        adda    2,x                     ; +Y
        suba    #128                    ; -128
        adda    18,x                    ; pixel_x_adj
        sta     26,x                    ; pixel_x
        lda     2,x                     ; Y
        suba    1,x                     ; -X
        adda    #128                    ; +128
        lsra
        adda    3,x                     ; +Z
        suba    #104                    ; -104
        adda    19,x                    ; pixel_y_adj
        sta     27,x                    ; pixel_y
        cmpa    #192
        rts

; returns ptr sprite data in U
flip_sprite:
        ldb     ,x                      ; graphic no
        ldu     #sprite_tbl
        clra
        aslb
        rola
        ldu     d,u                     ; sprite data addr
        lda     ,u                      ; flip & width
        lbne    vflip_sprite_data       ; not null sprite
        leas    2,s                     ; exit from caller
        rts

calc_pixel_XY_and_render:
        lda     0,x                     ; graphic_no
        cmpa    #1
        bne     1$
        clr     0,x                     ; graphic_no
        rts
1$:     lda     7,x                     ; flags7
        anda    #~FLAG_DRAW
        sta     7,x                     ; flags7
        jsr     calc_pixel_XY
        bcs     print_sprite
        rts

; sprites are actually vflipped in memory
; so render them directly to buffer
; - buffer is vflipped w.r.t. video
print_sprite:
        bsr     flip_sprite             ; U=ptr sprite data
        lda     26,x                    ; pixel_x
        anda    #7                      ; bit offset
        pshs    cc
        lsla                            ; x2
        adda    #>shift_tbl
        ldb     #0x80
        std     *offset
        lda     ,u+                     ; width
        anda    #0x07
        sta     *width
        puls    cc                      ; bit offset &7 flags
        beq     0$
        inca
0$:     sta     24,x                    ; width_bytes
        lda     ,u+                     ; height
        sta     25,x                    ; height_lines
        adda    27,x                    ; pixel_y
        suba    #192                    ; off screen?
        bcs     1$                      ; no, skip
        nega
        adda    25,x
        sta     25,x                    ; adjust height lines
1$:     ldb     26,x                    ; pixel_x     
        lda     27,x                    ; pixel_y
        tfr     u,y
        jsr     calc_vidbuf_addr        ; ->U
        exg     u,y
; this next bit requires some serious optimisation
;       X = object
;       Y = video buffer address
;       U = sprite data
        ldb     25,x                    ; height_lines
2$:     pshs    b
        ldb     *width                  ; width_bytes
        pshs    x
3$:     pshs    b

        ldx     *offset
        lda     0,u                     ; read mask
        lda     a,x                     ; shifted mask byte 1
        coma
        anda    ,y                      ; from video
        ldb     1,u                     ; read data
        ora     b,x                     ; add shifted data byte 1
        sta     ,y+                     ; write back to video

        leax    0x100,x
        lda     0,u                     ; read mask
        lda     a,x                     ; shifted mask byte 2
        coma
        anda    ,y                      ; from video
        ldb     1,u                     ; read data
        ora     b,x                     ; add shifted data byte 2
        sta     ,y                      ; write back to video

        leau    2,u
        puls    b
        decb
        bne     3$
        puls    x
        lda     #32
        suba    *width
        leay    a,y                     ; next line
        puls    b
        decb
        bne     2$
        rts

; A=Y, B=X
; addr = ((y<<8)>>3)|(x>>3)
; returns vidbuf address in U
calc_vidbuf_addr:
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                            ; D=offset
        tfr     d,u
        leau    vidbuf,u
        rts

; A=Y, B=X (preserved)
; addr = (((191-y)<<8)>>3)|(x>>3)
; returns vidbuf address in U
calc_vram_addr:
        pshs    d
        nega
        adda    #191
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                            ; D=offset
        tfr     d,u
        leau    coco_vram,u
        puls    d
        rts

calc_attrib_addr:
        rts
        
vflip_sprite_data:
        pshs    y,u
        eora    7,x                     ; flags7
        anda    #FLAG_VFLIP             ; same?
        beq     hflip_sprite_data       ; yes, skip
        lda     ,u
        eora    #FLAG_VFLIP
        sta     ,u+
        anda    #0x0f                   ; width_bytes
        sta     *width
        lsla                            ; x2 for mask bytes
        ldb     ,u+                     ; height_lines
        stb     *height
        decb                            ; (h-1)
        mul                             ; w*2*(h-1)=last line
        tfr     u,y
        leay    d,y                     ; y=last line
        ldb     *height
        lsrb                            ; /2 = #swaps
vflip_sprite_line_pair:
        pshs    b
        ldb     *width
1$:     pshs    b
        ldd     ,u                      ; lo mask+data
        pshs    d
        ldd     ,y                      ; hi mask+data
        std     ,u++                    ; lo mask+data
        puls    d
        std     ,y++                    ; hi mask+data
        puls    b
        decb
        bne     1$
        lda     *width
        asla                            ; x2 for mask
        asla                            ; x4 for 2 lines
        nega                            ; subtract
        leay    a,y                     ; next hi line
        puls    b
        decb
        bne     vflip_sprite_line_pair

hflip_sprite_data:
        puls    y,u
        lda     ,u                      ; flip & width
        eora    7,x                     ; flags7
        anda    #FLAG_HFLIP             ; same?
        beq     flip_done               ; yes, skip
        pshs    x,y,u
        lda     ,u
        eora    #FLAG_HFLIP
        sta     ,u+
        anda    #0x0f                   ; width_bytes
        sta     *width
        ldb     ,u+                     ; height_lines
        stb     *height
        ldx     #reverse_tbl+0x80
hflip_line:
        pshs    b,u                     ; lines
        ldb     *width
        lslb                            ; width*2
        leay    b,u                     ; end of line
        ldb     *width
        lsrb                            ; /2=#swaps
1$:     pshs    b
        ldd     ,u                      ; mask+data
        lda     a,x                     ; reverse mask
        ldb     b,x                     ; reverse data
        pshs    d
        ldd     -2,y
        lda     a,x                     ; reverse mask
        ldb     b,x                     ; reverse data
        std     ,u++                    ; store beginning
        puls    d
        std     ,--y                    ; store end
        puls    b
        decb                            ; done line?
        bne     1$                      ; no, loop
        ldb     *width
        bitb    #1                      ; odd width?
        beq     2$                      ; no, skip
        ldd     ,u
        lda     a,x
        ldb     b,x
        std     ,u
2$:     puls    b,u
        lda     *width
        lsla                            ; width*2
        leau    a,u                     ; next line
        decb                            ; done all lines?
        bne     hflip_line
        puls    x,y,u
flip_done:
        rts

vidbuf:
        .ds     0x1800
                                                                                
				.end		start_coco
        