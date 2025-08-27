	bsr	OsStore
	bsr	InitPlanes
	bsr	InitCopper
	bsr	InitColors

	move.l	#Copper1,$dff080
	move.w	d0,$dff088
	move.l	#299,d7
StartLoop:
	bsr	VWait
	addq.b	#1,cop1ntsc+4
	addq.b	#1,cop2ntsc+4
	tst.b	cop1ntsc+4
	beq	.Dwn
	btst	#6,$bfe001
	beq	OsRestore
	dbf	d7,StartLoop
	bra	MAINLOOP
.Dwn
	move.l	#$ffdffffe,cop1ntsc
	move.l	#$ffdffffe,cop2ntsc
	dbf	d7,StartLoop


MAINLOOP:

	bsr	VWait
	
CheckMouse:
	btst	#6,$bfe001
	beq	End



	bra	MAINLOOP

End:
	move.l	#290,d7
EndLoop:
	bsr	VWait
	subq.b	#1,cop1ntsc+4
	subq.b	#1,cop2ntsc+4
	tst.b	cop1ntsc+4
	beq	.Up
	dbf	d7,EndLoop
	bra	OsRestore	;PROG END
.Up
	move.l	#$01fe00,cop1ntsc
	move.l	#$01fe00,cop2ntsc
	subq.b	#1,cop1ntsc+4
	subq.b	#1,cop2ntsc+4
	dbf	d7,EndLoop
	bra	OsRestore	;PROG END



;--------------------------------------------------------------
MathY:
	addq.w	#1,Y
	rts
;--------------------------------------------------------------
ChangeRaster:
	tst.b	Y+1
	beq	.DownLines
	move.b	Y+1,cop1ntsc+4
	move.b	Y+1,cop2ntsc+4
	rts
	
.DownLines:
	move.l	#$ffdffffe,cop1ntsc
	move.l	#$ffdffffe,cop2ntsc
	rts


;--------------------------------------------------------------
VWait:
	lea	$dff004,a0
.l1	lsr	(a0)
	bcc	.l1
.l2	lsr	(a0)
	bcs	.l2
	rts
;--------------------------------------------------------------
InitColors:
	move.w	#$100,$dff180
	move.w	#$321,$dff182
	move.w	#$531,$dff184
	move.w	#$742,$dff186
	move.w	#$963,$dff188
	move.w	#$a74,$dff18a
	move.w	#$c85,$dff18c
	move.w	#$864,$dff18e
	rts
;--------------------------------------------------------------


InitPlanes:
	move.l	#RAW,d0
	moveq	#3-1,d7
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
InitCopper:
	move.w	#$2c81,$dff08e	;DIWSTRT
	move.w	#$2ce1,$dff090	;DIWSTOP
	move.w	#$003c,$dff092	;DDFSTRT
	move.w	#$00d4,$dff094	;DDFSTOP
	move.w	#$0000,$dff1fc	;FMODE
	move.w	#$0020,$dff096	;DMA
	move.w	#$7fff,$dff09a	;INTENA
	move.w	#$7fff,$dff09c	;INTREQ
	move.w	#$b204,$dff100	;BPLCON0

	move.l	#Copper1,d0
	move.l	#Copper2,d1
	move.w	d0,cop1jmp+6
	swap	d0
	move.w	d0,cop1jmp+2

	move.w	d1,cop2jmp+6
	swap	d1
	move.w	d1,cop2jmp+2
	rts
;--------------------------------------------------------------
OsStore:
	move.l	4,a6
	jsr	-132(a6)
	move.w	$dff01c,d0
	or.w	#$8000,d0
	move.w	d0,osOldIntena
	
	move.l	#0,$dff0a0
	move.l	#0,$dff0b0
	move.w	#3,$dff096
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
OsRestore:
	move.l	#Copper0,$dff080
	move.w	#0,$dff088
	bsr	VWait
	move.w	osOldIntena(pc),$dff09a
	move.l	4,a6
	jsr	-138(a6)
	
	move.w	osOldDma(pc),$dff096
	move.l	gfxBase(pc),a6
	jsr	-228(a6)
	jsr	-462(a6)
	move.l	osOldView(pc),a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	move.l	$26(a6),$dff080
	move.l	4,a6
	move.l	gfxBase(pc),a1
	jsr	-414(a6)
	rts
;--------------------------------------------------------------


Y:		dc.w	0
gfxName:	dc.b	"graphics.library",0
	even
gfxBase:	dc.l	0
osOldView:	dc.l	0
osOldDma:	dc.w	0
osOldIntena:	dc.w	0


	Section	ChipRam,DATA_C

Copper0:
	dc.l	$01800000
	dc.l	$01000000
	dc.l	$fffffffe

Copper1:
	dc.l	$00e00000,$00e20000
	dc.l	$00e40000,$00e60000
	dc.l	$00e80000,$00ea0000
	dc.l	$01080050,$010a0050
	dc.l	$2c01fffe
cop1ntsc:
	dc.l	$01fe00
	dc.l	$0001ff00,$0108ffb0,$010affb0
cop2jmp:
	dc.l	$00800000
	dc.l	$00820000
	dc.l	$fffffffe
	
Copper2:
	dc.l	$00e00000,$00e20000
	dc.l	$00e40000,$00e60000
	dc.l	$00e80000,$00ea0000
	dc.l	$01080050,$010a0050
	dc.l	$2c01fffe
cop2ntsc:
	dc.l	$01fe00
	dc.l	$0001ff00,$0108ffb0,$010affb0
cop1jmp:
	dc.l	$00800000
	dc.l	$00820000
	dc.l 	$fffffffe

RAW:	incbin "DHC:awesomegamesintros/awesomegames3.raw"
