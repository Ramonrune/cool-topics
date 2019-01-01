;************************************************************************
;*	Microchip Technology Inc. 2002					*
;*	Assembler version: 2.0000					*
;*	Filename: 							*
;*		p16demo.asm (main routine)   				*
;*	Dependents:							*
;*		p16lcd.asm						*
;*		p16math.asm						*
;*		16f877.lkr						*
;*	03/14/02							*
;*	Designed to run at 4MHz						*
;* 	PICDEM 2 PLUS DEMO code. The following functions are included 	*
;*	with this code:							*
;*		1. Voltmeter						*
;*			The center tap of R16 is connected to RA0, the	*
;*			A/D converter converts this analog voltage and	*
;*			the result is displayed on the LCD in a range	*
;*			from 0.00V - 5.00V.				*
;*		2. Buzzer						*
;*			The Piezo buzzer is connected to RC2 and is	*
;*			driven by the CCP1 module. The period and duty	*
;*			cycle are adjustable on the fly through the LCD	*
;*			and push-buttons.				*
;*		3. Temperature						*
;*			A TC74 Serial Digital Thermal Sensor is used to	*
;*			measure ambient temperature. The PIC and TC74	*
;* 			communicate using the MSSP module. The TC74 is	*
;*			connected to the SDA & SCL I/O pins of the PIC	*
;*			and functions as a slave. Every 2 seconds, the	*
;*			temeperature is logged into the external EEPROM	*
;*			in a specific memory location.			*
;*		4. Clock						*
;*			This function is a real-time clock. When the	*
;*			mode is entered, time begins at 00:00:00. The 	*
;*			user can set the time if desired.		*
;************************************************************************



	list p=16F877
	#include p16F877.inc


	__CONFIG _CP_OFF & _WDT_OFF & _HS_OSC & _LVP_OFF & _BODEN_OFF

	#define	scroll_dir	TRISA,4
	#define	scroll		PORTA,4		;Push-button RA4 on PCB
	#define	select_dir	TRISB,0		
	#define	select		PORTB,0		;Push-button RB0 on PCB

	EXTERN	LCDInit, temp_wr, d_write, i_write, LCDLine_1, LCDLine_2
	EXTERN	UMUL0808L, UDIV1608L, AARGB0, AARGB1, BARGB0


variables	UDATA 0x30
ptr_pos		RES 1
ptr_count	RES 1
temp_1		RES 1
temp_2		RES 1
temp_3		RES 1
cmd_byte	RES 1
temperature	RES 1
LSD		RES 1
MsD		RES 1
MSD		RES 1
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

stan_t	CODE	0x100			;start standard table at ROM 0x100	
stan_table				;table for standard code
	addwf	PCL,f
	;	"XXXXXXXXXXXXXXXX"
	;				ptr:
	dt	"   Voltmeter    "	;0
	dt	"     Buzzer     "	;16
	dt	"  Temperature   "	;32
	dt	"     Clock      "	;48
	dt	"RA4=Next RB0=Now"	;64
	dt	"   Microchip    "      ;80
	dt	" PICDEM 2 PLUS  "	;96
	dt	"RA4=Set RB0=Menu"	;112
	dt	"RA4= --> RBO= ++"	;128
	dt	"   RB0 = Exit 	 "	;144
	dt	"Volts =	 "	;160
	dt	"Prd.=128 DC=128 "	;176

start	
	call LCDInit

	banksel	T1CON			;Configure Timer1 for real time clock
	movlw	0x0F			;	start here for timer "warm-up"
	movwf	T1CON

	banksel	TXSTA			;initialize USART		
	movlw	B'10100100'		;Master mode, 8-bit, Async, High speed
	movwf	TXSTA
	movlw	.25			;9.6Kbaud @ 4MHz
	movwf	SPBRG
	banksel	RCSTA
	movlw	B'10010000'
	movwf	RCSTA
	
	banksel	TRISC			;configure CCP1 module for buzzer
	bcf	TRISC,2

	banksel	T2CON			;bank 0
	movlw	0x05			;postscale 1:1, prescaler 4, Timer2 ON
	movwf	T2CON
		
	bsf	TRISA,4			;make switch RA4 an Input
	bsf	TRISB,0			;make switch RB0 an Input

