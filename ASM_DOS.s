
;--------------------------------------------------------------
BLoad:

;A0 name of file
;A1 buffer
;D0 size to read
;->D0 size of read bytes

	movem.l	d1-d2/a2-a3,-(sp)

;--- Open(file,MODE_OLDFILE) ---
	move.l	a0,d1
	moveq	#100,d2
	move.l	4.w,a6	; DOS LIBRARY
	jsr	-30(a6)	; _LVOOPEN
	tst.l	d0
	beq.s	.error

	move.l	d0,d3

;--- Read(handle,buffer,size) ---
	move.l	d3,d1
	move.l	a1,d2
	move.l	d0,-(sp)
	move.l	(sp)+,d3
	move.l	d3,d3
	jsr	-42(a6)	; _LVOREAD

	move.l	d0,d4

;--- Close(handle) ---
	move.l	d3,d1
	jsr	-36(a6)	; _LVOCLOSE

	move.l	d4,d0
	bra.s	.done

.error:
	moveq	#-1,d0

.done:
	movem.l	(sp)+,d1-d2/a2-a3
	rts
;--------------------------------------------------------------
AllocMem:

;D0 size to alloc memory
;D1 type of memory
;->D0 pointer to memory block

	move.l	4.w,a6
	jsr	-198(a6)	;_LVOAllocMem
	rts
;--------------------------------------------------------------
FreeMem:
;A1 pointer of block memory
;D0 size

	move.l	4.w,a6
	jsr	-210(a6)	; _LVOFreeMem
	rts
;--------------------------------------------------------------
