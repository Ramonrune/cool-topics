;************************************************************************
;*	Microchip Technology Inc. 2002										*
;*	Assembler version: 2.0000											*
;*	Filename: 															*
;*		p18demo.asm (main routine)   									*
;*	Dependents:															*
;*		p18lcd.asm														*
;*		p18math.asm														*
;*		p2plsp18.lkr													*
;*	March 14,2002														*
;* 	PICDEM 2 PLUS DEMO code. The following functions are included 		*
;*	with this code:														*
;*		1. Voltmeter													*
;*			The center tap of R16 is connected to RA0, the				*
;*			A/D converter converts this analog voltage and				*
;*			the result is displayed on the LCD in a range				*
;*			from 0.00V - 5.00V.											*
;*		2. Buzzer														*
;*			The Piezo buzzer is connected to RC2 and is					*
;*			driven by the CCP1 module. The period and duty				*
;*			cycle are adjustable on the fly through the LCD				*
;*			and push-buttons.											*
;*		3. Temperature													*
;*			A TC74 Serial Digital Thermal Sensor is used to				*
;*			measure ambient temperature. The PIC and TC74				*
;* 			communicate using the MSSP module. The TC74 is				*
;*			connected to the SDA & SCL I/O pins of the PIC				*
;*			and functions as a slave. Every 2 seconds, the				*
;*			temperature is logged into the external EEPROM  			*
;*			in a specific memory location.								*
;*		4. Clock														*
;*			This function is a real-time clock. When the				*
;*			mode is entered, time begins at 00:00:00. The 				*
;*			user can set the time if desired.							*
;*																		*
;*		The data that is sent to the LCD is also sent to the			*
;*		USART through the RS-232 port to be displayed on a PC			*
;*		HyperTerminal.													*
;*																		*
;* Revisions:															*
;*	1/23/04 Removed comments from Config Word Lines						*
;*		Changed the call for the 16/8 divide routine.					*
;************************************************************************

	list p=18f452
	#include p18f452.inc


;Program Configuration Registers
		__CONFIG    _CONFIG1H, _OSCS_OFF_1H & _EC_OSC_1H
		__CONFIG    _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
		__CONFIG    _CONFIG2H, _WDT_OFF_2H
		__CONFIG    _CONFIG3H, _CCP2MX_OFF_3H
		__CONFIG    _CONFIG4L, _STVR_OFF_4L & _LVP_OFF_4L & _DEBUG_OFF_4L
		__CONFIG    _CONFIG5L, _CP0_OFF_5L & _CP1_OFF_5L & _CP2_OFF_5L & _CP3_OFF_5L 
		__CONFIG    _CONFIG5H, _CPB_OFF_5H & _CPD_OFF_5H
		__CONFIG    _CONFIG6L, _WRT0_OFF_6L & _WRT1_OFF_6L & _WRT2_OFF_6L & _WRT3_OFF_6L 
		__CONFIG    _CONFIG6H, _WRTC_OFF_6H & _WRTB_OFF_6H & _WRTD_OFF_6H
		__CONFIG    _CONFIG7L, _EBTR0_OFF_7L & _EBTR1_OFF_7L & _EBTR2_OFF_7L & _EBTR3_OFF_7L
		__CONFIG    _CONFIG7H, _EBTRB_OFF_7H

	#define	scroll_dir	TRISA,4
	#define	scroll		PORTA,4		;Push-button RA4 on PCB
	#define	select_dir	TRISB,0		
	#define	select		PORTB,0		;Push-button RB0 on PCB

	EXTERN	LCDInit, temp_wr, d_write, i_write, LCDLine_1, LCDLine_2
	EXTERN	UMUL0808L, FXD1608U, AARGB0, AARGB1, BARGB0


ssprw	macro				;check for idle SSP module routine
	movlw	0x00
	andwf	SSPCON2,W
	sublw	0x00
	btfss	STATUS,Z
	bra	$-8

	btfsc	SSPSTAT,R_W
	bra	$-2
	endm

