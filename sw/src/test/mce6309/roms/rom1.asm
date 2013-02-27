*
* mce6309 test rom v1
*
				org		$0000
start		equ		$
				adda	<$10
				adda	<$11
				nop
				nop
				exg		d,x
				inca
				incb
				exg		x,u
				exg		s,u
				exg		a,cc
				exg		b,dp
				exg		d,s
				adda	<$-1
				adda	>$0005
				adda	,x
				adda	5,x
				nop
				nop
				nop
				nop
				nop
end			equ		$
