;****************************************************************
;*	Microchip Technology Inc. 2007								*
;*	Assembler version: 											*
;*	Filename: 													*
;*		Main.asm (main routine)   								*
;*	Dependents:													*
;*		LCD.asm													*
;*		Math.asm												*
;*		18F8722.lkr	or 18F87J11.lkr								*
;*	Jan 29,2008													*
;* 	HPC explorer 2. The following functions are included 		*
;*	with this code:												*
;*		1. Voltmeter											*
;*			The center tap of R3 is connected to RA0, the		*
;*			A/D converter converts this analog voltage and		*
;*			the result is displayed on the LCD in a range		*
;*			from 0.00V - 5.00V .								*
;*		2. Temperature											*
;*			The MCP9701A Analog  Thermal Sensor is used to    	*
;*			measure ambient temperature. 						*
;*		3. Clock												*
;*			This function is a real-time clock. When the		*
;*			mode is entered, time begins at 00:00:00. The 		*
;*			user can set the time if desired.					*
;*																*	
;****************************************************************

#ifdef __18F8722
	list p=18F8722
	#include p18F8722.inc
   CONFIG	OSC = HSPLL
   CONFIG	FCMEN = OFF
   CONFIG	IESO = OFF
   CONFIG	PWRT = OFF           
   CONFIG	BOREN = OFF
   CONFIG	WDT = OFF 
   CONFIG	MCLRE = ON  
   CONFIG	LVP = OFF  
   CONFIG	XINST = OFF 
#endif

#ifdef __18F87J11
	list p=18F87J11
	#include p18F87J11.inc
    CONFIG	FOSC = HSPLL
	CONFIG STVREN = OFF,XINST = OFF,WDTEN = OFF,CP0 = OFF,FCMEN = OFF,IESO = OFF
	CONFIG      MODE = MM 

#endif

	#define	scroll_dir	TRISA,5
	#define	scroll		PORTA,5		;Push-button RA5 on PCB
	#define	select_dir	TRISB,0		
	#define	select		PORTB,0		;Push-button RB0 on PCB

#define	EEPROM_CS		LATA,3	    ; EEprom chip select
#define	EEPROM_CS_TRIS	TRISA,3	    ; EEprom chip select


	EXTERN	LCDInit, temp_wr, d_write, i_write, LCDLine_1, LCDLine_2
	EXTERN	UDIV1608L, AARGB0, AARGB1, BARGB0
	EXTERN 	Delay,Check,InitSPI
	EXTERN 	ARG1H,ARG1L,ARG2H,ARG2L,RES0,RES1,RES2,RES3,Mul16 



variables	UDATA_ACS
ptr_pos		RES 1
ptr_count	RES 1
temp_1		RES 1
temp_2		RES 1
temp_3		RES 1
cmd_byte	RES 1
temperature	RES 1
LSD			RES 1
MsD			RES 1
MSD			RES 1
seconds		RES 1
minutes		RES 1
hours		RES 1

NumH		RES 1
NumL		RES 1
TenK		RES 1
Thou		RES 1
Hund		RES 1
Tens		RES 1
Ones		RES 1

adr  		RES 1
dat			RES	1

STARTUP CODE 0
	NOP
	goto	start
	NOP
	NOP
	NOP
PROG1 	CODE

stan_table				;table for standard code
	;		"XXXXXXXXXXXXXXXX"
	;				ptr:
	data	"   Voltmeter    "	;0
	data	"                "	;16
	data	"  Temperature   "	;32
	data	"     Clock      "	;48
	data	"RB0=Now RA5=Next"	;64
	data	"Microchip PICDEM"  ;80
	data	" PIC18 Explorer "	;96
	data	"RB0=Menu RA5=Set"	;112
	data	"RB0= ++ RA5= -->"	;128
	data	"   RB0 = Exit 	 "	;144
	data	"Volts =	     "	;160

start

	;bsf	  	OSCTUNE,PLLEN		;Enable PLL
	call 	LCDInit				;Initialize the LCD


#ifdef __18F8722
	movlw	b'00001110'			;RA0 = analog input
	movwf	ADCON1
