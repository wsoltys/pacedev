.export chr_tbl
.export copyright
.export extra_ship
.export ship_tbl
.export shifted_ship_tbl
.export asteroid_tbl
.export shifted_asteroid_tbl
.export large_saucer
.export shifted_large_saucer
.export small_saucer
.export shifted_small_saucer
.export shrapnel_tbl
.export shifted_shrapnel_tbl

PIXEL=$0C
OO=$00
OC=PIXEL
CO=(PIXEL<<4)
CC=(PIXEL<<4)|PIXEL

char_SPACE:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO

char_0:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_1:
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO

char_2:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO

char_3:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_4:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

char_5:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_6:
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_7:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

char_8:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_9:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

char_A:
    .BYTE  OO, CO, OO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO

char_B:
    .BYTE  CC, CC, OO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, OO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, OO, OO

char_C:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO

char_D:
    .BYTE  CC, CO, OO, OO
    .BYTE  CO, OC, OO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OC, OO, OO
    .BYTE  CC, CO, OO, OO

char_E:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO

char_F:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO

char_G:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_H:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO

char_I:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  CC, CC, CO, OO

char_J:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OO, CC, CO, OO

char_K:
    .BYTE  CO, OC, OO, OO
    .BYTE  CO, CO, OO, OO
    .BYTE  CC, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, OO, OO, OO
    .BYTE  CO, CO, OO, OO
    .BYTE  CO, OC, OO, OO

char_L:
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO

char_M:
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, OC, CO, OO
    .BYTE  CO, CO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO

char_N:
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, OO, CO, OO
    .BYTE  CO, CO, CO, OO
    .BYTE  CO, CO, CO, OO
    .BYTE  CO, OC, CO, OO
    .BYTE  CO, OC, CO, OO
    .BYTE  CO, OO, CO, OO

char_O:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_P:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO

char_Q:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, CO, CO, OO
    .BYTE  CO, OC, OO, OO
    .BYTE  CC, CO, CO, OO

char_R:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, CO, OO, OO
    .BYTE  CO, OC, OO, OO
    .BYTE  CO, OO, CO, OO

char_S:
    .BYTE  CC, CC, CO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_T:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO

char_U:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CC, CC, CO, OO

char_V:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO

char_W:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, CO, CO, OO
    .BYTE  CC, OC, CO, OO
    .BYTE  CO, OO, CO, OO

char_X:
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  CO, OO, CO, OO
    .BYTE  CO, OO, CO, OO

char_Y:
    .BYTE  CO, OO, CO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO

char_Z:
    .BYTE  CC, CC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OC, OO, OO, OO
    .BYTE  CO, OO, OO, OO
    .BYTE  CC, CC, CO, OO

extra_ship:
		.byte	OO, CO, OO, OO
		.byte OO, CO, OO, OO
		.byte OC, OC, OO, OO		
		.byte OC, OC, OO, OO		
		.byte OC, OC, OO, OO		
		.byte CC, CC, CO, OO
		.byte CO, OO, CO, OO

; "(c)1979 ATARI INC " 60x5 pixels
copyright:
		.byte OO, OO, OC, OO, CC, CO, CC, CO, CC, CO, OO, OO, OC, OO, CC
		.byte CO, OC, OO, CC, CO, CC, CO, OO, OO, CC, CO, CO, OC, OC, CC
		.byte CC, OO, OC, OO, CO, CO, OO, CO, CO, CO, OO, OO, CO, CO, OC
		.byte OO, CO, CO, CO, CO, OC, OO, OO, OO, OC, OO, CC, OC, OC, OO
		.byte CO, OO, OC, OO, CC, CO, OO, CO, CC, CO, OO, OO, CC, CO, OC
		.byte OO, CC, CO, CC, CO, OC, OO, OO, OO, OC, OO, CO, CC, OC, OO
		.byte CC, OO, OC, OO, OO, CO, OO, CO, OO, CO, OO, OO, CO, CO, OC
		.byte OO, CO, CO, CC, OO, OC, OO, OO, OO, OC, OO, CO, OC, OC, OO
		.byte OO, OO, OC, OO, OO, CO, OO, CO, OO, CO, OO, OO, CO, CO, OC
		.byte OO, CO, CO, CO, CO, CC, CO, OO, OO, CC, CO, CO, OC, OC, CC 

