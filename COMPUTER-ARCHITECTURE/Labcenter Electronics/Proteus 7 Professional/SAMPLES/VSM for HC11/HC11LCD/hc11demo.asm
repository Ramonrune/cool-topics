;HC11 Pixel Addressable LCD Demo

#include ioregs.inc

;Reset Vectors etc.
                org $FFFE
                dw start

                org $F000

;Initialization code:
start:          lds #$FF
		ldx #$1000

		jsr lcdinit

;Reset the graphics home address:
main:		ldd #$0400			
		jsr wrdouble
		ldaa #LCD_GFXHOME
		jsr wrcmd

;Write the Labcenter logo to the LCD graphics area
;This is performed in auto-write mode for maximum speed.
		ldd #$0400
		jsr wraddr
		ldaa #LCD_AUTOWRITE
		jsr wrcmd
		ldy #lxlogo
loop1		ldaa 0,Y
		jsr awdata
		iny
		cpy #presents
		bne loop1

		jsr delay

;Now the word 'presents'. The LCD is still in auto-write mode.
loop2		ldaa 0,Y
		jsr awdata
		iny
		cpy #vsmlogo
		bne loop2

		jsr delay


;Cancel auto-write mode, then re-start it at the top of the display:
		jsr awreset
		ldd #$0400
		jsr wraddr
		ldaa #LCD_AUTOWRITE
		jsr wrcmd

;Now the VSM logo is transferred:
		ldy #vsmlogo
loop3		ldaa 0,Y
		jsr awdata
		iny
		cpy #vsmlogoend
		bne loop3
		jsr awreset

		jsr delay

;Finally, we scroll it off the screen by moving the GFXHOME address
;downwards by one row (16 bytes) at a time.
		ldd #$0400
loop4a		psha
		pshb
		jsr wrdouble
		ldaa #LCD_GFXHOME
		jsr wrcmd
		ldd #1000
loop4b		subd #1
		bne loop4b
		pulb
		pula
		addd #16
		cpd #$0800
		bne loop4a

		jsr delay

;Clear the screeen so that we are ready to start again.
;The graphics screen occupies 1k of memory.
		ldd #$0400
		jsr wraddr
		ldaa #LCD_AUTOWRITE
		jsr wrcmd
		ldy #0
loop5		clra
		jsr awdata
		iny
		cpy #$0400
		bne loop5
		jsr awreset

;And round we go again...
		jmp main

;Subroutine to create a pause. 
delay:		ldd #0
dloop		subd #1
		nop
		nop
		nop
		nop
		nop
		nop
		bne dloop
		rts
		


;The Labcenter Logo bitmap
lxlogo:		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $1E,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $1E,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $1E,$00,$00,$40,$00,$00,$00,$00,$00,$00,$20,$00,$00,$00,$00,$00
		db $1E,$00,$00,$40,$00,$00,$00,$00,$00,$00,$20,$00,$00,$00,$00,$00
		db $1E,$00,$00,$40,$00,$00,$00,$00,$00,$00,$20,$00,$00,$00,$00,$00
		db $1E,$07,$FE,$7F,$E0,$3F,$C0,$FE,$03,$F8,$3F,$C0,$3F,$C0,$FF,$00
		db $1E,$08,$02,$40,$10,$40,$01,$01,$04,$04,$20,$00,$40,$40,$80,$80
		db $1E,$08,$02,$40,$10,$80,$02,$00,$88,$02,$20,$00,$40,$21,$00,$80
		db $1E,$10,$02,$40,$08,$80,$02,$00,$88,$02,$20,$00,$80,$12,$00,$40
		db $1E,$10,$02,$40,$09,$00,$04,$00,$88,$01,$20,$00,$80,$12,$00,$40
		db $1E,$10,$02,$40,$09,$00,$07,$FF,$D0,$01,$20,$00,$FF,$F2,$00,$00
		db $1E,$10,$02,$40,$09,$00,$04,$00,$10,$01,$20,$04,$80,$02,$00,$00
		db $1E,$10,$02,$40,$08,$80,$02,$00,$10,$01,$20,$04,$80,$02,$00,$00
		db $1E,$08,$02,$40,$10,$80,$02,$00,$10,$01,$10,$08,$40,$02,$00,$00
		db $1E,$08,$02,$40,$10,$40,$01,$00,$10,$01,$10,$18,$40,$02,$00,$00
		db $1E,$06,$02,$40,$60,$30,$00,$C0,$10,$01,$0C,$60,$30,$02,$00,$00
		db $1E,$01,$FE,$7F,$80,$0F,$E0,$3F,$90,$01,$03,$80,$0F,$E2,$00,$00
		db $1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $1E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8
		db $1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8
		db $1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8
		db $1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $07,$80,$20,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $04,$00,$20,$06,$00,$60,$0E,$03,$00,$38,$03,$80,$10,$06,$00,$70
		db $0F,$00,$40,$0F,$00,$80,$08,$06,$00,$48,$06,$80,$20,$08,$00,$60
		db $08,$00,$40,$08,$00,$80,$08,$04,$00,$48,$04,$80,$20,$08,$00,$90
		db $0F,$00,$40,$0E,$00,$C0,$0C,$04,$00,$70,$04,$80,$20,$0C,$00,$70
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
lxlogoend

