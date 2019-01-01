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
;   Filename:       stepper.asm                                          
;   Date:           04/04/05                                          
;   File Version:   1.00                                              
                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;                                                                     
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          stepperinc.inc                                                           
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;      This file implements single-stepping, half-stepping, and micro-stepping for
;      a bipolar stepper motor.  Cycle trought the different modes by pressing SW2. 
;      Adjust the speed of the motor with POT1.
;
;	Connections:
;       AN0 to POT1
;       RA4 to SW2
;       RD7 to P1
;       RD6 to P2
;       RD5 to P3
;       RD4 to P4
;       CCP1 to PWM1
;       CCP2 to PWM3
;       Place three shunts vertically on J2
;       Place three shunts vertically on J3
;       Drive 1 to Brown wire
;       Drive 2 to Orange wire
;       Drive 3 to Red wire
;       Drive 4 to Yellow wire                                        
;                                                                     
;************************************************************************************

	#include	<stepperinc.inc>		

STARTUP code
        goto    Initialize

PORT1   code

	
;************************************************************************************
; Initialize - Initialize CCP1, comparators, internal oscillator, I/O pins, 
;	analog pins, motor parameters, variables	
;
;************************************************************************************
Initialize
	bsf		STATUS,RP0		; bank 1

	bcf 	TRISC,5			; Output: RC5
	movlw	b'00001011'		; Outputs: RD2,RD4-RD7
	movwf	TRISD		
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
	movlw	b'00000001'		; enable AN0
	movwf	ANSEL
	movwf	b'01010000'		; Fosc/16
	movwf	ADCON1
	movlw	0x3F			; 31.2 kHz PWM
	movwf	PR2
	movlw	b'00000000'		; 1:2 prescaler for TMR0
	movwf	OPTION_REG
	bcf		STATUS,RP0		; bank 0

	clrf	PORTD			; turn off windings
	clrf	PORTC
	movlw	b'00000001'		; left justified, AN0 selected, module on
	movwf	ADCON0			
	movlw	0x07
	movwf	CMCON0			; turn off comparators
	clrf	CCPR1L
	clrf	CCPR2L
	movlw	b'00001100'		; pwm mode
	movwf	CCP1CON
	movwf	CCP2CON
	bsf 	T2CON,TMR2ON	; turn on PWM
	bsf		T1CON,TMR1ON	; turn on Timer 1

	clrf	State			; initialize motor state pointer and duty cycle
	clrf	Index			;  index pointer
	clrf	Mode
	clrf	ADRESH
	movlw	1
	movwf	StepModeScaler
	movwf	Counter
	clrf	Speed			
	clrf	ButtonState		; initialize button state

;************************************************************************************
; Main - Choose motor mode
;
;************************************************************************************
Main
	btfss	INTCON,T0IF		; Wait 2.5ms
	goto	Main
	bcf		INTCON,T0IF
	
	call	ButtonPress		; Call the button press debounce routine
	btfsc	STATUS,C		; The carry flag is set if a button press just occurred
	incf	Mode,f			;  Change to the next state when a button press occurs.

	decfsz	Counter,f		; This is the scaler for different stepping modes
	goto	Main
	movf	StepModeScaler,w
	movwf	Counter
	decfsz	Speed,f			; Delay counter
	goto	Main

	comf	ADRESH,w		; Set speed of motor
	btfsc	STATUS,Z		; If zero, then make 255
	sublw	1
	movwf	Speed			; Store in speed variable
	bsf		ADCON0,GO_DONE	; start another ADC convertion	
	goto	ModeStateMachine

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
	goto	SingleStep
	goto	HalfStep
	goto	MicroStep
	clrf	Mode
	goto	ModeTable


;************************************************************************************
; SingleStep - Single Step the motor
;
;************************************************************************************
SingleStep
	movlw	8
	movwf	StepModeScaler
	incf	State,f			; Increment motor state
	movlw	0xFF			; Turn off PWMs	 
	movwf	CCPR1L
	movwf	CCPR2L
	movlw	0x30
	iorwf	CCP1CON,f
	iorwf	CCP1CON,f
SingleStateMachine			; jump to motor state based on State pointer
	movlw	high SingleJumpTable
	movwf	PCLATH
	movf	State,w
	andlw	0x03
	addlw	low SingleJumpTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
	
SingleJumpTable
	goto	SingleState0
	goto	SingleState1
	goto	SingleState2
	goto	SingleState3

SingleState0
	movlw	CTRL1FWD
	movwf	PORTD
	goto	Main

SingleState1
	movlw	CTRL2REV
	movwf	PORTD
	goto	Main

SingleState2
	movlw	CTRL1REV
	movwf	PORTD
	goto	Main

SingleState3
	movlw	CTRL2FWD
	movwf	PORTD
	goto	Main

;************************************************************************************
; HalfStep - Half Step the motor
;
;************************************************************************************
HalfStep
	movlw	4
	movwf	StepModeScaler
	incf	State,f
	movlw	0x30
	iorwf	CCP1CON,f
	iorwf	CCP1CON,f
HalfStateMachine			; jump to motor state based on State pointer
	movlw	high HalfJumpTable
	movwf	PCLATH
	movf	State,w
	andlw	0x07
	addlw	low HalfJumpTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
	