;**************** STANDARD CODE MENU SELECTION *******************
			;Introduction
	banksel	ptr_pos
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
	goto	$-1		
	btfss	select			;wait for RB0 release
	goto	$-1

	banksel	ptr_pos			;Send "Voltmeter" to LCD
	movlw	0x00
	movwf	ptr_pos
	call	stan_char_1

	banksel	ptr_pos			;send "RA4=Next  RB0=Now" to lCD
	movlw	.64
	movwf	ptr_pos
	call	stan_char_2
v_wait
	banksel	PORTA			;bank 0
	btfss	select			;voltmeter measurement ??
	goto	voltmeter
	btfsc	scroll			;next mode ??
	goto	v_wait			;NO
	btfss	scroll			;YES
	goto	$-1			;wait for RA4 release
;------------------ BUZZER --------------------------------------
menu_buz
	btfss	select			;wait for RB0 release
	goto	$-1			

	banksel	ptr_pos			;send "Buzzer" to LCD
	movlw	.16
	movwf	ptr_pos
	call	stan_char_1

	banksel	ptr_pos			;sned "RA4=Next  RB0=Now" to LCD
	movlw	.64
	movwf	ptr_pos
	call	stan_char_2
b_wait
	banksel	PORTA			;bank 0
	btfss	select			;Buzzer sound ??
	goto	buzzer			;YES
	btfsc	scroll			;NO, next mode ??
	goto	b_wait			;NO
	btfss	scroll			;YES
	goto	$-1			;wait for RA4 release
;----------------- TEMPERATURE MEASUREMENT ----------------------
menu_temp	
	btfss	scroll			;wait for RA4 release
	goto	$-1		

	banksel	ptr_pos			;send "Temperature" to LCD
	movlw	.32
	movwf	ptr_pos
	call	stan_char_1

	banksel	ptr_pos			;send "RA4=Next  RB0=Now" to lCD
	movlw	.64
	movwf	ptr_pos
	call	stan_char_2
t_wait
	banksel	PORTA			;bank 0
	btfss	select			;temperature measurement ??
	goto	temp			;YES
	btfsc	scroll			;NO, next mode ??
	goto	t_wait			;NO
	btfss	scroll			;YES
	goto	$-1			;wait for release
;------------------ CLOCK TIME ----------------------------------
menu_clock
	btfss	select			;wait for RB0 release
	goto	$-1		

	banksel	ptr_pos			;send "Clock" to LCD
	movlw	.48
	movwf	ptr_pos
	call	stan_char_1

	banksel	ptr_pos			;send "RA4=Next  RB0=Now" to LCD
	movlw	.64
	movwf	ptr_pos
	call	stan_char_2
c_wait
	banksel	PORTA			;bank 0
	btfss	select			;goto time ??
	goto	clock			;YES
	btfsc	scroll			;NO, next mode ??
	goto	c_wait			;NO
	btfss	scroll			;YES
	goto	$-1			;wait for release
;-------------------------------------------------------------------
	goto	menu			;beginning of menu
	return

;*******************************************************************




;************* STANDARD USER CODE **********************************

;------------- Voltmeter--------------------------------------------
voltmeter
	btfss	select			;wait for RB0 release
	goto	$-1

	movlw	B'00000001'		;configure A/D converter	
	movwf	ADCON0			;turn A/D on
	banksel	ADCON1
	movlw	b'00001110'		;RA0 = analog input
	movwf	ADCON1

	banksel	ptr_pos			;send "Volts = " to the LCD
	movlw	.160
	movwf	ptr_pos
	call	stan_char_1
volts_again
	banksel	ADCON0
	bsf	ADCON0,GO		;start conversion
	btfsc	ADCON0,GO
	goto	$-1
	movf	ADRESH,w

	movwf	AARGB0			;move adresh into AARGB1
	movlw	0xC3			;19.5mV/step   0xC3 = 195
	movwf	BARGB0
	bcf	PCLATH,4		;page 1
	bsf	PCLATH,3
	call	UMUL0808L
	
	movlw	0x64			;divide result by 100 (0x64)
	movwf	BARGB0
	call	UDIV1608L
	clrf	PCLATH
	
	movf	AARGB0,w		;prepare for 16-bit binary to BCD
	movwf	NumH
	movf	AARGB1,w
	movwf	NumL
	call	bin16_bcd		;get volts ready for LCD
	
	call	LCDLine_2		;display A/D result on 2nd line
	movf	Hund,w			;get hunds
	call	bin_bcd
	movf	LSD,w			;send high digit from the LSD #.xx	
	movwf	temp_wr
	call	d_write
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write
	
	movf	Tens,w			;get tens
	call	bin_bcd
	movf	LSD,w			;send low digit   x.#x
	movwf	temp_wr
	call	d_write

	movf	Ones,w			;get ones
	call	bin_bcd
	movf	LSD,w			;send low digit   x.x#
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

	banksel	TXREG			;move data into TXREG 
	movlw	"\r"			;carriage return
	movwf	TXREG
	banksel	TXSTA
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-1
	banksel	PORTA

	btfss	select			;exit volt measurement ??
	goto	menu_buz			;YES
	goto	volts_again		;NO, do conversion again

;--------------------- BUZZER --------------------------------------
buzzer
	btfss	select			;wait for RB0 release
	goto	$-1

	banksel	PR2			;start at these PWM values
	movlw	0x80
	movwf	PR2			;initialize PWM period 
	movlw	0x80			
	banksel	CCPR1L			
	movwf	CCPR1L			;initialize PWM duty cycle
	
	call	LCDLine_1
	banksel	ptr_pos			;send "Prd.=128 DC=128" to LCD
	movlw	.176
	movwf	ptr_pos
	call	stan_char_1
	call	LCDLine_2
	banksel	ptr_pos			;send "RA4= -> RB0 = ++" to LCD
	movlw	.128
	movwf	ptr_pos
	call	stan_char_2
		
	banksel	CCP1CON			;turn buzzer on		
	movlw	0x0F
	movwf	CCP1CON	
		
pr2_again			
	btfsc	select			;increment PR2 ???
	goto	pr2_out			;NO
	call	delay_100ms		;YES
	call	delay_100ms		
	banksel	PR2
	incf	PR2,f			;increment PR2
pr2_out
	banksel	temp_wr
	movlw	0x85			;move cursor into position
	movwf	temp_wr
	call	i_write

	btfss	scroll			;goto increment CCPR1L
	goto	inc_dc
	btfsc	select			;wait for RB0 press
	goto	$-3

	banksel	PR2
	movf	PR2,w			;send PR2 register to conversion
	call	bin_bcd

	banksel	temp_wr	
	movf	MSD,w			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
	movwf	temp_wr
	call	d_write

	goto	pr2_again		

;------------------------
		;adjust Duty Cycle
inc_dc
	btfss	scroll			;wait for button release
	goto	$-1

inc_ccpr1l	
	btfsc	select			;increment CCPR1L ???
	goto	ccpr1l_out		;NO
	call	delay_100ms		;YES
	call	delay_100ms
	banksel	CCPR1L
	incf	CCPR1L,f		;increment CCPR1L
ccpr1l_out
	banksel	temp_wr			
	movlw	0x8C			;move cursor into position
	movwf	temp_wr
	call	i_write

	btfss	scroll			;exit?
	goto	pwm_out
	btfsc	select			;wait for RB0 press
	goto	$-3
	
	banksel	CCPR1L
	movf	CCPR1L,w		;send PR2 register to conversion
	call	bin_bcd
	
	banksel	temp_wr	
	movf	MSD,w			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
	movwf	temp_wr
	call	d_write			
	goto	inc_ccpr1l

pwm_out
	movlw	0
	movwf	CCP1CON			;turn buzzer off
	goto	menu_temp

;---------------------- Temperature -------------------------------- 
temp
;	This code if for the TC74A5-5.0VAT temperature sensor
;		1st. Check if temperature is ready to be read in config reg.
;		2nd. If ready, retireve temperatute in hex.
;		     If not ready, check config register again.

	banksel	TRISC			;initialize MSSP module
	bsf	TRISC,3
	bsf	TRISC,4
	movlw	B'00101000'
	banksel	SSPCON
	movwf	SSPCON
	banksel	SSPSTAT
	bsf	SSPSTAT,SMP
	movlw	.5
	movwf	SSPADD

	banksel	PIR1
	bcf	PIR1,TMR1IF		
	clrf	TMR1H			;load regs for 2 sec overflow
	clrf	TMR1L
get_temp
	banksel	cmd_byte
	movlw	0x01			;config register command byte
	movwf	cmd_byte
temp_now
	banksel	SSPCON2			;write to TC74
	bsf	SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1	
	movlw	B'10011010'		;send TC74 ADDRESS (write)
	banksel	SSPBUF	
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	banksel	cmd_byte
	movf	cmd_byte,w		;send COMMAND byte (config)
	banksel	SSPBUF
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	bsf	SSPCON2,RSEN		;send repeated start
	btfsc	SSPCON2,RSEN
	goto	$-1
	movlw	B'10011011'		;send TC74 ADDRESS (read)
	banksel	SSPBUF
	movwf	SSPBUF
	call	ssprw				;module idle?
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	bsf	SSPCON2,RCEN		;enable receive mode
	btfsc	SSPCON2,RCEN
	goto	$-1

	banksel	SSPBUF			;retrieve config reg or temp reg
	movf	SSPBUF,w
	
	banksel	SSPCON2			;send NOT-ACK
	bsf	SSPCON2,ACKDT
	bsf	SSPCON2,ACKEN
	btfsc	SSPCON2,ACKEN
	goto	$-1
			
	bsf	SSPCON2,PEN		;stop
	btfsc	SSPCON2,PEN
	goto	$-1
	
	banksel	cmd_byte		;config command OR temp command
	btfss	cmd_byte,0
	goto	convert_temp		;get temperature ready for display

	andlw	0x40		
	sublw	0x40
	btfss	STATUS,Z		;is temp ready ??
	goto	get_temp		;NO, try again
	movlw	0x00			;YES, send temp command
	banksel	cmd_byte		;send temp register command
	movwf	cmd_byte
	goto	temp_now

convert_temp
	movwf	temperature
	call	bin_bcd			;NO, get temp ready for LCD
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

	movf	MSD,w			;send high digit
	movwf	temp_wr
	call	d_write
	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
	movwf	temp_wr
	call	d_write
	movlw	A'C'			;send "C" for Celsius
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
	banksel	ptr_pos			
	movlw	.144
	movwf	ptr_pos
	call	stan_char_2
	
	btfss	select			;wait for RB0 release
	goto	$-1
	call	delay_100ms
	btfss	select			;exit ?
	goto	menu_clock		;YES, goto main menu
	btfsc	PIR1, TMR1IF		;2 second overflow occur ??
	call	write_eeprom		;YES
	goto	get_temp		;NO, get temperature again

	
;----------------- CLOCK ------------------------------------------

clock
	btfss	select			;wait for RB0 button release
	goto	$-1
	banksel	T1CON
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

	incf	seconds,f		;increment seconds
	movf	seconds,w
	sublw	.60
	btfss	STATUS,Z		;increment minutes ?
	goto	clk_done
	incf	minutes,f		
	clrf	seconds

	movf	minutes,w
	sublw	.60
	btfss	STATUS,Z		;increment hours ?
	goto	clk_done	
	incf	hours,f			
	clrf	minutes

	movf	hours,w
	sublw	.13
	btfss	STATUS,Z
	goto	clk_done
	movlw	.1			;start a new 12 hour period
	movwf	hours
clk_done
	movf	hours,w			;send hours to LCD
	call	bin_bcd

	call	LCDLine_1		;place time on line 1

	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send  :   colon
	movwf	temp_wr
	call	d_write

	movf	minutes,w		;send minutes to LCD
	call	bin_bcd

	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			; send :   colon
	movwf	temp_wr
	call	d_write

	movf	seconds,w		;send seconds to LCD
	call	bin_bcd

	movf	MsD,w			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send low digit
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
	
	banksel	ptr_pos			;send "RA4=Dn RB0=Menu" to LCD
	movlw	.112
	movwf	ptr_pos
	call	stan_char_2

	banksel	PORTA			
	btfss	scroll			;set time ??
	goto	set_time

	btfss	select			;return to main menu ??
	goto	menu
	
	btfss	PIR1,TMR1IF		;has timer1 overflowed ?	
	goto	$-1			;NO, wait til overflow
	goto	overflow		;YES

	return
;*******************************************************************
							

;************************** ROUTINES ******************************
;******************************************************************
;******************************************************************
		
;----Standard code, Place characters on line-1--------------------------
stan_char_1
	call	LCDLine_1		;mvoe cursor to line 1 
	banksel	ptr_count
	movlw	.16			;1-full line of LCD
	movwf	ptr_count
stan_next_char_1
	movlw	HIGH stan_table
	movwf	PCLATH
	movf	ptr_pos,w		;character table location
	call	stan_table		;retrieve 1 character
	movwf	temp_wr			
	call	d_write			;send character to LCD

	banksel	ptr_pos			;get next character for LCD
	incf	ptr_pos,f
	decfsz	ptr_count,f		;move pointer to next char
	goto	stan_next_char_1

	banksel	TXREG			;move data into TXREG 
	movlw	"\n"			;next line
	movwf	TXREG
	banksel	TXSTA
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-1
	banksel	TXREG			;move data into TXREG 
	movlw	"\r"			;carriage return
	movwf	TXREG
	banksel	TXSTA
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-1	
	banksel	PORTA			;bank 0
	
	return

;----Standard code, Place characters on line-2--------------------------
stan_char_2	
	call	LCDLine_2		;move cursor to line 2 
	banksel	ptr_count
	movlw	.16			;1-full line of LCD
	movwf	ptr_count
stan_next_char_2
	movlw	HIGH stan_table
	movwf	PCLATH
	movf	ptr_pos,w		;character table location
	call	stan_table		;retrieve 1 character
	movwf	temp_wr			
	call	d_write			;send character to LCD

	banksel	ptr_pos			;get next character for lCD
	incf	ptr_pos,f
	decfsz	ptr_count,f		;move pointer to next char
	goto	stan_next_char_2

	banksel	TXREG			;move data into TXREG 
	movlw	"\n"			;next line
	movwf	TXREG
	banksel	TXSTA
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-1
	banksel	TXREG			;move data into TXREG 
	movlw	"\r"			;carriage return
	movwf	TXREG
	banksel	TXSTA
	btfss	TXSTA,TRMT		;wait for data TX
	goto	$-1
	banksel	PORTA			;bank 0	

	return
;----------------------------------------------------------------------


;------------------ 100ms Delay --------------------------------
delay_100ms
	banksel	temp_1
	movlw	0xFF
	movwf	temp_1
	movlw	0x83
	movwf	temp_2

	decfsz	temp_1,f
	goto	$-1
	decfsz	temp_2,f
	goto	$-3
	return

;---------------- 1s Delay -----------------------------------
delay_1s
	banksel	temp_1
	movlw	0xFF
	movwf	temp_1
	movwf	temp_2
	movlw	0x05

	movwf	temp_3
	decfsz	temp_1,f
	goto	$-1
	decfsz	temp_2,f
	goto	$-3
	decfsz	temp_3,f
	goto	$-5
	return	

;---------------- Set Current Time ----------------------------
set_time
	banksel	ptr_pos			;send "RA4= --> RBO= ++" to LCD
	movlw	.128
	movwf	ptr_pos
	call	stan_char_2
set_time_again
	btfss	scroll			;wait for RA4 button release
	goto	$-1

	call	LCDLine_1		;start at 0x00 on LCD

	btfss	select			;wait for RB0 button release
	goto	$-1
	call	delay_100ms			
	btfss  	select			;increment hours (tens) ?
	goto	inc_hours
	goto	next_digit
inc_hours	
	incf	hours
	movf	hours,w			;check if hours has passed 12 ?
	sublw	.13
	btfss	STATUS,Z
	goto	$+2
	clrf	hours			;YES, reset hours to 00
next_digit
	btfss	scroll			;move to next digit
	goto	inc_mins
	movf	hours,w		

	call	bin_bcd			;get hours ready for display
	
	movf	MsD,w			;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send   :   colon
	movwf	temp_wr
	call	d_write

	goto	set_time_again
	
inc_mins
	btfss	scroll			;wait for RA4 button release
	goto	$-1
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
	goto	$-1
	call	delay_100ms
	btfss  	select			;increment minutes (tens) ?
	goto	inc_minutes
	goto	next_digit?
inc_minutes	
	incf	minutes
	movf	minutes,w		;check if hours has passed 12 ?
	sublw	.60
	btfss	STATUS,Z
	goto	$+2
	clrf	minutes
next_digit?
	btfss	scroll			;move to next digit
	goto	set_time_done
	movf	minutes,w
		
	call	bin_bcd			;get minutes ready for display
	
	movf	MsD,w			;send tens digit
	movwf	temp_wr
	call	d_write
	movf	LSD,w			;send ones digit
	movwf	temp_wr
	call	d_write	
	movlw	0x3A			;send  :   colon
	movwf	temp_wr
	call	d_write	
	goto	inc_mins

set_time_done
	btfss	scroll			;wait for RA4 button release
	goto	$-1
	goto	overflow
	
