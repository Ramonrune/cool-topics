; EEPROM - Read Write the EEPROM.
; Specify Device.
.device AT90S8515

; I/O Register Definitions
.equ    SREG    =$3F
.equ    SP      =$3D            
.equ    TIMSK   =$39              
.equ    TIFR    =$38        
.equ    MCUCR   =$35
.equ    TCCR1A  =$2F
.equ    TCCR1B  =$2E   
.equ    OCR1AH  =$2B
.equ    OCR1AL  =$2A         
.equ    ICR1H   =$25
.equ    ICR1L   =$24
.equ    EECR	=$1C
.equ    EEDR    =$1D
.equ    EEAR    =$1E
.equ	PORTB	=$18 		
.equ	DDRB	=$17 		
.equ    PINB    =$16
.equ    PORTC   =$15    
.equ    DDRC    =$14
.equ	PINC	=$13
.equ	PORTD	=$12		
.equ	DDRD	=$11
.equ    SPDR    =$0F
.equ    SPSR    =$0E 		
.equ    SPCR    =$0D
.equ    UDR     =$0C
.equ    USR     =$0B
.equ    UCR     =$0A
.equ    UBRR    =$09
.equ    ACSR    =$08     
.equ    ADMUX   =$07
.equ    ADCSR   =$06
.equ    ADCH    =$05
.equ    ADCL    =$04       
                     
                     
; Variable Declarations
.def temp     = r16
.def isrsreg  = r17
.def isrtemp1 = r18     
.def isrtemp2 = r19    
.def isrflag  = r20     
.def X        = r26
.def Y        = r28 
.def Z        = r30

.cseg					; CODE segment.

.org 0      
	rjmp init			; origin.

	    
;Main Routine                    
init:   ldi r16,$DF			; Initialize the stack.
	out SP,r16
                    
; Write some data to the external memory at 0x0400
loop:   ldi r16,$A0			; Enable Sleep and SRAM - 0 ws
	out MCUCR,r16    
	ldi r16,$55
        sts $0400,r16           
        sts $0401,r16
        lds r0,$0400
        lds r0,$0401

	ldi r16,$E0			; Enable Sleep and SRAM - 1 ws
	out MCUCR,r16    
        ldi r16,$AA
        sts $0400,r16
        sts $0401,r16
        lds r0,$0400
        lds r0,$0401
        
	sleep	    
