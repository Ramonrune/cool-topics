

main:	readadc 2,b1
	if b1 > 150 then show9
	if b1 > 130 then show8
	if b1 > 110 then show7
	if b1 > 90 then show6
	if b1 > 70 then show5
	if b1 > 50 then show4
	if b1 > 30 then show3
	if b1 > 20 then show2
	if b1 > 10 then show1
	
show0:
	let pins = %00111111	' digit 0
	goto main
show1:
	let pins = %00000110	' digit 1
	goto main
show2:
	let pins = %01011011	' digit 2
	goto main
show3:
	let pins = %01001111	' digit 3
	goto main
show4:
	let pins = %01100110	' digit 4
	goto main
show5:
	let pins = %01101101	' digit 5
	goto main
show6:
	let pins = %01111101	' digit 6
	goto main
show7:
	let pins = %00000111	' digit 7
	goto main
show8:
	let pins = %01111111	' digit 8
	goto main
show9:
	let pins = %01101111	' digit 9
	goto main

