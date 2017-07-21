.export chr_tbl
.export ship_tbl
.export shifted_ship_tbl
.export extra_ship
.export large_ufo
.export small_ufo
.export shrapnel_tbl
.export asteroid_tbl
.export copyright

char_SPACE:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00

char_0:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00

char_1:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00

char_2:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00

char_3:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00

char_4:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00

char_5:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00

char_6:
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00

char_7:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00

char_8:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00

char_9:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00

char_A:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00

char_B:
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $00, $00
char_C:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
char_D:
    .BYTE  $FF, $F0, $00, $00
    .BYTE  $F0, $0F, $00, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $0F, $00, $00
    .BYTE  $FF, $F0, $00, $00
char_E:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
char_F:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
char_G:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
char_H:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
char_I:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $FF, $FF, $F0, $00
char_J:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $00, $FF, $F0, $00
char_K:
    .BYTE  $F0, $0F, $00, $00
    .BYTE  $F0, $F0, $00, $00
    .BYTE  $FF, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $00, $00, $00
    .BYTE  $F0, $F0, $00, $00
    .BYTE  $F0, $0F, $00, $00
char_L:
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
char_M:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $0F, $F0, $00
    .BYTE  $F0, $F0, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
char_N:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $00, $F0, $00
    .BYTE  $F0, $F0, $F0, $00
    .BYTE  $F0, $F0, $F0, $00
    .BYTE  $F0, $0F, $F0, $00
    .BYTE  $F0, $0F, $F0, $00
    .BYTE  $F0, $00, $F0, $00
char_O:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
char_P:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
char_Q:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $F0, $F0, $00
    .BYTE  $F0, $0F, $00, $00
    .BYTE  $FF, $F0, $F0, $00
char_R:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $F0, $00, $00
    .BYTE  $F0, $0F, $00, $00
    .BYTE  $F0, $00, $F0, $00
char_S:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
char_T:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
char_U:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $FF, $FF, $F0, $00
char_V:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
char_W:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $F0, $F0, $00
    .BYTE  $FF, $0F, $F0, $00
    .BYTE  $F0, $00, $F0, $00
char_X:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $F0, $00, $F0, $00
char_Y:
    .BYTE  $F0, $00, $F0, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
char_Z:
    .BYTE  $FF, $FF, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $0F, $00, $00, $00
    .BYTE  $F0, $00, $00, $00
    .BYTE  $FF, $FF, $F0, $00

chr_tbl:
		.word char_SPACE
		.word char_0, char_1, char_2, char_3
		.word char_4, char_5, char_6, char_7
		.word char_8, char_9
		.word char_A, char_B, char_C, char_D
		.word char_E, char_F, char_G, char_H
		.word char_I, char_J, char_K, char_L
		.word char_M, char_N, char_O, char_P
		.word char_Q, char_R, char_S, char_T
		.word char_U, char_V, char_W, char_X
		.word char_Y, char_Z

ship_0:
    .BYTE  $00, $00, $00, $00
    .BYTE  $FF, $00, $00, $00
    .BYTE  $0F, $FF, $F0, $00
    .BYTE  $0F, $00, $0F, $F0
    .BYTE  $0F, $FF, $F0, $00
    .BYTE  $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $00
ship_1:
    .BYTE  $00, $00, $00, $00
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $0F, $00, $FF, $F0
    .BYTE  $0F, $00, $FF, $00
    .BYTE  $0F, $FF, $00, $00
    .BYTE  $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $00
ship_2:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $0F, $FF, $F0
    .BYTE  $FF, $F0, $0F, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $00, $00, $00
ship_3:
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $0F, $FF, $00
    .BYTE  $0F, $F0, $0F, $00
    .BYTE  $FF, $F0, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
ship_4:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $FF, $F0, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
ship_5:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $00, $00, $0F, $00
ship_6:
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $0F, $00, $0F, $00
ship_7:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $0F, $00, $00, $00
ship_8:
    .BYTE  $0F, $00, $00, $00
    .BYTE  $0F, $F0, $00, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $00, $FF, $0F, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
