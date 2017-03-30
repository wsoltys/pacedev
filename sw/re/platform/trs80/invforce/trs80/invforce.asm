
; +----------------------------------------------------+
; | TRS-80 Model I/III Invasion Force (enhanced) v1.01 |
; |    - by tcdev (msmcdoug@gmail.com)                 |
; | Enhancements:                                      |
; | - ORG $5200 for disk system compatibility          |
; |   (the source code is fully relocatable)           |
; | - Mixed-case text messages throughout the game     |
; | - Fixed the Experimental Ray bug that makes        |
; |   Space Stations invisible instead of Jovians      |
; |   that was introduced in the TRS-80 port.          |
; | - Modified direction controls to map to            |
; |   more intuitive numeric keypad layout             |
; +----------------------------------------------------+
;
; Trivia: This program was written originally for the
;         8080-based SOL-20 Microcomputer in 1977 and
;         released as TREK 80.
;         Tandy obtained the source code and ported it
;         to the TRS-80 Model I, removing most of the
;         references to the Star Trek universe for
;         legal reasons.
;
; Memory Map (original):
;
; $5000-$5F89 - Code
; $5F8A-$67EE - Strings
; $67EF-$69BA - Data & Variables (mixed)
; $69BB-$6F9A - ASCII/Block Graphics
; $6F9B-$6FDF - Variable space cleared each game
; $6FE0-$6FFB - Stack
; $6FFC-$7101 - Garbage?

; Processor       : z80 []
; Target assembler: ASxxxx by Alan R. Baldwin v1.5
       .area   idaseg (ABS)
       .hd64 ; this is needed only for HD64180

; ===========================================================================

.define PLATFORM_TRS80
;.define PLATFORM_MICROBEE

; *** BUILD OPTIONS
.define BUILD_OPT_ENHANCED
.ifndef BUILD_OPT_ENHANCED
  ; (un)comment as required
  .define BUILD_OPT_MIXED_CASE
  .define BUILD_OPT_FIX_RAY_BUG
  .define BUILD_OPT_KEYPAD_DIRS
.endif
; *** end of BUILD OPTIONS

.ifdef PLATFORM_TRS80
VIDEO                   .equ    0x3C00
                        ;.org     0x5000
                        .org    0x5200
.endif

.ifdef PLATFORM_MICROBEE
VIDEO                   .equ    0xF000
; .COM file format
                        .org    0x0100
; .BEE/.TAP format
                        .org    0x0900
.endif

; *** derived - do not edit
.ifdef BUILD_OPT_ENHANCED
  .define BUILD_OPT_MIXED_CASE
  .define BUILD_OPT_FIX_RAY_BUG
  .define BUILD_OPT_KEYPAD_DIRS
.endif
; *** end of derived

  .macro XLATE_DIR
      push    hl
      ld      hl, #dir_xlate_tbl        ; dir translation table
      add     l                         ; offset to entry
      ld      l, a
      ld      a, (hl)                   ; get entry
      pop     hl
  .endm

START:                        
                        xor     a
; START OF FUNCTION CHUNK FOR handle_low_power

MAIN:
                        ld      a, #3
                        ld      (antimatter_pods), a
                        ld      a, #6
                        ld      (pod_speed), a
; clear $45 bytes @$6f9b
                        ld      hl, #antimatter_pod_tbl         ; start of scratch RAM
                        sub     a
                        ld      b, #0x45 ; 'E'                  ; length of scratch RAM

loc_5011:
                        ld      (hl), a
                        inc     hl
                        dec     b                               ; done all bytes?
                        jp      NZ, loc_5011                    ; no, loop
                        dec     a                               ; $FF
                        ld      (eot), a                        ; flag end of pod table
                        ld      sp, #STACK_WATERMARK
; display title screen, prompt for speed factor
                        ld      b, #0x20 ; ' '                  ; <SPACE>
                        call    clear_video_with_B
                        ld      de, #aEnterSpeedFact            ; "ENTER SPEED FACTOR (0(FAST)-9(SLOW))"
                        call    print_string_last_line
                        ld      hl, # VIDEO+0x100
                        ld      de, #aTitle                     ; "  INVASION FORCE  -------  RADIO SHACK "
                        call    print_string

loc_5032:
                        call    keyboard_scan
                        jp      Z, loc_5032                     ; no key, loop
                        and     #0xF                            ; low nibble of key (supposedly 0-9)
                        rlca
                        rlca                                    ; x4
                        add     a, #16                          ; x4 + 16
                        ld      (game_delay_factor), a
                        ld      a, #2
                        ld      (time_to_jovian_fire), a
                        ld      a, #0x10                        ; init number of triton missiles (10)
                        ld      (triton_misls), a
                        ld      a, #8                           ; init ion drive speed
                        ld      (ion_speed), a
                        ld      a, #0x99 ; 'ô'                  ; init power available (99%)
                        ld      (power_avail), a
                        ld      hl, # VIDEO+0x337               ; init command entry buffer (on screen)
                        ld      (cmd_entry_addr), hl
; print main display
                        ld      hl, #aMainDisplay               ; " L-R SENSOR  %-MINE   ------RADIO SHACK"...
                        ld      de, #VIDEO

loc_5061:                                                       ; get char
                        ld      a, (hl)
                        ld      (de), a                         ; write to video
                        inc     de                              ; next video address
                        inc     hl                              ; next source address
                        ld      a, d
                        cp      #0x40 ; '@'                     ; end of video?
                        jp      NZ, loc_5061                    ; no, loop
                        ld      hl, (chaser_addr)
                        ld      (hl), #0xA0 ; '†'               ; graphic at chaser location
; init power distribution
; 20, 10, 20, 20, 9, 11%
                        ld      hl, #pwr_hypr_ion
                        ld      b, #4                           ; 4 power distribution values to init

loc_5075:                                                       ; init power distibution to 20%
                        ld      (hl), #0x20 ; ' '
                        inc     hl                              ; next power value address
                        dec     b                               ; done all values?
                        jp      NZ, loc_5075                    ; no, loop
                        ld      (hl), #9                        ; init masers to 9%
                        inc     hl                              ; next pwer value address
                        ld      (hl), #0x11                     ; init triton missiles to 11%
                        ld      a, #0x10                        ; re-init lr power to 10%
                        ld      (pwr_lr_sensor), a
; zero quadrant data
                        ld      de, #300                        ; # bytes to clear
                        ld      hl, #quadrant_tbl               ; start of quadrant data

loc_508C:                                                       ; zero byte
                        ld      (hl), #0
                        inc     hl                              ; next location
                        dec     de
                        ld      a, d
                        or      e                               ; done all bytes?
                        jp      NZ, loc_508C                    ; no, loop

init_jovians_left:
                        call    rand_0_9
                        cp      #3                              ; less than 3?
                        jp      M, init_jovians_left            ; yes, regenerate
                        cp      #6                              ; greater than 5?
                        jp      P, init_jovians_left            ; yes, regenerate
                        rlca
                        rlca
                        rlca
                        rlca                                    ; (3-5)*16
                        ld      b, a
                        call    rand_0_9
                        add     a, b                            ; (3-5)*16 + rnd()
                        ld      b, a                            ; jovians left to init
                        ld      (jovians_left), a

loc_50AF:
                        call    rand_0_9
                        rlca
                        rlca
                        rlca
                        rlca
                        ld      c, a
                        call    rand_0_9
                        add     a, c                            ; random quadrant
                        push    bc
                        call    get_ptr_quadrant_A_data
                        pop     bc
                        ld      a, (hl)                         ; get warships in quadrant
                        and     a                               ; zero?
                        jp      NZ, loc_50AF                    ; no, regenerate

loc_50C5:
                        call    rand_0_9
                        cp      #5                              ; greater than 4?
                        jp      P, loc_50C5                     ; yes, regenerate
                        dec     a
                        cp      b                               ; more than jovians left?
                        jp      P, loc_50C5                     ; yes, regenerate
                        inc     a
                        ld      (hl), a                         ; init warships in quadrant
                        and     a                               ; zero?
                        jp      Z, loc_50AF                     ; yes, regenerate
                        ld      d, a
                        ld      a, b                            ; jovians left to init

loc_50DA:
                        add     a, #0x99 ; 'ô'
                        daa                                     ; all done?
                        jp      Z, init_stars                   ; yes, go
                        dec     d                               ; done for this quadrant?
                        jp      NZ, loc_50DA                    ; no, loop
                        ld      b, a                            ; update jovians left to init
                        jp      loc_50AF                        ; loop
; ---------------------------------------------------------------------------
; 0-9 stars in each quadrant

init_stars:                                                     ; quadrant data
                        ld      hl, #quadrant_tbl
                        ld      c, #100                         ; # quadrants to init

loc_50ED:
                        call    rand_0_9
                        inc     hl
                        inc     hl
                        ld      (hl), a                         ; init stars in quadrant
                        inc     hl                              ; next quadrant
                        dec     c                               ; done all quadrants?
                        jp      NZ, loc_50ED                    ; no, loop
; 1-3 space stations in the game

init_space_stations:
                        call    rand_0_9
                        and     a                               ; zero?
                        jp      Z, init_space_stations          ; yes, regenerate
                        cp      #4                              ; greater than 3?
                        jp      P, init_space_stations          ; yes, regenerate
                        ld      c, a                            ; (1-3)

loc_5105:
                        call    rand_0_9
                        rlca
                        rlca
                        rlca
                        rlca
                        ld      b, a
                        call    rand_0_9
                        add     a, b                            ; random quadrant
                        push    bc
                        call    get_ptr_quadrant_A_data
                        pop     bc
                        inc     hl                              ; space stations in quadrant
                        ld      a, (hl)
                        and     a                               ; zero?
                        jp      NZ, loc_5105                    ; no, regenerate
                        ld      (hl), #1                        ; add a space station
                        dec     c                               ; done all space stations?
                        jp      NZ, loc_5105                    ; no, loop
; init starting quadrant
                        call    rand_0_9                        ; starting quadrant X
                        ld      b, a
                        call    rand_0_9                        ; starting quadrant Y
                        rlca
                        rlca
                        rlca
                        rlca
                        add     a, b                            ; combine
                        ld      (quadrant), a                   ; init starting quadrant
                        call    print_jovians_left
                        ld      a, #3                           ; SE, flag disabled
                        ld      (disable_pod_update), a
                        ld      c, #1                           ; 1 quadrant
                        call    move_quadrant
                        call    print_quadrant
                        call    update_chaser_pods_cmd_entry
                        ld      a, (played_before)
                        and     a                               ; played a game before this?
                        jp      NZ, loc_5188                    ; yes, skip animated intro message
                        ld      de, #aHQ_Officer                ; "                     "
                        call    print_10_lines
                        ld      de, #aCommandHeadqua            ; "COMMAND HEADQUARTERS: THE JOVIANS HAVE "...
                        ld      hl, # VIDEO+0x340
                        call    print_string
; animate HQ officer
                        ld      e, #17                          ; # animation loops

loc_515C:
                        call    rnd_delay
                        ld      hl, # VIDEO+0x122               ; HQ commander's eye
                        ld      (hl), #0x88 ; 'à'
                        inc     hl
                        ld      (hl), #0x8C ; 'å'
                        ld      hl, # VIDEO+0x1E1               ; HQ commander's mouth
                        ld      (hl), #0x4F ; 'O'
                        call    rnd_delay
                        ld      hl, # VIDEO+0x122               ; HQ commander's eye
                        ld      (hl), #0xAA ; '™'
                        inc     hl
                        ld      (hl), #0xBB ; 'ª'
                        call    rand_0_9
                        cp      #9                              ; 9?
                        jp      NC, loc_5184                    ; ues, skip
                        ld      hl, # VIDEO+0x1E1               ; HQ commander's mouth
                        ld      (hl), #0x2D ; '-'

loc_5184:
                        dec     e
                        jp      NZ, loc_515C

loc_5188:                                                       ; current quadrant on LR sensor display
                        ld      hl, # VIDEO+0xC5
                        call    init_quadrant                   ; quadrant display
                        ld      hl, # VIDEO+0x340
                        ld      de, #aHyprHIonIMsrMT            ; "HYPR=H,ION=I,MSR=M,TRM=T,PWRDST=D,SELFD"...
                        call    clear_last_2_lines_print_string

game_loop:                                                      ; flag no cmd
                        ld      a, #0xFF
                        ld      (cmd_flag), a
                        ld      a, (critical)
                        and     a                               ; condition critical?
                        jp      Z, loc_51BD                     ; no, skip
                        ld      a, (engine_explode_countdown)
                        dec     a                               ; tick!
                        ld      (engine_explode_countdown), a
                        jp      P, loc_51BD                     ; set to explode? no, skip
                        ld      de, #aNavigatorTheEn            ; "NAVIGATOR:THE ENGINES ARE EXPLODING"
                        call    print_string_last_line
                        jp      print_game_over_screen
; END OF FUNCTION CHUNK FOR handle_low_power

; =============== S U B R O U T I N E =======================================


keyboard_scan:
                        push    de
                        call    0x2B                            ; KBDSCN
                        and     a                               ; set flag for key
                        pop     de
                        ret
; End of function keyboard_scan

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR handle_low_power

loc_51BD:
                        call    update_chaser_pods_cmd_entry
                        call    handle_low_power
                        ld      a, (game_delay_factor)
                        ld      b, a
                        call    delay_B_with_duty_cycle
                        sub     a                               ; flag not fired
                        ld      (maser_fired), a
                        call    update_star_time
                        jp      game_loop
; END OF FUNCTION CHUNK FOR handle_low_power
; ---------------------------------------------------------------------------

hyperdrive:
                        call    clear_last_2_lines
                        sub     a                               ; flag normal
                        ld      (jovian_time_frozen), a
                        ld      a, (hyperdrive_disabled)
                        and     a                               ; disabled?
                        jp      M, loc_5202                     ; yes, exit
                        call    rand_0_9
                        cp      #5                              ; less than 5?
                        ld      a, (pwr_hypr_ion)
                        jp      C, loc_51F4                     ; yes, skip
                        or      a                               ; zero power?
                        jp      Z, loc_51FC                     ; yes, skip
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement ion power

loc_51F4:                                                       ; update
                        ld      (pwr_hypr_ion), a
                        cp      #6                              ; greater than 5%?
                        jp      P, loc_5208                     ; yes, go

loc_51FC:                                                       ; "ENGINEER:COMMANDER, THE ENGINES HAVEN'T"...
                        ld      de, #aEngineerComman
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

loc_5202:                                                       ; "ENGINEER:THE UNKNOWN WE SHOT DISABLED T"...
                        ld      de, #aEngineerTheUnk
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

loc_5208:
                        call    rand_0_9
                        cp      #6                              ; less than 6?
                        jp      C, loc_5213                     ; yes, skip
                        call    jovian_attack_and_move

loc_5213:                                                       ; direction
                        call    get_next_cmd_char

loc_5216:                                                       ; less than '0'?
                        sub     #0x30 ; '0'
                        ld      b, a
                        jp      M, print_no_sense_and_ret       ; yes, exit
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        cp      #8                              ; greater than 7?
.else
                        jp      Z, print_no_sense_and_ret       ; 0, exit
                        cp      #5
                        jp      Z, print_no_sense_and_ret
                        cp      #10                             ; greater than 9?
.endif                        
                        jp      P, print_no_sense_and_ret       ; yes, exit
.ifdef BUILD_OPT_KEYPAD_DIRS                        
                        XLATE_DIR
.endif

loc_5221:
                        push    bc
                        ld      a, b                            ; direction
                        ld      c, #1                           ; move 1 quadrant
                        call    move_quadrant
                        call    print_quadrant
                        ld      hl, # VIDEO+0xC5                ; current quadrant in LR sensor
                        call    init_quadrant
                        call    print_sector
                        ld      b, #8
                        call    delay_B_and_update_all
                        pop     bc
                        call    keyboard_scan
                        jp      Z, loc_5221                     ; no key, loop
                        cp      #9                              ; tab?
                        ret     Z                               ; yes, return
                        jp      loc_5216                        ; loop
; ---------------------------------------------------------------------------

ion_engine:
                        ld      a, (pwr_hypr_ion)
                        cp      #5                              ; less than 5%?
                        jp      M, loc_51FC                     ; yes, exit
                        call    rand_0_9
                        cp      #3                              ; greater than 2?
                        jp      NC, loc_5259                    ; yes, skip
                        call    jovian_attack_and_move

loc_5259:
                        call    clear_last_2_lines
                        call    get_next_cmd_char               ; direction

get_dir:                                                        ; digit?
                        sub     #0x30 ; '0'
                        jp      M, print_no_sense_and_ret       ; no, exit
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        cp      #8                              ; greater than 7?
.else
                        jp      Z, print_no_sense_and_ret       ; 0, exit
                        cp      #5
                        jp      Z, print_no_sense_and_ret
                        cp      #10                             ; greater than 9?
.endif                        
                        jp      P, print_no_sense_and_ret       ; yes, exit
.ifdef BUILD_OPT_KEYPAD_DIRS                        
                        XLATE_DIR
