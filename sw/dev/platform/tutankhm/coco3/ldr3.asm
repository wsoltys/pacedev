*
* COCO registers
*
PIA0		equ	$FF00
PIA1		equ	$FF20
*
KEYCOL		equ	PIA0+2
KEYROW		equ	PIA0
*
* GIME registers
*
INIT0		equ	$FF90
INIT1		equ	$FF91
IRQENR		equ	$FF92
FIRQENR		equ	$FF93
TMRMSB		equ	$FF94
TMRLSB		equ	$FF95
VMODE		equ	$FF98
VRES		equ	$FF99
BRDR		equ	$FF9A
VSC		equ	$FF9C
VOFFMSB		equ	$FF9D
VOFFLSB		equ	$FF9E
HOFF		equ	$FF9F
MMUTSK1		equ	$FFA0
MMUTSK2		equ	$FFA8
PALETTE		equ	$FFB0
CPU089		equ	$FFD8
CPU179		equ	$FFD9
ROMMODE		equ	$FFDE
RAMMODE		equ	$FFDF
*
* Tutankham defines
*
DSW2		equ	$8160
IN0		equ	$8180
IN1		equ	$81A0
IN2		equ	$81C0
DSW1		equ	$81E0
* Locations that need patching
OFFSET		equ	$1000
PALTBL		equ	$A2D1-OFFSET	; address of palette table in ROM
INTENA2		equ	$A496-OFFSET	; another one
CPYRGHT3	equ	$CCD1-OFFSET	; and another one
INTDIS		equ	$CCD6-OFFSET	; interrupt disable routine
INTENA		equ	$CD03-OFFSET	; interrupt enable routine
INC15		equ	$CD1E-OFFSET	; increments colour 15 twice (make it once)
CPYRGHT		equ	$CE27-OFFSET	; copyright check conditional branch
CPYRGHT2	equ	$D974-OFFSET	; another copyright check
E187TBL		equ	$E187-OFFSET	; another table of colours
*
* 		Scratch area
*
ROW3		equ	$84FD
ROW4		equ	$84FE
IRQ30HZ		equ	$84FF
*
* 		Tutankham Loader
*	
		org	$7000
RAM_TOP		equ	*
*		ISR
isr_start	equ	*
		lda	IRQENR			; acknowledge GIME interrupt
		anda	#$08			; IRQ interrupt?
		beq	isr_exit		; no exit
		eora	IRQ30HZ			; time for 30Hz interrupt?
		sta	IRQ30HZ
*		fqb	#$10261BF5		; yes, LBNE $A006
		fqb	#$10260BF5		; yes, LBNE $9006
*		read some keys
		clra				; clear carry
		deca				; #$FF (active low)
		sta	#ROW3
		sta	#ROW4
		ldx	#PIA0
key_loop	rola				; finished all columns?
		bcc	keys_read		; yes, exit
		sta	2,x			; set column strobe
		ldb	,x			; read row
		tfr	d,y			; save column, row data
		bitb	#$08			; row3?
		bne	read_row4
		anda	ROW3			; reset column bit for row 3
		sta	#ROW3
		tfr	y,d			; restore column, row data				
read_row4	bitb	#$10			; row4?
		bne	key_loop
		anda	ROW4			; reset column bit for row 4
		sta	#ROW4
		tfr	y,d			; restore column, row data
		bra	key_loop
keys_read	lda	ROW4			; coins, start
		ora	#$99			; only want "1","2","5","6"
		orcc	#$01			; set carry flag
		rola
		rola				; shift START1,2 into bits 3,4
		sta	#ROW4			; save
		rola
		rola				; shift COIN1,2 into bits 0,1
		anda	ROW4			; combine START,COIN bits
		ora	#$E4			; mask off unwanted bits
		sta	#IN0			; patch game inputs
		lda	ROW3			; player 1 controls
		ora	#$02			; mask off unwanted bits
		orcc	#$01			; set carry flag
		rora				; shift up, down, button3 into bits 2,3,6
		ora	#$B3			; mask off invalid bits
		sta	#IN1			; add keys to game inputs
		lda	ROW3			; original
		rola
		rola				; shift button1 into bit 4
		tfr	a,b
		orb	#$EF			; mask off invalid bits
		andb	IN1
		stb	#IN1			; add keys to game inputs
		rola
		rola				; shift left, right into bits 0,1
		tfr	a,b
		orb	#$FC			; mask off invalid bits
		andb	IN1
		stb	#IN1			; add keys to game inputs
		rola				; shift button2 into bit 5
		ora	#$DF			; mask off invalid bits
		anda	IN1
		sta	#IN1			; add keys to game inputs						