#endif
#ifdef __18F87J11
	bsf		WDTCON,ADSHR		;Shared SFR
	setf	ANCON0
	setf	ANCON1
	bcf		ANCON1,0			;Make RA0 Analog input	
	bcf		WDTCON,ADSHR
#endif

	movlw	B'10100100'			;initialize USART
	movwf	TXSTA				;8-bit, Async, High Speed
	movlw	.255
	movwf	SPBRG				;9.6kbaud @ 40MHz
	movlw	B'10010000'
	movwf	RCSTA

	bsf	TRISB,0					;make switch RB0 an Input
	bsf	TRISA,5					;make switch RA5 an Input

;**************** STANDARD CODE MENU SELECTION *******************
			;Introduction
	movlw	.80					;send "Microchip PICDEM" to LCD
	movwf	ptr_pos
	call	stan_char_1

	movlw	.96					;send " HPC Explorer2 " to LCD
	movwf	ptr_pos
	call	stan_char_2
	call	delay_1s			;delay for display


menu

	btfss	scroll				;wait for RA5 release
	goto	$-2		
	btfss	select				;wait for RB0 release
	goto	$-2


;------------------ VOLT MEASUREMENT  ----------------------------
	call delay_100ms
	call delay_100ms
	call delay_100ms
	btfss	scroll				;YES
	bra	$-2						;wait for release

	movlw	0x00				;Display  " Voltmeter  "
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64					;Display "RB0=Now RA5=Next"
	movwf	ptr_pos
	call	stan_char_2

;wait for key press 
v_wait
	btfss	select				;Check Voltage?
	bra	voltmeter
	btfsc	scroll				;Goto Next
	bra	v_wait					;NO



;----------------- TEMPERATURE MEASUREMENT ----------------------
menu_temp
	call delay_100ms
	call delay_100ms
	call delay_100ms
	btfss	scroll				;wait for RA5 release
	bra	$-2	
	

	movlw	.32					;Display "Temperature"
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64					;Display "RB0=Now RA5=Next"
	movwf	ptr_pos
	call	stan_char_2



t_wait
	btfss	select				;Check temperature
	bra	temp					;YES
	btfsc	scroll				;Goto Next
	bra	t_wait					;NO


;------------------ CLOCK TIME ----------------------------------
menu_clock
	call	delay_100ms
	call delay_100ms
	call delay_100ms
	btfss	select;				;wait for RB0 release
	bra	$-2;			

	movlw	.48					;Display "Clock           "
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64					;Display "RB0=Now RA5=Next"
	movwf	ptr_pos
	call	stan_char_2


c_wait
	btfss	select				;Goto Time
	bra	clock					;YES
	btfsc	scroll				;Go back to Main menu
	bra	c_wait	

	bra	menu					;begining of menu

;*******************************************************************




;************* STANDARD USER CODE **********************************
;------------- Voltmeter--------------------------------------------
voltmeter
	call    delay_1s
	btfss	select				;wait for RB0 release
	bra	$-2

#ifdef __18F8722
	clrf	ADCON0
	bsf		ADCON0,0			;turn on A/D

	movlw	b'00001110'			;RA0 = analog input
	movwf	ADCON1

	movlw	b'10111010';        ;right Justified Fosc/32
	movwf	ADCON2
#endif
#ifdef __18F87J11

	bsf		WDTCON,ADSHR		;Shared SFR
	setf	ANCON0
	setf	ANCON1
	bcf		ANCON1,0			;Make RA0 Analog input	
	bcf		WDTCON,ADSHR

	clrf	ADCON0
	bsf		ADCON0,0			;turn on A/D	

	movlw	b'10111010'			;Fos/32 right justified
	movwf	ADCON1


#endif


	movlw	.160				;send "Volts = " to the LCD
	movwf	ptr_pos
	call	stan_char_1
volts_again
	bsf	ADCON0,GO				;start conversion
	btfsc	ADCON0,GO
	bra	$-2
	movff	ADRESL,ARG1L
	movff	ADRESH,ARG1H

#ifdef __18F8722
	movlw	.49						;ADC voltage steps  5V/1023
#endif
#ifdef __18F87J11
	movlw	.32						;ADC voltage steps  3.3V/1023