;---------------- Binary (8-bit) to BCD -----------------------
;		255 = highest possible result
bin_bcd
	banksel	MSD
	clrf	MSD
	clrf	MsD
	movwf	LSD		;move value to LSD
ghundreth	
	movlw	.100		;subtract 100 from LSD
	subwf	LSD,w
	btfss	STATUS,C	;is value greater then 100
	goto	gtenth		;NO goto tenths
	movwf	LSD		;YES, move subtraction result into LSD
	incf	MSD,f		;increment hundreths
	goto	ghundreth	
gtenth
	movlw	.10		;take care of tenths
	subwf	LSD,w
	btfss	STATUS,C
	goto	over		;finished conversion
	movwf	LSD
	incf	MsD,f		;increment tenths position
	goto	gtenth
over				;0 - 9, high nibble = 3 for LCD
	movf	MSD,w		;get BCD values ready for LCD display
	xorlw	0x30		;convert to LCD digit
	movwf	MSD
	movf	MsD,w
	xorlw	0x30		;convert to LCD digit
	movwf	MsD
	movf	LSD,w
	xorlw	0x30		;convert to LCD digit
	movwf	LSD
	retlw	0

;---------------- Binary (16-bit) to BCD -----------------------
;		xxx = highest possible result
bin16_bcd			; Takes number in NumH:NumL 
	                       	; Returns decimal in TenK:Thou:Hund:Tens:Ones 
        swapf   NumH,w 
        andlw   0x0F             
        addlw   0xF0             
        movwf   Thou 
        addwf   Thou,f 
        addlw   0xE2 
        movwf   Hund 
        addlw   0x32 
        movwf   Ones 

        movf    NumH,w 
        andlw   0x0F 
        addwf   Hund,f 
        addwf   Hund,f 
        addwf   Ones,f 
        addlw   0xE9 
        movwf   Tens 
        addwf   Tens,f 
        addwf   Tens,f 

        swapf   NumL,w 
        andlw   0x0F 
        addwf   Tens,f 
        addwf   Ones,f 

        rlf     Tens,f 
        rlf     Ones,f 
        comf    Ones,f 
        rlf     Ones,f 

        movf    NumL,w 
        andlw   0x0F 
        addwf   Ones,f 
        rlf     Thou,f 

        movlw   0x07 
        movwf   TenK 

        movlw   0x0A                             ; Ten 
Lb1: 
        addwf   Ones,f 
        decf    Tens,f 
        btfss   3,0 
         goto   Lb1 
Lb2: 
        addwf   Tens,f 
        decf    Hund,f 
        btfss   3,0 
         goto   Lb2 
Lb3: 
        addwf   Hund,f 
        decf    Thou,f 
        btfss   3,0 
         goto   Lb3 
Lb4: 
        addwf   Thou,f 
        decf    TenK,f 
        btfss   3,0 
         goto   Lb4 

        retlw   0

;---------------------------- EEPROM WRITE -------------------------------
write_eeprom	
	banksel	SSPCON2			;write to EEPROM
	bsf	SSPCON2,SEN		;start bit
	btfsc	SSPCON2,SEN
	goto	$-1	
	movlw	B'10100000'		;send control byte (write)
	banksel	SSPBUF	
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	movlw	0x00			;send slave address HIGH byte
	banksel	SSPBUF
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	movlw	0x05			;send slave address LOW byte(0x0005)
	banksel	SSPBUF
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	banksel	temperature
	movf	temperature,w		;send slave DATA = temperature
	movwf	SSPBUF
	call	ssprw
	banksel	SSPCON2
	btfsc	SSPCON2,ACKSTAT		;ack?
	goto	$-1

	bsf	SSPCON2,PEN		;stop bit
	btfsc	SSPCON2,PEN
	goto	$-1
		
	banksel	TMR1L
	bcf	PIR1,TMR1IF		;clear TIMER1 overflow flag
	clrf	TMR1L			;clear registers for next overflow
	clrf	TMR1H

	return
;------------------------ IDLE MODULE -------------------------------------
ssprw					;check for idle SSP module 
	movlw	0x00
	banksel	SSPCON2
	andwf	SSPCON2,w
	sublw	0x00
	btfss	STATUS,Z
	goto	$-4

	btfsc	SSPSTAT,R_W
	goto	$-1
	return

;---------------------------------------------------------------------------
	end	
