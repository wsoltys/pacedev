;
; ROTATED GRAPHICS
;
        
; $1A95
byte_0_1A95:
        .db 0                           ; Image form (increments each draw)
        .db 0                           ; Delta X
        .db 0xFF                        ; Delta Y is -1
        .db 0xFE                        ; Y starting coordinate (swapped for 6809)
        .db 0xB8                        ; X coordinate (swapped for 6809)
        .dw alien_spr_a+0x20            ; Base image (small alien)
        DEF_SPRW 16                     ; Size of image (16 bytes)
        .db 0x9E                        ; Target Y coordinate
        .db 0                           ; Reached Y flag
        .dw alien_spr_a+0x20            ; Base image (small alien)

; $1AA1
; The tables at 1CB8 and 1AA1 control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then 
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less 
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything 
; above 3000 is 07.
;
; 1CB8: 02 10 20 30
shot_reload_rate:
        .db 48, 16, 11, 8, 7

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

; $1AE4
message_score:
;       " SCORE<1> HI-SCORE SCORE<2>"
        .db 0x26,0x12,2,0xE,0x11,4,0x24,0x1B,0x25,0x26,7,8,0x3F
        .db 0x12,2,0xE,0x11,4,0x26,0x12,2,0xE,0x11,4,0x24,0x1C
        .db 0x25,0x26

; this is mainly for debugging
;        .bndry  0x100
        
;-------------------------- RAM initialization -----------------------------
; Copied to RAM (2000) C0 bytes as initialization.
; See the description of RAM at the top of this file for the details on this data.
byte_0_1B00:    .db 1                   ; wait_on_draw
                .db 0                   ; (unused)
                .db 0                   ; alien_is_exploding
                .db 0x10                ; exp_alien_timer
                .db 0                   ; alien_row
                .db 0                   ; alien_frame
                .db 0                   ; alien_cur_index
                .db 0                   ; ref_alien_dyr
                .db 2                   ; ref_alien_dxr
                .dw 0x3878              ; ref_alien (xr,yr)
                .dw 0x3878              ; alien_pos (msb,lsb)
                .db 0                   ; rack_direction
                .db 0xF8                ; rack_down_delta
                .db 0                   ; (unused)
                
                .db 0, 0x80, 0          ; obj0_timer_msb/lsb/extra
                .dw game_obj_0          ; obj0_handler_msb/lsb
                .db 0xFF                ; player_alive
                .db 5, 0xC              ; exp_animate_timer/cnt
                .dw player_sprite       ; plyr_spr_pic_m/l
                .dw 0x3020              ; player_xr/yr
                .db 0x10                ; plyr_spr_size
                .db 1                   ; next_demo_cmd
                .db 0                   ; hid_mess_seq
                .db 0                   ; (unused)
                
                .db 0,0,0               ; obj1_timer_msb/lsb/extra
                .dw game_obj_1          ; obj1_hamdler_msb/lsb
                .db 0                   ; plyr_shot_status
                .db 0x10                ; blow_up_timer
                .dw player_shot_spr     ; obj1_image_msb/lsb
                .dw 0x3028              ; obj1_coor_xr/yr
                .db 1                   ; obj1_image_size
                .db 4                   ; shot_delta_x
                .db 0                   ; fire_bounce
                .db 0xFF, 0xFF          ; (unused)
                
                .db 0,0,2               ; obj2_timer_msb/lsb/extra
                .dw game_obj_2          ; obj2_handler_msb/lsb
                .db 0,0,0               ; rol_shot_status/set_cnt/track
                .dw 0x0000              ; rol_shot_x_fir_msb/lsb
                .db 4                   ; rol_shot_blow_cnt
                .dw roll_shot           ; rol_shot_image_msb/lsb
                .dw 0x0000              ; rol_shot_xr/yr
                .db 3                   ; rol_shot_size
                
                .db 0,0,0               ; obj3_timer_msb/lsb/extra
                .dw game_obj_3          ; obj3_handler_msb/lsb
                .db 0,0,1               ; plu_shot_status/step_cnt/track
                .dw col_fire_table      ; plu_shot_c_fir_msb/lsb
                .db 4                   ; plu_shot_blow_cnt
                .dw plunger_shot        ; plu_shot_image_msb/lsb
                .dw 0x0000              ; plu_shot_xr/yr
                .db 3                   ; plu_shot_size

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
                DEF_SPRW 3              ; squShotSize