#endif
	movwf	ARG2L
	clrf	ARG2H

	call	Mul16
	
	movff	RES0,AARGB1
	movff	RES1,AARGB0		
	
	movlw	0x64					;divide result by 100 (0x64)
	movwf	BARGB0
	call	UDIV1608L
	
	movf	AARGB0,W				;prepare for 16-bit binary to BCD
	movwf	NumH
	movf	AARGB1,W
	movwf	NumL
	call	bin16_bcd				;get volts ready for LCD
	
	call	LCDLine_2				;display A/D result on 2nd line
	movf	Hund,W					;get hunds
	call	bin_bcd
	movf	LSD,W					;send high digit from the LSD #.xx	
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;send decimal point "."
	movwf	temp_wr
	call	d_write
	
	movf	Tens,W					;get tens
	call	bin_bcd
	movf	LSD,W					;send low digit   x.#x
	movwf	temp_wr
	call	d_write

	movf	Ones,W					;get ones
	call	bin_bcd
	movf	LSD,W					;send low digit   x.x#
	movwf	temp_wr
	call	d_write
	movlw	A'V'					;send "V" unit
	movwf	temp_wr
	call	d_write

	movlw	0x20					;3 spaces	
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write
	movlw	A'R'					;Display  "RB0=Exit" to LCD
	movwf	temp_wr
	call	d_write
	movlw	A'B'			
	movwf	temp_wr
	call	d_write
	movlw	A'0'			
	movwf	temp_wr
	call	d_write
	movlw	A'='			
	movwf	temp_wr
	call	d_write
	movlw	A'E'			
	movwf	temp_wr
	call	d_write
	movlw	A'x'		
	movwf	temp_wr
	call	d_write
	movlw	A'i'			
	movwf	temp_wr
	call	d_write
	movlw	A't'			
	movwf	temp_wr
	call	d_write
	movlw	0x20					;2 spaces	
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write

	movlw	"\r"					;move data into TXREG
	movwf	TXREG					;carriage return
	btfss	TXSTA,TRMT				;wait for data TX
	bra	$-2
	
	btfss	select					;exit volt measurement ??
;	bra	menu_buz					;YES
	bra menu_temp
	bra	volts_again					;NO, do conversion again


;---------------------- Temperature -------------------------------- 
temp
;	This code if for the MCP9701A temperature sensor
	call    delay_1s
	btfss	select					;wait for RB0 release
	bra	$-2

#ifdef __18F8722
	bsf		ADCON0,0				;turn on A/D
	bsf		ADCON0,CHS0				;Channel1

	movlw	b'00001101'				;RA1= analog input
	movwf	ADCON1

	movlw	b'10111010'				;right justified Fosc/32
	movwf	ADCON2
#endif

#ifdef __18F87J11
	clrf	ADCON0
	bsf		ADCON0,0				;turn on A/D	
	bsf		ADCON0,CHS0				;Channel 1

	movlw	b'10111010'      		;right justified Fosc/Tosc
	movwf	ADCON1

	bsf		WDTCON,ADSHR			;Shared SFR
	setf	ANCON0
	setf	ANCON1
	bcf		ANCON1,0				;Make RA0 Analog input	
	bcf		ANCON1,1				;Make RA1 Analog input	
	bcf		WDTCON,ADSHR
#endif

tempnew

	bsf	ADCON0,GO					;start conversion
	btfsc	ADCON0,GO
	bra	$-2

	movff	ADRESL,ARG1L
	movff	ADRESH,ARG1H

#ifdef __18F8722
	movlw	.49						;ADC voltage steps  
#endif
#ifdef __18F87J11
	movlw	.32
