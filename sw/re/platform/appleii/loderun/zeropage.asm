; zero-page variables

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
