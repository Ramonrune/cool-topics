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
;   Filename:       DisplayTemp.asm                                          
;   Date:           March 14,2005                                          
;   File Version:   1.00                                              
;                                                                     
;   Company:        Microchip Technology Inc.                         
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          DisplayTemp.inc                                                           
;          16f917.lkr                                                           
;                                                                     
;************************************************************************************
;                                                                     
;    Notes:                                                           
;     This code reads and analog temperature sensor (TC1047A) and converts the result
;     into degrees Celsius using the following algorithms:
;
;		Valid temperature exists:  21 < ADC Value(10-bit) < 358  
;
;       Temperature(degrees C) = (ADC Value/2) - 50       
;
;     The result is displayed on the LCD.
;
;    Connections:
;	   AN0 to the output of TC1047A
;                                                                     
;************************************************************************************

	#include	<DisplayTemp.inc>		

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
	bsf		STATUS,RP0		; we'll set up the bank 1 Special Function Registers first

; Configure I/O pins for project	
	bsf 	TRISA,0			; RA0 is an input
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	MOVLW	b'10000111'		; PORTB PULL-UP DISABLED
	MOVWF	OPTION_REG		; TMR0 RATE 1:256
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators
; Set up Analog Channel(s) 
	movlw	b'00000001'		; select AN0 as an analog channel (RA0)
	movwf	ANSEL
	movlw	b'01010000'		; select A/D converstion clock Fosc/16
	movwf	ADCON1

	bcf		STATUS,RP0		; go back to bank 0

; Finish ADC set up
	movlw	b'10000001'		; right justified, Vss and Vdd as refs, AN0 is on
	movwf	ADCON0			; turn ADC module on


;************************************************************************************
; Main - Calls the function to initialized the LCD registers, then reads the output
;        from the temperature sensor, converts this value to degrees C, and displays
;        this value on the LCD.
;************************************************************************************
Main
	call	InitLCD			; Initialize LCD Special Function Registers

; Main program loop
Loop
	btfss	INTCON,T0IF		; Wait for TMR0 to overflow at 32ms
	goto	Loop
	bcf		INTCON,T0IF

GetTemperature
	banksel ADCON0			; Do A-to-C conversion
	bsf 	ADCON0,1
	btfsc	ADCON0,1		; Wait for result before proceeding
	goto	$-1
	banksel	ADRESH
	movf	ADRESH,w		; store high two bits in TempHigh
	banksel TempHigh
	movwf	TempHigh
	banksel	ADRESL
	movf	ADRESL,w		; store lower bits in TempLow
	banksel	TempLow
	movwf	TempLow

CheckForValidity
	bcf		Flag,InvalidTemp	; clear flag that indicates temperature is invalid
	movf	TempHigh,w			; Are bits 9 or 10 set?
	btfss	STATUS,Z			
	goto	CheckForOverTemp	; Yes, then check for an over temperature condition
CheckForUnderTemp				; No, then check for an under temperature condition
	movlw	.22					; If the the low order bits are under 22 then the temperature is under -40C
	subwf	TempLow,w
	btfss	STATUS,C
	bsf		Flag,InvalidTemp
	goto	EndCheck
CheckForOverTemp
	movlw	.1					; make sure high order byte only has a 1
	subwf	TempHigh,w
	btfss	STATUS,Z
	goto	NotValid
	movlw	.102				; then check to make sure the low order byte isn't over 102
	subwf	TempLow,w
	btfsc	STATUS,C
NotValid
	bsf		Flag,InvalidTemp
EndCheck

ConvertToTemperature		; Temperature = (AN0/2) - 50  "in Celcius"
	rrf		TempHigh,f		; bit 10 is never set so it is ignored
	rrf 	TempLow,f
	bcf		Flag,Negative
	movlw	.50				; Subtract 50
	subwf	TempLow,f
	btfsc	STATUS,C		; is value negative?
	goto	CheckAgainstStoredValue
	comf	TempLow,f		; make a negative value unsigned
	bsf		Flag,Negative
CheckAgainstStoredValue 		
	movf	TempLow,w		; check against the stored temperature value
	xorwf	TempSave,w
	btfsc	STATUS,Z		; if the value is the same then check for consistancy
	goto	CheckForConsistancy
	clrf	Counter			; else, save the temperature value
	movf	TempLow,w
	movwf	TempSave
	goto	Loop

CheckForConsistancy			; if the same value is read 4 times then display the
	incf	Counter,f		;  temperature
	btfss	Counter,2		
	goto	Loop
	clrf	Counter

DisplayTemperature			; display the temperature
	call	InitLCD			; clear the display first
	btfsc	Flag,InvalidTemp  ; If temperature is invalid then indicate that with "---"
	goto	DisplayDashDashDash
	btfsc	Flag,Negative	; If the Negative flag is set then display negative sign 
	call	DisplayNeg
	movf	TempLow,w		; first convert the hexidecemal value to binary coded decimal
	call	ConvertToBCD
	movwf	TempBCD			; the ones and tens decimal values are returned in W
	movf	TempBCD,w
	andlw	0x0F
	call	DisplayDigit2
	swapf	TempBCD,w
	andlw	0x0F
	call	DisplayDigit3
	movlw	0x00
	btfsc	Flag,Overflow	; the hundred value is returned in Overflow flag
	movlw	0x01
	call	DisplayDigit4	
	movlw	0x0C			; Display C for Celcius in the first digit
	call	DisplayDigit1
	goto	Loop

DisplayDashDashDash			; Display "---"
	banksel	LCDDATA0
	bsf		LCDDATA5,7		; segment 1g  (s1g in LCD.asm)
	bsf		LCDDATA5,5		; segment 2g  (s2g in LCD.asm)
	bsf 	LCDDATA4,3		; segment 3g  (s3g in LCD.asm)
	clrf	STATUS
	goto	Loop

;**********************************************************************
; ConvertToBCD
; Converts a hexidecimal number to binary coded decimal
; Example: 0x7D becomes 125
;**********************************************************************
ConvertToBCD
	movwf	Temp
	incf	Temp,f
	clrf	BCDValue
	bcf 	Flag,Overflow
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
	movf	BCDValue,w
	andlw	0xF0
	xorlw	0xA0
	btfss	STATUS,Z
	goto	ConvertLoop
	movlw	0x60
	addwf	BCDValue,f
	bsf 	Flag,Overflow
	goto	ConvertLoop
EndConvertToBCD
	movf	BCDValue,w
	return

	END						; directive 'end of program'
