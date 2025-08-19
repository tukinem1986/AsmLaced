	bsr OsStore
	bsr InitPlanes
	bsr InitCopJumps

	move.l #Copper2,$dff080
	move.w #$8180,$dff096

;--------------------------------------------------------------
;--------------------------------------------------------------
MAINLOOP:

	bsr VBlank
MouseWait:
	btst #6,$bfe001
	bne MouseWait

	bsr OsRestore
	rts
;--------------------------------------------------------------
;--------------------------------------------------------------
InitPlanes:
	move.l #RAW,D0
	move.l #Copper1,A0
	adda.l #48,A0

;LINIE PARZYSTE
	move.w D0,6(A0)
	swap D0
	move.w D0,2(A0)
	swap D0

;LINIE NIEPARZYSTE
	move.l #Copper2,A1
	add.l #80,D0
	move.w D0,6(A1)
	swap D0
	move.w D0,2(A1)
	rts

;--------------------------------------------------------------

InitCopJumps:

	move.l #Copper1,D0
	move.w D0,cop1jmp+6
	swap D0
	move.w D0,cop1jmp+2


	move.l #Copper2,D1
	move.w D1,cop2jmp+6
	swap D1
	move.w D1,cop2jmp+2
	rts
;--------------------------------------------------------------
OsStore
	move.l #0,$dff0a0
	move.l #0,$dff0b0
	move.w #$3,$dff096
	move.l 4,a6
	lea gfxName(pc),a1
	jsr -408(a6)
	move.l d0,gfxBase
	move.l d0,a6
	move.l $22(a6),osOldView
	jsr -456(a6)
	jsr -228(a6)
	sub.l a1,a1
	jsr -222(a6)
	jsr -270(a6)
	jsr -270(a6)
	move.w $dff002,d0
	or.w #$8000,d0
	move.w d0,osOldDma
	rts
;--------------------------------------------------------------
OsRestore
	move.l #Copper0,$dff080
	move.w #0,$dff088
	bsr VBlank
	move.w osOldDma,$dff096
	move.l gfxBase,a6
	jsr -228(a6)
	jsr -462(a6)
	move.l osOldView,a1
	jsr -222(a6)
	jsr -270(a6)
	jsr -270(a6)
	move.l $26(a6),$dff080
	move.l 4,a6
	move.l gfxBase,a1
	jsr -414(a6)
	rts
;--------------------------------------------------------------
VBlank
	lea $dff004,a0
.V1
	lsr (a0)
	bcc.b .V1
.V2
	lsr (a0)
	bcs.b .V2
	rts
;--------------------------------------------------------------

gfxName: dc.b "graphics.library",0
	even
gfxBase: dc.l 0
osOldView: dc.l 0
osOldDma: dc.w 0
	Section ChipRAM,DATA_C

Copper0: dc.l 0

Copper1:

; NTSC
; dc.l $008e2c81,$0090f4c1
; dc.l $0092003c,$009400d4

	dc.l $008e2c81,$00902cc1 ;DIWSTRT & DIWSTOP
	dc.l $0092003c,$009400d4 ;DDFSTRT & DDFSTOP
	dc.l $01fc0000 ;FMODE
	dc.l $00960020 ;DMA
	dc.l $01020000,$01040000 ;BPLCON1 & BPLCON2
	dc.l $01080050,$010a0050 ;BPL1MOD & BPL2MOD
	dc.l $01800000,$01820880 ;COL0 & COL1
	dc.l $00e00000,$00e20000 ;BITPLAN 1
	dc.l $2c01fffe
	dc.l $01009204 ;BPLCON0 1 bitplan+hires+interlaced
	dc.l $ffdffffe ;LINE $FF
	dc.l $2c01fffe ;CZEKAM NA LINIE 256+44

cop2jmp:dc.l $00800000 ;URUCHAMIAM DRUGA COPPERLISTE
	dc.l $00820000 ;
	dc.l $fffffffe ;KONIEC

Copper2:
	dc.l $00e00000,$00e20000
	dc.l $2c01fffe
	dc.l $01009204
	dc.l $ffdffffe
	dc.l $2c01fffe
cop1jmp:dc.l $00800000
	dc.l $00820000
	dc.l $fffffffe


RAW: IncBin "DHC:AsmLaced/laced.raw"
