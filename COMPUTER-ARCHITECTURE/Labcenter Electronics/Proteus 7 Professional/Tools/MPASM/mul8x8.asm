;*******************************************************************
;                           MUL8x8.ASM
;                   8x8 Software Multiplier
;*******************************************************************
;
;   The 16 bit result is stored in 2 bytes
;
; Before calling the subroutine "mpy", the multiplier should
; be loaded in location "mulplr", and the multiplicand in
; "mulcnd".  The 16 bit result is stored in locations
; H_byte & L_byte.
;
;       Performance :
;                       Program Memory  :  14 locations
;                       # of cycles     :  71
;                       RAM             :   5 locations
;
;  This routine is optimized for code efficiency ( looped code )
;  For time efficiency code refer to "mult8x8F.asm" ( straight line code )
;*******************************************************************
;
        LIST    P=16C54

#include "P16C5x.INC"


	UDATA

mulcnd  RES     1       ; 8 bit multiplicand
mulplr  RES     1       ; 8 bit multiplier
H_byte  RES     1       ; High byte of the 16 bit result
L_byte  RES     1       ; Low byte of the 16 bit result
count   RES     1       ; loop counter

	GLOBAL  mulcnd, mulplr, H_byte, L_byte

;
;
; *****************************         Begin Multiplier Routine
	CODE

mpy
	GLOBAL  mpy

        clrf    H_byte
        clrf    L_byte
        movlw   8
        movwf   count
        movf    mulcnd, W
        bcf     STATUS, C        ; Clear the carry bit in the status Reg.
loop    rrf     mulplr, F
        btfsc   STATUS, C
        addwf   H_byte, F
        rrf     H_byte, F
        rrf     L_byte, F
        decfsz  count, F
        goto    loop

        retlw   0

	END