; $1B60->$2060
                .db 0xFF                ; end_of_tasks
                .db 0                   ; collision
                .dw alien_explode       ; exp_alien_msb/lsb
                .dw 0x0000              ; exp_alien_xr/yr
                .db 0x10                ; exp_aline_size
                .db >byte_0_2100        ; player_data_msb
                .db 1                   ; player_ok
                .db 0                   ; enable_alien_fire
                .db 0x30                ; alien_fire_delay
                .db 0                   ; one_alien
                .db 0x12                ; temp_206C
                .db 0                   ; invaded
                .db 0                   ; skip_plunger
                .db 0                   ; (unused)
                
; These don't need to be copied over to RAM (see 1BA0 below).
; $1B70
message_p1: 
; "PLAY PLAYER<1>"
        .db 0xF,0xB,0,0x18,0x26,0xF,0xB,0
        .db 0x18,4,0x11,0x24,0x1B,0x25,0xFC
        .db 0

; $1B80
        .db 1                           ; shot_sync
        .db 0xFF                        ; tmp_2081
        .db 0xFF                        ; num_aliens
; $1B83
byte_0_1B83:
        .db 0                           ; saucer_start
        .db 0                           ; saucer_active
        .db 0                           ; saucer_hit
        .db 32                          ; saucer hit time
        .dw unk_0_1D64                  ; saucer_pri_pic_msb/lsb (bug-swap)
        .dw 0x29D0                      ; saucer_pri_loc_msb/lsb (bug-swap)
        DEF_SPRW 24                     ; saucer_pri_size
        .db 2                           ; saucer_delta_y
        .dw saucer_scr_tab              ; sau_score_msb/lsb
        .db 0                           ; shot_count_msb
; $1B90        
        .db 8                           ; shot_count_lsb
        .dw 0x600                       ; till_saucer_msb/lsb
        .db 0                           ; wait_start_loop
        .db 0                           ; sound_port_3
        .db 1                           ; change_fleet_snd
        .db 0x40                        ; fleet_snd_cnt
        .db 0                           ; fleet_snd_reload
        .db 1                           ; sound_port_5
        .db 0                           ; extra_hold
        .db 0                           ; tilt
        .db 0x10                        ; fleet_snd_hold
        .db 0x9E, 0, 0x20, 0x1C         ; (unused)

; $1BA0 (rotated)
alien_spr_CYA:
; Alien sprite type C pulling upside down Y
        .db 0x00, 0x10, 0x10, 0x1D, 0x13, 0x28, 0x45, 0x44
        .db 0x30, 0x78, 0xFC, 0xB6, 0xFE, 0xB4, 0x02, 0x84

byte_0_1BB0:    
        .db 0                           ; image form            
        .db 0                           ; delta x               
        .db 1                           ; delta y               
        .db 0x98                        ; y starting coordinate (swapped for 6809)
        .db 0xB8                        ; x coordinate (swapped for 6809)
        .dw alien_spr_CYA               ; Base image
        DEF_SPRW 16                     ; size of image         
        .db 0xFF                        ; target y coordinate   
        .db 0                           ; reached flag          
        .dw alien_spr_CYA               ; Base image

        .db    0, 0, 0, 0

; sqiggly shot descriptor
; gets copied to $2050 ($7050) overwriting value from init
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
        DEF_SPRW 3                      ; squShotSize     