ship_0:
    .BYTE  OO, OO, OO, OO
    .BYTE  CC, OO, OO, OO
    .BYTE  OC, CC, CO, OO
    .BYTE  OC, OO, OC, CO
    .BYTE  OC, CC, CO, OO
    .BYTE  CC, OO, OO, OO
    .BYTE  OO, OO, OO, OO

ship_1:
    .BYTE  OO, OO, OO, OO
    .BYTE  CC, CC, OO, OO
    .BYTE  OC, OO, CC, CO
    .BYTE  OC, OO, CC, OO
    .BYTE  OC, CC, OO, OO
    .BYTE  OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO

ship_2:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OC, CC, CO
    .BYTE  CC, CO, OC, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, OO, OO, OO

ship_3:
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, OC, CC, OO
    .BYTE  OC, CO, OC, OO
    .BYTE  CC, CO, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO

ship_4:
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, CC, CO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

ship_5:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OO, OO, OC, OO

ship_6:
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OC, OO, OC, OO

ship_7:
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OC, OO, OO, OO

ship_8:
    .BYTE  OC, OO, OO, OO
    .BYTE  OC, CO, OO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OO, CC, OC, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO

ship_9:
    .BYTE  CC, OO, OO, OO
    .BYTE  CO, CC, OO, OO
    .BYTE  OC, OO, CC, OO
    .BYTE  OC, OO, CC, CO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, OC, OO, OO

ship_10:
    .BYTE  OO, OO, OO, OO
    .BYTE  CC, CC, OO, OO
    .BYTE  OC, OO, CC, CO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, OO, OO

ship_11:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OC, CC, CO
    .BYTE  CC, CO, OC, OO
    .BYTE  OC, CO, OC, OO
    .BYTE  OO, OC, CC, OO
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, OO, OO

ship_12:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, CC, CC, OO
    .BYTE  CC, OO, OC, OO
    .BYTE  OO, CC, CC, OO
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, OO, OO, OO

ship_13:
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OC, CC, OO
    .BYTE  OC, CO, OC, OO
    .BYTE  CC, CC, OC, OO
    .BYTE  OO, OO, CC, CO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO

ship_14:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OC, OC, CC, CO
    .BYTE  CC, CO, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO

ship_15:
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OC, OO, CC, CO
    .BYTE  OC, OC, CO, OO
    .BYTE  CC, CO, OO, OO
    .BYTE  CO, OO, OO, OO

ship_16:
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CC, OC, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OC, OC, OO, OO
    .BYTE  OC, CO, OO, OO
    .BYTE  OC, OO, OO, OO

ship_17:
    .BYTE  OC, OO, OO, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OC, OO, CO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CO, OO, OO

ship_18:
    .BYTE  OC, OO, OC, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO

ship_19:
    .BYTE  OO, OO, OC, OO
    .BYTE  OC, CC, CC, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OO, CO, OO

ship_20:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OC, OC, CO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, OC, OO

ship_21:
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  CC, CO, CO, OO
    .BYTE  OO, CC, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, OO, CO

ship_22:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  CC, CC, OC, OO
    .BYTE  OO, OO, CC, CO
    .BYTE  OO, OO, OO, OO

