;
;	KNIGHT LORE
; - ported from the original ZX Spectrum version
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

        .org    code_base-#0x800
        
        .bndry  0x100
dp_base:                        .ds 256        
c       .equ    0x00
width   .equ    0x00
height  .equ    0x01
lines   .equ    0x02
bytes   .equ    0x03

; *** KNIGHT-LORE stuff here
VFLIP   .equ    1<<7
HFLIP   .equ    1<<6

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
                                .ds 1120
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
sprite_tbl            .equ    data_base+0x4ce0
reverse_tbl           .equ    0xcf00
shift_tbl             .equ    0xd000

				              .org		code_base

; Spectrum Palette for Coco3
; - spectrum format : B=1, R=2, G=4
; -     coco format : RGBRGB

speccy_pal:
;       black, blue, red, magenta, green, cyan, yellow, grey/white
.ifdef GFX_1BPP
  .ifdef GFX_RGB
      .db 0x00<<0, 0x07*9, 0, 0, 0, 0, 0, 0
      .db 0, 0, 0, 0, 0, 0, 0, 0
  .else
      .db 0, 63, 0, 0, 0, 0, 0, 0
      .db 0, 0, 0, 0, 0, 0, 0, 0
  .endif
.else
  .ifdef GFX_RGB
      .db 0x00<<0, 0x01<<0, 0x04<<0, 0x05<<0, 0x02<<0, 0x03<<0, 0x06<<0, 0x07<<0
      .db 0x00*9, 0x01*9, 0x04*9, 0x05*9, 0x02*9, 0x03*9, 0x06*9, 0x07*9
  .else
      .db 0, 12, 7, 9, 3, 29, 4, 32
      .db 0, 28, 23, 41, 17, 61, 51, 63
  .endif
.endif
				
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
        lbsr    clr_mem
        puls    a
        sta     seed_1
        bra     main
        
start_menu:        
        ldx     #objs_wiped_cnt
        ldy     #eod-#objs_wiped_cnt
        lbsr    clr_mem
        
main:
        lbsr    build_lookup_tbls
        clra
        sta     not_1st_screen
        sta     flags12_1
        lda     #5
        sta     lives
        ldx     seed_1
        lda     seed_2
        adda    ,x
        sta     seed_1
        lbsr    clear_scrn
        lbsr    do_menu_selection
        bsr     play_audio
        bsr     shuffle_objects_required
        lbsr    init_start_location
        lbsr    init_sun
        lbsr    init_special_objects
        
player_dies:
        lbsr    lose_life
        
game_loop:                
        lbsr    build_screen_objects
        
onscreen_loop:

update_sprite_loop:
        lbsr    save_2d_info

jump_to_upd_object:

jump_to_tbl_entry:

ret_from_tbl_jp:
        ;bra     update_sprite_loop
        
loc_B000:
        ldu     seed_2
        leau    1,u
        stu     seed_2
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
        lbsr    handle_pause
        bsr     init_cauldron_bubbles
        lbsr    list_objects_to_draw
        lbsr    render_dynamic_objects
        
game_delay:
loc_B038:

loc_B03F:
        tst     render_status_info
        beq     1$
        lbsr    fill_attr
        lbsr    display_objects
        lbsr    colour_panel
        lbsr    colour_sun_moon
        lbsr    display_panel
        ldx     #sun_moon_scratchpad
        lbsr    display_sun_moon_frame
        lbsr    display_day
        lbsr    print_days
        lbsr    print_lives_gfx
        lbsr    print_lives
        lbsr    update_screen
        lbsr    reset_objs_wipe_flag

1$:     clra
        sta     rising_blocks_z
        ldx     #graphic_objs_tbl
; check player dies
        bra     onscreen_loop
        
reset_objs_wipe_flag:
        rts

upd_sprite_jmp_tbl:

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

do_any_objs_intersect:
        rts

is_object_not_ignored:
        rts

shuffle_objects_required:
        rts

; sparkles from the blocks in the cauldron room
; at the end of the game
upd_131_to_133:
        rts

dec_dZ_wipe_and_draw:
        lbsr    dec_dZ_and_update_XYZ
        lbra    set_wipe_and_draw_flags

