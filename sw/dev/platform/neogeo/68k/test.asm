	cpu 68000

ram_start equ $d00000
ram_end   equ $000fff
rom_start equ $000000
rom_end   equ $0007ff
io_start  equ $001000
io_end	  equ $ffffff

	org $0000

reset_ssp	dc.l	$000dff
reset_pc  dc.l	start
	
	org $0400
	
start:
	nop
	
	move.w #$55, d0
	move.l #io_start,a0
	move.w d0,(a0)

	move.w #$1234,d0
	move.l #$0810,a0
	move.w d0,(a0)
	move.w (a0),d0

myhalt:
	bra myhalt
	
rdzero:	
	move.w (a0),d0
	btst #7,d0
	bne setmem
	movea.w d0,(a0)
	bra rdzero

	clr.w d0
		
	
setmem:
	; yes yes redundant when ram_start is 0 I know
	suba.w a0,a0
	movea.l #ram_start,a0
	suba.w a1,a1
	movea.l #io_start,a1
	suba.w a2,a2
	movea.l #ram_start,a2

_l1:
	addq.b #1,d0
	move.w d0,(a0)+
	movea.w d0,(a1)
	cmpa.l #(ram_start + $400),a0
	blt _l1 

	move.l #ram_start,a0
	clr.w d0
	clr.w d1

getmem:
	addq.b #1,d0
	movea.w (a0),d1
	cmp.w	d0,d1
	bne error
	cmpa.l #(ram_start + $400),a0
	addq.l #1,a0
	blt getmem
	
done:
	suba.w a0,a0
	movea.w #$ee,(a0)
	bra done	

error:
	suba.w a0,a0
	movea.w #$a5,(a0)
	bra error