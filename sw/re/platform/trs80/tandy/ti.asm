 
; **********************************************************
; 100% relocatable source code for TRS-80 TANDY INVADERS
; - reverse-engineered by msmcdoug@gmail.com 2014
; - produces 100% identical binary to original
; - option to replace TRS-80 ROM routines
; - option to build for MICROBEE
; **********************************************************

; TANDY INVADERS was written in 1979 (according to the text embedded in the code),
; and - impressively - ran on a 4KB TRS-80 Model I (Level II only) computer. As
; the name suggests, it is a port of the classic arcade game 'Space Invaders'.
; 
; Whilst arguably not the best port of Space Invaders for the TRS-80 (that honour
; would likely go to Adventure International's 'Space Intruders'), it was almost 
; certainly the first (machine language) version and does a good job of 
; replicating the spirit of the arcade game, especially considering the chunky
; graphics of the TRS-80 and the fact that it runs in just 4KB of memory. And no
; doubt for this reason, the game does not have any sound at all.
; 
; The game was also hacked and distributed by Dick Smith Electronics in 
; Australia as "The Space Invader Game". The binary differs by only 189 bytes and 
; for some inexplicable reason the left/right keys were changed to "2" and "0"
; which are on opposite sides of the keyboard! A very lazy hack indeed.
;
; [Incidentally this is the very reason this file exists. I saw a YouTube video
;  idly claiming that invaders was written by programmers contracted by Dick
;  Smith Electronics - I was pretty sure it was a simple hack of Tandy Invaders
;  and so I went looking to confirm that it was indeed the case. Then I started 
;  to disassemble the game and it ended up as a port to the Microbee!]
;
; The original binary has been disassembled with the unrivalled IDAPro 
; disassembler and reverse-engineered to the extent that every line of code has 
; been understood and duly commented. The result is a 100% relocatable source 
; file that may be assembled to produce the exact binary of the original.
; 
; The original game was distributed on cassette and like most early TRS-80 games
; loads in low memory that was subsequently used by the various Disk Operating
; Systems of the day. For this reason a lot of TRS-80 games are loaded from disk
; into high memory and then moved to their original location, overwriting (and
; hence effectively disabling) the DOS. This source allows the game to be
; relocated into high memory, and loaded directly from disk and even potentially
; have a high score load/save game option added.
; 
; The game makes use of five (5) TRS-80 Level II ROM routines, and for this reason
; requires the Level II BASIC ROM vectors to be valid and in place. When running
; (from high memory) with a DOS loaded, the integer print routine (used when you
; hit a UFO) crashes for reasons I did not bother to look into - that's left as
; an exercise for the reader.
; 
; In order to circumvent this issue, and also to allow porting to other computers,
; I've implemented replacement routines that negate the requirement to have a
; TRS-80 Level II ROM at all. The only 'controversial' routine is the random
; number generator; the ROM routine is intertwined with the other maths routines
; and was way overkill for the game. I've implemented a very simple routine based
; on the Z80 refresh register which appears not to have affected gameplay.
; 
; The source contains an option to build the game for the Australian Microbee 
; computer; unique amongst TRS-80 contemparies in that the video memory and
; graphics characters map very closely to the TRS-80, making porting much easier
; than other machines. There are several options for the Microbee output - the
; most generic being the .BEE format which is a straight binary and most
; commonly loading and executing at 900h. This same output can be converted to
; the emulator .TAP format and directly loaded in the uBee512 emulator.
; 
; The game source makes for interesting reading and certainly takes what I
; would consider to be a unique approach to design, most likely due to the 4KB
; constraint. Rather than keep track of objects in tables in memory for example,
; it uses the video memory itself to ascertain the state of the game and only 
; requires a handful of variables. Clever!
; 
; Although it made very heavy use of video memory, most of the references were
; identified and labelled by the disassembler as offsets from the base address.
; There are, however, a few areas of the code that require special attention
; when moving the video base address (for the Microbee for example) that are not
; immediately obvious. I've attempted to use address arithmetic to mitigate
; this issue, but there is the odd bit test that needs to be revisited should
; the video be moved again.
; 
; The only other TRS-80-specific code was the direct read of the keyboard scan
; matrix - a really, really nice feature of the TRS-80. These parts of the code
; have been patched as necessary; you only need to see the hoops that you need
; to jump through on the Microbee to appreciate how nice and easy it was to read
; the TRS-80 keyboard!
; 
; The source has been formatted for the ASZ80 assembler, primarily because that
; was one of the built-in options in IDAPro. There's nothing too assembler-
; specific AFAIK, except perhaps a few expressions for address arithmetic.
;

; Processor:        z80
; Target assembler: ASxxxx by Alan R. Baldwin v1.5
       		.area   idaseg (ABS)
					.z80

; build options
;					.define		TRS80
					.ifndef TRS80
					.define		MICROBEE
					.endif
; optional for TRS-80, mandatory for MICROBEE					
					.define		NO_ROM
					
.ifdef TRS80
; original code location on TRS-80
;	codebase	.equ	0x4300
	video_ram .equ 	0x3c00
; original stack location	
; - comment out to use stack at end of code
;	stack			.equ	0x428a
; new location in higher memory
	codebase	.equ	0x5200
.endif
.ifdef MICROBEE
; .COM file format					
;	codebase	.equ	0x0100			
; .BEE/.TAP file format
	codebase	.equ	0x0900
	video_ram .equ 	0xF000
.endif		

; TRS-80 ROM routines
.ifndef		NO_ROM
	putc			.equ	0x0033
	delay			.equ	0x0060
	prtnum		.equ	0x0faf
	cursor		.equ	0x4020
.endif

; ===========================================================================

        .org codebase

.ifdef MICROBEE
				ld			hl,#m6545_data+15
				ld			b,#16									; 16 registers to init
1$:			ld			a,b
				dec			a
				out			(0x0c),a							; register address
				ld			a,(hl)
				out			(0x0d),a							; register data
				dec			hl
				djnz		1$
; setup the LORES character set (copied from ROM 0x8027)
init_lores:
				ld			hl,#0xf800						; start of PCG RAM
				ld			c,#128								; 1st graphic character
1$:			ld			e,c										; get character
				ld			d,#0x03								; 3 lines of pixels
2$:			xor			a											; clear pixel line
				bit			0,e										; left pixel on?
				jr			z,3$									; no skip
				or			#0xf0									; data for left pixel
3$:			bit			1,e										; right pixel on?
				jr			z,4$									; no skip
				or			#0x0f									; data for right pixel
4$:			ld			b,#5									; 5 raster lines per LORES pixel
5$:			ld			(hl),a								; store pixel line data
				inc			hl										; next PCG RAM location
				djnz		5$										; loop thru 5 raster lines
				rrc			e
				rrc			e											; next 2 bits of character
				dec			d											; next pixel line
				jr			nz,2$									; loop thru 3 pixel lines
				ld			(hl),a								; 16th raster scan line
				inc			hl										; next PCG RAM location
				inc			c											; done all characters?
				jr			nz,1$									; no, loop
				jp			START
				
m6545_data:
; 'mbeeic' from MESS initialises with this data
				.db			0x6b,0x40,0x51,0x37,0x12,0x09,0x10,0x11
;				.db			0x48,0x0f,0x6f,0x0f,0x00,0x00,0x00,0x00
; (0x0A)=0x2f to hide/turn cursor off
				.db			0x48,0x0f,0x2f,0x0f,0x00,0x00,0x00,0x00
.endif
        
; ===========================================================================

; Segment type: Regular
; segment 'ram'
fire_throttle:.ds 1
invaders_left:.ds 1
row_1_invader_addr:.ds 2
row_2_invader_addr:.ds 2
row_3_invader_addr:.ds 2
row_4_invader_addr:.ds 2
invader_dir:.ds 1
ufo_TTL:.ds 1
ufo_timer:.ds 1
ufo_dir:.ds 1
wave_no:.ds 1
no_lives:.ds 1
; end of 'ram'

; File Name   : tandy.bin
; Format      : Binary File
; Base Address: 0000h Range: 4310h - 5000h Loaded length: 0CF0h
; ===========================================================================

; Segment type: Pure code
; segment 'code'
				        
ufo_active:.db 0
bullet_active:.db 0
unused_4312:.db 0xC9
base_centre:.dw 0x45B0
unused_4315:.db 1
init_row_1_invader_addr:.dw video_ram+0x40
init_row_2_invader_addr:.dw video_ram+0xC0
init_row_3_invader_addr:.dw video_ram+0x140
init_row_4_invader_addr:.dw video_ram+0x1C0
bullet_addr:.dw video_ram+0x253
game_timer:.db 0x60
invader_timer:.db 0x2B
keybd_state:.db 0
invader_30pt:.db 0xA0, 0xB6, 0xBF, 0xB9, 0x90, 0x1A, 1, 0x20, 0x86, 0x20, 0x89
        .db 0x20, 0
invader_20pt:.db 0x9C, 0xB7, 0xBF, 0xBB, 0xAC, 0x1A, 1, 0x8C, 0x83, 0x20, 0x83
        .db 0x8C, 0
invader_10pt:.db 0xBE, 0xBB, 0xBF, 0xB7, 0xBD, 0x1A, 1, 0x8C, 0x83, 0x20, 0x83
        .db 0x8C, 0
ufo:    .db 0x8C, 0xB7, 0xB7, 0xB7, 0xB7, 0x8C, 0
shield: .db 0xB8, 0xBF, 0xBF, 0xBF, 0xBF, 0xBF, 0xB4, 0x1A, 8, 8, 1, 0x8F
        .db 0x8F, 0x83, 0x83, 0x83, 0x8F, 0x8F, 0
player: .db 0xB8, 0xBC, 0xBF, 0xBC, 0xB4, 0
explosion:.db 0x82, 0x84, 0x20, 0x88, 0x81, 0x1A, 1, 0x88, 0x81, 0x20, 0x82
        .db 0x84, 0
        .db    0 ;  
        .db    0 ;  
blank_space:.db 0x1B, 1, 0x20, 0x20, 0x20, 0x20, 0x20, 0x1A, 1, 0x20, 0x20
        .db 0x20, 0x20, 0x20, 0
aPlay:  .ascii 'PLAY'
        .db 9
        .dw video_ram+0x00D6
aTandyInvaders:.ascii 'TANDY       INVADERS'
        .db 9
        .dw video_ram+0x0154
aScoreAdvanceTa:.ascii '* SCORE ADVANCE TABLE *'
        .db 0
aTandyElectroni:.ascii '* TANDY ELECTRONICS *'
        .db 0
a30Points:.ascii '<----   30  POINTS'
        .db 9
        .dw video_ram+0x021E
a20Points:.ascii '<----   20  POINTS'
        .db 9
        .dw video_ram+0x029E
a10Points:.ascii '<----   10  POINTS'
        .db 9
        .dw video_ram+0x031E
a_Mystery:.ascii '<----   ?   MYSTERY'
        .db 0
aPressZKeyToMov:.ascii 'PRESS "Z" KEY TO MOVE LEFT'
        .db 9
        .dw video_ram+0x0113
aPressXKeyToMov:.ascii 'PRESS "X" KEY TO MOVE RIGHT'
        .db 9
        .dw video_ram+0x0193
aPressKeyToFire:.ascii 'PRESS " " KEY TO FIRE !'
        .db 9
        .dw video_ram+0x0213
aPressRKeyToSta:.ascii 'PRESS "R" KEY TO START'
        .db 0
aGAMEOVER:.ascii 'G A M E - O V E R'
        .db 0
aScore00000High:.ascii '  SCORE  00000                                 HIGH-SCOR'
        .ascii 'E 00000'
        .db 0

; --------------- S U B R O U T I N E ---------------------------------------


display_message:
        push    bc

loc_0_44E6:                             ; get character
        ld      a, (hl)
        or      a                       ; finished?
        jr      Z, loc_0_4503           ; yes, exit
        cp      #1
        jr      NZ, loc_0_44FC
        ld      b, #5                   ; 5 characters to print
        ld      a, #8                   ; backspace

loc_0_44F2:
        push    de
        call    putc                    ; display character
        pop     de
        djnz    loc_0_44F2              ; loop

loc_0_44F9:                             ; next character
        inc     hl
        jr      loc_0_44E6              ; loop
; ---------------------------------------------------------------------------

loc_0_44FC:
        push    de
        call    putc                    ; display character
        pop     de
        jr      loc_0_44F9              ; loop
; ---------------------------------------------------------------------------

loc_0_4503:
        pop     bc
        ret     
; End of function display_message


; --------------- S U B R O U T I N E ---------------------------------------


display_message_slowly:
        ld      a, (hl)                 ; get character
        or      a                       ; done?
        ret     Z                       ; yes, exit
        push    de
        push    bc
        call    putc                    ; display character
        ld      bc, #8960               ; ~130ms
        call    delay                   ; delay
        pop     bc
        pop     de
        inc     hl                      ; next character
        jr      display_message_slowly  ; loop through message
; End of function display_message_slowly


; --------------- S U B R O U T I N E ---------------------------------------


wipe_screen_left_to_right_slow:
        exx     
        ld      hl, #video_ram-1				; start of video (-1)
        ld      b, #0x40 ; '@'          ; characters/line

loc_0_451E:
        push    bc
        inc     hl                      ; next column
        push    hl
        ld      b, #0xF                 ; 15 lines
        ld      a, #0x20 ; ' '          ; space
        ld      de, #0x40 ; '@'         ; next line address

loc_0_4528:                             ; display character
        ld      (hl), a
        add     hl, de                  ; next line
        djnz    loc_0_4528              ; loop all lines
        call    delay_1_5ms
        pop     hl
        pop     bc
        djnz    loc_0_451E              ; loop all columns
        exx     
        ret     
; End of function wipe_screen_left_to_right_slow

; ---------------------------------------------------------------------------

START:
        di      
        ld      a, #0xF
        call    putc                    ; display character
        ld      sp, #stack
        ld      hl, #video_ram+0x3C0    ; cursor position
        ld      (cursor), hl
        ld      hl, #aScore00000High    ; "  SCORE  00000                         "...
        call    display_message
        ld      a, #0x20 ; ' '
        ld      (video_ram+0x3FF), a

attract_loop:
        call    wipe_screen_left_to_right_slow
        ld      hl, #video_ram+0x394    ; cursor position
        ld      (cursor), hl
        ld      hl, #aTandyElectroni    ; "* TANDY ELECTRONICS *"
        call    display_message
        ld      hl, #video_ram+0x9E     ; cursor position
        ld      (cursor), hl
        ld      hl, #aPlay              ; "PLAY"
        call    print_slow_and_check_for_R_key
        ld      hl, #video_ram+0x192    ; cursor position
        ld      (cursor), hl
        ld      hl, #invader_30pt
        call    display_message
        ld      hl, #video_ram+0x212    ; cursor position
        ld      (cursor), hl
        ld      hl, #invader_20pt
        call    display_message
        ld      hl, #video_ram+0x292    ; cursor poition
        ld      (cursor), hl
        ld      hl, #invader_10pt
        call    display_message
        ld      hl, #video_ram+0x312    ; cursor position
        ld      (cursor), hl
        ld      hl, #ufo
        call    display_message
        ld      hl, #video_ram+0x19E    ; cursor position
        ld      (cursor), hl
        ld      hl, #a30Points          ; "<----   30  POINTS"
        call    print_slow_and_check_for_R_key
        ld      bc, #0xFFFF             ; ~1s
        call    delay                   ; delay
        call    delay                   ; delay

loc_0_45AF:
        call    wipe_screen_left_to_right_slow
        call    check_for_R_key
        ld      hl, #video_ram+0x394
        ld      (cursor), hl
        ld      hl, #aTandyElectroni    ; "* TANDY ELECTRONICS *"
        call    display_message
        ld      hl, #video_ram+0x93
        ld      (cursor), hl
        ld      hl, #aPressZKeyToMov    ; "PRESS \"Z\" KEY TO MOVE LEFT"
        call    print_slow_and_check_for_R_key
        ld      bc, #65535              ; ~1s
        call    delay                   ; delay
        call    delay                   ; delay
        jp      attract_loop

; --------------- S U B R O U T I N E ---------------------------------------


check_for_R_key:
.ifdef TRS80
        ld      a, (0x3804)             ; read keyboard
        cp      #4                      ; 'R'?
.endif
.ifdef MICROBEE
				ld			a, #18 									; 'R'
				call		testky
.endif        
        jp      Z, start_game           ; yes, skip
        ret     
; End of function check_for_R_key


; --------------- S U B R O U T I N E ---------------------------------------


compare_video_addresses:
        push    hl                      ; bullet address
        push    de                      ; video address to check
        ld      a, h
        cp      d                       ; same MSB?
        jr      Z, loc_0_45EE           ; yes, continue
        jr      NC, loc_0_45F4          ; continue if bullet below

no_hit:                                 ; flag no hit
        xor     a

loc_0_45EB:
        pop     de
        pop     hl
        ret     
; ---------------------------------------------------------------------------

loc_0_45EE:
        ld      a, l
        cp      e                       ; same address?
        jr      Z, loc_0_45F8           ; yes, continue
        jr      C, no_hit               ; exit if bullet above

loc_0_45F4:                             ; flag bullet right/below
        ld      a, #0xFF
        jr      loc_0_45EB
; ---------------------------------------------------------------------------

loc_0_45F8:                             ; flag bullet match
        ld      a, #0x20 ; ' '
        jr      loc_0_45EB
; End of function compare_video_addresses


; --------------- S U B R O U T I N E ---------------------------------------


animate_invaders:
        push    hl
        push    bc
        ld      hl, (row_1_invader_addr)
        ld      b, #0x3F ; '?'          ; characters/line-1

animate_top_row:                        ; get character from video
        ld      a, (hl)
        bit     7, a                    ; graphic character?
        jr      Z, loc_0_460B           ; no, skip
        xor     #0xF                    ; invert top 4 pixels
        ld      (hl), a                 ; display

loc_0_460B:                             ; next video address
        inc     hl
        djnz    animate_top_row         ; loop thru line
        push    de
        ld      hl, (row_2_invader_addr)
        call    animate_invader_row
        ld      hl, (row_3_invader_addr)
        call    animate_invader_row
        ld      hl, (row_4_invader_addr)
        call    animate_invader_row
        pop     de
        pop     bc
        pop     hl
        ret     
; End of function animate_invaders


; --------------- S U B R O U T I N E ---------------------------------------


animate_invader_row:
        push    hl                      ; invader row addr
        ld      b, #0x40 ; '@'          ; characters/line

loc_0_4628:                             ; get character from video
        ld      a, (hl)
        cp      #0x8C ; 'Œ'
        jr      Z, loc_0_4636
        cp      #0x83 ; 'ƒ'
        jr      NZ, loc_0_4639          ; not part of animation, skip
        ld      a, #0x8C ; 'Œ'          ; 0x83->0x8C
        ld      (hl), a                 ; display
        jr      loc_0_4639
; ---------------------------------------------------------------------------

loc_0_4636:                             ; 0x8C->0x83
        ld      a, #0x83 ; 'ƒ'
        ld      (hl), a                 ; display

loc_0_4639:                             ; next video address
        inc     hl
        djnz    loc_0_4628              ; loop thru line
        pop     hl
        ret     
; End of function animate_invader_row


; --------------- S U B R O U T I N E ---------------------------------------


move_video_line_right_HL:
        push    hl
        ld      de, #0x3E ; '>'         ; start at right end
        add     hl, de
        push    hl
        pop     de
        inc     de                      ; DE = end of row
        ld      b, #63                  ; number of characters/line-1
        ld      a, (de)                 ; get character from end of row
        bit     7, a                    ; graphic?
        jr      Z, loc_0_4650           ; no, skip
        ld      a, #0x20 ; ' '          ; space
        ld      (de), a                 ; display space

loc_0_4650:                             ; graphic character left byte?
        bit     7, (hl)
        jr      Z, loc_0_4658           ; no, skip
        ld      a, (hl)                 ; get character left byte
        ld      (de), a                 ; display to the right
        ld      (hl), #0x20 ; ' '       ; display space at left-hand byte

loc_0_4658:
        dec     hl
        dec     de
        djnz    loc_0_4650              ; loop through line
        pop     hl
        ld      (hl), #0x20 ; ' '       ; display space
        ret     
; End of function move_video_line_right_HL


; --------------- S U B R O U T I N E ---------------------------------------


move_video_line_left_HL:
        push    hl
        push    hl
        pop     de
        inc     hl
        ld      b, #63                  ; characters/line-1
        ld      a, (de)                 ; get character LH byte
        bit     7, a                    ; graphic?
        jr      Z, loc_0_466E           ; no, skip
        ld      a, #0x20 ; ' '          ; space
        ld      (de), a                 ; display space LH byte

loc_0_466E:                             ; graphic RH byte?
        bit     7, (hl)
        jr      Z, loc_0_4676           ; no, skip
        ld      a, (hl)                 ; get character from video (RH byte)
        ld      (de), a                 ; display LH byte
        ld      (hl), #0x20 ; ' '       ; space RH byte

loc_0_4676:
        inc     hl
        inc     de
        djnz    loc_0_466E              ; loop thru row
        pop     hl
        ld      de, #0x3F ; '?'
        add     hl, de
        ld      (hl), #0x20 ; ' '       ; display space on end of row
        ret     
; End of function move_video_line_left_HL


; --------------- S U B R O U T I N E ---------------------------------------


add_10_to_score:
        push    hl
        push    bc
        ld      hl, #video_ram+0x3CC    ; tens digit
        call    add_1_to_score_digit
        jr      NZ, loc_0_46A1          ; skip if no carry
        dec     hl                      ; hundreds digit
        call    add_1_to_score_digit
        jr      NZ, loc_0_46A1          ; skip if no carry
        dec     hl                      ; thousands digit
        call    add_1_to_score_digit
        jr      NZ, loc_0_46A1          ; skip if no carry
        dec     hl                      ; tens of thousands digit
        call    add_1_to_score_digit
        jr      NZ, loc_0_46A1          ; skip if no carry
        call    zero_score

loc_0_46A1:
        pop     bc
        pop     hl
        ret     
; End of function add_10_to_score


; --------------- S U B R O U T I N E ---------------------------------------


add_1_to_score_digit:
        ld      a, (hl)                 ; get score digit
        cp      #0x39 ; '9'             ; 9?
        jr      Z, flag_carry           ; yes, skip
        inc     a                       ; add 1
        ld      (hl), a                 ; store
        ret     
; ---------------------------------------------------------------------------

flag_carry:                             ; set to 0
        ld      (hl), #0x30 ; '0'
        xor     a                       ; flag carry
        ret     
; End of function add_1_to_score_digit


; --------------- S U B R O U T I N E ---------------------------------------


zero_score:
        ld      hl, #video_ram+0x3C9    ; score
        ld      b, #5                   ; 5 digits to zap

loc_0_46B5:                             ; set digit to 0
        ld      (hl), #0x30 ; '0'
        inc     hl                      ; next digit
        djnz    loc_0_46B5              ; loop thru all score digits
        ret     
; End of function zero_score


; --------------- S U B R O U T I N E ---------------------------------------


update_score_and_chk_bonus_life:
        call    add_10_to_score
        ld      hl, #video_ram+0x3CC    ; tens digit of score
        ld      a, (hl)                 ; get digit
        cp      #0x30 ; '0'             ; 0?
        jr      NZ, loc_0_46E2          ; no, exit
        dec     hl                      ; hundreds digit
        ld      a, (hl)                 ; get digit
        cp      #0x35 ; '5'             ; 5?
        jr      NZ, loc_0_46E2          ; no, skip
        dec     hl                      ; thousands digit
        ld      a, (hl)                 ; get digit
        cp      #0x31 ; '1'             ; 1?
        jr      NZ, loc_0_46E2          ; no, skip
        dec     hl                      ; tens of thousands digit
        ld      a, (hl)                 ; get digit
        cp      #0x30 ; '0'             ; 0?
        jr      NZ, loc_0_46E2          ; no, skip
        ld      a, (no_lives)
        inc     a                       ; bonus life
        ld      (no_lives), a
        call    display_lives_left

loc_0_46E2:
        djnz    update_score_and_chk_bonus_life
        ret     
; End of function update_score_and_chk_bonus_life


; --------------- S U B R O U T I N E ---------------------------------------


handle_fire:
        ld      a, (bullet_active)
        or      a                       ; already fired?
        ret     NZ                      ; yes, return
        ld      a, (fire_throttle)
        or      a                       ; waiting for throttle?
        ret     NZ                      ; yes, return
        ld      a, #20                  ; init throttle value
        ld      (fire_throttle), a
        ld      a, (ufo_active)
        or      a                       ; on-screen?
        jr      NZ, loc_0_4702          ; yes, skip
        ld      a, (ufo_dir)
        xor     #1                      ; toggle direction
        ld      (ufo_dir), a

loc_0_4702:
        ld      a, #1
        ld      (bullet_active), a      ; flag fired
        exx     
        ld      hl, (base_centre)
        ld      de, #0xFFC0             ; -64
        add     hl, de                  ; video address of row above
        ld      (bullet_addr), hl       ; save
        ld      a, (hl)                 ; get character from video
        cp      #0x20 ; ' '             ; space?
        jp      NZ, loc_0_4807          ; no, skip
        ld      (hl), #0x5B ; '['       ; display player bullet
        exx     
        ret     
; End of function handle_fire


; --------------- S U B R O U T I N E ---------------------------------------


update_bullet:
        exx     
        ld      hl, (bullet_addr)
        ld      a, (hl)                 ; get character from video
        cp      #0x5B ; '['             ; player bullet?
        jr      NZ, handle_bullet_hit   ; no, skip
        ld      (hl), #0x20 ; ' '       ; display space
        ld      de, #0xFFC0             ; -64
        add     hl, de                  ; address of row above
.ifdef TRS80        
        bit     2, h                    ; off the top of the screen?
.endif
.ifdef MICROBEE        
        bit     4, h                    ; off the top of the screen?
.endif        
        jr      Z, delete_bullet        ; yes, skip
        ld      a, (hl)                 ; get character from video
        cp      #0x80 ; '€'             ; graphic space?
        jr      Z, display_bullet       ; yes, skip
        cp      #0x20 ; ' '             ; space?
        jr      NZ, handle_bullet_hit   ; no, skip

display_bullet:                         ; display player bullet
        ld      (hl), #0x5B ; '['

loc_0_473A:                             ; update bullet address
        ld      (bullet_addr), hl
        exx     
        ret     
; ---------------------------------------------------------------------------

handle_bullet_hit:                      ; 2nd line on display
        ld      de, #video_ram+0x40
        call    compare_video_addresses
        or      a                       ; bullet in top line now?
        jr      Z, check_and_handle_ufo_hit ; yes, skip
        bit     7, (hl)                 ; graphic character?
        jp      Z, chk_and_handle_bullet_hits_bomb ; no, skip
        push    hl                      ; bullet address
        call    find_end_of_lowest_invader_row
        pop     de                      ; bullet address
        call    compare_video_addresses
        or      a                       ; have we hit an invader?
        push    de                      ; bullet address
        pop     hl                      ; bullet address
        jp      Z, handle_shield_hit    ; no, must be a shield
        call    get_invader_address
        ld      (cursor), hl            ; set cursor position
        ld      a, (hl)                 ; get character from video
        ld      b, #3                   ; default to 30 pts
        cp      #0xA0 ; ' '             ; 30pt invader character?
        jr      Z, loc_0_476C           ; yes, skip
        jr      C, loc_0_476B           ; 20pt invader character, skip
        dec     b                       ; 10pt invader

loc_0_476B:
        dec     b

loc_0_476C:
        call    update_score_and_chk_bonus_life
        ld      hl, #explosion
        call    display_message
        call    delay_15ms
        ld      hl, #blank_space
        call    display_message
        ld      a, (invaders_left)
        dec     a                       ; end of wave?
        jp      Z, end_of_wave          ; yes, go
        ld      (invaders_left), a
        ld      de, #0
        call    update_invader_row_addresses
        jr      clear_bullet_active
; ---------------------------------------------------------------------------

delete_bullet:                          ; characters/line
        ld      de, #0x40 ; '@'
        add     hl, de                  ; next row
        ld      (hl), #0x20 ; ' '       ; display space

clear_bullet_active:
        xor     a
        ld      (bullet_active), a      ; clear fired flag
        exx     
        ret     
; ---------------------------------------------------------------------------

check_and_handle_ufo_hit:               ; graphic character?
        bit     7, (hl)
        jr      Z, clear_bullet_active  ; no, hit a bomb, exit
        ld      hl, #video_ram
        ld      b, #64                  ; characters/line

loc_0_47A5:                             ; graphic character?
        bit     7, (hl)
        jr      NZ, loc_0_47AC          ; yes, skip
        inc     hl                      ; next video address
        djnz    loc_0_47A5              ; loop thru line

loc_0_47AC:
        push    hl
        ld      hl, #video_ram
        call    clear_video_line_HL     ; wipe UFO
        ld      hl, #6                  ; RAND(1-6)
        call    rand
        ld      b, l                    ; get result
        xor     a                       ; clear carry
        ld      c, #5                   ; 50 pts

loc_0_47BD:                             ; multiplier
        add     a, c
        djnz    loc_0_47BD              ; calc ufo score
        ld      b, a
        push    af
        call    update_score_and_chk_bonus_life
        pop     af
        pop     hl
        ld      (cursor), hl            ; cursor position
        ld      b, #10
        ld      e, a                    ; bonus/10
        ld      hl, #0
        ld      d, l

loc_0_47D1:
        add     hl, de
        djnz    loc_0_47D1              ; calc bonus
        ld      a, #0x3C ; '<'
        call    putc                    ; display character
        call    prtnum                  ; display integer in HL
        ld      a, #0x3E ; '>'
        call    putc                    ; display character
        xor     a
        ld      (ufo_active), a         ; flag inactive
        ld      (ufo_timer), a          ; reset timer
        jr      clear_bullet_active
; ---------------------------------------------------------------------------

chk_and_handle_bullet_hits_bomb:
        push    hl
        ld      hl, #3                  ; RAND(1-3)
        call    rand
        ld      a, l                    ; get result
        pop     hl
        cp      #3
        push    af
        call    NZ, handle_bullet_destroys_bomb
        pop     af
        cp      #2
        jp      C, display_bullet       ; RAND=1
        jp      NZ, clear_bullet_active ; RAND=3
        ld      (hl), #0x20 ; ' '       ; display space
        jp      loc_0_473A
; ---------------------------------------------------------------------------

loc_0_4807:
        exx     
        jp      update_bullet
; ---------------------------------------------------------------------------

handle_shield_hit:
        call    erode_shield_from_bullet
        jr      clear_bullet_active
; End of function update_bullet


; --------------- S U B R O U T I N E ---------------------------------------


erode_shield_from_bomb:
        push    hl
        push    bc
        ld      a, (hl)                 ; get character from video
        ld      c, a
        ld      a, #0xBC ; '¼'
        and     c
        cp      c
        jr      NZ, loc_0_4822
        ld      a, #0xB0 ; '°'
        and     c
        cp      c
        jr      NZ, loc_0_4822
        ld      a, #0x20 ; ' '

loc_0_4822:
        cp      #0x80 ; '€'
        jr      NZ, loc_0_4828
        ld      a, #0x20 ; ' '

loc_0_4828:                             ; update character
        ld      (hl), a
        pop     bc
        pop     hl
        jp      dec_bomb_count
; End of function erode_shield_from_bomb


; --------------- S U B R O U T I N E ---------------------------------------


erode_shield_from_bullet:
        push    hl                      ; bullet address
        push    bc
        ld      a, (hl)                 ; get character from video
        ld      c, a
        ld      a, #0x8F ; ''          ; top 4 cells?
        and     c
        cp      c                       ; match?
        jr      NZ, loc_0_4840          ; no, skip
        ld      a, #0x83 ; 'ƒ'          ; top 2 cells?
        and     c
        cp      c                       ; match?
        jr      NZ, loc_0_4840          ; no, skip
        ld      a, #0x20 ; ' '

loc_0_4840:                             ; blank graphic?
        cp      #0x80 ; '€'
        jr      NZ, loc_0_4846          ; no, skip
        ld      a, #0x20 ; ' '

loc_0_4846:                             ; update character
        ld      (hl), a
        pop     bc
        pop     hl
        ret     
; End of function erode_shield_from_bullet


; --------------- S U B R O U T I N E ---------------------------------------


find_end_of_lowest_invader_row:
        ld      hl, (row_4_invader_addr)
        ld      a, h
        or      a                       ; any invaders left in row?
        jr      NZ, loc_0_4862          ; yes, continue
        ld      hl, (row_3_invader_addr)
        ld      a, h
        or      a                       ; any invaders left in row?
        jr      NZ, loc_0_4862          ; yes, continue
        ld      hl, (row_2_invader_addr)
        ld      a, h
        or      a                       ; any invaders left in row?
        jr      NZ, loc_0_4862          ; yes, continue
        ld      hl, (row_1_invader_addr)

loc_0_4862:
        push    de
        push    bc
        ld      de, #63                 ; characters/line-1
        add     hl, de                  ; start at end of line
        ld      b, #63                  ; characters/line-1

loc_0_486A:                             ; graphic character?
        bit     7, (hl)
        jr      NZ, loc_0_4871          ; yes, return
        dec     hl                      ; previous video address
        djnz    loc_0_486A              ; loop thru line

loc_0_4871:
        pop     bc
        pop     de
        ret     
; End of function find_end_of_lowest_invader_row

; ---------------------------------------------------------------------------

end_of_wave:
        jp      new_wave

; --------------- S U B R O U T I N E ---------------------------------------


check_for_graphic_in_column:
        ld      de, #64                 ; characters/line
        ld      b, #13

loc_0_487C:                             ; graphic character?
        bit     7, (hl)
        jr      NZ, loc_0_4886          ; yes, skip
        add     hl, de                  ; next line
        djnz    loc_0_487C              ; loop thru 13 lines
        ld      a, #0x20 ; ' '          ; flag no match
        ret     
; ---------------------------------------------------------------------------

loc_0_4886:                             ; flag match
        xor     a
        ret     
; End of function check_for_graphic_in_column


; --------------- S U B R O U T I N E ---------------------------------------


check_and_handle_move:
.ifdef TRS80
        ld      a, (0x3808)             ; keyboard
        and     #5                      ; "X" or "Z" pressed?
        ret     Z                       ; no return
        cp      #4                      ; "Z"?
        jr      NC, handle_move_left    ; yes, skip
.endif
.ifdef MICROBEE
				ld			a, #26 									; 'Z'?
				call		testky
				jr			z, handle_move_left
				ld			a, #24 									; 'X'?
				call		testky
				ret			nz
.endif        
        ld      a, (video_ram+0x3BB)    ; right-most position for base
        bit     7, a                    ; graphic character?
        ret     NZ                      ; yes, return (can't move right)
        exx     
        ld      hl, #video_ram+0x380    ; base row
        call    move_video_line_right_HL
        ld      hl, (base_centre)
        inc     hl                      ; move player right
        ld      (base_centre), hl

loc_0_48A6:
        exx     
        ret     
; ---------------------------------------------------------------------------

handle_move_left:
        ret     NZ
        ld      a, (video_ram+0x384)    ; left-most position for base
        bit     7, a                    ; graphic character?
        ret     NZ                      ; yes, return (can't move left)
        exx     
        ld      hl, #video_ram+0x380    ; base row
        call    move_video_line_left_HL
        ld      hl, (base_centre)
        dec     hl                      ; move player left
        ld      (base_centre), hl
        jr      loc_0_48A6
; End of function check_and_handle_move


; --------------- S U B R O U T I N E ---------------------------------------


check_and_start_ufo:
        ld      a, (ufo_timer)
        inc     a                       ; increment_timer
        ld      (ufo_timer), a
        ret     NZ                      ; not time for ufo yet
        ld      a, (invaders_left)
        cp      #8                      ; less than 8 invaders remaining?
        ret     C                       ; yes, return
        ld      a, (ufo_active)
        or      a                       ; on-screen?
        ret     NZ                      ; yes, return
        exx     
        ld      a, #65
        ld      (ufo_TTL), a
        ld      a, (ufo_dir)
        or      a                       ; left?
        jr      Z, loc_0_48E3           ; yes, skip
        ld      hl, #video_ram          ; start on left
        jr      loc_0_48E6
; ---------------------------------------------------------------------------

loc_0_48E3:                             ; start on right
        ld      hl, #video_ram+0x3A

loc_0_48E6:                             ; update cursor position
        ld      (cursor), hl
        ld      hl, #ufo
        call    display_message
        ld      a, #1                   ; flag on-screen
        ld      (ufo_active), a
        exx     
        ret     
; End of function check_and_start_ufo


; --------------- S U B R O U T I N E ---------------------------------------


update_ufo:
        ld      a, (ufo_active)
        or      a                       ; ufo on-screen?
        ret     Z                       ; no, return
        exx     
        ld      hl, #video_ram
        ld      b, #63                  ; characters/line-1

loc_0_4901:                             ; get character from video
        ld      a, (hl)
        cp      #0xBB ; '»'
        jr      Z, loc_0_490F           ; yes, alternate
        cp      #0xB7 ; '·'
        jr      Z, loc_0_4913

loc_0_490A:                             ; next video address
        inc     hl
        djnz    loc_0_4901              ; loop thru line
        jr      move_ufo
; ---------------------------------------------------------------------------

loc_0_490F:                             ; display
        ld      (hl), #0xB7 ; '·'
        jr      loc_0_490A
; ---------------------------------------------------------------------------

loc_0_4913:                             ; display
        ld      (hl), #0xBB ; '»'
        jr      loc_0_490A
; ---------------------------------------------------------------------------

move_ufo:
        ld      a, (ufo_dir)
        or      a                       ; left?
        jr      Z, move_ufo_left        ; yes, skip
        ld      hl, #video_ram
        call    move_video_line_right_HL
        jr      ufo_TTL_tick
; ---------------------------------------------------------------------------

move_ufo_left:
        ld      hl, #video_ram
        call    move_video_line_left_HL

ufo_TTL_tick:
        ld      a, (ufo_TTL)
        dec     a                       ; ufo still active?
        ld      (ufo_TTL), a
        jr      Z, flag_ufo_inactive    ; no, skip

loc_0_4934:
        exx     
        ret     
; ---------------------------------------------------------------------------

flag_ufo_inactive:                      ; flag ufo inactive
        xor     a
        ld      (ufo_active), a
        jr      loc_0_4934
; End of function update_ufo

; ---------------------------------------------------------------------------

game_over:
        ld      sp, #stack
        ld      hl, #video_ram+0x19     ; cursor position
        ld      (cursor), hl
        ld      hl, #video_ram          ; start of video
        call    clear_video_line_HL
        ld      hl, #aGAMEOVER          ; "G A M E - O V E R"
        call    display_message_slowly
        call    check_for_new_high_score
        ld      bc, #65535              ; ~1s
        call    delay                   ; delay
        call    delay                   ; delay
        call    delay                   ; delay
        jp      attract_loop

; --------------- S U B R O U T I N E ---------------------------------------


display_invader_row:
        push    hl
        push    de
        push    bc
        ld      b, #10                  ; 10 invaders/row
        push    de
        ld      de, #64
        sbc     hl, de                  ; line above
        pop     de
        inc     hl

loc_0_4970:                             ; cursor position
        ld      (cursor), hl
        push    de
        push    hl
        ex      de, hl
        call    display_message
        pop     hl
        ld      de, #6                  ; offset to next invader
        add     hl, de                  ; update video address
        pop     de
        djnz    loc_0_4970              ; loop thru 10 invaders
        pop     bc
        pop     de
        pop     hl
        ret     
; End of function display_invader_row


; --------------- S U B R O U T I N E ---------------------------------------


update_invader_row_addresses:
        push    hl
        push    de
        push    bc
        ld      hl, (row_1_invader_addr)
        call    find_1st_invader_on_row
        ld      (row_1_invader_addr), hl
        ld      hl, (row_2_invader_addr)
        call    find_1st_invader_on_row
        ld      (row_2_invader_addr), hl
        ld      hl, (row_3_invader_addr)
        call    find_1st_invader_on_row
        ld      (row_3_invader_addr), hl
        ld      hl, (row_4_invader_addr)
        call    find_1st_invader_on_row
        ld      (row_4_invader_addr), hl
        pop     bc
        pop     de
        pop     hl
        ret     
; End of function update_invader_row_addresses


; --------------- S U B R O U T I N E ---------------------------------------


find_1st_invader_on_row:
        push    hl                      ; invader row address
        ld      b, #63                  ; characters/line-1

loc_0_49B3:                             ; get character from video
        ld      a, (hl)
        bit     7, a                    ; graphic?
        inc     hl                      ; next video address
        jr      NZ, loc_0_49BF          ; yes, skip
        djnz    loc_0_49B3              ; find 1st invader on row
        pop     hl
        ld      h, #0                   ; flag no invaders on row
        ret     
; ---------------------------------------------------------------------------

loc_0_49BF:                             ; invader row address
        pop     hl
        add     hl, de                  ; ???
        ret     
; End of function find_1st_invader_on_row

; ---------------------------------------------------------------------------

start_game:
        xor     a
        ld      (ufo_timer), a
        ld      (unused_4315), a
        ld      (unused_4312), a
        ld      (ufo_dir), a
        ld      (wave_no), a
        ld      (ufo_active), a
        ld      (bullet_active), a
        ld      (keybd_state), a
        inc     a
        ld      (invader_dir), a
        ld      a, #5
        ld      (ufo_timer), a
        ld      a, #3
        ld      (no_lives), a
        call    display_lives_left
        ld      sp, #stack
        call    zero_score
        call    display_GOOD_LUCK

new_wave:
        ld      sp, #stack
        xor     a
        ld      (bullet_active), a      ; clear fired flag
        ld      a, (wave_no)
        inc     a                       ; next wave number
        cp      #7                      ; highest?
        jr      NZ, loc_0_4A06          ; no, skip
        ld      a, #1                   ; reset to 1

loc_0_4A06:
        ld      (wave_no), a
        and     #6                      ; 2/4/6
        ld      de, #0x40 ; '@'         ; characters/line
        ld      h, d
        ld      l, e                    ; hl=0x0040
        ld      b, #1
        cp      #2                      ; compare wave_no with 2
        jr      C, loc_0_4A1C           ; wave_no=1, skip
        jr      Z, loc_0_4A1A           ; wave_no=2, skip
        inc     b
        add     hl, de

loc_0_4A1A:
        inc     b
        add     hl, de

loc_0_4A1C:
        ex      de, hl

calc_invader_row_addr:
        push    bc
        ld      ix, #init_row_1_invader_addr
        ld      iy, #row_1_invader_addr
        ld      b, #4                   ; 4 rows of invaders

loc_0_4A28:
        ld      l, 0(ix)
        ld      h, 1(ix)
        add     hl, de                  ; calc video address for invader row
        ld      0(iy), l
        ld      1(iy), h                ; store
        inc     ix
        inc     ix                      ; next row address
        inc     iy
        inc     iy
        djnz    loc_0_4A28              ; loop thru all rows of invaders
        pop     bc
        djnz    calc_invader_row_addr
        call    wipe_screen_left_to_right_slow
        ld      hl, #video_ram+0x309    ; cursor position
        ld      (cursor), hl
        ld      hl, #shield             ; shield #1
        push    hl
        call    display_message
        ld      hl, #video_ram+0x317    ; cursor position
        ld      (cursor), hl
        pop     hl
        push    hl                      ; shield #2
        call    display_message
        ld      hl, #video_ram+0x324    ; cursor position
        ld      (cursor), hl
        pop     hl
        push    hl                      ; shield #3
        call    display_message
        ld      hl, #video_ram+0x331    ; cursor position
        ld      (cursor), hl
        pop     hl                      ; shield #4
        call    display_message
        ld      de, #invader_30pt
        ld      hl, (row_1_invader_addr)
        call    display_invader_row     ; display 1st row of invaders
        ld      de, #invader_20pt
        ld      hl, (row_2_invader_addr)
        call    display_invader_row     ; display 2nd row of invaders
        ld      de, #invader_10pt
        ld      hl, (row_3_invader_addr)
        call    display_invader_row     ; display 3rd row of invaders
        ld      hl, (row_4_invader_addr)
        call    display_invader_row     ; display 4th row of invaders
        ld      a, #40                  ; number of invaders left
        ld      (invaders_left), a
        ld      (invader_timer), a

init_and_display_player_base:           ; cursor position
        ld      hl, #video_ram+0x384
        ld      (cursor), hl
        ld      hl, #player
        call    display_message         ; draw player base
        ld      hl, #video_ram+0x386
        ld      (base_centre), hl       ; center of base
        jp      init_turn
; ---------------------------------------------------------------------------

decrement_player_life:
        ld      a, (no_lives)
        dec     a                       ; any lives left?
        jp      Z, game_over            ; no, exit
        ld      (no_lives), a
        call    display_lives_left
        xor     a
        ld      (bullet_active), a      ; clear fired flag
        ld      (unused_4312), a
        call    restore_space_characters
        ld      hl, #video_ram+0x380
        call    clear_video_line_HL
        ld      bc, #65535              ; ~1s
        call    delay                   ; delay
        call    delay                   ; delay
        ld      sp, #stack
        jp      init_and_display_player_base

; --------------- S U B R O U T I N E ---------------------------------------


invert_display:
        ld      hl, #video_ram
        ld      bc, #0x400              ; video ram size

loc_0_4AE2:                             ; get character
        ld      a, (hl)
        cp      #0x20 ; ' '             ; space?
        jr      NZ, loc_0_4AE9          ; no, skip
        ld      (hl), #0x80 ; '€'       ; graphic space

loc_0_4AE9:                             ; graphics character?
        bit     7, (hl)
        jr      Z, loc_0_4AF4           ; no, skip
        ld      a, (hl)                 ; get character
        cpl                             ; invert
        set     7, a                    ; make graphics character
        res     6, a                    ; 1st block of graphics characters
        ld      (hl), a                 ; display

loc_0_4AF4:                             ; next video address
        inc     hl
        dec     bc
        ld      a, b
        or      c
        jr      NZ, loc_0_4AE2          ; loop through screen
        ret     
; End of function invert_display


; --------------- S U B R O U T I N E ---------------------------------------


get_player_address:
        ld      hl, (base_centre)
        dec     hl
        dec     hl
        ret     
; End of function get_player_address


; --------------- S U B R O U T I N E ---------------------------------------


animate_base_hit:
        ld      a, #0xA6 ; '¦'          ; hash graphic
        ld      b, #0                   ; 256 times

loc_0_4B05:
        push    bc
        push    hl                      ; player base address
        ld      b, #5                   ; 5 chars to display
        xor     #0x3F ; '?'             ; invert hash

loc_0_4B0B:                             ; display hash
        ld      (hl), a
        inc     hl                      ; next video address
        djnz    loc_0_4B0B              ; loop through 5 chars

loc_0_4B0F:
        ex      (sp), hl
        ex      (sp), hl
        ex      (sp), hl
        ex      (sp), hl                ; delay
        djnz    loc_0_4B0F              ; loop 256 times
        pop     hl
        pop     bc
        djnz    loc_0_4B05              ; loop 256 times
        ret     
; End of function animate_base_hit


; --------------- S U B R O U T I N E ---------------------------------------


animate_player_hit:
        call    get_player_address
        push    hl
        call    invert_display
        pop     hl
        call    animate_base_hit
        jr      invert_display
; End of function animate_player_hit

; ---------------------------------------------------------------------------

handle_base_hit:
        call    animate_player_hit
        jp      decrement_player_life
; ---------------------------------------------------------------------------

flash_screen_10_times:                  ; 10 times
        ld      b, #10

flash_screen:
        push    bc
        call    invert_display
        ld      bc, #10000              ; ~140ms
        call    delay                   ; delay
        call    invert_display
        ld      bc, #10000              ; ~140ms
        call    delay                   ; delay
        pop     bc
        djnz    flash_screen            ; repeat
        jp      game_over

; --------------- S U B R O U T I N E ---------------------------------------


animate_and_move_invaders:
        push    hl
        push    de
        push    bc
        ld      a, (invader_dir)
        or      a                       ; left?
        jr      Z, animate_and_move_invaders_left ; yes, skip
        ld      hl, #video_ram+0x7F     ; end of 2nd line on screen
        call    check_for_graphic_in_column
        or      a                       ; invaders reached RHS of screen?
        jp      Z, set_invader_dir_left ; yes, skip
        ld      hl, (row_4_invader_addr)
        call    move_invader_row_right
        ld      hl, (row_3_invader_addr)
        call    move_invader_row_right
        ld      hl, (row_2_invader_addr)
        call    move_invader_row_right
        ld      hl, (row_1_invader_addr)
        call    move_invader_row_right
        call    animate_invaders

move_invaders_down_ret:
        pop     bc
        pop     de
        pop     hl
        ret     
; End of function animate_and_move_invaders


; --------------- S U B R O U T I N E ---------------------------------------


move_invader_row_right:
        ld      a, h
        or      a                       ; any invaders left on this row?
        ret     Z                       ; no, return
        call    move_video_line_right_HL
        ld      de, #64                 ; characters/line
        sbc     hl, de                  ; line above
        jp      move_video_line_right_HL
; End of function move_invader_row_right

; ---------------------------------------------------------------------------

animate_and_move_invaders_left:         ; start of 2nd line
        ld      hl, #video_ram+0x40
        call    check_for_graphic_in_column
        or      a                       ; inavders reached LHS of screen?
        jr      Z, move_invaders_down   ; yes, skip
        call    animate_invaders

move_invaders_left:
        ld      hl, (row_4_invader_addr)
        call    move_invader_row_left
        ld      hl, (row_3_invader_addr)
        call    move_invader_row_left
        ld      hl, (row_2_invader_addr)
        call    move_invader_row_left
        ld      hl, (row_1_invader_addr)
        call    move_invader_row_left
        jr      move_invaders_down_ret

; --------------- S U B R O U T I N E ---------------------------------------


move_invader_row_left:
        ld      a, h
        or      a                       ; any invaders left on row?
        ret     Z                       ; no, return
        push    hl
        call    move_video_line_left_HL
        pop     hl
        ld      de, #64                 ; characters/line
        sbc     hl, de                  ; line above
        jp      move_video_line_left_HL
; End of function move_invader_row_left

; ---------------------------------------------------------------------------

set_invader_dir_left:
        ld      a, (invader_dir)
        xor     #1                      ; toggle invader direction
        ld      (invader_dir), a
        jp      move_invaders_left
; ---------------------------------------------------------------------------

move_invaders_down:
        ld      a, (bullet_active)
        or      a                       ; fired?
        jr      Z, loc_0_4BD4           ; no, skip
        ld      hl, (bullet_addr)
        ld      (hl), #0x20 ; ' '       ; display space

loc_0_4BD4:
        ld      ix, #row_4_invader_addr
        ld      b, #4                   ; 4 rows to check

loc_0_4BDA:
        ld      l, 0(ix)
        ld      h, 1(ix)                ; hl = invader addr
        ld      a, h
        or      a                       ; any invaders left on this line?
        call    NZ, move_invader_row_down ; yes, call
        dec     ix
        dec     ix                      ; next invader row address
        djnz    loc_0_4BDA              ; loop thru 4 rows of invaders
        ld      ix, #row_4_invader_addr
        ld      b, #4                   ; 4 rows of invaders
        ld      de, #video_ram+0x380    ; 2nd last line on screen

loc_0_4BF4:
        ld      l, 0(ix)
        ld      h, 1(ix)                ; HL = invader row addr
        call    get_video_line_below_invaders
        call    compare_video_addresses
        cp      #0x20 ; ' '             ; invaded?
        jp      Z, flash_screen_10_times ; yes, exit
        ld      0(ix), l
        ld      1(ix), h                ; update invader row address
        dec     ix
        dec     ix                      ; row above
        djnz    loc_0_4BF4              ; loop thru 4 rows of invaders
        ld      a, (invader_dir)
        xor     #1                      ; toggler invader direction (=right)
        ld      (invader_dir), a
        ld      a, (bullet_active)
        or      a                       ; fired?
        jp      Z, move_invaders_down_ret ; no, skip
        ld      hl, (bullet_addr)
        ld      a, (hl)                 ; get character from video
        cp      #0x20 ; ' '             ; space?
        jp      NZ, move_invaders_down_ret ; no, skip
        ld      (hl), #0x5B ; '['       ; display player bullet
        jp      move_invaders_down_ret

; --------------- S U B R O U T I N E ---------------------------------------


move_invader_row_down:
        push    bc
        push    hl                      ; invader row address
        ld      de, #63                 ; characters/line
        add     hl, de                  ; next line down, 1 character left
        push    hl
        inc     de                      ; 64
        add     hl, de                  ; next line down again
        ex      de, hl                  ; DE = 2 lines below, 1 character left
        pop     hl                      ; invader row+1 address
        ld      b, #128                 ; 2 video lines

loc_0_4C3B:                             ; get character from video
        ld      a, (de)
        cp      #0x80 ; '€'             ; graphic?
        ld      a, (hl)                 ; get character from invader row
        jr      NC, loc_0_4C45          ; yes, ok to overwrite
        cp      #0x80 ; '€'             ; invader a graphic?
        jr      C, loc_0_4C46           ; no, skip

loc_0_4C45:                             ; move character
        ld      (de), a

loc_0_4C46:
        dec     de
        dec     hl
        djnz    loc_0_4C3B              ; loop thru 2 lines
        pop     hl
        ld      de, #64                 ; characters/line
        sbc     hl, de                  ; line above
        call    clear_video_line_HL
        pop     bc
        ret     
; End of function move_invader_row_down


; --------------- S U B R O U T I N E ---------------------------------------


get_video_line_below_invaders:
        ld      a, h
        or      a                       ; any invaders left in row?
        ret     Z                       ; no, return
        push    de
        ld      de, #64                 ; characters/line
        add     hl, de                  ; next line
        pop     de
        ret     
; End of function get_video_line_below_invaders


; --------------- S U B R O U T I N E ---------------------------------------


check_for_new_high_score:
        ld      hl, #video_ram+0x3C9    ; score
        ld      de, #video_ram+0x3FA    ; high score
        ld      b, #4                   ; 4 digits to compare

loc_0_4C67:                             ; get score digit
        ld      c, (hl)
        ld      a, (de)                 ; get high score digit
        cp      c                       ; score higher?
        jr      C, update_high_score    ; yes, skip
        ret     NZ                      ; done if not the same
        inc     hl
        inc     de                      ; next digits
        djnz    loc_0_4C67              ; loop through all digits
        ret     
; ---------------------------------------------------------------------------

update_high_score:                      ; source = score
        ld      hl, #video_ram+0x3C9
        ld      de, #video_ram+0x3FA    ; destination = high score
        ld      bc, #5                  ; 5 digits to copy
        ldir                            ; copy
        ret     
; End of function check_for_new_high_score


; --------------- S U B R O U T I N E ---------------------------------------


clear_video_line_HL:
        push    bc
        push    de
        ld      b, #64                  ; characters/line

loc_0_4C82:                             ; display space
        ld      (hl), #0x20 ; ' '
        inc     hl                      ; next video address
        djnz    loc_0_4C82              ; clear a line
        pop     de
        pop     bc
        ret     
; End of function clear_video_line_HL


; --------------- S U B R O U T I N E ---------------------------------------


handle_drop_new_bomb:
        exx     
        ld      b, #4                   ; number of invader rows
        ld      ix, #row_4_invader_addr

loc_0_4C91:
        ld      a, 1(ix)
        or      a                       ; any invaders left on this row?
        jr      NZ, check_and_handle_new_bomb ; yes, continue
        dec     ix
        dec     ix                      ; next row above
        djnz    loc_0_4C91              ; loop thru all rows

init_bomb_ret:
        exx     
        ret     
; ---------------------------------------------------------------------------

check_and_handle_new_bomb:
        ld      hl, (base_centre)
        ld			de, #(0xfc80-video_ram)	; 0xC080/0x0C80
        add     hl, de                  ; base X position
        ex      de, hl                  ; base X position
        ld      l, 0(ix)
        ld      h, 1(ix)                ; invader row address
        push    hl
        ld      hl, #3                  ; RAND(1-3)
        call    rand
        ld      a, l                    ; get result
        pop     hl                      ; invader row address
        cp      #1                      ; drop a bomb near the base?
        jr      NZ, random_bomb_x_position ; no, random

loc_0_4CBA:                             ; calc bomb X position
        add     hl, de
        ld      de, #0xFF80             ; offset of 2 video lines above

loc_0_4CBE:                             ; invader above bomb position?
        bit     7, (hl)
        jr      NZ, init_new_bomb       ; yes, continue
        add     hl, de                  ; 2 lines above
        djnz    loc_0_4CBE              ; find invader above
        jr      init_bomb_ret           ; no invaders, no bomb
; ---------------------------------------------------------------------------

init_new_bomb:
        ld      ix, #bomb_tbl
        ld      b, #4

find_free_bomb_entry:
        ld      a, 1(ix)
        or      a                       ; bomb active?
        jr      Z, loc_0_4CDB           ; no, continue
        call    add_3_to_ix             ; next table location
        djnz    find_free_bomb_entry
        jp      init_bomb_ret           ; no free entries, return
; ---------------------------------------------------------------------------

loc_0_4CDB:
        call    get_invader_address
        ld      de, #0x82 ; '‚'         ; 2 lines below and 2 chars right
        add     hl, de                  ; centre under invader
        push    hl
        ld      hl, #3                  ; rand(1-3)
        call    rand
        ld      de, #base_icon+3        ; bomb_characters
        add     hl, de                  ; get random character
        pop     de                      ; centre under invader
        bit     7, e
        jr      Z, check_new_bomb_shield

init_bomb_entry:                        ; get character from video
        ld      a, (de)
        cp      #0x20 ; ' '             ; space?
        jr      NZ, init_bomb_ret       ; no, exit
        ld      a, (hl)                 ; get bomb character from table
        ld      (de), a                 ; display
        ld      0(ix), e
        ld      1(ix), d                ; store bomb address
        ld      2(ix), a                ; store bomb character
        jp      init_bomb_ret
; ---------------------------------------------------------------------------

random_bomb_x_position:
        push    hl
        ld      hl, #64                 ; RAND(1-64)
        call    rand
        ex      de, hl                  ; DE = result
        pop     hl
        jr      loc_0_4CBA
; ---------------------------------------------------------------------------

check_new_bomb_shield:                  ; HL = centre under invader
        ex      de, hl
        bit     7, (hl)                 ; graphic character?
        ex      de, hl
        jr      Z, init_bomb_entry      ; no, continue
        ex      de, hl
        push    hl
        exx     
        pop     hl
        jp      erode_shield_from_bomb
; End of function handle_drop_new_bomb


; --------------- S U B R O U T I N E ---------------------------------------

.ifndef	NO_ROM
rand:
        push    de
        push    bc
        call    0x14CC                  ; ROM RAND() function
        call    0xA7F                   ; transfer result to HL
        pop     bc
        pop     de
        ret     
; End of function rand
.endif


; --------------- S U B R O U T I N E ---------------------------------------


get_invader_address:
        push    de
        ld      a, (hl)                 ; character at video address
        and     #0x30 ; '0'             ; any pixels on bottom row of cell?
        ld      de, #0xFFC0             ; offset of line above
        jr      NZ, loc_0_4D32          ; yes, skip (top half of invader)
        add     hl, de                  ; line above (top half of invader)

loc_0_4D32:                             ; graphic character?
        bit     7, (hl)
        dec     hl                      ; previous video address
        jr      NZ, loc_0_4D32          ; loop until non-graphic
        inc     hl
        inc     hl                      ; 2nd character of invader
        pop     de
        ret     
; End of function get_invader_address


; --------------- S U B R O U T I N E ---------------------------------------


restore_space_characters:
        ld      hl, #video_ram
        ld      bc, #0x3C0              ; 15 lines (all but last)

loc_0_4D41:                             ; graphics character?
        bit     7, (hl)
        jr      Z, loc_0_4D4A           ; no, skip
        ld      a, (hl)                 ; get character
        cp      #0x80 ; '€'             ; graphic space character?
        jr      NZ, loc_0_4D4C          ; no, skip

loc_0_4D4A:                             ; convert to space character
        ld      (hl), #0x20 ; ' '

loc_0_4D4C:                             ; next video address
        inc     hl
        dec     bc
        ld      a, b
        or      c                       ; done?
        ret     Z                       ; yes, return
        jr      loc_0_4D41              ; loop through 15 lines
; End of function restore_space_characters


; --------------- S U B R O U T I N E ---------------------------------------


delete_bomb:
        xor     a                       ; zero bomb address
        ld      1(ix), a

dec_bomb_count:
        ld      a, (unused_4312)
        dec     a                       ; probably supposed to be bomb count
        ld      (unused_4312), a
        ret     
; End of function delete_bomb


; --------------- S U B R O U T I N E ---------------------------------------


update_bombs:
        exx     
        ld      ix, #bomb_tbl
        ld      b, #4                   ; max 4 bombs

loc_0_4D66:
        ld      a, 1(ix)
        or      a                       ; valid address?
        jr      NZ, check_and_update_bomb ; yes, skip

next_bomb:                              ; next bomb entry
        call    add_3_to_ix
        djnz    loc_0_4D66              ; loop thru all bombs
        exx     
        ret     
; ---------------------------------------------------------------------------

check_and_update_bomb:
        ld      l, 0(ix)
        ld      h, 1(ix)                ; bomb address
        ld      a, 2(ix)                ; bomb character
        cp      (hl)                    ; same character?
        jr      Z, update_bomb          ; yes, continue
        call    delete_bomb
        jr      next_bomb
; ---------------------------------------------------------------------------

update_bomb:                            ; display space
        ld      (hl), #0x20 ; ' '
        ld      de, #64                 ; characters/line
        add     hl, de                  ; next line down
        ld      0(ix), l
        ld      1(ix), h                ; update bomb address
        push    hl
        ld      de, #video_ram+0x3C0    ; bottom line of video
        call    compare_video_addresses
        or      a                       ; reached bottom of screen?
        push    af
        jr      NZ, delete_bomb_and_loop ; yes, delete bomb
        pop     af
        pop     hl                      ; bomb address
        ld      a, (hl)                 ; get character from video
        cp      #0x5B ; '['             ; player bullet?
        jr      Z, handle_bullet_hit_bomb ; yes, skip
        cp      #0x81 ; ''             ; graphic (non-blank)?
        jr      NC, check_and_handle_bomb_hit ; yes, skip
        ld      a, 2(ix)                ; bomb character
        ld      (hl), a                 ; display
        jr      next_bomb
; ---------------------------------------------------------------------------

handle_bullet_hit_bomb:
        push    hl
        push    af
        ld      hl, #3
        call    rand
        ld      a, l
        cp      #2
        jr      C, delete_bomb_and_loop
        jr      NZ, handle_bomb_destroys_bullet
        xor     a
        ld      (bullet_active), a
        call    delete_bomb             ; both destroyed
        pop     af
        pop     hl
        ld      (hl), #0x20 ; ' '
        jr      next_bomb
; ---------------------------------------------------------------------------

delete_bomb_and_loop:
        call    delete_bomb
        pop     af
        pop     hl
        jr      next_bomb
; ---------------------------------------------------------------------------

handle_bomb_destroys_bullet:
        xor     a
        ld      (bullet_active), a      ; flag inactive
        pop     af
        pop     hl
        ld      a, 2(ix)                ; bomb character
        ld      (hl), a                 ; display
        jr      next_bomb
; ---------------------------------------------------------------------------

check_and_handle_bomb_hit:
        ex      de, hl
        call    find_end_of_lowest_invader_row
        call    compare_video_addresses
        ex      de, hl
        push    hl
        push    af
        cp      #0xFF
        jr      Z, delete_bomb_and_loop
        pop     af
        pop     hl
        ld      de, #video_ram+0x380    ; 2nd bottom row
        call    compare_video_addresses
        or      a                       ; possible shield hit?
        jp      NZ, handle_base_hit     ; no, must be player base
        call    erode_shield_from_bomb
        push    hl
        push    af
        jr      delete_bomb_and_loop
; End of function update_bombs


; --------------- S U B R O U T I N E ---------------------------------------


zero_bullet_tbl:
        ld      hl, #bomb_tbl
        ld      de, #bomb_tbl+1
        ld      bc, #0xC
        ld      (hl), #0
        ldir    
        ret     
; End of function zero_bullet_tbl


; --------------- S U B R O U T I N E ---------------------------------------


handle_bullet_destroys_bomb:
        push    hl
        exx     
        pop     de
        ld      ix, #bomb_tbl
        ld      b, #4                   ; max bombs

loc_0_4E13:
        ld      l, 0(ix)
        ld      h, 1(ix)                ; bomb address
        call    compare_video_addresses
        cp      #0x20 ; ' '             ; hit?
        jp      Z, loc_0_4E26           ; yes, skip
        call    add_3_to_ix             ; next bullet data
        djnz    loc_0_4E13              ; loop thru all bullets

loc_0_4E26:
        exx     
        jp      delete_bomb             ; returns
; End of function handle_bullet_destroys_bomb


; --------------- S U B R O U T I N E ---------------------------------------


add_3_to_ix:
        inc     ix
        inc     ix
        inc     ix
        ret     
; End of function add_3_to_ix


; --------------- S U B R O U T I N E ---------------------------------------


display_GOOD_LUCK:
        call    wipe_screen_left_to_right_slow
        ld      hl, #video_ram+0x219    ; cursor position
        ld      b, #50                  ; flash 50 times

loc_0_4E39:
        push    bc
        ld      (cursor), hl            ; current cursor position
        push    hl
        ld      hl, #aGoodLuck          ; "GOOD LUCK"
        call    display_message
        call    delay_15ms
        pop     hl                      ; cursor position
        ld      (cursor), hl
        push    hl
        ld      hl, #blank_x9
        call    display_message
        call    delay_15ms
        pop     hl
        pop     bc
        djnz    loc_0_4E39              ; loop though all flashes
        ret     
; End of function display_GOOD_LUCK


; --------------- S U B R O U T I N E ---------------------------------------


delay_15ms:
        ld      bc, #1000               ; ~15ms
        jp      delay                   ; delay
; End of function delay_15ms


; --------------- S U B R O U T I N E ---------------------------------------


delay_1_5ms:
        ld      bc, #100                ; ~1.5ms
        jp      delay                   ; delay
; End of function delay_1_5ms


; --------------- S U B R O U T I N E ---------------------------------------


print_slow_and_check_for_R_key:
        push    hl                      ; ptr message
        pop     ix

loc_0_4E69:                             ; get character
        ld      a, 0(ix)
        or      a                       ; done?
        ret     Z                       ; yes, exit
        cp      #9                      ; cursor position embedded?
        jr      NZ, loc_0_4E80          ; no, skip
        ld      l, 1(ix)
        ld      h, 2(ix)                ; cursor position
        ld      (cursor), hl            ; set ROM variable
        call    add_3_to_ix
        jr      loc_0_4E69              ; next character
; ---------------------------------------------------------------------------

loc_0_4E80:                             ; display character
        call    putc
        ld      bc, #1280               ; ~20ms
        call    delay                   ; delay
        call    check_for_R_key
        inc     ix                      ; next character
        jr      loc_0_4E69              ; loop
; End of function print_slow_and_check_for_R_key


; --------------- S U B R O U T I N E ---------------------------------------


display_lives_left:
        push    hl
        push    de
        push    bc
        push    af
        ld      hl, (cursor)            ; current cursor position
        push    hl
        ld      hl, #video_ram+0x3D0    ; cursor position
        ld      (cursor), hl
        ld      a, (no_lives)
        dec     a                       ; any lives left?
        jr      Z, wipe_all_ship_icons
        ld      b, a                    ; number of lives

loc_0_4EA5:
        ld      hl, #base_icon
        call    display_message
        djnz    loc_0_4EA5              ; loop thru all icons
        ld      a, (no_lives)
        ld      b, a
        ld      a, #4
        sub     b                       ; no. icons to wipe
        jr      Z, loc_0_4EC2           ; none, skip
        jr      wipe_ship_icons
; ---------------------------------------------------------------------------

wipe_all_ship_icons:                    ; max 3 ship icons
        ld      b, #3

wipe_ship_icons:
        ld      hl, #blank_x3
        call    display_message
        djnz    wipe_ship_icons

loc_0_4EC2:
        pop     hl
        ld      (cursor), hl            ; restore cursor position
        pop     af
        pop     bc
        pop     de
        pop     hl
        ret     
; End of function display_lives_left

; ---------------------------------------------------------------------------
blank_x3:.db 0x20, 0x20, 0x20, 0
base_icon:.db 0x88, 0x8E, 0x8C, 0
bomb_characters:.db 0x5C ; \            ; bomb characters
        .db 0x56 ; V
        .db 0x2A ; *
aGoodLuck:.ascii 'GOOD LUCK'
        .db 0
blank_x9:.db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0
bomb_tbl:.db 0xD1, 0x3E, 0x56
        .db 0xDF, 0, 0x56
        .db 0x92, 0x3F, 0x56
        .db 0, 0, 0
        .db    0 ;  
        .db    0 ;  
        .db    0 ;  
        .db    0 ;  
        .db    0 ;  
; ---------------------------------------------------------------------------

init_turn:
        call    zero_bullet_tbl
        xor     a
        ld      (unused_4312), a
        ld      (game_timer), a

game_loop:                              ; read keyboard
.ifdef TRS80
        ld      a, (0x3840)
.endif
.ifdef MICROBEE
				ld			a, #55									; space
				call		testky
				ld			a, #0x80
				jr			z, 1$										; space hit
				xor			a												; not
1$:				
.endif        
        ld      d, a
        ld      bc, #0x200              ; ~7.5ms
        call    delay                   ; delay
.ifdef TRS80        
        ld      a, (0x3840)             ; read keyboard
.endif
.ifdef MICROBEE
				ld			a, #55									; space
				call		testky
				ld			a, #0x80
				jr			z, 2$										; space hit
				xor			a												; not
2$:				
.endif        
        xor     d
        and     #0x80 ; '€'             ; space - changed state?
        jr      NZ, loc_0_4F26          ; yes, skip
        ld      a, (keybd_state)        ; last read
        ld      e, a
        xor     d                       ; changed state?
        and     d                       ; pressed?
        and     #0x80 ; '€'             ; space only
        ld      a, d
        ld      (keybd_state), a        ; store keyboard state
        call    NZ, handle_fire         ; yes, call

loc_0_4F26:
        ld      a, (game_timer)
        and     #3                      ; time to move player?
        call    Z, check_and_handle_move ; yes, call
        ld      a, (bullet_active)
        or      a                       ; fired?
        jr      Z, loc_0_4F3C           ; no, skip
        ld      a, (game_timer)
        and     #3                      ; time to move bullet?
        call    Z, update_bullet        ; yes, call

loc_0_4F3C:
        ld      a, (game_timer)
        and     #7                      ; time to move UFO?
        call    Z, update_ufo           ; yes, call
        call    check_and_start_ufo
        ld      a, (ufo_active)
        or      a                       ; on-screen?
        jr      NZ, loc_0_4F5A          ; yes, skip
        ld      a, (ufo_timer)
        cp      #0x80 ; '€'             ; time to wipe bonus?
        jr      NZ, loc_0_4F5A          ; no, skip
        ld      hl, #video_ram
        call    clear_video_line_HL     ; wipe bonus

loc_0_4F5A:
        nop     
        ld      a, (game_timer)
        and     #0xF                    ; time to update bombs?
        push    af
        call    Z, update_bombs         ; yes, call
        pop     af
        call    Z, handle_drop_new_bomb
        ld      hl, #game_timer
        inc     (hl)                    ; increment game timer
        ld      a, (invader_timer)
        dec     a                       ; tick
        push    af                      ; time to move invaders?
        call    Z, animate_and_move_invaders ; yes, call
        pop     af
        push    af
        call    NZ, delay_1_5ms
        pop     af                      ; invader timer expired?
        jr      NZ, loc_0_4F82          ; no, skip
        ld      a, (invaders_left)
        add     a, a
        sub     #1                      ; calc new invader timer

loc_0_4F82:
        ld      (invader_timer), a
        ld      a, (bullet_active)
        or      a                       ; fired?
        jr      NZ, loc_0_4F95          ; yes, skip
        ld      a, (fire_throttle)
        or      a
        jr      Z, loc_0_4F95
        dec     a
        ld      (fire_throttle), a

loc_0_4F95:
.ifdef MICROBEE
; microbee runs faster
; - already adjusted the delay routine
; - but also need to throttle the main loop
; - 200 looks about right side-by-side
				ld			bc, #200
				call		delay
.endif
        jp      game_loop
; ---------------------------------------------------------------------------
aCopyrightC1979:.ascii 'COPYRIGHT (C) 1979, '
        .db 0xB0, 0x37, 0x2F, 0x31, 0x33, 0x42, 0x59, 0x20, 0x54, 0x52
        .db 0x53, 0x2D, 0x42, 0x4D, 0x20, 0x4B, 0x4F, 0x47, 0x41, 0x4E
        .db 0x45, 0x49, 0, 0x81, 0x5F, 0x7A, 0xFE, 0x30, 0x28, 2, 0x77
        .db 0x23, 0x7B, 0xE, 0xA, 0x10, 0xEC, 0xC6, 0x30, 0x77, 0x23, 0x36
        .db 3, 0xE1, 6, 0x20, 0x3E, 0, 0x3D, 0x20, 4, 0x77, 0x23, 0x10
        .db 0xFC, 0xAF, 0xC9, 0x3A, 0xC4, 0x4E, 0x6F, 0xCB, 0xA6, 0x5A
        .db 0x23, 0x56, 0xCD, 0x82, 0x4E, 0x7B, 0xF, 0xF, 0xF, 0xE6, 0x1F
        .db 0xC5, 0x21, 0xC0, 0x4D, 0x4F, 6, 0, 9, 0x7B

.ifdef NO_ROM

cursor:	.ds			2

putc:
;				jp			0x0033
; this is a bit quicker than the ROM routine
; which gets vectored via the driver mechanism
; and handles control codes and scrolling
; - only need to handle 0x08, 0x0F, 0x1A, 0x1B codes
				push		af
				push		hl
				push		de
				push		bc
				ld			hl,(cursor)
				cp			#0x08										; backspace?
				jr			z,1$										; yes, handle
				cp			#0x0f										; cursor off?
				jr			z,9$										; yes, nothing to do
				cp			#0x1a										; cursor down
				jr			z,2$										; yes, handle
				cp			#0x1b										; cursor up
				jr			z,8$										; yes, handle
				ld			(hl),a									; display character
				inc			hl											; advance cursor
				jr			7$
1$:			dec			hl
				ld			a,h
				and			#0x03
				or			#>video_ram							; 0x3C/0xF0
				ld			h,a
				ld			(hl),#0x20							; insert space
				jr			9$
2$:			ld			de,#0x0040
				add			hl,de										; next line down
7$:			ld			a,h
				cp			#>(video_ram+0x0400)		; 0x40/0xF0
				jr			nz,9$
8$:			ld			de,#0xffc0
				add			hl,de										; move up 1 line
9$:			ld			(cursor),hl							; update cursor
				pop			bc
				pop			de
				pop			hl
				pop			af
				ret

delay:
;				jp			0x0060
; this is an exact copy of the ROM routine
; each loop is approx. 14.66us on the 
; 1.77MHz TRS-80 Model I
.ifdef MICROBEE
; 1.5x the delay
				push		bc
				srl			b
				rr			c
				call		1$
				pop			bc
.endif
1$:			jp			2$
2$:			ld			a,a
				dec			bc
				ld			a,b
				or			c
				jr			nz,2$				
				ret

prtnum:
;				jp			0x0faf
; display integer in HL
; - values 50,100,150,200,250,300
; - (hex) $32,$64,$96,$C8,$FA,$12C
				push		de
				ld			de,#100
				xor			a												; zero 100 counter
1$:			sbc			hl,de
				jr			c,2$										; negative, done
				inc			a												; inc 100 counter
				jr			1$											; loop
2$:			add			hl,de										; restore HL
				or			a												; leading zero?
				jr			z,3$										; yes, no print
				add			#0x30										; convert to ASCII
				call		putc
3$:			ld			de,#10
				xor			a												; zero 10 counter
4$:			sbc			hl,de
				jr			c,5$										; negative, done
				inc			a												; in 10 counter
				jr			4$											; loop
5$:			add			hl,de										; restore HL
				add			#0x30										; convert to ASCII
				call		putc
				ld			a,l											; remainder
				add			#0x30										; convert to ASCII
				call		putc
				pop			de								
				ret

rand:
; integer range in HL
; returns result in HL
; - only need 8-bit for this program
; - hacky version, seems to run OK
1$:			ld			a,r											; pseudo-random value
2$:			cp			l												; outside range?
				jr			c,3$										; no, OK
				sub			l												; subtract range
				jr			2$											; test again
3$:			inc			a												; 1-based
				ld			h,0
				ld			l,a											; store in HL
				ret
												
.endif

.ifdef MICROBEE
testky:
; from Wildcards Vol.3
				push		bc
				ld			c,a											; save value of key being tested
				ld			b,a
				ld			a,#0x12
				out			(0x0c),a								; select update register (high) of 6845
				ld			a,b
				rrca
				rrca
				rrca
				rrca
				and			#0x03
				out			(0x0d),a								; set high address of key
				ld			a,#0x13
				out			(0x0c),a								; select update register (low) of 6845
				ld			a,b
				rlca
				rlca
				rlca
				rlca
				out			(0x0d),a								; select low address of key
				ld			a,#0x01
				out			(0x0b),a								; select ROM read latch on
				ld			a,#0x10
				out			(0x0c),a
				in			a,(0x0d)
				ld			a,#0x1f
				out			(0x0c),a
				out			(0x0d),a
wait1:	in			a,(0x0c)
				bit			7,a
				jr			z,wait1
				in			a,(0x0c)
				cpl
				bit			6,a
				ld			a,#0x00
				out			(0x0b),a								; select ROM read latch off
				ld			a,b											; restore original key code
				pop			bc					
				ret
.endif

stack		.equ		.+0x400

; end of 'code'

				.end		START
				
; end of file
