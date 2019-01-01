        LIST    p=12C671 ; 
	#include "P12C671.INC" ; Include header file

; Macro to generate a MOVLW instruction that also causes a model break:
break   MACRO arg
        DW    0x3100 | (arg & H'FF')
        ENDM

bank0   MACRO 
	bcf STATUS,RP0
	ENDM
	
bank1   MACRO
	bsf STATUS,RP0
	ENDM	

	cblock 0x20   
	result           
	count	
	endc

	; Vector for normal start up.
        org     0
        goto    start

        org     4
        goto intvec

; Main program starts here:
start   clrw			; Clear W.	
        movwf   GPIO            ; Ensure PORTA is zero before we enable it.
        movlw	0xC1
        movwf	ADCON0		; Turn on the ADC    	                                                	 
        bcf PIR1,ADIF		; Clear any pending interrupt
        bank1                                   
        bcf TRISIO,5		; GP5 is an output
        bcf TRISIO,4		; GP4 is an output
        bsf OPTION_REG,INTEDG	; Interrupt on rising edge of INT
        movlw 0x05
        movwf ADCON1		; GP0/GP1 analog inputs        

	bcf INTCON,INTF        
	bsf INTCON,INTE	
	bsf INTCON,PEIE		; Enable peripheral interrupt	
	bsf PIE1,ADIE		; Enable ADC interrupt
	bsf INTCON,GIE                                       
        
;Select voltage reference mode:
loop	sleep			; Wait for external interrupt

	bank0
        movlw   0x04		; VREF=VDD pin
        btfsc GPIO,3
        movlw  	0x05            ; VREF=VREF pin
        bank1
        movwf   ADCON1		
        bank0

;Wait out the acquisition time
	movlw 10
	movfw count
wtacc	decfsz count,F
	goto wtacc

;Do the conversion	        
	bsf ADCON0,GO		; Start the ADC
	sleep			; Wait for ADC completion
	movfw ADRES 		; Catch the result
        movwf result

;Serial output of result
	movlw 8       		;Loop for 8 bits
	movwf count	     
loop1	clrw			;Start with a zero 			
 	btfsc result,7       	;Test result bit    
	iorlw 0x20
	movwf TRISIO            ;Output data bit to port on GP5
	bsf TRISIO,4		;Generate Clock pulse on GP4
	bcf TRISIO,4                            
	rlf result,F            ;Get next result bit
	decfsz count,F		;Loop for next bit
	goto loop1
			
	goto loop	

			
;Interrupt Vector
intvec	bcf INTCON,INTF
	bcf PIR1,ADIF
	retfie
	
	END