ship_9:
    .BYTE  $FF, $00, $00, $00
    .BYTE  $F0, $FF, $00, $00
    .BYTE  $0F, $00, $FF, $00
    .BYTE  $0F, $00, $FF, $F0
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $0F, $00, $00
ship_10:
    .BYTE  $00, $00, $00, $00
    .BYTE  $FF, $FF, $00, $00
    .BYTE  $0F, $00, $FF, $F0
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00
ship_11:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $0F, $FF, $F0
    .BYTE  $FF, $F0, $0F, $00
    .BYTE  $0F, $F0, $0F, $00
    .BYTE  $00, $0F, $FF, $00
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $00, $00
ship_12:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $FF, $FF, $00
    .BYTE  $FF, $00, $0F, $00
    .BYTE  $00, $FF, $FF, $00
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $00, $00, $00
ship_13:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $0F, $FF, $00
    .BYTE  $0F, $F0, $0F, $00
    .BYTE  $FF, $FF, $0F, $00
    .BYTE  $00, $00, $FF, $F0
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
ship_14:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $0F, $0F, $FF, $F0
    .BYTE  $FF, $F0, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
ship_15:
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $0F, $00, $FF, $F0
    .BYTE  $0F, $0F, $F0, $00
    .BYTE  $FF, $F0, $00, $00
    .BYTE  $F0, $00, $00, $00
ship_16:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $FF, $0F, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $0F, $0F, $00, $00
    .BYTE  $0F, $F0, $00, $00
    .BYTE  $0F, $00, $00, $00
ship_17:
    .BYTE  $0F, $00, $00, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $0F, $00, $F0, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $F0, $00, $00
ship_18:
    .BYTE  $0F, $00, $0F, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
ship_19:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $0F, $FF, $FF, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $00, $F0, $00
ship_20:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $0F, $0F, $F0, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $0F, $00
ship_21:
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $FF, $F0, $F0, $00
    .BYTE  $00, $FF, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $00, $F0
ship_22:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $FF, $FF, $0F, $00
    .BYTE  $00, $00, $FF, $F0
    .BYTE  $00, $00, $00, $00
ship_23:
    .BYTE  $00, $00, $00, $00
    .BYTE  $0F, $00, $00, $00
    .BYTE  $0F, $FF, $00, $00
    .BYTE  $0F, $00, $FF, $00
    .BYTE  $0F, $0F, $FF, $F0
    .BYTE  $FF, $F0, $00, $00
    .BYTE  $00, $00, $00, $00

ship_tbl:
		.word ship_0,   ship_1,  ship_2,  ship_3
		.word ship_4,   ship_5,  ship_6,  ship_7
		.word ship_8,   ship_9, ship_10,  ship_11
		.word ship_12, ship_13, ship_14,  ship_15
		.word ship_16, ship_17, ship_18,  ship_19
		.word ship_20, ship_21, ship_22,  ship_23

shifted_ship_0:
    .BYTE  $00, $00, $00, $00
    .BYTE  $0F, $F0, $00, $00
    .BYTE  $00, $FF, $FF, $00
    .BYTE  $00, $F0, $00, $FF
    .BYTE  $00, $FF, $FF, $00
    .BYTE  $0F, $F0, $00, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_1:
    .BYTE  $00, $00, $00, $00
    .BYTE  $0F, $FF, $F0, $00
    .BYTE  $00, $F0, $0F, $FF
    .BYTE  $00, $F0, $0F, $F0
    .BYTE  $00, $FF, $F0, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_2:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $FF, $FF
    .BYTE  $0F, $FF, $00, $F0
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_3:
    .BYTE  $00, $00, $00, $FF
    .BYTE  $00, $00, $FF, $F0
    .BYTE  $00, $FF, $00, $F0
    .BYTE  $0F, $FF, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
shifted_ship_4:
    .BYTE  $00, $00, $00, $F0
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $00, $F0, $F0
    .BYTE  $00, $0F, $FF, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $0F, $00
