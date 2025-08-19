	bsr	OsStore
	bsr	InitPlanes
	bsr	InitCopJumps
	bsr	InitColors


		
	move.l	#Copper1,$dff080

;--------------------------------------------------------------
;--------------------------------------------------------------
MAINLOOP:

	bsr	VBlank
MouseWait:
	btst	#6,$bfe001
	bne	MouseWait

	bsr	OsRestore
	rts
;--------------------------------------------------------------
;--------------------------------------------------------------
InitPlanes:
	move.l	#RAW,D0
	moveq	#1,d7
	move.l	#Copper1,a0
	move.l	#Copper2,a1
.PlanesLoop:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#80,d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	adda.l	#8,a0
	adda.l	#8,a1
	add.l	#511*80,d0
	dbf	d7,.PlanesLoop
	rts
;--------------------------------------------------------------
InitCopJumps:
	move.w	#$50,$dff108		;BPL1MOD
	move.w	#$50,$dff10a		;BPL2MOD
	move.w	#$a204,$dff100		;BPLCON0
	move.w	#$2c81,$dff08e		;DIWSTRT
	move.w	#$2cc1,$dff090		;DIWSTOP
	move.w	#$0038,$dff092		;DDFSTRT
	move.w	#$00d0,$dff094		;DDFSTOP
	move.w	#$0000,$dff1fc		;FMODE
	move.w	#$0020,$dff096		;DMA
	

	move.l	#Copper1,D0
	move.l	#Copper2,D1
	move.w	D0,cop1jmp+6
	swap	D0
	move.w	D0,cop1jmp+2
	
	move.w	D1,cop2jmp+6
	swap	D1
	move.w	D1,cop2jmp+2
	rts
;--------------------------------------------------------------
InitColors:
	move.w	#$606,$dff180
	move.w	#$000,$dff182
	move.w	#$eee,$dff184
	move.w	#$24e,$dff186
	rts
;--------------------------------------------------------------
OsStore
	move.l	#0,$dff0a0
	move.l	#0,$dff0b0
	move.w	#$3,$dff096
	move.l	4,a6
	lea	gfxName(pc),a1
	jsr	-408(a6)
	move.l	d0,gfxBase
	move.l	d0,a6
	move.l	$22(a6),osOldView
	jsr	-456(a6)
	jsr	-228(a6)
	sub.l	a1,a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	move.w	$dff002,d0
	or.w	#$8000,d0
	move.w	d0,osOldDma
	rts
;--------------------------------------------------------------
OsRestore
	move.l	#Copper0,$dff080
	move.w	#0,$dff088
	bsr	VBlank
	move.w	osOldDma,$dff096
	move.l	gfxBase,a6
	jsr	-228(a6)
	jsr	-462(a6)
	move.l	osOldView,a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	move.l	$26(a6),$dff080
	move.l	4,a6
	move.l	gfxBase,a1
	jsr	-414(a6)
	rts
;--------------------------------------------------------------
VBlank
	lea	$dff004,a0
.V1
	lsr	(a0)
	bcc.b	.V1
.V2
	lsr	(a0)
	bcs.b	.V2
	rts
;--------------------------------------------------------------

gfxName:	dc.b "graphics.library",0
	even
gfxBase:	dc.l 0
osOldView:	dc.l 0
osOldDma:	dc.w 0
	Section ChipRAM,DATA_C

Copper0:	dc.l 0

Copper1:
	dc.l	$00e00000,$00e20000	;BITPLAN 1
	dc.l	$00e40000,$00e60000	;BITPLAN 2
cop2jmp:dc.l	$00800000		;COP2LCH
	dc.l	$00820000		;COP2LCL
	dc.l	$fffffffe		;END COPPERLIST

Copper2:
	dc.l	$00e00000,$00e20000
	dc.l	$00e40000,$00e60000
cop1jmp:dc.l	$00800000
	dc.l	$00820000
	dc.l	$fffffffe


RAW:	IncBin "DHC:AsmLaced/girl.raw"

