'-----------------------------------------------------------------------------
' 
' Sample program to drive LCD in 4-bit mode
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
SYMBOL char				= B1
SYMBOL temp				= B2
SYMBOL temp2			= B3
SYMBOL custom			= B4


SYMBOL LCD_RS			= 4
SYMBOL LCD_E			= 5
SYMBOL LCD_CLEARSCREEN  = $01
SYMBOL LCD_SETVISIBLE	= $08
SYMBOL LCD_SETMODE		= $04
SYMBOL LCD_SETDDADDR	= $80
SYMBOL LCD_CGADDR		= $40
SYMBOL PACMAN_OPENMOUTH = 16						' location of open mouth custom character
SYMBOL PACMAN_SHUTMOUTH = 24						' location of closed mouth custom character


EEPROM 0,("4-Bit LCD Mode",13)
EEPROM 16,($0E,$07,$03,$01,$03,$07,$0E,$00)
EEPROM 24,($00,$0F,$1F,$01,$1F,$0F,$00,$00)


'=============================================================================
'
'
'=============================================================================
main:
	PAUSE	200

	' initialize lcd
	LET		DIRS = $3F								' set lcd pins to output	

	LET		char = 3
	GOSUB	lcd_wrcmd	
	LET		char = 2
	GOSUB	lcd_wrcmd	
	LET		char = 12
	GOSUB	lcd_wrcmd	
	LET		char = 6
	GOSUB	lcd_wrcmd

	LET		char = LCD_CGADDR
	GOSUB	lcd_wrcmd

	' write open mouth custom character to lcd
	LET		custom = PACMAN_OPENMOUTH
	FOR B0 = 0 TO  7
		READ	custom,char
		GOSUB	lcd_wrdata
		LET		custom = custom + 1
	NEXT

	' write shut mouth custom character to lcd
	LET		custom = PACMAN_SHUTMOUTH
	FOR B0 = 0 TO  7
		READ	custom,char
		GOSUB	lcd_wrdata
		LET		custom = custom + 1
	NEXT


main_1:
	LET		B0 = 0									' reset eeprom counter
	GOSUB	lcd_cls									' clear the screen

main_2:
	READ	B0,char		
	IF char = 13 THEN main_3
	
	GOSUB	lcd_wrdata
	LET		B0 = B0 + 1
	PAUSE	150
	GOTO	main_2

main_3:
	LET		custom = 0
	
	FOR		B0 = 15 TO 0 step -1
		LET		char = LCD_SETDDADDR + B0
		GOSUB	lcd_wrcmd
		LET		char = custom
		GOSUB	lcd_wrdata
		LET		char = 32
		GOSUB	lcd_wrdata

		PAUSE	350
		LET		custom = custom ^ 1					' toggle the character
	NEXT

	PAUSE	500
	GOTO	main_1

	END


'=============================================================================
'
'
'=============================================================================
lcd_cls:
	LET		char = LCD_CLEARSCREEN
	GOSUB	lcd_wrcmd
	RETURN


'=============================================================================
'
'
'=============================================================================
lcd_wrcmd:
	' write high nibble first
	LOW		LCD_RS
	GOSUB	lcd_wrnibbles							' write data to lcd
	RETURN
	
	
'=============================================================================
'
'
'=============================================================================
lcd_wrdata:
	' write high nibble first
	HIGH	LCD_RS
	GOSUB	lcd_wrnibbles							' write data to lcd
	RETURN	



'=============================================================================
'
'
'=============================================================================
lcd_wrnibbles:
	' write MSN
	LET 	PINS = PINS & %01110000					' clear data bus
	LET 	temp = char / 16						' put high nibble of char into temp
	LET 	PINS = PINS | temp						' OR the contents of temp into pins
	PULSOUT LCD_E,1 								' strobe the E pin

	' write LSN
	LET 	PINS = PINS & %01110000					' clear data bus
	LET 	temp = char & %00001111					' put low nibble of char into temp
	LET 	PINS = PINS | temp						' OR the contents of temp into pins
	PULSOUT LCD_E,1 								' strobe the E pin

	IF char <> 1 THEN lcd_wrnibbles_1
	PAUSE 20

lcd_wrnibbles_1:	
	GOSUB	lcd_wait
	RETURN
	
'=============================================================================
'
'
'=============================================================================
lcd_wait:
	LET		DIRS = DIRS & $F0						' set data bus to input
	LOW		LCD_RS
	
lcd_wait_1:
	PULSOUT	LCD_E,1
	PULSOUT	LCD_E,1

	LET		DIRS = DIRS | $0F
	RETURN	
	
	
	