; B=column (active low)
; returns A=row data (active high)
read_port:
				ldx			#PIA0
				stb			2,x											; column strobe
				lda			,x											; active low
				coma                            ; active high
        rts
        
; ball (bouncing around)
; - bounces towards wulf
; - bounces away from sabreman
upd_182_183:
        rts

; block (high?)
upd_91:
        rts

; collapsing block
upd_143:
        rts

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
        rts

; spiked ball
upd_63:
        rts

spiked_ball_drop:
draw_spiked_ball:
        lbra    set_wipe_and_draw_flags

; spikes
upd_23:
        rts

; fire (moving EW)
upd_86_87:
        rts

; fire (stationary) (not used)
upd_176_177:

set_deadly_wipe_and_draw_flags:
        bsr     set_both_deadly_flags
        lbra    set_wipe_and_draw_flags

set_both_deadly_flags:
        rts

; ball up/down
upd_178_179:
loc_B892:
        bra     set_deadly_wipe_and_draw_flags                                                                                        
ball_up:        
        bra     loc_B892

init_cauldron_bubbles:
        lbra    adj_m4_m12

; even more sparkles (showing next object required)
upd_160_163:
        lbra    set_wipe_and_draw_flags

; special objs when 1st being put into cauldron
upd_168_to_175:
        rts

; repel spell
upd_164_to_167:
        rts

upd_111:
        lbra    audio_B467_wipe_and_draw

move_towards_plyr:

toggle_next_prev_sprite:        

next_graphic_no_mod_4:

save_graphic_no:

; cauldron (bottom)
upd_141:
        lbra    upd_88_to_90

; cauldron (top)
upd_142: 
        lbra    set_pixel_adj

; guard and wizard (top half)
upd_30_31_158_159:
        bra     set_deadly_wipe_and_draw_flags

move_guard_wizard_NSEW:
        lbra    jump_to_tbl_entry

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
        lbsr    clear_scrn_buffer
        lbsr    clear_scrn
        ldy     #gameover_xy
        ldx     #gameover_text
        ldb     #6
        lbsr    display_text_list
        ldy     #vidbuf+0x0fef
        ldx     #days
        ldb     #1
        lbsr    print_BCD_number
;
        lbsr    print_border
        lbsr    update_screen
1$:     clra
        bsr     read_port
        beq     1$
;
        bsr     wait_for_key_release        
        lbra    start_menu

wait_for_key_release:
        pshs  x
        ldx   #0
1$:     clra
        bsr   read_port
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
        lda     #0
        sta     7,x                     ; flags7
        lda     #16
        sta     26,x                    ; pixel_x
        lda     #32
        sta     27,x                    ; pixel_y
        lbsr    print_sprite
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
        lbsr    print_8x8
        puls    b
print_BCD_lsd:
        lda     ,x+                     ; get digit pair
        anda    #0x0f                   ; low nibble
        pshs    b
        lbsr    print_8x8
        puls    b
        decb                            ; done all pairs?
        bne     print_BCD_msd           ; no, loop
        rts
        
display_day:
        ldu     #day_font
        stu     gfxbase_8x8
        ldx     #day_txt
        ldd     #0xf70
        lbra    print_text
        
day_txt:
        .db 0, 0, 1, 2, 0x83
day_font:
        .db 6, 7, 6, 6, 6, 6, 6, 0xF
        .db 0, 1, 0x82, 0xC6, 0x64, 0x6C, 0x6D, 0xC6
        .db 0xC8, 0xC6, 0xE1, 0x60, 0x60, 0xE0, 0x64, 0x63
        .db 0x60, 0x60, 0x60, 0xE0, 0x60, 0x40, 0xC0, 0x80

do_menu_selection:
        clra
        sta     suppress_border
        ldx     #menu_colours
        ldb     #8
1$:     lda     ,x
        anda    #0x7f
        sta     ,x+
        decb
        bne     1$
        lbsr    clear_scrn_buffer
        lbsr    display_menu
        bsr     flash_menu
        
menu_loop:
        lbsr    display_menu
        
