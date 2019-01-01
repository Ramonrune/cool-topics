' Cyper Pet Program 1
' For PICAXE-08

' LDR on pin 1
' Push switch on pin 3
' LEDs on pins 0 and 4
' Piezo sounder on pin 2

symbol light = b1
	
' ***** main loop *****

' loop here flashing lights
' and checking switch and light sensor

main:

' LEDs full on and read light value
	high 4
	high 0
	readadc 1,light

' if light value low then goto bed
	if light < 80 then bed

' if switch pushed do sound
	if pin3 = 1 then purr

' do a delay
	pause 500

' LEDs full off and check sensor again
	low 4
	low 0
	readadc 1,light

' if light value low then goto bed
	if light < 80 then bed

' if switch pushed do sound
	if pin3 = 1 then purr

	pause 500
	goto main


' ***** make sound *****
purr:
	sound 2,(80,50,80,50,120,50)
	pause 200
	goto main


' ***** bed routine when in dark ****
' in dark so switch off LEDs and wait till
' light again

bed:
	low 0
	low 4
	readadc 1,light
	if light > 80 then main
	goto bed




