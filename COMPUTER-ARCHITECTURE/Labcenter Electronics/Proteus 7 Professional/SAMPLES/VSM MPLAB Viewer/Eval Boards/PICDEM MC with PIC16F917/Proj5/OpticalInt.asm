;************************************************************************************
;                            Software License Agreement
;
; The software supplied herewith by Microchip Technology Incorporated (the "Company")
; for its PICmicro(r) Microcontroller is intended and supplied to you, the Company's
; customer, for use solely and exclusively on Microchip PICmicro Microcontroller
; products.
;
; The software is owned by the Company and/or its supplier, and is protected under
; applicable copyright laws. All rights are reserved. Any use in violation of the
; foregoing restrictions may subject the user to criminal sanctions under applicable
; laws, as well as to civil liability for the breach of the terms and conditions of
; this license.
;
; THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES, WHETHER EXPRESS,
; IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE
; COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;                                                                   
;************************************************************************************
;                                                                     
;   Filename:       OpticalInt.asm                                          
;   Date:           March 21,2005                                          
;   File Version:   1.00                                              
;                                                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;                                                                     
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          OpticalInt.inc
;          LCD.asm
;          LCD.inc
;          16F917.lkr                                                          
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:  This project controls the speed of a brushed DC motor.  POT1 is used to
;            set the speed of the motor.  The optical interrupter provides speed 
;            feedback.  This feedback is fed into the T1CKL pin and the speed of the 
;            motor is measured.  The speed is then displayed on the LCD as RPM / 10^3.                                                         
;                                                                     
;    Connections:
;     POT1 (J4) to RA0 (J13)
;     Optical Interrupter (J7) to RC5 (J10)
;     N2 (J1) to CCP2 (J10)
;     P1 (J1) to RD7 (J10)
;
;************************************************************************************

	#include	<OpticalInt.inc>

;**********************************************************************
STARTUP	code
	goto	Initialize

PORT1	code

;************************************************************************************
; Initialize - Initialize CCP1, comparators, internal oscillator, I/O pins, 
;	analog pins, motor parameters, variables	
;
;************************************************************************************
Initialize
	clrf	STATUS			; bank 0
	bsf		STATUS,RP0		; we'll set up the bank 1 Special Function Registers fist

; Configure I/O pins for project	
	bcf 	TRISD,7			; RD7 is an output
	bcf		TRISD,2			; RD6 is an output
	bsf		TRISC,5			; RC5 is an input
	bsf		TRISA,4			; RA4 is an input
	bsf		TRISA,0			; RA0 is an input
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set up A-to-D Module
	movlw	b'00000001'		; enable AN0
	movwf	ANSEL
	movwf	b'01010000'		; Fosc/16
	movwf	ADCON1
; Configure PR2 to
	movlw	0x3F			; 31.2 kHz PWM
	movwf	PR2
; Set TMR0 parameters
	MOVLW	B'10000111'		;PORTB PULL-UP DISABLED
	MOVWF	OPTION_REG		;TMR0 RATE 1:256
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators
	bcf		STATUS,RP0		; go back to bank 0

; Finish setting up A-to-D Module
	movlw	b'00000001'		; left justified, AN0 selected, module on
	movwf	ADCON0		
; Turn off all interrupts
	clrf	INTCON			; Make sure interrupts are turn off
; Configure Capture Compare PWM Module 2
	clrf	CCPR2L
	movlw	b'00001100'		; pwm mode
	movwf	CCP2CON
; Turn on Timer 2
	bsf 	T2CON,TMR2ON	; turn on PWM
; Turn on Timer 1
	movlw	b'00010111'		; set Timer 1 prescaler to 1:2, Select external clock source, Timer 1 on
	movwf	T1CON

	clrf	PORTD			; Turn off Motor


;************************************************************************************
; Main - Every 23.4ms POT1 is measured and moved into the dutycycle registers for 
;  CCP2.  CCP2 drives the brushed dc motor, thereby controlling the speed.  Timer 1
;  is clocked by the Optical Interrupter.  Every 3/4 of a second the value in Timer 1
;  is converted to RPM and displayed as: RPM / 10^3.
;
;************************************************************************************
Main
	bsf		ADCON0,GO_DONE	; start an A-to-D conversion
	call	InitLCD			; Initialize LCD Special Function Registers
	clrf 	Counter
	clrf	TMR1L
	clrf	TMR1H