shifted_ship_5:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $0F, $00, $F0
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $00, $00, $F0
shifted_ship_6:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $F0, $00, $F0
shifted_ship_7:
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $F0, $00, $00
shifted_ship_8:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $0F, $F0, $F0
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
shifted_ship_9:
    .BYTE  $0F, $F0, $00, $00
    .BYTE  $0F, $0F, $F0, $00
    .BYTE  $00, $F0, $0F, $F0
    .BYTE  $00, $F0, $0F, $FF
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $00, $F0, $00
shifted_ship_10:
    .BYTE  $00, $00, $00, $00
    .BYTE  $0F, $FF, $F0, $00
    .BYTE  $00, $F0, $0F, $FF
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_11:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $FF, $FF
    .BYTE  $0F, $FF, $00, $F0
    .BYTE  $00, $FF, $00, $F0
    .BYTE  $00, $00, $FF, $F0
    .BYTE  $00, $00, $00, $F0
    .BYTE  $00, $00, $00, $00
shifted_ship_12:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $FF
    .BYTE  $00, $0F, $FF, $F0
    .BYTE  $0F, $F0, $00, $F0
    .BYTE  $00, $0F, $FF, $F0
    .BYTE  $00, $00, $00, $FF
    .BYTE  $00, $00, $00, $00
shifted_ship_13:
    .BYTE  $00, $00, $00, $F0
    .BYTE  $00, $00, $FF, $F0
    .BYTE  $00, $FF, $00, $F0
    .BYTE  $0F, $FF, $F0, $F0
    .BYTE  $00, $00, $0F, $FF
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_14:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $F0, $FF, $FF
    .BYTE  $0F, $FF, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
shifted_ship_15:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $F0, $0F, $FF
    .BYTE  $00, $F0, $FF, $00
    .BYTE  $0F, $FF, $00, $00
    .BYTE  $0F, $00, $00, $00
shifted_ship_16:
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $0F, $F0, $F0
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $F0, $F0, $00
    .BYTE  $00, $FF, $00, $00
    .BYTE  $00, $F0, $00, $00
shifted_ship_17:
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $F0, $0F, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00
    .BYTE  $00, $0F, $00, $00
shifted_ship_18:
    .BYTE  $00, $F0, $00, $F0
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
shifted_ship_19:
    .BYTE  $00, $00, $00, $F0
    .BYTE  $00, $FF, $FF, $F0
    .BYTE  $00, $0F, $00, $F0
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $00, $00, $0F, $00
shifted_ship_20:
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $00, $0F, $00
    .BYTE  $00, $F0, $FF, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $00, $00, $F0, $F0
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $00, $00, $F0
shifted_ship_21:
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $00, $FF, $00
    .BYTE  $0F, $FF, $0F, $00
    .BYTE  $00, $0F, $F0, $F0
    .BYTE  $00, $00, $0F, $F0
    .BYTE  $00, $00, $00, $0F
shifted_ship_22:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $0F, $00, $00
    .BYTE  $00, $00, $F0, $00
    .BYTE  $00, $0F, $0F, $00
    .BYTE  $0F, $FF, $F0, $F0
    .BYTE  $00, $00, $0F, $FF
    .BYTE  $00, $00, $00, $00
shifted_ship_23:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $F0, $00, $00
    .BYTE  $00, $FF, $F0, $00
    .BYTE  $00, $F0, $0F, $F0
    .BYTE  $00, $F0, $FF, $FF
    .BYTE  $0F, $FF, $00, $00
    .BYTE  $00, $00, $00, $00

shifted_ship_tbl:
		.word shifted_ship_0,   shifted_ship_1,  shifted_ship_2,  shifted_ship_3
		.word shifted_ship_4,   shifted_ship_5,  shifted_ship_6,  shifted_ship_7
		.word shifted_ship_8,   shifted_ship_9, shifted_ship_10,  shifted_ship_11
		.word shifted_ship_12, shifted_ship_13, shifted_ship_14,  shifted_ship_15
		.word shifted_ship_16, shifted_ship_17, shifted_ship_18,  shifted_ship_19
		.word shifted_ship_20, shifted_ship_21, shifted_ship_22,  shifted_ship_23
		
