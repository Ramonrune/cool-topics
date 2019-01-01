        LIST    p=12CE518 ; 
	#include "P12CE518.INC" ; Include header file


	cblock 0x10   
	result           
	count	
	endc

	; Vector for normal start up.
        org     0
        goto    start

        
; Main program starts here:
start   movlw 0x3C
	tris  GPIO

                                              
; Write a byte
	movlw 0
	movwf EEADDR
loop	movlw 0x85
	movwf EEDATA
	call WRITE_BYTE
	movwf result

	call serout
	
; Wait for INT high	
wait1	btfss GPIO,2
	goto wait1

;Read it back
                     
        movlw 0xFF
        movwf EEDATA
        
	call READ_CURRENT
	movfw EEDATA
	movwf result
	call serout

; Wait for INT low	
wait2	btfsc GPIO,2
	goto wait2
	
	incf EEADDR,F
	goto loop	
        
;Serial output of result
serout	movlw 8       		;Loop for 8 bits
	movwf count	     
loop1	movlw 0xC0		;Start with a zero except for SDA/SCL 			
 	btfsc result,7       	;Test result bit    
	iorlw 0x01
	movwf GPIO              ;Output data bit to port on GP0
	bsf GPIO,1		;Generate Clock pulse on GP1
	bcf GPIO,1                            
	rlf result,F            ;Get next result bit
	decfsz count,F		;Loop for next bit
	goto loop1
	return
			
			

	#include fl51xinc.asm
	
	END