ship_23:
    .BYTE  OO, OO, OO, OO
    .BYTE  OC, OO, OO, OO
    .BYTE  OC, CC, OO, OO
    .BYTE  OC, OO, CC, OO
    .BYTE  OC, OC, CC, CO
    .BYTE  CC, CO, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_0:
    .BYTE  OO, OO, OO, OO
    .BYTE  OC, CO, OO, OO
    .BYTE  OO, CC, CC, OO
    .BYTE  OO, CO, OO, CC
    .BYTE  OO, CC, CC, OO
    .BYTE  OC, CO, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_1:
    .BYTE  OO, OO, OO, OO
    .BYTE  OC, CC, CO, OO
    .BYTE  OO, CO, OC, CC
    .BYTE  OO, CO, OC, CO
    .BYTE  OO, CC, CO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_2:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, CC, CC
    .BYTE  OC, CC, OO, CO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_3:
    .BYTE  OO, OO, OO, CC
    .BYTE  OO, OO, CC, CO
    .BYTE  OO, CC, OO, CO
    .BYTE  OC, CC, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

shifted_ship_4:
    .BYTE  OO, OO, OO, CO
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, OO, CO, CO
    .BYTE  OO, OC, CC, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, OC, OO

shifted_ship_5:
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OC, OO, CO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, OO, OO, CO

shifted_ship_6:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, CO, OO, CO

shifted_ship_7:
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, CO, OO, OO

shifted_ship_8:
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, OC, CO, CO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO

shifted_ship_9:
    .BYTE  OC, CO, OO, OO
    .BYTE  OC, OC, CO, OO
    .BYTE  OO, CO, OC, CO
    .BYTE  OO, CO, OC, CC
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OO, CO, OO

shifted_ship_10:
    .BYTE  OO, OO, OO, OO
    .BYTE  OC, CC, CO, OO
    .BYTE  OO, CO, OC, CC
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_11:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, CC, CC
    .BYTE  OC, CC, OO, CO
    .BYTE  OO, CC, OO, CO
    .BYTE  OO, OO, CC, CO
    .BYTE  OO, OO, OO, CO
    .BYTE  OO, OO, OO, OO

shifted_ship_12:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC
    .BYTE  OO, OC, CC, CO
    .BYTE  OC, CO, OO, CO
    .BYTE  OO, OC, CC, CO
    .BYTE  OO, OO, OO, CC
    .BYTE  OO, OO, OO, OO

shifted_ship_13:
    .BYTE  OO, OO, OO, CO
    .BYTE  OO, OO, CC, CO
    .BYTE  OO, CC, OO, CO
    .BYTE  OC, CC, CO, CO
    .BYTE  OO, OO, OC, CC
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_14:
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, CO, CC, CC
    .BYTE  OC, CC, OO, OO
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO

shifted_ship_15:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, CO, OC, CC
    .BYTE  OO, CO, CC, OO
    .BYTE  OC, CC, OO, OO
    .BYTE  OC, OO, OO, OO

shifted_ship_16:
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OC, CO, CO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, CO, CO, OO
    .BYTE  OO, CC, OO, OO
    .BYTE  OO, CO, OO, OO

shifted_ship_17:
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, CO, OC, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, CO, OO
    .BYTE  OO, OC, OO, OO

shifted_ship_18:
    .BYTE  OO, CO, OO, CO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO

shifted_ship_19:
    .BYTE  OO, OO, OO, CO
    .BYTE  OO, CC, CC, CO
    .BYTE  OO, OC, OO, CO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OO, OO, OC, OO

shifted_ship_20:
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, OO, OC, OO
    .BYTE  OO, CO, CC, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OO, OO, CO, CO
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, OO, OO, CO

shifted_ship_21:
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OO, CC, OO
    .BYTE  OC, CC, OC, OO
    .BYTE  OO, OC, CO, CO
    .BYTE  OO, OO, OC, CO
    .BYTE  OO, OO, OO, OC

shifted_ship_22:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, OC, OO, OO
    .BYTE  OO, OO, CO, OO
    .BYTE  OO, OC, OC, OO
    .BYTE  OC, CC, CO, CO
    .BYTE  OO, OO, OC, CC
    .BYTE  OO, OO, OO, OO

shifted_ship_23:
    .BYTE  OO, OO, OO, OO
    .BYTE  OO, CO, OO, OO
    .BYTE  OO, CC, CO, OO
    .BYTE  OO, CO, OC, CO
    .BYTE  OO, CO, CC, CC
    .BYTE  OC, CC, OO, OO
    .BYTE  OO, OO, OO, OO