#endif
	movwf	ARG2L
	clrf	ARG2H

	call	Mul16

	movff	RES0,AARGB1
	movff	RES1,AARGB0

 	movlw	0xA0					; for 400mv for 9701A(0x0FA0)
	subwf	AARGB1,f

	btfss	STATUS,C
	decf	AARGB0
	movlw	0x0F					;for 400mv for 9701A(0x0FA0)
	subwf	AARGB0,f
	



	movlw	0xC3					;divide result by 195 for 19.5mV (0xC3)
	movwf	BARGB0
	call	UDIV1608L



	movf	AARGB1,w
	call	bin_bcd	

	call	LCDLine_1
	movlw	A'T'					;send "Temp=" to LCD
	movwf	temp_wr	
	call	d_write
	movlw	A'e'
	movwf	temp_wr	
	call	d_write
	movlw	A'm'
	movwf	temp_wr	
	call	d_write
	movlw	A'p'
	movwf	temp_wr	
	call	d_write
	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write
	movlw	A'='
	movwf	temp_wr	
	call	d_write

	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write


	movlw	A'='
	movwf	temp_wr	
	call	d_write

	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write

	movf	MSD,W					;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,W					;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send low digit
	movwf	temp_wr
	call	d_write
	movlw	A'C'					;send "C" for celcius
	movwf	temp_wr	
	call	d_write

	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write
	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write
	movlw	0x20					;space
	movwf	temp_wr	
	call	d_write
	
	call	LCDLine_2				;send "RB0 = Exit" to LCD
	movlw	.144
	movwf	ptr_pos
	call	stan_char_2
	

	NOP
	call	delay_100ms
	
	btfss	select					;exit ?
	bra	menu_clock1					;YES, goto main menu
	bra tempnew


menu_clock1							;Write the temperature to eeprom 
	call	InitEEprom
	call	WriteEEprom
	bra	menu_clock
	
;----------------- CLOCK ------------------------------------------

clock
	call    delay_1s
	btfss	select					;wait for RB0 release
	bra	$-2

	
	movlw	0x0F					;intitialize TIMER1
	movwf	T1CON
	clrf	seconds
	clrf	minutes
	clrf	hours
overflow	
	bcf	PIR1,TMR1IF
	movlw	0x80		
	movwf	TMR1H					;load regs for 1 sec overflow
	clrf	TMR1L

	incf	seconds,F				;increment seconds
	movf	seconds,W
	sublw	.60
	btfss	STATUS,Z				;increment minutes ?
	bra	clk_done
	incf	minutes,F		
	clrf	seconds

	movf	minutes,W
	sublw	.60
	btfss	STATUS,Z				;increment hours ?
	bra	clk_done	
	incf	hours,F			
	clrf	minutes

	movf	hours,W
	sublw	.13
	btfss	STATUS,Z
	bra	clk_done
	movlw	.1						;start a new 12 hour period
	movwf	hours
clk_done
	movf	hours,W					;send hours to LCD
	call	bin_bcd

	call	LCDLine_1				;place time on line 1

	movf	MsD,W					;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A					;send  :   colon
	movwf	temp_wr
	call	d_write

	movf	minutes,W				;send minutes to LCD
	call	bin_bcd

	movf	MsD,W					;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A					; send :   colon
	movwf	temp_wr
	call	d_write

	movf	seconds,W				;send seconds to LCD
	call	bin_bcd

	movf	MsD,W					;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send low digit
	movwf	temp_wr
	call	d_write

	movlw	0x20					;send 3 spaces after 00:00:00
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	
	movlw	.112					;send "RA5=Dn RB0=Menu" to LCD
	movwf	ptr_pos
	call	stan_char_2
ClockLoop							;ndebug
	btfss	scroll					;set time ??
	bra	set_time

	btfss	select					;return to main menu ??
	bra	menu
	
	btfss	PIR1,TMR1IF				;has timer1 overflowed ?	
	goto	ClockLoop				;	ndebug
	bra	overflow					;YES

	return
;*******************************************************************
InitEEprom
	bcf 	EEPROM_CS_TRIS
	call	InitSPI
	bsf		EEPROM_CS
	return
ReadEEprom
	bcf		EEPROM_CS
	movlw	0x03
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	call	Check
	movf	adr,w
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	btfss	PIR1,SSPIF
	goto	$-2
	bcf		PIR1,SSPIF


;	movff	SSPBUF,LATD
	movf	SSPBUF,w
	bsf		EEPROM_CS	
			
	return
