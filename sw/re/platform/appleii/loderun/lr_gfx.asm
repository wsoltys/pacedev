;
;	LODE RUNNER - TITLE_DATA
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.include "coco3.asm"

        ; $4000
        .org    MMUTSK1+2
        .db     0x02, 0x03

        .org    tile_data & 0x7FFF
        
.ifdef GFX_1BPP
  .include "tile_data_m1bpp.asm"
.else
  .ifdef GFX_MONO
    .include "tile_data_m2bpp.asm"
  .else
    .include "tile_data_c2bpp.asm"
  .endif
.endif       
        
        .org    title_data & 0x7FFF

.ifdef GFX_1BPP
  .include "title_data_m1bpp.asm"
.else
  .ifdef GFX_MONO
    .include "title_data_m2bpp.asm"
  .else
    .include "title_data_c2bpp.asm"
  .endif
.endif
  
        ; $4000,$6000
        .org    MMUTSK1+2
        .db     0x3A, 0x3B
