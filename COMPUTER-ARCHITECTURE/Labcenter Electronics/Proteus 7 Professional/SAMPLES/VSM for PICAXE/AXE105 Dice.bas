' ****** Dice using random command *****

	low 0		' make LED pins outputs
	low 1
	low 2
	low 4

main:
	let pins=0	' switch all LEDs off
	random b1	' get a random number
	if input3 is on then makenumber	' test switch
	goto main

makenumber:
	if b1>210  then showsix		' test random number and jump
	if b1>168  then showfive
	if b1>126  then showfour
	if b1>84   then showthree
	if b1>42   then showtwo

showone:
	let pins=4	' show LEDs for 1
	wait 2
	goto main

showtwo:
	let pins=16	' show LEDs for 2
	wait 2
	goto main

showthree:
	let pins=20	' show LEDs for 3
	wait 2
	goto main

showfour:
	let pins=18	' show LEDs for 4
	wait 2
	goto main

showfive:
	let pins=22	' show LEDs for 5
	wait 2
	goto main

showsix:
	let pins=19	' show LEDs for 6
	wait 2
	goto main