asteroid_0:
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OC, OC, OO, OO, CO, CO, OO, OO, OO
    .BYTE  OO, CO, OO, CO, OC, OO, OC, OO, OO, OO
    .BYTE  OC, OO, OO, OC, OC, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, CO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OC, CO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OC, CO, OO, OO, OO
    .BYTE  OO, OC, CO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, CC, CC, OO, OO, OO, OO, OO

asteroid_1:
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, CO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_2:
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_3:
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OC, OC, CO, OC, CO, CO, OO, OO, OO
    .BYTE  OO, CO, OO, OC, CO, OO, OC, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, CC, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OC, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, CO, OO, CC, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OC, OC, OO, CC, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, CC, OO, OO, OO, OO

asteroid_4:
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_5:
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_6:
    .BYTE  OO, OO, OO, CC, CC, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  CC, CC, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, CC, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, CO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OC, CO, OO, OO, CO, OO, OO
    .BYTE  OC, OO, OO, CO, CO, OO, OO, CO, OO, OO
    .BYTE  OO, CO, OO, CO, CO, OO, OC, OO, OO, OO
    .BYTE  OO, CO, OC, OO, CO, OO, OC, OO, OO, OO
    .BYTE  OO, OC, OC, OO, CO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, CC, CC, OO, OO, OO, OO

asteroid_7:
    .BYTE  OO, OO, OO, OC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CC, CO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_8:
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_9:
    .BYTE  OO, OO, CC, CC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OC, CO, OO, OO
    .BYTE  CC, CC, CC, CO, OO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OC, CC, OO, OO
    .BYTE  CO, OO, OO, OO, OC, CC, CO, OO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OC, CO, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OC, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, OC, OO, OO, OC, OO, OO, CO, OO, OO
    .BYTE  OO, OC, OO, CC, CO, CO, OC, OO, OO, OO
    .BYTE  OO, OO, CC, OO, OO, OC, CO, OO, OO, OO

asteroid_10:
    .BYTE  OO, OO, OO, CC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CC, CO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OC, CC, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, CO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

asteroid_11:
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_0:
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, CO, OO, OC, OC, OO, OO, OO
    .BYTE  OO, OC, OO, OC, OO, CO, OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO, CO, CO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OC, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, CC, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, CC, OO, OO, OO
    .BYTE  OO, OO, CC, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, CC, CO, OO, OO, OO, OO

shifted_asteroid_1:
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OC, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_2:
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_3:
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, CC, OO, CC, OC, OO, OO, OO
    .BYTE  OO, OC, OO, OO, CC, OO, OO, CO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OC, CC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OO, CC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, OC, OO, OC, CO, OO, OO, CO, OO, OO
    .BYTE  OO, OO, CO, CO, OC, CO, OC, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OC, CO, OO, OO, OO

shifted_asteroid_4:
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_5:
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_6:
    .BYTE  OO, OO, OO, OC, CC, CC, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OC, CC, CO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, CC, CO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OC, OO, OO, OO, CO, OO
    .BYTE  OO, CO, OO, OO, CC, OO, OO, OC, OO, OO
    .BYTE  OO, CO, OO, OC, OC, OO, OO, OC, OO, OO
    .BYTE  OO, OC, OO, OC, OC, OO, OO, CO, OO, OO
    .BYTE  OO, OC, OO, CO, OC, OO, OO, CO, OO, OO
    .BYTE  OO, OO, CO, CO, OC, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OC, CC, CO, OO, OO, OO

shifted_asteroid_7:
    .BYTE  OO, OO, OO, OO, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, CC, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_8:
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_9:
    .BYTE  OO, OO, OC, CC, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OC, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OO, OO, CC, OO, OO
    .BYTE  OC, CC, CC, CC, OO, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CC, CO, OO
    .BYTE  OC, OO, OO, OO, OO, CC, CC, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, CC, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, CC, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, OO, CO, OO, OO, CO, OO, OC, OO, OO
    .BYTE  OO, OO, CO, OC, CC, OC, OO, CO, OO, OO
    .BYTE  OO, OO, OC, CO, OO, OO, CC, OO, OO, OO