WriteEEprom
	bcf		EEPROM_CS
	movlw	0x06					;Write Latch enable
	movwf	SSPBUF
	call	Check
	bsf		EEPROM_CS

	call	Delay

	bcf		EEPROM_CS
	movlw	0x02					;Write command
	movwf	SSPBUF
	call	Check
	movlw	0x00					;Read from Address
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	call	Check
	
	movf	MSD,w					;write the data in MSD,MsD and LSD
	movwf	SSPBUF
	call	Check
	movf	MsD,w
	movwf	SSPBUF
	call	Check
	movf	LSD,w
	movwf	SSPBUF
	call	Check
	bsf		EEPROM_CS
	return







;************************** ROUTINES ******************************
;******************************************************************
;******************************************************************

;----Standard code, Place characters on line-1--------------------------
stan_char_1
	call	LCDLine_1				;mvoe cursor to line 1 
	movlw	.16						;1-full line of LCD
	movwf	ptr_count
	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F

stan_next_char_1
	tblrd	*+
	movff	TABLAT,temp_wr			
	call	d_write					;send character to LCD

	decfsz	ptr_count,F				;move pointer to next char
	bra	stan_next_char_1

	movlw	"\n"					;move data into TXREG
	movwf	TXREG					;next line
	btfss	TXSTA,TRMT				;wait for data TX
	goto	$-2
	movlw	"\r"					;move data into TXREG
	movwf	TXREG					;carriage return
	btfss	TXSTA,TRMT				;wait for data TX
	goto	$-2

	return

;----Standard code, Place characters on line-2--------------------------
stan_char_2	
	call	LCDLine_2				;move cursor to line 2 
	movlw	.16						;1-full line of LCD
	movwf	ptr_count
	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F

stan_next_char_2
	tblrd	*+
	movff	TABLAT,temp_wr
	call	d_write					;send character to LCD

	decfsz	ptr_count,F				;move pointer to next char
	bra	stan_next_char_2

	movlw	"\n"					;move data into TXREG
	movwf	TXREG					;next line
	btfss	TXSTA,TRMT				;wait for data TX
	goto	$-2
	movlw	"\r"					;move data into TXREG
	movwf	TXREG					;carriage return
	btfss	TXSTA,TRMT				;wait for data TX
	goto	$-2

	return
;----------------------------------------------------------------------


;------------------ 100ms Delay --------------------------------
delay_100ms
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	call Delaysmall
	return


Delaysmall ;100ms at 4Mhz
	movlw	0xFF
	movwf	temp_1
	movlw	0x83
	movwf	temp_2

d100l1
	decfsz	temp_1,F
	bra	d100l1
	decfsz	temp_2,F
	bra	d100l1
	return

;---------------- 1s Delay -----------------------------------
delay_1s
	call	Ldelay
	call	Ldelay
	call	Ldelay
	call 	Ldelay
	call	Ldelay
	call 	Ldelay
	call 	Ldelay
	call 	Ldelay
	call	Ldelay
	call 	Ldelay
	return




Ldelay		;1S at f Mhx
	movlw	0xFF
	movwf	temp_1
	movwf	temp_2
	movlw	0x05
	movwf	temp_3
d1l1
	decfsz	temp_1,F
	bra	d1l1
	decfsz	temp_2,F
	bra	d1l1
	decfsz	temp_3,F
	bra	d1l1
	return	

;---------------- Set Current Time ----------------------------
set_time
	movlw	.128					;send "RA5= --> RBO= ++" to LCD
	movwf	ptr_pos
	call	stan_char_2
set_time_again
	btfss	scroll					;wait for button release
	bra	$-2

	call	LCDLine_1				;start at 0x00 on LCD

	btfss	select					;wait for RB0 button release
	bra	$-2
	call	delay_100ms			
	btfss  	select					;increment hours (tens) ?
	bra	inc_hours
	bra	next_digit
inc_hours	
	incf	hours
	movf	hours,W					;check if hours has passed 12 ?
	sublw	.13
	btfss	STATUS,Z
	bra	next_digit
	clrf	hours					;YES, reset hours to 00
next_digit
	btfss	scroll					;move to next digit
	bra	inc_mins
	movf	hours,W		

	call	bin_bcd					;get hours ready for display
	
	movf	MsD,W					;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A					;send   :   colon
	movwf	temp_wr
	call	d_write

	bra	set_time_again
	