variables	UDATA
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

STARTUP CODE
	NOP
	goto	start
	NOP
	NOP
	NOP
PROG1 	CODE

stan_table				;table for standard code
	;	"XXXXXXXXXXXXXXXX"
	;				ptr:
	data	"   Voltmeter    "	;0
	data	"     Buzzer     "	;16
	data	"  Temperature   "	;32
	data	"     Clock      "	;48
	data	"RA4=Next RB0=Now"	;64
	data	"   Microchip    "      ;80
	data	" PICDEM 2 PLUS  "	;96
	data	"RA4=Set RB0=Menu"	;112
	data	"RA4= --> RBO= ++"	;128
	data	"   RB0 = Exit 	 "	;144
	data	"Volts =	 "	;160
	data	"Prd.=128 DC=128 "	;176

start	
	call LCDInit
	
	movlw	B'10100100'		;initialize USART
	movwf	TXSTA			;8-bit, Async, High Speed
	movlw	.25
	movwf	SPBRG			;9.6kbaud @ 4MHz
	movlw	B'10010000'
	movwf	RCSTA

	bcf	TRISC,2			;configure CCP1 module for buzzer
;	bcf	TRISC,6
	movlw	0x80
	movwf	PR2			;initialize PWM period 
	movlw	0x80			;initialize PWM duty cycle
	movwf	CCPR1L
	bcf	CCP1CON,CCP1X
	bcf	CCP1CON,CCP1Y
	
	movlw	0x05			;postscale 1:1, prescaler 4, Timer2 ON
	movwf	T2CON
		
	bsf	TRISA,4			;make switch RA4 an Input
	bsf	TRISB,0			;make switch RB0 an Input


;**************** STANDARD CODE MENU SELECTION *******************
			;Introduction
	movlw	.80			;send "Microchip" to LCD
	movwf	ptr_pos
	call	stan_char_1

	movlw	.96			;send "PICDEM 2 PLUS" to LCD
	movwf	ptr_pos
	call	stan_char_2
	call	delay_1s		;delay for display
	call	delay_1s		;delay for display
menu
;------------------ VOLT MEASUREMENT  ----------------------------
	btfss	scroll			;wait for RA4 release
	goto	$-2		
	btfss	select			;wait for RB0 release
	goto	$-2

	movlw	0x00			;voltmeter
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64				;RA4=Next  RB0=Now
	movwf	ptr_pos
	call	stan_char_2
v_wait
	btfss	select			;voltmeter measurement ??
	bra		voltmeter
	btfsc	scroll			;next mode ??
	bra		v_wait			;NO
	btfss	scroll			;YES
	bra		$-2				;wait for RA4 release
;------------------ BUZZER --------------------------------------
menu_buz
	btfss	select			;wait for RB0 release
	bra	$-2			

	movlw	.16			;buzzer
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64			;RA4=Next  RB0=Now
	movwf	ptr_pos
	call	stan_char_2
b_wait
	btfss	select			;Buzzer sound ??
	goto	buzzer			;YES
	btfsc	scroll			;NO, next mode ??
	goto	b_wait			;NO
	btfss	scroll			;YES
	bra	$-2			;wait for RA4 release
;----------------- TEMPERATURE MEASUREMENT ----------------------
menu_temp
	btfss	scroll			;wait for RA4 release
	bra	$-2		

	movlw	.32			;temperature
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64			;RA4=Next  RB0=Now
	movwf	ptr_pos
	call	stan_char_2
t_wait
	btfss	select			;temperature measurement ??
	bra	temp			;YES
	btfsc	scroll			;NO, next mode ??
	bra	t_wait			;NO
	btfss	scroll			;YES
	bra	$-2			;wait for release
;------------------ CLOCK TIME ----------------------------------
menu_clock
	btfss	select			;wait for RB0 release
	bra	$-2		

	movlw	.48			;clock
	movwf	ptr_pos
	call	stan_char_1

	movlw	.64			;RA4=Next  RB0=Now
	movwf	ptr_pos
	call	stan_char_2