.endif
                        ld      c, a                            ; tmp store direction
                        call    get_next_cmd_char               ; speed
                        jp      Z, loc_527F                     ; not specified, skip
                        sub     #0x30 ; '0'                     ; digit?
                        jp      M, print_no_sense_and_ret       ; no, exit
                        cp      #10                             ; greater than 9?
                        jp      NC, print_no_sense_and_ret      ; yes, exit
                        inc     a
                        inc     a                               ; speed += 2
                        ld      (ion_speed), a                  ; store

loc_527F:
                        ld      hl, #dir_addr_delta_tbl
                        ld      a, c                            ; direction
                        ld      (ion_dir), a                    ; save
                        and     a                               ; up?
                        jp      Z, loc_5290                     ; yes, skip

loc_528A:
                        inc     hl
                        inc     hl                              ; next table entry
                        dec     a                               ; done?
                        jp      NZ, loc_528A                    ; no, loop

loc_5290:
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)                         ; DE = video address delta
                        ld      hl, (hephaestus_video_addr)

loc_5296:                                                       ; write empty star to quadrant display
                        ld      (hl), #0x2E ; '.'
                        push    hl                              ; save old address
                        add     hl, de                          ; update USS Hephaestus video address
                        ld      a, (hl)                         ; get sector contents
                        and     #0x7F ; ''
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, loc_52C3                    ; no, skip
                        ld      (hl), #0x5B ; '['               ; USS Hephaestus graphic
                        ld      a, (ion_speed)
                        ld      b, a
                        call    delay_B_and_update_all
                        ex      (sp), hl                        ; push new address, HL = old address
                        pop     hl                              ; pop new address
                        ld      (hephaestus_video_addr), hl     ; update
                        call    keyboard_scan
                        jp      Z, loc_5296                     ; no key, loop
                        cp      #9                              ; <TAB>?
                        jp      NZ, get_dir                     ; no, loop
                        ld      (hl), #0x5B ; '['               ; write USS Hephaestus graphic to video
                        ld      (hephaestus_video_addr), hl     ; update
                        jp      print_sector
; ---------------------------------------------------------------------------

loc_52C3:                                                       ; old address
                        pop     hl
                        ld      (hephaestus_video_addr), hl     ; update (stop)
                        push    de
                        call    print_sector
                        pop     de
                        ld      hl, (hephaestus_video_addr)
                        ld      (hl), #0x5B ; '['               ; display USS Hephaestus graphic
                        add     hl, de                          ; (potential) new address
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x8F ; 'è'                     ; ???
                        jp      Z, loc_530C
                        and     #0x7F ; ''
                        cp      #0x30 ; '0'                     ; space station?
                        jp      Z, dock_space_station           ; yes, go
                        cp      #0x25 ; '%'                     ; triton mine
                        jp      Z, hit_triton_mine              ; yes, go
                        cp      #0x26 ; '&'                     ; jovian battle cruiser?
                        jp      Z, hit_jovian_warship           ; yes, go
                        cp      #0x40 ; '@'                     ; jovian command cruiser?
                        jp      Z, hit_jovian_warship           ; yes, go
                        cp      #0x2A ; '*'                     ; star?
                        jp      Z, hit_star                     ; yes, go
                        cp      #0x58 ; 'X'                     ; unknown?
                        jp      NZ, left_quadrant               ; no, go
                        ld      a, #0xFF                        ; flag as blocked
                        ld      (blocked_by_unknown), a
                        push    hl
                        ld      de, #aFirstOfficer_0            ; "FIRST OFFICER:CAPTAIN, WE HAVE BEEN BLO"...
                        call    print_string_last_line
                        ld      b, #8
                        call    delay_B_with_duty_cycle
                        jp      loc_5570
; ---------------------------------------------------------------------------

loc_530C:                                                       ; zero power
                        xor     a
                        ld      (pwr_lr_sensor), a
                        ld      (pwr_sr_sensor), a
                        dec     a                               ; flag malfunctioned
                        ld      (computer_malfunction), a

left_quadrant:                                                  ; direction
                        ld      a, (ion_dir)
                        ld      c, #1                           ; 1 quadrant
                        call    move_quadrant
                        call    print_quadrant
                        ld      hl, # VIDEO+0xC5                ; current quadrant on LR sensor
                        call    init_quadrant
                        jp      print_sector
; ---------------------------------------------------------------------------

dock_space_station:                                             ; "COMMUNICATIONS:THE SPACE STATION HAS AC"...
                        ld      de, #aCommunications
                        call    print_string_last_line
                        sub     a                               ; A=0
                        ld      (critical), a                   ; flag OK
                        ld      (always_zero), a
                        ld      (delay_duty_cycle_i), a
                        ld      hl, # VIDEO+0xBB
                        ld      de, #aDock                      ; " DOCK"
                        call    print_string
                        ld      b, #26
                        call    delay_B_with_duty_cycle
                        ld      a, #0x99 ; 'ô'                  ; full power
                        ld      (power_avail), a
                        call    print_power_avail
                        call    update_power_distribution
                        ld      hl, # VIDEO+0x17D               ; triton misls value video address
                        ld      (hl), #0x31 ; '1'
                        inc     hl
                        ld      (hl), #0x30 ; '0'               ; display '10'
                        ld      a, #0x10                        ; max triton missiles
                        ld      (triton_misls), a
                        ld      a, #3
                        ld      (unused_69BA), a
                        ld      (antimatter_pods), a
                        ld      hl, # VIDEO+0x23E               ; antimatter pods value video address
                        call    print_BCD_byte                  ; display antimatter pods
                        ld      hl, #antimatter_pod_tbl
                        ld      de, #6                          ; offset to next byte
                        ld      b, #3                           ; bytes to clear

loc_5377:                                                       ; flag pod unused
                        ld      (hl), #0
                        add     hl, de                          ; next entry
                        dec     b                               ; done all bytes?
                        jp      NZ, loc_5377                    ; no, loop
                        sub     a
                        ld      (hyperdrive_disabled), a        ; repair hyperdrive
                        ld      (computer_malfunction), a       ; repair malfunction
                        jp      clear_last_2_lines
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR fire_maser

hit_triton_mine:                                                ; "FIRST OFFICER: SIR, WE HAVE HIT A TRITO"...
                        ld      de, #aFirstOfficerSi
                        call    print_string_last_line
; END OF FUNCTION CHUNK FOR fire_maser
; START OF FUNCTION CHUNK FOR handle_low_power

print_game_over_screen:                                         ; -1
                        sub     a
                        ld      (cmd_flag), a                   ; disable cmd entry
                        call    animate_destruction
                        ld      b, #0x20 ; ' '                  ; <SPACE>
                        call    clear_video_with_B
                        ld      de, #aHQ_Officer                ; "                     "
                        call    print_10_lines
                        ld      de, #aShipLogUssPhae            ; "SHIP LOG-USS PHAETON-CAPTAIN DAR: SENSO"...
                        ld      hl, # VIDEO+0x380
                        call    print_string
                        ld      b, #17                          ; delay outer loop counter

loc_53AB:                                                       ; delay inner loop counter
                        ld      de, #0

delay:
                        dec     de
                        ld      a, d
                        or      e
                        jp      NZ, delay
                        dec     b
                        jp      NZ, delay
                        ld      a, #1                           ; flag as played
                        ld      (played_before), a
                        jp      MAIN
; END OF FUNCTION CHUNK FOR handle_low_power
; ---------------------------------------------------------------------------
played_before:          .db 0
; ---------------------------------------------------------------------------

hit_jovian_warship:                                             ; "                     "
                        ld      de, #aJovian_Officer
                        call    print_10_lines
                        ld      de, #aJovianWatchWhe            ; "JOVIAN: WATCH WHERE YOU ARE GOING YOU T"...
                        call    print_string_last_line
                        ld      de, #aCommunicatio_0            ; "COMMUNICATIONS:SIR, WE MADE CONTACT WIT"...
                        ld      hl, # VIDEO+0x380
                        call    print_string
                        ld      a, #1                           ; flag disabled
                        ld      (disable_pod_update), a
                        ld      e, #20                          ; 20 iterations

loc_53DD:
                        call    rnd_delay
; animate jovian officer
                        ld      hl, # VIDEO+0x15F
                        ld      (hl), #0x8C ; 'å'
                        inc     hl
                        ld      (hl), #0x84 ; 'Ñ'
                        inc     hl
                        inc     hl
                        ld      (hl), #0xAA ; '™'
                        inc     hl
                        ld      (hl), #0xBB ; 'ª'
                        ld      hl, # VIDEO+0x1E1
                        ld      (hl), #0x3D ; '='
                        call    rnd_delay
                        ld      hl, # VIDEO+0x15F
                        ld      (hl), #0xB7 ; '∑'
                        inc     hl
                        ld      (hl), #0x95 ; 'ï'
                        inc     hl
                        inc     hl
                        ld      (hl), #0x88 ; 'à'
                        inc     hl
                        ld      (hl), #0x8C ; 'å'
                        ld      hl, # VIDEO+0x1E1
                        ld      (hl), #0x4F ; 'O'
                        call    update_chaser_pods_cmd_entry
                        dec     e                               ; done animation?
                        jp      NZ, loc_53DD                    ; no, loop
                        ld      hl, # VIDEO+0xC5                ; ptr current quadrant on LR sensor
                        jp      init_quadrant                   ; randomise again!
; ---------------------------------------------------------------------------

hit_star:                                                       ; "NAVIGATOR:WE HIT A STAR!?!"
                        ld      de, #aNavigatorWeHit
                        call    print_string_last_line
; *** BUG #001 - in original SOL-20 source code
; this value is an index into a duty cycle table
; which only has 4 entries
; - can only assume it's picking up a garbage value
                        ld      a, #17
                        ld      (delay_duty_cycle_i), a
                        ld      b, a
                        call    delay_B_with_duty_cycle
                        jp      print_game_over_screen
; ---------------------------------------------------------------------------

maser:
                        call    clear_last_2_lines
                        ld      a, #0xFF                        ; flag fired
                        ld      (maser_fired), a
                        ld      a, (pwr_masers)
                        cp      #8                              ; less than 8%?
                        jp      P, loc_5440                     ; no, skip
                        ld      de, #aEngineerComm_0            ; "ENGINEER:COMMANDER, WE HAVEN'T THE POWE"...
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

loc_5440:                                                       ; direction
                        call    get_next_cmd_char
                        sub     #0x30 ; '0'                     ; digit?
                        jp      M, print_no_sense_and_ret       ; no, exit
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        cp      #8                              ; greater than 7?
.else
                        jp      Z, print_no_sense_and_ret       ; 0, exit
                        cp      #5
                        jp      Z, print_no_sense_and_ret
                        cp      #10                             ; greater than 9?
.endif                        
                        jp      P, print_no_sense_and_ret       ; yes, exit
.ifdef BUILD_OPT_KEYPAD_DIRS                        
                        XLATE_DIR
.endif

; =============== S U B R O U T I N E =======================================


fire_maser:

; FUNCTION CHUNK AT 5388 SIZE 00000006 BYTES

                        ld      hl, #dir_addr_delta_tbl
                        and     a                               ; up?
                        jp      Z, loc_545A                     ; yes, exit

loc_5454:
                        inc     hl
                        inc     hl                              ; next table entry
                        dec     a                               ; done?
                        jp      NZ, loc_5454                    ; no, loop

loc_545A:
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)                         ; DE = delta
                        ld      a, (delay_duty_cycle_i)
                        ld      (tmp_delay_cycle), a
                        ld      a, #2
                        ld      (delay_duty_cycle_i), a
                        ld      hl, (hephaestus_video_addr)
                        ld      b, #0                           ; init maser path length
                        push    de

move_maser:                                                     ; add delta
                        add     hl, de
                        ld      a, (hl)                         ; get sector contents
                        ld      (tmp_sector_contents), a
                        ld      (hl), #0xBF ; 'ø'               ; write maser graphic to video
                        push    bc
                        ld      b, #1
                        call    delay_B_and_update_all
                        pop     bc
                        ld      a, (tmp_sector_contents)
                        and     #0x7F ; ''
                        inc     b                               ; inc maser path length
                        cp      #0x2E ; '.'                     ; empty sector?
                        jp      Z, move_maser                   ; yes, loop
                        cp      #0x26 ; '&'                     ; jovian battle cruiser?
                        jp      Z, maser_hit_jovian             ; yes, go
                        cp      #0x25 ; '%'
                        jp      Z, hit_triton_mine
                        cp      #0x58 ; 'X'
                        jp      NZ, maser_miss                  ; no, go
                        pop     de
                        push    hl
                        ld      hl, #loc_54A0                   ; return address
                        ex      (sp), hl
                        push    de
                        jp      wipe_maser
; ---------------------------------------------------------------------------

loc_54A0:
                        jp      shot_hit_unknown
; ---------------------------------------------------------------------------

maser_miss:                                                     ; "FIRST OFFICER:SIR, MY SENSORS SHOW MASE"...
                        ld      de, #aFirstOfficer_1
                        push    bc
                        call    print_string_last_line
                        pop     bc
                        jp      wipe_maser
; ---------------------------------------------------------------------------

maser_hit_jovian:
                        call    rand_0_9
                        cp      #7                              ; less than 7?
                        jp      M, wipe_maser                   ; yes, go
                        ld      (hl), #0xAE ; 'Æ'
                        ld      a, #0x2E ; '.'                  ; empty sector
                        ld      (tmp_sector_contents), a
                        push    bc
                        call    dec_jovians
                        pop     bc
                        ld      a, (VIDEO+0xC5)                 ; warships in current quadrant of LR sensor
                        dec     a                               ; adjust
                        ld      (VIDEO+0xC5), a                 ; update

wipe_maser:
                        call    update_chaser_pods_cmd_entry
                        pop     de
                        ld      hl, (hephaestus_video_addr)

loc_54D0:                                                       ; add delta
                        add     hl, de
                        ld      a, (hl)                         ; get sector contents
                        ld      a, #0x2E ; '.'                  ; empty
                        ld      (hl), a                         ; write to video
                        push    bc
                        ld      b, #1
                        call    delay_B_and_update_all
                        pop     bc
                        dec     b                               ; done path?
                        jp      NZ, loc_54D0                    ; no, loop
                        ld      a, (tmp_sector_contents)
                        ld      (hl), a                         ; write to video
                        ld      a, (tmp_delay_cycle)
                        ld      (delay_duty_cycle_i), a
                        ret
; End of function fire_maser

; ---------------------------------------------------------------------------

triton_missile:
                        call    clear_last_2_lines
                        call    dec_triton_misls_and_print
                        jp      C, print_no_more_triton_misls   ; no missiles, exit
                        ld      a, (pwr_trt_missl)
                        cp      #10                             ; less than 10%?
                        jp      P, triton_pwr_ok                ; no, skip

loc_54FC:                                                       ; "ENGINEER:COMMANDER, THE MISSILE TUBES A"...
                        ld      de, #aEngineerComm_1
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

triton_pwr_ok:                                                  ; direction
                        call    get_next_cmd_char
                        sub     #0x30 ; '0'                     ; digit?
                        jp      M, print_no_sense_and_ret       ; no, exit
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        cp      #8                              ; greater than 7?
.else
                        jp      Z, print_no_sense_and_ret       ; 0, exit
                        cp      #5
                        jp      Z, print_no_sense_and_ret
                        cp      #10                             ; greater than 9?
.endif                        
                        jp      P, print_no_sense_and_ret       ; yes, exit
.ifdef BUILD_OPT_KEYPAD_DIRS                        
                        XLATE_DIR
.endif

; =============== S U B R O U T I N E =======================================


move_triton_missile:

; FUNCTION CHUNK AT 5585 SIZE 00000017 BYTES
; FUNCTION CHUNK AT 5662 SIZE 00000014 BYTES
; FUNCTION CHUNK AT 5842 SIZE 0000000F BYTES

                        ld      hl, #dir_addr_delta_tbl
                        and     a                               ; up?
                        jp      Z, loc_551C                     ; yes, skip

loc_5516:
                        inc     hl
                        inc     hl                              ; next tbl entry
                        dec     a                               ; done?
                        jp      NZ, loc_5516                    ; no, loop

loc_551C:
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)                         ; DE = delta
                        ld      hl, (hephaestus_video_addr)

loc_5522:                                                       ; add delta
                        add     hl, de
                        ld      a, (hl)                         ; get sector contents
                        and     #0x7F ; ''
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, loc_553F                    ; no, skip
                        ld      (hl), #0x2B ; '+'               ; write missile graphic to video
                        ld      b, #6
                        call    delay_B_and_update_all
                        ld      (hl), #0x2E ; '.'               ; write empty sector to video
                        call    keyboard_scan                   ; any key?
                        jp      Z, loc_5522                     ; no, loop
                        cp      #9                              ; <TAB>?
                        jp      NZ, loc_5522                    ; no, loop