check_for_start_game:
				ldb			#~(1<<0)								; 0-7
				lbsr    read_port
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
        lbsr    calc_vidbuf_addr ; in U
        tfr     u,y
        bra     loc_BE56
        
print_text_std_font:

print_text:
        lbsr    calc_vidbuf_addr
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
        lbsr    print_border
        lbra    update_screen
1$:     rts        

; U=dx,dy B=num        
multiple_print_sprite:
        pshs    b
        pshs    y,u
        lbsr    print_sprite
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
        lbra    set_wipe_and_draw_flags

; last player appears sparkle
upd_127:
        lbra    jump_to_upd_object

init_death_sparkles:                                            ; twinkly transform

; death sparkles
upd_112_to_118_184:
        lbra    set_wipe_and_draw_flags

; sparkles (object in cauldron)
upd_185_187:

; last death sparkle
upd_119:

display_objects_carried:
display_objects:
display_object:
        rts

object_attributes:
sprite_scratchpad:
        .ds 32

chk_pickup_drop:
        rts

handle_pickup_drop:
done_pickup_drop:
        rts

drop_object:
adjust_carried:
pickup_object:

can_pickup_spec_obj:
is_on_or_near_obj:
        rts

is_obj_moving:
        rts

; extra life
upd_103:
        lbra    dec_dZ_upd_XYZ_wipe_if_moving
        
; special objects being put in cauldron
upd_104_to_110:
audio_B467_wipe_and_draw:
        lbra    set_wipe_and_draw_flags
        
centre_of_room:
add_obj_to_cauldron:        
        lbra    upd_111
        
ret_next_obj_required:
        lbra    add_HL_A
        
objects_required:

; special objects
upd_96_to_102:
        bra     audio_B467_wipe_and_draw
        
cycle_colours_with_sound:
cycle_attribute_mem:

no_update:
        rts

prepare_final_animation:
        rts
        
chk_and_init_transform:
        bra     rand_legs_sprite

; human/wulf transform
upd_92_to_95:
        bra     init_death_sparkles
        
rand_legs_sprite:
        lbra    set_wipe_and_draw_flags
        
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
        lbsr    fill_window
        lbsr    print_sprite
        ldx     #sprite_scratchpad
        lda     #0
        sta     7,x                   ; flags7
        lda     #0x5a
        sta     0,x                   ; graphic_no
        lda     #184
        sta     26,x                  ; pixel_x
        lda     #0
        sta     27,x                  ; pixel_y
        lbsr    print_sprite
        lda     #208
        sta     26,x                  ; pixel_x
        lda     #0xba
        sta     0,x                   ; graphic_no
        lbsr    print_sprite
        puls    x                     ; vidbuf addr (src)
        puls    u                     ; lines,bytes
        ldy     #coco_vram+0x17F7     ; (184,0) (dest)
        lbra    blit_to_screen

toggle_day_night:
        lda     0,x                   ; graphic_no
        eora    #1                    ; toggle sun/moon
        sta     0,x
        lbsr    colour_sun_moon
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
        lbsr    print_days
        ldd     #0x0078                 ; (120,0)
        bsr     blit_2x8
        bra     display_frame
                
blit_2x8:
        lbsr    calc_vram_addr;         ; ->U
        tfr     u,y
        lbsr    calc_vidbuf_addr        ; ->U
        tfr     u,x                     ; vidbuf (src)
        ldu     #0x0802                 ; 8 lines, 2 bytes        
        lbra    blit_to_screen

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
init_obj_loop:
        rts

; block
upd_62:
        lbra    dec_dZ_wipe_and_draw

; chest
upd_85:
        lbra    audio_B467_wipe_and_draw

; table
upd_84:
        bsr     upd_6_7

dec_dZ_upd_XYZ_wipe_if_moving:
        lbra    audio_B467_wipe_and_draw

; tree wall
upd_128_to_130:
        bra     jp_set_pixel_adj

adj_m4_m12:

jp_set_pixel_adj:
        bra     set_pixel_adj

adj_m6_m12:
        bra     jp_set_pixel_adj

; rock and block
upd_6_7:
        bra     jp_set_pixel_adj

; bricks
upd_10:                                                         ; -1, -20
        bra     jp_set_pixel_adj