shifted_asteroid_10:
    .BYTE  OO, OO, OO, OC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, CC, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, CC, CO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_asteroid_11:
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

large_saucer:
    .BYTE  OO, OO, OO, CC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, CC, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, CC, CC, CC, CC, CC, CC, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, CC, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_large_saucer:
    .BYTE  OO, OO, OO, OC, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, CC, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OC, CC, CC, CC, CC, CC, CO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, CC, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

small_saucer:
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OC, CO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_small_saucer:
    .BYTE  OO, OO, OO, OO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shrapnel_0:
    .BYTE  OO, OC, OO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shrapnel_1:
    .BYTE  OO, CO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shrapnel_2:
    .BYTE  OC, OO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shrapnel_3:
    .BYTE  CO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  CO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, OC, OO, OO, OO

shifted_shrapnel_0:
    .BYTE  OO, OO, CO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, CO, OO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_shrapnel_1:
    .BYTE  OO, OC, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OC, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_shrapnel_2:
    .BYTE  OO, CO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OC, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, CO, OO, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OC, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_shrapnel_3:
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, CO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OC, OO, OO, OO, OO, OO, OO, CO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, CO, OO, OO

unused_player_ship_0:
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, CC, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, CC, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CC, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OC, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

shifted_unused_player_ship_0:
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OO, OC, CO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, OC, CO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OC, CO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, CO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO
    .BYTE  OO, OO, OO, OO, OO, OO, OO, OO, OO, OO

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

ship_tbl:
		.word ship_0,   ship_1,  ship_2,  ship_3
		.word ship_4,   ship_5,  ship_6,  ship_7
		.word ship_8,   ship_9, ship_10,  ship_11
		.word ship_12, ship_13, ship_14,  ship_15
		.word ship_16, ship_17, ship_18,  ship_19
		.word ship_20, ship_21, ship_22,  ship_23

shifted_ship_tbl:
		.word shifted_ship_0,   shifted_ship_1,  shifted_ship_2,  shifted_ship_3
		.word shifted_ship_4,   shifted_ship_5,  shifted_ship_6,  shifted_ship_7
		.word shifted_ship_8,   shifted_ship_9, shifted_ship_10,  shifted_ship_11
		.word shifted_ship_12, shifted_ship_13, shifted_ship_14,  shifted_ship_15
		.word shifted_ship_16, shifted_ship_17, shifted_ship_18,  shifted_ship_19
		.word shifted_ship_20, shifted_ship_21, shifted_ship_22,  shifted_ship_23
		
asteroid_tbl:
		; 4 asteroid patterns; large, medium, small
		.word asteroid_0,  asteroid_1,  asteroid_2
		.word asteroid_3,  asteroid_4,  asteroid_5
		.word asteroid_6,  asteroid_7,  asteroid_8
		.word asteroid_9,  asteroid_10, asteroid_11

shifted_asteroid_tbl:
		; 4 asteroid patterns; large, medium, small
		.word shifted_asteroid_0,  shifted_asteroid_1,  shifted_asteroid_2
		.word shifted_asteroid_3,  shifted_asteroid_4,  shifted_asteroid_5
		.word shifted_asteroid_6,  shifted_asteroid_7,  shifted_asteroid_8
		.word shifted_asteroid_9,  shifted_asteroid_10, shifted_asteroid_11

shrapnel_tbl:
		.word shrapnel_0
		.word shrapnel_1
		.word shrapnel_2, shrapnel_2
		.word shrapnel_3, shrapnel_3
    
shifted_shrapnel_tbl:
		.word shifted_shrapnel_0
		.word shifted_shrapnel_1
		.word shifted_shrapnel_2, shifted_shrapnel_2
		.word shifted_shrapnel_3, shifted_shrapnel_3