HalfJumpTable
	goto	HalfState0
	goto	HalfState1
	goto	HalfState2
	goto	HalfState3
	goto	HalfState4
	goto	HalfState5
	goto	HalfState6
	goto	HalfState7

HalfState0
	movlw	CTRL1FWD
	movwf	PORTD
	movlw	0x3F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState1
	movlw	CTRL1FWD | CTRL2REV
	movwf	PORTD
	movlw	0x2F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState2
	movlw	CTRL2REV
	movwf	PORTD
	movlw	0x3F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState3
	movlw	CTRL2REV | CTRL1REV
	movwf	PORTD
	movlw	0x2F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState4
	movlw	CTRL1REV
	movwf	PORTD
	movlw	0x3F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState5
	movlw	CTRL1REV | CTRL2FWD
	movwf	PORTD
	movlw	0x2F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState6
	movlw	CTRL2FWD
	movwf	PORTD
	movlw	0x3F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

HalfState7
	movlw	CTRL2FWD | CTRL1FWD
	movwf	PORTD
	movlw	0x2F
	movwf	CCPR1L
	movwf	CCPR2L
	goto	Main

;************************************************************************************
; MicroStep - Micro step the motor
;
;************************************************************************************
MicroStep
	movlw	1
	movwf	StepModeScaler
	call	DutyCycleLookup	; lookup duty cycle value
	btfss	STATUS,C		; if DutyCycleLookup sets carry variable then it's time
	goto	MicroStateMachine	; to change state
	incf	State,f

MicroStateMachine			; jump to motor state based on State pointer
	movlw	high MicroJumpTable
	movwf	PCLATH
	movf	State,w
	andlw	0x03
	addlw	low MicroJumpTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
	
MicroJumpTable
	goto	MicroState0
	goto	MicroState1
	goto	MicroState2
	goto	MicroState3

;		0 - CTRL1FWD ascending, CTRL2FWD decending  
;		1 - CTRL1FWD decending, CTRL2REV ascending   
;		2 - CTRL1REV ascending, CTRL2REV decending  
;		3 - CTRL1REV decending, CTRL2FWD ascending  

MicroState0
	movlw	CTRL1FWD | CTRL2FWD
	movwf	PORTD
	goto	Main

MicroState1
	movlw	CTRL1FWD | CTRL2REV
	movwf	PORTD
	goto	Main

MicroState2
	movlw	CTRL1REV | CTRL2REV
	movwf	PORTD
	goto	Main

MicroState3
	movlw	CTRL1REV | CTRL2FWD
	movwf	PORTD
	goto	Main

;************************************************************************************
; DutyCycleLookup - Lookup duty cycle value based on motor state, direction, and duty 
;	cycle index.  Move this 8-bit value into CCPxCON(LS 2-bits) and 
;	CCPRxL(HS 6-bits).
;
;************************************************************************************
DutyCycleLookup
; Winding 1 duty cycle lookup
	btfss	State,0
	call	DutyCycleDec
	btfsc	State,0
	call	DutyCycleAsc

	movwf	DutyCycle			; move least significant 2 bits of duty cycle into
	swapf	DutyCycle,w			;  bits 4 and 5 of CCP2CON
	andlw	0x30
	iorlw	0x8D
	movwf	CCP2CON

	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR2L
	andlw	0x3F
	movwf	CCPR2L
; Winding 2 duty cycle lookup
	btfss	State,0
	call	DutyCycleAsc
	btfsc	State,0
	call	DutyCycleDec

	movwf	DutyCycle			; move least significant 2 bits of duty cycle into
	swapf	DutyCycle,w			;  bits 4 and 5 of CCP1CON
	andlw	0x30
	iorlw	0x8D
	movwf	CCP1CON

	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR1L
	andlw	0x3F
	movwf	CCPR1L

	incf	Index,f				; increment duty cycle index
	movf	Index,w				
	andlw	0x07				; if Index has reached end of table it's time
	xorlw	0					;  to change states - indicate this by setting
	bsf 	STATUS,C			;  the carry bit
	btfss	STATUS,Z
	bcf		STATUS,C
	return

;************************************************************************************
; DutyCycleDec - Descending duty cycle lookup table
;
;************************************************************************************
DutyCycleDec
	movlw	high DutyCycleDecTable
	movwf	PCLATH
	movf	Index,w
	andlw	0x07
	addlw	low DutyCycleDecTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL	
DutyCycleDecTable	
	retlw	.255
	retlw	.249
	retlw	.230
	retlw	.199
	retlw	.159
	retlw	.111
	retlw	.57
	retlw	.0

;************************************************************************************
; DutyCycleAsc - Ascending duty cycle lookup table
;
;************************************************************************************
DutyCycleAsc
	movlw	high DutyCycleAscTable
	movwf	PCLATH
	movf	Index,w
	andlw	0x07
	addlw	low DutyCycleAscTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL	
DutyCycleAscTable
	retlw	.0
	retlw	.57
	retlw	.111
	retlw	.159
	retlw	.199
	retlw	.230
	retlw	.249
	retlw	.255

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