; $1BD0 (rotated)
alien_spr_CYB:
; Alien sprite C pulling upside down Y. Note the difference between this and the first picture
; above. The Y is closer to the ship. This gives the effect of the Y kind of "sticking" in the
; animation.
        .db 0x00, 0x08, 0x08, 0x0D, 0x0B, 0x14, 0x22, 0x23
        .db 0x30, 0x78, 0xFC, 0xB6, 0xFE, 0x48, 0xB4, 0x4A

; $1BE0
; More RAM initialization copied by 18D9
        .db 0, 0, 0, 0, 0               ; (not used)
        .db 0                           ; player1_ex
        .db 0                           ; player2_ex
        .db 0                           ; player1_alive
        .db 0                           ; player2_alive
        .db 1                           ; suspend_play
        .db 0                           ; coin_switch
        .db 0                           ; num_coins
        .db 1                           ; splash_animate
        .dw demo_commands               ; demo_cmd_ptr_msb/lsb
        .db 0                           ; game_mode

; $1BF0
        .db 0x80                        ; (not used)
        .db 0                           ; adjust_score
        .db 0                           ; score_delta_msb
        .db 0                           ; score_delta_lsb

; hi score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x2F, 
        DEF_VRAM  0x0b1c
; p1 score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x27, 
        DEF_VRAM  0x031c
; p2 score and vram location        
        .db 0, 0
        ;.db 0x1C, 0x39
        DEF_VRAM  0x151c

; $1C00 (rotated)
alien_spr_a:    
        .db 0x03, 0x1F, 0x3F, 0x39, 0x3F, 0x06, 0x0D, 0x30
        .db 0xC0, 0xF8, 0xFC, 0x9C, 0xFC, 0x60, 0xB0, 0x0C
        .db 0x04, 0x12, 0x17, 0x1D, 0x1F, 0x0F, 0x04, 0x08
        .db 0x10, 0x24, 0xF4, 0xDC, 0xFC, 0xF8, 0x10, 0x08
        .db 0x01, 0x03, 0x07, 0x0D, 0x0F, 0x02, 0x05, 0x0A
        .db 0x80, 0xC0, 0xE0, 0xB0, 0xF0, 0x40, 0xA0, 0x50
; $1C30 (rotated)
alien_spr_b:        
        .db 0x03, 0x1F, 0x3F, 0x39, 0x3F, 0x0E, 0x19, 0x0C
        .db 0xC0, 0xF8, 0xFC, 0x9C, 0xFC, 0x70, 0x98, 0x30
        .db 0x04, 0x02, 0x07, 0x0D, 0x1F, 0x17, 0x14, 0x03
        .db 0x10, 0x20, 0xF0, 0xD8, 0xFC, 0xF4, 0x14, 0x60
        .db 0x01, 0x03, 0x07, 0x0D, 0x0F, 0x05, 0x08, 0x04
        .db 0x80, 0xC0, 0xE0, 0xB0, 0xF0, 0xA0, 0x10, 0x20
; $1C60 (rotated)
player_sprite:           
        .db 0x00, 0x01, 0x01, 0x1F, 0x3F, 0x3F, 0x3F, 0x3F
        .db 0x80, 0xC0, 0xC0, 0xFC, 0xFE, 0xFE, 0xFE, 0xFE
; $1C70 (rotated)
plr_blow_up_sprites:    
        .db 0x02, 0x00, 0x02, 0x12, 0x01, 0x45, 0x1F, 0x3F
        .db 0x00, 0x10, 0xA0, 0x00, 0xB0, 0xA8, 0xE4, 0xF5
; $1C80 (rotated)
        .db 0x10, 0x82, 0x10, 0x02, 0x4B, 0x21, 0x1F, 0x37
        .db 0x04, 0x19, 0xC0, 0x02, 0x31, 0xC4, 0xF0, 0xF2
; $1C90
player_shot_spr:
        .db 0xF0
; $1C91 (rotated)
shot_exploding:
        .db 0x89, 0x22, 0x7E, 0xFF, 0xFF, 0x7E, 0x24, 0x91
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

