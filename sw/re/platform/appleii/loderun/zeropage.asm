; zero-page variables

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