; bricks
upd_11:
        bra     jp_set_pixel_adj

; bricks
upd_12_to_15:
        bra     jp_set_pixel_adj

adj_m8_m12:
        bra     jp_set_pixel_adj

adj_m7_m12:
        bra     jp_set_pixel_adj

adj_m12_m12:
        bra     jp_set_pixel_adj

upd_88_to_90:                                                   ; -12, -16
        bra     jp_set_pixel_adj

adj_p7_m12:
        bra     jp_set_pixel_adj

adj_p3_m12:
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
        rts

update_special_objs:
        rts

; ghost
upd_80_to_83:
        lbra    set_deadly_wipe_and_draw_flags
        
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
        bra     set_draw_objs_overlapped
        
set_wipe_and_draw_IY:
        rts

init_portcullis_up:

; portcullis (moving)
upd_9:
stop_portcullis:
        bra     set_wipe_and_draw_flags
        
move_portcullis_up:        
        bra     stop_portcullis

dec_dZ_and_update_XYZ:
add_dXYZ:
        rts
        
; arch (far side)
upd_3_5:                                                        ; hflip?

set_pixel_adj:
        rts
        
adj_3_5_hflip:                                                  ; -2, -7
        bra     set_pixel_adj

adj_m3_p1:                                                      ; -3, +1

; arch (near side)
upd_2_4:                                                        ; hflip?

adj_2_4_hflip:
        bra     lookup_plyr_dXY

adj_arch_tbl:

adj_ew:

adj_ns:
        rts
        
chk_plyr_spec_near_arch:
        rts

is_near_to:
        rts

; sabreman legs
upd_16_to_21_24_to_29:
        bsr     adj_m6_m12
        bra     upd_player_bottom

; wulf legs
upd_48_to_53_56_to_61:
        bsr     adj_m7_m12

upd_player_bottom:                                              ; dead?
        lbra    init_death_sparkles
 
plyr_not_OOB:

chk_plyr_OOB: 
        rts
         
handle_left_right:
        rts

left_right_non_directional:

handle_jump:
        rts

handle_forward:
        rts

move_player:
clear_dX_dY:
        rts

calc_plyr_dXY:
lookup_plyr_dXY:
        lbra    jump_to_tbl_entry

get_sprite_dir:
        rts
        
off_CA32:

move_plyr_W:
        rts

move_plyr_E:

move_plyr_N:
        rts

move_plyr_S:

adj_dZ_for_out_of_bounds:
        rts

handle_exit_screen:
        bra     lookup_plyr_dXY
        
adj_d_for_out_of_bounds:
        rts
        
screen_move_tbl:

screen_west:
screen_e_w:
exit_screen:        
        lbra    game_loop

screen_east:
        bra     screen_e_w
        
screen_north:
        bra     exit_screen
        
screen_south:
        bra     exit_screen
                
adj_for_out_of_bounds:
dZ_ok:
        rts

adj_dX_for_obj_intersect:
        rts

adj_dY_for_obj_intersect:                
        rts

adj_dZ_for_obj_intersect:
        rts
        
do_objs_intersect_on_x:
        rts

do_objs_intersect_on_y:
        rts
                        
do_objs_intersect_on_z:
        rts

adj_dX_for_out_of_bounds:
dX_ok:
        rts

adj_dY_for_out_of_bounds:
        dY_ok:
        rts

calc_2d_info:
        rts

set_draw_objs_overlapped:
        rts

; player (human top half)
upd_32_to_47:
        bsr     adj_m8_m12
        bra     upd_player_top

; player (wulf top half)
upd_64_to_79:
        bsr     adj_m12_m12

; copies most information from bottom half object
; handles randomly looking around
upd_player_top:
set_top_sprite:
        rts
        
save_2d_info:
        rts
        
list_objects_to_draw:
        rts

objects_to_draw:

calc_display_order_and_render:
process_remaining_objs:
        lbra    jump_to_tbl_entry

off_CF69:

continue_1:
continue_2:
d_3467121516:
        bra     render_obj
        
objs_coincide:
render_obj_no1:
render_obj:
render_done:
        rts

