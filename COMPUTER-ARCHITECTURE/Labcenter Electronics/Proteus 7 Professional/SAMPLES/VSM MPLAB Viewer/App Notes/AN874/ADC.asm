;*********************************************************************************************
;* Software License Agreement                                                                *
;* The software supplied herewith by Microchip Technology Incorporated                       *
;* (the "Company") is intended and supplied to you, the Company's                            *
;* customer, for use solely and exclusively on Microchip products.                           *
;*                                                                                           *
;* The software is owned by the Company and/or its supplier, and is                          *
;* protected under applicable copyright laws. All rights are reserved.                       *
;* Any use in violation of the foregoing restrictions may subject the                        *
;* user to criminal sanctions under applicable laws, as well as to                           *
;* civil liability for the breach of the terms and conditions of this                        *
;* license.                                                                                  *
;*                                                                                           *
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,                         *
;* WHETHER EXPRESS, IMPLIED OR STATU-TORY, INCLUDING, BUT NOT LIMITED                        *
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                               *
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,                         *
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR                                *
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                                         *
;*                                                                                           *
;*********************************************************************************************
;***** ADC state machine                                                                     *
;* The ADC statemachine monitors the current supply voltage by measuring the voltage across  *
;* a silicon diode.  An ADC value of 20hex is typical for a 5-5.5VDC supply voltage.  An ADC *
;* value of 48hex is typical for a 3-3.5VDC supply voltage.  Based on the measured diode     *
;* voltage, a conversion factor is calculated  CF = (ADC*6 - 11) / 256. The conversion factor*
;* is a value between 166 and 232.  When multiplied by the intensity and doubled, the value  *
;* is a supply voltage corrected duty cycle.                                                 *
;* A new conversion factor is calculated by the state machine 10 times a second and the      *
;* current duty cycle is corrected on the next pass.  If the intensity is changed external to*
;* the state machine, then the int_chng flag notifies the state machine to convert the new   *
;* intensity value.                                                                          *
;* if the ADC value exceeds 2A hex, then the VDD voltage is too low and the state machine    *
;* shuts down the system.                                                                    *
;*                                                                                           *
;* ADC State machine design                                                                  *
;* Execution indexed state machine                                                           *
;*                                                                                           *
;* 	State                                                                                *
;* 0	Idle		wait state                                                           *
;* 1	Convert		do battery voltage conversion                                        *
;* 2	Calculate	correct intensity for battery voltage                                *
;* 3	LowBattery	shut down state                                                      *
;*                                                                                           *
;*                                                                                           *
;* STATE TO STATE TRANSITIONS                                                                *
;* From	Conditional				if True		if False	comments     *
;* ----------------------------------------------------------------------------------------- *
;* Idle		if intensity change		Calculate	Idle		waiting      *
;* Idle		if convert timer timeout	Convert		Idle                         *
;* Idle		if intensity change		Calculate	Idle                         *
;* Convert	none				Calculate                                    *
;* Calculate	none				Idle                                         *
;* LowBattery	shutdown                                                                     *
;*                                                                                           *
;* 	                                                                                     *
;* ACTIONS                                                                                   *
;* Idle		none                                                                         *
;* Convert	set PWM output high and convert battery voltage                              *
;* Calculate	using ADC of battery convert intensity to duty cycle                         *
;* LowBattery	shutdown                                                                     *
;*                                                                                           *
;* INPUT/OUTPUT                                                                              *
;* 		input					output                               *
;* Idle		ADC_skip_timer, Intensity_change	none                                 *
;* Convert	ADC, dutycycle				ADRESH                               *
;* Calculate	Intensity, ADRESH			dutycycle                            *
;* LowBattery	none					none                                 *
;*                                                                                           *
;* Math functions                                                                            *
;*                                                                                           *
;* DATA For Buck system                                                                      *
;* VDC	ADC	Max PWM	CF	                                                             *
;* 4.0	2E	.337	100%                                                                 *
;* 4.5	29	.385	91%                                                                  *
;* 5.0	25	.435	80%                                                                  *
;* 5.5	21	.483	72%                                                                  *
;* 6.0	1E	.535	65%                                                                  *
;*                                                                                           *
;* Maximum intensity @ 350 mV                                                                *
;*                                                                                           *
;* Conversion factor = (ADC*6 - 0B)                                                          *
;* Duty cycle        = Scaling value * Intensity * 2 / 256                                   *
;*                                                                                           *
;*********************************************************************************************

ADC					; start of ADC state machine
	btfsc	tstats,doadc		; check for the flag from the skip timer
	goto	ADC_decode		; if set then do decode
;	btfss	istats,new_int		; check for intensity change
	return				; if clear then return
	nop
ADC_decode
	movlw	0xFC			; do sanity check on state variable
	andwf	adc_state,w
	btfss	STATUS,Z
	goto	adc_error		; if larger than 3 then error

	movlw	adc_sm_tab/0x100	; compute the address of the state in the jump table
	movwf	PCLATH
	movf	adc_state,w
	andlw	0x03			; Only four states so 0-3 are only legal values
	addlw	adc_sm_tab
	movwf	PCL			; jump to state jump

