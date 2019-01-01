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
;   Company:        Microchip Technology Inc.                         
;                                                                     
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          Clock.inc 
;		   16f917.lkr
;          LCD.inc
;          LCD.asm                                                         
;                                                                     
;                                                                     
;************************************************************************************
;                                                                     
;    Notes: This project implements a real-time clock using the 32.768kHz crystal.
;           The crystal gives a reliable time base compared to the internal RC                                                                   
;           oscillator on-board the PIC16F917.  The RC oscillator may be off by
;           +- 1%.  The crystal in combination with some circuitry internal to the 
;           PIC microcontrontroller drives Timer 1 at a frequency of 32.768kHz.  Bit
;           6 gives a 1/2 second time period.  This is used as the basis for keeping 
;           time and blinking the decimal point at a 1/2 second rate.
;           - SW2 is used to set the hours (note the "A" for indication AM)
;           - SW3 is used to set minutes
;           - SW4 toggles between displaying hours/minutes and seconds 
;
;    Connections:
;     OSI (J4) to T1OSI (J13)
;     OSO (J4) to T1OSO (J13)
;     SW2 (J4) to RA3 (J13)
;     SW3 (J4) to RA4 (J13)
;     SW4 (J4) to RA5 (J13)                                                                 
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
	bsf		TRISA,5			; RA5 is an input
	bsf		TRISA,4			; RA4 is an input
	bsf		TRISA,3			; RA3 is an input
; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	movlw	B'10000110'		;PORTB PULL-UP DISABLED
	movwf	OPTION_REG		;TMR0 RATE 1:128
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators
; Turn off Analog 
	clrf	ANSEL

	bcf		STATUS,RP0		; go back to bank 0

; Set up Timer 1
	movlw	b'00001011'		; Use external oscillator
	movwf	T1CON


;************************************************************************************
; Main - The main loop makes the time, displays the time, and responds to button 
;  presses from the user.
;
;************************************************************************************
Main
	call	InitLCD			; Initialize LCD Special Function Registers
	clrf	Second			; Display 12:00 on startup
	clrf	Minute
	movlw	.12
	movwf	Hour
	clrf	TimeBaseMultiple ; This variable is keep track of the number of 1/2 second intervals
	clrf	Flag			
	clrf	StateSW2
	clrf	StateSW3
	clrf	StateSW4
	bsf		TMR1H,6			; Make sure the first time around the code displays something

; Main program loop
Loop
	call	ServiceSwitches ; Looks for button presses an whether or not a switch debounce routine is currently being executed
	btfss	TMR1H,6			; 1/2 second will be our timebase (when bit 6 is set 1/2 second has passed
	goto	Loop
	bcf		TMR1H,6
	incf	TimeBaseMultiple,f ; Keep track of 1/2 second intervals (bit 0 is 1 at 1 second intervals, bit 1 is 1 at 2 second intervals, etc.)

; Every 1/2second do this
	call	BlinkDot			; toggle blink flag
	call	DisplayTime			; Display either seconds or Hour and Minutes dempending on mode

; Every 1 second do this
	btfsc	TimeBaseMultiple,0
	goto	EndLoop
	call	MakeTime			; Constuct the time (increment seconds, minutes, hours appropiately)

EndLoop
	goto	Loop

;************************************************************************************
; BlinkDot - Toggle the flag indicating whether the blinking dot is set or not.	
;
;************************************************************************************
BlinkDot
	movlw	0x20				; Toggle Blink Flag
	xorwf	Flag,f
	return

;************************************************************************************
; DisplayTime - Display the time based on the state of the "DisplayMode" flag.  	
;
;************************************************************************************
DisplayTime
	call	InitLCD				; Clear display momentarily
	btfsc	Flag,Blink			; If the Blink flag is set then display the dot
	call	Display3DP
	btfsc	Flag,DisplayMode	; Display either seconds or Hour and Minutes depending on mode
	call	DisplaySeconds		
	btfss	Flag,DisplayMode
	call	DisplayHourAndMinutes 
	return

;************************************************************************************
; DisplaySeconds - Convert Seconds to Binary Coded Decimal (BCD) and then display.
;
;************************************************************************************
DisplaySeconds
	movf	Second,w
	call	ConvertToBCD
	movwf	SecondBCD

	movf	SecondBCD,w
	andlw	0x0F
	call	DisplayDigit1
	swapf	SecondBCD,w	
	andlw	0x0F
	call	DisplayDigit2
	return

;************************************************************************************
; DisplayHourAndMinutes - Convert Hours and Minutes	to BCD and display.
;
;************************************************************************************
DisplayHourAndMinutes
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
	btfss	Flag,AMorPM
	call	DisplayA
	return

;************************************************************************************
; MakeTime - Construct seconds, minutes, and hours every 1 second.
;
;************************************************************************************
MakeTime
	call	IncrementSecond
	btfsc	STATUS,Z			; If seconds overflows (59 to 0) then the zero flag is set
	call	IncrementMinute
	btfsc	STATUS,Z			; If minutes overflows (59 to 0) then the zero flag is set
	call 	IncrementHour
	return

;************************************************************************************
; IncrementSecond - Increment seconds
;   Output - Zero flag set if Second rolls over from 59 to 0
;
;************************************************************************************
IncrementSecond
	incf	Second,f
	movf	Second,w
	xorlw	.60
	btfsc	STATUS,Z
	clrf	Second
	return

;************************************************************************************
; IncrementMinute - Increment minutes
;   Output - Zero flag set if Minute rolls over from 59 to 0
;
;************************************************************************************
IncrementMinute
	incf	Minute,f
	movf	Minute,w
	xorlw	.60
	btfsc	STATUS,Z
	clrf	Minute
	return

;************************************************************************************
; IncrementHour - Increment the hour. Toggle the "ToggleAMorPM" flag when hour
;  rolls over from 12 to 1.
;
;************************************************************************************
IncrementHour
	incf	Hour,f
	movf	Hour,w
ToggleAMorPM
	xorlw	.12
	btfss	STATUS,Z
	goto	Next
	movlw	0x10
	xorwf	Flag,f			; Change from AM to PM or vice versa
Next
	movf	Hour,w
	xorlw	.13
	btfss	STATUS,Z
	goto	EndMakeHour
	movlw	1
	movwf	Hour
	goto	EndMakeHour
EndMakeHour
	return

;************************************************************************************
; ConvertToBCD - Convert a decimal number to Binary Coded Decimal (BCD).  This
;  function only works for values less than 100.  
;
;************************************************************************************
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

;************************************************************************************
; ServiceSwitches - Checks for pressed switches.  It a switch is pressed a flag 
;  is set to indicate the switch has been pressed.  This initiates a routine that 
;  debounces the switch and also determines the functionality of the switch.  The 
;  flag is only cleared when the routine is over
;
;************************************************************************************
ServiceSwitches
	btfss	SW2						; If SW2 is pressed set a flag to begin debounce routine
	bsf		Flag,ServiceSW2
	btfss	SW3						; If SW3 is pressed set a flag to begin debounce routine
	bsf		Flag,ServiceSW3
	btfss	SW4						; If SW4 is pressed set a flag to begin debounce routine
	bsf		Flag,ServiceSW4	

	btfsc	Flag,ServiceSW2			; Set the hour if SW2 is pressed
	call	SetHour
	btfsc	Flag,ServiceSW3			; Set the minute if SW3 is pressed
	call	SetMinute
	btfsc	Flag,ServiceSW4			; Toggle between display modes when SW4 is pressed
	call	ChangeDisplay
EndServiceSwitches
	return


;************************************************************************************
; SetHour - Implements a state machine that debounces SW2 and also determines whether
;  or not SW2 was pressed momentarily or whether it is being held down. If pressed
;  momentarily then increment hour only once.  If pressed and held, then increment 
;  the hour at a rate of one hour per 1/4 second.
;
;************************************************************************************
SetHour
	movlw	high SW2StateTable
	movwf	PCLATH
	movf	StateSW2,w
	andlw	0x07			; mask off state pointer
	addlw	low SW2StateTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
SW2StateTable
	goto	SW2State0
	goto	SW2State1
	goto	SW2State2
	goto	SW2State3
	goto	SW2State4
	goto	SW2State5
	nop
	clrf	StateSW2
	bcf		Flag,ServiceSW2
	return	

SW2State0					; Check for button press
	clrf	TMR0
	bcf		INTCON,T0IF
	incf	StateSW2,f
	return

SW2State1
	btfsc	SW2				; If button is released before timeout then exit state machine
	goto	ExitStateMachine
	btfss	INTCON,T0IF		; Has 16ms passed?
	goto	EndSW2State1
	call	IncrementHour	; Yes then Increment the Hour and display it
	call	DisplayTime
	clrf	Counter			; Prepare for next time sequence where we wait to see how long
	clrf	TMR0			;  the button is pushed
	bcf		INTCON,T0IF
	incf	StateSW2,f
	goto	EndSW2State1
ExitStateMachine
	bcf		Flag,ServiceSW2
	clrf	StateSW2
EndSW2State1
	return
	
SW2State2					
	btfsc  	SW2
	goto	SW2Unpressed	; Button pressed less than 1/2 second
	btfss	INTCON,T0IF
	goto	EndSW2State2
	bcf		INTCON,T0IF
	incf	Counter,f
	btfsc	Counter,5		; if 1/2 second has passed then proceed to next state
	incf	StateSW2,f
	goto	EndSW2State2
SW2Unpressed
	movlw	2
	addwf	StateSW2,f
EndSW2State2
	return

SW2State3					; Button pressed a long time, increment hour faster
	btfsc	SW2
	incf	StateSW2,f
	btfss	INTCON,T0IF
	goto	EndSW2State3
	bcf		INTCON,T0IF
	incf	Counter,f
	btfss	Counter,4		; if 1/4 second has passed then increment hour
	goto	EndSW2State3
	bcf		Counter,4
	call	IncrementHour	
	call	DisplayTime
EndSW2State3
	return

SW2State4
	btfss	SW2				; Wait for button release
	goto	EndSW2State4
	clrf	TMR0
	bcf 	INTCON,T0IF
	incf	StateSW2,f
EndSW2State4
	return

SW2State5
	btfss	SW2
	goto	BackToSW2State1
	btfss	INTCON,T0IF
	goto	EndSW2State5
	bcf		Flag,ServiceSW2
	clrf	StateSW2
	goto	EndSW2State5
BackToSW2State1
	decf	StateSW2,f
EndSW2State5
	return

;************************************************************************************
; SetMinute - Implements a state machine that debounces SW3 and also determines whether
;  or not SW3 was pressed momentarily or whether it is being held down. If pressed
;  momentarily then increment minute only once.  If pressed and held, then increment 
;  the minute at a rate of one minute per 1/8 second.
;
;************************************************************************************
SetMinute
	movlw	high SW3StateTable
	movwf	PCLATH
	movf	StateSW3,w
	andlw	0x07			; mask off state pointer
	addlw	low SW3StateTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
SW3StateTable
	goto	SW3State0
	goto	SW3State1
	goto	SW3State2
	goto	SW3State3
	goto	SW3State4
	goto	SW3State5
	nop
	clrf	StateSW3
	bcf		Flag,ServiceSW3
	return	

SW3State0					; Check for button press
	clrf	TMR0
	bcf		INTCON,T0IF
	incf	StateSW3,f
	return

SW3State1
	btfsc	SW3				; If button is released before timeout then exit state machine
	goto	ExitSW3StateMachine
	btfss	INTCON,T0IF		; Has 16ms passed?
	goto	EndSW3State1
	call	IncrementMinute	; Yes then Increment the Minute and display it
	call	DisplayTime
	clrf	Counter			; Prepare for next time sequence where we wait to see how long
	clrf	TMR0			;  the button is pushed
	bcf		INTCON,T0IF
	incf	StateSW3,f
	goto	EndSW3State1
ExitSW3StateMachine
	bcf		Flag,ServiceSW3
	clrf	StateSW3
EndSW3State1
	return
	
SW3State2					
	btfsc  	SW3
	goto	SW3Unpressed	; Button pressed less than 1/2 second
	btfss	INTCON,T0IF
	goto	EndSW3State2
	bcf		INTCON,T0IF
	incf	Counter,f
	btfsc	Counter,5		; if 1/2 second has passed then proceed to next state
	incf	StateSW3,f
	goto	EndSW3State2
SW3Unpressed
	movlw	2
	addwf	StateSW3,f
EndSW3State2
	return

SW3State3					; Button pressed a long time, increment hour faster
	btfsc	SW3
	incf	StateSW3,f
	btfss	INTCON,T0IF
	goto	EndSW3State3
	bcf		INTCON,T0IF
	incf	Counter,f
	btfss	Counter,3		; if 1/8 second has passed then increment hour
	goto	EndSW3State3
	bcf		Counter,3
	call	IncrementMinute	
	call	DisplayTime
EndSW3State3
	return

SW3State4
	btfss	SW3				; Wait for button release
	goto	EndSW3State4
	clrf	TMR0
	bcf 	INTCON,T0IF
	incf	StateSW3,f
EndSW3State4
	return

SW3State5
	btfss	SW3
	goto	BackToSW3State1
	btfss	INTCON,T0IF
	goto	EndSW3State5
	bcf		Flag,ServiceSW3
	clrf	StateSW3
	goto	EndSW3State5
BackToSW3State1
	decf	StateSW3,f
EndSW3State5
	return

;************************************************************************************
; ChangeDisplay - Implements a state machine that debounces SW4 and toggles the
;  display mode flag.
;
;************************************************************************************
ChangeDisplay
	movlw	high SW4StateTable
	movwf	PCLATH
	movf	StateSW4,w
	andlw	0x03				; mask off state pointer
	addlw	low SW4StateTable
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
SW4StateTable
	goto	SW4State0
	goto	SW4State1
	goto	SW4State2
	goto	SW4State3

SW4State0
	movlw	0x01			; Toggle DisplayMode Flag
	xorwf	Flag,f
	call	DisplayTime		; Display the time
	incf	StateSW4,f
	return

SW4State1
	btfss	SW4				; Wait for button release
	goto	EndSW4State1
	clrf	TMR0
	bcf 	INTCON,T0IF
	incf	StateSW4,f
EndSW4State1
	return

SW4State2
	btfss	SW4
	goto	BackToSW4State1
	btfsc	INTCON,T0IF
	incf	StateSW4,f
	goto	EndSW4State2
BackToSW4State1
	decf	StateSW4,f
EndSW4State2
	return

SW4State3
	bcf		Flag,ServiceSW4
	clrf	StateSW4
	return

	END						; directive 'end of program'