c_wait
	btfss	select			;goto time ??
	bra	clock			;YES
	btfsc	scroll			;NO, next mode ??
	bra	c_wait			;NO
	btfss	scroll			;YES
	bra	$-2			;wait for release
;-------------------------------------------------------------------
	bra	menu			;begining of menu
	return

;*******************************************************************




;************* STANDARD USER CODE **********************************

;------------- Voltmeter--------------------------------------------
voltmeter
	btfss	select			;wait for RB0 release
	bra		$-2

	movlw	B'01000001'		;configure A/D converter	
	movwf	ADCON0			;turn A/D on
	movlw	b'00001110'		;RA0 = analog input
	movwf	ADCON1

	movlw	.160			;send "Volts = " to the LCD
	movwf	ptr_pos
	call	stan_char_1
volts_again
	bsf		ADCON0,GO		;start conversion
again	
	btfsc	ADCON0,GO
	goto	again
	movf	ADRESH,W		;ADRESH --> WREG
	
	movwf	AARGB0			;move ADRESH into AARGB0
	movlw	0xC3			;19.5mV/step   0xC3 = 195
	movwf	BARGB0
	call	UMUL0808L	
	
	movlw	0x64			;divide result by 100 (0x64)
	movwf	BARGB0
	call	FXD1608U
	
	movf	AARGB0,W		;prepare for 16-bit binary to BCD
	movwf	NumH
	movf	AARGB1,W
	movwf	NumL
	call	bin16_bcd		;get volts ready for LCD
	
	call	LCDLine_2		;display A/D result on 2nd line
	movf	Hund,W			;get hunds
	call	bin_bcd
	movf	LSD,W			;send high digit from the LSD #.xx	
	movwf	temp_wr
	call	d_write
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write
	
	movf	Tens,W			;get tens
	call	bin_bcd
	movf	LSD,W			;send low digit   x.#x
	movwf	temp_wr
	call	d_write

	movf	Ones,W			;get ones
	call	bin_bcd
	movf	LSD,W			;send low digit   x.x#
	movwf	temp_wr
	call	d_write
	movlw	A'V'			;send "V" unit
	movwf	temp_wr
	call	d_write

	movlw	0x20			;3 spaces	
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write
	movlw	A'R'			;send "RB0=Exit" to LCD
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
	movlw	0x20			;2 spaces	
	movwf	temp_wr
	call	d_write
	movlw	0x20			
	movwf	temp_wr
	call	d_write

	movlw	"\r"			;move data into TXREG
	movwf	TXREG			;carriage return
	btfss	TXSTA,TRMT		;wait for data TX
	bra		$-2

	btfss	select			;exit volt measurement ??
	bra		menu_buz		;YES
	bra		volts_again		;NO, do conversion again

;--------------------- BUZZER --------------------------------------
buzzer
	btfss	select			;wait for RB0 release
	bra	$-2

	movlw	0x80			;start at these PWM values
	movwf	PR2			;initialize PWM period 
	movlw	0x80			
	movwf	CCPR1L			;initialize PWM duty cycle
	
	call	LCDLine_1
	movlw	.176			;send "Prd.=128 DC=128" to LCD
	movwf	ptr_pos
	call	stan_char_1
	call	LCDLine_2
	movlw	.128			;send "RA4= -> RB0 = ++" to LCD
	movwf	ptr_pos
	call	stan_char_2
		
	movlw	0x0F			;turn buzzer on	
	movwf	CCP1CON	
		
pr2_again			
	btfsc	select			;increment PR2 ???
	bra	pr2_out			;NO
	call	delay_100ms		;YES
	call	delay_100ms		
	incf	PR2,F			;increment PR2
pr2_out
	movlw	0x85			;move cursor into position
	movwf	temp_wr
	call	i_write

