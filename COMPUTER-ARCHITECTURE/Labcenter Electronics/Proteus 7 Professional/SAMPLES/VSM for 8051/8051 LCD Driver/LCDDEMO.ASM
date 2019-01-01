; LCD Display Driver Demo.
; Timing code assumes 1.2MHz Clock

;LCD Registers addresses
LCD_CMD_WR	equ 	0
LCD_DATA_WR	equ	1
LCD_BUSY_RD	equ	2
LCD_DATA_RD	equ	3

;LCD Commands
LCD_CLS		equ	1
LCD_HOME	equ	2
LCD_SETMODE	equ	4
LCD_SETVISIBLE	equ	8
LCD_SHIFT	equ	16
LCD_SETFUNCTION	equ	32
LCD_SETCGADDR	equ	64
LCD_SETDDADDR	equ	128

;Reset vector
	org 0000h
	jmp start


;Start of the program
	org 0100h

string1a:db ' !! A M A Z I N G !! '
	 db 0
string1b:db '!! A M A Z I N G !! '
	 db 0
string2:db ' A virtual LM032L... '
	db 0

string3:db ' driven by a virtual '
	db 0
string4:db '   8051 processor!'
	db 0

start:	mov A,#038h
	call wrcmd

loop:	mov A,#LCD_SETVISIBLE+6 	;Make the display & blink visible:
	call wrcmd

	mov R7,#2
loop2: 
	mov DPTR,#string1a
	call wrstr

 	mov DPTR,#200
 	call wtms

	mov A,#LCD_CLS			;Clear screen
	call wrcmd

	mov DPTR,#string1b
	call wrstr

 	mov DPTR,#200
 	call wtms

	mov A,#LCD_CLS			;Clear screen
	call wrcmd

	djnz R7,loop2

	mov DPTR,#string1a
	call wrstr

 	mov DPTR,#400
 	call wtms

	mov A,#LCD_SETDDADDR+64
	call wrcmd

	mov DPTR,#string2
	call wrslow

 	mov DPTR,#200
 	call wtms

	mov A,#LCD_CLS			;Clear screen
	call wrcmd

	mov DPTR,#string3
	call wrslow

        mov A,#LCD_SETDDADDR+64
	call wrcmd

	mov DPTR,#string4
	call wrslow

	mov A,#LCD_SETVISIBLE+7		;Show the blink cursor as well.
	call wrcmd

 	mov DPTR,#2000
 	call wtms

	mov A,#LCD_CLS			;Clear screen
	call wrcmd

	jmp loop


;Sub routine to write null terminated string at DPTR in program ram.
wrstr:	mov R0,#LCD_DATA_WR
wrstr1:	clr A
	movc A,@A+DPTR
	jz wrstr2
	movx @R0,A
	call wtbusy
	inc DPTR
	push DPL
	push DPH
	pop DPH
	pop DPL	
	jmp wrstr1
wrstr2:	ret

;Sub routine to write null terminated string at DPTR in program ram. Slowly
wrslow:	mov R0,#LCD_DATA_WR
wrslw1:	clr A
	movc A,@A+DPTR
	jz wrslw2
	movx @R0,A
	call wtbusy
	inc DPTR
	push DPL
	push DPH
        mov DPTR,#100
        call wtms
	pop DPH
	pop DPL	
	jmp wrslw1
wrslw2:	ret


;Sub routine to write command:
wrcmd:	mov R0,#LCD_CMD_WR
	movx @R0,A
	jmp wtbusy


;Sub routine to write character:
wrchar:	mov R0,#LCD_DATA_WR
	movx @R0,A

;Subroutine to wait for busy clear
wtbusy: mov R1,#LCD_BUSY_RD
	movx A,@r1
	jb ACC.7,wtbusy
	ret

;Wait for number of seconds in A
wtsec:	push ACC
	call wtms
	pop ACC
	dec A
	jnz wtsec
	ret

;Wait for number of milliseconds in DPTR
wtms:   xrl DPL,#0FFh			;Can't do DEC DPTR, so do the loop by forming 2's complement
	xrl DPH,#0FFh			;and incrementing instead.
	inc DPTR
wtms1:	mov TL0,#09Ch			;100 ticks before overflow = 1ms at 1.2MHz Clock
	mov TH0,#0FFh	
	mov TMOD,#1			;Timer 0 mode 1
	setb TCON.4			;Timer 0 runs
wtms2:	jnb TCON.5,wtms2	
	clr TCON.4			;Timer 0 stops
	clr TCON.5
	inc DPTR
	mov A,DPL
	orl A,DPH
	jnz wtms1
	ret

	
	END