; $1CB8
a_reload_score_tab:    
; The tables at 1CB8 and 1AA1 control how fast shots are created. The speed is based
; on the upper byte of the player's score. For a score of less than or equal 0200 then 
; the fire speed is 30. For a score less than or equal 1000 the shot speed is 10. Less 
; than or equal 2000 the speed is 0B. Less than or equal 3000 is 08. And anything 
; above 3000 is 07.
;
; 1AA1: 30 10 0B 08                           
; 1AA5: 07           ; Fastest shot firing speed
;
        .db 2, 0x10, 0x20, 0x30

; $1CBC
message_tilt:
        .db 0x13, 8, 0xB, 0x13          ; "TILT"

; $1CC0 (rotated)
alien_explode:
        .db 0x04, 0x22, 0x10, 0x08, 0x60, 0x08, 0x12, 0x24
        .db 0x40, 0x88, 0x10, 0x20, 0x0C, 0x20, 0x90, 0x48

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

; $1CE2
plunger_shot:
        .db 0x20, 0x3F, 0x20
        .db 0x08, 0x3F, 0x08
        .db 0x04, 0x3F, 0x04
        .db 0x01, 0x3F, 0x01

; $1CEE
roll_shot:
        .db 0x00, 0x7F, 0x00
        .db 0x24, 0x7F, 0x48
        .db 0x00, 0x7F, 0x00
        .db 0x12, 0x7F, 0x09

; $1CFA
message_play_UY:
        .db 0xF, 0xB, 0, 0x29           ; "PLAY" with inverted Y

; $1CFE
        .db 0, 0
        
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

; $1D15
; This appears to be part of the column-firing table, but it is never used.
; Perhaps this was originally intended for the "rolling" shot but then the
; "rolling" was change to target the player specifically.
        .db 5, 2, 5, 4, 6, 7, 8, 0xA
        .db 6, 0xA, 3

; $1D20
shield_image:
        .db 0xFF, 0xF0, 0xFF, 0xF8, 0xFF, 0xFC, 0xFF, 0xFE
        .db 0xFF, 0xFF, 0x3F, 0xFF, 0x1F, 0xFF, 0x0F, 0xFF
        .db 0x0F, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF
        .db 0x0F, 0xFF, 0x0F, 0xFF, 0x1F, 0xFF, 0x3F, 0xFF
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0xFF, 0xFC
        .db 0xFF, 0xF8, 0xFF, 0xF0

; $1D4C
byte_0_1D4C:
        .db 5, 0x10, 0x15, 0x30         ; Table of possible saucer scores
byte_0_1D50:
        .db 0x94, 0x97, 0x9A, 0x9D      ; Table of corresponding string prints for each possible score

; $1D54
; 208D points here to the score given when the saucer is shot. It advances 
; every time the player-shot is removed. The code wraps after 15, but there
; are 16 values in this table. This is a bug in the code at 044E (thanks to
; Colin Dooley for finding this).
;
; Thus the one and only 300 comes up every 15 shots (after an initial 8).
saucer_scr_tab: 
        .db 0x10, 5, 5, 0x10, 0x15, 0x10, 0x10, 5
        .db 0x30, 0x10, 0x10, 0x10, 5, 0x15, 0x10, 5

; $1D64 (rotated - fixme)
unk_0_1D64:
        .db 0x00, 0x00, 0x01, 0x03
; $1D68 (rotated - fixme)
sprite_saucer:
        .db                         0x06, 0x0F, 0x03, 0x01
        .db 0x00, 0x7E, 0xFF, 0xFF, 0xDB, 0xFF, 0x99, 0x00
        .db 0x00, 0x00, 0x80, 0xC0, 0x60, 0xF0, 0xC0, 0x80

; $1D7C
sprite_saucer_exp:
        .db 0, 0x22, 0, 0xA5, 0x40, 8, 0x98, 0x3D, 0xB6, 0x3C
        .db 0x36, 0x1D, 0x10, 0x48, 0x62, 0xB6, 0x1D, 0x98, 8
        .db 0x42, 0x90, 8, 0, 0

