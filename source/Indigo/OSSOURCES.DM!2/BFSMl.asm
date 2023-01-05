; BfsMl.asm -- miscellaneous machine code; Copyright Xerox Corporation 1979; Last modified December 9, 1979  6:30 PM by Taft; outgoing procedures.ent MoveBlock, SetBlock, Zero, BitBlt
.ent Usc, DoubleAdd, Min, Max, Umin, Umax
.ent Idle, Noop, StartIO.ent DisableInterrupts, EnableInterrupts.ent TruePredicate, FalsePredicate.ent BFSSetStartingVDA; outgoing statics.bext oneBits, freePageFp, freePageFid.bext lvIdle
	.srel
MoveBlock:	.MoveBlock
SetBlock:	.SetBlock
Zero:		.ZeroBitBlt:		.BitBlt
Usc:		.UscDoubleAdd:	.DoubleAddMin:		.MinMax:		.MaxUmin:		.UminUmax:		.Umax

oneBits:	.oneBits
freePageFid:	.freePageFidfreePageFp:	.freePageFid
DisableInterrupts: .DisableInterrupts
EnableInterrupts: .EnableInterruptsStartIO:	.StartIONoop:		.NoopIdle:		.IdlelvIdle:		0TruePredicate:	.TruePredicateFalsePredicate:	.FalsePredicateBFSSetStartingVDA: .Noop	; dummy - deimplemented

	.nrel
; Data transfer primitives; MoveBlock(dest, src, count)
.MoveBlock: sta 3 1,2
	neg 1 3	mov 0 1	com 3 0
	lda 3 3,2
	neg 3 3	adc 3 1
	blt
	jmp done
; Zero(addr, count)
.Zero:	sta 1 3,2
	mkzero 1 1
; fall through
; SetBlock(dest, value, count)
.SetBlock: sta 3 1,2
	mov 1 3	mov 0 1	mov 3 0
	lda 3 3,2
	neg 3 3	adc 3 1
	blks
	jmp done; BitBlt(bbt).BitBlt: sta 3 1,2	movr# 0 0 szc	 #77400		; swat if bbt is odd	mov 2 1	mov 0 2		; bbt	sta 1 1,2	; save frame pointer in unused bbt word	mkzero 1 1	; scan line count	bitblt	lda 2 1,2
	jmp done

; Arithmetic; Usc(a,b)
; a and b are treated as 16 bit positive integers.  Returns:;	-1 if a < b;	 0 if a = b;	 1 if a > b
.Usc:	adcz# 0 1 szc
	 jmp true		; -1
	subz 1 0 szr
	 mkone 0 0
	jmp 1,3; Min(a, b); Max(a, b) -- signed compares (a and b must differ by < 2^15); Umin(a, b); Umax(a, b) -- unsigned compares.Min:	sle 0 1	 mov 1 0	jmp 1 3.Max:	sge 0 1	 mov 1 0	jmp 1 3.Umin:	sleu 0 1	 mov 1 0	jmp 1 3.Umax:	sgeu 0 1	 mov 1 0	jmp 1 3; DoubleAdd(a, b); a _ a + b (a and b are pointers to double precision numbers).DoubleAdd:	sta 3 1,2	sta 1 2,2		;=> first word of arg 2	mov 1 3	lda 1 1,3		;word 2 of arg 2	mov 0 3	lda 0 1,3		;word 2 of arg 1	addz 1 0		;Sets carry if overflow	sta 0 1,3		;Save word 2 of result	lda 0 0,3		;word 1 of arg 1	lda 1 @2,2		;word 1 of arg 2	mov 0 0 szc	 inc 1 1	add 1 0	sta 0 0,3		;Save word 1 of result
	jmp done; Miscellaneous
; DisableInterrupts() - No interrupts take until enabled;	returns true if interrupts were on
.DisableInterrupts:	dirsfalse:	 mkzero 0 0 skp		; offtrue:	 mkminusone 0 0		; on
	jmp 1,3

; EnableInterrupts() - Let interrupts take
.EnableInterrupts:	eir
	jmp 1,3
; StartIO(ac0) - access to the SIO instruction.StartIO: sio;	jmp 1,3		; fall through; Following 3 (4?) routines may be invoked by the CALL mechanism; Idle() - called by OS when waiting for something.Noop:.Idle:	jmp 1,3done:	lda 3 1,2	jmp 1,3; TruePredicate() - returns BCPL true.TruePredicate:	jmp true	lda 3 1,2	jmp true; FalsePredicate() - returns BCPL false.FalsePredicate:	jmp false	lda 3 1,2	jmp false

; table to convert from bit number to bit position
.oneBits:	100000
	40000
	20000
	10000
	4000
	2000
	1000
	400
	200
	100
	40
	20
	10
	4
	2
	1

; free page FID and FP -- because they are both 3 -1's, they point; to the same place.  They are given different names to aid documentation
.freePageFid:	-1
	-1
	-1
	.end