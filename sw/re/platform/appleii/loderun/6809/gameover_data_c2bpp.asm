				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.include "coco3.asm"

        .org  gameover_data

; line 1
				.db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00  
; line 2
				.db     0x00, 0x00, 0x15, 0x55, 0x55, 0x55, 0x55, 0x55  
        .db     0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55  
        .db     0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x50  
        .db     0x00, 0x00  
; line 3
				.db     0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01  
        .db     0x00, 0x00  
; line 4
				.db     0x00, 0x01, 0x01, 0x55, 0x50, 0x15, 0x50, 0x15  
        .db     0x55, 0x50, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50  
        .db     0x15, 0x01, 0x01, 0x55, 0x50, 0x15, 0x55, 0x01  
        .db     0x00, 0x00  
; line 5
				.db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x15  
        .db     0x50, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50  
        .db     0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01  
        .db     0x00, 0x00  
; line 6
				.db     0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50  
        .db     0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01  
        .db     0x00, 0x00  
; line 7
				.db     0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x50, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x01, 0x01, 0x55, 0x00, 0x15, 0x55, 0x01  
        .db     0x00, 0x00  
; line 8
				.db     0x00, 0x01, 0x01, 0x01, 0x50, 0x15, 0x50, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x01, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01  
        .db     0x00, 0x00  
; line 9
				.db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x55, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01  
        .db     0x00, 0x00  
; line 10
				.db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x50, 0x01, 0x00, 0x00, 0x15, 0x01, 0x01  
        .db     0x00, 0x00  
; line 11
				.db     0x00, 0x01, 0x01, 0x55, 0x50, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50  
        .db     0x01, 0x00, 0x01, 0x55, 0x50, 0x15, 0x01, 0x01  
        .db     0x00, 0x00  
