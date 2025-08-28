
	section intro,CODE

;--------------------------------------------------------------
; ALLOCMEM CHIP RAM CODE
;--------------------------------------------------------------
; 33*4B + 30 720B
	move.l	#30852,d0	;size
	moveq	#2,d1		;chipram
	bsr	AllocMem
	move.l	d0,a3		;chipPtr in A3
;--------------------------------------------------------------
; COPY DATA TO CHIP RAM
	lea	Copper0(pc),a0
	move.l	a3,a1
	move.l	#7713-1,d7
CopyLoop:
	move.l	(a0)+,(a1)+
	dbf	d7,CopyLoop
;--------------------------------------------------------------



	
	bsr	OsStore
	bsr	InitPlanes
	move.l	a3,d0
	add.l	#12,d0
	move.l	d0,$dff080
	move.l	#290,d7
StartLoop:
	bsr	VWait
	addq.b	#1,116(a3)
	tst.b	116(a3)
	beq	.Dwn
	btst	#6,$bfe001
	beq	EndLoop
	dbf	d7,StartLoop
	bra	MAINLOOP
.Dwn
	move.l	#$ffdffffe,112(a3)
	dbf	d7,StartLoop


MAINLOOP:
	move.l	#290,d7
	bsr	VWait
	
CheckMouse:
	btst	#6,$bfe001
	beq	EndLoop



	bra	MAINLOOP

EndLoop:
	bsr	VWait
	subq.b	#1,116(a3)
	tst.b	116(a3)
	beq	.Up
	dbf	d7,EndLoop
	bra	ENDPROG
.Up
	move.l	#$01fe00,112(a3)
	subq.b	#1,116(a3)
	dbf	d7,EndLoop



;--------------------------------------------------------------
ENDPROG:
	bsr	OsRestore
	
;FREE MEM FROM CHIP RAM
	move.l	a3,a1
	move.l	#30852,d0
	bsr	FreeMem
	rts
;--------------------------------------------------------------






	include "ASM_DOS.s"

;--------------------------------------------------------------
MathY:
	addq.w	#1,Y
	rts
;--------------------------------------------------------------
ChangeRaster:
	tst.b	Y+1
	beq	.DownLines
	move.b	Y+1,116(a3)
	rts
	
.DownLines:
	move.l	#$ffdffffe,112(a3)
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




InitPlanes:
	move.l	a3,a0		;planes
	adda.l	#56,a0
	move.l	a3,d0		;RAW
	add.l	#132,d0
	moveq	#2,d1
SetPlanes:	
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	adda.l	#8,a0
	dbf	d1,SetPlanes
	rts

;--------------------------------------------------------------
OsStore:
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
	move.l	a3,$dff080
	move.w	d0,$dff088
	bsr	VWait
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



Copper0:
	dc.l	$01800000
	dc.l	$01000000
	dc.l	$fffffffe

Copper:
	dc.l	$01fc0000
	dc.l	$008e2c81
	dc.l	$00902cc1
	dc.l	$00920038
	dc.l	$009400d0
	dc.l	$01003000
	dc.l	$01020000,$01040000
	dc.l	$01080000,$010a0000
	dc.l	$00960020
Planes:					;56
	dc.l	$00e00000,$00e20000
	dc.l	$00e40000,$00e60000
	dc.l	$00e80000,$00ea0000
Palette:				;80
col0:	dc.l	$01800110
col1:	dc.l	$01820220
col2:	dc.l	$01840330
col3:	dc.l	$01860460
col4:	dc.l	$01880580
col5:	dc.l	$018a06a0
col6:	dc.l	$018c07c0
col7:	dc.l	$018e08e0
					;112
L212:	dc.l	$01fe0000
Raster:	dc.l	$0001fffe,$0108ffd8,$010affd8
	dc.l 	$fffffffe

RAW:	incbin "DHC:awesomegamesintros/awesomegames2.raw"
EndBlock:
