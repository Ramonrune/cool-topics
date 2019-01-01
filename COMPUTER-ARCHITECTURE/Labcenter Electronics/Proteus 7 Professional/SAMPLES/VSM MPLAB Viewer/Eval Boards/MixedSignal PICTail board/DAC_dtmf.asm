 #include "p16F767.inc"
;*************************************************************************
;
;	DTMF SUBROUTINE using a Rolling Loop Timer
;
;	Program memory	= 149 words for 32 step tone subroutine
;				= 133 words for 16 step tone subroutine
;	Data memory 		= 12 registers for tone subroutine
;
;*************************************************************************
;
;	THEORY OF OPERATION - ROLLING LOOP TIMER
;	2's complement subtraction of a marked time and a continuous timer
;	(overflows from 0FFh to 0h) provides an elapsed time which can then
;	be compared to some threshold value (another subtraction).  The
;	result of the compare (<, > or =) can then be used to perform some
;	periodic event.  The fewest possible cycles per loop is desired to
;	achieve the least amount of error from the "zero" cycle (when the
;	result of the compare is "=").  One major advantages of this 
;	technique is the ability to use only one timer to keep track of 
;	several independent periodic events with relatively few instructions
;	and instruction cycles.
;
;	THEORY OF OPERATION - DISTORTION
;	This routine works with relatively low distortion because the
;	statistical distribution of the possible error cycles doesn't peak
;	at the "zero" cycle but at some repeatable value relative to the
;	"zero" cycle.  Error cycles will be +-X from the distribution's
;	peak instead of from the "zero" cycle.
;
;	THEORY OF OPERATION - LOOP TIMING
;	LOW	- No update yet = 6 cycles
;		- Update output w/o resetting Sine_Table = 18
;		- Update output w/reset of Sine_Table = 19
;	HIGH	- No update yet = 6 cycles
;		- Update output w/o resetting Sine_Table = 18
;		- Update output w/reset of Sine_Table & ToneLength = 22
;		(Note: end of Tone until Repeat_tone re-enters >11 cycles
;			depending upon user's code)
;	OUTPUT	- 5 cycles
;
;	THEORY OF OPERATION - CHOOSING # OF STEPS
;	Using the above #s:
;		Minimum loop = 17 cycles
;		Maximum loop = 46 cycles
;		Maximum Low distortion = 5 + 22 + 5 = 32
;		Maximum High distortion = 5 + 19 + 5 = 29
;
;	These numbers need to be taken into consideration when choosing Fosc
;	and the # of steps.  Obviously, there is a balance between adding
;	more steps (doesn't have to be 2^X # of steps) and the distortion
;	caused by not executing the minimum loop very often.  The user could
;	model this with most mathematical software packages to determine 
;	what is best for their system.
;
;*************************************************************************
DTMF		UDATA
F_Low 			RES	1	;# of cycles for the low frequency
F_Low_Rolling		RES	1	;last value of TMR0 when F_Low_Out was updated
F_Low_Step		RES	1	;SINE table index
F_Low_Out		RES	1	;Output duty cycle for F_Low
F_High			RES	1	;# of cycles for the high frequency
F_High_Rolling		RES	1	;last value of TMR0 when F_High_Out was updated
F_High_Step		RES	1	;SINE table index
F_High_Out		RES	1	;Output duty cycle for F_High
DTMF_Out		RES	1	;Output for DAC
ToneLength		RES	1	;# of F_High cycles used for delay
Key_Value		RES	1	;what # to dial?

 GLOBAL	F_Low, F_Low_Rolling,F_Low_Step, F_Low_Out, F_High, F_High_Rolling
 GLOBAL	F_High_Step, F_High_Out, DTMF_Out, ToneLength, Key_Value
 GLOBAL	Tone, Repeat_tone
 EXTERN	DAC_MSB, DAC_LSB, WriteToMCP492X

DTMF_SUB		CODE
;
;	Conditional Assembly Control Words
;				;No = 0, Yes = 1
#DEFINE Fosc_8000000	1	;8MHz oscillator
#DEFINE Fosc_4000000	0	;4MHz oscillator
#DEFINE Fosc_3570000	0	;3.57MHz oscillator

  if Fosc_8000000
#DEFINE _32_steps		0	;32 steps per cycle
#DEFINE _16_steps		1	;16 steps per cycle
#DEFINE ToneLength_100	0	;100 ms tone per subroutine call
#DEFINE ToneLength_50	1	;50 ms tone per subroutine call
  endif
  if Fosc_4000000 | Fosc_3570000
#DEFINE _32_steps		0	;32 steps per cycle
#DEFINE _16_steps		1	;16 steps per cycle
#DEFINE ToneLength_100	0	;100 ms tone per subroutine call
#DEFINE ToneLength_50	1	;50 ms tone per subroutine call
  endif

  if  _32_steps
;
;*************************************************************************
;	This is a 32 level lookup table of a 7 bit SINE wave
;		Y = 7 bit result	X = step #
;
;	Y = 63 + 64 * Sin (X * 360 / 32)
;
SINE_Table_7bit		;32 step
	addwf	PCL,F
	nop		;this location is never used since W != 0
 DT	.63,  .75,  .87,  .99,  .108, .116, .122, .126
 DT	.127, .126, .122, .116, .108, .99,  .87,  .75
 DT	.63,  .51,  .39,  .27,  .18,  .10,  .4,   .1
 DT	.0,   .1,   .4,   .10,  .18,  .27,  .39,  .51
  endif

;  if _32_steps & _8_bit
;***************************************************************************************
;	32 step lookup table of an 8 bit SINE wave
;		Y = 8 bit result
;		X = step #
;	Y = 127 + 128 * Sin (X * 360 / 32)
;
;SINE_Table_32step_8bit
;	addwf	PCL,F
;	nop		;this location is never used since W != 0
; DT	.127,  .152,  .176,  .198,  .218, .233, .245, .253
; DT	.255, .253, .245, .233, .218,  .198,  .176, .152
; DT	.127,  .102,  .78,  .56,  .36,  .21,  .9,   .1
; DT	.0,   .1,   .9,   .21,  .36,  .56,  .78,  .102
;  endif

  if  _16_steps
;
;*************************************************************************
;	This is a 16 level lookup table of a 7 bit SINE wave
;		Y = 7 bit result	X = step #
;
;	Y = 63 + 64 * Sin (X * 360 / 16)
;
SINE_Table_7bit		;16 step
	addwf		PCL,F
	nop			;this location is never used since W != 0
 DT	.63,  .87,  .108, .122
 DT	.127, .122, .108, .87
 DT	.63,  .39,  .18,  .4
 DT	.0,   .4,   .18,  .39
  endif

; 
;*************************************************************************
;
;   		DTMF Frequency Tables
;
;		Key	Low	High
;		0	941	1336
;		1	697	1209
;		2	697	1336
;		3	697	1477
;		4	770	1209
;		5	770	1336
;		6	770	1477
;		7	852	1209
;		8	852	1336
;		9	852	1477
;		A	697	1633
;		B	770	1633
;		C	852	1633
;		D	941	1633
;		*	941	1209
;		#	941	1477

  if  ((_32_steps) & (Fosc_8000000)) | ((_16_steps) & (Fosc_4000000))
;
;*************************************************************************
;
;		Delay Calculation for Frequency Generation
;		Fosc = 8MHz		#steps = 32
;				OR
;		Fosc = 4MHz		#steps = 16
;
;		X = Fosc / ( 4 * #steps * Ftone)
;
;
F_Low_table
	addwf		PCL,F
		;X	Actual		Desired		%Error
	retlw	.66	;947.0		941		.63%
	retlw	.90	;694.4		697		.37%
	retlw	.90	;694.4		697		.37%
	retlw	.90	;694.4		697		.37%
	retlw	.81	;771.6		770		.21%
	retlw	.81	;771.6		770		.21%
	retlw	.81	;771.6		770		.21%
	retlw	.73	;856.2		852		.49%
	retlw	.73	;856.2		852		.49%
	retlw	.73	;856.2		852		.49%
	retlw	.90	;694.4		697		.37%
	retlw	.81	;771.6		770		.21%
	retlw	.73	;856.2		852		.49%
	retlw	.66	;947.0		941		.63%
	retlw	.66	;947.0		941		.63%
	retlw	.66	;947.0		941		.63%

F_High_table
	addwf	PCL,F
		;X	Actual		Desired		%Error
	retlw	.47	;1329.8		1336		.47%
	retlw	.52	;1201.9		1209		.59%
	retlw	.47	;1329.8		1336		.47%
	retlw	.42	;1488.1		1477		.75%
	retlw	.52	;1201.9		1209		.59%
	retlw	.47	;1329.8		1336		.47%
	retlw	.42	;1488.1		1477		.75%
	retlw	.52	;1201.9		1209		.59%
	retlw	.47	;1329.8		1336		.47%
	retlw	.42	;1488.1		1477		.75%
	retlw	.38	;1644.7		1633		.72%
	retlw	.38	;1644.7		1633		.72%
	retlw	.38	;1644.7		1633		.72%
	retlw	.38	;1644.7		1633		.72%
	retlw	.52	;1201.9		1209		.59%
	retlw	.42	;1488.1		1477		.75%
  endif

  if  _16_steps & Fosc_8000000
;
;*************************************************************************
;
;		Delay Calculation for Frequency Generation
;		Fosc = 8MHz		#steps = 16
;
;		X = Fosc / ( 4 * #steps * Ftone)
;
;
F_Low_table
	addwf		PCL,F
		;X	Actual		Desired		%Error
	retlw	.133	;939.8		941		.12%
	retlw	.179	;698.3		697		.19%
	retlw	.179	;698.3		697		.19%
	retlw	.179	;698.3		697		.19%
	retlw	.162	;771.6		770		.21%
	retlw	.162	;771.6		770		.21%
	retlw	.162	;771.6		770		.21%
	retlw	.147	;850.3		852		.19%
	retlw	.147	;850.3		852		.19%
	retlw	.147	;850.3		852		.19%
	retlw	.179	;698.3		697		.19%
	retlw	.162	;771.6		770		.21%
	retlw	.147	;850.3		852		.19%
	retlw	.133	;939.8		941		.12%
	retlw	.133	;939.8		941		.12%
	retlw	.133	;939.8		941		.12%

F_High_table
	addwf	PCL,F
		;X	Actual		Desired		%Error
	retlw	.94	;1329.8		1336		.47%
	retlw	.103	;1213.6		1209		.37%
	retlw	.94	;1329.8		1336		.47%
	retlw	.85	;1470.6		1477		.43%
	retlw	.103	;1213.6		1209		.37%
	retlw	.94	;1329.8		1336		.47%
	retlw	.85	;1470.6		1477		.43%
	retlw	.103	;1213.6		1209		.37%
	retlw	.94	;1329.8		1336		.47%
	retlw	.85	;1470.6		1477		.43%
	retlw	.77	;1623.4		1633		.59%		; may run out of tcy and be too slow
	retlw	.77	;1623.4		1633		.59%		; may run out of tcy and be too slow
	retlw	.77	;1623.4		1633		.59%		; may run out of tcy and be too slow
	retlw	.77	;1623.4		1633		.59%		; may run out of tcy and be too slow
	retlw	.103	;1213.6		1209		.37%
	retlw	.85	;1470.6		1477		.43%
  endif


  if  _16_steps & Fosc_3570000
;
;*************************************************************************
;
;		Delay Calculation for Frequency Generation
;		Fosc = 3.57MHz		#steps = 16
;
;		X = Fosc / ( 4 * #steps * Ftone)
;
F_Low_table
	addwf		PCL,F
		;X	Actual		Desired		%Error
	retlw	.59	;945.5		941		.47%
	retlw	.80	;697.3		697		.04%
	retlw	.80	;697.3		697		.04%
	retlw	.80	;697.3		697		.04%
	retlw	.72	;774.7		770		.72%
	retlw	.72	;774.7		770		.72%
	retlw	.72	;774.7		770		.72%
	retlw	.65	;858.2		852		.65%
	retlw	.65	;858.2		852		.65%
	retlw	.65	;858.2		852		.65%
	retlw	.80	;697.3		697		.04%
	retlw	.72	;774.7		770		.72%
	retlw	.65	;858.2		852		.65%
	retlw	.59	;945.5		941		.47%
	retlw	.59	;945.5		941		.47%
	retlw	.59	;945.5		941		.47%

F_High_table
	addwf		PCL,F
		;X	Actual		Desired		%Error
	retlw	.42	;1328.1		1336		.59%
	retlw	.46	;1212.6		1209		.30%
	retlw	.42	;1328.1		1336		.59%
	retlw	.38	;1467.9		1477		.61%
	retlw	.46	;1212.6		1209		.30%
	retlw	.42	;1328.1		1336		.59%
	retlw	.38	;1467.9		1477		.61%
	retlw	.46	;1212.6		1209		.30%
	retlw	.42	;1328.1		1336		.59%
	retlw	.38	;1467.9		1477		.61%
	retlw	.34	;1640.6		1633		.47%
	retlw	.34	;1640.6		1633		.47%
	retlw	.34	;1640.6		1633		.47%
	retlw	.34	;1640.6		1633		.47%
	retlw	.46	;1212.6		1209		.30%
	retlw	.38	;1467.9		1477		.61%
  endif

  if  ((_32_steps & Fosc_8000000 & ToneLength_100)|(_16_steps & Fosc_8000000 & ToneLength_50)|(_16_steps & Fosc_4000000 & ToneLength_100))
;
;*************************************************************************
;
;		Tone Length Calculation
;
;	desired_length = 200ms		Fosc = 8MHz	#steps = 16
;				OR
;	desired_length = 100ms		Fosc = 8MHz	#steps = 32
;
;	X is from the delay calc for F_High
;
;	ToneLength = (desired_length * Fosc) / (32 * X * 4)
;
;
ToneLength_table
	addwf		PCL,F
	retlw	.133
	retlw	.120
	retlw	.133
	retlw	.149
	retlw	.120
	retlw	.133
	retlw	.149
	retlw	.120
	retlw	.133
	retlw	.149
	retlw	.164
	retlw	.164
	retlw	.164
	retlw	.164
	retlw	.120
	retlw	.149
  endif

  if  _16_steps & Fosc_4000000 & ToneLength_50
;
;*************************************************************************
;
;		Tone Length Calculation
;
;	desired_length = 50ms		Fosc = 4MHz	#steps = 16
;
;	X is from the delay calc for F_High
;
;	ToneLength = (desired_length * Fosc) / (16 * X * 4)
;
;
ToneLength_table
	addwf		PCL,F
	retlw	.149
	retlw	.136
	retlw	.149
	retlw	.164
	retlw	.136
	retlw	.149
	retlw	.164
	retlw	.136
	retlw	.149
	retlw	.164
	retlw	.184
	retlw	.184
	retlw	.184
	retlw	.184
	retlw	.136
	retlw	.164
  endif

  if  _16_steps & Fosc_3570000 & ToneLength_50
;
;*************************************************************************
;
;		Tone Length Calculation
;
;	desired_length = 50ms		Fosc = 3.57MHz	#steps = 16
;	X is from the delay calc for F_High
;
;	ToneLength = (desired_length * Fosc) / (16 * X * 4)
;
;
ToneLength_table
	addwf		PCL,F
	retlw	.133
	retlw	.121
	retlw	.133
	retlw	.147
	retlw	.121
	retlw	.133
	retlw	.147
	retlw	.121
	retlw	.133
	retlw	.147
	retlw	.164
	retlw	.164
	retlw	.164
	retlw	.164
	retlw	.121
	retlw	.147
  endif

Tone			;The following Syncs the SINE wave and the Timer
			;Initialize all registers for startup
	movlw		HIGH SINE_Table_7bit
	movwf		PCLATH
  if  _32_steps
	movlw		.32
  endif
  if  _16_steps
	movlw		.16
  endif
	movwf		F_Low_Step
	movwf		F_High_Step
	movlw		01Fh
	movwf		F_Low_Out
	movwf		F_High_Out
	movf		TMR0,W
	movwf		F_Low_Rolling
	movwf		F_High_Rolling
	movlw		0Fh
	andwf		Key_Value,F
	movf		Key_Value,W
	call		F_Low_table
	movwf		F_Low
	movf		Key_Value,W
	call		F_High_table
	movwf		F_High
Repeat_tone				;Call here to repeat the tone for ToneLength
					;The following inits the ToneLength delay reg's
	movf		Key_Value,W
	call		ToneLength_table
	movwf		ToneLength
	
test_F_Low					;Low frequency tone loop timer
	movf		F_Low_Rolling,W
	subwf		TMR0,W		;result = time since last update
	subwf		F_Low,W		;Carry bit determines if enough time has elapsed
	btfsc		STATUS,C
	goto		test_F_High		;do not update the SINE wave yet
	movf		F_Low,W
	addwf		F_Low_Rolling,F	;Very Important to add to the last reference
						;instead of using the actual timer value
	decfsz		F_Low_Step,F		;update the step count
	goto		no_reset_F_Low_Step
  if  _32_steps
	movlw		.32
  endif
  if  _16_steps
	movlw		.16
  endif
	movwf		F_Low_Step
no_reset_F_Low_Step
	movf		F_Low_Step,W
	call		SINE_Table_7bit	;fetch the corresponding Sin value
	movwf		F_Low_Out		;store result
	
test_F_High					;High frequency tone loop timer
	movf		F_High_Rolling,W
	subwf		TMR0,W		;result = time since last update
	subwf		F_High,W		;Carry bit determines if enough time has elapsed
	btfsc		STATUS,C
	goto		update_output		;do not update the SINE wave yet
	movf		F_High,W
	addwf		F_High_Rolling,F	;Very Important to add to the last reference
						;instead of using the actual timer value
	decfsz		F_High_Step,F		;update the step count
	goto		no_reset_F_High_Step
  if  _32_steps
	movlw		.32
  endif
  if  _16_steps
	movlw		.16
  endif
	movwf		F_High_Step
						;ToneLength timer
	decfsz		ToneLength,F
	goto		no_reset_F_High_Step
						;ToneLength time expired, Exit subroutine
	retlw		00h
	
no_reset_F_High_Step
	movf		F_High_Step,W
	call		SINE_Table_7bit	;fetch the corresponding Sin value
	movwf		F_High_Out		;store result

update_output			;Sum the 2 7-bit SINE outputs & refresh the D/A converter
				;We can output one frequency at a time for test purposes
				;w/o changing any timing! (Notice the sine wave quality)
	movf		F_High_Out,W		;comment this line for Low frequency Only
;	addwf		F_High_Out,W		;uncomment this line for High frequency Only

;	movf		F_Low_Out,W		;uncomment this line for Low frequency Only
	addwf		F_Low_Out,W		;comment this line for High frequency Only
	movwf		DTMF_Out
	xorwf		DAC_LSB,W
	btfsc		STATUS,Z		; nothing changed so continue looping
	goto		test_F_Low

;	movf		DTMF_Out,W		; Use this if seeking an 8b result
;	movwf		PORTB			; Use this if R2R on PortB
;	movwf		CCPR1L			; Use this if utilizing a HW PWM... shifted R for speed.
	swapf		DTMF_Out,W		; Use this for L shift 8b -> 12b result
	movwf		DAC_LSB		; should mask the 4 LSBs... if we were getting picky
	iorlw		b'11110000'		; Use this for 12b result , set DAC B, Vref Buffered, 1x Gain
	movwf		DAC_MSB		; Use this for 12b result, otherwise let it default to preload
	call		WriteToMCP492X	; takes 30 Tcy using HW SPI
	goto		test_F_Low

tone_done

 end
