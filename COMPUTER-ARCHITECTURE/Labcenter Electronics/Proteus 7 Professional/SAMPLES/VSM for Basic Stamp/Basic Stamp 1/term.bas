'-----------------------------------------------------------------------------
' 
' Simple terminal filter
'
'
'
'
'
'
'
'
'		(C)2002, Advanced Digital Technologies
'                                                                                                                                                                                                      
'=============================================================================
'
'
SYMBOL RXD	= 0
SYMBOL TXD	= 1

loop:
	SERIN	RXD,N2400,B0
	
	' change lowercase letters to uppercase
	IF B0 < "a" OR B0 > "z" THEN skip
	B0 = B0 - 32	
	
skip:	
	SEROUT	TXD,N2400,(B0)
	GOTO	loop
	
	