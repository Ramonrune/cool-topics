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
;***** VARIABLE DEFINITIONS
	cblock	0x20
;********************************************************************************************
;***** State machine specific variables

	;* PWM routine variables
	timer1				; counter used by pwm for pulse generation

	;* key state machine variables
	bcounter			; key press counter variable (3 bits 0-2)
	key_skip_timer			; skip timer for the key task 0-20 decimal
	key_state			; state variable for the key task
	khold_timer			; key hold timer

	;* command state machine variables
	cmd_skip_timer			; skip timer for command state machine
	cmd_state			; command state machine state variable
	cmd_delay			; command state machine delay variable
	cmd_pntr			; Repeat command return pointer
	cmd_cntr			; repeat command counter

	;* error recovery variables
	estats				; error control related flags

	;* autosequence state machine variables
	asq_skip_timer			; autosequence skip timer
	asq_state			; autosequence state variable
	addr_next			; address of next command in eeprom
	asq_data			; address of current data from eeprom
	asq_timer			; autosequence delay timer
	addr_offset			; offset between 0 and start of current sequence
	decode_temp			; temperary variable used by command decoder
	stack : 4			; first half of repeat command stack
	stack2: 4			; second half of repeat command stack
	rpt_cntr			; current repeat command counter
	rpt_pntr			; current repeat command return pointer
	temp				; temperary variable used by autosequencer

	;* ADC state machine variables
	adc_skip_timer			; skip timer for the ADC routine
	adc_state			; state variable for the ADC routine
	multa				; 1 byte of 8x8 multiply input
	multb				; other byte of 8x8 multiply input
	msbyte				; most significant byte of 16 bit result
	lsbyte				; least significant byte of result
	cnv_factor			; conversion factor for scaling dutycycle
	dead_count			; counter for power down averaging

;***********************************************************************************************
;* InterTask communications variables

	dutycycle			; duty cycle of pwm pulse (7 bits 0-6)	Broadcast
	tstats				; timer related flags			Broadcast
	kstats				; key press related flags		Broadcast
	istats				; intensity control related flags	Broadcast
;*** shadowed in EEPROM
	intensity			; current flash light intensity setting 00-3F 			Broadcast
	mode				; current mode, 1=flashlight 2-5=preprogrammed sequences	Broadcast
	num_modes			; maximum number of modes defined in eeprom			Broadcast
	start2				; start address of 1st sequence, mode=2				Broadcast
	start3				; start address of 2nd sequence, mode=3				Broadcast
	start4				; start address of 3rd sequence, mode=4				Broadcast
	start5				; start address of 4th sequence, mode=5				Broadcast
;*** end shadow

	endc

;***** I/O DEFINES
#define	pwm		5		; GPIO pin for intensity PWM output
#define batt		4		; battery voltage test input pin
#define btn		3		; GPIO pin for button input
#define mosfet		2		; output to MOSFET driver

;***** EEPROM data addres defines
#define EE_intensity	0		; power up default intensity setting
#define EE_mode		1		; power up default mode setting
#define EE_num_modes	2		; number of modes available
#define EE_start2	3		; start address of mode 2
#define EE_start3	4		; start address of mode 3
#define EE_start4	5		; start address of mode 4
#define EE_start5	6		; start address of mode 5

;***** TSTATS flags whose origin is the timer function
#define	dokey		0		; skip timer time out for key statemachine
#define	docmd		1		; skip timer time out for command statemachine
#define doadc		2		; skip timer time out for adc statemachine
#define doasq		3		; skip timer time out for autosequence statemachine

;***** KSTATS flags whose origin is the key function
#define keypress	0		; current state of the button, debounced
#define press		1		; a press command is issued
#define push		2		; a push command is issued
#define old_push	3		; the last command was a push
#define hold		4		; a hold command is issued

#define prs_hld		b'00010010'	; OR combination of press and hold flags

;***** ISTATS flags whose origin is the control or autosequence (relating to intensity)
#define overide		0		; command overide of autosequence, 1=overide
#define	new_mode	1		; new autoseqence mode available
#define new_int		2		; change to intensity

;***** ESTATS flags related to error control
#define pwm_err		0		; error in PWM state machine
#define adc_err		1		; error in ADC state machine
#define cmd_err		2		; error in command state machine
#define asq_err		3		; error in auto sequence state machine
#define key_err		4		; error in key press state machine

;***** key states
#define K_Idle_st	0		; key state machine idle state
#define K_press_st 	1		; decoding a press command state
#define K_push_st	2		; decoding a push command state
#define K_hold_st	3		; decoding a hold command state
#define K_delay_st	4		; delay state for hold autorepeat

;***** command states
#define C_Incint_st	0		; increment command state
#define C_Decint_st	1		; decrement command state
#define C_Modesel_st	2		; mode select command state
#define C_Display_st	3		; mode display command state

;***** auto sequencer states
#define	A_decode	0		; decode new command state
#define A_intensity	1		; intensity set command state
#define A_time		2		; time delay command state
#define A_jump		3		; jump command state
#define A_repeat	4		; repeat command state
#define A_delay		5		; generic delay state
#define A_change	6		; mode change command state
#define A_flashlite	7		; mode 1 flashlight state

;***** ADC states
#define	A_Idle		0		; ADC idle state, no action
#define A_Cnvrt		1		; get results and create conversion factor
#define A_Calc		2		; convert intensity to duty cycle using conversion factor
#define A_Shutdn	3		; battery is too low, shut down state



;**************************************************************************************************
;***** Macros for system functions

;***** EEPROM write macro any address
M_EE_wr	macro				; write data into EEPROM
	bsf	EECON1,WREN		; enable write
	movlw	0x55			; unlock EEPROM
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1,WR		; perform write
	endm

;***** EEPROM read macro any address
M_EE_rd	macro				; read data from EEPROM
	bsf	EECON1,RD
	endm

;***** EEPROM write macro intensity only
M_eeprom macro
	movf	intensity,w		; copy new intensity into eeprom
	banksel	EECON1
	movwf	EEDATA
	movlw	EE_intensity
	movwf	EEADR
	bsf	EECON1,WREN		; enable write
	movlw	0x55			; unlock EEPROM
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1,WR		; perform write
	banksel	GPIO
	endm

;***** Driver shut down macro with wake on change
M_shutdown macro			; macro to shut down driver and sleep micro
	banksel	GPIO
	movlw	b'00000111'
	movwf	CMCON			; turn off comparator
	bsf	GPIO,mosfet		; turn off mosfet transistor
	banksel	TRISIO			; make PWM output Hi-Z
	bcf	TRISIO,pwm
	banksel	GPIO
	movf	GPIO,w			; update the IOCB register
	bcf	INTCON,GPIF		; clear an pending IOCB
	sleep
	call	Pinit			; on wake up reset peripherals
	call	Vinit			; on wake up reset variables
	return
	endm