render_list:

check_user_input:
keyboard:
finished_input:
        rts
        
lose_life:
        ldu     #plyr_spr_1_scratchpad
        ldy     #graphic_objs_tbl
        tfr     u,x
        ldb     #64
1$:     lda     ,u+
        sta     ,y+
        decb
        bne     1$
        clra
        sta     transform_flag_graphic
        dec     lives
        lbmi    game_over
        lda     sun_moon_scratchpad
        rora
        rora
        rora
        anda    #0x20                   ; day/night
        sta     *c
        lda     16,x                    ; plyr graphic no
        anda    #0x1f
        adda    *c
        sta     16,x
        lda     0x30,x
        anda    #0x0f
        adda    *c
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
        sta     start_loc_1
        sta     start_loc_2
        rts

start_locations:
        .db 0x2F, 0x44, 0xB3, 0x8F

build_screen_objects:
        tst     not_1st_screen
        beq     1$
        lbsr    update_special_objs
1$:     pshs    x
        lbsr    clear_scrn_buffer
        puls    x
        lbsr    retrieve_screen
        lbsr    find_special_objs_here
        lbsr    adjust_plyr_xyz_for_room_size
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
        lbsr    print_sprite
        puls    u
        rts

display_panel:
        ldx     #sprite_scratchpad
        ldu     #panel_data
        bsr     transfer_sprite
        ldy     #0xf810                 ; x+=16, y-=8
        ldb     #5
        lbsr    multiple_print_sprite
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite_and_print
        bsr     transfer_sprite
        ldy     #0x0810                 ; x+=16, y+=8
        ldb     #5
        lbsr    multiple_print_sprite
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
        lbsr    multiple_print_sprite
        bsr     transfer_sprite
        ldb     #24
        lbsr    multiple_print_sprite
        bsr     transfer_sprite
        ldy     #0x0100                 ; x+=0, y+=16
        ldb     #128
        lbsr    multiple_print_sprite
        lbsr    transfer_sprite
        ldb     #128
        lbra    multiple_print_sprite
                
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
        ;lbra    fill_window
        rts

colour_sun_moon:
        ;lbra    fill_window
        rts

adjust_plyr_xyz_for_room_size:
        rts                                                        

adjust_plyr_y:
copy_spr_1_xy_2:
        rts
        
adjust_plyr_x:
        bra     copy_spr_1_xy_2
        
adjust_plyr_Z_for_arch:
        rts

get_ptr_object:
        rts

retrieve_screen:
        ldy     #other_objs_here
        ldu     #location_tbl

find_screen:
        lda     ,u+                     ; location id
        cmpa    8,x                     ; same as player?
        beq     found_screen
        lda     ,u                      ; #bytes
        leau    a,u                     ; next location
        cmpu    #eolt                   ; end of table?
        bge     zero_end_of_graphic_objs_tbl
        bra     find_screen

zero_end_of_graphic_objs_tbl:
        cmpy    #eod
        beq     9$
        ldb     #32
        bsr     zero_Y
        bra     zero_end_of_graphic_objs_tbl
9$:     rts

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
        sta     *c
        adda    *c
        adda    *c                      ; x3
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
        pshs    u
        ldu     #background_type_tbl
        asla                            ; word offset
        leau    a,u                     ; ptr entry
        ldu     ,u                      ; get entry
next_bg_obj_sprite:
        pshs    b                       ; bytes left
        ldb     #8
1$:     lda     ,u+                     ; byte from object
        sta     ,y+                     ; copy to graphic_objs_tbl
        decb
        bne     1$
        lda     8,x                     ; current screen
        sta     ,y+                     ; set object screen
        ldb     #23
        bsr     zero_Y
        puls    b                       ; bytes left
        tst     ,u                      ; done object?
        bne     next_bg_obj_sprite      ; no, loop
        puls    u                       ; location data
        decb                            ; any bytes left?
        bne     next_bg_obj             ; yes, loop
        bra     zero_end_of_graphic_objs_tbl

find_fg_objs:
next_fg_obj:                                                    
next_fg_obj_in_count:
next_fg_obj_sprite:
        ;bra     zero_end_of_graphic_objs_tbl
        rts

