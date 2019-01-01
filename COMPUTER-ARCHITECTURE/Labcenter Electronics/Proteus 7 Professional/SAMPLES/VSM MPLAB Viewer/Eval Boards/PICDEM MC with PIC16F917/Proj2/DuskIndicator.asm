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
;   Filename:      	DuskIndicator.asm                                          
;   Date:           March 14,2005                                          
;   File Version:   1.00                                              
;                                                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          DuskIndicator.inc                                                           
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;		This project uses the PIC16F917 onboard analog comparator module.
;       A Potentiometer input is compared to the light sensor.  If the light sensor
;		reads lower than the potentiometer input, an LED is lit.  This is similar
;		to what a dusk indicator on a flood light does - when the sun goes down, 
;		the flood light turn on.  Hysteresis is implemented so that the LED does
;       not flicker when the light sensor and POT are equal in voltage          
;     
;	Connections:
;	 	C1- to Light Sensor
;		C1+ to POT1
;		RD7 to D0 (LED0)
;                                                   
;************************************************************************************

	#include	<DuskIndicator.inc>		; this file includes variable definitions
										; and pin assignments	

;************************************************************************************
org 0x00
        goto    Initialize

  org 0x20

;************************************************************************************
; Initialize - Initialize comparators, internal oscillator, I/O pins, 
;	analog pins, variables	
;
;************************************************************************************
Initialize
	bsf		STATUS,RP0		; we'll set up the bank 1 Special Function Registers first

; Configure I/O pins for project	
	bcf 	TRISD,7			; RD7 is an output
	bsf		TRISA,0			; RA0 is an input
	bsf		TRISA,3			; RA3 is an input
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	MOVLW	B'10000000'		;PORTB PULL-UP DISABLED
	MOVWF	OPTION_REG		;TMR0 Prescaler 1:1
; Configure comparators
	movlw	b'00010100'
	movwf	CMCON0			; turn comparators on as two independent comparators, invert C1 output
; Turn off Analog 
	clrf	ANSEL

	bcf		STATUS,RP0		; go back to bank 0


;************************************************************************************
; Main - The code waits for 0.128ms to pass and then checks the comparator state. 
;        The comparator state must be stable for 256 reads before it changes the state
;        of the LED.
;
;************************************************************************************
Main
	btfss	INTCON,T0IF		; Wait for Timer 0 to overflow before running comparator test
	goto	Main
	bcf		INTCON,T0IF

	banksel	CMCON0
	btfss	CMCON0, C1OUT   ; 
	goto	LEDon
	btfsc	CMCON0, C1OUT
	goto	LEDoff

LEDon
	clrf	STATUS			; Bank 0
	clrf	OffCntr			; Clear hysteresis counter for turning off the LED
	incf	OnCntr,f		; Increment hysteresis counter for turning on the LED
	btfsc	STATUS,Z		; If the comparator state hasn't changed for a while then turn on the LED
	bsf		LED
	goto	Main

LEDoff
	clrf	STATUS			; Bank 0
	clrf	OnCntr			; Clear hysteresis counter for turning on the LED
	incf	OffCntr,f		; Increment hysteresis counter for turning off the LED
	btfsc	STATUS,Z		; If the comparator state hasn't changed for a while then turn off the LED
	bcf		LED
	goto	Main

	END						; directive 'end of program'
