; zero-page variables

msg_addr:					; $10-$11
				.dw			0x0000									; for display_message
scanline:					; $1B
				.db			0x00										; for display_char_pg1
col_addr_offset:	; $1C
				.db			0x00										; for display_char_pg1				
msg_char:					; $1E
				.db			0x00										; for display_message		
col_pixel_shift:	; $71
				.db			0x00										; for display_char_pg1						
col:							; $85
				.db			0x00										; for display_message
row:							; $86
				.db			0x00										; for display_message
paddles_detected: ; $95
				.db			0xca										; paddles detected?
no_lives:					; $98
				.db			0x00										; number of lives
byte_A7:					; $A7
				.db			0x00										; ???														
char_render_buf: 	; $DF
				.ds			33											; for render_char_in_buffer
