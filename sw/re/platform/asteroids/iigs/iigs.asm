.include "apple2.inc"

apple_reset:
				.A8
				.I8
				lda			#$02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts

apple_start:
				.A8
				.I8
				; switch into superhires mode (from 8-bit mode)
				lda			NEWVIDEO
				ora			#(1<<7)|(1<<6)				; SHR, linear
				and			#~(1<<5)+256					; colour
				sta			NEWVIDEO
				; enable shadowing
				lda			SHADOW
				ora			#!(1<<3)+256					; enable for SHR (only)
				sta			SHADOW
				; init the palette
				IIGSMODE
				lda			#$000									; black
				sta			$019e00								; palette=0, colour=0
				lda			#$fff									; white
				sta			$019e02								; palette=0, colour=1
				; init SCBs
				ldx			#200-1								; 200 lines
				lda			#$0000
:				sta			$019D00,x
				dex
				dex
				bpl			:-				
				IIMODE
				rts

apple_render_frame:
				IIGSMODE
				IIMODE
				rts