;'Presents'
presents	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$E0,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$E0,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$E0,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$C0,$00,$00
		db $00,$07,$EF,$07,$EE,$07,$E0,$1F,$A0,$FC,$1F,$BE,$3F,$F0,$FD,$00
		db $00,$07,$DF,$87,$DE,$1F,$F0,$7F,$C3,$FE,$1F,$7F,$3F,$F3,$FE,$00
		db $00,$0F,$FF,$CF,$FC,$7F,$F8,$FF,$CF,$FF,$3F,$FF,$7F,$E7,$FE,$00
		db $00,$0F,$FF,$8F,$FC,$FF,$F9,$FF,$9F,$FF,$3F,$FF,$7F,$EF,$FC,$00
		db $00,$0F,$FF,$8F,$FC,$FD,$F9,$F9,$1F,$BF,$3F,$FF,$FF,$EF,$C8,$00
		db $00,$1F,$9F,$9F,$C9,$FF,$F9,$FE,$3F,$FF,$7E,$7E,$3F,$0F,$F0,$00
		db $00,$1F,$9F,$9F,$81,$FF,$F8,$FF,$BF,$FF,$7E,$7E,$3F,$07,$FC,$00
		db $00,$1F,$FF,$1F,$81,$F8,$02,$1F,$3F,$00,$7E,$7E,$3F,$10,$F8,$00
		db $00,$3F,$FF,$3F,$01,$FF,$F7,$FF,$3F,$FE,$FC,$FC,$7E,$3F,$F8,$00
		db $00,$3F,$FE,$3F,$01,$FF,$EF,$FE,$3F,$FC,$FC,$FC,$7E,$7F,$F0,$00
		db $00,$3E,$FC,$3F,$00,$FF,$DF,$FC,$1F,$F8,$FC,$FC,$7E,$FF,$E0,$00
		db $00,$7E,$78,$7E,$00,$7F,$07,$F0,$0F,$E1,$F9,$F8,$FC,$3F,$80,$00
		db $00,$7E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $01,$F8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
presentsend

