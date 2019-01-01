;***********************************************************************
;* Software License Agreement                                          *
;* The software supplied herewith by Microchip Technology Incorporated *
;* (the "Company") is intended and supplied to you, the Company's      *
;* customer, for use solely and exclusively on Microchip products.     *
;*                                                                     *
;* The software is owned by the Company and/or its supplier, and is    *
;* protected under applicable copyright laws. All rights are reserved. *
;* Any use in violation of the foregoing restrictions may subject the  *
;* user to criminal sanctions under applicable laws, as well as to     *
;* civil liability for the breach of the terms and conditions of this  *
;* license.                                                            *
;*                                                                     *
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,   *
;* WHETHER EXPRESS, IMPLIED OR STATU-TORY, INCLUDING, BUT NOT LIMITED  *
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A         *
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,   *
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR          *
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                   *
;*                                                                     *
;***********************************************************************
;*   This file is the central file for the LumiLED high power LED      *
;*   driver system using PIC12F676 microcontrollers.  In addition to   *
;*   this file, an include file FLASHLITE.INC is needed, which hold    *
;*   all the variable defines.  Additionally, 5 state machine files are*
;*   also required.  PWM which contains the system timing system.  ADC *
;*   which contains the ADC control and intensity compensation control.*
;*   KEY which contains the key press decoding statemachine.  CMD which*
;*   contains the command decoder for intensity control in the flash   *
;*   light mode, and the four addition pregrammable sequences.  ASQ is *
;*   the file containing the automated preprogrammed sequence control  *
;*   state machine.                                                    *
;*                                                                     *
;***********************************************************************
;*                                                                     *
;*    Filename:	    flashlite.asm                                      *
;*    Date:          06/04/03                                          *
;*    File Version:  Rev A.0                                           *
;*                                                                     *
;*    Author:        Keith Curtis                                      *
;*    Company:       Microchip Technology Incorporated                 *
;*                                                                     *
;*                                                                     *
;***********************************************************************
;*                                                                     *
;*    Files required:  PWM.asm, KEY.asm, CMD.asm, ADC.asm, ASQ.asm     *
;*                     flashlite.inc, Seq.asm                          *
;*                                                                     *
;*                                                                     *
;***********************************************************************
;*                                                                     *
;*    Notes:                                                           *
;*                                                                     *
;*                                                                     *
;*                                                                     *
;*                                                                     *
;***********************************************************************

	list      p=12f675		; list directive to define processor
	#include "p12f675.inc"		; processor specific variable definitions
	#include "flashlite.inc"	; all variables and defines
	errorlevel  -302		; suppress message 302 from list file

	__CONFIG   _CP_OFF & _CPD_OFF & _BODEN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

;***** INTERRUPT AND RESET VECTORS
	ORG     0x000			; processor reset vector
	goto    Main			; go to beginning of program

	ORG     0x004			; interrupt vector location
	retfie				; return from interrupt

Main
	call	Pinit			; configure peripheral routine
	call	Vinit			; load variables routine
loop					; main program loop
	call	ASQ			; auto sequence state machine
	call	Key			; key press state machine
	call	Cmd			; command decoder state machine
	call	Timer			; PWM output state machine
	call	ADC			; ADC with intensity compensation state machine
	movf	estats,w		; check for error conditions
	btfsc	STATUS,Z
	goto	loop

err_recovery
	btfsc	estats,pwm_err		; check for pwm error
	call	pwm_fix
	btfsc	estats,adc_err		; check for adc error
	call	adc_fix
	btfsc	estats,cmd_err		; check for command error
	call	cmd_fix
	btfsc	estats,asq_err		; check for autosequence error
	call	asq_fix
	btfsc	estats,key_err		; check for key error
	call	key_fix
	clrf	estats			; clear all errors
	goto	loop

pwm_fix
	movlw	0x3F
	movwf	dutycycle		; set duty cycle to mid range
	return
adc_fix
	movlw	A_Idle			; put adc state machine in idle state
	movwf	adc_state
	return
cmd_fix
	movlw	C_Incint_st		; put command in increment state
	movwf	cmd_state
	return
asq_fix
	movlw	A_change		; put autosequence state machine in new state
	movwf	asq_state
	return
key_fix
	movlw	K_Idle_st		; put key state machine in idle state
	movwf	key_state
	return

;***** Peripheral initialization routine
Pinit
	movlw	b'00000100'		; preset I/O pin driver outputs
	movwf	GPIO			; set 2 high (comparator out) hi=mosfet off

	banksel	TRISIO
	movlw	b'11011011'		; configure the tri-state drivers
	movwf	TRISIO			; all input, except 2 (comparator out) and 5 (PWM out)
	movlw	b'10000001'		; configure timer0
	movwf	OPTION_REG		; clock = Fosc/4 and 4:1 prescaler
	movlw	b'00011011'		; configure comparator inputs and
	movwf	ANSEL			; battery voltage input as analog
	movlw	b'00001000'		; enable IOCB on button input
	movwf	IOCB
	banksel	GPIO
	movlw	b'00001101'
	movwf	ADCON0			; configure the ADC for battery check
	movlw	b'00000001'		; configure the comparator, non invert out,
	movwf	CMCON			; two analog inputs and enable the comparator output
	clrf	TMR0			; reset Timer0 to start with a complete cycle
	bcf	INTCON,GIE		; turn off interrupts
	bsf	INTCON,T0IE		; enable the timer0 roll over flag
	bsf	INTCON,GPIE		; enable the GPIO interrupt on change flag
	bcf	INTCON,T0IF		; clear the timer0 roll over flag
	bcf	INTCON,GPIF		; clear the GPIO IOC flag

	return

Vinit
	movlw	.22			; normal reset value is 20, but passive
	movwf	key_skip_timer		; priority control starts the timer offset by 1
	movlw	.14			; normal reset value is 10, but passive
	movwf	cmd_skip_timer		; priority control starts the timer offset by 2
	movlw	.106			; normal reset value is 100, but passive
	movwf	asq_skip_timer		; priority control starts the tiemr offset by 3
	movlw	.208
	movwf	adc_skip_timer

	clrf	bcounter		; clear the bounce counter for the key state machine

	movlw	intensity		; starting with intensity, copy the eeprom presets
	movwf	FSR			; into the GPR storage
	movlw	0x07
	movwf	cmd_cntr		; total of 7 bytes transfered
	banksel	EECON1
	clrf	EEADR
var_loop				; copy intensity, mode, num of modes
	M_EE_rd				; and start vectors for 4 sequences out
	movf	EEDATA,w		; of eeprom, into ram
	movwf	INDF
	incf	FSR,f
	incf	EEADR,f
	decfsz	cmd_cntr,f
	goto	var_loop
	banksel	GPIO

	movlw	b'00000000'		; preset all bit fields for startup
	movwf	tstats
	movlw	b'00000000'
	movwf	kstats
	movlw	b'00000000'
	movwf	estats
	movlw	b'00000010'
	movwf	istats
	clrf	estats

	clrf	key_state		; preset state machine state variables
	clrf	cmd_state
	movlw	0x06
	movwf	asq_state
	clrf	adc_state

	clrf	bcounter		; clear bit counter for key task
	movlw	0x20
	movwf	dead_count		; preset counter for shut down
	return

#include ADC.asm
#include ASQ.asm
#include CMD.asm
#include KEY.asm
#include PWM.asm			; Timer / PWM state machine file
#include SEQ.asm

	END				; directive 'end of program'