; $1D94
sauc_score_str:                          
        .db 0x26, 0x1F, 0x1A            ; _50
        .db 0x1B, 0x1A, 0x1A            ; 100
        .db 0x1B, 0x1F, 0x1A            ; 150
        .db 0x1D, 0x1A, 0x1A            ; 300

; $1DA0
alien_scores:
;       Score table for hitting alien type
        .db 0x10                        ; Bottom 2 rows     
        .db 0x20                        ; Middle row
        .db 0x30                        ; Highest row

; $1DA3
; Starting Y coordinates for aliens at beginning of rounds. The first round is initialized to $78 at 07EA.
; After that this table is used for 2nd, 3rd, 4th, 5th, 6th, 7th, 8th, and 9th. The 10th starts over at
; 1DA3 (60).
alien_start_table:
        .db 96, 80, 72, 72, 72, 64, 64, 64

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
        DEF_VRAM  0x080E
        .dw sprite_saucer               ; ptr ufo bitmap
        DEF_VRAM  0x080C
        .dw alien_spr_a+0x20            ; ptr 30 pt invader bitmap
        DEF_VRAM  0x080A
        .dw alien_spr_b+0x10            ; ptr 20 pt invader bitmap
        DEF_VRAM  0x0808
        .dw alien_spr_a                 ; ptr 10 pt invader bitmap
        .db 0xFF

; score table text info
word_0_1DCF:    
        DEF_VRAM  0x0A0E
        .dw message_myst                ; "=? MYSTERY"
        DEF_VRAM  0x0A0C
        .dw message_30_pts              ; "=30 POINTS"
        DEF_VRAM  0x0A0A
        .dw message_20_pts              ; "=20 POINTS"
        DEF_VRAM  0x0A08
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
        .db 0x00, 0x10, 0x28, 0x44, 0x44, 0x7C, 0x44, 0x44    ; "A"
        .db 0x00, 0x78, 0x44, 0x44, 0x78, 0x44, 0x44, 0x78    ; "B"
        .db 0x00, 0x38, 0x44, 0x40, 0x40, 0x40, 0x44, 0x38    ; "C"
        .db 0x00, 0x78, 0x44, 0x44, 0x44, 0x44, 0x44, 0x78    ; "D"
        .db 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7C    ; "E"
        .db 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x40    ; "F"
        .db 0x00, 0x3C, 0x40, 0x40, 0x40, 0x4C, 0x44, 0x3C    ; "G"
        .db 0x00, 0x44, 0x44, 0x44, 0x7C, 0x44, 0x44, 0x44    ; "H"
        .db 0x00, 0x38, 0x10, 0x10, 0x10, 0x10, 0x10, 0x38    ; "I"
        .db 0x00, 0x04, 0x04, 0x04, 0x04, 0x04, 0x44, 0x38    ; "J"
        .db 0x00, 0x44, 0x48, 0x50, 0x60, 0x50, 0x48, 0x44    ; "K"
        .db 0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7C    ; "L"
        .db 0x00, 0x44, 0x6C, 0x54, 0x54, 0x44, 0x44, 0x44    ; "M"
        .db 0x00, 0x44, 0x44, 0x64, 0x54, 0x4C, 0x44, 0x44    ; "N"
        .db 0x00, 0x38, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38    ; "O"
        .db 0x00, 0x78, 0x44, 0x44, 0x78, 0x40, 0x40, 0x40    ; "P"
        .db 0x00, 0x38, 0x44, 0x44, 0x44, 0x54, 0x48, 0x34    ; "Q"
        .db 0x00, 0x78, 0x44, 0x44, 0x78, 0x50, 0x48, 0x44    ; "R"
        .db 0x00, 0x38, 0x44, 0x40, 0x38, 0x04, 0x44, 0x38    ; "S"
        .db 0x00, 0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10    ; "T"
        .db 0x00, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38    ; "U"
        .db 0x00, 0x44, 0x44, 0x44, 0x44, 0x44, 0x28, 0x10    ; "V"
        .db 0x00, 0x44, 0x44, 0x44, 0x54, 0x54, 0x6C, 0x44    ; "W"
        .db 0x00, 0x44, 0x44, 0x28, 0x10, 0x28, 0x44, 0x44    ; "X"
        .db 0x00, 0x44, 0x44, 0x28, 0x10, 0x10, 0x10, 0x10    ; "Y"
        .db 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x40, 0x7C    ; "Z"
        .db 0x00, 0x38, 0x44, 0x4C, 0x54, 0x64, 0x44, 0x38    ; "0"
        .db 0x00, 0x10, 0x30, 0x10, 0x10, 0x10, 0x10, 0x38    ; "1"
        .db 0x00, 0x38, 0x44, 0x04, 0x18, 0x20, 0x40, 0x7C    ; "2"
        .db 0x00, 0x7C, 0x04, 0x08, 0x18, 0x04, 0x44, 0x38    ; "3"
        .db 0x00, 0x08, 0x18, 0x28, 0x48, 0x7C, 0x08, 0x08    ; "4"
        .db 0x00, 0x7C, 0x40, 0x78, 0x04, 0x04, 0x44, 0x38    ; "5"
        .db 0x00, 0x1C, 0x20, 0x40, 0x78, 0x44, 0x44, 0x38    ; "6"
        .db 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x20, 0x20    ; "7"
        .db 0x00, 0x38, 0x44, 0x44, 0x38, 0x44, 0x44, 0x38    ; "8"
        .db 0x00, 0x38, 0x44, 0x44, 0x3C, 0x04, 0x08, 0x70    ; "9"
        .db 0x00, 0x08, 0x10, 0x20, 0x40, 0x20, 0x10, 0x08    ; "<"
        .db 0x00, 0x20, 0x10, 0x08, 0x04, 0x08, 0x10, 0x20    ; ">"
        .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00    ; " "
        .db 0x00, 0x00, 0x00, 0x7C, 0x00, 0x7C, 0x00, 0x00    ; "="
        .db 0x00, 0x10, 0x54, 0x38, 0x10, 0x38, 0x54, 0x10    ; "*"
        .db 0x00, 0x10, 0x10, 0x10, 0x10, 0x28, 0x44, 0x44    ; "Ý"

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
        
