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
;   Filename:       ECCP.asm                                          
;   Date:           05/05/05                                          
;   File Version:   1.00                                              
                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;                                                                     
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          ECCP.inc                                                           
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;      This file implements brushed DC motor control using the Enahanced
;      Capture, Compare, PWM (ECCP) module on-board the PIC16F690.
;      - Use SW2 to cycle through the following modes
;			- Motor off
;     		- Forward
;           - Motor off
;           - Reverse
;      - Use POT1 to adjust the speed of the motor
;
;	Connections:
;		SW2 to RA5
;		POT1 to AN2
;       P1 to P1A
;       N1 to P1B
;       P2 to P1C
;       N2 to P1D                                      
;                                                                     
;************************************************************************************

	#include	<eccp.inc>		

org 0x00
    goto    Initialize
org 0x05
	
;************************************************************************************
; Initialize - Initialize CCP1, comparators, internal oscillator, I/O pins, 
;	analog pins, motor parameters, variables	
;
;************************************************************************************
Initialize
	bsf		STATUS,RP0		; bank 1
	movlw	b'11000011'		; Outputs: RC2-RC5
	movwf	TRISC
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
	movlw	b'00000100'		; enable AN2
	movwf	ANSEL
	movwf	b'01010000'		; Fosc/16
	movwf	ADCON1
	movlw	0x3F			; 31.2 kHz PWM
	movwf	PR2
	movlw	b'00000111'		; 1:256 prescaler for TMR0
	movwf	OPTION_REG
	bcf		STATUS,RP0		; bank 0

	movlw	b'00001001'		; left justified, AN2 selected, module on
	movwf	ADCON0			
	movlw	0x07
	movwf	CM1CON0			; turn off comparators
	bsf 	T2CON,TMR2ON	; turn on PWM
	bsf		T1CON,TMR1ON	; turn on Timer 1

	clrf	PORTC			; turn off motor
	clrf	Mode			; clear mode pointer
	clrf	ButtonState		; clear debounce pointer

;************************************************************************************
; Main - Choose motor mode
;
;************************************************************************************
Main
	btfss	INTCON,T0IF		; Wait 32ms
	goto	Main
	bcf		INTCON,T0IF
	
	call	ButtonPress		; Call the button press debounce routine
	btfsc	STATUS,C		; "ButtonPress" sets Carry when press is detected
	incf	Mode,f			; Increment mode if button is pressed

	movf	ADRESH,w		; Set speed of motor
	movwf	DutyCycle
	bsf		ADCON0,GO_DONE

ModeStateMachine			; Select stepping mode
	movlw	high ModeTable
	movwf	PCLATH
	movf	Mode,w
	andlw	0x03
	addlw	low ModeTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
	
ModeTable					
	goto	MotorOff
	goto	Forward
	goto	MotorOff
	goto	Reverse

;************************************************************************************
; MotorOff - Turn off motor
;
;************************************************************************************
MotorOff
	clrf	CCP1CON
	clrf	PORTC
	goto	Main

;************************************************************************************
; Forward - Set forward motor speed
;
;************************************************************************************
Forward
	bcf		CCP1CON,7
	swapf	DutyCycle,w			;  bits 4 and 5 of CCP1CON
	andlw	0x30
	iorlw	0x4C
	movwf	CCP1CON
	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR1L
	andlw	0x3F
	movwf	CCPR1L
	goto	Main
	
;************************************************************************************
; Reverse - Set reverse motor speed
;
;************************************************************************************
Reverse
	swapf	DutyCycle,w			;  bits 4 and 5 of CCP1CON
	andlw	0x30
	iorlw	0xCC
	movwf	CCP1CON
	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR1L
	andlw	0x3F
	movwf	CCPR1L
	goto	Main

;************************************************************************************
; ButtonPress - When the button is first pressed this function sets the carry flag to
;  indicate it's time to change modes.  Then the function debounces the switch to 
;  ensure one button press by the user is interpreted as one button press by the 
;  microcontroller
;
;************************************************************************************
ButtonPress
	movlw	high DebounceStates
	movwf	PCLATH
	movf	ButtonState,w
	andlw	0x03
	addlw	low DebounceStates
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL	
DebounceStates
	goto	DebounceState0
	goto	DebounceState1
	goto	DebounceState2
	goto	DebounceState1	

DebounceState0	; Wait for a Button Press
	bcf		STATUS,C
	btfsc	SW2
	goto	EndDebounceState0
	incf	ButtonState,f
	bsf		STATUS,C
EndDebounceState0
	return

DebounceState1
	btfss	SW2
	goto	EndDebounceState1
	incf	ButtonState,f
	clrf	TMR1L
	clrf	TMR1H
	bcf		PIR1,TMR1IF
EndDebounceState1
	bcf		STATUS,C
	return

DebounceState2
	btfss	SW2
	decf	ButtonState,f
	btfsc	PIR1,TMR1IF
	clrf	ButtonState
	bcf		STATUS,C
	return

	END						; directive 'end of program'
