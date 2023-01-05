
; BcplTricks.asm; Copyright Xerox Corporation 1979; Last modified March 1, 1980  5:19 PM by BoggscallersFrame = 0savedPC = 1temp = 2extraArguments = 3getframe = 370return = 366
.ent FrameSize, MyFrame.ent CallersFrame, FramesCaller
.ent CallFrame, GotoFrame
.ent CoCall, CoReturn
.ent ReturnTo, ReturnFrom.ent GotoLabel, RetryCall
	.srel
FrameSize:	.FrameSize
MyFrame:	.MyFrame
CallersFrame:	.CallersFrameFramesCaller:	.FramesCaller
CallFrame:	.CallFrame
GotoFrame:	.GotoFrame
CoCall:		.CoCall
CoReturn:	.CoReturn
ReturnTo:	.ReturnToReturnFrom:	.ReturnFromGotoLabel:	.GotoLabelRetryCall:	.RetryCall

	.nrel
; FrameSize(proc) returns the frame size required by proc.
.FrameSize:	sta 3 savedPC,2
	mov 0 3
	lda 0 2,3
	jmp Done
; MyFrame() returns pointer to current fram.
.MyFrame:	mov 2 0
	jmp 1,3
; CallersFrame([f]) returns pointer to frame that calls f.; Default f=current frame
.CallersFrame:	sta 3 savedPC,2	lda 1 0,3		;get number of arguments	snz 1 1	 mov 2 0		;use present frame	mov 0 3	lda 0 callersFrame,3	jmp Done; FramesCaller(foo) returns the address to which the caller of; the frame foo sent control, provided that he made the call; with a jsris or jsrii, and that there has been no monkey-business; with the frame subsequently.; If the call was not made with a jsris or jsrii it returns 0.; If foo is omitted it defaults to the caller's frame..FramesCaller:	sta 3 savedPC,2	lda 1 0,3	snz 1 1			; default the argument?	 mov 2 0	mov 0 3			; 3 has frame in question	lda 3 callersFrame,3	; get frame of caller	sta 3 temp,2		; save the frame in temp; compute the address of the jsrxx instruction, which is savedPC-1	lda 3 savedPC,3; find out what the opcode is	lda 0 -1,3	lda 1 cLmask	and 1 0	lda 1 opJsris	se 0 1	 jmp NotJsris; calling instruction was jsris	lda 0 -1,3	lda 3 temp,2	inc 3 3			; bump to make look like pc.	jmp FcFinishUpNotJsris: lda 1 opJsrii	se 0 1	 jmp NotJsrii; calling instruction was jsrii	lda 0 -1,3FcFinishUp:	lda 1 cRmask	and 1 0; the next three instructions extend the sign of the address field, now in 0	inczr 1 1	andzl 0 1	sub 1 0; now add in the base (PC or frame) specified by the opcode	add 0 3			; address of word +1	lda 0, @-1,3		; go indirect through static locn	jmp DoneNotJsrii:  mkzero 0 0	; return zero if can't recognize opcode	jmp DonecLmask:		177400cRmask:		377opJsris:	jsris 0opJsrii:	jsrii .

; CallFrame(destframe[, arg 1[, arg 2]]); Sends control to the specified frame and links it back to this one.
.CallFrame:	sta 3 savedPC,2
	mov 0 3
	sta 2 callersFrame,3
Callf1:	mov 1 0
	lda 1 extraArguments,2
Callf2:	mov 3 2Done:
	lda 3 savedPC,2
	jmp 1,3
; GotoFrame(destframe[, arg 1[, arg 2]])
; Just like CallFrame, but doesn't plant the return link.; This is like Mesa's transfer.
.GotoFrame:	sta 3 savedPC,2
	mov 0 3
	jmp Callf1

; CoCall(a, b) = CallFrame(MyFrame()>>F.callersFrame, a, b)
.CoCall:	sta 3 savedPC,2
	lda 3 callersFrame,2
	sta 2 callersFrame,3
	jmp Callf2
; CoReturn(a, b)
; Just like CoCall, but doesn't plant the return link
.CoReturn:	sta 3 savedPC,2
	lda 2 callersFrame,2	jmp Done

; ReturnTo(label); Does a return to the specified label
.ReturnTo:	lda 2 callersFrame,2
	mov 0 3
	jmp 0,3; GotoLabel(frame, label, v); Sends control to the specified label in the specified frame,; and passes v in AC0.GotoLabel:	mov 0 3	lda 0 extraArguments,2	mov 3 2	mov 1 3	jsr 0,3	;in case proc head, must find #args in @ac3	 1; RetryCall(p1, p2); Repeats the call which appears to have given control to the caller; of RetryCall with p1 and p2 as the first two arguments, and the other; arguments unchanged.RetryCall:	nop	lda 2 callersFrame,2	lda 3 savedPC,2	jmp -1,3
; ReturnFrom(fnOrFrame, v); Looks for a frame f which is either equal to fnOrFrame,; or has FramesCaller(f) equal to fnOrFrame.  It then cuts back; the stack to f and simulates a return from f with v as the value.; If it runs into trouble it returns 0; local variables for this routinefnOrFrame = 4v = 5nextFrame = 6count = 7.ReturnFrom:	sta 3 savedPC,2	jsr @getframe	 count+1	 nop	lda 0 cRmask	sta 0 count,2	mov 2 3; the frame we just looked at is in 3RfLoop:	lda 0 callersFrame,3; if we've looked at too many frames, give up	dsz count 2; if the next frame is 0, give up	snz 0 0	 jmp RfFailed; if the next frame is equal to the last one, give up	sne 0 3	 jmp RfFailed	sta 0 nextFrame,2; is the next frame equal to fnOrFrame?	lda 1 fnOrFrame,2	sne 0 1	 jmp FoundFrame; is its caller equal to fnOrFrame?	jsr .FramesCaller	 1	lda 1 fnOrFrame,2	sne 0 1	 jmp FoundFrame; it's not the one we want; charge on	lda 3 nextFrame,2	jmp RfLoopFoundFrame: lda 0 v,2	lda 2 nextFrame,2	lda 2 callersFrame,2	;get his caller (return FROM him)	jmp DoneRfFailed: mkzero 0 0	jsr @return
	.end