; $1F80 (rotated)
alien_spr_CA:        
        .db 0x00, 0x88, 0x8C, 0x57, 0x23, 0x20, 0x21, 0x20    ; "Y"
        .db 0x30, 0x78, 0xFC, 0xB6, 0xFE, 0xB4, 0x02, 0x84    ; " "

; $1F90        
message_coin:  
;       "INSERT  COIN"           
        .db 8, 0xD, 0x12, 4, 0x11, 0x13, 0x26, 0x26, 2, 0xE, 8
        .db 0xD

; $1F9C
credit_table:     
        DEF_VRAM  0x60D                 ; screen loc
        .dw message_p1_or_2             ; "<1 OR 2 PLAYERS>
        DEF_VRAM  0x60A                 ; screen loc
        .dw message_1_coin              ; "*1 PLAYER 1  COIN"
        DEF_VRAM  0x607                 ; screen loc
        .dw message_2_coins             ; "*2 PLAYERS 2 COINS"
        .db 0xFF

; $1FA9        
message_credit:
;       "CREDIT "
        .db 2, 0x11, 4, 3, 8, 0x13, 0x26

; $1FB0 (rotated)
alien_spr_CB:        
        .db 0x00, 0x44, 0x46, 0x2B, 0x13, 0x10, 0x10, 0x11    ; "Y"
        .db 0x30, 0x78, 0xFC, 0xB6, 0xFE, 0x48, 0xB4, 0x4A    ; " "

; $1FC0 (rotated)
        .db 0x00, 0x38, 0x44, 0x08, 0x10, 0x10, 0x00, 0x10    ; "?"
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
        DEF_SPRW 16                     ; size of image
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
        DEF_SPRW 16                     ; size of image
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

; $1FF8 (rotated)
        .db 0x00, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00    ; "-"

