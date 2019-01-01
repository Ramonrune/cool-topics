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
;   Filename:      	LightLED.asm                                          
;   Date:           March 14,2005                                          
;   File Version:   1.00                                              
;                                                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          LightLED.inc                                                           
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;     This project reads a tactile switch input.
;     On every button push RD7 is toggled from a 1 to a 0 or vice-versa.                                                                                                                                  
;                                                                     
;     Connections:
;     RA0 to a SW2
;     RD7 to a D0 (left most LED)           
;                                                        
;************************************************************************************

	#include	<LightLED.inc> 			; this file includes variable definitions
										; and pin assignments	

;************************************************************************************
  org 0x00
	goto	Initialize

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
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	movlw	b'10000110'		; PORTB pull-up disabled, TMR0 Prescaler 1:128
	movwf	OPTION_REG		
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators
; Turn off Analog 
	clrf	ANSEL

	bcf		STATUS,RP0		; go back to bank 0

	bcf		LED				; clear the LED

;************************************************************************************
; Main - When SW2 is pressed, the LED is toggled, and the debounce routine for SW2 is
;        initiated.  Debouncing a switch is necessary to prevent one button press from 
;        being read as more than one button press by the microcontroller.  A 
;        microcontroller can read a button so fast that contact jitter in the switch 
;        may be interpreted as more than one button press.
;
;************************************************************************************
Main
	btfsc	SW2				; Loop here until Switch 2 is pressed (SW2 is defined in the include file)
	goto	Main
							; Once Switch 2 is pressed, toggle the LED on or off
	movlw	0x80			; Exclusive ORing PORTD with 0x80 will effectively
	xorwf	PORTD,f			;  toggle RD7 on and off

DebounceState1				; Wait here until SW2 is released
	btfss	SW2
	goto	DebounceState1
	clrf	TMR0			; Once released clear TMR0 and the TMR0 interrupt flag
	bcf		INTCON,T0IF		;  in preparation to time 16ms

DebounceState2				; State2 makes sure than SW2 is unpressed for 16ms before
	btfss	SW2				;  returning to look for the next time SW2 is pressed
	goto	DebounceState1	; If SW2 is pressed again in this state then return to State1
	btfss	INTCON,T0IF 	; Else, continue to count down 16ms
	goto	DebounceState2	; Time = TMR0_max * TMR0 prescaler * (1/(Fosc/4)) = 256*128*0.5E-6 = 16.4ms
	goto	Main

	END						; directive 'end of program'