;The VSM Logo bitmap
vsmlogo:	db $FF,$FF,$E1,$FF,$FF,$C0,$0F,$FF,$FC,$01,$FF,$FF,$80,$3F,$FF,$E0
		db $F7,$F7,$F1,$F7,$F7,$F0,$75,$55,$77,$81,$F7,$F7,$C0,$77,$F7,$F0
		db $7F,$FF,$FF,$FF,$FF,$F8,$FF,$FF,$FF,$E1,$FF,$FF,$E0,$7F,$FF,$F8
		db $55,$55,$7F,$55,$57,$FF,$55,$55,$55,$71,$55,$55,$70,$D5,$55,$7C
		db $6A,$AA,$FE,$AA,$AB,$FE,$AA,$AA,$AA,$F9,$AA,$AA,$F9,$AA,$AA,$FE
		db $55,$55,$75,$55,$57,$7D,$55,$55,$55,$7F,$55,$55,$77,$55,$55,$77
		db $2A,$AA,$BE,$AA,$AF,$FE,$AA,$AA,$AA,$FF,$AA,$AA,$BE,$AA,$AA,$FF
		db $34,$54,$7C,$54,$57,$FC,$54,$54,$54,$FF,$54,$54,$5C,$54,$54,$7F
		db $2A,$AA,$BA,$AA,$AF,$FA,$AA,$AA,$AA,$FF,$AA,$AA,$AA,$AA,$AA,$FF
		db $00,$00,$10,$00,$0F,$F0,$00,$00,$00,$F7,$00,$00,$00,$00,$00,$77
		db $1A,$8A,$9A,$8A,$8F,$FA,$8A,$8A,$8B,$FF,$8A,$8A,$8A,$8A,$8A,$FF
		db $10,$00,$10,$00,$0F,$F0,$00,$1F,$01,$FF,$00,$00,$00,$00,$00,$7F
		db $02,$22,$22,$22,$3F,$E2,$22,$3F,$E3,$FF,$22,$22,$22,$22,$22,$7F
		db $00,$00,$00,$00,$1F,$60,$00,$07,$63,$7F,$00,$00,$00,$00,$00,$77
		db $0A,$AA,$AA,$AA,$BF,$EA,$AA,$AF,$EB,$FF,$AA,$AA,$AA,$AA,$AA,$FF
		db $08,$40,$40,$40,$5F,$E0,$40,$40,$F3,$FF,$40,$40,$40,$40,$40,$7F
		db $06,$AA,$AA,$AA,$BF,$FA,$AA,$AA,$BF,$FF,$AA,$AA,$AA,$AA,$AA,$FF
		db $04,$10,$10,$10,$3F,$F0,$10,$10,$17,$F7,$10,$10,$10,$10,$10,$77
		db $06,$AA,$AA,$AA,$BF,$FA,$AA,$AA,$AF,$FF,$AA,$AA,$AA,$AA,$AA,$FF
		db $00,$44,$44,$44,$7F,$FC,$44,$44,$45,$FF,$44,$44,$44,$44,$44,$7F
		db $02,$AA,$AA,$AA,$FF,$FA,$AA,$AA,$AB,$FD,$AA,$AA,$AA,$AA,$AA,$FF
		db $03,$11,$11,$11,$7F,$75,$11,$11,$11,$75,$11,$11,$11,$11,$11,$77
		db $02,$AA,$AA,$AA,$FF,$F6,$AA,$AA,$AA,$FD,$AA,$AA,$AA,$AA,$AA,$FF
		db $01,$55,$55,$55,$FF,$F7,$D5,$55,$55,$7D,$55,$55,$D5,$D5,$55,$7F
		db $01,$AA,$AA,$AA,$FF,$E7,$EA,$AA,$AA,$FF,$AA,$AA,$EA,$EA,$AA,$FF
		db $01,$55,$55,$55,$F7,$E5,$F5,$55,$55,$77,$55,$55,$D5,$D5,$55,$77
		db $00,$AE,$AE,$AF,$FF,$EE,$FE,$AE,$AE,$BF,$AE,$AE,$EF,$EE,$AE,$FF
		db $00,$D5,$55,$55,$FF,$CD,$FF,$55,$55,$7F,$55,$55,$F7,$D5,$55,$7F
		db $00,$AB,$AB,$AB,$FF,$CB,$BF,$AB,$AB,$BF,$AB,$AB,$FF,$EB,$AB,$FF
		db $00,$55,$55,$57,$7F,$55,$57,$55,$55,$7F,$55,$55,$77,$55,$55,$77
		db $00,$7E,$FE,$FF,$FF,$DE,$FE,$FE,$FE,$FF,$FE,$FE,$FF,$FE,$FE,$FF
		db $00,$55,$55,$57,$FF,$B5,$55,$55,$55,$7F,$55,$55,$FF,$D5,$55,$7F
		db $00,$7B,$BB,$BF,$FF,$BB,$BB,$BB,$BB,$FF,$BB,$BB,$FF,$FB,$BB,$FF
		db $00,$35,$55,$57,$F7,$B5,$55,$55,$55,$77,$55,$55,$F7,$D5,$55,$77
		db $00,$3F,$FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FF,$FF
		db $00,$35,$55,$57,$FF,$55,$55,$55,$55,$FF,$55,$55,$FE,$D5,$55,$7F
		db $00,$1F,$FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FF,$FF
		db $00,$15,$55,$5F,$7E,$55,$55,$55,$57,$7F,$55,$55,$77,$55,$55,$77
		db $00,$1F,$FF,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $00,$1D,$DD,$DF,$FE,$3F,$DD,$DD,$FF,$FF,$DD,$DD,$FF,$DD,$DD,$FF
		db $00,$0F,$FF,$FF,$FE,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $00,$07,$F7,$F7,$F4,$03,$F7,$F7,$FF,$FF,$F7,$F7,$F7,$F7,$F7,$F7
		db $00,$03,$FF,$FF,$FC,$00,$FF,$FF,$FF,$FE,$FF,$FF,$FF,$7F,$FF,$FF
		db $00,$00,$FF,$FF,$FC,$00,$1F,$FF,$FF,$F8,$3F,$FF,$FF,$1F,$FF,$FF
		db $00,$00,$3F,$FF,$F8,$00,$0F,$FF,$FF,$F0,$1F,$FF,$FF,$0F,$FF,$FF
		db $00,$00,$07,$77,$70,$00,$01,$77,$7F,$00,$04,$71,$77,$03,$55,$77
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $20,$C0,$00,$00,$81,$E0,$00,$00,$00,$00,$60,$C0,$04,$05,$40,$00
		db $21,$00,$40,$00,$82,$10,$00,$40,$00,$00,$60,$C0,$04,$05,$00,$00
		db $11,$4E,$F4,$9E,$82,$04,$7C,$F7,$9E,$E0,$51,$4E,$3C,$F5,$4F,$3C
		db $11,$4A,$44,$92,$81,$E4,$62,$44,$91,$20,$51,$51,$44,$95,$49,$24
		db $0A,$48,$44,$9E,$80,$12,$A0,$47,$91,$20,$4A,$51,$44,$F5,$49,$24
		db $0A,$48,$44,$92,$82,$12,$BE,$44,$11,$20,$4A,$51,$44,$85,$49,$24
		db $0A,$48,$54,$92,$82,$12,$A2,$54,$91,$20,$4A,$51,$44,$95,$49,$24
		db $04,$48,$77,$9E,$81,$E1,$3E,$73,$91,$20,$44,$4E,$3C,$75,$49,$3C
		db $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04
		db $00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$38
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