loc_553F:                                                       ; get sector contents
                        ld      a, (hl)
                        ld      (tmp_sector_contents), a
                        or      #0x80 ; 'Ä'
                        ld      (hl), a                         ; animate
                        ld      b, #6
                        call    delay_B_and_update_all
                        ld      a, (hl)                         ; *** dead code
                        ld      a, (tmp_sector_contents)
                        ld      (hl), a                         ; restore contents
                        cp      #0x30 ; '0'                     ; space station?
                        jp      Z, missile_destroyed_object     ; yes, go
                        cp      #0x26 ; '&'                     ; jovian battle cruiser?
                        jp      Z, missile_hit_jovian           ; yes, go
                        cp      #0x25 ; '%'                     ; triton mine?
                        jp      Z, hit_triton_mine              ; yes, go
                        cp      #0x58 ; 'X'                     ; unknown?
                        jp      Z, shot_hit_unknown             ; yes, go
                        cp      #0x5B ; '['                     ; USS Hephaestus?
                        jp      Z, power_minus_2_and_update     ; yes, go
                        ld      de, #aComputerTriton            ; "COMPUTER:TRITON MISSILE HAS NO EFFECT"
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

shot_hit_unknown:                                               ; sector video address
                        push    hl

loc_5570:                                                       ; random entry
                        call    rand_0_9
                        and     a                               ; zero?
                        jp      Z, finish_shot                  ; yes, go
                        ld      hl, #missile_hit_unknown_tbl-2

loc_557A:                                                       ; found entry?
                        dec     a
                        inc     hl
                        inc     hl
                        jp      NZ, loc_557A                    ; no, loop
; End of function move_triton_missile

; START OF FUNCTION CHUNK FOR update_chaser_pods_cmd_entry

jump_HL_vector:
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a                            ; HL=vector address
                        jp      (hl)
; END OF FUNCTION CHUNK FOR update_chaser_pods_cmd_entry
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR move_triton_missile

finish_shot:
                        pop     hl
                        ld      a, (blocked_by_unknown)
                        and     a                               ; blocked?
                        jp      P, loc_5592                     ; no, skip
                        xor     a                               ; flag OK
                        ld      (blocked_by_unknown), a
                        ret
; ---------------------------------------------------------------------------

loc_5592:                                                       ; *** dead code
                        ld      a, (maser_fired)
                        sub     a                               ; flag not fired
                        ld      (maser_fired), a
                        jp      missile_destroyed_object
; END OF FUNCTION CHUNK FOR move_triton_missile
; ---------------------------------------------------------------------------
; Either
; * maser fired, rebounds in random direction, or
; * if blocked, removes Hephaestus & object from display, or
; * fires triton missile in random direction


missile_hit_unk_079:
                        ld      a, (maser_fired)
                        and     a                               ; fired?
                        ld      hl, (hephaestus_video_addr)
                        ex      (sp), hl                        ; swap with sector video address
                        ld      (hephaestus_video_addr), hl     ; store as hephaestrus address (for fire)
                        jp      P, loc_55B8                     ; not fired, skip

loc_55AA:                                                       ; dir
                        call    rand_0_9
                        cp      #8                              ; greater than 7?
                        jp      P, loc_55AA                     ; yes, regenerate
                        call    fire_maser                      ; A=dir from unknown object
                        jp      loc_55D0
; ---------------------------------------------------------------------------

loc_55B8:
                        ld      a, (blocked_by_unknown)
                        or      a                               ; blocked?
                        jp      P, loc_55C5                     ; no, go
                        ld      (hl), #0x2E ; '.'               ; write empty sector to video (unknown object)
                        pop     hl                              ; hephaestus video address
                        ld      (hl), #0x2E ; '.'               ; write empty sector to video
                        ret
; ---------------------------------------------------------------------------

loc_55C5:                                                       ; dir
                        call    rand_0_9
                        cp      #8                              ; greater than 7?
                        jp      P, loc_55C5                     ; yes, regenerate
                        call    move_triton_missile

loc_55D0:                                                       ; hephaestus video address
                        pop     hl
                        ld      (hephaestus_video_addr), hl     ; restore
                        ret
; ---------------------------------------------------------------------------
; * sets all objects to unknown
; * randomly disables hyperdrive

missile_hit_unk_1:                                              ; unknown graphic
                        ld      a, #0x58 ; 'X'
                        ld      (loc_55EA+1), a                 ; patch!

loc_55DA:                                                       ; top-left '.' in quadrant display
                        ld      hl, # VIDEO+0x57
                        ld      de, #0x2B ; '+'                 ; offset to next line of quadrant display
                        ld      b, #10                          ; 10 rows to update

loc_55E2:                                                       ; 21 columns to update
                        ld      c, #21

loc_55E4:                                                       ; get sector contents
                        ld      a, (hl)
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, loc_55EC                    ; no, skip
; the object graphic is patched (X/%)

loc_55EA:                                                       ; write object graphic to video
                        ld      (hl), #0x58 ; 'X'

loc_55EC:                                                       ; done all columns?
                        dec     c
                        inc     hl                              ; next video address
                        jp      NZ, loc_55E4                    ; no, loop
                        add     hl, de                          ; next row video address
                        dec     b                               ; done all rows?
                        jp      NZ, loc_55E2                    ; no, loop
                        call    rand_0_9
                        cp      #5                              ; greater than 4?
                        jp      NC, loc_5603                    ; yes, skip
                        ld      a, #0xFF                        ; flag disabled
                        ld      (hyperdrive_disabled), a

loc_5603:
                        pop     hl
                        ret
; ---------------------------------------------------------------------------
; * sets all objects to triton mines
; * randomly disables hyperdrive

missile_hit_unk_2:                                              ; triton mine
                        ld      a, #0x25 ; '%'
                        ld      (loc_55EA+1), a                 ; patch
                        jp      loc_55DA
; ---------------------------------------------------------------------------
; randomly either:
; * changes unknown to space station, or
; * jumps to option 4

missile_hit_unk_6:
                        call    rand_0_9
                        cp      #5                              ; less than 5?
                        jp      C, missile_hit_unk_4            ; yes, go
                        pop     hl                              ; unknown object address
                        ld      (hl), #0x30 ; '0'               ; is now a space station!
                        ret
; ---------------------------------------------------------------------------
; warps to a random quadrant

missile_hit_unk_3:
                        call    rand_0_9
                        rlca
                        rlca
                        rlca
                        rlca
                        ld      b, a
                        call    rand_0_9
                        add     a, b                            ; random quadrant
                        ld      (quadrant), a                   ; store as current
                        ld      a, #3                           ; direction=SE
                        ld      c, #1                           ; 1 quadrant
                        call    move_quadrant
                        ld      hl, # VIDEO+0xC5                ; current quadrant LR sensor
                        call    init_quadrant
                        call    print_quadrant
                        call    print_sector
                        pop     hl                              ; discard
                        ret
; ---------------------------------------------------------------------------
; rolls the dice again!?!

missile_hit_unk_4:                                              ; *** dead code
                        call    rand_0_9
                        call    rnd_delay
                        jp      loc_5570                        ; roll the dice again!
; ---------------------------------------------------------------------------
; randomly decrement power

missile_hit_unk_58:                                             ; "FIRST OFFICER: THE UNKNOWN IS STEALING "...
                        ld      de, #aFirstOfficer_2
                        call    print_string_last_line
                        pop     hl                              ; discard

loc_564D:
                        call    rand_0_9
                        cp      #4                              ; less than 4?
                        jp      C, loc_565D                     ; yes, go
                        ld      b, #18                          ; *** dead code
                        call    jovian_attack_and_move
                        jp      loc_564D                        ; again
; ---------------------------------------------------------------------------

loc_565D:                                                       ; *** dead code
                        ld      b, #25
                        jp      clear_last_2_lines              ; wipe the message
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR move_triton_missile

missile_hit_jovian:
                        push    hl
                        call    dec_jovians
                        ld      a, (VIDEO+0xC5)                 ; warships in quadrant, LR sensor
                        dec     a                               ; adjust
                        ld      (VIDEO+0xC5), a                 ; update
                        pop     hl                              ; object video address
; the object is not removed from any data table
; - confirmed; re-enter the quadrant and it's back!

missile_destroyed_object:                                       ; write empty sector to video
                        ld      (hl), #0x2E ; '.'
                        ld      de, #aComputerObject            ; "COMPUTER:OBJECT DESTROYED"
                        jp      print_string_last_line
; END OF FUNCTION CHUNK FOR move_triton_missile
; ---------------------------------------------------------------------------

print_no_more_triton_misls:                                     ; "WEAPONRY:SIR, WE HAVE NO MORE TRITON MI"...
                        ld      de, #aWeaponrySirWeH
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

power_distrib:                                                  ; flag OK
                        sub     a
                        ld      (critical), a
                        call    clear_last_2_lines
                        call    get_next_cmd_char               ; get subcmd
                        ld      hl, #pwr_subcmd_tbl             ; "HLSDMT"
                        ld      de, #pwr_hypr_ion
                        ld      b, a                            ; subcmd

loc_568D:                                                       ; subcmd entry from table
                        ld      a, (hl)
                        and     a                               ; end of table?
                        jp      Z, print_no_sense_and_ret       ; yes, exit
                        cp      b                               ; found it?
                        jp      Z, pwr_subcmd_ok                ; yes, go
                        inc     hl                              ; next entry in tbl
                        inc     de                              ; next power value
                        jp      loc_568D                        ; loop
; ---------------------------------------------------------------------------

pwr_subcmd_ok:                                                  ; get next char
                        call    get_next_cmd_char
                        jp      Z, loc_56A3                     ; none, skip
                        sub     #0x30 ; '0'                     ; convert to binary

loc_56A3:
                        ld      b, a
                        call    get_next_cmd_char               ; get next char
                        jp      NZ, loc_56B0                    ; non-zero, skip
                        ld      c, b
                        ld      b, #0                           ; B,C=value
                        jp      loc_56B3
; ---------------------------------------------------------------------------

loc_56B0:                                                       ; convert to binary
                        sub     #0x30 ; '0'
                        ld      c, a

loc_56B3:
                        ld      a, b
                        rrca
                        rrca
                        rrca
                        rrca
                        or      c                               ; convert to BCD byte
                        ld      (de), a                         ; store in power settings

; =============== S U B R O U T I N E =======================================


update_power_distribution:
                        ld      b, #6                           ; 6 power values
                        ld      de, # VIDEO+0x1CD               ; HYPR&ION value
                        sub     a                               ; flag OK
                        ld      (power_overflow), a
                        ld      hl, #pwr_hypr_ion

loc_56C6:                                                       ; add power value
                        add     a, (hl)
                        daa
                        jp      NC, loc_56D0                    ; skip if no overflow
                        ld      a, #0xFF                        ; flag overflow
                        ld      (power_overflow), a

loc_56D0:                                                       ; store total
                        ld      c, a
                        ld      a, (hl)                         ; get power value
                        rrca
                        rrca
                        rrca
                        rrca                                    ; high->low nibble
                        and     #0xF                            ; nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (de), a                         ; write to video
                        inc     de                              ; next video address
                        ld      a, (hl)
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (de), a                         ; write to video
                        push    hl
                        ld      hl, #0x3F ; '?'
                        add     hl, de                          ; next line
                        ex      de, hl                          ; DE = video address
                        pop     hl
                        dec     b                               ; done all power values?
                        inc     hl                              ; next power value
                        ld      a, c                            ; restore total
                        jp      NZ, loc_56C6                    ; no, loop
                        ld      b, a                            ; get total
                        ld      a, (power_overflow)
                        and     a                               ; overflow?
                        jp      M, loc_56FC                     ; yes, go
                        ld      a, (power_avail)
                        cp      b                               ; more than available power?
                        ret     NC                              ; no, return

loc_56FC:                                                       ; "ENGINEER:COMMANDER, THE ENGINES ARE OVE"...
                        ld      de, #aEngineerComm_2
                        ld      hl, # VIDEO+0x380
                        call    clear_last_2_lines_print_string
                        ld      b, #16
                        call    delay_B_with_duty_cycle
                        ld      a, (critical)
                        and     a                               ; exploding?
                        ret     M                               ; yes, return

loc_570F:
                        call    rand_0_9
                        cp      #4                              ; less than 4?
                        jp      C, loc_570F                     ; yes, regenerate
                        ld      (engine_explode_countdown), a
                        ld      a, #0xFF                        ; flag exploding
                        ld      (critical), a
                        ld      a, #3
                        ld      (delay_duty_cycle_i), a
                        ld      hl, # VIDEO+0xBB                ; ptr to condition value
                        ld      de, #aCrtcl                     ; "CRTCL"
                        call    clear_last_2_lines_print_string
                        jp      update_chaser_pods_cmd_entry
; End of function update_power_distribution

; ---------------------------------------------------------------------------

self_destruct:                                                  ; "COMPUTER:SELF DESTRUCT SEQUENCE INITIAT"...
                        ld      de, #aComputerSelfDe
                        call    print_string_last_line
                        ld      e, #0x15                        ; 15 sec countdown
                        ld      hl, # VIDEO+0x3EB               ; self destruct countdown video address

loc_573B:
                        ld      b, #16
                        call    delay_B_and_update_all
                        ld      a, e                            ; countdown
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement
                        ld      e, a                            ; update
                        rrca
                        rrca
                        rrca
                        rrca
                        and     #0xF                            ; high->low nibble
                        add     a, #0x30 ; '0'                  ; convert to ASCII
                        ld      (hl), a                         ; write to video
                        inc     hl                              ; next video address
                        ld      a, e
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII
                        ld      (hl), a                         ; write to video
                        dec     hl                              ; restore video address
                        ld      a, e
                        and     a                               ; done countdown?
                        jp      Z, print_game_over_screen       ; yes, exit
                        cp      #6                              ; less than 6s left?
                        jp      M, loc_573B                     ; yes, loop
                        call    keyboard_scan                   ; any key?
                        jp      Z, loc_573B                     ; no, loop
                        cp      #9                              ; <TAB>?
                        jp      NZ, loc_573B                    ; no, loop
                        ld      de, #aComputerSelf_0            ; "COMPUTER:SELF DESTRUCT SEQUENCE ABORTED"
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

experimental_ray:
                        ld      a, (experimental_ray_disabled)
                        and     a                               ; disabled?
                        jp      P, loc_577E                     ; no, go
                        ld      de, #aIsPermanentlyD            ; "IS PERMANENTLY DISABLED"
                        jp      print_experimental_ray_outcome
; ---------------------------------------------------------------------------

loc_577E:
                        call    rand_0_9
                        and     a                               ; zero?
                        jp      Z, expr_9                       ; yes, go
                        ld      de, #expr_tbl-2

loc_5788:                                                       ; found vector?
                        dec     a
                        inc     de
                        inc     de                              ; next vector entry
                        jp      NZ, loc_5788                    ; no, loop
                        ex      de, hl
                        jp      jump_HL_vector                  ; go
; ---------------------------------------------------------------------------
; launches a triton missile in a circle

expr_9:                                                         ; "IS FIRING TRITON MISSILES"
                        ld      de, #aIsFiringTriton
                        call    print_experimental_ray_outcome
                        ld      a, #7                           ; dir=NW

loc_579A:
                        push    af
                        call    move_triton_missile
                        pop     af
                        dec     a                               ; next direction
                        jp      NZ, loc_579A                    ; loop all directions
                        jp      move_triton_missile
; ---------------------------------------------------------------------------
; converts all characters to graphics (distort)

expr_0:                                                         ; "CAUSED A CHANGE IN SPACIAL     STRUCTUR"...
                        ld      de, #aCausedAChangeI
                        call    print_experimental_ray_outcome
                        ld      a, #1                           ; flag disabled
                        ld      (disable_pod_update), a
                        ld      de, #0x2B ; '+'                 ; offset to next row in quadrant display
                        ld      hl, # VIDEO+0x57                ; ptr first sector in quadrant display
                        ld      b, #10                          ; 10 rows

loc_57B9:                                                       ; 21 columns
                        ld      c, #21

loc_57BB:                                                       ; get sector contents
                        ld      a, (hl)
                        add     a, #0x80 ; 'Ä'                  ; make graphic
                        ld      (hl), a                         ; write to video
                        inc     hl                              ; next video address
                        dec     c                               ; done all columns?
                        jp      NZ, loc_57BB                    ; no, loop
                        add     hl, de                          ; ptr next row
                        dec     b                               ; done all rows?
                        jp      NZ, loc_57B9                    ; no, loop
                        ret
; ---------------------------------------------------------------------------
; freezes time for jovians in this quadrant

expr_1:                                                         ; "HAS FROZEN TIME FOR THE        JOVIANS"
                        ld      de, #aHasFrozenTimeF
                        ld      a, #0xFF                        ; flag frozen
                        ld      (jovian_time_frozen), a
                        jp      print_experimental_ray_outcome
; ---------------------------------------------------------------------------
; *** BUG #002 - introduced in TRS-80 version
; this is supposed to make jovians invisible
; - but it looks like it makes space stations invisible???

