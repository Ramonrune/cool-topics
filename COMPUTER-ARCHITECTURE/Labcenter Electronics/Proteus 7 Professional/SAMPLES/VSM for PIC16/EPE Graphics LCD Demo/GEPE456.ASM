; CONVERTED TASM PIC16F877 C:\PIC\GEPE456.ASM TO MPASM C:\ASMCNV\GEPE456.ASM 01-22-2001	22:15:32

	list p=16F877,r=dec
			    ;GEPE456.ASM 07SEP00 - JOHN	BECKER - EPE LCD GRAPH DEMO 2 (MAIN DEMOS)
			    
#DEFINE	  PAGE0	BCF H'03',5;STATUS bit 5
#DEFINE	  PAGE1	BSF H'03',5;STATUS bit 5
			    
INDF	  EQU H'00'	    ;page 0, 1,	2, 3
OPSHUN	  EQU H'01'	    ;page 1, 3
PCL	  EQU H'02'	    ;page 0, 1,	2, 3
STATUS	  EQU H'03'	    ;page 0, 1,	2, 3
FSR	  EQU H'04'	    ;page 0, 1,	2, 3
			    
PORTA	  EQU H'05'	    ;page 0
TRISA	  EQU H'05'	    ;page 1
PORTB	  EQU H'06'	    ;page 0, 2
TRISB	  EQU H'06'	    ;page 1, 3
PORTC	  EQU H'07'	    ;page 0
TRISC	  EQU H'07'	    ;page 1
PORTD	  EQU H'08'	    ;page 0
TRISD	  EQU H'08'	    ;page 1
PORTE	  EQU H'09'	    ;page 0
TRISE	  EQU H'09'	    ;page 1
INTCON	  EQU H'0B'	    ;page 0, 1,	2, 3
EEDATA	  EQU H'0C'	    ;page 2
EECON1	  EQU H'0C'	    ;page 3
EEADR	  EQU H'0D'	    ;page 2
			    
LOOPB	  EQU H'20'	    ; general loop
LOOPC	  EQU H'21'	    ; general loop
LOOPD	  EQU H'22'	    ; general loop
LOOPE	  EQU H'23'	    ; general loop
STORE1	  EQU H'24'	    ; temp store
TEMPA	  EQU H'25'	    ; temp store
CLKCNT	  EQU H'26'	    ; counter for PAUSE	val
ADRLSB	  EQU H'27'	    ; low address
ADRMSB	  EQU H'28'	    ; high address
ATTRIB	  EQU H'29'	    ; ATTRIBUTE	value
BITVAL	  EQU H'2A'	    ; val of bit to be set/reset
RDBYTE	  EQU H'2B'	    ; byte read	from screen
COUNT	  EQU H'2C'	    ; counter for BIRD loop, used also for waveform
COLUMN	  EQU H'2D'	    ; column length holder
QCKCOL	  EQU H'2E'	    ; quack bill column
PEAKLO	  EQU H'2F'	    ; waveform peak lo (demo 11)
PEAKHI	  EQU H'30'	    ; waveform peak hi (demo 11)
LOBIT	  EQU H'31'	    ; waveform section (demo 11)
LOOPLO	  EQU H'32'	    ; waveform section (demo 11)
			    
JOIN00	  EQU H'34'	    ; 1st store	for BIRD roll-over join	(right-hand edge bit)
			    ; extends to $50 for JOIN32, used also for waveforms
			    ; (64 for scope style)
			    
			    ;........FIXED VALUES FOR COMMANDS
			    
TXHOME	  EQU H'40'	    ; text home	address	command
TXAREA	  EQU H'41'	    ; text area	(columns) address command
GRHOME	  EQU H'42'	    ; graphics home address command
GRAREA	  EQU H'43'	    ; graphic area (columns) address command
AWRON	  EQU H'B0'	    ; autowrite	on command
AWROFF	  EQU H'B2'	    ; autowrite	off command
OFFSET	  EQU H'22'	    ; offset command
ADPSET	  EQU H'24'	    ; address set command
PEEK	  EQU H'E0'	    ; screen peek command
CSRPOS	  EQU H'21'	    ; set cursor position ommand
			    
			    ;........BIT VALUES
			    
W	  EQU 0		    ; working reg
F	  EQU 1		    ; file reg
Z	  EQU 2		    ; zero status
C	  EQU 0		    ; CARRY status
RP0	  EQU 5		    ; STATUS bank reg
RP1	  EQU 6		    ; STATUS bank reg
RD	  EQU 0		    ; EEPROM read flag
EEPGD	  EQU 7		    ; EECON1 reg
FS	  EQU B'00000000'   ;FS	mode set by bit	5: 1 = 6x8, 0 =	8x8
			    ;8x8 needed	for EPE	demos
			    
			    ;..........
			    
	  ORG 0	     
	  GOTO 5

	  ORG 5
			    
	  BCF STATUS,RP0    
	  BCF STATUS,RP1    
	  CLRF PORTA	    
	  CLRF PORTB	    
	  MOVLW	B'00001111' ; FS low, RST low, CD CE RD	WR high
	  MOVWF	PORTC	    
	  CLRF PORTD	    
	  CLRF PORTE	    
	  PAGE1		    
	  MOVLW	255	    
	  MOVWF	TRISA	    ; PORTA as input
	  CLRF TRISB	    ; PORTB as output
	  MOVLW	FS	    
	  MOVWF	TRISC	    ; PORTC as output GRAPHIC LCD control/FS
	  CLRF TRISD	    ; PORTD as output GRAPHIC LCD D0-D7
	  CLRF TRISE	    ; PORTE as output
	  MOVLW	B'10000110' ; pull-up Rs off (bit 7 hi), timer 1/25 sec
	  MOVWF	OPSHUN	    ; (for 3.2768MHz xtal)
	  PAGE0		    
	  MOVLW	B'00011111' ; FS low, RST CD CE	RD WR high
	  MOVWF	PORTC	    
			    
	  CALL PAUSIT	    
	  GOTO GRAPHIC	    
			    
TABLE1	  ADDWF	PCL,F	    
	  RETLW	'G'	    
	  RETLW	'R'	    
	  RETLW	'A'	    
	  RETLW	'P'	    
	  RETLW	'H'	    
	  RETLW	'I'	    
	  RETLW	'C'	    
	  RETLW	' '	    
	  RETLW	'L'	    
	  RETLW	'C'	    
	  RETLW	'D'	    
	  RETLW	' '	    
	  RETLW	'D'	    
	  RETLW	'E'	    
	  RETLW	'M'	    
	  RETLW	'O'	    
			    
	  RETLW	'E'	    
	  RETLW	'P'	    
	  RETLW	'E'	    
	  RETLW	' '	    
	  RETLW	'S'	    
	  RETLW	'H'	    
	  RETLW	'O'	    
	  RETLW	'W'	    
	  RETLW	'S'	    
	  RETLW	' '	    
	  RETLW	'Y'	    
	  RETLW	'O'	    
	  RETLW	'U'	    
	  RETLW	' '	    
	  RETLW	'H'	    
	  RETLW	'O'	    
	  RETLW	'W'	    
	  RETLW	'!'	    
			    
	  RETLW	'T'	    
	  RETLW	'H'	    
	  RETLW	'I'	    
	  RETLW	'S'	    
	  RETLW	' '	    
	  RETLW	'I'	    
	  RETLW	'S'	    
	  RETLW	' '	    
	  RETLW	'P'	    
	  RETLW	'A'	    
	  RETLW	'G'	    
	  RETLW	'E'	    
	  RETLW	' '	    
	  RETLW	'2'	    
			    
	  RETLW	'Q'	    
	  RETLW	'U'	    
	  RETLW	'A'	    
	  RETLW	'C'	    
	  RETLW	'K'	    
			    