pol1
	btfss	scroll			;goto increment CCPR1L
	bra	inc_dc
	btfsc	select			;wait for RB0 press
	bra	pol1

	movf	PR2,W			;send PR2 register to conversion
	call	bin_bcd

	movf	MSD,W			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write

	bra	pr2_again		

;------------------------
		;adjust Duty Cycle
inc_dc
	btfss	scroll			;wait for button release
	bra	$-2

inc_ccpr1l	
	btfsc	select			;increment CCPR1L ???
	goto	ccpr1l_out		;NO
	call	delay_100ms		;YES
	call	delay_100ms
	incf	CCPR1L,F		;increment CCPR1L
ccpr1l_out
	movlw	0x8C			;move cursor into position
	movwf	temp_wr
	call	i_write

col1
	btfss	scroll			;exit?
	bra	pwm_out
	btfsc	select			;wait for RB0 press
	bra	col1
	
	movf	CCPR1L,W		;send PR2 register to conversion
	call	bin_bcd
	
	movf	MSD,W			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write			
	bra	inc_ccpr1l

pwm_out
	movlw	0
	movwf	CCP1CON			;turn buzzer off
	bra	menu_temp

;---------------------- Temperature -------------------------------- 
temp
;	This code if for the TC74A5-5.0VAT temperature sensor
;		1st. Check if temperature is ready to be read in config reg.
;		2nd. If ready, retireve temperatute in hex.
;		     If not ready, check config register again.

	bsf	TRISC,3			;initialize MSSP module
	bsf	TRISC,4
	movlw	B'00101000'
	movwf	SSPCON1
	bsf	SSPSTAT,SMP
	movlw	.5
	movwf	SSPADD

	bcf	PIR1,TMR1IF
	clrf	TMR1H			;load Timer1 for 2 sec overflow
	clrf	TMR1L

get_temp
	movlw	0x01			;config register command byte
	movwf	cmd_byte
temp_now
	bsf	SSPSTAT,6		;SMBUS spec for TC74

	bsf	SSPCON2,SEN		;write to TC74
	btfsc	SSPCON2,SEN
	bra	$-2	
	movlw	B'10011010'		;send TC74 ADDRESS (write)
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	bra	$-2

	movf	cmd_byte,W		;send COMMAND byte (config)
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	bra	$-2

	bsf	SSPCON2,RSEN		;send repeated start
	btfsc	SSPCON2,RSEN
	bra	$-2
	movlw	B'10011011'		;send TC74 ADDRESS (read)
	movwf	SSPBUF
	ssprw				;module idle?
	btfsc	SSPCON2,ACKSTAT		;ack?
	bra	$-2

	bsf	SSPCON2,RCEN		;enable receive mode
	btfsc	SSPCON2,RCEN
	bra	$-2

	movf	SSPBUF,W		;retrieve config reg or temp reg
	
	bsf	SSPCON2,ACKDT		;send NOT-ACK
	bsf	SSPCON2,ACKEN
	btfsc	SSPCON2,ACKEN
	bra	$-2
			
	bsf	SSPCON2,PEN		;stop
	btfsc	SSPCON2,PEN
	bra	$-2
	
	btfss	cmd_byte,0		;config command OR temp command
	bra	convert_temp		;get temperature ready for display

	andlw	0x40			;is temp ready ??
	sublw	0x40
	btfss	STATUS,Z
	bra	get_temp
	movlw	0x00			;temp is ready for reading
	movwf	cmd_byte		;send temp register command
	bra	temp_now

