;
;
;	File: EXAMPLE.ASM
;	This is the main file in the MPLINK example
;       Use with EXAMPLE2.ASM and EXAM.BAT 
;
;	See EXAM.BAT for information on using in an MPLAB project
;
;

	list	p=16f84
	#include p16f84.inc

PROG	CODE		; Set the start of code from 16F84.lkr script

main			; Min code entry called from example2.asm
	global	main	; Define as global so can be used in example2.asm
	nop		; Main does nothing --Put your code here
	goto	main	; Our sample "main" is just an infinite loop

service 		; Interrupt routine, called from example2.asm
	global service	; Define as global so can be used in example2.asm
	nop		; Interrupt code would go here
	nop
	retfie

IDLOCS CODE		; ID location data, address in in 16F84.lkr
	dw 0x0102
	dw 0x0304

CONFIG CODE		; Set config bits from defines in P16F84.INC
			; Config address for device programmer is in 16F84.lkr
	dw _LP_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF       

	end
