; SAMPOBJ.ASM

; This test file is a sample of using relocatable object files. 
; It calls the function "mpy", which is in a separate object file,
; to multiply two 8-bit values, giving a 16-bit result.

;
;********************************************************************
;               Test Program
;*********************************************************************

        LIST    p=16C54

#include "P16C5x.INC"

        __CONFIG _CP_OFF & _WDT_OFF & _XT_OSC
        __IDLOCS H'1234'

	EXTERN  mulcnd, mulplr, H_byte, L_byte
	EXTERN	mpy


	CODE

start   clrw
	option

main    movf    PORTB, W
        movwf   mulplr
        movf    PORTB, W
        movwf   mulcnd

call_m  call    mpy             ; The result is in H_byte & L_byte
        goto    main


Reset	CODE    H'01FF'

        goto    start

        END