AMPLIFIER ADDWF	PCL,F	    
	  RETLW	H'80'	    ; amp top left + first slope down (1
			    
	  RETLW	H'83'	    ;amp input (2
	  RETLW	H'86'	    ;cap top
	  RETLW	H'83'	    ;amp input
	  RETLW	H'83'	    ;amp input
	  RETLW	H'81'	    ;amp left
	  RETLW	H'82'	    ;amp slope down
	  RETLW	H'83'	    ;amp output
	  RETLW	H'86'	    ;cap top
	  RETLW	H'83'	    ;amp output
			    
	  RETLW	H'8B'	    ;word IN (3
	  RETLW	H'87'	    ;cap bot
	  RETLW	H'89'	    ;resistor top
	  RETLW	H'00'	    
	  RETLW	H'81'	    ;amp left
	  RETLW	H'84'	    ;amp slope up
	  RETLW	H'00'	    
	  RETLW	H'87'	    ;cap bot
	  RETLW	H'8C'	    ;1st part OUT
	  RETLW	H'8D'	    ;2nd part OUT
			    
	  RETLW	H'88'	    ;resistor (4
	  RETLW	H'00'	    
	  RETLW	H'85'	    ;amp bot left + first slope	up
			    
	  RETLW	H'88'	    ;resistor (5
	  RETLW	H'8A'	    ;resistor bot (6
	  RETLW	H'8E'	    ;0V	(7
			    
CGTABLE	  ADDWF	PCL,F	    ; EXTERNAL CG FONT DATA
			    
	  RETLW	B'10000000' ; CHARACTER	$80
	  RETLW	B'11000000' ; amp top left + first slope down
	  RETLW	B'10100000' 
	  RETLW	B'10010000' 
	  RETLW	B'10001000' 
	  RETLW	B'10000100' 
	  RETLW	B'10000010' 
	  RETLW	B'10000001' 
			    
	  RETLW	B'10000000' ; CHARACTER	$81
	  RETLW	B'10000000' ; amp left
	  RETLW	B'10000000' 
	  RETLW	B'10000000' 
	  RETLW	B'10000000' 
	  RETLW	B'10000000' 
	  RETLW	B'10000000' 
	  RETLW	B'10000000' 
			    
	  RETLW	B'10000000' ; CHARACTER	$82
	  RETLW	B'01000000' ; amp slope	down
	  RETLW	B'00100000' 
	  RETLW	B'00010000' 
	  RETLW	B'00001000' 
	  RETLW	B'00000100' 
	  RETLW	B'00000010' 
	  RETLW	B'00000001' 
			    
	  RETLW	B'00000000' ; CHARACTER	$83
	  RETLW	B'00000000' ; amp output
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
	  RETLW	B'11111111' 
			    
	  RETLW	B'00000001' ; CHARACTER	$84
	  RETLW	B'00000010' ; amp slope	up
	  RETLW	B'00000100' 
	  RETLW	B'00001000' 
	  RETLW	B'00010000' 
	  RETLW	B'00100000' 
	  RETLW	B'01000000' 
	  RETLW	B'10000000' 
			    
	  RETLW	B'10000001' ; CHARACTER	$85
	  RETLW	B'10000010' ; amp bot left + first slope up
	  RETLW	B'10000100' 
	  RETLW	B'10001000' 
	  RETLW	B'10010000' 
	  RETLW	B'10100000' 
	  RETLW	B'11000000' 
	  RETLW	B'10000000' 
			    
	  RETLW	B'00000000' ; CHARACTER	$86
	  RETLW	B'00000000' ; capacitor	top
	  RETLW	B'01111010' 
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'11001011' 
			    
	  RETLW	B'01001010' ; CHARACTER	$87
	  RETLW	B'01001010' ; capacitor	bot
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'01111010' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
			    
	  RETLW	B'00001000' ; CHARACTER	$88
	  RETLW	B'00000100' ; resistor
	  RETLW	B'00000010' 
	  RETLW	B'00000001' 
	  RETLW	B'00000010' 
	  RETLW	B'00000100' 
	  RETLW	B'00001000' 
	  RETLW	B'00010000' 
			    
	  RETLW	B'00000010' ; CHARACTER	$89
	  RETLW	B'00000010' ; resistor top
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000100' 
	  RETLW	B'00001000' 
	  RETLW	B'00010000' 
			    
	  RETLW	B'00001000' ; CHARACTER	$8A
	  RETLW	B'00000100' ; resistor bot
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000010' 
	  RETLW	B'00000000' 
			    
	  RETLW	B'00000000' ; CHARACTER	$8B
	  RETLW	B'00000000' ; word IN
	  RETLW	B'10010010' 
	  RETLW	B'10011010' 
	  RETLW	B'10010110' 
	  RETLW	B'10010010' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
			    
	  RETLW	B'00000000' ; CHARACTER	$8C
	  RETLW	B'00000000' ; 1st half word OUT
	  RETLW	B'00110010' 
	  RETLW	B'01001010' 
	  RETLW	B'01001010' 
	  RETLW	B'00110001' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
			    
	  RETLW	B'00000000' ; CHARACTER	$8D
	  RETLW	B'00000000' ; 2nd half word OUT
	  RETLW	B'01011111' 
	  RETLW	B'01000100' 
	  RETLW	B'01000100' 
	  RETLW	B'10000100' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
			    
	  RETLW	B'00000000' ; CHARACTER	$8E
	  RETLW	B'01100101' ; word 0V
	  RETLW	B'10010101' 
	  RETLW	B'10010101' 
	  RETLW	B'01100010' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
	  RETLW	B'00000000' 
			    
BITSLO	  ANDLW	7	    
	  ADDWF	PCL,F	    
	  RETLW	B'10000000' 
	  RETLW	B'01000000' 
	  RETLW	B'00100000' 
	  RETLW	B'00010000' 
	  RETLW	B'00001000' 
	  RETLW	B'00000100' 
	  RETLW	B'00000010' 
	  RETLW	B'00000001' 
			    
			    ;.............
			    
GRAPHIC	  MOVLW	34	    
	  MOVWF	COLUMN	    ;set column	length
	  CALL SETUP	    
			    
DEM1	  CALL DEMO1	    ; basic circuit diagram
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM2	  CALL DEMO2	    ; bit set/clear - square
	  CALL WAITOFF	    ; wait until switch	released
			    
DEM3	  CALL DEMO3	    ; text highlight
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM4	  CALL DEMO4	    ; cursor use
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM5	  CALL DEMO5	    ; pan between pages
	  CALL WAITOFF	    ; wait until switch	released
			    
DEM6	  CALL DEMO6	    ; switch between pages
	  CALL WAITOFF	    ; wait until switch	released
			    
DEM7	  CALL DEMO7	    ; setting AND-OR-XOR modes (superimpose)
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM8	  CALL DEMO8	    ; bird - data from EEPROM, slow travel right
	  CALL WAITOFF	    ; wait until switch	released
			    
DEM9	  CALL DEMO9	    ; full text	character set
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM10	  CALL DEMO10	    ; full graphics character set
	  CALL WAITSW	    ; wait until switch	pressed
			    
DEM11	  CALL DEMO11	    ; shifting waveform	demo - horizontal
	  CALL WAITOFF	    ; wait until switch	released
			    
DEM12	  CALL DEMO12	    ; shifting waveform	demo - scope style
	  CALL WAITOFF	    ; wait until switch	released
			    
	  GOTO GRAPHIC	    ; end of demo, restart from	beginning
			    
			    ;****** DEMO 1 CREATE & SHOW SYMBOLS AS TEXT CHARACTERS **********
			    
DEMO1	  MOVLW	B'10010100' ; text on, graphic off, cursor & blink off
	  CALL SENDCMD	    ; send command
			    
			    ; SETUP USER CG RAM
	  MOVLW	120	    ; 15 char x	8 byte = 120
	  MOVWF	LOOPC	    ;
	  CALL SETCG	    ;
			    
CIRCUIT	  CLRF ADRMSB	    ; SHOW SYMBOLS
	  MOVLW	5	    ; set column
	  CALL LINE1	    ; set cell number for line stated
	  MOVLW	1	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CLRF LOOPB	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	1	    ; set column
	  CALL LINE2	    ; set cell number for line stated
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	1	    ; set column
	  CALL LINE3	    ; set cell number for line stated
	  MOVLW	10	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	3	    ; set column
	  CALL LINE4	    ; set cell number for line stated
	  MOVLW	3	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	3	    ; set column
	  CALL LINE5	    ; set cell number for line stated
	  MOVLW	1	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	3	    ; set column
	  CALL LINE6	    ; set cell number for line stated
	  MOVLW	1	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	3	    ; set column
	  CALL LINE7	    ; set cell number for line stated
	  MOVLW	1	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CALL SHOWCG	    ;
			    
WORDS			    ; SHOW TEXT
	  CLRF ADRMSB	    
	  MOVLW	0	    ; set column
	  CALL LINE0	    ; set cell number for line stated
	  MOVLW	16	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CLRF LOOPB	    ; clear table loop counter
	  CALL SHWTXT	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE6	    ; set cell number for line stated
	  MOVLW	10	    ; character	quantity
	  MOVWF	LOOPC	    ; table loop counter remains at last call val
	  CALL SHWTXT	    ;
			    
	  CLRF ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE7	    ; set cell number for line stated
	  MOVLW	8	    ; character	quantity
	  MOVWF	LOOPC	    ; table loop counter remains at last call val
	  CALL SHWTXT	    ;
			    
	  CLRF ADRMSB	    ; THIS GOES	INTO PAGE 2
	  MOVLW	17	    ; set column
	  CALL LINE3	    ; set cell number for line stated
	  MOVLW	14	    ; character	quantity
	  MOVWF	LOOPC	    ; table loop counter remains at last call val
	  CALL SHWTXT	    ;
	  RETURN	    
			    
			    ;**********	DEMO 2 BIT SETTING/CLEARING DEMO ****************
			    
DEMO2	  MOVLW	B'10000000' ; internal CG RAM mode, OR mode
	  CALL SENDCMD	    ; send command
			    
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$00xx
	  CLRF ADRLSB	    ; set for PAGE 1
	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
	  MOVLW	B'10011100' ; text & graphic on, cursor	& blink	off
	  CALL SENDCMD	    ; send command
			    
			    ; ** SET SINGLE CENTRE BIT **
	  MOVLW	12	    ; set column number
	  MOVWF	ADRLSB	    
	  MOVLW	23	    ; set graph	line
	  CALL GLINE	    ; multiply by line length to get address
	  MOVLW	B'11111000' ; set bit 0
	  CALL BITWRITE	    
			    
	  MOVLW	B'11111000' ; bits 0-2 indicate	bit affected
	  MOVWF	STORE1	    ; bit 3 high set, low = clear
			    
			    ; ** DRAW SQUARE **
SQUARE	  MOVLW	11	    ; set column number
	  MOVWF	ADRLSB	    
	  MOVLW	30	    ; set graph	line
	  CALL GLINE	    ; multiply by line length to get address
			    
	  MOVLW	16	    
	  MOVWF	LOOPC	    
SQ1	  MOVF STORE1,W	    ; draw up
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  MOVF COLUMN,W	    
	  SUBWF	ADRLSB,F    
	  BTFSS	STATUS,C    
	  DECF ADRMSB,F	    
	  DECFSZ LOOPC,F    
	  GOTO SQ1	    
			    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
SQ1A	  MOVF COLUMN,W	    ; draw right
	  ADDLW	1	    
	  ADDWF	ADRLSB,F    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
			    
	  MOVLW	8	    
	  MOVWF	LOOPC	    
SQ2	  DECF LOOPC,W	    
	  IORWF	STORE1,W    
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  DECFSZ LOOPC,F    
	  GOTO SQ2	    
			    
	  INCF ADRLSB,F	    
	  MOVLW	8	    
	  MOVWF	LOOPC	    
SQ3	  DECF LOOPC,W	    
	  IORWF	STORE1,W    
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  DECFSZ LOOPC,F    
	  GOTO SQ3	    
			    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
SQ3A	  MOVLW	16	    ; draw down
	  MOVWF	LOOPC	    
SQ4	  MOVF STORE1,W	    
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  MOVF COLUMN,W	    
	  ADDWF	ADRLSB,F    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
	  DECFSZ LOOPC,F    
	  GOTO SQ4	    
			    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
SQ4A	  MOVF COLUMN,W	    ; draw left
	  SUBWF	ADRLSB,F    
	  BTFSS	STATUS,C    
	  DECF ADRMSB,F	    
			    
	  CLRF LOOPC	    
SQ5	  MOVF LOOPC,W	    
	  IORWF	STORE1,W    
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  INCF LOOPC,F	    
	  BTFSS	LOOPC,3	    
	  GOTO SQ5	    
			    
	  DECF ADRLSB,F	    
	  CLRF LOOPC	    
SQ6	  MOVF LOOPC,W	    
	  IORWF	STORE1,W    
	  CALL BITWRITE	    
	  BTFSS	PORTA,4	    ; check switch
	  GOTO ENDDEMO2	    
			    
	  CALL PAUSE2	    
	  INCF LOOPC,F	    
	  BTFSS	LOOPC,3	    
	  GOTO SQ6	    
			    
	  MOVLW	B'00001000' ; toggle between set/clear by bit 3
	  ADDWF	STORE1,W    
	  IORLW	B'11110000' 
	  MOVWF	STORE1	    
			    
	  BTFSC	PORTA,4	    ; check switch
	  GOTO SQUARE	    
			    
ENDDEMO2  RETURN	    
			    
			    ;************* DEMO	3 HOW TO HIGHLIGHT TEXT	****************
			    
DEMO3			    ; ** FILL SELECTED GRAPHIC AREA WITH SELECTED ATTRIBUTE VALUE **
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	0	    ; set column
	  CALL LINE0	    ; set cell number for line stated
	  MOVLW	16	    ; character	quantity to be affected
	  MOVWF	LOOPC	    ;
	  MOVLW	B'11110101' ; attribute	reverse	*
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    ;
			    ; *	TRY THESE ATTRIBUTE OPTIONS:
			    ; movlw %00000000 ;	attribute normal
			    ; movlw %11110101 ;	attribute reverse
			    ; movlw %00001000 ;	attribute blink	normal
			    ; movlw %00001101 ;	attribute blink	reverse
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE6	    ; set cell number for line stated
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	B'00001101' ; attribute	blink reverse
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    ;
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE7	    ; set cell number for line stated
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	B'00001101' ; attribute	blink reverse
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    ;
			    
			    ; ** SET FOR TEXT ATTRIBUTE	MODE **
	  MOVLW	B'10000100' ; text attribute mode
	  CALL SENDCMD	    ; send command
	  MOVLW	B'10011100' ; text & graphic on, cursor	& blink	off
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;*********** DEMO 4	SETTING	CURSOR ************
			    
DEMO4	  MOVLW	B'10010111' ; text on, graphic off, cursor & blink on
	  CALL SENDCMD	    ; send command
			    
			    ; set cursor position + type
	  MOVLW	15	    ; set column
	  MOVWF	ADRLSB	    
	  MOVLW	3	    ; set line
	  MOVWF	ADRMSB	    
	  CALL CSRADR	    
	  CALL CSRTYP	    ;set type (specified in sub-routine)
	  RETURN	    ; (from 1 to 8 lines high)
			    
			    ;*********** DEMO 5	PANNING	BETWEEN	PAGES ************
			    
DEMO5			    ; ** SHIFT PAGE 1 LEFT TO REVEAL PAGE 2
			    
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$00xx
	  MOVLW	1	    
	  MOVWF	ADRLSB	    ; set for PAGE 1 col 1
			    
	  MOVLW	16	    ;
	  MOVWF	LOOPC	    
SL2	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
SL2A	  MOVLW	5	    ; short pause
	  MOVWF	LOOPB	    
WAIT2	  BTFSS	PORTA,4	    
	  GOTO ENDDEMO5	    
	  CALL PAUSIT	    
	  DECFSZ LOOPB,F    
	  GOTO WAIT2	    
			    
	  INCF ADRLSB,F	    
	  DECFSZ LOOPC,F    
	  GOTO SL2	    
			    
	  MOVLW	17	    ; ** SHIFT PAGE 2 RIGHT TO REVEAL PAGE 1
	  MOVWF	LOOPC	    
	  MOVLW	16	    
	  MOVWF	ADRLSB	    ; set for PAGE 2
SL3	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
SL3A	  MOVLW	5	    ; short pause
	  MOVWF	LOOPB	    
WAIT3	  BTFSS	PORTA,4	    
	  GOTO ENDDEMO5	    
	  CALL PAUSIT	    
	  DECFSZ LOOPB,F    
	  GOTO WAIT3	    
			    
	  DECF ADRLSB,F	    
	  DECFSZ LOOPC,F    
	  GOTO SL3	    
	  GOTO DEMO5	    
			    
ENDDEMO5  RETURN	    
			    
			    ;*********** DEMO 6	SWITCHING BETWEEN PAGES	************
			    
DEMO6	  MOVLW	B'10000000' ; (OR mode,	Internal CG mode)
	  CALL SENDCMD	    ; send command
			    
DEMO6A			    ;**	CHANGE PAGE **
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$00xx
	  MOVLW	17	    ; set for PAGE 2
	  MOVWF	ADRLSB	    
	  CLRF LOOPC	    
SL1	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
SL1A	  MOVLW	5	    ; short pause
	  MOVWF	LOOPB	    
WAIT	  BTFSS	PORTA,4	    ; check switch press
	  GOTO ENDDEMO6	    
	  CALL PAUSIT	    
	  DECFSZ LOOPB,F    
	  GOTO WAIT	    
			    
	  INCF LOOPC,F	    
	  CLRF ADRLSB	    ; set for PAGE 1
	  BTFSS	LOOPC,1	    
	  GOTO SL1	    
	  GOTO DEMO6A	    
			    
ENDDEMO6  RETURN	    
			    
			    ;*********** DEMO 7	SETTING	AND-OR-XOR MODES ***************
			    
DEMO7			    ; ** FILL SELECTED GRAPHIC SCREEN AREA WITH	VALUES FOR AND-OR-XOR **
			    
			    ; first clear attribute data for text lines	0, 6 & 7 set in	DEMO3
			    ; but graphic data set in DEMO2 (SQUARE) not cleared
			    
	  MOVLW	B'10000000' ; clear text attribute mode
	  CALL SENDCMD	    ; send command
			    
	  MOVLW	B'10011100' ; text & graphic on, cursor	& blink	off
	  CALL SENDCMD	    ; send command
			    
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$00xx
	  MOVLW	0	    
	  MOVWF	ADRLSB	    
	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	0	    ; set column
	  CALL LINE0	    ; set cell number for line stated
	  MOVLW	16	    ; character	quantity to be affected
	  MOVWF	LOOPC	    ;
	  CLRF ATTRIB	    
	  CALL SETATTR	    
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE6	    ; set cell number for line stated
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CLRF ATTRIB	    
	  CALL SETATTR	    ;
			    
	  MOVLW	2	    ; set graphic address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVLW	6	    ; set column
	  CALL LINE7	    ; set cell number for line stated
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  CLRF ATTRIB	    
	  CALL SETATTR	    ;
			    
			    ; ** start of AND-OR XOR mode proper **
			    
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$00xx
	  MOVLW	0	    
	  MOVWF	ADRLSB	    
	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
			    
	  MOVLW	15	    ;
	  MOVWF	LOOPD	    ; set line start
AND2	  MOVLW	1	    ; set column number
	  MOVWF	ADRLSB	    
	  MOVF LOOPD,W	    ; set graph	line
	  CALL GLINE	    ; multiply by line length
	  MOVLW	10	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	B'10101010' ; fill graphic with	val shown
	  BTFSS	LOOPD,0	    
	  MOVLW	B'01010101' ; fill graphic with	val shown
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    ; send value
	  INCF LOOPD,F	    ; inc line count
	  MOVF LOOPD,W	    
	  XORLW	33	    ; has line count reached max?
	  BTFSS	STATUS,Z    
	  GOTO AND2	    
			    
SETAND			    ; ** SET AND-OR-XOR	MODE **	TRY ANY	OF THESE OPTIONS:
	  MOVLW	B'10000001' ; internal CG RAM mode, XOR
			    ; movlw %10000000 ;	internal CG RAM	mode, OR
			    ; movlw %10000011 ;	internal CG RAM	mode, AND
	  CALL SENDCMD	    ; send command
			    
			    ; ** CHANGE	DISPLAY	MODE **	TRY ANY	OF THESE OPTIONS:
	  MOVLW	B'10011100' ; text & graphic on, cursor	& blink	off
			    ; movlw %10010100 ;	text on, graphic off, cursor & blink off
			    ; movlw %10011000 ;	text off, graphic on, cursor & blink off
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;******* DEMO 8 GET	GRAPHICS (BIRD)	FROM EEPROM, DRAW & REPEAT SHIFT RIGHT ***
			    
DEMO8	  CALL CLRTXT	    
	  CALL CLRGRAPH	    
			    
	  MOVLW	16	    ; change column length to 16
	  MOVWF	COLUMN	    
	  CALL TEXTAREA	    ; SET TEXT AREA
	  CALL GRAPHAREA    ; SET GRAPHIC AREA
			    
	  MOVLW	B'10000000' ; internal CG RAM mode, OR
	  CALL SENDCMD	    ; send command
	  MOVLW	B'10011100' ; text & graphic on, cursor	& blink	off
	  CALL SENDCMD	    ; send command
			    
EPE	  CLRF ADRMSB	    ; show EPE text PT1
	  MOVLW	1	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE0	    ; set line
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	16	    ; position in table
	  MOVWF	LOOPB	    ; set table	loop counter
	  CALL SHWTXT	    ;
			    
	  CLRF ADRMSB	    ; set and show EPE text PT2
	  MOVLW	11	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE0	    ; set line
	  MOVLW	4	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	30	    ; position in table
	  MOVWF	LOOPB	    ; set table	loop counter
	  CALL SHWTXT	    ;
			    
	  BSF STATUS,RP1    ; set PIC's	Page 2 and EEPROM reading address
	  CLRF EEADR	    
	  BCF STATUS,RP1    
			    
	  CLRF LOOPD	    
	  CLRF LOOPE	    
			    
BIRDX	  MOVF LOOPE,W	    
	  MOVWF	ADRLSB	    ; set column
	  MOVLW	20	    ; set line
	  CALL GLINE	    ; multiply by line length to get address
			    
BIRD2	  MOVLW	32	    ; get & show BIRD details from EEPROM
	  MOVWF	LOOPB	    
BIRD2A	  CALL PRMGET	    
	  CALL ONEWRITE	    
	  MOVF COLUMN,W	    
	  ADDWF	ADRLSB,F    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
	  DECFSZ LOOPB,F    
	  GOTO BIRD2A	    
	  INCF LOOPE,F	    
	  BTFSS	LOOPE,4	    
	  GOTO BIRDX	    
			    
BEAK1	  BSF STATUS,RP1    
	  MOVLW	202	    ; set for reading from EEPROM byte 202
	  MOVWF	EEADR	    
	  BCF STATUS,RP1    
	  MOVLW	3	    ;
	  MOVWF	LOOPC	    
			    
	  MOVLW	H'14'	    ; CG RAM start address $1400 + 128
	  MOVWF	ADRMSB	    ; (character code $90)
	  MOVLW	128	    ; 
	  MOVWF	ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
			    
BK2	  CALL PRMGET	    ; get BIRD beak details from EEPROM
	  CALL AUTOWRITE    ; auto write beak as character $90 
	  INCF EEADR,F	    ; just 3 lines of eeprom taken as $90
	  DECFSZ LOOPC,F    ; is assumed to have been cleared earlier
	  GOTO BK2	    
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
			    
	  MOVLW	51	    ; start line for water
	  MOVWF	LOOPE	    
	  MOVLW	12	    ; number of	lines to be filled
	  MOVWF	LOOPD	    
			    
WATER	  MOVLW	0	    ; draw "WATER"
	  MOVWF	ADRLSB	    ; set column
	  MOVF LOOPE,W	    ; set line
	  CALL GLINE	    ; multiply by line length
	  MOVLW	16	    ; character	quantity
	  MOVWF	LOOPC	    
	  MOVLW	B'10101010' ; "WATER" pattern -	try changing this value
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    
	  INCF LOOPE,F	    
	  DECFSZ LOOPD,F    
	  GOTO WATER	    
			    
	  MOVLW	28	    
	  MOVWF	LOOPE	    
	  MOVLW	JOIN00	    ; clear JOIN variables
	  MOVWF	FSR	    
CLRJOIN	  CLRF INDF	    ;JKJ: removed ',F'
	  INCF FSR,F	    
	  DECFSZ LOOPE,F    
	  GOTO CLRJOIN	    
	  MOVLW	6	    
	  MOVWF	QCKCOL	    ; set quack	bill column
	  MOVLW	1	    ; loop period before next quack
	  MOVWF	COUNT	    
			    
BIRDZ	  MOVLW	23	    ; set start	line for shift right of	display
	  MOVWF	LOOPE	    
	  CLRF ADRLSB	    ; set column
	  MOVF LOOPE,W	    ; set line
	  CALL GLINE	    ; multiply by line length
	  CALL SCREENADR    ; set screen write address
	  MOVLW	JOIN00	    ; set join variable	for right-hand line bit
	  MOVWF	FSR	    
			    
BIRDY	  MOVLW	16	    ;
	  MOVWF	LOOPD	    ; set loop val (number of columns to be shifted)
			    
BIRDY2	  CALL DATAREAD	    ; read screen, returns with	val held in RDBYTE
	  RLF INDF,F	    ; rotate STORE into	CARRY
	  RRF RDBYTE,F	    ; rotate RDBYTE and	bring in CARRY bit
	  RRF INDF,F	    ; shift CARRY into STORE
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF RDBYTE,W	    ; re-store RDBYTE on screen
	  CALL OUTDATA	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  DECFSZ LOOPD,F    
	  GOTO BIRDY2	    ; repeat until done
			    
	  BTFSS	PORTA,4	    ; check switch
	  RETURN	    
			    
	  INCF FSR,F	    ; inc JOIN store address
	  INCF LOOPE,F	    ; inc line number
	  MOVF LOOPE,W	    
	  XORLW	51	    
	  BTFSS	STATUS,Z    ; has line limit been reached?
	  GOTO BIRDY	    ; no, so repeat for	next line
			    
	  DECF COUNT,F	    ; dec counter
	  BTFSS	STATUS,Z    ; is it zero?
	  GOTO BIRDZ	    ; no, so start again
			    
QUACK			    
	  CLRF ADRMSB	    ; show beak
	  MOVF QCKCOL,W	    ; set column
	  CALL LINE4	    ; set line
	  MOVLW	H'90'	    ; beak symbol
	  CALL ONEWRITE	    
			    
	  CLRF ADRMSB	    ; show QUACK text
	  MOVLW	5	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE1	    ; set line
	  MOVLW	5	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	48	    
	  MOVWF	LOOPB	    ; set table	loop counter
	  CALL SHWTXT	    ;
			    
	  MOVLW	3	    ; short pause
	  MOVWF	LOOPB	    
QK2	  CALL PAUSIT	    
	  DECFSZ LOOPB,F    
	  GOTO QK2	    
			    
	  CLRF ADRMSB	    ; clear QUACK text
	  MOVLW	5	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE1	    ; set line
	  MOVLW	5	    ; character	quantity
	  MOVWF	LOOPC	    
	  MOVLW	0	    ; clear QUACK
	  MOVWF	ATTRIB	    
	  CALL SETATTR	    
			    
	  CLRF ADRMSB	    ; clear QUACK bill
	  MOVF QCKCOL,W	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE4	    ; set line
	  MOVLW	0	    
	  CALL ONEWRITE	    
	  INCF QCKCOL,F	    
	  BCF QCKCOL,4	    
			    
	  MOVLW	8	    ; set QUACK	period loop count
	  MOVWF	COUNT	    
	  MOVF QCKCOL,W	    
	  BTFSC	STATUS,Z    
	  INCF COUNT,F	    
	  GOTO BIRDZ	    
			    
			    ;******* DEMO 9 SHOW FULL ALPHANUMERIC TEXT	SET ***
			    
DEMO9			    ; ** WRITE FULL ASCII TEXT **
	  MOVLW	B'10010100' ; text on, graphic off, cursor & blink off
	  CALL SENDCMD	    ; send command
			    
	  CLRF ADRMSB	    ;
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CLRF LOOPB	    
DM9	  MOVF LOOPB,W	    ;
	  CALL AUTOWRITE    ; auto write and increment
	  INCF LOOPB,F	    ;
	  BTFSS	LOOPB,7	    
	  GOTO DM9	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;******* DEMO 10 SHOW CHARACTER GEN	SYMBOL TEXT SET	***
			    
DEMO10			    ; ** FIRST COPY EEPROM INTO	CG RAM **
			    
	  BSF STATUS,RP1    ; set for PIC its Page 2 for EEPROM	reading
	  CLRF EEADR	    
	  BCF STATUS,RP1    
			    
	  MOVLW	H'14'	    ; CG RAM start address $1400 + 136
	  MOVWF	ADRMSB	    ;
	  MOVLW	136	    
	  MOVWF	ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; SET DATA AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CLRF LOOPB	    ;
	  MOVLW	224	    
	  MOVWF	LOOPC	    
			    
SETEG2	  MOVF LOOPB,W	    ; WRITE TO EXTERNAL	RAM
	  CALL PRMGET	    
	  CALL AUTOWRITE    ; auto write and increment
	  INCF LOOPB,F	    ; 
	  DECFSZ LOOPC,F    ; LOOPC val	specified by calling routine
	  GOTO SETEG2	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
			    
			    ; ** WRITE FULL NON-ASCII TEXT AS HELD IN CG RAM **
	  CLRF ADRMSB	    ;
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  MOVLW	128	    ; first CG RAM character $80 = 128
	  MOVWF	LOOPB	    
DM10	  MOVF LOOPB,W	    ;
	  CALL AUTOWRITE    ; auto write and increment
	  INCFSZ LOOPB,F    ;
	  GOTO DM10	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;******** DEMO 11 CREATE MOVING WAVEFORM - HORIZONTAL *************
			    
DEMO11	  CALL CLRTXT	    
	  MOVLW	B'10011100' ; text on, graphic on, cursor & blink off
	  CALL SENDCMD	    ; send command
			    
	  CLRF ADRMSB	    ; show EPE text PT1
	  MOVLW	1	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE0	    ; set line
	  MOVLW	9	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	16	    ; position in table
	  MOVWF	LOOPB	    ; set table	loop counter
	  CALL SHWTXT	    ;
			    
	  CLRF ADRMSB	    ; set and show EPE text PT2
	  MOVLW	11	    ; set column
	  MOVWF	ADRLSB	    
	  CALL LINE0	    ; set line
	  MOVLW	4	    ; character	quantity
	  MOVWF	LOOPC	    ;
	  MOVLW	30	    ; position in table
	  MOVWF	LOOPB	    ; set table	loop counter
	  CALL SHWTXT	    ;
			    
	  MOVLW	16	    ; clear temp storage memory
	  MOVWF	LOOPD	    
	  MOVLW	JOIN00	    
	  MOVWF	FSR	    
CLRMEM	  CLRF INDF	    
	  INCF FSR,F	    
	  DECFSZ LOOPD,F    
	  GOTO CLRMEM	    
			    
	  CLRF COUNT	    ; volts simulator counter
	  CLRF PEAKLO	    
			    
WAVE0	  CLRF LOOPE	    ; set start	line
WAVE1	  CLRF ADRMSB	    
	  CLRF ADRLSB	    
			    
	  MOVF COUNT,W	    ; copy loop	val into PEAKHI
	  MOVWF	PEAKHI	    
			    
	  SUBWF	PEAKLO,W    ; is PEAKHI	> PEAKLO ?
	  BTFSS	STATUS,C    ; is there a borrow?
	  GOTO WAVE2	    ; yes
			    
	  MOVF PEAKLO,W	    ; no, so swap lo & hi
	  MOVWF	PEAKHI	    
	  MOVF COUNT,W	    
	  MOVWF	PEAKLO	    
			    
WAVE2	  MOVF PEAKLO,W	    ; get LO remainder less than 8
	  CALL BITSLO	    
	  MOVWF	LOBIT	    
			    
	  RLF PEAKLO,W	    ; get LO integer (i.e. divide by 8)
	  MOVWF	LOOPLO	    
	  SWAPF	LOOPLO,W    
	  ANDLW	15	    
	  MOVWF	LOOPLO	    
			    
	  MOVF LOOPLO,W	    ; set address for 1st temp store memory
	  ADDLW	JOIN00	    
	  MOVWF	FSR	    
			    
	  BCF STATUS,C	    
	  MOVF PEAKLO,W	    
	  MOVWF	LOOPD	    
			    
WAVE3	  MOVF LOOPD,W	    
	  XORWF	PEAKLO,W    
	  BTFSC	STATUS,Z    
	  GOTO WAVE4	    
	  MOVF LOBIT,W	    
	  IORWF	INDF,F	    
	  INCF LOOPD,F	    
	  BTFSC	LOOPD,7	    
	  GOTO WAVE5	    
	  BCF STATUS,C	    
	  RRF LOBIT,F	    
	  BTFSS	STATUS,C    
	  GOTO WAVE3	    
	  INCF FSR,F	    
	  BSF LOBIT,7	    
	  BCF STATUS,C	    
	  GOTO WAVE3	    
			    
WAVE4	  MOVF LOOPD,W	    
	  XORWF	PEAKHI,W    
	  BTFSC	STATUS,Z    
	  GOTO WAVE5	    
	  MOVF LOBIT,W	    
	  IORWF	INDF,F	    
	  INCF LOOPD,F	    
	  BTFSC	LOOPD,7	    
	  GOTO WAVE5	    
	  BCF STATUS,C	    
	  RRF LOBIT,F	    
	  BTFSS	STATUS,C    
	  GOTO WAVE4	    
	  INCF FSR,F	    
	  BSF LOBIT,7	    
	  BCF STATUS,C	    
	  GOTO WAVE4	    
			    
WAVE5	  MOVLW	JOIN00	    
	  MOVWF	FSR	    
	  CLRF LOOPD	    
	  CLRF ADRLSB	    ; set column
	  MOVF LOOPE,W	    ; set line
	  CALL GLINE	    ; multiply by line length
	  CALL SCREENADR    ; set screen write address
			    
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
			    
WAVE6	  MOVF INDF,W	    ; send data	to LCD
	  CALL OUTDATA	    
	  CLRF INDF	    ; JKJ: removed ',F'
	  INCF FSR,F	    
	  INCF LOOPD,F	    
	  BTFSS	LOOPD,4	    
	  GOTO WAVE6	    
	  MOVF COUNT,W	    
	  MOVWF	PEAKLO	    
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
			    
WAVE7	  MOVLW	4	    
	  ADDWF	COUNT,F	    ; add to volts loop
	  BCF COUNT,7	    
	  BTFSS	PORTA,4	    ; is switch	on?
	  RETURN	    ; yes
	  INCF LOOPE,F	    ; no, inc line number
	  MOVF LOOPE,W	    
	  XORLW	64	    
	  BTFSS	STATUS,Z    ; has line limit been reached?
	  GOTO WAVE1	    ; no, so repeat for	next line
	  DECF COUNT,F	    ; introduce	a displacement to uniform count
	  DECF COUNT,F	    ; JKJ: taking off 4	makes it smoother.
	  DECF COUNT,F	    ; 
	  DECF COUNT,F	    ; 
	  GOTO WAVE0	    ; yes so start again
			    
			    ;******** DEMO 12 CREATE MOVING WAVEFORM - SCOPE STYLE *************
			    
DEMO12	  MOVLW	B'10011100' ; text on, graphic on, cursor & blink off
	  CALL SENDCMD	    ; send command
	  CLRF COUNT	    ; volts simulator counter
	  CLRF PEAKLO	    
	  CLRF LOOPD	    
			    
SCOPE0	  MOVLW	B'10000000' ; indicates	which bit of column is affected
	  MOVWF	LOBIT	    
			    
SCOPE1	  MOVF COUNT,W	    ; copy loop	val into PEAKHI
	  MOVWF	PEAKHI	    
	  SUBWF	PEAKLO,W    ; is PEAKHI	> PEAKLO ? (subtract hi	from lo)
	  BTFSS	STATUS,C    ; is there a borrow?
	  GOTO SCOPE2	    ; yes
			    
	  MOVF PEAKLO,W	    ; no, so swap lo & hi
	  MOVWF	PEAKHI	    
	  MOVF COUNT,W	    
	  MOVWF	PEAKLO	    
			    
SCOPE2	  MOVLW	JOIN00	    ; set address for 1st affected temp	store memory
	  ADDWF	PEAKLO,W    
	  MOVWF	FSR	    
	  MOVF PEAKLO,W	    ; set loop to val of PEAKLO
	  MOVWF	LOOPE	    
	  MOVF LOBIT,W	    
	  IORWF	INDF,F	    ; set new bit
			    
SCOPE3	  MOVF LOOPE,W	    ; is loop =	peakhi?
	  XORWF	PEAKHI,W    
	  BTFSC	STATUS,Z    
	  GOTO SCOPE4	    ; yes
	  MOVF LOBIT,W	    ; no
	  IORWF	INDF,F	    ; set new bit
	  INCF LOOPE,F	    
	  BTFSC	LOOPE,6	    
	  GOTO SCOPE4	    
	  INCF FSR,F	    
	  GOTO SCOPE3	    
			    
SCOPE4	  MOVF COUNT,W	    
	  MOVWF	PEAKLO	    
	  MOVLW	2	    
	  ADDWF	COUNT,F	    ; inc wavform counter
	  BCF COUNT,6	    ; limit to 63 max
	  BCF STATUS,C	    
	  RRF LOBIT,F	    ; shift right bitting setting val
	  BTFSS	STATUS,C    ; is CARRY set? (stating all 8 bits	of col done)
	  GOTO SCOPE1	    ; no
			    
	  MOVLW	JOIN00	    ; send 8-bit column	to screen
	  MOVWF	FSR	    
	  MOVLW	64	    
	  MOVWF	LOOPE	    ; set loop val (number of columns)
	  MOVLW	2	    ; set graphic base address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVF LOOPD,W	    ; set column
	  MOVWF	ADRLSB	    
			    
SCOPE5	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF INDF,W	    ; get val from STORE
	  CALL OUTDATA	    ;
	  CLRF INDF	    ; JKJ: removed ',F'
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  INCF FSR,F	    
	  DECF LOOPE,F	    
	  BTFSC	STATUS,Z    
	  GOTO SCOPE6	    
	  MOVF COLUMN,W	    ; set for next line
	  ADDWF	ADRLSB,F    
	  BTFSC	STATUS,0    ; add CARRY	(if any) to MSB
	  INCF ADRMSB,F	    
	  GOTO SCOPE5	    ; repeat until done
			    
SCOPE6	  INCF LOOPD,F	    ; inc to next column
	  BTFSS	LOOPD,4	    
	  GOTO SCOPE0	    
			    
	  CLRF LOOPD	    ; start again at screen left
	  MOVLW	3	    ; add displacement factor to waveform loop
	  SUBWF	COUNT,W	    
			    
	  ANDLW	B'00111111' 
	  MOVWF	COUNT	    
	  BTFSC	PORTA,4	    ; is switch	on?
	  GOTO SCOPE0	    ; no, so repeat
	  RETURN	    ; yes
			    
			    ;**********	END DEMOS - START OF SUB-ROUTINES ***************
			    
BITWRITE		    ; ** WRITE SINGLE SINGLE BIT DATA ROUTINE **
	  MOVWF	BITVAL	    
	  CALL SCREENADR    ; set screen write address
	  MOVF BITVAL,W	    
	  CALL SENDCMD	    ; send command
	  RETURN	    ;
			    
			    ;.........
			    
ONEWRITE		    ; ** WRITE SINGLE BYTE **
	  MOVWF	ATTRIB	    ; temp store val brought in	on W
	  CALL SCREENADR    ; set screen write address - vals preset at	call
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF ATTRIB,W	    
	  CALL OUTDATA	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    ;............
			    
AUTOWRITE		    ; ** AUTO WRITE ROUTINE **
	  MOVWF	TEMPA	    ; temp store value brought in on W
	  CALL CHECK8	    ; read status for DA3 = 8
	  MOVF TEMPA,W	    ; WRITE DATA
	  CALL OUTDATA	    ;
	  RETURN	    ;
			    
			    ;..............
			    
CMDADR			    ; ** SET ADDRESS FOR COMMAND SENDING **
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF ADRLSB,W	    ; WRITE DATA D1
	  CALL OUTDATA	    ;
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF ADRMSB,W	    ; WRITE DATA D2
	  CALL OUTDATA	    ;
	  RETURN	    ;
			    
			    ;.........
			    
SCREENADR		    ; ** SET ADDRESS FOR WRITE/READ TO/FROM SCREEN
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF ADRLSB,W	    ; WRITE ADDRESS LSB
	  CALL OUTDATA	    ;
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF ADRMSB,W	    ; WRITE ADDRESS MSB
	  CALL OUTDATA	    ;
	  MOVLW	ADPSET	    ; SET ADDRESS POINTER
	  CALL SENDCMD	    ; send command
	  RETURN	    ;
			    
			    ;.............
			    
TEXTHOME		    ; ** SET TEXT HOME ADDRESS **
	  CLRF ADRMSB	    ; TEXT HOME	ADDRESS	$0000
	  CLRF ADRLSB	    ;
	  CALL CMDADR	    ; send command address
	  MOVLW	TXHOME	    ;
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
GRAPHHOME		    ; ** SET GRAPHIC HOME ADDRESS **
	  MOVLW	H'02'	    ; GRAPHIC HOME ADDRESS $0200
	  MOVWF	ADRMSB	    
	  CLRF ADRLSB	    
	  CALL CMDADR	    ; send command address
	  MOVLW	GRHOME	    ;
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
TEXTAREA		    ; ** SET TEXT AREA **
	  CLRF ADRMSB	    ;
	  MOVF COLUMN,W	    ; columns length
	  MOVWF	ADRLSB	    ;
	  CALL CMDADR	    ; send command address
	  MOVLW	TXAREA	    ; text area	command
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
GRAPHAREA		    ; ** SET GRAPHIC AREA **
	  CLRF ADRMSB	    ;
	  MOVF COLUMN,W	    ; columns length
	  MOVWF	ADRLSB	    ;
	  CALL CMDADR	    ; send command address
	  MOVLW	GRAREA	    ; graphic area command
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
CSRADR			    ; ** SET CURSOR POSITION **
	  CALL CMDADR	    ; send command address
	  MOVLW	CSRPOS	    ; cursor position command
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
CSRTYP			    ; ** SET CURSOR TYPE **
	  MOVLW	B'10100111' ; 8-line
	  CALL SENDCMD	    ; send command
	  RETURN	    ; OPTIONS:
			    ; %10100000	; 1-line
			    ; %10100001	; 2-line
			    ; %10100010	; 3-line
			    ; %10100011	; 4-line
			    ; %10100100	; 5-line
			    ; %10100101	; 6-line
			    ; %10100110	; 7-line
			    ; %10100111	; 8-line
			    ;...........
			    
SETMODE			    ; ** SET MODE - MANY OPTIONS, see EPE text **
	  MOVLW	B'10000000' ; (OR mode,	Internal CG mode)
			    ; movlw %10000000 ;	External CG RAM	mode, OR
			    ; movlw %10000011 ;	External CG RAM	mode, AND
			    ; movlw %10000001 ;	External CG RAM	mode, XOR
			    ; movlw %10000100 ;	text attribute mode
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    ; %1000x000	; OR mode
			    ; %1000x001	; XOR mode
			    ; %1000x011	; AND mode
			    ; %1000x100	; Text Attribute mode
			    ; %10000xxx	; Internal CG ROM mode
			    ; %10001xxx	; External CG RAM mode
			    
			    ;...........
			    
SETOFFSET		    ; ** SET OFFSET REGISTER **
			    ; setting OFFSET address at	2 selects
			    ; CG RAM START ADDRESS = $1400 where
			    ; $80 is character number of 1st graphic byte
			    ; values below that	call ASCII text	characters
	  CLRF ADRMSB	    ;
	  MOVLW	2	    ;
	  MOVWF	ADRLSB	    ;
	  CALL CMDADR	    ; send command address
	  MOVLW	OFFSET	    ;
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;...........
			    
SETDISPLAY		    ; ** DISPLAY MODE ** SOME OPTIONS:
	  MOVLW	B'10010100' ; text on, graphic off, cursor & blink off
			    ; movlw %10011100 ;	text on, graphic on, cursor & blink off
			    ; movlw %10011000 ;	text off, graphic on, cursor & blink off
	  CALL SENDCMD	    ; send command
	  RETURN	    ; OTHER OPTIONS:
			    ; %10010000	display	off
			    ; %1001xx10	cursor on, blink off
			    ; %1001xx11	cursor on, blink on
			    ; %100101xx	text on, graphic off
			    ; %100110xx	text off, graphic on
			    ; %100111xx	text on, graphic on
			    
			    ;...........
			    
CLRTXT			    ; ** CLEAR TEXT AREA ($0000) **
	  CLRF ADRMSB	    ; clear all	text screen lines, length as set
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  MOVLW	8	    ; number of	lines
	  MOVWF	LOOPC	    
CLR2	  MOVF COLUMN,W	    ; column length
	  MOVWF	LOOPB	    ;
CLR3	  MOVLW	0	    ; write 0
	  CALL AUTOWRITE    ; auto write and increment
	  DECFSZ LOOPB,F    ;
	  GOTO CLR3	    ;
	  DECFSZ LOOPC,F    ;
	  GOTO CLR2	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;............
			    
CLRGRAPH		    ; ** CLEAR GRAPH AREA ($0200) **
	  MOVLW	H'02'	    
	  MOVWF	ADRMSB	    ;
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  MOVLW	64	    ; number of	lines
	  MOVWF	LOOPC	    
CLRG2	  MOVF COLUMN,W	    ; column length
	  MOVWF	LOOPB	    ;
CLRG3	  MOVLW	0	    ; write 0
	  CALL AUTOWRITE    ; auto write and increment
	  DECFSZ LOOPB,F    ;
	  GOTO CLRG3	    ;
	  DECFSZ LOOPC,F    ;
	  GOTO CLRG2	    ;
	  MOVLW	AWROFF	    ; AUTO RESET OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;..............
			    
CLRCG			    ; ** CLEAR CG RAM AREA ($1400) **
	  MOVLW	H'14'	    
	  MOVWF	ADRMSB	    ;
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  MOVLW	64	    ; number of	lines
	  MOVWF	LOOPC	    
CLRCG2	  MOVF COLUMN,W	    ; column length
	  MOVWF	LOOPB	    ;
CLRCG3	  MOVLW	0	    ; write 0
	  CALL AUTOWRITE    ; auto write and increment
	  DECFSZ LOOPB,F    ;
	  GOTO CLRCG3	    ;
	  DECFSZ LOOPC,F    ;
	  GOTO CLRCG2	    ;
	  MOVLW	AWROFF	    ; AUTO RESET OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;............
			    
SETCG			    ; ** SETUP USER CG RAM **
	  MOVLW	H'14'	    ; CG RAM start address 1400H
	  MOVWF	ADRMSB	    ;
	  CLRF ADRLSB	    ;
	  CALL SCREENADR    ; set screen write address
	  MOVLW	AWRON	    ; SET DATA AUTO WRITE ON
	  CALL SENDCMD	    ; send command
	  CLRF LOOPB	    ;
			    
SETCG2	  MOVF LOOPB,W	    ; WRITE TO EXTERNAL	RAM
	  CALL CGTABLE	    ; get table	data
	  CALL AUTOWRITE    ; auto write and increment
	  INCF LOOPB,F	    ; 
	  DECFSZ LOOPC,F    ; LOOPC val	specified by calling routine
	  GOTO SETCG2	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;..............
			    
SHWTXT			    ; ** SHOW TEXT HELD	IN TABLE **
	  CALL SCREENADR    ; set screen write address - vals preset at	call
	  MOVLW	AWRON	    ; SET AUTO WRITE ON
	  CALL SENDCMD	    ; send command
SHTXT1	  MOVF LOOPB,W	    ; LOOPB val	specified by calling routine
	  CALL TABLE1	    ; get table	data and convert to graphic LCD	val
	  ADDLW	224	    ; +224 is same as -32 for conversion from ASCII
	  CALL AUTOWRITE    ; auto write and increment
	  INCF LOOPB,F	    ;
	  DECFSZ LOOPC,F    ; LOOPC val	specified by calling routine
	  GOTO SHTXT1	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;..............
			    
SETATTR			    ; ** SEND ATTRIBUTE	& OTHER	DATA TO	SCREEN AS 1 CHARACTER, LOOPED
	  CALL SCREENADR    ; set screen write address - vals preset at	call
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
SETAT	  MOVF ATTRIB,W	    ; val to be	sent preset at call
	  CALL AUTOWRITE    ; auto write and increment
	  DECFSZ LOOPC,F    ; LOOPC val	specified by calling routine
	  GOTO SETAT	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;............
			    
SHOWCG			    ; ** SHOW USER CG RAM IN ORDER HELD	BY TABLE **
	  CALL SCREENADR    ; set screen write address - vals preset at	call
	  MOVLW	AWRON	    ; AUTO WRITE ON
	  CALL SENDCMD	    ; send command
SHWCG2	  MOVF LOOPB,W	    ;
	  CALL AMPLIFIER    ; get table	data
	  CALL AUTOWRITE    ; auto write and increment
	  INCF LOOPB,F	    ;
	  DECFSZ LOOPC,F    ; LOOPC val	specified by calling routine
	  GOTO SHWCG2	    ;
	  MOVLW	AWROFF	    ; AUTO WRITE OFF
	  CALL SENDCMD	    ; send command
	  RETURN	    
			    
			    ;.........
			    
CHECK3	  PAGE1		    ; STATUS CHECK for DA0/DA1 = 3
	  MOVLW	255	    ;
	  MOVWF	TRISD	    ; set PORTD	as inputs
	  PAGE0		    ; RST CD CE	RD WR 
	  MOVLW	B'00011001' ; 1	1 0 0 1	
	  MOVWF	PORTC	    ; set CE, RD low
	  NOP		    
CK3	  BTFSS	PORTD,0	    ; PORTD bit	0 set?
	  GOTO CK3	    ; no
CK3A	  BTFSS	PORTD,1	    ; PORTD bit	1 set?
	  GOTO CK3A	    ; no RST CD	CE RD WR 
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set controls
	  NOP		    
	  PAGE1		    ;
	  CLRF TRISD	    ; set PORTD	as outputs
	  PAGE0		    ;
	  RETURN	    
			    
			    ;............
			    
CHECK6	  PAGE1		    ; STATUS CHECK for DA6 low
	  BSF TRISD,6	    ; set PORTD	bit as input
	  PAGE0		    ; RST CD CE	RD WR
	  MOVLW	B'00011001' ; 1	1 0 0 1
	  MOVWF	PORTC	    ; set CE, RD low
	  NOP		    
CK6	  BTFSC	PORTD,6	    ; is PORTD bit 6 low?
	  GOTO CK6	    ; no RST CD	CE RD WR
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set controls
	  NOP		    
	  PAGE1		    ;
	  BCF TRISD,6	    ; set PORTD	bit 6 as output
	  PAGE0		    ;
	  RETURN	    
			    
			    ;............
			    
CHECK8	  PAGE1		    ; STATUS CHECK for DA3 = 8
	  BSF PORTD,3	    ; set PORTD	bit 3 as input
	  PAGE0		    ; RST CD CE	RD WR
	  MOVLW	B'00011001' ; 1	1 0 0 1
	  MOVWF	PORTC	    ; set CE, RD low
	  NOP		    
CK8	  BTFSS	PORTD,3	    ; is PORTD,3 high?
	  GOTO CK8	    ; no RST CD	CE RD WR
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set controls
	  NOP		    
	  PAGE1		    ;
	  BCF TRISD,3	    ; set PORTD	bit 3 as output
	  PAGE0		    ;
	  RETURN	    
			    
			    ;........
			    
OUTDATA			    ; ** SEND DATA ROUTINE **
	  MOVWF	TEMPA	    ; temp store val brought in	on W
			    ; RST CD CE	RD WR
	  MOVLW	B'00010111' ; 1	0 1 1 1
	  MOVWF	PORTC	    ; set CD low
	  MOVF TEMPA,W	    ; get stored data
	  MOVWF	PORTD	    ; send data
	  NOP		    ; RST CD CE	RD WR
	  MOVLW	B'00010010' ; 1	0 0 1 0
	  MOVWF	PORTC	    ; set CD, CE, WR low
	  NOP		    ; RST CD CE	RD WR
	  MOVLW	B'00010111' ; 1	0 1 1 1
	  MOVWF	PORTC	    ; set CE, WR high
	  NOP		    ; RST CD CE	RD WR
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set CD high
	  RETURN	    
			    
			    ;..........
			    
SENDCMD			    ; ** COMMAND WRITE ROUTINE **
	  MOVWF	TEMPA	    ; temp store val brought in	on W
	  CALL CHECK3	    ; read status for DA0/DA1 =	3
	  MOVF TEMPA,W	    ; WRITE COMMAND
	  MOVWF	PORTD	    ; send stored data
	  NOP		    ; RST CD CE	RD WR
	  MOVLW	B'00011010' ; 1	1 0 1 0
	  MOVWF	PORTC	    ; set CE, WR low
	  NOP		    ; RST CD CE	RD WR
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set all high
	  RETURN	    
			    
			    ;.............
			    
DATAREAD		    ; ** DATA READ ROUTINE **
	  MOVLW	PEEK	    ; screen peek command
	  CALL SENDCMD	    ; send command
	  PAGE1		    ;
	  MOVLW	255	    ;
	  MOVWF	TRISD	    ; set PORTD	as inputs
	  PAGE0		    ; RST CD CE	RD WR
	  MOVLW	B'00011001' ; 1	1 0 0 1
	  MOVWF	PORTC	    ; set CE, RD low
	  NOP		    
			    
DR1	  BTFSC	PORTD,6	    ; is PORTD STATUS bit 6 low?
	  GOTO DR1	    ; no
DR2	  BTFSS	PORTD,0	    ; is PORTD STATUS bit 0 high?
	  GOTO DR2	    ; no
DR3	  BTFSS	PORTD,1	    ; is PORTD STATUS bit 1 high?
	  GOTO DR3	    ; no
	  BCF PORTC,3	    ; set CD low
	  NOP		    
	  MOVF PORTD,W	    ; read data	value
	  MOVWF	RDBYTE	    ; store read value
			    
			    ; RST CD CE	RD WR 
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set controls
	  PAGE1		    ;
	  CLRF TRISD	    ; set PORTD	as outputs
	  PAGE0		    ;
	  RETURN	    
			    
			    ;...........
			    
LINE7	  ADDWF	COLUMN,W    ; sets line	addresses for text screen
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE6	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE5	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE4	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE3	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE2	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE1	  ADDWF	COLUMN,W    
	  BTFSC	STATUS,C    
	  INCF ADRMSB,F	    
LINE0	  MOVWF	ADRLSB	    ; COLUMN sets number of cells per line
	  RETURN	    ; ADRMSB is	set/cleared before routine called
			    
			    ;..............
			    
GLINE			    ;**	GET GRAPHIC LINE ADDRESS **
	  MOVWF	LOOPB	    ; store line val
	  MOVLW	2	    ; set graphic base address ($02xx)
	  MOVWF	ADRMSB	    
	  MOVF LOOPB,W	    ; line val = 0?
	  BTFSC	STATUS,Z    
	  RETURN	    ; yes
GLIN2	  MOVF COLUMN,W	    ; no, multiply line	length by line val
	  ADDWF	ADRLSB,F    
	  MOVLW	1	    
	  ANDWF	STATUS,W    ; extract and add CARRY (if	any) to	MSB
	  ADDWF	ADRMSB,F    
	  DECFSZ LOOPB,F    
	  GOTO GLIN2	    
	  RETURN	    
			    
			    ;............
			    
			    ;READ DATA FROM EEPROM ROUTINE modified for	PIC16F87x devices
			    ; according	to data	sheet DS30292A page 43
			    ; Routine entered with eeprom byte address preset
			    
PRMGET	  BSF STATUS,RP1    ; set for Page 2
	  BSF STATUS,RP0    ; set for Page 3
	  BCF EECON1,EEPGD  ; point to data memory
	  BSF EECON1,RD	    ; enable read flag
	  BCF STATUS,RP0    ; set for Page 2 
	  MOVF EEDATA,W	    ; read eeprom data into W
	  INCF EEADR,F	    ; inc address
	  BCF STATUS,RP1    ; set for Page 0
	  RETURN	    
			    
			    ;.........
			    
WAITSW	  BTFSC	PORTA,4	    ; wait for switch press
	  GOTO WAITSW	    
	  CALL PAUSIT	    ; allow for	switch bounce, then wait switch	release
			    
WAITOFF			    ; wait for switch release
WT2	  BTFSS	PORTA,4	    
	  GOTO WT2	    
	  CALL PAUSIT	    ; allow for	switch bounce
	  RETURN	    
			    
			    ;................
			    
PAUSIT	  MOVLW	5	    ; pause routine, 1/5th sec
	  MOVWF	CLKCNT	    
	  CLRF INTCON	    
PAUSE	  BTFSS	INTCON,2    
	  GOTO PAUSE	    
	  BCF INTCON,2	    
	  DECFSZ CLKCNT,F   
	  GOTO PAUSE	    
	  RETURN	    
			    
			    ;................
			    
PAUSE2	  MOVLW	1	    ; pause routine, 1/25th sec
	  MOVWF	CLKCNT	    
	  CLRF INTCON	    
PAUS2	  BTFSS	INTCON,2    
	  GOTO PAUSE	    
	  BCF INTCON,2	    
	  DECFSZ CLKCNT,F   
	  GOTO PAUS2	    
	  RETURN	    
			    
			    ;..............
			    
SETUP			    ; RST CD CE	RD WR GENERAL SETUP
	  MOVLW	B'00011111' ; 1	1 1 1 1
	  MOVWF	PORTC	    ; set controls high	(off)
	  CALL TEXTHOME	    ; SET TEXT HOME ADDRESS
	  CALL GRAPHHOME    ; SET GRAPHIC HOME ADDRESS
	  CALL TEXTAREA	    ; SET TEXT AREA
	  CALL GRAPHAREA    ; SET GRAPHIC AREA
	  CALL SETMODE	    ; SET MODE (INT/EXT/AND-OR-XOR etc)
	  CALL SETOFFSET    ; SET OFFSET (see EPE text)
	  CALL SETDISPLAY   ; DISPLAY MODE (text, graph	on/off etc)
	  CALL CLRTXT	    ; WRITE TEXT BLANK CODE $0000
	  CALL CLRGRAPH	    ; WRITE GRAPH BLANK	CODE $0200
	  CALL CLRCG	    ; WRITE CGRAM BLANK	CODE $1400
	  RETURN	    
			    
			    ;..............
			    
	  END		    
			    
