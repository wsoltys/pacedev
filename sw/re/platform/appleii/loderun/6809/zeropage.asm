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
lsb_row_lda_dyn						.equ		0x07		; swapped for 6809
msb_row_lda_dyn						.equ		0x06		; swapped for 6809
lsb_row_lda_static				.equ		0x09		; swapped for 6809
msb_row_lda_static				.equ		0x08		; swapped for 6809
word_a										.equ		0x0a
lsb_line_addr_pg1					.equ		0x0d		; swapped for 6809
msb_line_addr_pg1					.equ		0x0c		; swapped for 6809
lsb_line_addr_pg2					.equ		0x0f		; swapped for 6809
msb_line_addr_pg2					.equ		0x0e		; swapped for 6809
msg_addr									.equ		0x10
curr_guard_col						.equ		0x12
curr_guard_row						.equ		0x13
curr_guard_sprite					.equ		0x14
curr_guard_dir						.equ		0x15
curr_guard_state					.equ		0x16
curr_guard_x_offset				.equ		0x17
curr_guard_y_offset				.equ		0x18
curr_guard								.equ		0x19
nibble_cnt								.equ		0x1a
scanline									.equ		0x1b
col_addr_offset						.equ		0x1c
scanline_cnt							.equ		0x1d
msg_char									.equ		0x1e
hires_page_msb_1					.equ		0x1f
lchar_mask								.equ		0x50
rchar_mask								.equ		0x51
collision_detect          .equ		0x52
guard_respawn_col					.equ		0x53
sndq_length               .equ		0x54
guard_ai_col							.equ		0x55
guard_ai_row							.equ		0x56
target_col								.equ		0x57
guard_ai_dir							.equ		0x58
guard_ai_best_delta				.equ		0x59
farthest_left							.equ		0x5a
farthest_right						.equ		0x5b
farthest_updown_plyr_row	.equ		0x5c
byte_5d										.equ		0x5d
byte_5e										.equ		0x5e
guard_trap_cnt_init				.equ		0x5f
byte_60										.equ		0x60
byte_61										.equ		0x61
byte_62										.equ		0x62
byte_63										.equ		0x63
byte_64										.equ		0x64
joy_x											.equ		0x65
joy_y											.equ		0x66
byte_69										.equ		0x69
byte_6d                   .equ    0x6d
col_pixel_shift						.equ		0x71
drawing                   .equ    0x72
r                         .equ    0x74	; 6809 only
y0                        .equ    0x76	; 6809 only
x0                        .equ    0x78	; 6809 only
x                         .equ    0x7a	; 6809 only
y                         .equ    0x7c	; 6809 only
re                        .equ    0x7e	; 6809 only
minus_x										.equ		0x80	; 6809 only
minus_y										.equ		0x82	; 6809 only
circle_mask								.equ		0x84	; 6809 only
col												.equ		0x85
row												.equ		0x86
display_char_page					.equ		0x87
curr_hole									.equ		0x88
hundreds									.equ		0x89
tens											.equ		0x8a
units											.equ		0x8b
game_speed								.equ		0x8c
no_guards									.equ		0x8d
score_1e1_1								.equ		0x8e
score_1e3_1e2							.equ		0x8f
score_1e5_1e4							.equ		0x90
score_1e6									.equ		0x91
packed_byte_cnt						.equ		0x92
no_gold										.equ		0x93
enable_collision_detect   .equ    0x94
paddles_detected					.equ		0x95
level_0_based							.equ		0x96
unused_97									.equ		0x97
no_lives									.equ		0x98
sound_enabled							.equ		0x99
level_active							.equ		0x9a
not_falling               .equ		0x9b
dig_dir										.equ		0x9c
no_cheat									.equ		0x9d
key_1											.equ		0x9e
key_2											.equ		0x9f
dig_sprite								.equ		0xa0
timer											.equ		0xa1
editor_n									.equ		0xa2
no_eos_ladder_tiles				.equ		0xa3
falling_snd_freq					.equ		0xa4
wipe_next_time            .equ		0xa5
level											.equ		0xa6
attract_mode							.equ		0xa7
lsb_demo_inp_ptr					.equ		0xa9		; swapped for 6809
msb_demo_inp_ptr					.equ		0xa8		; swapped for 6809
demo_inp_key_1_2					.equ		0xaa
demo_inp_cnt							.equ		0xab
demo_not_interrupted			.equ		0xac
game_over_loop_cnt				.equ		0xd6		; 6809 only
no_eos_ladder_entries			.equ		0xd7		; 6809 only
initial_cnt								.equ		0xd8		; 6809 only
blink_char								.equ		0xd9		; 6809 only
sound_cnt									.equ		0xda		; 6809 only
sound_bits								.equ		0xdb		; 6809 only
sound_setting							.equ		0xdc		; 6809 only
debug_page								.equ		0xdd		; 6809 only
zp_de											.equ		0xde		; (temp) added MMc
char_render_buf						.equ		#ZEROPAGE+0xdf
