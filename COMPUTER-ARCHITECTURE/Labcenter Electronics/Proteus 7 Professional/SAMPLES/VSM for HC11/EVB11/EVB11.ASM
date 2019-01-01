;EVB11 Demo Program
;A very simple example which implements a
;terminal echo program and writes the incomming 
;and outgoing characters to some LED displays.

ACIA_CONTROL  	equ $9800
ACIA_STATUS	equ $9800
ACIA_DATA  	equ $9801
                          
PORTC             equ      $1003
PORTB             equ      $1004
PORTCL            equ      $1005
DDRC              equ      $1007

                          
                org $FFFE
                dw start

                org $E000

start:          lds  #$FF

		ldaa #$03			; Reset
		staa ACIA_CONTROL

 		ldaa #$1D			; 8 bits, odd, 1 stop, div 16 clocks
 		staa ACIA_CONTROL
                                   
		ldaa #$FF
		staa DDRC
                                   

waitrx:		ldaa ACIA_STATUS
		anda #$01       
		bne readrx
		ldaa #0
delay:		deca
		bne delay
		bra waitrx

readrx:		ldab ACIA_DATA
		stab PORTB

waittx:		ldaa ACIA_STATUS
		anda #$02
		beq waittx
   	
   		stab ACIA_DATA
   		stab PORTC

done:		bra waitrx