extra_ship:
		.byte	$00, $F0, $00, $00
		.byte $00, $F0, $00, $00
		.byte $0F, $0F, $00, $00		
		.byte $0F, $0F, $00, $00		
		.byte $0F, $0F, $00, $00		
		.byte $FF, $FF, $F0, $00
		.byte $F0, $00, $F0, $00

asteroid_0:
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $0F, $0F, $00, $00, $F0, $F0, $00
    .BYTE  $00, $F0, $00, $F0, $0F, $00, $0F, $00
    .BYTE  $0F, $00, $00, $0F, $0F, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $F0, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $00, $00, $0F, $00
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $0F, $00, $00, $00, $00, $00, $0F, $F0
    .BYTE  $00, $F0, $00, $00, $00, $0F, $F0, $00
    .BYTE  $00, $0F, $F0, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $0F, $FF, $FF, $00, $00, $00
asteroid_1:
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $0F, $F0, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $F0, $0F, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $0F, $00, $0F, $F0, $00, $00
    .BYTE  $00, $00, $00, $FF, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_2:
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_3:
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $0F, $0F, $F0, $0F, $F0, $F0, $00
    .BYTE  $00, $F0, $00, $0F, $F0, $00, $0F, $00
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $0F, $00, $00, $00, $00, $00, $FF, $F0
    .BYTE  $0F, $00, $00, $00, $00, $0F, $00, $00
    .BYTE  $00, $F0, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $F0, $00, $00, $00, $00, $0F, $F0
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $00, $F0, $00, $FF, $00, $00, $0F, $00
    .BYTE  $00, $0F, $0F, $00, $FF, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00, $00, $FF, $00, $00
asteroid_4:
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $0F, $F0, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $0F, $00, $0F, $F0, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $0F, $0F, $F0, $F0, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_5:
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_6:
    .BYTE  $00, $00, $00, $FF, $FF, $FF, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00, $00, $00, $F0, $00
    .BYTE  $00, $0F, $00, $00, $00, $00, $0F, $00
    .BYTE  $00, $F0, $00, $00, $00, $00, $00, $F0
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $FF, $FF, $00, $00, $00, $00, $00, $0F
    .BYTE  $00, $00, $F0, $00, $00, $00, $00, $0F
    .BYTE  $0F, $FF, $00, $00, $00, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $F0, $00, $00, $0F
    .BYTE  $0F, $00, $00, $0F, $F0, $00, $00, $F0
    .BYTE  $0F, $00, $00, $F0, $F0, $00, $00, $F0
    .BYTE  $00, $F0, $00, $F0, $F0, $00, $0F, $00
    .BYTE  $00, $F0, $0F, $00, $F0, $00, $0F, $00
    .BYTE  $00, $0F, $0F, $00, $F0, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00, $FF, $FF, $00, $00
asteroid_7:
    .BYTE  $00, $00, $00, $0F, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $00, $F0, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $FF, $F0, $00, $0F, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $0F, $00, $F0, $F0, $00, $00
    .BYTE  $00, $00, $0F, $0F, $F0, $F0, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_8:
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $0F, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_9:
    .BYTE  $00, $00, $FF, $FF, $FF, $00, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $FF, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $F0, $00, $00, $0F, $F0
    .BYTE  $FF, $FF, $FF, $F0, $00, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $F0, $00, $00, $00, $00, $00, $0F, $FF
    .BYTE  $F0, $00, $00, $00, $0F, $FF, $F0, $00
    .BYTE  $F0, $00, $00, $00, $00, $F0, $00, $00
    .BYTE  $F0, $00, $00, $00, $00, $0F, $F0, $00
    .BYTE  $0F, $00, $00, $00, $00, $00, $0F, $F0
    .BYTE  $0F, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $00, $F0, $00, $00, $00, $00, $00, $0F
    .BYTE  $00, $0F, $00, $00, $0F, $00, $00, $F0
    .BYTE  $00, $0F, $00, $FF, $F0, $F0, $0F, $00
    .BYTE  $00, $00, $FF, $00, $00, $0F, $F0, $00
