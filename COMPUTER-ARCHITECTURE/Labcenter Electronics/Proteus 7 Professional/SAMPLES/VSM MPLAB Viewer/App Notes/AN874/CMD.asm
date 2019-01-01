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
;***** CMD state machine                                                      *
;* This module handles the command decode of intensity and mode selection.  It*
;* receives PRESS, PUSH, and HOLD commands and makes the appropriate changes  *
;* to the lamp intensity (dutycycle) and system mode (cmd_mode).  It also     *
;* updates the appropriate EEPROM locations, so on power up, the flash light  *
;* has the same intensity and mode as it did on power down.                   *
;* Command State machine design                                               *
;* Hybrid Execution and Data indexed state machine                            *
;*                                                                            *
;* 	State                                                                 *
;* 0	Incint		Intensity increment mode                              *
;* 1	Decint		Intensity decrement mode                              *
;* 2	Modesel		Mode select mode                                      *
;* 3	Display		data indexed state machine for mode number display    *
;* Note: no default state decoded, default can only be access by corrupted    *
;*       data in the state variable.                                          *
;*                                                                            *
;* STATE TO STATE TRANSITIONS                                                 *
;* From		Conditional		True	False	comments              *
;* ---------------------------------------------------------------------------*
;* Incint	if push command		Decint	Incint	change from inc to dec*
;* Incint	if hold command		Modesel	Incint	change to mode select *
;*                                                                            *
;* Decint	if push command		Incint	Decint	change from dec to inc*
;* Decint	if hold command		Modesel	Decint	change to mode select *
;*                                                                            *
;* Modesel	if keypress = 0		Incint	Modesel	key released go Incint*
;* Modesel	if hold command		Display	Modesel	display next mode     *
;*                                                                            *
;* Display	if display complete	Modesel	Display	end of display routine*
;* 	                                                                      *
;* ACTIONS                                                                    *
;* Incint                                                                     *
;* 	if (Push == 1) and (old_push == 1) then power off                     *
;* 	if (Push == 1) then old_push = 1                                      *
;* 	if (Press == 1) or (Hold == 1) old_push = 0                           *
;* 	clear Push                                                            *
;*                                                                            *
;* 	if (Press == 1) and (intensity < max) then intensity++ & store in ee  *
;* 	clear Press                                                           *
;* Decint                                                                     *
;* 	if (Push == 1) and (old_push == 1) then power off                     *
;* 	if (Push == 1) then old_push = 1                                      *
;* 	if (Press == 1) or (Hold == 1) old_push = 0                           *
;* 	clear Push                                                            *
;*                                                                            *
;* 	if (Press == 1) and (intensity > 0) then intensity-- and store in ee  *
;* 	clear Press                                                           *
;* Modesel                                                                    *
;* 	set asq_hold                                                          *
;* 	if keypress = 0                                                       *
;* 		clear asq_hold                                                *
;* 		set new_mode flag                                             *
;* 	mode++                                                                *
;* 	if mode = number_of_modes+2                                           *
;* 		mode = 1                                                      *
;* Display                                                                    *
;* 	flash .5 second off with 1 second gap for mode 1-5 (1 to 5 flashes)   *
;*                                                                            *
;*                                                                            *
;* INPUT/OUTPUT                                                               *
;* 		input			output                                *
;* Incint	press, push, hold	intensity                             *
;* Decint	press, push, hold	intensity                             *
;* Modesel	hold, keypress		Mode                                  *
;* Display	----			intensity                             *
;*                                                                            *
;* DISPLAY SEQUENCE                                                           *
;* counter = 0                                                                *
;* pointer = mode * 2                                                         *
;*                                                                            *
;* loop                                                                       *
;* 	if counter == 0                                                       *
;* 		if pointer is odd                                             *
;* 			counter = 20                                          *
;* 			intensity = 1/2                                       *
;* 		else                                                          *
;* 			counter = 10                                          *
;* 			intensity = full                                      *
;* 		pointer--                                                     *
;* 		if pointer == 0                                               *
;* 		goto	Modesel_state                                         *
;* 	counter--                                                             *
;*                                                                            *
;******************************************************************************
Cmd					; start of Command state machine
	btfss	tstats,docmd		; check for the flag from the skip timer
	return				; if not zero, then return
	bcf	tstats,docmd		; if zero, clear the flag

	movlw	0xFC			; range check the state variable
	andwf	cmd_state,w
	btfss	STATUS,Z
	goto	cmd_error		; if greater than 3 then error

	movlw	cmd_sm_tab/0x100	; compute the address of the state in the jump table
	movwf	PCLATH
	movf	cmd_state,w
	andlw	0x03			; Only four states so 0-3 are only legal values
	addlw	cmd_sm_tab & 0xFF
	movwf	PCL			; jump to state jump
cmd_sm_tab
	goto	C_Incint		; increment intensity
	goto	C_Decint		; decrement intensity
	goto	C_Modesel		; mode selection
	goto	C_Display		; display for mode selection

;******************************************************************************
;***** Intensity increment state