expr_2:                                                         ; "HAS CAUSED THE JOVIANS TO      BECOME I"...
                        ld      de, #aHasCausedTheJo
                        call    print_experimental_ray_outcome
                        ld      hl, # VIDEO+0x57                ; first sector in quadrant video address
                        ld      de, #0x2B ; '+'                 ; offset to next quadrant row
                        ld      b, #10                          ; 10 rows

loc_57E3:                                                       ; 21 columns
                        ld      c, #21

loc_57E5:                                                       ; get object from video
                        ld      a, (hl)
.ifndef BUILD_OPT_FIX_RAY_BUG
                        cp      #0x30 ; '0'                     ; space station?
.else
                        cp      #0x26 ; '&'                     ; jovian battle cruiser?
                        jp      Z, invisible                    ; yes, wipe
                        cp      #0x40 ; '@'                     ; jovian command cruiser?
.endif                        
                        jp      NZ, loc_57ED                    ; no, continue
invisible:                        
                        ld      (hl), #0x2E ; '.'               ; write empty sector to video

loc_57ED:                                                       ; next video address
                        inc     hl
                        dec     c                               ; done all columns?
                        jp      NZ, loc_57E5                    ; no, loop
                        add     hl, de                          ; next quadrant row video address
                        dec     b                               ; done all rows?
                        jp      NZ, loc_57E3                    ; no, loop
                        ret
; ---------------------------------------------------------------------------
; re-randomises the quadrant

expr_3:                                                         ; "HAS JUMBLED THE QUADRANT"
                        ld      de, #aHasJumbledTheQ
                        call    print_experimental_ray_outcome
                        ld      hl, # VIDEO+0xC5                ; current quadrant in LR sensor
                        jp      init_quadrant
; ---------------------------------------------------------------------------
; destroys all Jovians in quadrant

expr_4:
                        ld      hl, # VIDEO+0x380
                        ld      de, #aHasDestroyedAl            ; "HAS DESTROYED ALL THE          JOVIANS "...
                        call    print_experimental_ray_outcome
                        ld      a, (quadrant)
                        call    get_ptr_quadrant_A_data
                        ld      b, (hl)                         ; warships in quadrant
                        dec     b                               ; adjust for call below
                        ld      a, #0x99 ; 'ô'
                        sub     b
                        ld      b, a                            ; negative
                        ld      a, (jovians_left)
                        add     a, b
                        daa                                     ; adjust jovians left
                        ld      (jovians_left), a               ; update
                        ld      (hl), #1                        ; fudge to 1 for call below
                        ld      a, #0x30 ; '0'                  ; 0 warships
                        ld      (VIDEO+0xC5), a                 ; write to LR sensor video
                        call    dec_jovians                     ; handle decrement of jovians
                        ld      hl, # VIDEO+0xC5                ; current quadrant in LR sensor
                        jp      init_quadrant
; ---------------------------------------------------------------------------
; destroys itself

expr_5:                                                         ; "DESTROYS ITSELF"
                        ld      de, #aDestroysItself
                        ld      a, #0xFF
                        ld      (experimental_ray_disabled), a
                        jp      print_experimental_ray_outcome
; ---------------------------------------------------------------------------
; backfires, subtracts 2 from power

expr_6:                                                         ; "HAS BACKFIRED ON US"
                        ld      de, #aHasBackfiredOn
                        call    print_experimental_ray_outcome
; START OF FUNCTION CHUNK FOR move_triton_missile

power_minus_2_and_update:
                        ld      a, (power_avail)
                        add     a, #0x98 ; 'ò'
                        daa                                     ; decrement power
                        ld      (power_avail), a
                        call    print_power_avail
                        jp      update_power_distribution
; END OF FUNCTION CHUNK FOR move_triton_missile
; ---------------------------------------------------------------------------
; causes computer malfunction

expr_7:                                                         ; "HAS CAUSED A COMPUTER          MALFUNCT"...
                        ld      de, #aHasCausedAComp
                        ld      a, #0xFF
                        ld      (computer_malfunction), a
                        jp      print_experimental_ray_outcome
; ---------------------------------------------------------------------------
; not allowed to fire

expr_8:                                                         ; "MEDICAL OFFICER:I CAN'T ALLOW YOU TO FI"...
                        ld      de, #aMedicalOfficer
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

launch_antimatter:
                        ld      a, (antimatter_pods)
                        and     a                               ; none left?
                        ld      de, #aWeaponryWeReOu            ; "WEAPONRY: WE'RE OUT OF PODS"
                        jp      Z, print_string_last_line       ; yes, exit
                        ld      a, (pwr_trt_missl)
                        cp      #8                              ; less than 8%?
                        jp      M, loc_54FC                     ; yes, exit
                        call    get_next_cmd_char               ; pod #
                        jp      Z, print_no_sense_and_ret       ; none, exit
                        sub     #0x31 ; '1'                     ; less than '1'?
                        jp      M, print_no_sense_and_ret       ; yes, exit
                        cp      #3                              ; greater than 3?
                        jp      P, print_no_sense_and_ret       ; yes, exit
                        ld      hl, #antimatter_pod_tbl
                        ld      b, a                            ; zero-based pod #
                        rlca                                    ; x2
                        add     a, b                            ; x3
                        rlca                                    ; x6
                        add     a, l
                        ld      l, a
                        ld      a, h
                        adc     a, #0
                        ld      h, a                            ; ptr pod entry
                        ld      a, (hl)                         ; get pod status
                        and     a                               ; used?
                        ld      de, #aComputerThePod            ; "COMPUTER: THE POD HAS BEEN USED"
                        jp      NZ, print_string_last_line      ; yes, exit
                        call    get_next_cmd_char               ; direction
                        jp      Z, print_no_sense_and_ret       ; none, exit
                        sub     #0x30 ; '0'                     ; less than '0'?
                        jp      M, print_no_sense_and_ret       ; yes, exit
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        cp      #8                              ; greater than 7?
.else
                        jp      Z, print_no_sense_and_ret       ; 0, exit
                        cp      #5
                        jp      Z, print_no_sense_and_ret
                        cp      #10                             ; greater than 9?
.endif                        
                        jp      P, print_no_sense_and_ret       ; yes, exit
.ifdef BUILD_OPT_KEYPAD_DIRS                        
                        XLATE_DIR
.endif
                        push    af                              ; tmp store direction
                        call    get_next_cmd_char               ; speed
                        jp      Z, loc_58BF                     ; none, skip
                        sub     #0x30 ; '0'                     ; less than '0'?
                        jp      M, print_no_sense_and_ret       ; yes, exit
                        cp      #10                             ; greater than 9?
                        jp      P, print_no_sense_and_ret       ; yes, exit
                        inc     a
                        rlca                                    ; scale
                        ld      (pod_speed), a

loc_58BF:                                                       ; flag pod launched
                        ld      (hl), #1
                        pop     af                              ; direction
                        push    hl                              ; tmp store pod status
                        inc     hl                              ; ptr pod address delta
                        ex      de, hl
                        ld      hl, #dir_addr_delta_tbl
                        rlca
                        add     a, l
                        ld      l, a
                        ld      a, h
                        adc     a, #0
                        ld      h, a                            ; ptr tbl entry
                        ld      a, (hl)                         ; delta lsb
                        ld      (de), a                         ; store in pod delta lsb
                        inc     hl
                        inc     de
                        ld      a, (hl)                         ; delta msb
                        ld      (de), a                         ; store in pod delta msb
                        push    de
                        dec     de                              ; ptr pod delta lsb
                        ld      hl, (hephaestus_video_addr)
                        ld      a, (de)
                        add     a, l
                        ld      l, a                            ; calc video address lsb
                        inc     de                              ; ptr pod delta msb
                        ld      a, (de)
                        adc     a, h
                        ld      h, a                            ; calc video address msb
                        pop     de
                        inc     de                              ; ptr pod video address lsb
                        ld      a, l
                        ld      (de), a                         ; store pod video address lsb
                        inc     de
                        ld      a, h
                        ld      (de), a                         ; store pod video address msb
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, print_pod_blocked           ; no, exit
                        ld      (hl), #0x23 ; '#'               ; write pod graphic to video
                        inc     de
                        ld      a, (pod_speed)
                        ld      (de), a                         ; store pod speed
                        ld      a, (antimatter_pods)
                        dec     a                               ; update
                        ld      (antimatter_pods), a
                        pop     hl                              ; discard tmp store
                        ld      hl, # VIDEO+0x23E               ; antimatter pods value video address
                        jp      print_BCD_byte
; ---------------------------------------------------------------------------

print_pod_blocked:                                              ; "COMPUTER: POD LAUNCH IS BLOCKED"
                        ld      de, #aComputerPodLau
                        pop     hl                              ; ptr pod status
                        ld      (hl), #0                        ; flag unused again
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

explode_pod:                                                    ; pod #
                        call    get_next_cmd_char
                        jp      Z, print_no_sense_and_ret       ; none, exit
                        sub     #0x31 ; '1'                     ; less than 1?
                        jp      M, print_no_sense_and_ret       ; yes, exit
                        cp      #3                              ; greater than 3?
                        jp      P, print_no_sense_and_ret       ; yes exit
                        ld      b, a                            ; 0-based pod #
                        rlca                                    ; x2
                        add     a, b                            ; x3
                        rlca                                    ; x6
                        ld      hl, #antimatter_pod_tbl
                        add     a, l
                        ld      l, a
                        ld      a, h
                        adc     a, #0
                        ld      h, a                            ; get ptr pod entry
                        ld      a, (hl)                         ; pod status
                        and     a                               ; used?
                        jp      Z, print_no_sense_and_ret       ; no, exit
                        cp      #1                              ; launched?
                        jp      Z, explode_pod_ok               ; yes, skip
                        ld      de, #aComputerThePod            ; "COMPUTER: THE POD HAS BEEN USED"
                        jp      print_string_last_line
; ---------------------------------------------------------------------------

explode_pod_ok:                                                 ; flag exploded
                        ld      (hl), #2
                        inc     hl
                        inc     hl
                        inc     hl
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a                            ; get pod video address
                        ld      (hl), #0x8F ; 'è'               ; animate
                        ex      de, hl
                        ld      hl, #dir_addr_delta_tbl
                        ld      b, #8                           ; 8 directions to iterate

loc_594A:
                        push    hl
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a                            ; get delta
                        add     hl, de                          ; add delta to pod video address
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x26 ; '&'                     ; jovian battle cruiser?
                        jp      Z, pod_hit_jovian               ; yes, go
                        cp      #0x40 ; '@'                     ; command cruiser?
                        jp      Z, pod_hit_jovian               ; yes, go
                        cp      #0x25 ; '%'                     ; triton mine?
                        jp      Z, hit_triton_mine              ; yes, go
                        cp      #0x5B ; '['                     ; USS Hephaestus?
                        jp      Z, print_game_over_screen       ; yes, go (oops)
                        cp      #0x23 ; '#'                     ; antimatter pod?
                        jp      Z, print_game_over_screen       ; yes, go (oops)
                        cp      #0x30 ; '0'                     ; space station?
                        jp      Z, pod_animate_object           ; yes, go
                        cp      #0x2A ; '*'                     ; star?
                        jp      Z, pod_animate_object           ; yes, go
                        cp      #0x2B ; '+'                     ; triton missile?
                        jp      Z, pod_animate_object           ; yes, go
                        cp      #0x58 ; 'X'                     ; unknown?
                        jp      Z, pod_animate_object           ; yes, go
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, loc_5985                    ; no, skip

pod_animate_object:                                             ; animate
                        ld      (hl), #0x8F ; 'è'

loc_5985:                                                       ; direction address delta table ptr
                        pop     hl
                        inc     hl
                        inc     hl                              ; next entry
                        dec     b                               ; done all directions?
                        jp      NZ, loc_594A                    ; no, loop
                        ret
; ---------------------------------------------------------------------------

pod_hit_jovian:
                        push    hl
                        ld      hl, # VIDEO+0xC5                ; current quadrant LR sensor
                        ld      a, (hl)                         ; get warships
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement
                        ld      (hl), a                         ; write to video
                        push    bc
                        push    de
                        call    dec_jovians
                        pop     de
                        pop     bc
                        pop     hl
                        jp      pod_animate_object

; =============== S U B R O U T I N E =======================================


handle_low_power:

; FUNCTION CHUNK AT 5001 SIZE 000001B5 BYTES
; FUNCTION CHUNK AT 51BD SIZE 00000017 BYTES
; FUNCTION CHUNK AT 538E SIZE 00000032 BYTES

                        ld      a, (pwr_lr_sensor)              ; get power to LR sensor
                        cp      #5                              ; greater than 4%?
                        jp      P, check_sr_sensor              ; yes, skip
                        ld      hl, # VIDEO+0x41                ; 1st row
                        ld      de, # VIDEO+0xC1                ; 2nd row
                        ld      bc, # VIDEO+0x141               ; 3rd row
                        ld      a, #11                          ; 11 bytes/row to wipe

loc_59B4:
                        push    af
                        ld      a, #0x20 ; ' '
                        ld      (bc), a                         ; space over 3rd row digit
                        ld      (hl), a                         ; space over 1st row digit
                        ld      a, e
                        cp      #0xC5 ; '≈'                     ; 1st digit current quadrant?
                        jp      Z, loc_59CC                     ; yes, skip
                        cp      #0xC6 ; '∆'                     ; 2nd digit current quadrant?
                        jp      Z, loc_59CC                     ; yes, skip
                        cp      #0xC7 ; '«'                     ; 3rd digit current quadrant?
                        jp      Z, loc_59CC                     ; yes, skip
                        ld      a, #0x20 ; ' '
                        ld      (de), a                         ; space over 2nd row digit

loc_59CC:
                        inc     de
                        inc     hl
                        inc     bc
                        pop     af
                        dec     a                               ; done row?
                        jp      NZ, loc_59B4                    ; no, loop

check_sr_sensor:
                        ld      a, (pwr_sr_sensor)
                        cp      #3                              ; greater than 2%?
                        jp      P, check_jovian_threat          ; yes, skip
                        ld      a, #1                           ; flag disabled
                        ld      (disable_pod_update), a
                        ld      hl, # VIDEO+0x57                ; SR sensor display
                        ld      de, #0x2C ; ','                 ; offset to next sector row
                        ld      b, #10                          ; 10 rows to overwrite

loc_59E9:                                                       ; 20 bytes to overwrite
                        ld      c, #20

loc_59EB:                                                       ; space over sector
                        ld      (hl), #0x20 ; ' '
                        inc     hl                              ; next video address
                        dec     c                               ; done row?
                        jp      NZ, loc_59EB                    ; no, loop
                        ld      (hl), #0x20 ; ' '               ; space
                        add     hl, de                          ; next sector row
                        dec     b                               ; done all rows?
                        jp      NZ, loc_59E9                    ; no, loop

check_jovian_threat:
                        ld      a, (jovian_time_frozen)
                        and     a                               ; frozen?
                        jp      M, condition_green              ; yes, skip
                        ld      a, (VIDEO+0xC5)                 ; #jovian warships
                        sub     #0x30 ; '0'                     ; convert to binary
                        and     a                               ; zero?
                        jp      NZ, condition_red               ; no, go

condition_green:
                        ld      a, (critical)
                        and     a                               ; exploding?
                        ret     M                               ; yes, return
                        ld      a, (always_zero)
                        ld      (delay_duty_cycle_i), a
                        ld      hl, # VIDEO+0xBB                ; ptr to condition value
                        ld      de, #aGreen                     ; "GREEN"
                        jp      print_string
; ---------------------------------------------------------------------------

condition_red:
                        ld      a, (critical)
                        and     a                               ; exploding?
                        jp      M, loc_5A32                     ; yes, go
                        ld      a, #1
                        ld      (delay_duty_cycle_i), a
                        ld      hl, # VIDEO+0xBB                ; ptr to condition value
                        ld      de, #aRed                       ; " RED "
                        call    print_string

loc_5A32:
                        ld      hl, (hephaestus_video_addr)
                        ld      a, (hl)                         ; get Hephaestus graphic
                        or      #0x80 ; 'Ä'                     ; animate
                        ld      (hl), a                         ; write to video
                        ld      a, (game_delay_factor)
                        rrca                                    ; /2
                        inc     a                               ; /2+1
                        ld      b, a
                        call    delay_B_and_update_all
                        ld      a, (hl)                         ; get Hephaestus graphic
                        and     #0x7F ; ''                     ; animate
                        ld      (hl), a                         ; write to video
                        ld      a, (VIDEO+0xC5)                 ; #jovian warships
                        sub     #0x30 ; '0'                     ; convert to binary
                        cp      #4                              ; more than 3?
                        call    P, lose_power_crystal           ; yes, go
                        ld      a, (pwr_deflectors)
                        cp      #5                              ; less than 5%?
                        call    M, print_shields_failing        ; yes, go
                        ld      c, #0
                        ld      hl, #pwr_deflectors
                        ld      a, (hl)
                        and     a                               ; pwr zero?
                        jp      Z, jovian_attack_and_move       ; yes, skip
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement power
                        ld      (hl), a                         ; update pwr_deflectors

