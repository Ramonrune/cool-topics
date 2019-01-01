;Tiny 15 - Test of ADC - also include multiplex display driver.

; Specify Device.
.device ATTINY15

; I/O Register Definitions
.equ    SREG    =$3F
.equ    GIMSK   =$3B
.equ    GIFR    =$3A
.equ    TIMSK   =$39              
.equ    TIFR    =$38 
.equ    MCUCR   =$35
.equ    TCCR0   =$33
.equ    TCNT0   =$32
.equ    TCCR1   =$30
.equ    TCNT1   =$2F
.equ    OCR1A   =$2E
.equ    OCR1B   =$2D
.equ    PORTB   =$18
.equ	DDRB	=$17
.equ    ACSR    =$08     
.equ    ADMUX   =$07
.equ    ADCSR   =$06
.equ    ADCH    =$05
.equ    ADCL    =$04       

; Variable Declarations
.def temp     = r16
.def isrsreg  = r18
.def isrtemp1 = r19     
.def isrtemp2 = r20    
.def cseg     = r21
.def seg0     = r22
.def seg1     = r23
.def seg2     = r24
.def seg3     = r25

.cseg					; CODE segment.

;Interrupt Vectors
.org 0
	rjmp init			;Reset
	reti				;INT 0
	reti				;Pin Change
	reti				;Output compare
	reti				;Timer 1
	rjmp tov0			;Timer 0
	reti				;EEPROM ready
	reti				;Analog Comparator
	reti				;ADC Complete 

;Initialization      
init:   ldi r16,$1F		; 5 bits are outputs
	out DDRB,r16   		; set portb bit 0 for outputs to display
	ldi r16,3		; Timer 0 rolls over at 1.6MHz/256/64 = 97Hz
	out TCCR0,r16
	ldi r16,$02		; Enable TOVF0
	out TIMSK,r16
	ldi cseg,$01		; Start at segment 
	sei			; Enable Interrupts                                   

	ldi r16,$8E		; Enable, ADIE, Prescale = 1/64
	out ADCSR,r16                                 
	ldi r16,0		; Select ADC0 as input, VCC as VREF
	out ADMUX,r16

loop:	ldi r16,$20		; Sleep enable, idling mode
	out MCUCR,r16                                          
	sleep			; Wait for a timer 0 interrupt
	cpi cseg,8		; Wait for write to MS segment
	breq loop
	
	ldi r16,$28		; Sleep enable, ADC low noise mode
	out MCUCR,r16                                          
	sleep			; Wait for ADC to convert

	in r0,ADCL		; Read the converted value
	in r1,ADCH

;Convert and display value for output
;Start value taken to be in r1:r0
	clr r4			;Count result
dc1a:	mov r2,r0		;Subtract 1000's
	mov r3,r1
        ldi r16,$e8
        sub r2,r16
        ldi r16,$3
        sbc r3,r16
        brcs dc1b
    	inc r4
    	mov r0,r2
    	mov r1,r3
    	rjmp dc1a		; Go again
dc1b:   mov seg0,r4		; Store result

	clr r4	
dc2a:	mov r2,r0		;Subtract 100's
	mov r3,r1
        ldi r16,100        
        sub r2,r16
        clr r16
        sbc r3,r16
        brcs dc2b
    	inc r4
    	mov r0,r2
    	mov r1,r3
    	rjmp dc2a		; Go again
dc2b:   mov seg1,r4		; Store result

	clr r4	
dc3a:	mov r2,r0		;Subtract 10's
        ldi r16,10
        sub r2,r16
        brcs dc3b
    	inc r4
    	mov r0,r2
    	rjmp dc3a		; Go again
dc3b:   mov seg2,r4		; Store result

	mov seg3,r0    		; The units are trivial
        
                                                                                                                               
	rjmp loop		; Go again               


;Timer 0 interrupt - display driver
tov0:	in isrsreg,SREG		; Preserver sreg
	
	clr isrtemp1		; Blank the display
	out PORTB,isrtemp1

	lsr cseg		; Advance segment selector address
	brcc tov0_1
	ldi cseg,0x08		; Reset to seg 3				
tov0_1: out PORTB,cseg		; Drive the latch		

	sbrc cseg,3		; Select byte to output	 
	mov isrtemp1,seg3
	sbrc cseg,2
	mov isrtemp1,seg2
	sbrc cseg,1
	mov isrtemp1,seg1
	sbrc cseg,0
	mov isrtemp1,seg0

	ldi isrtemp2,$10	;Bit 4 is set to enable the 7447
	or isrtemp1,isrtemp2	
		
	sbi PORTB,4		;Pre Assert PB4
	out PORTB,isrtemp1	;Drive the segment value onto the display

	out SREG,isrsreg
	reti
	    
