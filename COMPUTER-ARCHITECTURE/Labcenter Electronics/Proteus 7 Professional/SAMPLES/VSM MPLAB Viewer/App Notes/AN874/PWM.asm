;******************************************************************************
;* Software License Agreement                                                 *
;* The software supplied herewith by Microchip Technology Incorporated        *
;* (the "Company") is intended and supplied to you, the Company's             *
;* customer, for use solely and exclusively on Microchip products.            *
;*                                                                            *
;* The software is owned by the Company and/or its supplier, and is           *
;* protected under applicable copyright laws. All rights are reserved.        *
;* Any use in violation of the foregoing restrictions may subject the         *
;* user to criminal sanctions under applicable laws, as well as to            *
;* civil liability for the breach of the terms and conditions of this         *
;* license.                                                                   *
;*                                                                            *
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,          *
;* WHETHER EXPRESS, IMPLIED OR STATU-TORY, INCLUDING, BUT NOT LIMITED         *
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                *
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,          *
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR                 *
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                          *
;*                                                                            *
;******************************************************************************
;***** Timer Module                                                           *
;* This module provides the main timing for the system.  At the roll over of  *
;* TMR0, the routine determines if the PWM is greater or less than 50%.  It   *
;* then generates the shorter period.  It then decrements the skip flags for  *
;* the command, keypress, autosequence, and ADC state machines.  After the    *
;* the skip timer updates, it returns, releasing the system to the other state*
;* machines.  On average, the system has a minimum of 1/2 of the period to run*
;* the other state machines.  The duty cycle is controlled via the dutycycle  *
;* variable.                                                                  *
;* Timer State machine design                                                 *
;* Not a true state machine, rather is a timer system with a PWM pulse        *
;* generator as part of the execution path.                                   *
;*                                                                            *
;* Timing algorithm                                                           *
;*                                                                            *
;* Wait for TMR0 roll over                                                    *
;* switch (duty cycle)                                                        *
;* {                                                                          *
;* 	case 0%:	output low                                            *
;* 			return                                                *
;* 			                                                      *
;* 	case 100%:	output high                                           *
;* 			return                                                *
;* 			                                                      *
;* 	case 1-50%:	generate high output pulse                            *
;* 			return                                                *
;* 			                                                      *
;* 	case 50-100%:	generate low output pulse                             *
;* 			return                                                *
;* }                                                                          *
;*                                                                            *
;* if (key_skip_timer-- == 0)                                                 *
;* {                                                                          *
;* 	do_key = true                                                         *
;* 	key_skip_timer = 10                                                   *
;* }                                                                          *
;*                                                                            *
;* if (cmd_skip_timer-- == 0)                                                 *
;* {                                                                          *
;* 	do_cmd = true                                                         *
;* 	cmd_skip_timer = 10                                                   *
;* }                                                                          *
;*                                                                            *
;* if (auto_skip_timer-- == 0)                                                *
;* {                                                                          *
;* 	do_auto = true                                                        *
;* 	auto_skip_timer = 100                                                 *
;* }                                                                          *
;*                                                                            *
;* if (adc_skip_timer-- == 0)                                                 *
;* {                                                                          *
;* 	do_adc = true                                                         *
;* 	adc_skip_timer = 100                                                  *
;* }                                                                          *
;*                                                                            *
;* State Machine Variable List.                                               *
;*	NAME		DIRECTION	RANGE		SOURCE/DESTINATION    *
;*	dutycycle	input		0-7F		various               *
;*	tstats.dokey	output		0-1		key state machine     *
;*	tstats.docmd	output		0-1		command state machine *
;*	tstats.doasq	output		0-1		autosequence state mc *
;*	tstats.doadc	output		0-1		ADC state machine     *
;*	GPIO.PWM	output		0-1		PWM output            *
;*	TMR0		input		0-FF		Hardware Timer        *
;*	key_skip_timer	local		00-0A		key sm skip timer     *
;*	cmd_skip_timer	local		00-05		command sm skip timer *
;*	asq_skip_timer	local		00-64		autosq skip timer     *
;*	adc_skip_timer	local		00-64		ADC skip timer        *
;******************************************************************************