jovian_attack_and_move:
                        ld      a, (power_avail)
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement power
                        ld      (power_avail), a
                        call    update_power_distribution
                        call    print_power_avail
                        ld      a, (jovians_left)
                        and     a                               ; any left?
                        jp      Z, print_game_over_screen       ; no, go
                        ld      a, (time_to_jovian_fire)
                        dec     a                               ; zero?
                        ld      (time_to_jovian_fire), a
                        ret     NZ                              ; no, return

loc_5A84:
                        call    rand_0_9
                        cp      #1                              ; less than 1?
                        jp      M, loc_5A84                     ; yes, regenerate
                        cp      #5                              ; greater than 4?
                        jp      P, loc_5A84                     ; yes, regenerate
                        ld      (time_to_jovian_fire), a        ; update with new random value
                        ld      d, #4                           ; *** dead code
                        ld      hl, #jovian_tbl

get_jovian_address:
                        ld      a, (hl)
                        and     a
                        ret     Z
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        push    hl

move_jovian:
                        call    rand_0_9
                        cp      #8                              ; greater than 7?
                        jp      P, move_jovian                  ; yes, regenerate
                        ld      hl, #dir_addr_delta_tbl
                        and     a

loc_5AAC:
                        jp      Z, loc_5AB5
                        inc     hl
                        inc     hl
                        dec     a                               ; found direction entry?
                        jp      loc_5AAC                        ; no, loop
; ---------------------------------------------------------------------------

loc_5AB5:
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)                         ; DE=delta
                        ld      h, b
                        ld      l, c
                        add     hl, de                          ; add delta to jovian address
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, next_jovian                 ; no, go
                        ld      a, (bc)                         ; get jovian ship type
                        cp      #0x26 ; '&'                     ; battle cruiser?
                        jp      Z, loc_5ACC                     ; yes, skip
                        cp      #0x40 ; '@'                     ; command cruiser?
                        jp      NZ, next_jovian                 ; no, go

loc_5ACC:                                                       ; update sector with jovian vessel
                        ld      (hl), a
                        ld      a, #0x2E ; '.'                  ; empty sector
                        ld      (bc), a                         ; update original jovian vessel location
                        pop     de                              ; jovain tbl ptr
                        dec     de                              ; lsb
                        ld      a, l
                        ld      (de), a                         ; update lsb of address
                        ld      a, h
                        inc     de
                        ld      (de), a                         ; update msb of address
                        ex      de, hl
                        inc     hl                              ; adjust
                        push    hl

next_jovian:
                        pop     hl
                        jp      get_jovian_address
; End of function handle_low_power


; =============== S U B R O U T I N E =======================================


lose_power_crystal:
                        ld      de, #aEngineerThereG            ; "ENGINEER:THERE GOES A POWER CRYSTAL, CO"...
                        call    print_string_last_line

dec_power_by_5:
                        ld      a, (power_avail)
                        ld      b, #5                           ; decrement by 5%

loc_5AE9:
                        add     a, #0x99 ; 'ô'
                        daa                                     ; dec power
                        jp      Z, print_game_over_screen       ; no power, game over
                        dec     b                               ; done decrementing?
                        jp      NZ, loc_5AE9                    ; no, loop
                        ld      (power_avail), a                ; update
                        call    print_power_avail
                        jp      update_power_distribution
; End of function lose_power_crystal


; =============== S U B R O U T I N E =======================================


print_shields_failing:
                        ld      de, #aEngineerComm_3            ; "ENGINEER:COMMANDER, THE SHIELDS ARE FAL"...
                        call    print_string_last_line
                        jp      dec_power_by_5
; End of function print_shields_failing

; ---------------------------------------------------------------------------

print_no_sense_and_ret:                                         ; "FIRST OFFICER:CAPTAIN, YOUR LAST COMMAN"...
                        ld      de, #aFirstOfficerCa
                        call    print_string_last_line
                        ld      sp, #STACK_WATERMARK            ; reset stack
                        ld      de, #game_loop                  ; set return address
                        push    de
                        push    hl
                        push    de
                        push    bc
                        jp      clear_cmd_buffer
; move quadrant
; - A = direction (0-7), C = # quadrants

; =============== S U B R O U T I N E =======================================


move_quadrant:
                        ld      hl, #quadrant_delta_tbl-1
                        inc     a                               ; direction (1-8)???
                        ld      b, #3                           ; 3 rows to print
                        push    bc

loc_5B1F:                                                       ; ptr next entry
                        inc     hl
                        dec     a                               ; found entry for direction?
                        jp      NZ, loc_5B1F                    ; no, loop
                        ld      a, (quadrant)                   ; current

loc_5B27:
                        add     a, (hl)
                        daa                                     ; calculate new quadrant
                        dec     c                               ; done move?
                        jp      NZ, loc_5B27                    ; no, loop
                        ld      (quadrant), a
; print LR sensor
                        add     a, #0x89 ; 'â'                  ; NW quadrant
                        daa
                        ld      de, # VIDEO+0x41                ; video address

loc_5B36:
                        push    af
                        push    de
                        call    get_ptr_quadrant_A_data
                        pop     de
                        ld      c, #3                           ; 3 values / row

loc_5B3E:                                                       ; 3 digits / value
                        ld      b, #3

loc_5B40:
                        ld      a, (hl)
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (de), a                         ; write to video
                        inc     de                              ; next video address
                        inc     hl                              ; next data address
                        dec     b                               ; done all digits?
                        jp      NZ, loc_5B40                    ; no, loop
                        inc     de                              ; skip (space)
                        dec     c                               ; done a row?
                        jp      NZ, loc_5B3E                    ; no, loop
                        pop     af                              ; left quadrant
                        add     a, #0x10                        ; down a quadrant
                        daa
                        pop     bc
                        dec     b                               ; done all rows?
                        jp      Z, loc_5B63                     ; yes, exit
                        push    bc
                        ld      hl, #0x74 ; 't'                 ; offset for next row
                        add     hl, de                          ; update video address
                        ex      de, hl
                        jp      loc_5B36                        ; loop
; ---------------------------------------------------------------------------
; why do we need to do current quadrant again???

loc_5B63:
                        ld      a, (quadrant)
                        ld      c, #1                           ; *** dead code
                        call    get_ptr_quadrant_A_data
                        ld      b, #3                           ; 3 bytes to print
                        ld      de, # VIDEO+0xC5                ; current quadrant on LR display

loc_5B70:                                                       ; byte from tbl
                        ld      a, (hl)
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII
                        ld      (de), a                         ; warships/space stations/stars
                        inc     de                              ; next byte in table
                        inc     hl                              ; next video address
                        dec     b                               ; done all bytes?
                        jp      NZ, loc_5B70                    ; no, loop
                        sub     a                               ; flag normal
                        ld      (jovian_time_frozen), a
                        ret
; End of function move_quadrant


; =============== S U B R O U T I N E =======================================


print_quadrant:
                        ld      a, (quadrant)
                        ld      hl, # VIDEO+0xFC                ; video address
                        ld      c, a
                        and     #0xF0 ; ''                     ; high nibble only
                        rrca
                        rrca
                        rrca
                        rrca                                    ; high->low nibble
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (hl), a                         ; write to video
                        inc     hl
                        inc     hl                              ; video address += 2
                        ld      a, c
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (hl), a                         ; write to video
                        ret
; End of function print_quadrant


; =============== S U B R O U T I N E =======================================


get_ptr_quadrant_A_data:
                        ld      c, a
                        and     #0xF0 ; ''                     ; high nibble only
                        rrca
                        rrca
                        rrca
                        rrca                                    ; high->low nibble
; fast multiply HL=A(7:4)*30
                        ld      hl, #0
                        ld      de, #30
                        ld      b, #8                           ; 8 bits

loc_5BA9:
                        add     hl, hl
                        rla
                        jp      NC, loc_5BB1
                        add     hl, de
                        adc     a, #0

loc_5BB1:                                                       ; done all bits?
                        dec     b
                        jp      NZ, loc_5BA9                    ; no, loop
                        ex      de, hl                          ; DE=result
; add A(3:0)*3 to the result
                        ld      a, c
                        and     #0xF                            ; low nibble only
                        ld      l, a                            ; L=low nibble
                        ld      b, #3                           ; multiplier=3

loc_5BBC:
                        add     a, e
                        ld      e, a
                        ld      a, #0
                        adc     a, d
                        ld      d, a
                        ld      a, l
                        dec     b                               ; done multiplication?
                        jp      NZ, loc_5BBC                    ; no, loop
                        ld      hl, #quadrant_tbl
                        add     hl, de                          ; get ptr to quadrant data
                        ret
; End of function get_ptr_quadrant_A_data


; =============== S U B R O U T I N E =======================================


init_quadrant:
                        push    hl                              ; ptr current quadrant on LR sensor
                        sub     a                               ; flag enabled
                        ld      (disable_pod_update), a
; init quadrant with all '.'
                        ld      de, #0x2C ; ','                 ; offset to next line of quadrant display
                        ld      hl, # VIDEO+0x57                ; quadrant display video address
                        ld      b, #10                          ; 10 rows

loc_5BD9:                                                       ; 10 columns
                        ld      c, #10

loc_5BDB:                                                       ; <SPACE>
                        ld      (hl), #0x20 ; ' '
                        inc     hl                              ; next video address
                        ld      (hl), #0x2E ; '.'               ; '.'
                        inc     hl                              ; next video address
                        dec     c                               ; done all columns?
                        jp      NZ, loc_5BDB                    ; no, loop
                        ld      (hl), #0x20 ; ' '               ; <SPACE>
                        add     hl, de                          ; next line of quadrant display
                        dec     b                               ; done all rows?
                        jp      NZ, loc_5BD9                    ; no, loop
; init warships
                        pop     hl                              ; ptr current quadrant on LR sensor
                        ld      a, (hl)                         ; get warships
                        inc     hl                              ; ptr space stations
                        push    hl
                        sub     #0x30 ; '0'                     ; convert to binary
                        jp      Z, loc_5C12                     ; no warships, skip
                        ld      hl, #jovian_tbl                 ; ptr table of warships
                        ld      (tmp_jovian_tbl_ptr), hl        ; save copy
                        ld      d, a                            ; D=warships

loc_5BFC:
                        call    rand_0_9
                        cp      #1                              ; zero?
                        jp      P, loc_5C09                     ; no, skip
                        ld      e, #0x40 ; '@'                  ; Command Cruiser
                        jp      loc_5C0B
; ---------------------------------------------------------------------------

loc_5C09:                                                       ; Battle Cruiser
                        ld      e, #0x26 ; '&'

loc_5C0B:
                        call    add_obj_to_quadrant
                        dec     d                               ; done all warships in quadrant?
                        jp      NZ, loc_5BFC                    ; no, loop
; init space stations

loc_5C12:                                                       ; get current ptr
                        ld      hl, (tmp_jovian_tbl_ptr)
                        ld      (hl), #0                        ; terminate
                        pop     hl                              ; ptr space stations
                        ld      a, (hl)                         ; get space stations
                        inc     hl                              ; ptr stars
                        push    hl
                        sub     #0x30 ; '0'                     ; convert to binary
                        jp      Z, loc_5C2A                     ; none, skip
                        ld      d, a                            ; number of space stations
                        ld      e, #0x30 ; '0'                  ; space station graphic

loc_5C23:
                        call    add_obj_to_quadrant
                        dec     d                               ; done all space stations?
                        jp      NZ, loc_5C23                    ; no, loop
; init stars

loc_5C2A:                                                       ; ptr stars in quadrant
                        pop     hl
                        ld      a, (hl)                         ; get stars
                        sub     #0x30 ; '0'                     ; convert to binary
                        jp      Z, loc_5C3B                     ; none, skip
                        ld      d, a                            ; number of stars
                        ld      e, #0x2A ; '*'                  ; star graphic

loc_5C34:
                        call    add_obj_to_quadrant
                        dec     d                               ; done all stars?
                        jp      NZ, loc_5C34                    ; no, loop
; init USS Hephaestus

loc_5C3B:                                                       ; USS Hephaestus graphic
                        ld      e, #0x5B ; '['
                        call    add_obj_to_quadrant
                        ld      (hephaestus_video_addr), hl
; init mines

loc_5C43:
                        call    rand_0_9
                        cp      #3                              ; more than 2?
                        jp      P, loc_5C43                     ; yes, regenerate
                        and     a                               ; zero?
                        jp      Z, loc_5C59                     ; yes, skip
                        ld      d, a                            ; (1-2)
                        ld      e, #0x25 ; '%'                  ; mine graphic

loc_5C52:
                        call    add_obj_to_quadrant
                        dec     d                               ; done all mines?
                        jp      NZ, loc_5C52                    ; no, loop
; init unknowns

loc_5C59:
                        call    rand_0_9
                        cp      #4                              ; more than 3?
                        jp      P, loc_5C59                     ; yes, regenerate
                        and     a                               ; zero?
                        ld      d, a

loc_5C63:                                                       ; yes, skip
                        jp      Z, print_sector
                        ld      e, #0x58 ; 'X'                  ; Unknown graphic
                        call    add_obj_to_quadrant
                        dec     d                               ; done all unknowns?
                        jp      loc_5C63                        ; no, loop
; End of function init_quadrant

; D=num of (this) object in quadrant, E=object (graphic)

; =============== S U B R O U T I N E =======================================


add_obj_to_quadrant:
                        call    rand_0_9                        ; rand Y coord
                        ld      hl, # VIDEO+0x58                ; first '.' in quadrant display
                        ld      bc, #0x40 ; '@'                 ; offset to next line
                        and     a                               ; zero?
                        jp      Z, loc_5C81                     ; yes, skip

loc_5C7C:                                                       ; next line
                        add     hl, bc
                        dec     a                               ; at random line?
                        jp      NZ, loc_5C7C                    ; no, loop

loc_5C81:                                                       ; rand X coord
                        call    rand_0_9
                        rlca                                    ; x2 for display offset
                        ld      c, a
                        ld      b, #0
                        add     hl, bc                          ; offset to X coord
                        ld      a, (hl)                         ; get current contents
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, add_obj_to_quadrant         ; no, regenerate
                        ld      (hl), e                         ; store object
                        ld      a, e
                        cp      #0x40 ; '@'                     ; Jovian Command Cruiser?
                        jp      Z, loc_5C99                     ; yes, skip
                        cp      #0x26 ; '&'                     ; Jovian Battle Cruiser?
                        ret     NZ                              ; no, return

loc_5C99:
                        push    de
                        ex      de, hl
                        ld      hl, (tmp_jovian_tbl_ptr)
                        ld      (hl), e                         ; warship video address lsb
                        inc     hl
                        ld      (hl), d                         ; warship video address msb
                        inc     hl                              ; next entry
                        ld      (tmp_jovian_tbl_ptr), hl        ; update
                        pop     de
                        ret
; End of function add_obj_to_quadrant


; =============== S U B R O U T I N E =======================================


get_next_cmd_char:
                        push    hl
                        ld      hl, (cmd_entry_addr)
                        ld      a, (hl)                         ; get next cmd char
                        cp      #0x80 ; 'Ä'                     ; graphic space?
                        jp      Z, loc_5CB7                     ; yes, skip
                        inc     hl                              ; next cmd char
                        ld      (cmd_entry_addr), hl            ; update
                        pop     hl
                        ret
; ---------------------------------------------------------------------------

loc_5CB7:                                                       ; zero char
                        sub     a
                        pop     hl
                        ret
; End of function get_next_cmd_char


; =============== S U B R O U T I N E =======================================


rnd_delay:
                        call    rand_0_9
                        inc     a                               ; 1-10
                        ld      b, a
; End of function rnd_delay

; some sort of random time delay loop
; - which calls update_chaser_pods_cmd_entry
; B=out loop counter
; E,C=inner loop counters (random?)

; =============== S U B R O U T I N E =======================================


delay_B_with_duty_cycle:
                        push    hl
                        push    de

loc_5CC1:
                        ld      hl, #delay_duty_cycle_tbl
                        ld      a, (delay_duty_cycle_i)
                        rlca                                    ; x2
                        add     a, l
                        ld      l, a                            ; get ptr entry
                        ld      a, #1

loc_5CCC:
                        ld      (delay_cycle), a
                        ld      d, #16

loc_5CD1:                                                       ; e=0-duty (not initialised)
                        dec     e
                        jp      NZ, loc_5CD6
                        ld      e, (hl)                         ; reload duty

loc_5CD6:                                                       ; c=0-255 (not initialised)
                        dec     c
                        jp      NZ, loc_5CD1
                        dec     d
                        jp      NZ, loc_5CD1
                        inc     hl                              ; next cycle entry
                        call    update_chaser_pods_cmd_entry
                        dec     b                               ; done all iterations?
                        jp      Z, delay_exit                   ; yes, exit
                        ld      a, (delay_cycle)
                        xor     #1                              ; toggle
                        jp      Z, loc_5CCC
                        jp      loc_5CC1
; ---------------------------------------------------------------------------

delay_exit:
                        pop     de
                        pop     hl
                        ret
; End of function delay_B_with_duty_cycle


; =============== S U B R O U T I N E =======================================