asteroid_10:
    .BYTE  $00, $00, $00, $FF, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $F0, $00, $00
    .BYTE  $00, $00, $FF, $F0, $00, $0F, $00, $00
    .BYTE  $00, $00, $F0, $00, $0F, $FF, $00, $00
    .BYTE  $00, $00, $F0, $00, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $F0, $00, $00
    .BYTE  $00, $00, $0F, $00, $F0, $0F, $00, $00
    .BYTE  $00, $00, $00, $FF, $0F, $F0, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
asteroid_11:
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $FF, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
large_ufo:
    .BYTE  $00, $00, $00, $FF, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $FF, $FF, $F0, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $0F, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $FF, $FF, $FF, $FF, $FF, $FF, $00
    .BYTE  $00, $0F, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $F0, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $0F, $FF, $FF, $F0, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
small_ufo:
    .BYTE  $00, $00, $00, $0F, $F0, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $0F, $F0, $F0, $00, $00
    .BYTE  $00, $00, $00, $FF, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
shrapnel_0:
    .BYTE  $00, $0F, $00, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $00, $F0, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $0F, $00, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $00, $00, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $0F, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
shrapnel_1:
    .BYTE  $00, $F0, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $F0, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $0F, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $F0, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $0F, $00, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
shrapnel_2:
    .BYTE  $0F, $00, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $F0
    .BYTE  $00, $00, $F0, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $0F, $00, $00, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $00, $F0, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    
shrapnel_3:
    .BYTE  $F0, $00, $00, $00, $00, $00, $0F, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $0F
    .BYTE  $00, $00, $F0, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $F0, $00, $00, $00, $00, $00, $0F, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $0F, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $F0, $00, $00, $00, $0F, $00
		
shrapnel_tbl:
		.word shrapnel_0
		.word shrapnel_1
		.word shrapnel_2, shrapnel_2
		.word shrapnel_3, shrapnel_3
    
player_ship_0:
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $FF, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $F0, $00, $FF, $00, $00
    .BYTE  $00, $00, $00, $F0, $FF, $00, $00, $00
    .BYTE  $00, $00, $00, $FF, $00, $00, $00, $00
    .BYTE  $00, $00, $0F, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00, $00, $00, $00, $00
				
asteroid_tbl:
		; 4 asteroid patterns; large, medium, small
		.word asteroid_0,  asteroid_1,  asteroid_2
		.word asteroid_3,  asteroid_4,  asteroid_5
		.word asteroid_6,  asteroid_7,  asteroid_8
		.word asteroid_9,  asteroid_10, asteroid_11

; "(c)1979 ATARI INC " 60x5 pixels
copyright:
		.byte $00, $00, $0F, $00, $FF, $F0, $FF, $F0, $FF, $F0, $00, $00, $0F, $00, $FF
		.byte $F0, $0F, $00, $FF, $F0, $FF, $F0, $00, $00, $FF, $F0, $F0, $0F, $0F, $FF
		.byte $FF, $00, $0F, $00, $F0, $F0, $00, $F0, $F0, $F0, $00, $00, $F0, $F0, $0F
		.byte $00, $F0, $F0, $F0, $F0, $0F, $00, $00, $00, $0F, $00, $FF, $0F, $0F, $00
		.byte $F0, $00, $0F, $00, $FF, $F0, $00, $F0, $FF, $F0, $00, $00, $FF, $F0, $0F
		.byte $00, $FF, $F0, $FF, $F0, $0F, $00, $00, $00, $0F, $00, $F0, $FF, $0F, $00
		.byte $FF, $00, $0F, $00, $00, $F0, $00, $F0, $00, $F0, $00, $00, $F0, $F0, $0F
		.byte $00, $F0, $F0, $FF, $00, $0F, $00, $00, $00, $0F, $00, $F0, $0F, $0F, $00
		.byte $00, $00, $0F, $00, $00, $F0, $00, $F0, $00, $F0, $00, $00, $F0, $F0, $0F
		.byte $00, $F0, $F0, $F0, $F0, $FF, $F0, $00, $00, $FF, $F0, $F0, $0F, $0F, $FF 
