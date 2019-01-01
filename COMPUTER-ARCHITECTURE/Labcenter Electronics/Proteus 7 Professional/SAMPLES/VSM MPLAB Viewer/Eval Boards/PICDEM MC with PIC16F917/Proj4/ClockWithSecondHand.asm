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
;   Filename:       Clock.asm                                          
;   Date:           March 11,2005                                          
;   File Version:   1.00                                              
;                                                                     
;   Author:         Reston Condit                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;                                                                     
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          Clock.inc                                                           
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;                                                                     
;                                                                     
;                                                                     
;                                                                     
;************************************************************************************

	#include	<Clock.inc>		

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
	bsf 	TRISA,7			; RA7 is an input
	bsf		TRISA,6			; RA6 is an input
	bsf		TRISA,4			; RA4 is an input
	movlw	b'00001111'		; RD4-RD7 are outputs
	movwf	TRISD
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	MOVLW	B'10000111'		;PORTB PULL-UP DISABLED
	MOVWF	OPTION_REG		;TMR0 RATE 1:256
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators

	bcf		STATUS,RP0		; go back to bank 0

; Set up Timer 1
	movlw	b'00001011'		; Use external oscillator
	movwf	T1CON


;************************************************************************************
; Main - 
;
;************************************************************************************
Main
	call	InitLCD			; Initialize LCD Special Function Registers
	clrf	Second
	clrf	Minute
	clrf	HandState
	movlw	.12
	movwf	Hour
	call	DisplayA

Loop
	btfss	SW2
	call	SetTime

	btfss	TMR1H,7			; When bit 7 of TMR1H is set, increment second
	goto	Loop
	bcf 	TMR1H,7

	call	StepSecondHand
	call	MakeTime

	movf	Second,w
	call	ConvertToBCD
	movwf	SecondBCD
	movf	Minute,w
	call	ConvertToBCD
	movwf	MinuteBCD
	movf	Hour,w
	call	ConvertToBCD
	movwf	HourBCD

	movf	MinuteBCD,w
	andlw	0x0F
	call	DisplayDigit1
	swapf	MinuteBCD,w	
	andlw	0x0F
	call	DisplayDigit2	
	movf	HourBCD,w
	andlw	0x0F
	call	DisplayDigit3
	swapf	HourBCD,w
	andlw	0x0F
	call	DisplayDigit4

	goto	Loop

MakeTime
	incf	Second,f
	banksel	LCDDATA10		; bank 2
	movlw	b'00001000'		; make decimal point 3 blink
	xorwf	LCDDATA10,f
	banksel	TMR1H			; back to bank 0
	movf	Second,w
	xorlw	.60
	btfss	STATUS,Z
	goto	EndMakeTime
	clrf	Second
	incf	Minute,f
	movf	Minute,w
	xorlw	.60
	btfss	STATUS,Z
	goto	EndMakeTime
	clrf	Minute
	incf	Hour,f
	movf	Hour,w
ToggleAMorPM
	xorlw	.12
	btfss	STATUS,Z
	goto	Next
	banksel	LCDDATA0		; bank 2
	movlw	0x01			; toggle A for AM 
	xorwf	LCDDATA0,f
	clrf	STATUS			; back to bank 0
Next
	movf	Hour,w
	xorlw	.13
	btfss	STATUS,Z
	goto	EndMakeTime
	movlw	1
	movwf	Hour
	goto	EndMakeTime
EndMakeTime
	return

ConvertToBCD
	movwf	Temp
	incf	Temp,f
	clrf	BCDValue
ConvertLoop
	decf	Temp,f
	btfsc	STATUS,Z
	goto	EndConvertToBCD
	incf	BCDValue,f
	movf	BCDValue,w
	andlw	0x0F
	xorlw	0x0A
	btfss	STATUS,Z
	goto	ConvertLoop
	movlw	0x06
	addwf	BCDValue,f
	goto	ConvertLoop
EndConvertToBCD
	movf	BCDValue,w
	return

SetTime
	btfsc	SW2
	goto	EndSetTime

	call	MakeTime

	movf	Second,w
	call	ConvertToBCD
	movwf	SecondBCD
	movf	Minute,w
	call	ConvertToBCD
	movwf	MinuteBCD
	movf	Hour,w
	call	ConvertToBCD
	movwf	HourBCD

	movf	MinuteBCD,w
	andlw	0x0F
	call	DisplayDigit1
	swapf	MinuteBCD,w	
	andlw	0x0F
	call	DisplayDigit2	
	movf	HourBCD,w
	andlw	0x0F
	call	DisplayDigit3
	swapf	HourBCD,w
	andlw	0x0F
	call	DisplayDigit4

	goto	SetTime
EndSetTime
	return

StepSecondHand
	incf	HandState,f
	movlw	0x05
	xorwf	HandState,w
	btfsc	STATUS,Z
	clrf	HandState
	movlw	high HandTable
	movwf	PCLATH
	movf	HandState,w
	andlw	0x07
	addlw	low HandTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
HandTable
	goto	State0
	goto	State1
	goto	State2
	goto	State3
	goto	State4
	nop				
	nop
	goto	State0
State0
	movlw	b'10000000'
	movwf	PORTD
	goto	EndStepSecondHand
State1
	movlw	b'00010000'
	movwf	PORTD
	goto	EndStepSecondHand
State2
	movlw	b'01000000'
	movwf	PORTD
	goto	EndStepSecondHand
State3
	movlw	b'01100000'
	movwf	PORTD
	goto	EndStepSecondHand
State4
	movlw	b'00100000'
	movwf	PORTD
	goto	EndStepSecondHand
EndStepSecondHand
	return


	END						; directive 'end of program'