clear_video_with_B:
                        ld      hl, #VIDEO

loc_5CF7:                                                       ; set char
                        ld      (hl), b
                        inc     hl                              ; next video location
                        ld      a, h
                        cp      #0x40 ; '@'                     ; end of video?
                        jp      NZ, loc_5CF7                    ; no, loop
                        ret
; End of function clear_video_with_B


; =============== S U B R O U T I N E =======================================


rand_0_9:
                        push    bc
                        push    hl
                        ld      hl, (STACK_WATERMARK)

loc_5D05:
                        ld      b, #23
                        ld      a, l

loc_5D08:
                        and     #6
                        scf
                        jp      PE, loc_5D0F
                        ccf

loc_5D0F:
                        ld      a, h
                        rra
                        ld      h, a
                        ld      a, l
                        rra
                        and     #0xFE ; '˛'
                        ld      l, a
                        dec     b
                        jp      NZ, loc_5D08
                        ld      (STACK_WATERMARK), hl
                        ld      a, h
                        and     #0xF                            ; low nibble only
                        cp      #0xA                            ; greater than 9?
                        jp      NC, loc_5D05                    ; yes, regenerate
                        pop     hl
                        pop     bc
                        ret
; End of function rand_0_9


; =============== S U B R O U T I N E =======================================


print_experimental_ray_outcome:
                        push    de
                        ld      de, #aFirstOfficerTh            ; "FIRST OFFICER: THE EXPERIMENTAL RAY"
                        ld      hl, # VIDEO+0x380
                        call    clear_last_2_lines_print_string
                        pop     de
                        inc     hl
                        call    print_string
                        ret
; End of function print_experimental_ray_outcome


; =============== S U B R O U T I N E =======================================


print_string_last_line:
                        ld      hl, # VIDEO+0x3C0               ; last line
; End of function print_string_last_line


; =============== S U B R O U T I N E =======================================


clear_last_2_lines_print_string:
                        call    clear_last_2_lines
; End of function clear_last_2_lines_print_string

; HL=video address, DE=string (null-terminated)

; =============== S U B R O U T I N E =======================================


print_string:
                        ld      a, (de)                         ; get character
                        or      a                               ; end of string?
                        ret     Z                               ; yes, return
                        ld      (hl), a                         ; write to video
                        inc     de                              ; next string char
                        inc     hl                              ; next video address
                        jp      print_string                    ; loop
; End of function print_string


; =============== S U B R O U T I N E =======================================


delay_B_and_update_all:
                        call    delay_B_with_duty_cycle
; End of function delay_B_and_update_all


; =============== S U B R O U T I N E =======================================


update_chaser_pods_cmd_entry:

; FUNCTION CHUNK AT 5580 SIZE 00000005 BYTES

                        push    hl
                        push    de
                        push    bc
; update chaser
                        ld      hl, (chaser_addr)
                        ld      a, (hl)
                        call    rand_0_9
                        add     a, #0x80 ; 'Ä'
                        ld      (hl), #0x20 ; ' '               ; wipe chaser
                        inc     hl
                        inc     hl                              ; next chaser_addr
                        ld      a, l
                        cp      #0x2B ; '+'                     ; end? (right)
                        jp      M, loc_5D63                     ; no, skip
                        ld      l, #0x19                        ; reset to start (left)

loc_5D63:                                                       ; read char (why?)
                        ld      a, (hl)
                        ld      a, #0x8F ; 'è'                  ; chaser graphic
                        ld      (hl), a                         ; write to video
                        ld      (chaser_addr), hl               ; save new chaser address
                        ld      a, (critical)
                        and     a                               ; condition critical?
                        jp      Z, loc_5D7F                     ; no, skip
; toggles "CONDITION" value w/graphics
                        ld      b, #5                           ; 5 chars to toggle
                        ld      hl, # VIDEO+0xBB                ; ptr to condition value

loc_5D76:                                                       ; get char
                        ld      a, (hl)
                        add     a, #0x80 ; 'Ä'                  ; toggle graphics
                        ld      (hl), a                         ; write back to video
                        inc     hl                              ; next address
                        dec     b                               ; done?
                        jp      NZ, loc_5D76                    ; no, loop

loc_5D7F:
                        ld      a, (disable_pod_update)
                        and     a                               ; disabled?
                        jp      NZ, handle_cmd_entry            ; yes, skip
                        ld      de, #6                          ; 6 bytes per pod entry
                        ld      hl, #antimatter_pod_tbl

loc_5D8C:                                                       ; pod status
                        ld      a, (hl)
                        cp      #0xFF                           ; end of table?
                        jp      Z, handle_cmd_entry             ; yes, exit
                        and     a                               ; unused?
                        jp      NZ, get_pod_data                ; no, exit

next_pod:                                                       ; next pod entry
                        add     hl, de
                        jp      loc_5D8C                        ; loop
; ---------------------------------------------------------------------------

get_pod_data:                                                   ; pod launched?
                        cp      #1
                        jp      NZ, next_pod                    ; no, return
                        push    hl                              ; pod table entry
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)                         ; BC = video address delta
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)                         ; DE = video address
                        inc     hl
                        ld      a, (hl)                         ; speed countdown
                        and     a                               ; zero?
                        jp      Z, move_pod                     ; yes, go
                        dec     a                               ; decrement speed countdown
                        ld      (hl), a                         ; update
                        pop     hl

offset_for_next_pod:                                            ; offset to next pod entry
                        ld      de, #6
                        jp      next_pod
; ---------------------------------------------------------------------------

move_pod:                                                       ; reinit speed countdown
                        ld      a, (pod_speed)
                        ld      (hl), a                         ; update pod speed
                        ld      h, d
                        ld      l, e                            ; HL = video address
                        ld      (hl), #0x2E ; '.'               ; write empty sector to video
                        add     hl, bc                          ; add delta to address
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, change_pod_dir              ; no, go
                        ld      (hl), #0x23 ; '#'               ; write pod graphic to video
                        pop     de                              ; pod table entry
                        push    de
                        inc     de
                        inc     de
                        ex      de, hl                          ; HL = pod table entry+2

update_pod_address:                                             ; next entry address
                        inc     hl
                        ld      (hl), e                         ; video address lsb
                        inc     hl
                        ld      (hl), d                         ; video address msb
                        pop     hl
                        jp      offset_for_next_pod
; ---------------------------------------------------------------------------

change_pod_dir:                                                 ; direction
                        call    rand_0_9
                        cp      #8                              ; greater than 7?
                        jp      P, change_pod_dir               ; regenerate
                        ld      hl, #dir_addr_delta_tbl
                        rlca                                    ; x2
                        add     a, l
                        ld      l, a
                        ld      a, h
                        adc     a, #0
                        ld      h, a                            ; ptr direction delta address entry
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a                            ; HL = delta
                        ld      b, h
                        ld      c, l                            ; BC = delta
                        add     hl, de                          ; add delta to video address
                        ld      a, (hl)                         ; get sector contents
                        cp      #0x2E ; '.'                     ; empty?
                        jp      NZ, change_pod_dir              ; no, regenerate
                        ld      (hl), #0x23 ; '#'               ; write pod graphic to video
                        pop     de                              ; pod table entry
                        push    de
                        inc     de
                        ex      de, hl
                        ld      (hl), c                         ; new delta lsb
                        inc     hl
                        ld      (hl), b                         ; new delta msb
                        jp      update_pod_address
; ---------------------------------------------------------------------------

handle_cmd_entry:
                        ld      a, (cmd_flag)
                        and     a                               ; new command already?
                        jp      Z, loc_5E78                     ; yes, exit
                        call    keyboard_scan
                        jp      Z, loc_5E78                     ; no key, exit
                        cp      #9                              ; <TAB>? (cancel command)
                        jp      Z, clear_cmd_buffer             ; yes, go
                        ld      hl, (cmd_entry_addr)
                        ld      (hl), a                         ; display key
                        inc     hl                              ; next address
                        ld      (cmd_entry_addr), hl            ; save
                        cp      #0xD                            ; <ENTER>?
                        jp      Z, cmd_entered                  ; yes, go
                        ld      a, (cmd_len)
                        inc     a
                        cp      #7                              ; buffer full?
                        jp      P, clear_cmd_buffer             ; yes, skip
                        ld      (cmd_len), a                    ; save new length
                        jp      loc_5E78                        ; exit
; ---------------------------------------------------------------------------

cmd_entered:                                                    ; zero
                        sub     a
                        ld      (cmd_flag), a                   ; flag new command
                        dec     hl                              ; back to <ENTER>
                        ld      (hl), #0x80 ; 'Ä'               ; overwrite with graphical space
                        ld      hl, # VIDEO+0x337               ; cmd entry
                        ld      b, (hl)                         ; get 1st char
                        ld      a, (computer_malfunction)
                        and     a
                        jp      Z, loc_5E46
                        ld      a, b                            ; 1st char of command
                        cp      #0x49 ; 'I'                     ; ???
                        jp      NZ, clear_cmd_buffer            ; no, skip

loc_5E46:
                        inc     hl
                        ld      (cmd_entry_addr), hl
                        ld      hl, #cmd_tbl                    ; "HIMTDSEXAL"
                        ld      de, #cmd_jmp_vectors

lookup_cmd:                                                     ; get cmd entry
                        ld      a, (hl)
                        and     a                               ; end of table?
                        jp      Z, clear_cmd_buffer             ; yes, exit
                        cp      b                               ; found cmd?
                        jp      Z, found_cmd                    ; yes, go
                        inc     hl                              ; next table entry
                        inc     de
                        inc     de                              ; next vector entry
                        jp      lookup_cmd                      ; loop
; ---------------------------------------------------------------------------

clear_cmd_buffer:
                        ld      hl, # VIDEO+0x337
                        ld      (cmd_entry_addr), hl            ; reset cmd entry
                        ld      a, #0xFF
                        ld      (cmd_flag), a                   ; flag no command

loc_5E6A:
                        ld      a, #0x20 ; ' '
                        ld      (hl), a                         ; write space
                        inc     hl                              ; next video address
                        ld      a, (hl)                         ; get char
                        cp      #0x20 ; ' '                     ; space?
                        jp      NZ, loc_5E6A                    ; no, loop
                        sub     a                               ; zero cmd_len
                        ld      (cmd_len), a

loc_5E78:
                        pop     bc
                        pop     de
                        pop     hl
                        ret
; ---------------------------------------------------------------------------

found_cmd:                                                      ; HL = jump vector
                        ex      de, hl
                        ld      de, #clear_cmd_buffer
                        push    de                              ; set return address
                        jp      jump_HL_vector
; End of function update_chaser_pods_cmd_entry


; =============== S U B R O U T I N E =======================================


animate_destruction:
                        ld      a, #1                           ; flag disabled
                        ld      (disable_pod_update), a
                        ld      a, #1                           ; flag critical (self-destruct)
                        ld      (critical), a
                        ld      a, #3
                        ld      (delay_duty_cycle_i), a
                        ld      hl, # VIDEO+0xBB                ; condition value video address
                        ld      de, #aCrtcl                     ; "CRTCL"
                        call    print_string
                        ld      b, #50
                        call    delay_B_with_duty_cycle
                        ld      c, #30                          ; loop 30 times

loc_5EA3:
                        ld      b, #0x2B ; '+'
                        call    clear_video_with_B
                        ld      b, #0x23 ; '#'
                        call    clear_video_with_B
                        ld      b, #0x2A ; '*'
                        call    clear_video_with_B
                        ld      b, #0xBF ; 'ø'
                        call    clear_video_with_B
                        dec     c                               ; done?
                        jp      NZ, loc_5EA3                    ; no, loop
                        sub     a                               ; flag enabled
                        ld      (disable_pod_update), a
                        ret
; End of function animate_destruction


; =============== S U B R O U T I N E =======================================


clear_last_2_lines:
                        push    hl                              ; save video address
                        ld      a, #0x80 ; 'Ä'                  ; 2 lines to clear
                        ld      hl, # VIDEO+0x380               ; 2nd-last line

loc_5EC6:                                                       ; <SPACE>
                        ld      (hl), #0x20 ; ' '
                        dec     a                               ; done 2 lines?
                        inc     hl                              ; next video location
                        jp      NZ, loc_5EC6                    ; no, loop
                        pop     hl                              ; restore video location
                        ret
; End of function clear_last_2_lines


; =============== S U B R O U T I N E =======================================


print_10_lines:
                        ld      hl, # VIDEO+0x57
                        ld      a, #10                          ; # lines to print

loc_5ED4:
                        push    af
                        call    print_string
                        pop     af
                        ld      bc, #0x2B ; '+'                 ; offset to next line
                        add     hl, bc                          ; next video address
                        dec     a                               ; done all lines?
                        inc     de                              ; skip null
                        jp      NZ, loc_5ED4                    ; no, loop
                        ret
; End of function print_10_lines


; =============== S U B R O U T I N E =======================================


print_sector:
                        ld      hl, (hephaestus_video_addr)
                        ld      de, #0xC3A9                     ; $3C58+$C3A9=$10001
                        add     hl, de
                        ld      de, #0xFFC0                     ; -64 (1 line)
                        ld      b, #0

loc_5EEF:                                                       ; subtract a line
                        add     hl, de
                        ld      a, h
                        and     a                               ; negative?
                        jp      M, loc_5EF9                     ; yes, exit
                        inc     b                               ; inc Y coord
                        jp      loc_5EEF                        ; loop
; ---------------------------------------------------------------------------

loc_5EF9:
                        ld      de, #0x40 ; '@'
                        add     hl, de                          ; re-adjust
                        ld      a, l
                        rrca                                    ; X coord
                        and     #0xF
                        add     a, #0x30 ; '0'                  ; convert to ASCII
                        ld      hl, # VIDEO+0x13E               ; sector X video address
                        ld      (hl), a                         ; write to video
                        ld      hl, # VIDEO+0x13C               ; sector Y video address
                        ld      a, b
                        add     a, #0x30 ; '0'                  ; convert to ASCII
                        ld      (hl), a                         ; write to video
                        ret
; End of function print_sector


; =============== S U B R O U T I N E =======================================


update_star_time:
                        ld      hl, # VIDEO+0x7F                ; last digit STAR-TIME

loc_5F12:                                                       ; get digit
                        ld      a, (hl)
                        inc     a
                        ld      (hl), a                         ; write back to video
                        cp      #0x3A ; ':'                     ; ASCII '9'+1?
                        ret     NZ                              ; no, return
                        ld      (hl), #0x30 ; '0'               ; write '0' to video
                        dec     hl                              ; previous digit
                        jp      loc_5F12                        ; loop
; End of function update_star_time


; =============== S U B R O U T I N E =======================================


dec_jovians:
                        ld      a, (quadrant)
                        call    get_ptr_quadrant_A_data
                        dec     (hl)                            ; dec warships
                        ld      a, (jovians_left)
                        add     a, #0x99 ; 'ô'
                        daa                                     ; dec jovians left
                        ld      (jovians_left), a               ; update
; End of function dec_jovians


; =============== S U B R O U T I N E =======================================


print_jovians_left:
                        ld      a, (jovians_left)
                        ld      hl, # VIDEO+0x1FE               ; video address
                        and     a                               ; any left?
                        jp      NZ, print_BCD_byte              ; yes, go
                        call    print_BCD_byte                  ; display Jovians left
                        ld      hl, # VIDEO+0x380               ; 2nd-last line
                        ld      de, #aCommandHeadq_0            ; "COMMAND HEADQUARTERS:  CONGRATULATIONS,"...
                        call    clear_last_2_lines_print_string
                        ld      hl, # VIDEO+0xC5                ; current quadrant in LR sensor
                        ld      (hl), #0x30 ; '0'               ; write '0' to warships
; display officer from HQ
                        ld      de, #aHQ_Officer                ; "                     "
                        call    print_10_lines
                        sub     a                               ; flag no command
                        ld      (cmd_flag), a
                        ld      a, #1                           ; flag disabled
                        ld      (disable_pod_update), a
                        ld      b, #0xC
                        jp      loc_53AB
; End of function print_jovians_left


; =============== S U B R O U T I N E =======================================


print_power_avail:
                        ld      hl, # VIDEO+0x1BD               ; POWER AVAIL value
                        ld      a, (power_avail)
; End of function print_power_avail


; =============== S U B R O U T I N E =======================================


print_BCD_byte:
                        ld      e, a
                        rrca
                        rrca
                        rrca
                        rrca                                    ; high->low nibble
                        and     #0xF                            ; nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (hl), a                         ; write to video
                        inc     hl                              ; next video address
                        ld      a, e
                        and     #0xF                            ; low nibble only
                        add     a, #0x30 ; '0'                  ; convert to ASCII digit
                        ld      (hl), a                         ; write to video
                        ret
; End of function print_BCD_byte


; =============== S U B R O U T I N E =======================================


dec_triton_misls_and_print:
                        ld      hl, # VIDEO+0x17D               ; triton msls value video address
                        ld      a, (triton_misls)
                        and     a                               ; none?
                        jp      NZ, loc_5F81                    ; no, skip
                        scf
                        ret