vsmlogoend

;************************************************************************
;**** Pixel Addressable LCD Package ****
******************;*********************

;LCD Registers addresses
LCD_STATUS	equ 	5
LCD_COMMAND	equ	6
LCD_READ	equ	1
LCD_WRITE	equ	2

;Common LCD Commands
LCD_CURSOR	equ	$21
LCD_OFFSET   	equ	$22
LCD_ADDRESS	equ	$24
LCD_TEXTHOME	equ	$40
LCD_TEXTAREA    equ	$41
LCD_GFXHOME	equ	$42
LCD_GFXAREA	equ	$43
LCD_ORMODE	equ	$80
LCD_XORMODE	equ	$81
LCD_ANDMODE	equ	$83
LCD_ATTRMODE	equ	$84
LCD_DISPLAY	equ	$90
LCD_CLINES	equ	$A0
LCD_AUTOWRITE	equ	$B0
LCD_AUTOREAD	equ	$B1
LCD_AUTORESET   equ     $B2
LCD_WRITEINC	equ	$C0
LCD_READINC	equ	$C1
LCD_WRITEDEC	equ	$C2
LCD_READDEC	equ	$C3
LCD_SCREENPEEK	equ	$E0
LCD_SCREENCOPY  equ	$E8
LCD_BITSET	equ	$F0