Timer
	btfss	INTCON,T0IF		; wait for timer roll over
	goto	Timer
	bcf	INTCON,T0IF		; at roll over, clear flag and start PWM

	btfsc	dutycycle,7		; duty cycle is 00 > DC > 7F
	goto	pwm_error		; if out of range, then error
dc_good
	movlw	0x7F			; test for 7F duty cycle, if yes (always on)
	xorwf	dutycycle,w
	btfsc	STATUS,Z
	goto	alwayson
	movf	dutycycle,w		; test for 00 duty cycle, if yes (always off)
	btfsc	STATUS,Z
	goto	alwaysoff
	btfsc	dutycycle,6		; test for > 50% duty cycle (mostly on)
	goto	mostlyon
	goto	mostlyoff		; if not then only option is < 50% (mostly off)

pwm_error
	bsf	estats,pwm_err		; duty cycle out of range error
	clrf	dutycycle		; goto 0% for safety
	return

;******************************************************************************
;***** 4 PWM CONDITIONS

;********************** PWM CYCLE IS LESS THAN 50% OR MOSTLY OFF
;*****
mostlyoff				; duty cycle < 50% so generate high side of pulse
	bsf	CMCON,0
	movwf	timer1
	bsf	GPIO,pwm		; set the output to start high side pulse
wait1
	goto	$+1			; delay 5 cycles
	goto	$+1
	nop
	decfsz	timer1,f		; count the delay
	goto	wait1			; if not zero then delay again
	bcf	GPIO,pwm		; if zero then clear the output to end pulse
	goto	endtimer		; goto the skip timer updates

;********************** PWM CYCLE IS GREATER THAN 50% OR MOSTLY ON
;*****
mostlyon				; duty cycle > 50% so generate the low side of pulse
	bsf	CMCON,0
	sublw	0x80			; subract dutycyle from 80 to find low time
	movwf	timer1
	bcf	GPIO,pwm		; clear the output to start low pulse
wait2
	goto	$+1			; delay 5 counts
	goto	$+1
	nop
	decfsz	timer1,f		; count the delay
	goto	wait2			; if not zero then delay again
	bsf	GPIO,pwm		; if zero then set the output to end the pulse
	goto	endtimer		; goto the skip timer updates

;********************** PWM CYCLE IS 0% OR ALWAYS OFF
;*****
alwaysoff				; duty cycle = 0%, so output is always low
	bcf	GPIO,pwm
	bsf	GPIO,mosfet
	bcf	CMCON,0
	goto	endtimer

;********************** PWM CYCLE IS 100% OR ALWAYS ON
;*****
alwayson				; duty cycle = 100%, so output is always high
	bsf	GPIO,pwm
	bcf	CMCON,0


;*****
;*****************************************************
;***** END OF TIMER STATE MACHINE, UPDATING THE SKIP TIMERS FOR ALL OTHER STATE MACHINES
;*****
endtimer				; update the skip timers
	decfsz	key_skip_timer,f	; decrement key state machine skip timer
	goto	next_skip_1
	bsf	tstats,dokey		; if zero do key task and reset timer
	movlw	.10
	movwf	key_skip_timer
next_skip_1
	decfsz	cmd_skip_timer,f	; decrement skip timer
	goto	next_skip_2
	bsf	tstats,docmd		; if zero do key task
	movlw	.10
	movwf	cmd_skip_timer		; and reset skip timer
next_skip_2
	decfsz	asq_skip_timer,f	; decrement skip timer
	goto	next_skip_3
	bsf	tstats,doasq
	movlw	.100
	movwf	asq_skip_timer
	return
next_skip_3
	decfsz	adc_skip_timer,f
	return
	bsf	tstats,doadc
	movlw	.100
	movwf	adc_skip_timer
	return

