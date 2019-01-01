;*******************************************************************
;                           SAMPLE.ASM
;              8x8 Software Multiplier for 16Cxxx Family
;*******************************************************************
;
;   The 16 bit result is stored in 2 bytes
;
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;
;*******************************************************************
;
        LIST    p=16F84 ; PIC16F844 is the target processor

	#include "P16F84.INC" ; Include header file

	cblock 0x10   ; Temporary storage
	   mulcnd     ; 8 bit multiplicand
	   mulplr     ; 8 bit multiplier, this register will be set to zero after multiply
	   H_byte     ; High byte of the 16 bit result
	   L_byte     ; Low byte of the 16 bit result
	   count      ; loop counter
	endc
;
        org   0

        goto    start
;
; *****************************         Begin Multiplier Routine
mpy_S  	clrf    H_byte
	clrf    L_byte
        movlw   8
        movwf   count
        movf    mulcnd,w
        bcf     STATUS,C        ; Clear the carry bit in the status Reg.
loop    rrf     mulplr,F
        btfsc   STATUS,C 
        addwf   H_byte,F
        rrf     H_byte,F
        rrf     L_byte,F
        decfsz  count,F
        goto    loop
;
        retlw   0
;
;********************************************************************
;               Test Program
;*********************************************************************
start   clrw
       
main    movlw   0x35
        movwf   mulplr          ; test 0x35 times 0x2D
        movlw   0x2D
        movwf   mulcnd
;
call_m  call    mpy_S           ; The result is in file registers
                                ;   H_byte & L_byte and should equal 0x0951
;
        goto    main
;
;
     END


