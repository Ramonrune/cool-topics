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
;***** Key State machine module                                               *
;* This module handles the key debounce and decoding for the system.  It      *
;* decodes three seperate key conditions; PRESS: a key press of less than 1.5 *
;* seconds, PUSH: a key press of 1.5 to 3.0 seconds, and HOLD: the hold of the*
;* key for more than 3.0 seconds.  In addition, the HOLD command features an  *
;* auto repeat at a 3.0 second interval.  A KEYPRESS output is also available *
;* to allow the command decoder to determine that the key HOLD is complete.   *
;*                                                                            *
;* State Machine Variable List.                                               *
;*	NAME		DIRECTION	RANGE		SOURCE/DESTINATION    *
;*	tstats.dokey	input		0-1		key state machine     *
;*	bcounter	local		0-7		debounce counter      *
;*	stats.keypress	output		0-1		current status of key *
;*	stats.press	output		0-1		press decoded         *
;*	stats.push	output		0-1		push decoded          *
;*	stats.hold	output		0-1		hold decoded          *
;*	stats.k_error	output		0-1		error condition       *
;*	khold_timer	local		0-150		delay timer for repeat*
;*                                                                            *
;* Key Task: State machine design                                             *
;* Execution indexed state machine                                            *
;*                                                                            *
;* 	State                                                                 *
;* 0	Idle		no key pressed                                        *
;* 1	press		key held < 1.5 sec                                    *
;* 2	push		key held < 3.0 sec                                    *
;* 3	hold		key held > 3.0 sec                                    *
;* 4	delay		auto repeat delay for hold                            *
;* 5	default		error state                                           *
;* 6	default		error state                                           *
;* 7	default		error state                                           *
;*                                                                            *
;* STATE TO STATE TRANSITIONS                                                 *
;* From	  Conditional		True	False	comments                      *
;* -------------------------------------------------------------------------- *
;* Idle	  if keypress detected	press	Idle	no key                        *
;*                                                                            *
;* press  if keypress = 0	Idle	press	key stable at open press      *
;* press  is time > 1.5 sec	push	press	if held > 1.5 s then push     *
;*                                                                            *
;* push	  if keypress = 0	Idle	push	key stable at open Push       *
;* push   if time > 3.0 sec	hold	push	if held > 3.0 s then hold     *
;*                                                                            *
;* hold	  if keypress = 0	Idle	hold	key stable at open hold       *
;* hold				delay	----	goto delay for auto repeat    *
;*                                                                            *
;* delay  if keypress = 0	Idle	delay	key stable at open delay      *
;* delay  if time = 3.0 sec	hold	delay	auto repeat                   *
;* 	                                                                      *
;* ACTIONS                                                                    *
;* Idle		none                                                          *
;* press	if release send press command                                 *
;* push		if release send push command                                  *
;* hold		send hold command                                             *
;* delay 	delay 3.0 seconds then return to hold                         *
;*                                                                            *
;* Code segment prior to state variable decoder, monitors the button and      *
;* debounces with keypress as an output.                                      *
;* (Algorithm)                                                                *
;*                                                                            *
;* 	if (key == 0) and (bcounter < 7) then bcounter++                      *
;* 	if (key == 1) and (bcounter > 0) then bcounter--                      *
;* 	if bcounter == 6	then keypress = 1                             *
;* 	if bcounter == 2 	then keypress = 0                             *
;* 	                                                                      *
;* 		                                                              *
;* INPUT/OUTPUT                                                               *
;* 		input			output                                *
;* Idle		keypress		----                                  *
;* press	keypress		press cmd                             *
;* push		keypress		push cmd                              *
;* hold		keypress		hold cmd                              *
;* delay	keypress		----                                  *
;*                                                                            *
;******************************************************************************

Key
	btfss	tstats,dokey		; test timer flag for execution of state machine
	return
	bcf	tstats,dokey
	btfsc	GPIO,3 ;btn		; test the state of the button
	goto	buttonup		; if open debounce end of key