;Initialize LCD package for 128x75 pixel display
lcdinit		ldaa #2				;STRB active low, STRA on rising edges			
		staa PIOC,X

		ldaa #$FF			;Start with PORTB high.
		staa PORTB,X

		ldd #0				;Set Text base address
		bsr wrdouble
		ldaa #LCD_TEXTHOME
		bsr wrcmd

		ldd #16				;16 bytes per text row
		bsr wrdouble
		ldaa #LCD_TEXTAREA
		bsr wrcmd

		ldd #$0400			;Set Graphics base address
		bsr wrdouble
		ldaa #LCD_GFXHOME
		bsr wrcmd

		ldd #16				;16 bytes per graphics row
		bsr wrdouble
		ldaa #LCD_GFXAREA
		bsr wrcmd

		ldd #$0800			;Set CGRAM base address
		bsr wrdouble
		ldaa #LCD_OFFSET
		bsr wrcmd

		ldaa #LCD_DISPLAY+$0C		;Enable text, graphics, no cursor.
		bsr wrcmd
		rts

;Set the address pointer
wraddr		bsr wrdouble
		ldaa #LCD_ADDRESS
		bra wrcmd

;Write ASCIIZ string at Y to LCD
wrstr		ldaa 0,Y			;Read next character
		beq wsdone			;rtsurn if zero		
		suba #$20			;Display uses non ASCII charset.
		bsr wrdata			;Send it to the display as data
		ldaa #LCD_WRITEINC		;Write and increment
		bsr wrcmd
		iny				;Loop for next character
		bra wrstr
wsdone		rts

;Write command
wrcmd		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
wrcmd1		stab PORTB,X	
		brclr PORTCL,X,1,wrcmd1		;Bit 0 must be set
		staa PORTC,X
		ldab #$FF
		stab DDRC,X
		ldab #LCD_COMMAND
		stab PORTB,X
		rts

;Write double data parameter (B=data1, A=data2)
;Use for setting graphics/text home addresses etc.
wrdouble	psha
		tba
		bsr wrdata
		pula		 

;Write single data parameter
wrdata		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
wrdata1		stab PORTB,X	
		brclr PORTCL,X,2,wrdata1	;Bit 1 must be set
		staa PORTC,X
		ldab #$FF
		stab DDRC,X
		ldab #LCD_WRITE
		stab PORTB,X
		rts


;Write autodata value:
awdata		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
wrauto1		stab PORTB,X	
		brclr PORTCL,X,8,wrauto1	;Bit 3 must be set
		staa PORTC,X
		ldab #$FF
		stab DDRC,X
		ldab #LCD_WRITE
		stab PORTB,X
		rts

;Reset autowrite:
awreset		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
awr1		stab PORTB,X	
		brclr PORTCL,X,8,awr1		;Bit 3 must be set
		ldaa #LCD_AUTORESET
		staa PORTC,X
		ldab #$FF
		stab DDRC,X
		ldab #LCD_COMMAND
		stab PORTB,X
		rts

;Read autodata
rdauto		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
rdauto1		stab PORTB,X	
		brclr PORTCL,X,4,rdauto1	;Bit 2 must be set
		ldab #LCD_READ
		stab PORTB,X
		ldaa PORTCL
		rts

;Reset autoread:
arreset		clr DDRC,X			;Prepare to read
 		ldab #LCD_STATUS		;CD high, RD low
arr1		stab PORTB,X	
		brclr PORTCL,X,4,arr1		;Bit 2 must be set
		ldaa #LCD_AUTORESET
		staa PORTC,X
		ldab #$FF
		stab DDRC,X
		ldab #LCD_COMMAND
		stab PORTB,X
		rts
