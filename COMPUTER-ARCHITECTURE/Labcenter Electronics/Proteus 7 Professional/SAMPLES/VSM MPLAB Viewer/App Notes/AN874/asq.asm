;*************************************************************************
;* Software License Agreement                                            *
;* The software supplied herewith by Microchip Technology Incorporated   *
;* (the "Company") is intended and supplied to you, the Company's        *
;* customer, for use solely and exclusively on Microchip products.       *
;*                                                                       *
;* The software is owned by the Company and/or its supplier, and is      *
;* protected under applicable copyright laws. All rights are reserved.   *
;* Any use in violation of the foregoing restrictions may subject the    *
;* user to criminal sanctions under applicable laws, as well as to       *
;* civil liability for the breach of the terms and conditions of this    *
;* license.                                                              *
;*                                                                       *
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,     *
;* WHETHER EXPRESS, IMPLIED OR STATU-TORY, INCLUDING, BUT NOT LIMITED    *
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A           *
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,     *
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR            *
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                     *
;*                                                                       *
;*************************************************************************
;***** Auto Sequence State Machine                                       *
;* Auto Sequence State machine design                                    *
;* Hybrid Execution and Data indexed state machine                       *
;*                                                                       *
;* Auto sequence Task		D7	D6	D4-0                     *
;* 1.	Intensity command	0	0	Intensity                *
;* 2.	Time command		0	1	Time delay               *
;* 3.	Repeat command		1	0	repeat count             *
;* 	Return at the end	1	0	000000                   *
;* 4.	Goto command		1	1	destination              *
;* 	shut down command	1	1	000000                   *
;*                                                                       *
;* if overide is true, this state machine is idle                        *
;* if new_mode, state is reset to asq_change                             *
;* 	                                                                 *
;* sequence numbers 1-63, zero causes shut down                          *
;*                                                                       *
;* 	State                                                            *
;* 0	Decode		Fetch a command and decode it                    *
;* 1	Set_Intens	Intensity set command                            *
;* 2	Time_Delay	Time Delay command                               *
;*                      (only state to use skip timer)                   *
;* 3	Jump		goto different step number                       *
;* 4	Repeat		repeat section command                           *
;* 5	Delay		used for time command                            *
;* 6	ASQ_change	auto sequence, sequence change.                  *
;*                      Reset of system for next sequence                *
;* 7	flash_lite	no sequence, continuous mode only                *
;*                                                                       *
;* STATE TO STATE TRANSITIONS                                            *
;* From		Conditional			if True		if False *
;* Decode	if command = Intensity		Set_Intens	Decode   *
;* Decode	if command = Time		Time_delay	Decode   *
;* Decode	if command = Jump		Jump		Decode   *
;* Decode	if command = Repeat		Repeat		Decode   *
;* Set_Itens	none				Decode                   *
;* Time_Delay	none				Delay                    *
;* Jump		none				Decode                   *
;* Repeat	none				Decode                   *
;* Delay	if timer == 0			Decode		Delay    *
;* ASQ_change	mode = 1			flash_lite	Decode   *
;*                                                                       *
;* ACTIONS                                                               *
;* Decode		                                                 *
;* 		get command(addr_next)                                   *
;* 		addr_next++                                              *
;* 		decode command & 0xC0                                    *
;* 		ASQ_data = command & 0x3F                                *
;* Set_Intens                                                            *
;* 		intensity = ASQ_data                                     *
;* 		set int_chng                                             *
;* Time_Delay                                                            *
;* 		Timer = ASQ_data                                         *
;* Jump                                                                  *
;* 		addr_next = ASQ_data                                     *
;* Repeat                                                                *
;* 		addr_next++                                              *
;* 		if ASQ_data == 0	; indicates a return to a repeat *
;* 			pop ret_addr                                     *
;* 			pop counter	; pop counter and return address *
;* 			counter--	; count this pass                *
;* 			if counter == 0                                  *
;* 				break (return)                           *
;* 			else                                             *
;* 				push counter                             *
;* 				push ret_addr                            *
;* 				addr_next = ret_addr			 *
;* 		else					; not a return   *
;* 			push ASQ_data                                    *
;* 			push addr_next                                   *
;* Delay                                                                 *
;* 		Decrement timer                                          *
;* ASQ_change                                                            *
;* 		reset repeat stack                                       *
;* 		clear new_mode flag                                      *
;* 		if mode > 1                                              *
;* 			addr_next = eeprom(start,mode)                   *
;* flash_lite                                                            *
;* 		intensity = eeprom(EE_intensity)                         *
;* 		set int_chng                                             *
;* ***********************************************************************
ASQ
	btfsc	istats,overide		; test for hold due to mode set in process
	return

	btfss	istats,new_mode		; test for mode change
	goto	asq_do_decode		; if not decode normally

mode_change
	bcf	istats,new_mode		; if new mode, goto change state
	movlw	A_change
	movwf	asq_state

asq_do_decode
	movf	asq_state,w		; test if state variable is legal
	andlw	0xF8
	btfss	STATUS,Z
	goto	auto_error		; if not goto error recovery

	movlw	asq_sm_tab/0x100	; compute the address of the state in the jump table
	movwf	PCLATH
	movf	asq_state,w
	andlw	0x07			; Only eight states so 0-7 are only legal values
	addlw	asq_sm_tab & 0xFF
	movwf	PCL
	nop				; move table to next page boundry
	nop
	nop
	nop
	nop			; jump to state jump