convert_temp
	movwf	temperature
	call	bin_bcd			;get temp ready for LCD
	call	LCDLine_1
	
	movlw	A'T'			;send "Temp=" to LCD
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
	movlw	0x20			;space
	movwf	temp_wr	
	call	d_write
	movlw	A'='
	movwf	temp_wr	
	call	d_write

	movlw	0x20			;space
	movwf	temp_wr	
	call	d_write

	movf	MSD,W			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	movlw	A'C'			;send "C" for celcius
	movwf	temp_wr	
	call	d_write

	movlw	0x20			;space
	movwf	temp_wr	
	call	d_write
	movlw	0x20			;space
	movwf	temp_wr	
	call	d_write
	movlw	0x20			;space
	movwf	temp_wr	
	call	d_write
	
	call	LCDLine_2		;send "RB0 = Exit" to LCD
	movlw	.144
	movwf	ptr_pos
	call	stan_char_2
	
	btfss	select			;wait for RB0 release
	bra	$-2
	call	delay_100ms
	btfss	select			;exit ?
	bra	menu_clock		;YES, goto main menu
	btfsc	PIR1,TMR1IF		;2 second overflow occur ??
	call	write_eeprom		;YES
	bra	get_temp		;NO, get temperature again

	
;----------------- CLOCK ------------------------------------------

clock
	btfss	select			;wait for RB0 button release
	bra	$-2
	movlw	0x0F			;intitialize TIMER1
	movwf	T1CON
	clrf	seconds
	clrf	minutes
	clrf	hours
overflow	
	bcf	PIR1,TMR1IF
	movlw	0x80		
	movwf	TMR1H			;load regs for 1 sec overflow
	clrf	TMR1L

	incf	seconds,F		;increment seconds
	movf	seconds,W
	sublw	.60
	btfss	STATUS,Z		;increment minutes ?
	bra	clk_done
	incf	minutes,F		
	clrf	seconds

	movf	minutes,W
	sublw	.60
	btfss	STATUS,Z		;increment hours ?
	bra	clk_done	
	incf	hours,F			
	clrf	minutes

	movf	hours,W
	sublw	.13
	btfss	STATUS,Z
	bra	clk_done
	movlw	.1			;start a new 12 hour period
	movwf	hours
clk_done
	movf	hours,W			;send hours to LCD
	call	bin_bcd

	call	LCDLine_1		;place time on line 1

	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send  :   colon
	movwf	temp_wr
	call	d_write

	movf	minutes,W		;send minutes to LCD
	call	bin_bcd

	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			; send :   colon
	movwf	temp_wr
	call	d_write

	movf	seconds,W		;send seconds to LCD
	call	bin_bcd

	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write

	movlw	0x20			;send 3 spaces after 00:00:00
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	
	movlw	.112			;send "RA4=Dn RB0=Menu" to LCD
	movwf	ptr_pos
	call	stan_char_2

	btfss	scroll			;set time ??
	bra	set_time

	btfss	select			;return to main menu ??
	bra	menu
	
	btfss	PIR1,TMR1IF		;has timer1 overflowed ?	
	bra	$-2			;NO, wait til overflow
	bra	overflow		;YES

	return
;*******************************************************************


;************************** ROUTINES ******************************
;******************************************************************
;******************************************************************
		
;----Standard code, Place characters on line-1--------------------------
stan_char_1
	call	LCDLine_1		;mvoe cursor to line 1 
	movlw	.16			;1-full line of LCD
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
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra	stan_next_char_1

	movlw	"\n"			;move data into TXREG
	movwf	TXREG			;next line
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-2
	movlw	"\r"			;move data into TXREG
	movwf	TXREG			;carriage return
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-2

	return

;----Standard code, Place characters on line-2--------------------------
stan_char_2	
	call	LCDLine_2		;move cursor to line 2 
	movlw	.16			;1-full line of LCD
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
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra	stan_next_char_2

	movlw	"\n"			;move data into TXREG
	movwf	TXREG			;next line
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-2
	movlw	"\r"			;move data into TXREG
	movwf	TXREG			;carriage return
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-2

	return
;----------------------------------------------------------------------


;------------------ 100ms Delay --------------------------------
delay_100ms
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
	movlw	.128			;send "RA4= --> RBO= ++" to LCD
	movwf	ptr_pos
	call	stan_char_2
