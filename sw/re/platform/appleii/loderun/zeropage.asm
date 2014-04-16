; zero-page variables

msg_addr:					; $10-$11
				.dw			0x0000									; for display_message
msg_char:					; $1E
				.db			0x00										; for display_message				
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
