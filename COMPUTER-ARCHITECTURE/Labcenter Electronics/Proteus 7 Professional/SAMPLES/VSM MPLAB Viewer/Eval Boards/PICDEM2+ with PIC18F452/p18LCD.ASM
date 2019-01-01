;************************************************************************
;*	Microchip Technology Inc. 2002					*
;*	Assembler version: 2.0000					*
;*	Filename: 							*
;*		p18lcd.asm (main routine)   				*
;*	Dependents:							*
;*		p18demo.asm						*
;*		p18math.asm						*
;*		16f877.lkr						*
;*	March 14,2002							*
;* 	PICDEM 2 PLUS DEMO code. The following functions are included 	*
;*	with this code:							*
;*		1. Voltmeter						*
;*			The center tap of R16 is connected to RA0, the	*
;*			A/D converter converts this analog voltage and	*
;*			the result is displayed on the LCD in a range	*
;*			from 0.00V - 5.00V.				*
;*		2. Buzzer						*
;*			The Piezo buzzer is connected to RC2 and is	*
;*			driven by the CCP1 module. The period and duty	*
;*			cycle are adjustable on the fly through the LCD	*
;*			and push-buttons.				*
;*		3. Temperature						*
;*			A TC74 Serial Digital Thermal Sensor is used to	*
;*			measure ambient temperature. The PIC and TC74	*
;* 			communicate using the MSSP module. The TC74 is	*
;*			connected to the SDA & SCL I/O pins of the PIC	*
;*			and functions as a slave.			*
;*		4. Clock						*
;*			This function is a real-time clock. When the	*
;*			mode is entered, time begins at 00:00:00. The 	*
;*			user can set the time if desired.		*
;************************************************************************

	list p=18f452
	#include p18f452.inc


#define	LCD_D4		PORTD, 0	; LCD data bits
#define	LCD_D5		PORTD, 1
#define	LCD_D6		PORTD, 2
#define	LCD_D7		PORTD, 3

#define	LCD_D4_DIR	TRISD, 0	; LCD data bits
#define	LCD_D5_DIR	TRISD, 1
#define	LCD_D6_DIR	TRISD, 2
#define	LCD_D7_DIR	TRISD, 3

#define	LCD_E		PORTA, 1	; LCD E clock
#define	LCD_RW		PORTA, 2	; LCD read/write line
#define	LCD_RS		PORTA, 3	; LCD register select line

#define	LCD_E_DIR	TRISA, 1	
#define	LCD_RW_DIR	TRISA, 2	
#define	LCD_RS_DIR	TRISA, 3	

#define	LCD_INS		0	
#define	LCD_DATA	1

D_LCD_DATA	UDATA
COUNTER		res	1
delay		res	1
temp_wr		res	1
temp_rd		res	1

	GLOBAL	temp_wr

PROG1	CODE


;***************************************************************************
	
LCDLine_1
	movlw	0x80
	movwf	temp_wr
	rcall	i_write
	return
	GLOBAL	LCDLine_1

LCDLine_2
	movlw	0xC0
	movwf	temp_wr
	rcall	i_write
	return
	GLOBAL	LCDLine_2

	;write data
d_write
	movff	temp_wr,TXREG
	btfss	TXSTA,TRMT
	goto	$-2
	rcall	LCDBusy
	bsf	STATUS, C	
	rcall	LCDWrite
	return
	GLOBAL	d_write

	;write instruction
i_write
	rcall	LCDBusy
	bcf	STATUS, C
	rcall	LCDWrite
	return
 	GLOBAL	i_write


rlcd	macro	MYREGISTER
 IF MYREGISTER == 1
	bsf	STATUS, C
	rcall	LCDRead
 ELSE
	bcf	STATUS, C
	rcall	LCDRead
 ENDIF
	endm
;****************************************************************************




; *******************************************************************
LCDInit
	clrf	PORTA
	
	bcf	LCD_E_DIR		;configure control lines
	bcf	LCD_RW_DIR
	bcf	LCD_RS_DIR
	
	movlw	b'00001110'
	movwf	ADCON1	

	movlw	0xff			; Wait ~15ms @ 20 MHz
	movwf	COUNTER
lil1
	movlw	0xFF
	movwf	delay
	rcall	DelayXCycles
	decfsz	COUNTER,F
	bra	lil1
	
	movlw	b'00110000'		;#1 Send control sequence 
	movwf	temp_wr
	bcf	STATUS,C
	rcall	LCDWriteNibble

	movlw	0xff			;Wait ~4ms @ 20 MHz
	movwf	COUNTER