isr_exit	RTI
isr_end		equ	*
*
*		MAIN
*				
start		equ	*
		orcc	#$50			; disable interrupts
		lds	#RAM_TOP
*		DISABLE PIA interrupts
		lda	#$34
		sta	#(PIA0+1)		; PIA0, CA1,2 control
		sta	#(PIA0+3)		; PIA0, CB1,2 control
		sta	#(PIA1+1)		; PIA1, CA1,2 control
		sta	#(PIA1+3)		; PIA1, CB1,2 control
*		INITIALISE GIME
		lda	IRQENR			; ACK any pending GIME interrupt
		lda	#$40			; enable GIME MMU
		sta	INIT0
		lda	#$00			; slow timer, task 1
		sta	INIT1
		lda	#$08			; VBLANK IRQ
		sta	IRQENR
		lda	#$00			; no FIRQ enabled
		sta	FIRQENR
		lda	#$80			; graphics mode, 60Hz, 1 line/row
		sta	VMODE
		lda	#$7A			; 225 scanlines, 128 bytes/row, 16 colours
		sta	VRES
		lda	#$00			; black
		sta	BRDR
		lda	#$E1			; screen based at page $38 ($70000) + 16 lines (16*128=2KB)
		sta	VOFFMSB			; /8 = $E100
		lda	#$00
		sta	VOFFLSB
		lda	#$00			; normal display, horiz offset 0
		sta	HOFF
		sta	RAMMODE			; select RAM mode
*		map the font data into low memory for patching
		ldx	#MMUTSK1		; start of bank registers for TASK 1
		lda	#23			; bank 23 ($1E000) has font data @$1F000
		sta	2,x			; map to $4000 temporarily
*		PATCH font data ($F000-$FE3F)
*		- swap high, low nibble
		ldx	#$5000			; start of font data
!		lda	,x
		if	0=0
		ldb	#16
		mul
		stb	,x
		ora	,x			; swap nibbles by multiplying by 16, OR'ing results
		endif
		sta	,x+
		cmpx	#$5E40			; done?
		bne	<			; no, loop
*		map each graphics rom bank to $E000
*		nibble-swap the graphics data
*		and copy the font data across
		clra
		ldx	#MMUTSK1		; start of bank registers for TASK 1
copy_bank	sta	7,x			; map to $E000
		if	0=0
		ldy	#$E000			; start of graphics data
		cmpa	#4			; bank <= 4?
		ble	patch_bank		; yes, start patching
		ldy	#$EE00			; bottom of 5,6 is radar data
		cmpa	#6			; bank = 5,6?
		ble	patch_bank		; yes, start patching
		ldy	#$EC00			; bottom of bank 7 is maze data
		cmpa	#7			; bank = 7?
		ble	patch_bank		; yes, start patching
		ldy	#$E000
		cmpa	#8			; bank = 8?
		ble	patch_bank		; yes start patching
		bra	copy_font
*		PATCH graphics data ($E000-$EFFF)
*		- swap high, low nibble
patch_bank	lda	,y
		ldb	#16
		mul
		stb	,y
		ora	,y			; swap nibbles by multiplying by 16, OR'ing results
		sta	,y+
		cmpy	#$F000			; done?
		bne	patch_bank		; no, loop
		endif
*		copy the font data to the end of the graphics rom
copy_font	ldx	#$5000			; ptr font data
		ldy	#$F000			; destination
!		ldd	,x++
		std	,y++
		cmpx	#$5E40			; done?
		bne	<			; no, loop