inc_mins
	btfss	scroll					;wait for RA5 button release
	bra	$-2
	call	LCDLine_1
	movlw	0x14					;shift cursor to right 3 places
	movwf	temp_wr
	call	i_write
	movlw	0x14
	movwf	temp_wr
	call	i_write
	movlw	0x14
	movwf	temp_wr
	call	i_write
	
	btfss	select					;wait for RB0 button release
	bra	$-2
	call	delay_100ms
	btfss  	select					;increment minutes (tens) ?
	bra	inc_minutes
	bra	next_digit?
inc_minutes	
	incf	minutes
	movf	minutes,W				;check if hours has passed 12 ?
	sublw	.60
	btfss	STATUS,Z
	bra	next_digit?
	clrf	minutes
next_digit?
	btfss	scroll					;move to next digit
	bra	set_time_done
	movf	minutes,W
		
	call	bin_bcd					;get minutes ready for display
	
	movf	MsD,W					;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W					;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A					;send  :   colon
	movwf	temp_wr
	call	d_write	
	bra	inc_mins

set_time_done
	btfss	scroll					;wait for RA5 button release
	bra	$-2
	bra	overflow
	
;---------------- Binary (8-bit) to BCD -----------------------
;		255 = highest possible result
bin_bcd
	clrf	MSD
	clrf	MsD
	movwf	LSD						;move value to LSD
ghundreth	
	movlw	.100					;subtract 100 from LSD
	subwf	LSD,W
	btfss	STATUS,C				;is value greater then 100
	bra	gtenth						;NO goto tenths
	movwf	LSD						;YES, move subtraction result into LSD
	incf	MSD,F					;increment hundreths
	bra	ghundreth	
gtenth
	movlw	.10						;take care of tenths
	subwf	LSD,W
	btfss	STATUS,C
	bra	over						;finished conversion
	movwf	LSD
	incf	MsD,F					;increment tenths position
	bra	gtenth
over								;0 - 9, high nibble = 3 for LCD
	movf	MSD,W					;get BCD values ready for LCD display
	xorlw	0x30					;convert to LCD digit
	movwf	MSD
	movf	MsD,W
	xorlw	0x30					;convert to LCD digit
	movwf	MsD
	movf	LSD,W
	xorlw	0x30					;convert to LCD digit
	movwf	LSD
	retlw	0

;---------------- Binary (16-bit) to BCD -----------------------
;		xxx = highest possible result
bin16_bcd
	                       			; Takes number in NumH:NumL 
                                	; Returns decimal in 
                                	; TenK:Thou:Hund:Tens:Ones 
        swapf   NumH,W 
        andlw   0x0F
        addlw   0xF0
        movwf   Thou 
        addwf   Thou,F 
        addlw   0xE2 
        movwf   Hund 
        addlw   0x32 
        movwf   Ones 

        movf    NumH,W 
        andlw   0x0F 
        addwf   Hund,F 
        addwf   Hund,F 
        addwf   Ones,F 
        addlw   0xE9 
        movwf   Tens 
        addwf   Tens,F 
        addwf   Tens,F 

        swapf   NumL,W 
        andlw   0x0F 
        addwf   Tens,F 
        addwf   Ones,F 

        rlcf     Tens,F 
        rlcf     Ones,F 
        comf    Ones,F 
        rlcf     Ones,F 

        movf    NumL,W 
        andlw   0x0F 
        addwf   Ones,F 
        rlcf     Thou,F 

        movlw   0x07 
        movwf   TenK 

        movlw   0x0A            	; Ten 
Lb1: 
        decf    Tens,F 
        addwf   Ones,F 
        btfss   STATUS,C 
         bra   Lb1 
Lb2: 
        decf    Hund,F 
        addwf   Tens,F 
        btfss   STATUS,C 
         bra   Lb2 
Lb3: 
        decf    Thou,F 
        addwf   Hund,F 
        btfss   STATUS,C
         bra   Lb3 
Lb4: 
        decf    TenK,F 
        addwf   Thou,F 
        btfss   STATUS,C 
         bra   Lb4 

        retlw   0

;*********************************************************************


        end















