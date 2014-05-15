; zero-page variables

.ifdef TRS80
; because IX.IY displacements go negative
pad:									.ds			128
zero_page:						.ds			256
.endif

; offsets into zero-page
current_col								.equ		0x00
current_row								.equ		0x01
x_offset_within_tile			.equ		0x02
y_offset_within_tile			.equ		0x03
sprite_index							.equ		0x04
dir												.equ		0x05
lsb_row_level_data_addr		.equ		0x07		; swapped for 6809
msb_row_level_data_addr		.equ		0x06		; swapped for 6809
byte_8										.equ		0x09		; swapped for 6809
byte_9										.equ		0x08		; swapped for 6809
byte_a										.equ		0x0a
lsb_line_addr_pg1					.equ		0x0d		; swapped for 6809
msb_line_addr_pg1					.equ		0x0c		; swapped for 6809
lsb_line_addr_pg2					.equ		0x0f		; swapped for 6809
msb_line_addr_pg2					.equ		0x0e		; swapped for 6809
msg_addr									.equ		0x10
nibble_cnt								.equ		0x1a
scanline									.equ		0x1b
col_addr_offset						.equ		0x1c
scanline_cnt							.equ		0x1d
msg_char									.equ		0x1e
hires_page_msb_1					.equ		0x1f
lchar_mask								.equ		0x50
rchar_mask								.equ		0x51
byte_52										.equ		0x52
byte_55										.equ		0x55
byte_5c										.equ		0x5c
col_pixel_shift						.equ		0x71
col												.equ		0x85
row												.equ		0x86
display_char_page					.equ		0x87
byte_88										.equ		0x88
hundreds									.equ		0x89
tens											.equ		0x8a
units											.equ		0x8b
game_speed								.equ		0x8c
score_1e1_1								.equ		0x8e
score_1e3_1e2							.equ		0x8f
score_1e5_1e4							.equ		0x90
score_1e6									.equ		0x91
packed_byte_cnt						.equ		0x92
no_gold										.equ		0x93
paddles_detected					.equ		0x95
level_0_based							.equ		0x96
byte_9c										.equ		0x9c
no_lives									.equ		0x98
level_active							.equ		0x9a
unk_9b										.equ		0x9b
game_active								.equ		0x9d
key_1											.equ		0x9e
key_2											.equ		0x9f
dig_dir										.equ		0x9c
dig_sprite								.equ		0xa0
timer											.equ		0xa1
unk_a2										.equ		0xa2
no_eos_ladder_tiles				.equ		0xa3
level											.equ		0xa6
attract_mode							.equ		0xa7
byte_ac										.equ		0xac
char_render_buf_z					.equ		0xdf
zp_fe											.equ		0xfe
zp_ff											.equ		0xff

.if 0
msg_addr:					; $10-$11
				.dw			0x0000									; for display_message
scanline:					; $1B
				.db			0x00										; for display_char_pg1
col_addr_offset:	; $1C
				.db			0x00										; for display_char_pg1				
msg_char:					; $1E
				.db			0x00										; for display_message		
lchar_mask:				; $50
				.db			0x00										; for display_char_pg1				
rchar_mask:				; $51
				.db			0x00										; for display_char_pg1
col_pixel_shift:	; $71
				.db			0x00										; for display_char_pg1						
col:							; $85
				.db			0x00										; for display_message
row:							; $86
				.db			0x00										; for display_message
hundreds:					; $89
				.db			0x00										; temp
tens:							; $8A				
				.db			0x00										; temp
units:						; $8B
				.db			0x00										; temp
score_10_1:				; $8E
				.db			0x00
score_1000_100:		; $8F
				.db			0x00
score_100000_10000:	; $90
				.db			0x00
score_1000000:		; $91
				.db			0x00
paddles_detected: ; $95
				.db			0xca										; paddles detected?
no_lives:					; $98
				.db			0x00										; number of lives
level:						; $A6
				.db			0x00										; current level
byte_A7:					; $A7
				.db			0x00										; ???														
char_render_buf: 	; $DF
				.ds			33											; for render_char_in_buffer
.endif