*		PATCH IRQ vector
		lda	#$16			; LBRA
		sta	#$FEF7
		ldd	#$8506			; relative offset #$8400
		std	#$FEF8
		ldx	#MMUTSK1
		lda	7,x			; read back the bank
		anda	#$3F			; mask off invalid bits
		inca				; next bank
		cmpa	#16			; done all 16 banks?
		bne	copy_bank		; no, loop
*		now we've setup and patched everything in high memory
*		map the program ROMs into low memory where they'll run
		ldx	#MMUTSK1		; start of bank registers for TASK 1
		lda	#$3A
		sta	2,x			; restore bank $3A at $4000
		lda	#20			; bank 20 ($18000) ROM starting at $9000
		sta	4,x			; map to $8000
		inca				; bank 21 ($1A000) ROM
		sta	5,x			; map to $A000
		inca				; bank 22 ($1C000) ROM
		sta	6,x			; map to $C000
		clra
		sta	7,x			; map bank 0		
		sta	CPU179			; select fast CPU clock (1.79MHz)
*		Now patch code that checks for copyright graphics in above
*		- calculates checksum from $F5C0 for $66 bytes
		ldd	#$1212			; NOP,NOP
		std	#CPYRGHT
		std	#CPYRGHT+2		; patch out conditional branch to ultimate reboot		
		std	#CPYRGHT2
		std	#CPYRGHT2+2
		std	#CPYRGHT3
		std	#CPYRGHT3+2
*		CONVERT palette table entries
*		- this is rather brain-dead, but it works!!!
		ldx	#PALTBL
!		lda	,x
		bsr	cnvclr
		stb	,x+
		cmpx	#PALTBL+$70
		bne	<
		ldx	#E187TBL
!		lda	,x
		bsr	cnvclr
		stb	,x+
		cmpx	#E187TBL+$10
		bne	<
*		PATCH code that increments colour 15 twice
		ldd	#$1212			; nop nop
		std	#INC15
*		PATCH INPUTS for now (active HIGH)
		lda	#$FF
		sta	#DSW1
		sta	#IN2
		sta	#IN1
		sta	#IN0
		lda	#$DB			; "11011011"
		sta	#DSW2
		if	0=1
*		PATCH interrupt enable routine
		lda	#$60			; LDA #$60 (enable GIME MMU,VBLANK interrupt)
		sta	#INTENA+1
		sta	#INTENA2+1
*		PATCH interrupt disable routine
		ldd	#$8640			; LDA #$40 (enable GIME MMU only)
		std	#INTDIS
		lda	#$B7			; STA
		sta	#INTDIS+2
		ldd	#INIT0			; STA operand (address of interrupt enable)
		std	#INTDIS+3
		lda	#$12			; NOP (fortunately it also kicked the watchdog here)
		sta	#INTDIS+5
		endif
*		INSERT ISR
		clr	IRQ30HZ			; clear ISR toggle flag
		LDX	#isr_start
		LDY	#$8400
pvec		lda	,x+
		sta	,y+
		cmpx	#isr_end
		bne	pvec
*		START EXECUTION
		JMP	#$A003-OFFSET		; start Tutankham (skip CLR INT_EN)
*
*
*		Convert Tutankhm RGB value to GIME RGB value			
cnvclr		clrb
		bita	#$04			; BBGGG(R)RR
		beq	bit4
		orb	#$20			; ..(R)GBRGB
bit4		bita	#$20			; BB(G)GGRRR
		beq	bit3
		orb	#$10			; ..R(G)BRGB
bit3		bita	#$80			; (B)BGGGRRR
		beq	bit2
		orb	#$08			; ..RG(B)RGB
bit2		bita	#$02			; BBGGGR(R)R
		beq	bit1
		orb	#$04			; ..RGB(R)GB
bit1		bita	#$10			; BBG(G)GRRR
		beq	bit0
		orb	#$02			; ..RGBR(G)B
bit0		bita	#$40			; B(B)GGGRRR
		beq	bytedone
		orb	#$01			; ..RGBRG(B)
bytedone	rts
		end	start
	