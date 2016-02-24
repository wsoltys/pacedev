;
;	KNIGHT LORE
; - ported from the original ZX Spectrum version
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

				.org		codebase
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
				lda			#(VIDEOPAGE<<2)         ; screen at page $30
				sta			VOFFMSB
				lda			#0x00
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
				
				ldx			#PALETTE
				ldy     #speccy_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)
        ;sta     RAMMODE
        
  ; configure video MMU

        lda     #VIDEOPAGE
        ldx     #(MMUTSK1)              ; $0000-
        ldb     #3
  mmumap: 
        sta     ,x+
        inca
        decb
        bne     mmumap                  ; map pages $30-$31

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
			
				lda			#>ZEROPAGE
				tfr			a,dp

start:
        bsr     clr_mem
        bra     main
        
start_menu:        
        bsr     clr_mem
        
main:
        bsr     build_lookup_tbls
        bsr     clear_scrn
        bsr     do_menu_selection
        bsr     play_audio
        bsr     shuffle_objects_required
        bsr     init_start_location
        bsr     init_sun
        bsr     init_special_objects
        
player_dies:
        bsr     lose_life
        
game_loop:                
        bsr     build_screen_objects
        
onscreen_loop:

update_sprite_loop:
        bsr     save_2d_info

jump_to_upd_object:

jump_to_tbl_entry:

ret_from_tbl_jp:
        bra     update_sprite_loop
        
loc_B000:
game_delay:
loc_B038:
loc_B03F:
loc_B074:

reset_objs_wiped_flag:
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
        bsr     dec_dZ_and_update_XYZ
        bra     set_wipe_and_draw_flags

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
        bra     set_wipe_and_draw_flags

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
        bra     set_wipe_and_draw_flags

set_both_deadly_flags:
        rts

; ball up/down
upd_178_179:
loc_B892:
        bra     set_deadly_wipe_and_draw_flags                                                                                        
ball_up:        
        bra     loc_B892

init_cauldron_bubbles:
        bra     adj_m4_m12

; even more sparkles (showing next object required)
upd_160_163:
        bra     set_wipe_and_draw_flags

; special objs when 1st being put into cauldron
upd_168_to_175:
        rts

; repel spell
upd_164_to_167:
        rts

upd_111:
        bra     audio_B467_wipe_and_draw

move_towards_plyr:

toggle_next_prev_sprite:        

next_graphic_no_mod_4:

save_graphic_no:

; cauldron (bottom)
upd_141:
        bra     upd_88_to_90

; cauldron (top)
upd_142: 
        bra     set_pixel_adj

; guard and wizard (top half)
upd_30_31_158_159:
        bra     set_deadly_wipe_and_draw_flags

move_guard_wizard_NSEW:
        bra     jump_to_tbl_entry

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
        bra     start_menu

wait_for_key_release:
        rts
        
game_complete_msg:

calc_and_display_percent:

count_screens:
        bra     print_BCD_number
        
print_days:
        rts
                
print_lives_gfx:
        bra     fill_DE
        
print_lives:
        bra     print_BCD_number
        
print_BCD_number:
        rts
        
display_day:
        bra     print_text
        
day_txt:
day_font:

do_menu_selection:
menu_loop:
check_for_start_game:
        bra     menu_loop        

flash_menu:
        rts

print_text_single_colour:
print_text_std_font:
print_text:
        bsr     print_8x8
        rts
        
print_8x8:
        rts

toggle_selected:
        rts

display_menu:
display_text_list:
        bra     update_screen
        
multiple_print_sprite:
        rts

; player appear sparkles
upd_120_to_126:
        bra     set_wipe_and_draw_flags

; last player appears sparkle
upd_127:
        bra     jump_to_upd_object

init_death_sparkles:                                            ; twinkly transform

; death sparkles
upd_112_to_118_184:
        bra     set_wipe_and_draw_flags

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
        bra     dec_dZ_upd_XYZ_wipe_if_moving
        
; special objects being put in cauldron
upd_104_to_110:
audio_B467_wipe_and_draw:
        bra     set_wipe_and_draw_flags
        
centre_of_room:
add_obj_to_cauldron:        
        bra     upd_111
        
ret_next_obj_required:
        bra     add_HL_A
        
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
        bra     set_wipe_and_draw_flags
        
print_sun_moon:
display_sun_moon_frame:
display_frame:               
        bra     blit_to_screen
                
toggle_day_night:
inc_days:
        bra     display_frame
                
blit_2x8:
        bra     blit_to_screen

init_sun:
        rts
        
init_special_objects:
init_obj_loop:
        rts

; block
upd_62:
        bra     dec_dZ_wipe_and_draw

; chest
upd_85:
        bra     audio_B467_wipe_and_draw

; table
upd_84:
        bsr     upd_6_7

dec_dZ_upd_XYZ_wipe_if_moving:
        bra     audio_B467_wipe_and_draw

; tree wall
upd_128_to_130:
        bra     jp_set_pixel_adj

adj_m4_m12:
        bra     jp_set_pixel_adj

adj_m6_m12:
        bra     jp_set_pixel_adj

; rock and block

; =============== S U B R O U T I N E =======================================


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

fill_window:
        rts

find_special_objs_here:
        rts

update_special_objs:
        rts

; ghost
upd_80_to_83:
        bra     set_deadly_wipe_and_draw_flags
        
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
        bra     init_death_sparkles
 
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
        bra     jump_to_tbl_entry

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
        bra     game_loop

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


                                
				.end		start_coco