; ---------------------------------------------------------------------------

loc_5F81:
                        add     a, #0x99 ; 'ô'
                        daa                                     ; decrement
                        ld      (triton_misls), a               ; update
                        jp      print_BCD_byte
; End of function dec_triton_misls_and_print

; ---------------------------------------------------------------------------
.ifndef BUILD_OPT_MIXED_CASE

aCommandHeadqua:        .ascii 'COMMAND HEADQUARTERS: THE JOVIANS HAVE INVADED EARTH SPACE.     YOUR OR'
                        .ascii 'DERS ARE TO SEARCH FOR AND DESTROY ALL JOVIAN WAR        VESSELS IN EAR'
                        .ascii 'TH'
                        .db 0x27
                        .ascii 'S 100 QUADRANTS OF SPACE'
                        .db 0
aHyprHIonIMsrMT:        .ascii 'HYPR=H,ION=I,MSR=M,TRM=T,PWRDST=D,SELFD=S,EXPRAY=E,POD=A,XPOD=X '
                        .db 0
aEngineerComman:        .ascii 'ENGINEER:COMMANDER, THE ENGINES HAVEN'
                        .db 0x27
                        .ascii 'T THE POWER TO OPERATE'
                        .db 0
aEngineerTheUnk:        .ascii 'ENGINEER:THE UNKNOWN WE SHOT DISABLED THE HYPERDRIVE. '
                        .db 0
aFirstOfficerCa:        .ascii 'FIRST OFFICER:CAPTAIN, YOUR LAST COMMAND MADE NO SENSE'
                        .db 0
aFirstOfficer_0:        .ascii 'FIRST OFFICER:CAPTAIN, WE HAVE BEEN BLOCKED BY AN UNKNOWN       OBJECT'
                        .db 0
aCommunications:        .ascii 'COMMUNICATIONS:THE SPACE STATION HAS ACKNOWLEDGED OUR DOCKING.'
                        .db 0
aDock:                  .ascii ' DOCK'
                        .db 0
aGreen:                 .ascii 'GREEN'
                        .db 0
aRed:                   .ascii ' RED '
                        .db 0
aCrtcl:                 .ascii 'CRTCL'
                        .db 0
aFirstOfficerSi:        .ascii 'FIRST OFFICER: SIR, WE HAVE HIT A TRITON MINE'
                        .db 0
aCommunicatio_0:        .ascii 'COMMUNICATIONS:SIR, WE MADE CONTACT WITH A JOVIAN VESSEL'
                        .db 0
aJovianWatchWhe:        .ascii 'JOVIAN: WATCH WHERE YOU ARE GOING YOU TURKEY!!'
                        .db 0
aNavigatorWeHit:        .ascii 'NAVIGATOR:WE HIT A STAR!?!'
                        .db 0
aEngineerComm_0:        .ascii 'ENGINEER:COMMANDER, WE HAVEN'
                        .db 0x27
                        .ascii 'T THE POWER TO FIRE MASERS'
                        .db 0
aFirstOfficer_1:        .ascii 'FIRST OFFICER:SIR, MY SENSORS SHOW MASER HAD NO EFFECT'
                        .db 0
aEngineerComm_1:        .ascii 'ENGINEER:COMMANDER, THE MISSILE TUBES ARE POWER DEFICIENT'
                        .db 0
aComputerObject:        .ascii 'COMPUTER:OBJECT DESTROYED'
                        .db 0
aNavigatorTheEn:        .ascii 'NAVIGATOR:THE ENGINES ARE EXPLODING'
                        .db 0
aEngineerComm_2:        .ascii 'ENGINEER:COMMANDER, THE ENGINES ARE OVERLOADED, THEY CAN'
                        .db 0x27
                        .ascii 'T LAST    AT THAT RATE'
                        .db 0
aComputerSelfDe:        .ascii 'COMPUTER:SELF DESTRUCT SEQUENCE INITIATED. 15 SECONDS REMAIN'
                        .db 0
aComputerSelf_0:        .ascii 'COMPUTER:SELF DESTRUCT SEQUENCE ABORTED'
                        .db 0
aMedicalOfficer:        .ascii 'MEDICAL OFFICER:I CAN'
                        .db 0x27
                        .ascii 'T ALLOW YOU TO FIRE THE EXPERIMENTAL RAY!'
                        .db 0
aWeaponrySirWeH:        .ascii 'WEAPONRY:SIR, WE HAVE NO MORE TRITON MISSILES'
                        .db 0
aEngineerThereG:        .ascii 'ENGINEER:THERE GOES A POWER CRYSTAL, COMMANDER'
                        .db 0
aEngineerComm_3:        .ascii 'ENGINEER:COMMANDER, THE SHIELDS ARE FALLING APART!'
                        .db 0
aCommandHeadq_0:        .ascii 'COMMAND HEADQUARTERS:  CONGRATULATIONS, YOU HAVE DESTROYED ALL    THE J'
                        .ascii 'OVIANS. YOU ARE PROMOTED TO ADMIRAL'
                        .db 0
aFirstOfficerTh:        .ascii 'FIRST OFFICER: THE EXPERIMENTAL RAY'
                        .db 0
aIsFiringTriton:        .ascii 'IS FIRING TRITON MISSILES'
                        .db 0
aCausedAChangeI:        .ascii 'CAUSED A CHANGE IN SPACIAL     STRUCTURE'
                        .db 0
aHasFrozenTimeF:        .ascii 'HAS FROZEN TIME FOR THE        JOVIANS'
                        .db 0
aHasCausedTheJo:        .ascii 'HAS CAUSED THE JOVIANS TO      BECOME INVISIBLE'
                        .db 0
aComputerTriton:        .ascii 'COMPUTER:TRITON MISSILE HAS NO EFFECT'
                        .db 0
aHasJumbledTheQ:        .ascii 'HAS JUMBLED THE QUADRANT'
                        .db 0
aHasDestroyedAl:        .ascii 'HAS DESTROYED ALL THE          JOVIANS IN THE QUADRANT'
                        .db 0
aDestroysItself:        .ascii 'DESTROYS ITSELF'
                        .db 0
aHasBackfiredOn:        .ascii 'HAS BACKFIRED ON US'
                        .db 0
aHasCausedAComp:        .ascii 'HAS CAUSED A COMPUTER          MALFUNCTION'
                        .db 0
aIsPermanentlyD:        .ascii 'IS PERMANENTLY DISABLED'
                        .db 0
aShipLogUssPhae:        .ascii 'SHIP LOG-USS PHAETON-CAPTAIN DAR: SENSORS FOUND DEBRIS BELIEVED THAT OF'
                        .ascii ' USS HEPHAESTUS.'
                        .db 0
aEnterSpeedFact:        .ascii 'ENTER SPEED FACTOR (0(FAST)-9(SLOW))'
                        .db 0
aWeaponryWeReOu:        .ascii 'WEAPONRY: WE'
                        .db 0x27
                        .ascii 'RE OUT OF PODS'
                        .db 0
aComputerThePod:        .ascii 'COMPUTER: THE POD HAS BEEN USED'
                        .db 0
aComputerPodLau:        .ascii 'COMPUTER: POD LAUNCH IS BLOCKED'
                        .db 0
aFirstOfficer_2:        .ascii 'FIRST OFFICER: THE UNKNOWN IS STEALING POWER CAPTAIN'
                        .db 0
.else

aCommandHeadqua:        .ascii 'COMMAND HEADQUARTERS: The Jovians have invaded earth space.     your or'
                        .ascii 'ders are to search for and destroy all Jovian war        vessels in ear'
                        .ascii 'th'
                        .db 0x27
                        .ascii 's 100 quadrants of space'
                        .db 0
aHyprHIonIMsrMT:        .ascii 'Hypr=H,Ion=I,Msr=M,Trm=T,Pwrdst=D,Selfd=S,Expray=E,Pod=A,Xpod=X '
                        .db 0
aEngineerComman:        .ascii 'ENGINEER:Commander, the engines haven'
                        .db 0x27
                        .ascii 't the power to operate'
                        .db 0
aEngineerTheUnk:        .ascii 'ENGINEER:The unknown we shot disabled the hyperdrive. '
                        .db 0
aFirstOfficerCa:        .ascii 'FIRST OFFICER:Captain, your last command made no sense'
                        .db 0
aFirstOfficer_0:        .ascii 'FIRST OFFICER:Captain, we have been blocked by an unknown       object'
                        .db 0
aCommunications:        .ascii 'COMMUNICATIONS:The Space Station has acknowledged our docking.'
                        .db 0
aDock:                  .ascii ' DOCK'
                        .db 0
aGreen:                 .ascii 'GREEN'
                        .db 0
aRed:                   .ascii ' RED '
                        .db 0
aCrtcl:                 .ascii 'CRTCL'
                        .db 0
aFirstOfficerSi:        .ascii 'FIRST OFFICER: Sir, we have hit a Triton Mine'
                        .db 0
aCommunicatio_0:        .ascii 'COMMUNICATIONS:Sir, we made contact with a Jovian vessel'
                        .db 0
aJovianWatchWhe:        .ascii 'JOVIAN: Watch where you are going you TURKEY!!'
                        .db 0
aNavigatorWeHit:        .ascii 'NAVIGATOR:We hit a star!?!'
                        .db 0
aEngineerComm_0:        .ascii 'ENGINEER:Commander, we haven'
                        .db 0x27
                        .ascii 't the power to fire Masers'
                        .db 0
aFirstOfficer_1:        .ascii 'FIRST OFFICER:Sir, my sensors show Maser had no effect'
                        .db 0
aEngineerComm_1:        .ascii 'ENGINEER:Commander, the missile tubes are power deficient'
                        .db 0
aComputerObject:        .ascii 'COMPUTER:Object destroyed'
                        .db 0
aNavigatorTheEn:        .ascii 'NAVIGATOR:The engines are exploding'
                        .db 0
aEngineerComm_2:        .ascii 'ENGINEER:Commander, the engines are overloaded, they can'
                        .db 0x27
                        .ascii 't last    at that rate'
                        .db 0
aComputerSelfDe:        .ascii 'COMPUTER:Self Destruct Sequence initiated. 15 seconds remain'
                        .db 0
aComputerSelf_0:        .ascii 'COMPUTER:Self Destruct Sequence aborted'
                        .db 0
aMedicalOfficer:        .ascii 'MEDICAL OFFICER:I can'
                        .db 0x27
                        .ascii 't allow you to fire the Experimental Ray!'
                        .db 0
aWeaponrySirWeH:        .ascii 'WEAPONRY:Sir, We have no more Triton Missiles'
                        .db 0
aEngineerThereG:        .ascii 'ENGINEER:There goes a power crystal, Commander'
                        .db 0
aEngineerComm_3:        .ascii 'ENGINEER:Commander, the shields are falling apart!'
                        .db 0
aCommandHeadq_0:        .ascii 'COMMAND HEADQUARTERS:  Congratulations, you have destroyed all    the J'
                        .ascii 'ovians. You are promoted to Admiral'
                        .db 0
aFirstOfficerTh:        .ascii 'FIRST OFFICER: The Experimental Ray'
                        .db 0
aIsFiringTriton:        .ascii 'is firing Triton Missiles'
                        .db 0
aCausedAChangeI:        .ascii 'caused a change in spacial     structure'
                        .db 0
aHasFrozenTimeF:        .ascii 'has frozen time for the        Jovians'
                        .db 0
aHasCausedTheJo:        .ascii 'has caused the Jovians to      become invisible'
                        .db 0
aComputerTriton:        .ascii 'COMPUTER:Triton Missile has no effect'
                        .db 0
aHasJumbledTheQ:        .ascii 'has jumbled the quadrant'
                        .db 0
aHasDestroyedAl:        .ascii 'has destroyed all the          Jovians in the quadrant'
                        .db 0
aDestroysItself:        .ascii 'destroys itself'
                        .db 0
aHasBackfiredOn:        .ascii 'has backfired on us'
                        .db 0
aHasCausedAComp:        .ascii 'has caused a computer          malfunction'
                        .db 0
aIsPermanentlyD:        .ascii 'is permanently disabled'
                        .db 0
aShipLogUssPhae:        .ascii 'SHIP LOG-USS PHAETON-CAPTAIN DAR: Sensors found debris believed that of'
                        .ascii ' USS Hephaestus.'
                        .db 0
aEnterSpeedFact:        .ascii 'Enter Speed Factor (0(Fast)-9(Slow))'
                        .db 0
aWeaponryWeReOu:        .ascii 'WEAPONRY: We'
                        .db 0x27
                        .ascii 're out of pods'
                        .db 0
aComputerThePod:        .ascii 'COMPUTER: The pod has been used'
                        .db 0
aComputerPodLau:        .ascii 'COMPUTER: Pod launch is blocked'
                        .db 0
aFirstOfficer_2:        .ascii 'FIRST OFFICER: The unknown is stealing power Captain'
                        .db 0
.endif
                        
chaser_addr:            .dw VIDEO+0x319
tmp_delay_cycle:        .db 0
delay_cycle:            .db 0
tmp_sector_contents:    .db 0
                        .db 0
                        .db 0
; table used in delay routine
; - scaling factors for duty cycle
delay_duty_cycle_tbl:   .db 2, 2
                        .db 85, 2
                        .db 24, 24
                        .db 80, 34
                        .db 0
ion_speed:              .db 8
cmd_entry_addr:         .dw VIDEO+0x337
cmd_jmp_vectors:        .dw hyperdrive
                        .dw ion_engine
                        .dw maser
                        .dw triton_missile
                        .dw power_distrib
                        .dw self_destruct
                        .dw experimental_ray
                        .dw explode_pod
                        .dw launch_antimatter
cmd_l_vector:           .dw 0x1A19                              ; BASIC ENTRY POINT
cmd_tbl:                .ascii 'HIMTDSEXAL'
                        .db 0
pwr_subcmd_tbl:         .ascii 'HLSDMT'
                        .db 0
hephaestus_video_addr:  .dw 2
engine_explode_countdown:.db 0
antimatter_pods:        .db 3
; when a triton missile hits an unknown object
; randomly vector to one of these locations
missile_hit_unknown_tbl:.dw missile_hit_unk_079
                        .dw missile_hit_unk_1
                        .dw missile_hit_unk_2
                        .dw missile_hit_unk_3
                        .dw missile_hit_unk_4
                        .dw missile_hit_unk_58
                        .dw missile_hit_unk_6
                        .dw missile_hit_unk_079
                        .dw missile_hit_unk_58
                        .dw missile_hit_unk_079
pod_speed:              .db 6
expr_tbl:               .dw expr_0
                        .dw expr_1
                        .dw expr_2
                        .dw expr_3
                        .dw expr_4
                        .dw expr_5
                        .dw expr_6
                        .dw expr_7
                        .dw expr_8
                        .dw expr_9
blocked_by_unknown:     .db 0                                   ; $00=OK, $FF=blocked
ion_dir:                .db 0
                        .db    0