lil2
	movlw	0xFF
	movwf	delay
	rcall	DelayXCycles
	decfsz	COUNTER,F
	bra	lil2

	movlw	b'00110000'		;#2 Send control sequence
	movwf	temp_wr
	bcf	STATUS,C
	rcall	LCDWriteNibble

	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles
						
	movlw	b'0011000'		;#3 Send control sequence
	movwf	temp_wr
	bcf	STATUS,C
	rcall	LCDWriteNibble

		;test delay
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles


	movlw	b'00100000'		;#4 set 4-bit
	movwf	temp_wr
	bcf	STATUS,C
	rcall	LCDWriteNibble

	rcall	LCDBusy			;Busy?
				
	movlw	b'00101000'		;#5   Function set
	movwf	temp_wr
	rcall	i_write

	movlw	b'00001101'		;#6  Display = ON
	movwf	temp_wr
	rcall	i_write
			
	movlw	b'00000001'		;#7   Display Clear
	movwf	temp_wr
	rcall	i_write

	movlw	b'00000110'		;#8   Entry Mode
	movwf	temp_wr
	rcall	i_write	

	movlw	b'10000000'		;DDRAM addresss 0000
	movwf	temp_wr
	rcall	i_write

;	movlw	b'00000010'		;return home
;	movwf	temp_wr
;	call	i_write


	return

	GLOBAL	LCDInit	
; *******************************************************************








;****************************************************************************
;     _    ______________________________
; RS  _>--<______________________________
;     _____
; RW       \_____________________________
;                  __________________
; E   ____________/                  \___
;     _____________                ______
; DB  _____________>--------------<______
;
LCDWriteNibble
	btfss	STATUS, C		; Set the register select
	bcf	LCD_RS
	btfsc	STATUS, C	
	bsf	LCD_RS

	bcf	LCD_RW			; Set write mode

	bcf	LCD_D4_DIR		; Set data bits to outputs
	bcf	LCD_D5_DIR
	bcf	LCD_D6_DIR
	bcf	LCD_D7_DIR

	NOP				; Small delay
	NOP

	bsf	LCD_E			; Setup to clock data
	
	btfss	temp_wr, 7			; Set high nibble
	bcf	LCD_D7	
	btfsc	temp_wr, 7
	bsf	LCD_D7
	btfss	temp_wr, 6
	bcf	LCD_D6	
	btfsc	temp_wr, 6
	bsf	LCD_D6
	btfss	temp_wr, 5
	bcf	LCD_D5	
	btfsc	temp_wr, 5
	bsf	LCD_D5
	btfss	temp_wr, 4
	bcf	LCD_D4
	btfsc	temp_wr, 4
	bsf	LCD_D4	

	NOP
	NOP

	bcf	LCD_E			; Send the data

	return
; *******************************************************************





; *******************************************************************
LCDWrite
;	rcall	LCDBusy
	rcall	LCDWriteNibble
	swapf	temp_wr,F
	rcall	LCDWriteNibble
	swapf	temp_wr,F

	return

	GLOBAL	LCDWrite
; *******************************************************************





; *******************************************************************
;     _____    _____________________________________________________
; RS  _____>--<_____________________________________________________
;               ____________________________________________________
; RW  _________/
;                  ____________________      ____________________
; E   ____________/                    \____/                    \__
;     _________________                __________                ___
; DB  _________________>--------------<__________>--------------<___
;
LCDRead
	bsf	LCD_D4_DIR		; Set data bits to inputs
	bsf	LCD_D5_DIR
	bsf	LCD_D6_DIR
	bsf	LCD_D7_DIR		

	btfss	STATUS, C		; Set the register select
	bcf	LCD_RS
	btfsc	STATUS, C	
	bsf	LCD_RS

	bsf	LCD_RW			;Read = 1

	NOP
	NOP			

	bsf	LCD_E			; Setup to clock data

	NOP
	NOP
	NOP
	NOP

	btfss	LCD_D7			; Get high nibble
	bcf	temp_rd, 7
	btfsc	LCD_D7
	bsf	temp_rd, 7
	btfss	LCD_D6			
	bcf	temp_rd, 6
	btfsc	LCD_D6
	bsf	temp_rd, 6
	btfss	LCD_D5			
	bcf	temp_rd, 5
	btfsc	LCD_D5
	bsf	temp_rd, 5
	btfss	LCD_D4			
	bcf	temp_rd, 4
	btfsc	LCD_D4
	bsf	temp_rd, 4

	bcf	LCD_E			; Finished reading the data

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	bsf	LCD_E			; Setup to clock data

	NOP
	NOP

	btfss	LCD_D7			; Get low nibble
	bcf	temp_rd, 3
	btfsc	LCD_D7
	bsf	temp_rd, 3
	btfss	LCD_D6			
	bcf	temp_rd, 2
	btfsc	LCD_D6
	bsf	temp_rd, 2
	btfss	LCD_D5			
	bcf	temp_rd, 1
	btfsc	LCD_D5
	bsf	temp_rd, 1
	btfss	LCD_D4			
	bcf	temp_rd, 0
	btfsc	LCD_D4
	bsf	temp_rd, 0

	bcf	LCD_E			; Finished reading the data

FinRd
	return
; *******************************************************************






; *******************************************************************
LCDBusy
					; Check BF
	rlcd	LCD_INS
	btfsc	temp_rd, 7
	bra	LCDBusy
	return

	GLOBAL	LCDBusy
; *******************************************************************






; *******************************************************************
DelayXCycles
	decfsz	delay,F
	bra	DelayXCycles
	return
; *******************************************************************
	

	END