set_time_again
	btfss	scroll			;wait for button release
	bra	$-2

	call	LCDLine_1		;start at 0x00 on LCD

	btfss	select			;wait for RB0 button release
	bra	$-2
	call	delay_100ms			
	btfss  	select			;increment hours (tens) ?
	bra	inc_hours
	bra	next_digit
inc_hours	
	incf	hours
	movf	hours,W			;check if hours has passed 12 ?
	sublw	.13
	btfss	STATUS,Z
	bra	next_digit
	clrf	hours			;YES, reset hours to 00
next_digit
	btfss	scroll			;move to next digit
	bra	inc_mins
	movf	hours,W		

	call	bin_bcd			;get hours ready for display
	
	movf	MsD,W			;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send   :   colon
	movwf	temp_wr
	call	d_write

	bra	set_time_again
	
inc_mins
	btfss	scroll			;wait for RA4 button release
	bra	$-2
	call	LCDLine_1
	movlw	0x14			;shift cursor to right 3 places
	movwf	temp_wr
	call	i_write
	movlw	0x14
	movwf	temp_wr
	call	i_write
	movlw	0x14
	movwf	temp_wr
	call	i_write
	
	btfss	select			;wait for RB0 button release
	bra	$-2
	call	delay_100ms
	btfss  	select			;increment minutes (tens) ?
	bra	inc_minutes
	bra	next_digit?
inc_minutes	
	incf	minutes
	movf	minutes,W		;check if hours has passed 12 ?
	sublw	.60
	btfss	STATUS,Z
	bra	next_digit?
	clrf	minutes
next_digit?
	btfss	scroll			;move to next digit
	bra	set_time_done
	movf	minutes,W
		
	call	bin_bcd			;get minutes ready for display
	
	movf	MsD,W			;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send  :   colon
	movwf	temp_wr
	call	d_write	
	bra	inc_mins

set_time_done
	btfss	scroll			;wait for RA4 button release
	bra	$-2
	bra	overflow
	
;---------------- Binary (8-bit) to BCD -----------------------
;		255 = highest possible result
bin_bcd
	clrf	MSD
	clrf	MsD
	movwf	LSD		;move value to LSD
ghundreth	
	movlw	.100		;subtract 100 from LSD
	subwf	LSD,W
	btfss	STATUS,C	;is value greater then 100
	bra	gtenth		;NO goto tenths
	movwf	LSD		;YES, move subtraction result into LSD
	incf	MSD,F		;increment hundreths
	bra	ghundreth	
gtenth
	movlw	.10		;take care of tenths
	subwf	LSD,W
	btfss	STATUS,C
	bra	over		;finished conversion
	movwf	LSD
	incf	MsD,F		;increment tenths position
	bra	gtenth
over				;0 - 9, high nibble = 3 for LCD
	movf	MSD,W		;get BCD values ready for LCD display
	xorlw	0x30		;convert to LCD digit
	movwf	MSD
	movf	MsD,W
	xorlw	0x30		;convert to LCD digit
	movwf	MsD
	movf	LSD,W
	xorlw	0x30		;convert to LCD digit
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

        movlw   0x0A                             ; Ten 
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


;---------------------------- EEPROM WRITE -------------------------------
write_eeprom	
	bsf	SSPCON2,SEN		;start bit
	btfsc	SSPCON2,SEN
	goto	$-2	
	movlw	B'10100000'		;send control byte (write)
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-2

	movlw	0x00			;send slave address HIGH byte
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-2

	movlw	0x05			;send slave address LOW byte(0x0005)
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-2

	movf	temperature,w		;send slave DATA = temperature
	movwf	SSPBUF
	ssprw
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-2

	bsf	SSPCON2,PEN		;stop bit
	btfsc	SSPCON2,PEN
	goto	$-2
		
	bcf	PIR1,TMR1IF		;clear TIMER1 overflow flag
	clrf	TMR1L			;clear registers for next overflow
	clrf	TMR1H

	return

;*********************************************************************
	end	