jovians_left:           .db 0
quadrant_delta_tbl:     .db 0x90, 0x91, 1, 0x11, 0x10, 9, 0x99, 0x89
quadrant:               .db 0
; -- start of quadrant table
; 300 bytes cleared at startup
; - quadrant data, 3 bytes
;   +$00 - (3:0)=warships
;   +$01 - (3:0)=space stations
;   +$02 - (3:0)=stars
quadrant_tbl:           .db 0x4C, 0x4F, 0x54, 0x20, 0x44, 0x57, 0x20, 0x30, 0xD
                        .db 0x19, 0x31, 0x33, 0x38, 0x32, 0x20, 0x43, 0x4C, 0x45
                        .db 0x41, 0x52, 0x20, 0x41, 0x53, 0x43, 0x20, 0x27, 0x20
                        .db 0x20, 0x20, 0x20, 0x20, 0x20, 0x27, 0xD, 0xC, 0x31, 0x33
                        .db 0x38, 0x33, 0x20, 0x20, 0x44, 0x42, 0x20, 0x30, 0xD
                        .db 0x14, 0x31, 0x33, 0x38, 0x34, 0x20, 0x20, 0x41, 0x53
                        .db 0x43, 0x20, 0x27, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
                        .db 0x27, 0xD, 0xC, 0x31, 0x33, 0x38, 0x35, 0x20, 0x20, 0x44
                        .db 0x42, 0x20, 0x30, 0xD, 0x13, 0x31, 0x33, 0x38, 0x36
                        .db 0x20, 0x53, 0x57, 0x54, 0x31, 0x20, 0x45, 0x51, 0x55
                        .db 0x20, 0x27, 0x30, 0x27, 0xD, 0x13, 0x31, 0x33, 0x38
                        .db 0x37, 0x20, 0x53, 0x57, 0x54, 0x32, 0x20, 0x45, 0x51
                        .db 0x55, 0x20, 0x27, 0x21, 0x27, 0xD, 0x11, 0x31, 0x33
                        .db 0x38, 0x38, 0x20, 0x58, 0x46, 0x4C, 0x41, 0x47, 0x20
                        .db 0x44, 0x42, 0x20, 0x30, 0xD, 0x11, 0x31, 0x33, 0x38
                        .db 0x39, 0x20, 0x5A, 0x46, 0x4C, 0x41, 0x47, 0x20, 0x44
                        .db 0x42, 0x20, 0x30, 0xD, 0xF, 0x31, 0x33, 0x39, 0x30, 0x20
                        .db 0x57, 0x48, 0x31, 0x20, 0x44, 0x42, 0x20, 0x30, 0xD
                        .db 0xF, 0x31, 0x33, 0x39, 0x31, 0x20, 0x57, 0x48, 0x32
                        .db 0x20, 0x44, 0x42, 0x20, 0x30, 0xD, 0x11, 0x31, 0x33
                        .db 0x39, 0x32, 0x20, 0x44, 0x44, 0x45, 0x4D, 0x4F, 0x20
                        .db 0x44, 0x42, 0x20, 0x30, 0xD, 0x11, 0x31, 0x33, 0x39
                        .db 0x33, 0x20, 0x42, 0x54, 0x59, 0x50, 0x45, 0x20, 0x44
                        .db 0x42, 0x20, 0x30, 0xD, 0x11, 0x31, 0x33, 0x39, 0x34
                        .db 0x20, 0x4E, 0x53, 0x48, 0x54, 0x53, 0x20, 0x44, 0x57
                        .db 0x20, 0x30, 0xD, 0x11, 0x31, 0x33, 0x39, 0x35, 0x20
                        .db 0x4E, 0x48, 0x49, 0x54, 0x53, 0x20, 0x44, 0x57, 0x20
                        .db 0x30, 0xD, 0x27, 0x31, 0x33, 0x39, 0x36, 0x20, 0x58
                        .db 0x50, 0x4C, 0x4F, 0x31, 0x20, 0x44, 0x42, 0x20, 0x30
                        .db 0x32, 0x30, 0x48, 0x2C, 0x27, 0x2A, 0x27, 0x2C, 0x31
                        .db 0x39, 0x31, 0x2C, 0x27, 0x2A, 0x27, 0x2C, 0x30, 0x32
                        .db 0x30, 0x48, 0x2C, 0x30, 0xD, 0x20, 0x31, 0x33, 0x39
                        .db 0x37, 0x20, 0x20, 0x44, 0x42, 0x20, 0x27, 0x2A, 0x27
; -- end of quadrant table
                        .db 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F
pwr_hypr_ion:           .db 0x20
pwr_lr_sensor:          .db 0x20
pwr_sr_sensor:          .db 0x10
pwr_deflectors:         .db 0x20
pwr_masers:             .db 9
pwr_trt_missl:          .db 0x11
dir_addr_delta_tbl:     .dw 0xFFC0                              ; N
                        .dw 0xFFC2                              ; NE
                        .dw 2                                   ; E
                        .dw 0x42                                ; SE
                        .dw 0x40                                ; S
                        .dw 0x3E                                ; SW
                        .dw 0xFFFE                              ; W
                        .dw 0xFFBE                              ; NW
game_delay_factor:      .db 0                                   ; (0-9)x4+16
time_to_jovian_fire:    .db 0
tmp_jovian_tbl_ptr:     .dw 0
; table of jovian vessel video addresses
; - maximum of 4 vessels, zero-terminated
jovian_tbl:             .dw 0x2C48
                        .dw 0x2A27
                        .dw 0x2C27
                        .dw 0x3931
                        .dw 0x2C31
power_avail:            .db 0x99
triton_misls:           .db 0x10
unused_69BA:            .db 3
aJovian_Officer:        .ascii '                     '
                        .db 0
                        .ascii '        '
                        .db 0x98, 0x83, 0x83, 0x83, 0xA4
                        .ascii '        '
                        .db 0
                        .ascii '       '
                        .db 0x96, 0xA0
                        .ascii '   '
                        .db 0x90, 0xA9
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x95
                        .ascii ' '
                        .db 0x89
                        .ascii ' '
                        .db 0x86
                        .ascii ' '
                        .db 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x95, 0xB7, 0x95
                        .ascii ' '
                        .db 0xAA, 0xBB, 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x95
                        .ascii '  @  '
                        .db 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0xB5, 0xB0
                        .ascii ' O '
                        .db 0xB0, 0xBA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x86, 0x81, 0x8C, 0x8C, 0x8C, 0x82, 0x89
                        .ascii '       '
                        .db 0
                        .ascii '      '
                        .db 0x86
                        .ascii '  '
                        .db 0x89
                        .ascii ' '
                        .db 0x86
                        .ascii '  '
                        .db 0x89
                        .ascii '      '
                        .db 0
                        .ascii '     '
                        .db 0x86
                        .ascii ' !>> <<! '
                        .db 0x89
                        .ascii '     '
                        .db 0
aHQ_Officer:            .ascii '                     '
                        .db 0
                        .ascii '        '
                        .db 0xB0, 0x8C, 0x8F, 0x8C, 0xB0
                        .ascii '        '
                        .db 0
                        .ascii '     '
                        .db 0x83, 0x83, 0x9F, 0x83, 0x83, 0x83, 0x83, 0x83, 0xAF
                        .db 0x83, 0x83
                        .ascii '     '
                        .db 0
                        .ascii '       '
                        .db 0x95, 0xB7, 0x95
                        .ascii ' '
                        .db 0xAA, 0xBB, 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x95
                        .ascii '  '
                        .db 0xB0
                        .ascii '  '
                        .db 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0x95
                        .ascii ' '
                        .db 0x8C, 0x8F, 0x8C
                        .ascii ' '
                        .db 0xAA
                        .ascii '       '
                        .db 0
                        .ascii '       '
                        .db 0xA5
                        .ascii '  O  '
                        .db 0x9A
                        .ascii '       '
                        .db 0
                        .ascii '        '
                        .db 0x89, 0xB0, 0xB0, 0xB0, 0x86
                        .ascii '        '
                        .db 0
                        .ascii '    ((** < > **))    '
                        .db 0
                        .ascii '    ((  !! !!  ))    '
                        .db 0
.ifndef BUILD_OPT_MIXED_CASE
aTitle:                 .ascii '  INVASION FORCE  -------  RADIO SHACK '
                        .db 0
aMainDisplay:           .ascii ' L-R SENSOR  %-MINE   ------RADIO SHACK------ [ USS HEPHAESTUS ['
                        .ascii ' 000 000 000 [-HEPHS 0I                     I STAR-TIME   300200'
                        .ascii ' ----------- 0-SSTN  1I                     I CONDITION    STDBY'
                        .ascii ' 000 000 000 @-JCC   2I                     I QUADRANT      0-0 '
                        .ascii ' ----------- &-JBC   3I                     I SECTOR        0-0 '
                        .ascii ' 000 000 000 X-UNKN  4I                     I TRITON MISLS   10 '
                        .ascii '  PWR DIST   %       5I                     I POWER AVAIL    99%'
                        .ascii '  HYPR&ION   20      6I                     I JOVIANS LEFT   000'
                        .ascii '  LR SENSOR  10      7I                     I ANTIMATTER PODS 03'
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        .ascii '  SR SENSOR  20      8I                     I          7  0  1  '
                        .ascii '  DEFLECTORS 20      9I                     I   SCDM:  6  -  2  '
                        .ascii '  MASERS     09       I---------------------I          5  4  3  '
.else                        
                        .ascii '  SR SENSOR  20      8I                     I          7  8  9  '
                        .ascii '  DEFLECTORS 20      9I                     I   SCDM:  4  -  6  '
                        .ascii '  MASERS     09       I---------------------I          1  2  3  '
.endif                        
                        .ascii '  TRT MISSL  11       I 0 1 2 3 4 5 6 7 8 9 I  COMMAND:         '
.else
aTitle:                 .ascii '  INVASION FORCE+  -------  RADIO SHACK '
                        .db 0
aMainDisplay:           .ascii ' L-R Sensor  %-Mine   ------RADIO SHACK------ [ USS Hephaestus ['
                        .ascii ' 000 000 000 [-Hephs 0I                     I Star-Time   300200'
                        .ascii ' ----------- 0-SStn  1I                     I Condition    STDBY'
                        .ascii ' 000 000 000 @-JCC   2I                     I Quadrant      0-0 '
                        .ascii ' ----------- &-JBC   3I                     I Sector        0-0 '
                        .ascii ' 000 000 000 X-Unkn  4I                     I Triton Misls   10 '
                        .ascii '  Pwr Dist   %       5I                     I Power Avail    99%'
                        .ascii '  Hypr&Ion   20      6I                     I Jovians Left   000'
                        .ascii '  LR Sensor  10      7I                     I Antimatter Pods 03'
.ifndef BUILD_OPT_KEYPAD_DIRS                        
                        .ascii '  SR Sensor  20      8I                     I          7  0  1  '
                        .ascii '  Deflectors 20      9I                     I   SCDM:  6  -  2  '
                        .ascii '  Masers     09       I---------------------I          5  4  3  '
.else                        
                        .ascii '  SR Sensor  20      8I                     I          7  8  9  '
                        .ascii '  Deflectors 20      9I                     I   SCDM:  4  -  6  '
                        .ascii '  Masers     09       I---------------------I          1  2  3  '
.endif                        
                        .ascii '  Trt Missl  11       I 0 1 2 3 4 5 6 7 8 9 I  Command:         '
.endif
                        .ascii '                                                                '
                        .ascii '                                                                '
                        .ascii '                                                                '

.ifdef BUILD_OPT_KEYPAD_DIRS
                        .bndry 16
dir_xlate_tbl:          .db 0xFF, 5, 4, 3, 6, 0xFF, 2, 7, 0, 1
.endif                        

; $45 bytes cleared at startup

; - antimatter pod table
;   - 3x 6-byte entries
;     +$0 = pod status (0=used, 1=launched, 2=exploded)
;     +$1/2 = pod video address delta
;     +$3/4 = pod video address
;     +$5 = pod speed countdown
antimatter_pod_tbl:     .db 0x23, 0xC3, 0xBD, 0x6F, 1, 0xCB
                        .db 0x21, 0x7E, 0xFE, 0xC3, 0xC2, 0xE0
                        .db 0x6F, 0x2B, 0x7E, 0xB7, 0xCA, 0xBD
;
eot:                    .db 0x6F
always_zero:            .db 0xFE
delay_duty_cycle_i:     .db 0x7F
power_overflow:         .db 0xC2                                ; $00=OK, $FF=overflow
cmd_flag:               .db 0xE0                                ; 00=new, $FF=none
cmd_len:                .db 0x6F
hyperdrive_disabled:    .db 0x2E                                ; $00=OK, $FF=disabled
maser_fired:            .db 0x1F                                ; $00=NO, $FF=fired
computer_malfunction:   .db 0x22                                ; $00=OK, $FF=malfunctioned
jovian_time_frozen:     .db 6                                   ; $00=normal, $FF=frozen
experimental_ray_disabled:.db 0x70                              ; $00=OK, $FF=disabled
disable_pod_update:     .db 0x2E                                ; $00=OK, $XX=disabled
critical:               .db 4                                   ; $00=OK, $01=SELF-DESTRUCT, $FF=EXPLODING
                        .db 0x22 ; "
                        .db 0x14
                        .db 0x68 ; h
; looks like this had some debug code
; hooked at $7036
unk_6FBD:               .db 0x21 ; !
                        .db    0
                        .db    0
                        .db  0xA
                        .db 0x22 ; "
                        .db    0
                        .db    0
                        .db 0x22 ; "
                        .db    2
                        .db    0
                        .db 0x21 ; !
                        .db 0x73 ; s
                        .db 0x6B ; k
                        .db 0x11
                        .db 0x42 ; B
                        .db 0x70 ; p
                        .db 0xC3 ; √
                        .db    1
                        .db 0x50 ; P
                        .db 0x91 ; ë
                        .db 0x96 ; ñ
                        .db 0xE3 ; „
                        .db 0xC2 ; ¬
                        .db  0xE
                        .db 0x70 ; p
                        .db 0xE3 ; „
                        .db 0x23 ; #
                        .db    5
                        .db 0x13
                        .db 0xC2 ; ¬
                        .db 0xCD ; Õ
                        .db 0x6F ; o
                        .db 0xC3 ; √
                        .db    1
                        .db 0x50 ; P
;
; --- end of area cleared at startup ---
;
                        .db 0x3A ; :
                        .db    0
                        .db 0xE0 ; ‡
                        .db 0xB7 ; ∑
                        .db 0xC2 ; ¬
                        .db 0x1C
                        .db 0x70 ; p
                        .db 0x3A ; :
                        .db    1
                        .db 0xE0 ; ‡
                        .db 0xFE ; ˛
                        .db 0xC3 ; √
                        .db 0xC2 ; ¬
                        .db 0x1C
                        .db 0x70 ; p
                        .db 0x3E ; >
                        .db 0xCD ; Õ
                        .db 0x32 ; 2
                        .db 0xB6 ; ∂
                        .db 0x51 ; Q
                        .db 0x21 ; !
                        .db 0xA4 ; §
                        .db 0xD0 ; –
                        .db 0x22 ; "
                        .db    6
                        .db 0x70 ; p
                        .db 0x21 ; !
STACK_WATERMARK:        .dw 0xE060
                        .db 0x22 ; "
                        .db 0x14
                        .db 0x68 ; h
                        .db 0x21 ; !
                        .db 0xCC ; Ã
                        .db 0xD0 ; –
                        .db 0x22 ; "
                        .db    8
                        .db 0x70 ; p
                        .db 0x3E ; >
                        .db 0xCD ; Õ
                        .db 0x32 ; 2
                        .db  0xB
                        .db 0x70 ; p
                        .db 0xC3 ; √
                        .db 0xBD ; Ω
                        .db 0x6F ; o
                        .db 0x2A ; *
                        .db 0x2E ; .
                        .db 0x70 ; p
                        .db 0x77 ; w
                        .db 0x23 ; #
                        .db 0x1A
                        .db 0x77 ; w
                        .db 0x23 ; #
                        .db 0x22 ; "
                        .db 0x2E ; .
                        .db 0x70 ; p
                        .db 0xC3 ; √
                        .db 0xD6 ; ÷
                        .db 0x6F ; o
                        .db 0x21 ; !
                        .db 0x39 ; 9
                        .db 0x70 ; p
                        .db 0x11
                        .db 0xB6 ; ∂
                        .db 0x51 ; Q
; ---------------------------------------------------------------------------

loc_7022:
                        ld      a, (hl)
                        cp      #0xFF
                        jp      Z, loc_7030
                        ld      (de), a
                        inc     hl
                        inc     de
                        jp      loc_7022
; ---------------------------------------------------------------------------
                        .db  0xC
                        .db 0x5B ; [
; ---------------------------------------------------------------------------

loc_7030:
                        ld      hl, #3
                        ld      (cmd_l_vector), hl              ; hook "L" cmd
                        jp      unk_6FBD                        ; debug code???
; ---------------------------------------------------------------------------
                        .db 0xDB, 0, 0, 0xE6, 0x40, 0xC8, 0xDB, 1, 0xFF, 0, 0x27
                        .db 0x5A, 0x2E, 0x2C, 0x5A, 0x27, 0xD, 0xD, 0x31, 0x34, 0x37
                        .db 0x31, 0x20, 0x20, 0x44, 0x53, 0x20, 0x33, 0x32, 0xD
                        .db 0x11, 0x31, 0x34, 0x37, 0x32, 0x20, 0x53, 0x54, 0x41
                        .db 0x43, 0x4B, 0x20, 0x44, 0x42, 0x20, 0x30, 0xD, 1, 0x20
                        .db 0x33, 0x38, 0xD, 0x34, 0x31, 0x32, 0x38, 0x30, 0x20
                        .db 0x20, 0x41, 0x53, 0x43, 0x20, 0x2F, 0x41, 0x52, 0x45
                        .db 0x20, 0x53, 0x55, 0x43, 0x48, 0x20, 0x51, 0x55, 0x45
                        .db 0x53, 0x54, 0x49, 0x4F, 0x4E, 0x53, 0x20, 0x4F, 0x4E
                        .db 0x20, 0x59, 0x4F, 0x55, 0x52, 0x20, 0x4D, 0x49, 0x4E
                        .db 0x44, 0x20, 0x4F, 0x46, 0x54, 0x45, 0x4E, 0x3F, 0x2F
                        .db 0xD, 0xD, 0x31, 0x32, 0x38, 0x31, 0x20, 0x20, 0x44, 0x42
                        .db 0x20, 0x34, 0x30, 0xD, 0x36, 0x31, 0x32, 0x38, 0x32
                        .db 0x20, 0x20, 0x41, 0x53, 0x43, 0x20, 0x2F, 0x57, 0x48
                        .db 0x41, 0x54, 0x20, 0x49, 0x53, 0x20, 0x49, 0x54, 0x20
                        .db 0x54, 0x48, 0x41, 0x54, 0x20, 0x59, 0x4F, 0x55, 0x20
                        .db 0x52, 0x45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xF1
; end of 'CODE'

                        .end START
