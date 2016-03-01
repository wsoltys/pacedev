;
;	Knight Lore - LOADER
; - ported from the original ZX Spectrum version
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.include "coco3.asm"

        ; $2000,$4000,$6000
        .org    MMUTSK1+1
        .db     DATA_PG1, DATA_PG2, DATA_PG3

; needs to be at final location
; run "reloc" to fix the loading addresses
        .org    0x8000
.include "kl_dat.asm"
        
        ; $2000,$4000,$6000
        .org    MMUTSK1+1
        .db     0x39, 0x3a, 0x3b