C_Incint
	movlw	C_Modesel_st		; if hold then goto mode select state
	btfsc	kstats,hold
	movwf	cmd_state

	movlw	C_Decint_st		; if push then goto decrement state
	btfsc	kstats,push
	movwf	cmd_state

	btfss	kstats,push		; check for double push (shut off system)
	goto	C_I_nopwrdwn
	btfss	kstats,old_push
	goto	C_I_nopwrdwn
	M_shutdown

C_I_nopwrdwn
	btfsc	kstats,push		; if push is set, copy set into old_push
	bsf	kstats,old_push

	movlw	prs_hld			; if press or hold are set then clear old_push
	andwf	kstats,w
	btfss	STATUS,Z
	bcf	kstats,old_push

	bcf	kstats,push

C_I_press
	btfss	kstats,press		; if press command, increment the intensity by 4
	return
	bcf	kstats,press		; clear the press command

	movlw	0x01			; test for flash light mode
	xorwf	mode,w
	btfss	STATUS,Z
	return				; if not then do not increment

	movlw	0x04
	addwf	intensity,f		; increment intensity (dutycycle)
	movlw	0x3F
	btfsc	intensity,6
	movwf	intensity

	bsf	istats,new_int		; trigger ADC state machine to compensate value

	M_eeprom			; copy intensity to eeprom
	return

;******************************************************************************
;***** Intensity decrement state

C_Decint
	movlw	C_Modesel_st		; if hold then goto mode select state next
	btfsc	kstats,hold
	movwf	cmd_state

	movlw	C_Incint_st		; if push then goto decrement state next
	btfsc	kstats,push
	movwf	cmd_state

	btfss	kstats,push		; check for double push (shut off system)
	goto	C_D_nopwrdwn
	btfss	kstats,old_push
	goto	C_D_nopwrdwn
	M_shutdown

C_D_nopwrdwn
	btfsc	kstats,push		; if push is set, copy set into old_push
	bsf	kstats,old_push

	movlw	prs_hld			; if press or hold are set then clear old_push
	andwf	kstats,w
	btfss	STATUS,Z
	bcf	kstats,old_push

	bcf	kstats,push

C_D_press
	btfss	kstats,press		; if press command, decrement the intensity by 4
	return
	bcf	kstats,press		; clear the press command

	movlw	0x01			; test for flash light mode
	xorwf	mode,w
	btfss	STATUS,Z
	return				; if not then do not increment

	movlw	0x04
	subwf	intensity,f
	btfsc	intensity,7
	clrf	intensity
non_zero
	movf	intensity,w
	bsf	istats,new_int		; trigger ADC state machine to compensate value

	M_eeprom			; copy new intensity to eeprom
	return

;******************************************************************************
;***** Mode select state (flashlight and 4 programmable sequences)

C_Modesel
	btfsc	kstats,keypress			; check for key open to end command
	goto	C_M_hold

C_M_end						; key has been released
	movlw	C_Incint_st
	movwf	cmd_state

	movf	mode,w				; copy new mode into eeprom
	banksel	EECON1
	movwf	EEDATA
	movlw	EE_mode
	movwf	EEADR
	M_EE_wr
	banksel	GPIO

	bsf	istats,new_mode			; indicates mode change to auto-sequence state machine
	bcf	istats,overide			; return control to autosequence state machine
	return

C_M_hold					; key is still held
	bsf	istats,overide

	btfss	kstats,hold			; wait for next repeated hold
	return
	bcf	kstats,hold			; clear hold command

	incf	mode,f				; next mode

	movf	num_modes,w
	addlw	0x01				; use number of modes to find roll over for mode
	subwf	mode,w				; check for roll over
	btfss	STATUS,C
	goto	C_M_do_display
	movlw	0x01				; if roll over reset to mode 1
	movwf	mode

C_M_do_display					; if mode changed, display new mode to user
	movlw	.20				; set an initial delay
	movwf	cmd_cntr
	clrf	intensity			; goto dark display
	movf	mode,w
	movwf	cmd_pntr
	rlf	cmd_pntr,f			; double mode value for blank and flash times
	incf	cmd_pntr,f			; display predecrements so compensate counter
	movlw	C_Display_st			; point state var to display
	movwf	cmd_state
	return

;******************************************************************************
;***** Mode select display state

C_Display
	decfsz	cmd_cntr,f			; decrement the counter
	return
C_D_change
	decfsz	cmd_pntr,f			; when pointer is zero, display is done
	goto	C_do_display
	movlw	C_Modesel_st			; if zero then return to hold state
	movwf	cmd_state
	return
C_do_display					; if not then display state
	movlw	.10
	movwf	cmd_cntr			; first reset the timer
	btfsc	cmd_pntr,0
	goto	pntr_odd			; is pointer even or odd
pntr_even
	movlw	0x0F				; light on
	movwf	intensity
	bsf	istats,new_int
	return
pntr_odd
	clrf	intensity			; light off
	bsf	istats,new_int
	return

;******************************************************************************
;***** Error state

cmd_error
	movlw	0xFF				; lock state variable into error
	movwf	cmd_state
	bsf	estats,cmd_err			; set error flag and wait for reset
	return
