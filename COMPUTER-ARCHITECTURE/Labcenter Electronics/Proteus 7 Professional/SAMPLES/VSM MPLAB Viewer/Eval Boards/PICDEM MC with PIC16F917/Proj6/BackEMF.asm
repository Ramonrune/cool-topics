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
;   Filename:       BackEMF.asm                                          
;   Date:           April 18, 2005                                           
;   File Version:   1.00                                              
;                                                                                                 
;   Company:        Microchip Technology Inc.                         
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          BackEM.inc
;          LCD.inc
;          16f917.lkr
;          LCD.asm
;                                                                     
;************************************************************************************
;                                                                     
;    Notes: This project measures the Back Electromagnetic Flux (EMF) produced by
;           a brushed DC motor.  The windings of a brushed dc motor (or any number of
;           other motors) will produce a voltage when the motor is spinning that is
;           proportional to the speed of the motor.  Therefor if a motor is being 
;           driven, and the drive voltage is temporarily removed from the motor, the
;           voltage across the windings can be measured and the approximate speed of
;           the motor deduced.
;
;    Connections:
;     POT1 (J4) to RA0 (J13)
;     BACK EMF (J16) to RA4 (J13)
;     P1 (J1) to RD7 (J10)
;     N2 (J1) to CCP2 (J10)                                 
;                                                                     
;************************************************************************************

	#include	<BackEMF.inc>		
	

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
	bsf 	TRISA,0			; RA0 is an input
	bsf		TRISA,4			; RA4 is an input
	bsf		TRISA,5			; RA5 is an input
	bcf 	TRISD,7			; RD7 is an output
	bcf		TRISD,2			; RD2 is an output
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set up A-to-D Module
	movlw	b'00010001'		; enable AN0 and AN4
	movwf	ANSEL
	movlw	b'01100000'		; Fosc/16
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
	movlw	b'00010001'		; left justified, AN4 selected, module on
	movwf	ADCON0

; Configure Capture Compare PWM Module
	clrf	CCPR2L
	movlw	b'00001100'		; pwm mode
	movwf	CCP2CON
	bsf 	T2CON,TMR2ON	; turn on PWM


	clrf	PORTD			; Turn off Motor

;************************************************************************************
; Main - Sets the speed of the motor based on the position of POT1.
;        The Back EMF is measured, converted to RPM, and then displayed.
;
;************************************************************************************
Main
	call	InitLCD			; Initialize LCD Special Function Registers
	bsf		P1				; Turn on P-Channel MOSFET
	clrf	Pointer
	clrf	TimeKeeper
	
Loop
	btfss	INTCON,T0IF		; Every 32.768ms exit this loop and do something
	goto	Loop
	bcf		INTCON,T0IF
	incf	TimeKeeper,f	; This keeps track of the number of time intervals gone by

	call	ReadBackEMF		; Read the Back EMF 
	call	SetMotorSpeed   ; Set the speed of the motor based on the position of POT1
	btfss	TimeKeeper,5	; Every 1.048 seconds display the RPM (Displayed value = RPM x 10^3)
	goto	EndLoop
	call	DisplayRPM		
	clrf	TimeKeeper	
	
EndLoop
	goto	Loop

;************************************************************************************
; ReadBackEMF - Read the Back EMF, store the value in a 64-byte circular buffer, 
;  calculate the average of the values in the buffer, and convert this average to 
;  RPM.      
;
;************************************************************************************
ReadBackEMF					; Read Back EMF and store
	bcf 	P1				; Turn off P-Channel MOSFET
	movlw	0xF0
	andwf	CCP2CON,f		; Turn off PWM
	nop
	bsf		N2				; Turn on N-Channel MOSFET
	movlw	0x50
	movwf	Counter
Delay						; Delay for approx 120us (0x50 * 3 instructions * 4/Fosc)
	decfsz	Counter,f
	goto	Delay

	movlw	0x3F	
	andwf	Pointer,w		; pointer is a rolling pointer from 0 to 63
	addlw	BackEMFValue
	movwf	FSR				; point to next storage byte
	clrf	STATUS			; IRP bit needs to be clear
	bsf		ADCON0,GO_DONE  ; Start A-to-D conversion
ReadBEMFLoop
	btfsc	ADCON0,GO_DONE	; Wait for conversion to complete
	goto	ReadBEMFLoop
	movf	ADRESH,w		; Store Back EMF value in buffer
	movwf	INDF
	incf	Pointer,f
	movlw	b'00000001'		; aquire AN0 in preparation for POT1 read
	movwf	ADCON0
	