buttondown				; if down debounce key press
	incf	bcounter,f		; if down then increment the counter
	btfsc	bcounter,3		; check for an overflow
	decf	bcounter,f		; if over back up 1 count
	movlw	0x06			; load for hiside hysteresis test of counter
	xorwf	bcounter,w
	btfsc	STATUS,Z		; if bcounter = 6 then set key press flag
	bsf	kstats,keypress
	goto	key_machine
buttonup
	decf	bcounter,f		; if up then decrement counter
	btfsc	bcounter,7		; test for underflow
	incf	bcounter,f		; if under back up 1 count
	movlw	0x02			; load for loside hysteresis test of counter
	xorwf	bcounter,w
	btfsc	STATUS,Z		; if bcounter =2 then clear key press flag
	bcf	kstats,keypress

key_machine				; start of key press state machine
	movf	key_state,w		; verify state variable is in range 0-7
	andlw	0xF8
	btfss	STATUS,Z
	goto	K_default		; if upper bits set, then error

	movlw	key_sm_tab / 0x100	; if in range then use jump table to decode state
	movwf	PCLATH			; set the Program counter Latch High to MSB
	movf	key_state,w
	andlw	0x07			; add table address to state value to get pointer
	addlw	key_sm_tab & 0xFF
	movwf	PCL			; computed goto
key_sm_tab
	goto	K_Idle			; waiting
	goto	K_press			; short press < 1.5 seconds
	goto	K_push			; longer press < 3.0 seconds
	goto	K_hold			; longest press > 3.0 seconds
	goto	K_delay			; delay for hold autorepeat
	goto	K_default		; error
	goto	K_default		; error
	goto	K_default		; error

;***** KEY TASK STATE MACHINE, IDLE STATE
K_Idle
	clrf	khold_timer
	movlw	K_press_st
	btfsc	kstats,keypress
	movwf	key_state
	return
;***** KEY TASK STATE MACHINE, PRESS STATE
K_press
	incf	khold_timer,f		; increment the keyhold timer
	movlw	.76
	xorwf	khold_timer,w		; at 1.5 seconds goto push
	btfsc	STATUS,Z
	goto	K_pr_next		; goto next state is 1.5 seconds
	btfss	kstats,keypress		; check for key release
	goto	K_pr_open
	return
K_pr_next
	movlw	K_push_st
	movwf	key_state
	return
K_pr_open
	bsf	kstats,press		; if open in press state then press command
	movlw	K_Idle_st
	movwf	key_state
	return
;***** KEY TASK STATE MACHINE, PUSH STATE
K_push
	incf	khold_timer,f		; increment the keyhold timer
	movlw	.151
	xorwf	khold_timer,w		; at 3.0 seconds goto hold
	btfsc	STATUS,Z
	goto	K_pu_next		; goto next state is 1.5 seconds
	btfss	kstats,keypress		; check for key release
	goto	K_pu_open
	return
K_pu_next
	movlw	K_hold_st
	movwf	key_state
	return
K_pu_open
	bsf	kstats,push		; if open in press state then press command
	movlw	K_Idle_st
	movwf	key_state
	return
;***** KEY TASK STATE MACHINE, HOLD STATE
K_hold
	bsf	kstats,hold		; generate first hold output
	btfss	kstats,keypress		; check for key release
	goto	K_hl_open
	movlw	.150
	movwf	khold_timer
	movlw	K_delay_st
	movwf	key_state
	return
K_hl_open
	movlw	K_Idle_st		; at first key open return to idle
	movwf	key_state
	return

	return
;***** KEY TASK STATE MACHINE, DELAY STATE
K_delay
	decfsz	khold_timer,f
	goto	K_dly_k_chk
K_dly_timout
	movlw	K_hold_st
	movwf	key_state
	return
K_dly_k_chk
	btfsc	kstats,keypress
	return
	movlw	K_Idle_st
	movwf	key_state
	return
;***** KEY TASK STATE MACHINE, DEFAULT STATE
K_default
	bsf	kstats,key_err
	return