asq_sm_tab
	goto	A_decode_st
	goto	A_intensity_st
	goto	A_time_st
	goto	A_jump_st
	goto	A_repeat_st
	goto	A_delay_st
	goto	A_change_st
	goto	A_flashlite_st

auto_error
	bsf	estats,asq_err
	return

;***** decode state
A_decode_st
	banksel	EEADR
	movf	addr_next,w
	movwf	EEADR			; use addr_next to get next command
	M_EE_rd
	movf	EEDATA,w
	movwf	asq_data		; save in data next for decoding
	movwf	decode_temp
	banksel	GPIO
	movlw	asq_tbl / .256
	movwf	PCLATH
	swapf	decode_temp,f		; move bits 6&7 to bottom nibble
	rrf	decode_temp,w		; move into bits 1&2
	andlw	0x06			; remove all others
	addlw	asq_tbl & .255		; offset into table
	movwf	PCL			; jump
asq_tbl
	movlw	A_intensity		; 00 = intensity set command
	goto	asq_end
	movlw	A_time			; 01 = time delay command
	goto	asq_end
	movlw	A_repeat		; 10 = repeat command
	goto	asq_end
	movlw	A_jump			; 11 = jump command
asq_end
	movwf	asq_state		; store it and go
	return
;***** intensity set command state
A_intensity_st
	movlw	0x3F
	andwf	asq_data,w
	movwf	intensity
	incf	addr_next,f
	bsf	istats,new_int
	movlw	A_decode
	movwf	asq_state
	return
;***** time delay command state
A_time_st
	movlw	0x3F
	andwf	asq_data,w
	movwf	asq_timer
	incf	addr_next,f
	movlw	A_delay
	movwf	asq_state
	return
;***** time delay subroutine state
A_delay_st
	btfss	tstats,doasq		; check for the flag from the skip timer
	return				; if not zero, then return
	bcf	tstats,doasq		; if zero, clear the flag
	decfsz	asq_timer,f
	return
	movlw	A_decode
	movwf	asq_state
	return
;***** jump command state
A_jump_st
	movlw	0x3F
	andwf	asq_data,w
	btfsc	STATUS,Z
	goto	prog_off
	addwf	addr_offset,w
	movwf	addr_next
	movlw	A_decode
	movwf	asq_state
	return
prog_off
	M_shutdown
	return
;***** mode change state
A_change_st
	bcf	istats,new_mode

	movlw	0x01			; test for mode 1
	xorwf	mode,w
	btfsc	STATUS,Z
	goto	fl_mode			; goto flash lite mode

	movf	mode,w			; remove mode 1 (flashlite mode)
	addlw	start2 - 2		; offset to start addresses in eeprom
	movwf	FSR
	movf	INDF,w

	movwf	addr_next		; start the instruction pointer
	movwf	addr_offset
	decf	addr_offset,f

	movlw	A_decode
	movwf	asq_state
	return
fl_mode
	movlw	A_flashlite
	movwf	asq_state
	return

;***** flashlite mode state
A_flashlite_st
	banksel	EECON1
	movlw	EE_intensity		; set address of intensity in eeprom
	movwf	EEADR
	M_EE_rd				; perform the read
	movf	EEDATA,w
	banksel	GPIO
	movwf	intensity		; copy new data into intensity
	bsf	istats,new_int
	return

;***** repeat command state
;* this command has three possible paths
;* 1. repeat command, so push count and address of next command
;* 2. return command (non-zero result), popped count is decremented and jump to return address
;* 3. return command (zero result), next command following return is executed
;*****
A_repeat_st
	incf	addr_next,f		; move pointer to next instruction (needed in 1 and 3)
	movlw	0x3F
	andwf	asq_data,w
	btfss	STATUS,Z		; test for count of zero (indicates a return)
	goto	A_new_repeat
A_return				; RETURN command
	call	stack_pop		; pull return address and count off stack
	decfsz	rpt_cntr,f		; decrement the count
	goto	non_zero_return		; no zero result return
zero_return				; zero result return
	movlw	A_decode		; fall through to next command
	movwf	asq_state
	return
non_zero_return
	call	stack_push		; push count and return address back on to stack
	movf	rpt_pntr,w		; load return address in addr next
	movwf	addr_next
	movlw	A_decode		; goto decode for next command
	movwf	asq_state
	return

A_new_repeat				; new REPEAT command
	movf	addr_next,w
	movwf	rpt_pntr		; save the return address
	movlw	0x3F
	andwf	asq_data,w		; save the number of REPEATs
	movwf	rpt_cntr
	call	stack_push		; push both on stack
	movlw	A_decode
	movwf	asq_state
	return

stack_pop
	movf	stack+7,w
	movwf	rpt_cntr
	movf	stack+6,w
	movwf	rpt_pntr
shift_up
	movlw	.6
	movwf	temp
	movlw	stack+5
	movwf	FSR
loop_shft_up
	movf	INDF,w
	incf	FSR,f
	incf	FSR,f
	movwf	INDF
	movlw	0xFD
	addwf	FSR,f
	decfsz	temp,f
	goto	loop_shft_up
	return

stack_push
	movlw	.6
	movwf	temp
	movlw	stack+2
	movwf	FSR
loop_shft_dn
	movf	INDF,w
	decf	FSR,f
	decf	FSR,f
	movwf	INDF
	movlw	.3
	addwf	FSR,f
	decfsz	temp,f
	goto	loop_shft_dn
	movf	rpt_cntr,w
	movwf	stack+7
	movf	rpt_pntr,w
	movwf	stack+6
	return