TurnOnMotor
	movlw	0x0F			; Turn on PWM
	iorwf	CCP2CON,f
	bsf		P1				; Turn on P-Channel MOSFET

	call	AverageBEMF		; Find the average Back EMF Value and Convert to RPM
	return

;************************************************************************************
; SetMotorSpeed - Read the analog voltage output by the potentiometer.  Move this 
;  8-bit value into the duty cycle registers of the CCP2 module.  This module is 
;  running with a duty cycle resolution of 8-bits in order to produce a frequency of
;  31.2kHz.  This frequency is sufficient high to prevent the motor for making an
;  annoying whine at low speeds. (31.2kHz is outside the audible range of the human
;  ear.)    
;
;************************************************************************************
SetMotorSpeed
	bsf 	ADCON0,GO_DONE
ReadPOT1Loop
	btfsc	ADCON0,GO_DONE
	goto	ReadPOT1Loop
	movf	ADRESH,w		; store POT1 ADC value
	movwf	DutyCycle
	movlw	b'00010001'		; aquire AN4 in preparation for Back EMF read
	movwf	ADCON0

	swapf	DutyCycle,w			;  bits 4 and 5 of CCP2CON
	andlw	0x30
	iorlw	0x8D
	movwf	CCP2CON
	rrf 	DutyCycle,f			; move most significant 6 bits of duty cycle into
	rrf 	DutyCycle,w			;  CCPR2L
	andlw	0x3F
	movwf	CCPR2L
	return

;************************************************************************************
; DisplayRPM - Convert RPM to binary coded decimal and display the 3 most significant
;  bits (thousands, hundreds, and tens.
;
; Example: RPM = 4520
;  Display will show 4.52 K (K indicates the display number should be multiplied by 
;                            1000)     
;
;************************************************************************************
DisplayRPM
	movf	RPM_High,w
	movwf	H_byte
	movf	RPM_Low,w
	movwf	L_byte
	call	ConvertToBCD		; This function is taken from AN526. Why write code that is already written?
	
	swapf	R2,w				; This is the Tens digit
	andlw	0x0F
	call	DisplayDigit1
	movf	R1,w				; This is the Hundreds digit
	andlw	0x0F
	call	DisplayDigit2		
	swapf	R1,w				; This is the Thousands digit
	andlw	0x0F
	call	DisplayDigit3
	call	Display3DP			; Put the decimal point between the hundreds and thousands digits
	call	DisplayK			; Display K to indicate RPM = (value on LCD) * 1000
	return

;************************************************************************************
; AverageBEMF - Adds all 64 BackEMF values that are stored.  This number is divided
;  by 64.  This gives the average Back EMF value.  This number is then muliplied by
;  26.  (In actuality, the divide by 64 and multiply by 26 are done simultaneously) 
;
;************************************************************************************
AverageBEMF
	clrf	STATUS
	clrf	Math_Low
	clrf	Math_High
	movlw	BackEMFValue
	movwf	FSR
	movlw	.64
	movwf	Counter
AddLoop						; Add up all 64 Back EMF measurements stored in the circular buffer
	movf	INDF,w
	addwf	Math_Low,f
	btfsc	STATUS,C
	incf	Math_High,f
	incf	FSR,f
	decfsz	Counter,f
	goto	AddLoop
ConvertToRPM				; We have to divide by 64 and then multiple by 26.  Why not do it simultaneously?
AverageAndMultiply          ; Divide by 64 while multiplying by 26 (26 = 16+8+2)
	bcf		STATUS,C
	rrf		Math_High,f		; /4 (multiply by 16)
	rrf		Math_Low,f
	rrf		Math_High,f	
	rrf		Math_Low,f
	movf	Math_Low,w	
	andlw	b'11110000'
	movwf	RPM_Low
	movf	Math_High,w
	andlw	b'00001111'
	movwf	RPM_High
	bcf		STATUS,C
	rrf		Math_High,f		; /8 (add multiply by 8)
	rrf		Math_Low,f
	movf	Math_Low,w
	andlw	b'11111000'
	addwf	RPM_Low,f
	btfsc	STATUS,C
	incf	RPM_High,f
	movf	Math_High,w
	andlw	b'00000111'
	addwf	RPM_High,f
	bcf		STATUS,C
	rrf		Math_High,f		; /32 (add multiply by 2)
	rrf		Math_Low,f	
	rrf		Math_High,f
	rrf		Math_Low,f	
	movf	Math_Low,w
	andlw	b'11111110'
	addwf	RPM_Low,f
	btfsc	STATUS,C
	incf	RPM_High,f
	movf	Math_High,w
	andlw	b'00000001'
	addwf	RPM_High,f	
	return

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
