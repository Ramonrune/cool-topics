;
;
;	File: EXAMPLE2.ASM
;	This is the second file in the MPLINK example
;       Use with EXAMPLE.ASM and EXAM.BAT 
;

	list	p=16f84
	#include p16f84.inc

	extern main, service	; These routines are in example.asm

STARTUP	CODE 			; This area is defined in 16C84.LKR, the linker script

	goto main		; Jump to main code defined in example.asm
	nop			; Pad out so interrupt
	nop			;  service routine gets
	nop			;    put at address 0x0004.
	goto service 		; Points to interrupt service routine

	end