add_HL_A:
        rts

HL_equals_DE_x_A:
        rts
        
zero_Y:
        clr     ,y+
        decb
        bne     zero_Y
        rts

fill_DE:
        rts

handle_pause:
debounce_space_press:
wait_for_space:
debounce_space_release:
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
2$:     lda     ,x+
        sta     ,y+
        decb
        bne     2$
        leax    -64,x
        puls    b
        decb
        bne     1$
        puls    b,x,y
        rts

render_dynamic_objects:
wipe_next_object:
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
        stb     *c                      ; index
1$:     pshs    b                       ; counter
        lda     *c                      ; get index
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
        lda     *c
        inc     *c
        stb     a,x                     ; reversed
        puls    b
        decb                            ; done 256?
        bne     1$                      ; no loop
; 2nd is table of shifted values (2 bytes)
; - 1st run seeds low values
        ldb     #0
        stb     *c
        ldx     #shift_tbl
2$:     lda     *c
        inc     *c
        sta     ,x+
        clra
        sta     255,x
        decb
        bne     2$
; next 7 runs shift the previous entries
        ldx     #shift_tbl
        ldb     #7
3$:     pshs    b
        ldb     #0
4$:     pshs    b
        lda     ,x
        ldb     0x100,x
        lsra
        rorb
        sta     0x200,x
        stb     0x300,x
        leax    1,x
        puls    b
        decb
        bne     4$
        leax    0x100,x
        puls    b
        decb
        bne     3$
        rts

calc_pixel_XY:
        rts

; returns ptr sprite data in U
flip_sprite:
        ldb     ,x                      ; graphic no
        ldu     #sprite_tbl
        clra
        aslb
        rola
        leau    d,u
        ldu     ,u                      ; sprite data addr
        lda     ,u                      ; flip & width
        bne     vflip_sprite_data       ; not null sprite
        leas    2,s                     ; exit from caller
        rts

calc_pixel_XY_and_render:
        rts

; sprites are actually vflipped in memory
; so render them directly to buffer
; - buffer is vflipped w.r.t. video
print_sprite:
        bsr     flip_sprite             ; U=ptr sprite data
        lda     26,x                    ; pixel_x
        anda    #7                      ; bit offset
        beq     loc_D76F

loc_D76F:
        lda     ,u+                     ; width
        anda    #0x0f                   ; mask off flip bits
        sta     24,x                    ; width_bytes
        lda     ,u+                     ; height
        sta     25,x                    ; height_lines
        adda    27,x                    ; pixel_y
        suba    #192                    ; off screen?
        bcs     1$                      ; no, skip
        coma
        adda    25,x
        sta     25,x                    ; adjust height lines
1$:     ldb     26,x                    ; pixel_x     
        lda     27,x                    ; pixel_y
        tfr     u,y
        bsr     calc_vidbuf_addr        ; ->U
        exg     u,y
; this next bit requires some serious optimisation
;       X = object
;       Y = video buffer address
;       U = sprite data
        ldb     25,x                    ; height_lines
2$:     pshs    b
        ldb     24,x                    ; width_bytes
3$:     lda     ,u+                     ; read mask
        coma
        anda    ,y                      ; from video
        ora     ,u+                     ; add sprite byte
        sta     ,y+                     ; write back to video
        decb
        bne     3$
        lda     #32
        suba    24,x
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
        pshs    u
        eora    7,x                     ; flags7
        anda    #VFLIP                  ; same?
        beq     hflip_sprite_data       ; yes, skip
        lda     ,u
        eora    #VFLIP
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
        puls    u
        pshs    u
        lda     ,u                      ; flip & width
        eora    7,x                     ; flags7
        anda    #HFLIP                  ; same?
        beq     flip_done               ; yes, skip
        lda     ,u
        eora    #HFLIP
        sta     ,u+
        anda    #0x0f                   ; width_bytes
        sta     *width
        ldb     ,u+                     ; height_lines
        stb     *height
        pshs    x
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
        puls    x
flip_done:
        puls    u
        rts

vidbuf:
        .ds     0x1800
                                                                                
				.end		start_coco
        