Loop
	btfss	INTCON,T0IF		; TMR0 is preloaded so than this loop is exited every 23.4ms
	goto	Loop			; RPM/10 = (number of counts every 23.ms) * 256 (this is a nice number to work with)
	bcf		INTCON,T0IF
	movlw	.73
	movwf	TMR0

	call	SetMotorSpeed
	call	MeasureSpeed
	btfsc	STATUS,C
	call	DisplaySpeed

	goto	Loop

SetMotorSpeed
	movf	ADRESH,w
	movwf	DutyCycle
	bsf		ADCON0,GO_DONE
	bsf		P1					; Turn on motor
	swapf	DutyCycle,w			;  bits 4 and 5 of CCP2CON
	andlw	0x30
	iorlw	0x8D
	movwf	CCP2CON
	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR2L
	andlw	0x3F
	movwf	CCPR2L
	return

MeasureSpeed
	incf	Counter,f			; measure over 3^5 or 32 cycles (23.4ms * 32 = 0.75 second)
	bcf 	STATUS,C			; clear carry flag
	btfss	Counter,5	
	goto	EndMeasureSpeed
	clrf	Counter

	bcf		T1CON, TMR1ON		; turn off Timer 1
	movf	TMR1L,w				; Store Timer 1 in TimeL and TimeH	
	movwf	TimeL
	movf	TMR1H,w
	movwf	TimeH
	bsf		T1CON,TMR1ON		; turn Timer 1 back on
	clrf	TMR1L
	clrf	TMR1H
	bsf		STATUS,C			; Set carry flag to indicate its time to display a value
EndMeasureSpeed
	return
	
DisplaySpeed
	bcf		STATUS,C			; first multiply by 8 (0.75sec * 8 = 6 seconds = 1/10 of a minute)
	rlf 	TimeL,f
	rlf		TimeH,f
	rlf		TimeL,f
	rlf		TimeH,f
	rlf		TimeL,f
	rlf		TimeH,f
	
	movf	TimeL,w				; Now convert to BCD
	movwf	L_byte
	movf	TimeH,w
	movwf	H_byte
	call	ConvertToBCD		; This function was taken from AN526 (why write a function if you don't have too?!)
								;  It converts the RPM number to Binary Coded Decimal (BCD)

	movf	R2,w				; Example RPM = 4320
	andlw	0x0F				;  R2 contains 0x32  (remember we are displaying RPM/10)
	call	DisplayDigit1
	swapf	R2,w				
	andlw	0x0F
	call	DisplayDigit2		
	movf	R1,w				; R1 contains 0x04  
	andlw	0x0F
	call	DisplayDigit3
	call	Display3DP			; Place a decimal point between the 4 and the 3.  The display will read 4.32
	return						; Therefor the display shows RPM / 10^3.

;************************* Taken from AN526 **********************************
;                  Binary To BCD Conversion Routine 
;      This routine converts a 16 Bit binary Number to a 5 Digit
; BCD Number. This routine is useful since PIC16C55 & PIC16C57
; have  two 8 bit ports and one 4 bit port ( total of 5 BCD digits)
;
;       The 16 bit binary number is input in locations H_byte and
; L_byte with the high byte in H_byte.
;       The 5 digit BCD number is returned in R0, R1 and R2 with R0
; containing the MSD in its right most nibble.
;
;   Performance :
;               Program Memory  :       35
;               Clock Cycles    :       885
;
;
;       Program:          B16TOBCD.ASM 
;       Revision Date:   
;                         1-13-97      Compatibility with MPASMWIN 1.40
;
;*******************************************************************;
ConvertToBCD
	bcf     STATUS,0                ; clear the carry bit
	movlw   .16
	movwf   count
	clrf    R0
	clrf    R1
	clrf    R2
loop16  
	rlf     L_byte, F
	rlf     H_byte, F
	rlf     R2, F
	rlf     R1, F
	rlf     R0, F
;
	decfsz  count, F
	goto    adjDEC
	RETLW   0
;
adjDEC  
	movlw   R2
	movwf   FSR
	call    adjBCD
;
	movlw   R1
	movwf   FSR
	call    adjBCD
;
	movlw   R0
	movwf   FSR
	call    adjBCD
;
	goto    loop16
;
adjBCD  
	movlw   3
	addwf   0,W
	movwf   temp
	btfsc   temp,3          ; test if result > 7
	movwf   0
	movlw   30
	addwf   0,W
	movwf   temp
	btfsc   temp,7          ; test if result > 7
	movwf   0               ; save as MSD
	RETLW   0


	END						; directive 'end of program'
