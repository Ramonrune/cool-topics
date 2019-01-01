;***** STK500 LEDS and SWITCH demonstration
.include "m48def.inc"
.def Temp =r16 ; Temporary register
.def Delay =r17 ; Delay variable 1
.def Delay2 =r18 ; Delay variable 2
;***** Initialization
RESET:
ser Temp
out DDRB,Temp ; Set PORTB to output
;**** Test input/output
LOOP:
out PORTB,temp ; Update LEDS
sbis PIND,0x00 ; If (Port D, pin0 == 0)
inc Temp ; then count LEDS one down
sbis PIND,0x01 ; If (Port D, pin1 == 0)
dec Temp ; then count LEDS one up
sbis PIND,0x02 ; If (Port D, pin2 == 0)
ror Temp ; then rotate LEDS one right
sbis PIND,0x03 ; If (Port D, pin3 == 0)
rol Temp ; then rotate LEDS one left
sbis PIND,0x04 ; If (Port D, pin4 == 0)
com Temp ; then invert all LEDS
sbis PIND,0x05 ; If (Port D, pin5 == 0)
neg Temp ; then invert all LEDS and add 1
sbis PIND,0x06 ; If (Port D, pin6 == 0)
swap Temp ; then swap nibbles of LEDS
;**** Now wait a while to make LED changes visible.
DLY:
dec Delay
brne DLY
dec Delay2
brne DLY
rjmp LOOP ; Repeat loop forever