adc_sm_tab
	goto	ADC_Idle		; idle state
	goto	ADC_Cnvrt		; Perform ADC conversion
	goto	ADC_Calc		; calculate change in intensity
	goto	ADC_LoBatt		; Low Battery shut down

adc_error
	bsf	estats,adc_err
	return

;*********************************************************************************************
;*****
ADC_Idle				; this state determines if an ADC conversion is needed
	btfsc	tstats,doadc
	goto	adc_convert
	btfsc	istats,new_int		; if just intensity change, then goto calculation state
	goto	adc_calculate
	return
adc_convert
	movlw	A_Cnvrt			; if time for a conversion, then goto conversion state
	movwf	adc_state
	return
adc_calculate
	movlw	A_Calc			; or if their was just an intensity change.
	movwf	adc_state
	return

;*********************************************************************************************
;***** Perform ADC conversion state (includes calculation of compensation value)

ADC_Cnvrt
	btfss	GPIO,pwm		; determine the current state of the PWM output
	goto	pwm_low
pwm_high				; if the PWM is high, then no delay before the conversion
	call 	do_adc_nowait
	goto	end_adc_cnvrt
pwm_low					; if low, it must be set high during the conversion and
	bsf	GPIO,pwm		; the aquisition time must be added prior to start of conversion
	call	do_adc_wait
	bcf	GPIO,pwm		; after the conversion is complete, the output must be driven low again

end_adc_cnvrt
	movf	ADRESH,w		; check for overflow and limit ADC value
	movwf	multa
	movlw	0x2F			; value must be <=2F, if not then battery is too low
	subwf	multa,w
	btfss	STATUS,C
	goto	math_convert
	movlw	A_Shutdn		; if value is too high, VDD too low, goto shut down state
	movwf	adc_state
	return

math_convert
	movlw	0xFF
	movwf	dead_count

	movlw	A_Calc			; next state should use the conversion factor to scale current intensity
	movwf	adc_state

	movlw	0x06			; multiply ADC value by 6
	movwf	multb
	call	Multiply
	movlw	0x0B			; subtract B3 from result
	subwf	lsbyte,w
	btfss	STATUS,C		; if borrow then decrement MSB
	decf	msbyte,f

	movwf	cnv_factor		; store the result in the conversion factor variable

	movf	msbyte,f		; test MSB for overflow
	btfsc	STATUS,Z
	return				; if non then return

	movlw	0xFF			; if overflow then max out duty cycle
	movwf	cnv_factor
	return

;*********************************************************************************************
;***** Compensate intensity value for change in battery voltage

ADC_Calc				; this state uses the conversion factor to compensate the intensity
	bcf	STATUS,C
	rlf	intensity,w		; double intensity setting for a 0-7F range
	movwf	multa
	movf	cnv_factor,w		; multiply it by the conversion factor
	movwf	multb
	call	Multiply
	movf	msbyte,w		; move the result into the duty cycle variable
	btfsc	msbyte,7		; if the result was greater than 7F, then reset to the max duty cycle
	movlw	0x7F
	movwf	dutycycle
	bcf	tstats,doadc		; clear both initiating variables
	bcf	istats,new_int
	movlw	A_Idle			; and go back to the idle state
	movwf	adc_state
	bcf	istats,new_int		; if just intensity change, then goto calculation state
	return

;*********************************************************************************************
;***** Low battery detected state

ADC_LoBatt
	decfsz	dead_count,f
	return
	movlw	0x20			; reset dead counter for recovery
	movwf	dead_count
	movlw	A_Idle			; upon recovery, goto the idle state.
	movwf	adc_state
	M_shutdown

;*********************************************************************************************
;***** ADC conversion routine with and without settling time delay
;* with settling time is needed if pwm output was low at the time of the test
;* without settling time is needed if pwm output was high at the time of the test
do_adc_wait
	goto	$+1			; 9.5 uS aquisition time
	goto	$+1
	goto	$+1
	goto	$+1
	goto	$+1
	goto	$+1			; 9.5 uS aquisition time
	goto	$+1
	goto	$+1
	goto	$+1
	goto	$+1
do_adc_nowait
	bsf	ADCON0,GO		; start ADC conversion
do_adc_test
	btfsc	ADCON0,GO		; test for the end of conversion
	goto	do_adc_test
	return


;*********************************************************************************************
;***** 8 by 8 multiply routine
M_mult	macro	bit
	btfsc	multa,bit
	addwf	msbyte,f
	rrf	msbyte,f
	rrf	lsbyte,f
	endm

Multiply
	clrf	msbyte
	clrf	lsbyte
	movf	multb,W
	bcf	STATUS,C
	M_mult	0
	M_mult	1
	M_mult 	2
	M_mult	3
	M_mult	4
	M_mult	5
	M_mult	6
	M_mult	7
	return


