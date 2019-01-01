;PIC10 Parity Checker

        LIST    p=10F202 ; 
	#include "P10F202.INC" ; Include header file

        CBLOCK 0x08   ; Temporary storage
        dc1
        bitcount
        databyte
        onecount
        ENDC


	; Vector for normal start up.
        org     0
        goto    start


; Main program starts here:
start   clrw			; Clear W.	
        movwf   GPIO            ; Ensure PORT is zero before we enable it.
        movlw	0xFD		; All inputs except GP1
        tris	GPIO

;Wait for a start bit
wstart	btfsc	GPIO,0
	goto 	wstart

	call 	waithalf

;Check start bit still low	
	btfsc	GPIO,0
	goto 	wstart
	
;Loop 8 times to capture data byte
	clrf	databyte
	clrf	onecount
	movlw	8
	movwf	bitcount
l1	call 	waitfull
	rrf	GPIO,W
	rrf	databyte,F
	btfsc	GPIO,0
	incf	onecount,F
	decfsz	bitcount,F
	goto 	l1

;Wait for parity bit
	call waitfull
	
;Add the parity bit to the 1's count	
	btfsc	GPIO,0
	incf	onecount,F
;Add the state from GP2 to the 1's count so as to switch between
;checking even or odd parity	
	btfsc	GPIO,2
	incf	onecount,F
;If the 1's count is odd we are OK, if it's odd we had a parity error
	clrw	
	btfss	onecount,0
	movlw	0x02
;Write result to the LED	
	movwf	GPIO
		
;Wait for stop bit, then go again
wstop	btfss	GPIO,0
	goto wstop
	goto wstart	

	
;Wait a full bit time	
;
waitfull	
	call waithalf
	call waithalf
	return
	
;Wait half a bit time
;
waithalf		
	movlw 0x89
	movwf dc1
wh1	
	decfsz	dc1,f
	goto wh1
	return
	
	END
