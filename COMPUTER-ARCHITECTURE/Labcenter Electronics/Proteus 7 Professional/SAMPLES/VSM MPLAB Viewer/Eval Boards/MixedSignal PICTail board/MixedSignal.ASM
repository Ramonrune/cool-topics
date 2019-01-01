	TITLE "Mixed Signal PICtail Board Firmware"
;***************************************************************************************
;	Author:		Jim Simons
;	Tools:		MPLAB 6.62 using MPLINK
;	Editor:		ComicSans 8pt w/8 character Tabs
;	ProjectFiles:	MixedSignal_v100.asm
;			DAC_dtmf.asm
;			MixedSignal_16f767i.lkr
;			p16f767inc
;
;	Description:	Use the DIP Switches to select the mode of operation.  The PIC then polls for changes in the DIP switches.  
;			If a change is detected for 100mS during 500ms of scanning, a new mode is selected.
;
;		MCP4922 DAC modes	
;	Mode0000:	Flash LEDs and Dial a phone number stored in memory using DTMF created on MCP492X.
;	Mode0001:	Send 000h & FFFh commands to generate a 100Hz R-R output on the MCP4922.
;	Mode0010:	Send 400h & BFFh commands to generate a 100Hz output on the MCP4922.
;	Mode0011:	DACA = SHDN, DACB = SHDN, PIC = SLEEP
;	Mode0100:	DACB & DACA = 800h & Read w/PIC16F767 10b ADC, "broadcast on USART"
;	Mode0101:	DACB = 801h, DACA = 800h & Read w/MCP3302 13b Dif, "broadcast on USART"
;	Mode0110:	DACB & DACA = 800h & Read w/MCP3551, "broadcast on USART"
;	Mode0111:	Open for user to define their own routine.
;		TC132X DAC modes (MUST DEFINE WHICH SPECIFIC DEVICE BELOW)
;	Mode1000:	Flash LEDs and generate a 100Hz 32step sine wave on the TC1321.
;	Mode1001:	Send 000h & FFFh commands to generate a 100Hz R-R output on the TC1321.	
;	Mode1010:	Send 400h & BFFh commands to generate a 100Hz output on the TC1321.
;	Mode1011:	DAC = SHDN, PIC = SLEEP
;	Mode1100:	DAC = 200h & Read w/PIC16F767 10b ADC, "broadcast on USART"
;	Mode1101:	DAC = 200h & Read w/MCP3302 13b single-ended, "broadcast on USART"
;	Mode1110:	Open for user to define their own routine.
;	Mode1111:	Open for user to define their own routine.
;	
;***************************************************************************************
	LIST P=16F877, F=INHX32
	#INCLUDE "p16F877A.inc"
;***************************************************************************************
;Program Configuration Register 1
;	__CONFIG    _CONFIG1,  _CP_OFF & _CCP2_RC1 & _DEBUG_OFF & _VBOR_2_0 & _BOREN_1 & _MCLR_OFF & _PWRTE_OFF & _WDT_OFF & _INTRC_IO

;Program Configuration Register 2
;	__CONFIG    _CONFIG2,  _BORSEN_1 & _IESO_OFF & _FCMEN_OFF

	ERRORLEVEL -302

#define	BetaMCP3551		0	; beta MCP3551 28p has SCK & CS swapped - SW_SPI ONLY!
#define	SW_SPI		0	; compile time variable to bit-bang SPI
#define	HW_SPI		1	; compile time variable to use HW SPI Peripheral
#define	SW_I2C		0	; compile time variable to bit bang I2C interface
#define	HW_I2C		1	; compile time variable to bit bang I2C Peripheral
  if  HW_SPI & BetaMCP3551
	error	"BetaMCP3551 requires you to use SW_SPI"
  endif

; MUST DEFINE WHICH PART IS ON YOUR BOARD TO SEND CORRECT # OF BYTES IN COMMAND
#define	TC1320		1	; set if TC1320 (8b DAC) is on your board
#define	TC1321			0	; set if TC1321 (10b DAC) or TC1322 (12b DAC) is  on your board

;***************************************************************************************
; General Pupose Register Definitions
;***************************************************************************************
	UDATA
w_temp			res		1	; variable used for context saving 
status_temp		res		1	; variable used for context saving
LastMode		res		1
Mode			res		1	; Mode variable
DAC_MSB		res		1
DAC_LSB		res		1
DAC_Addr		res		1
DAC_Command		res		1
BitCount		res		1
ByteCount		res		1
ScanCount		res		1
ScanMatch		res		1
EchoCount		res		1
DLYCNT1		res		1
DLYCNT2		res		1
ADC_Byte2		res		1	; MCP3551 ADC Most Significant Byte
ADC_Byte1		res		1	; MCP3302, MCP3204, & PIC16F767 ADC MSB
ADC_Byte0		res		1	; ADC Least Significant Byte
RxData			res		1	; data received
TxData			res		1	; data to transmit
Temp			res		1	; General Purpose Temp Register
NoteCount		res		1	; Counts what digit of the phone number needs to be dialed.
StepCount		res		1	; counter to determine 32b sine wave step
SineOut		res		1	; ouput register for the sine wave generator

	#define	LDAC		PORTA,5		; LDAC for MCP492x
	#define	CS0		PORTC,0		; CS0 for MCP3302 & 3551
	#define	CS1		PORTC,1		; CS1 for MCP492X
	#define	SHDN		PORTC,2		; !SHDN for MCP492X
	#define	SCK		PORTC,3		; SPI Serial Clock
	#define	SDI		PORTC,4		; SPI Serial Data In
	#define	SDO		PORTC,5		; SPI Serial Data Out
	#define	SCL		INDF,3			; I2C Serial Clock (requires TRISC addr in FSR)
	#define	SDA		INDF,4			; I2C Serial Data (requires TRISC addr in FSR)
	#define	LED0_TX	PORTC,6		; RED LED & USART TX
	#define	LED1_RX	PORTC,7		; Green LED & USART RX
	#define	SPI_PORT	PORTC

	#define	SW1		PORTB,0		;Dip Switch 1 input - note, needs int pull-up
	#define	SW2		PORTB,1		;Dip Switch 2 input - note, needs int pull-up
	#define	SW3		PORTB,2		;Dip Switch 3 input - note, needs int pull-up
	#define	SW4		PORTB,3		;Dip Switch 4 input - note, needs int pull-up

;***************************************************************************************
RESET			CODE		; processor reset vector
ResetVector
	nop
	movlw		high  Start	; load upper byte of 'start' label
	movwf		PCLATH	; initialize PCLATH
	goto		Start		; go to beginning of program

;***************************************************************************************
INTERRUPT		 CODE		; interrupt vector location
InterruptVector
ISR_Push
	movwf		w_temp		; save off current W register contents
	movf		STATUS,w	; move status register into W register
	movwf		status_temp	; save off contents of STATUS register
	clrf		STATUS	; initialize the bank bits

; isr code can go here or be located as a call subroutine elsewhere
ISR_Pop
	movf		status_temp,w	; retrieve copy of STATUS register
	movwf		STATUS	; restore pre-isr STATUS register contents
	swapf		w_temp,f
	swapf		w_temp,w	; restore pre-isr W register contents
	retfie				; return from interrupt

;***************************************************************************************
MAIN		CODE
Start
	clrf		PCLATH
Init_Oscillator
	bsf		STATUS,RP0
 
;	movlw		.8			; Specific tuning adjustment for Board #1
;	addwf		OSCTUNE,f		; try to bump up the frequency by 2% for my particular device

;	movlw		b'01111010'		; Use internal 8Mhz oscillator as the primary
;	movwf		OSCCON
	movlw		b'01000001'		; PSA = TMR0 4:1, WDT 1:1, RB0 INT on Rising
	movwf		OPTION_REG		; PORTB Pullups enabled   -  Note, Too strong for 10k pull downs
	bcf		STATUS,RP0

Init_ADC			; change default Analog inputs to Digital
	bsf		STATUS,RP0
	iorlw		b'01001001'		; Fosc/16, AN1, ADON
	movwf		ADCON0		; 
	bsf		STATUS,RP0
	movlw		b'01001010'		; Left Justified, clock/2, Vref-=Vss, Vref+=Vdd, AN0-AN4 enabled
	movwf		ADCON1
;	movlw		b'00011000'		; 6Tad acquisition time
;	movwf		ADCON2
;	movlw		b'00000111'
;	movwf		CMCON		; make sure comparators disabled w/digital inputs
;	clrf		CVRCON
	bcf		STATUS,RP0
Init_SSP
	clrf		SSPCON		; Turn off SSP
Init_PORTS
	clrf		INTCON		; ensure all interrupts are disabled
	movlw		b'11100000'		; make RA0-RA3 output low - no current
	movwf		PORTA			; set LDAC pin
	movlw		b'00000000'
	movwf		PORTB 
	movlw		b'00001111'
	movwf		PORTC			; Turn off LEDs, SCK = 1 & SDO = 0, !SHDN = 1, !CS0 & !CS1 = 1
	bsf		PORTE,3

	bsf		STATUS,RP0		; need to set bank 1
	movlw		b'00001111' 		; Set PORTA <7:4> to outputs, <3:0> to inputs
	movwf		TRISA
	movlw		b'00000000'		; outputs including DIP switches
	movwf		TRISB
	movlw		b'11010000'
	movwf		TRISC			; make TX & RX & SDI inputs
	movlw		b'11110111'		; RE3 is MCLR
	movwf		TRISE
	bcf		STATUS,RP0		; need to set bank 0 

	movlw		.17			; not a valid MODE... forces first TX
	movwf		LastMode

;***************************************************************************************
;	Main Loop
;***************************************************************************************
ModeSelect
	movlw		HIGH InitScanCount
	movwf		PCLATH
InitScanCount
	movlw		TRISB
	movwf		FSR
	movlw		b'00001111'
	iorwf		INDF,f			; change TRISB to make Switches input
	movlw		.100
	movwf		ScanCount		; initialize ScanCount for a 5ms * 100 = 500ms window
	movlw		.20
	movwf		ScanMatch		; initialize consecutive ScanMatch for a 5ms * 20 = 100ms period
ScanSwitches
	movlw		b'00001111'
	andwf		PORTB,w		; mask the switch inputs and put result in Mode
	xorwf		LastMode,w
	btfsc		STATUS,Z
	goto		ScanDelay		; same as last mode
	movlw		b'00001111'		; switches changed
	andwf		PORTB,w
	xorwf		Mode,w
	btfsc		STATUS,Z		; is it the same as last scan?
	goto		ScanDelay

	movlw		.20			; no, reinitialize consecutive ScanMatch counter
	movwf		ScanMatch

	movlw		b'00001111'
	andwf		PORTB,	w		; reload Mode w/New Scan & KeepScanning
	movwf		Mode
ScanDelay
	movlw		.10
	call		VAR1000TcyDELAY	; generate a 5ms delay
	decf		ScanMatch,f
	btfsc		STATUS,Z		; Have we had 20 consecutive matches?
	goto		ConsecutiveMatch
	decfsz		ScanCount,f
	goto		ScanSwitches
	movf		LastMode,w
	movwf		Mode			; keep the same mode & keep going...
ConsecutiveMatch
	movf		Mode,w
	xorwf		LastMode,w
	btfsc		STATUS,Z		; Did the Mode change?
	goto		NoFlash		; no
	movlw		HIGH FlashLEDs
	movwf		PCLATH
	call		FlashLEDs		; Flash LEDs for 2s
NoFlash
	movlw		HIGH ModeJumpTable
	movwf		PCLATH
	movf		Mode,w
	movwf		LastMode		; save off the new Mode 
	call		ModeJumpTable
	goto		ModeSelect

;***************************************************************************************
ModeJumpTable
	addwf		PCL,f
	goto		Mode0000
	goto		Mode0001
	goto		Mode0010
	goto		Mode0011
	goto		Mode0100
	goto		Mode0101
	goto		Mode0110
	goto		Mode0111
	goto		Mode1000
	goto		Mode1001
	goto		Mode1010
	goto		Mode1011
	goto		Mode1100
	goto		Mode1101
	goto		Mode1110
	goto		Mode1111

;***************************************************************************************
;	Mode0000
;	Dial a phone number stored in PhoneNumberTable.
;	Returns to scan keys at the end of the Table
MODE0000		CODE
;***************************************************************************************
;	This Mode uses a DTMF SUBROUTINE.  The DTMF SUBROUTINE uses a 
;	Rolling Loop Timer technique to produce the 2 frequencies.  These 
;	frequencies are summed and output an 8-bit result on a low-cost DAC.
;	(R2R ladder, log ladder, PWM or HW DAC).
;
;	Program memory	~150 words total for 16 step tone subroutine
;	Program memory	~175 words for 32 step tone subroutine
;		NOTE: Can only use the 32 step code if R2R or PWM & 8Mhz or more
;	Data memory 		~13 registers total
;
;	DTMF_SUB source code is in "DAC_dtmf.asm" & must be part of the project
;	use MPASM & MPLINK to compile and "MixedSignal_16F767i.lkr" to link
 EXTERN	F_Low, F_Low_Rolling,F_Low_Step, F_Low_Out, F_High, F_High_Rolling
 EXTERN	F_High_Step, F_High_Out, DTMF_Out, ToneLength, Key_Value
 EXTERN	Tone, Repeat_tone
 GLOBAL	DAC_MSB, DAC_LSB, WriteToMCP492X
;***************************************************************************************
Mode0000
  if   !HW_SPI
	retlw		b'11111111'		; DTMF code using MCP492X requires HW_SPI to be fast enough
  endif
	bsf		STATUS,RP0
	movlw		b'01001000'		; PSA = TMR0 1:1, WDT 1:1, RB0 INT on Rising
	movwf		OPTION_REG		; PORTB Pullups enabled   -  Note, Too strong for 10k pull downs
	bcf		STATUS,RP0

 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	movlw		b'11111000'		;DAC B, Vref Buffered, 1x Gain, 0x87Fh
	movwf		DAC_MSB
	movlw		7Fh
	movwf		DAC_LSB
StartPhoneNumber
	clrf		NoteCount		;reset the digit count
NextKey
	movlw		HIGH PhoneNumberTable
	movwf		PCLATH
	movf		NoteCount,W
	call		PhoneNumberTable	; fetch the # to be dialed
	movwf		Key_Value		; store in Key_Value
	incfsz		Key_Value,W		; testing value for 0FFh determines
	goto		ContinueTone		; if the phone number has completed
PhoneNumberDone
 	movlw		.17
  	movwf		Mode			; forces a re-flash of LEDs after key scan
	retlw		b'00000000'

ContinueTone
	call		Tone			; Produce the DTMF tone for ToneLength_#ms
	call		Repeat_tone		; use this to generate a longer tone
	call		Repeat_tone		; use this to generate a longer tone
	call		Repeat_tone		; use this to generate a longer tone
;	call		Repeat_tone		; use this to generate a longer tone
;	goto		$-1			; use this to generate a fixed tone output

  	movlw		.200
  	call		VAR1000TcyDELAY		;wait 100ms before next tone
	incf		NoteCount,F
	goto		NextKey

PhoneNumberTable		;This test code uses 0FFh for End of #.
	addwf		PCL,F
 DT	1h, 4h, 8h, 0h, 7h, 9h, 2h, 7h, 5h, 2h, 7h, 0FFh
; DT	0h, 1h, 2h, 3h, 4h, 5h, 6h, 7h, 8h, 9h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,0FFh

;	NOTE:  The table size can be reduced by using a packed # similar
;		to packed BCD.  Obviously 0FFh cannot be used to determine
;		End of #.

;***************************************************************************************
;	Mode0001  &   Mode0010
;	Send a 1Khz square wave out using the DAC
;	Returns to scan keys after sending 0Fh
;***************************************************************************************
MODE0001		CODE
	#define	DACA_MSB_FFFh	b'01111111'	;DAC A, Vref Buffered, 1x Gain, 0xFFFh
	#define	DACA_MSB_000h	b'01110000'	;DAC A, Vref Buffered, 1x Gain, 0x000h
	#define	DACB_MSB_FFFh	b'11111111'	;DAC B, Vref Buffered, 1x Gain, 0xFFFh
	#define	DACB_MSB_000h	b'11110000'	;DAC B, Vref Buffered, 1x Gain, 0x000h

	#define	DACA_MSB_BFFh	b'01111100'	;DAC A, Vref Buffered, 1x Gain, 0xBFFh
	#define	DACA_MSB_400h	b'0110100'	;DAC A, Vref Buffered, 1x Gain, 0x400h
	#define	DACB_MSB_BFFh	b'11111100'	;DAC B, Vref Buffered, 1x Gain, 0xBFFh
	#define	DACB_MSB_400h	b'11110100'	;DAC B, Vref Buffered, 1x Gain, 0x400h

	#define	DAC_LSB_FFh		b'11111111'	;DAC LSB for FFh
	#define	DAC_LSB_00h		b'00000000'	;DAC LSB for 00h

Mode0001
Mode0010
 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	decf		Mode,f			; Mode1 LSB = 0, Mode2 LSB = 1
Freq1KhzOut
	movlw		.250
	movwf		ScanCount
DACA_High					; load DACA w/G=1, BufferEnabled, FFFh
	movlw		DACA_MSB_FFFh	;Mode0000
	btfsc		Mode,0			; test if Mode0000 or Mode0001
	movlw		DACA_MSB_BFFh	;Mode0001
	movwf		DAC_MSB
	movlw		DAC_LSB_FFh
	movwf		DAC_LSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
						; Need 5000 tcy = 2.5ms.  Add 4728 Tcy delay
	movlw		.4
	call		VAR1000TcyDELAY	; 4004 Tcy
 if	HW_SPI
	movlw		.191			; 191 * 5 + 5 = 960 Tcy
 else
	movlw		.142			; 142 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY
DACB_High					; load DACB w/G=1, BufferEnabled, FFFh
	movlw		DACB_MSB_FFFh	;Mode0000
	btfsc		Mode,0			; test if Mode0000 or Mode0001
	movlw		DACB_MSB_BFFh	;Mode0001
	movwf		DAC_MSB
	movlw		DAC_LSB_FFh
	movwf		DAC_LSB
	call		WriteToMCP492X	; takes 272 Tcy
						; Need 5000 tcy = 2.5ms.  Add ~4716 Tcy delay
	movlw		.4
	call		VAR1000TcyDELAY	; 4004 Tcy
 if	HW_SPI
	movlw		.191			; 191 * 5 + 5 = 960 Tcy
 else
	movlw		.142			; 142 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY
DACA_Low					; load DACA w/G=1, BufferEnabled, 000h
	movlw		DACA_MSB_000h	;Mode0000
	btfsc		Mode,0			; test if Mode0000 or Mode0001
	movlw		DACA_MSB_400h	;Mode0001
	movwf		DAC_MSB
	movlw		DAC_LSB_00h
	movwf		DAC_LSB
	call		WriteToMCP492X	; takes 272 Tcy
						; Need 5000 tcy = 2.5ms.  Add ~4716 Tcy delay
	movlw		.4
	call		VAR1000TcyDELAY	; 4004 Tcy
 if	HW_SPI
	movlw		.191			; 191 * 5 + 5 = 960 Tcy
 else
	movlw		.142			; 142 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY
	nop
DACB_Low					; load DACB w/G=1, BufferEnabled, 000h
	movlw		DACB_MSB_000h	;Mode0000
	btfsc		Mode,0			; test if Mode0000 or Mode0001
	movlw		DACB_MSB_400h	;Mode0001
	movwf		DAC_MSB
	movlw		DAC_LSB_00h
	movwf		DAC_LSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
						; Need 5000 tcy = 2.5ms.  Add ~4716 Tcy delay
	movlw		.4
	call		VAR1000TcyDELAY	; 4004 Tcy
 if	HW_SPI
	movlw		.191			; 191 * 5 + 5 = 960 Tcy
 else
	movlw		.142			; 142 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY

	decfsz		ScanCount,f		; scan the inputs every 2.5s
	goto		DACA_High
	incf		Mode,w			; increment Mode back up from 0 & 1 to 1 & 2 respectively
	incf		Mode,f
	return

;***************************************************************************************
;	Mode0011:	DACA = SHDN, DACB = SHDN, PIC = SLEEP
;***************************************************************************************
Mode0011
 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	clrf		DAC_LSB
	movlw		b'10100000'		;DAC B, !Buf, 1x, SHDN, 0x000h
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	bcf		DAC_MSB,7		;DAC A, !Buf, 1x, SHDN, 0x000h
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	nop
	sleep		; Once asleep... only MCLR (internal) or Vdd BOR will wake up.
	nop
	retlw		b'00000011'	; shouldn't get here

;***************************************************************************************
;	Mode0100:	DACB & DACA = 800h & Read w/PIC16F767 10b ADC, "broadcast on USART"
;	Mode0101:	DACB = 801h, DACA = 800h & Read w/MCP3302 13b Dif, "broadcast on USART"
;	Mode0110:	DACB & DACA = 800h & Read w/MCP3551, "broadcast on USART"
;***************************************************************************************
	#define	DACA_MSB_800h	b'01110000'	; DAC A, SHDN
	#define	DACB_MSB_800h	b'11111000'	; DAC B, Vref Buffered, 1x Gain, 0x800h
Mode0100
 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	clrf		DAC_LSB
	movlw		DACB_MSB_800h	; DAC B, Vref Buffered, 1x Gain, 0x800h
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	movlw		DACA_MSB_800h	; DACA, SHDN
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	movlw		.1			; Measure AN1 = VoutB
	call		ReadPIC10bADC	; 
	call		SendADC_Data	; Use the USART to send the ADC result
	retlw		b'00000100'

Mode0101
 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	clrf		DAC_LSB
	movlw		DACB_MSB_800h	; DAC B, Vref Buffered, 1x Gain, 0x800h
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	movlw		DACA_MSB_800h	; DACA, SHDN
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	movlw		b'00010001'		; Command needs RRF, start bit, diff mode, ch1-ch0 = VoutB-VoutA
	call		ReadMCP3302
	call		SendADC_Data	; Use the USART to send the ADC result
	retlw		b'00000101'

Mode0110
 if HW_SPI
	call		Init_SPI
 else
	clrf		SSPCON		; Turn off SSP
 endif
	clrf		DAC_LSB
	movlw		DACA_MSB_800h	; DACA, SHDN
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	clrf		DAC_LSB
	movlw		DACB_MSB_800h	; DAC B, Vref Buffered, 1x Gain, 0x800h
	movwf		DAC_MSB
	call		WriteToMCP492X	; takes 272 Tcy or 32 Tcy
	call		ReadMCP3551
	call		SendADC_Data	; Use the USART to send the ADC result
	retlw		b'00000110'

;***************************************************************************************
;	Mode0111:	Open for user to define their own routine.
;***************************************************************************************
Mode0111

	retlw		b'00000111'

;***************************************************************************************
;	Mode1000:	Flash LEDs and generate a 100Hz 32step sine wave on the TC1321.
MODE1000		CODE
;***************************************************************************************
Mode1000
	bsf		STATUS,RP0
	movlw		b'01000001'		; PSA = TMR0 4:1, WDT 1:1, RB0 INT on Rising
	movwf		OPTION_REG		; PORTB Pullups enabled   -  Note, Too strong for 10k pull downs
	bcf		STATUS,RP0
 	call		Init_I2C
	movlw		HIGH SINE_Table_32step_8bit
	movwf		PCLATH
	movlw		(0x100 - .156)		; ((1/100hz)/(32*4*Tcy) = 156.  Note TMR0 4:1 prescaler selected
	movwf		TMR0
	clrf		DAC_LSB		; not using least significant 2 bits
	clrf		DAC_Command
	movlw		.32
	movwf		StepCount
	movlw		.50
	movwf		ToneLength		; 500ms/(1/100Hz) = 50 100Hz cycles
SineLoop
	btfss		INTCON,TMR0IF
	goto		$-1
	bcf		INTCON,TMR0IF
	movlw		(0x100 - .156)
	addwf		TMR0,f
	movf		StepCount,W
	call		SINE_Table_32step_8bit
	movwf		DAC_MSB
	call		WriteToTC132X
	decfsz		StepCount,f
	goto		SineLoop
	movlw		.32
	movwf		StepCount
	decfsz		ToneLength,f
	goto		SineLoop		;ToneLength time expired, Exit subroutine
	retlw		b'00001000'

;***************************************************************************************
;	32 step lookup table of an 8 bit SINE wave
;		Y = 8 bit result
;		X = step #
;	Y = 127 + 128 * Sin (X * 360 / 32)
;
SINE_Table_32step_8bit
	addwf	PCL,F
	nop		;this location is never used since W != 0
 DT	.127,  .152,  .176,  .198,  .218, .233, .245, .253
 DT	.255, .253, .245, .233, .218,  .198,  .176, .152
 DT	.127,  .102,  .78,  .56,  .36,  .21,  .9,   .1
 DT	.0,   .1,   .9,   .21,  .36,  .56,  .78,  .102

;***************************************************************************************
;	Mode1001:	Send 000h & FFFh commands to generate a 100Hz R-R output on the TC1321.	
;	Mode1010:	Send 400h & BFFh commands to generate a 100Hz output on the TC1321.
;***************************************************************************************
Mode1001
Mode1010
	#define	DAC_MSB_3FFh	b'11111111'	;DAC 0x3FFh
	#define	DAC_MSB_000h	b'00000000'	;DAC 0x000h

	#define	DAC_MSB_2FFh	b'10111111'	;DAC 0x2FFh
	#define	DAC_MSB_100h	b'01000000'	;DAC 0x100h

	call		Init_I2C
	decf		Mode,f			; Mode1 LSB = 0, Mode2 LSB = 1
Freq100hzOut
	movlw		.250
	movwf		ScanCount
DAC_High
	clrf		DAC_Command
	movlw		DAC_MSB_3FFh	;Mode1001
	btfsc		Mode,0			; test if Mode1001 or Mode1010
	movlw		DAC_MSB_2FFh	;Mode1010
	movwf		DAC_MSB
	movlw		b'11000000'
	movwf		DAC_LSB
	call		WriteToTC132X	; takes 186 Tcy or 428 Tcy
						; Need 5000 tcy = 2.5ms.
	movlw		.9
	call		VAR1000TcyDELAY	; 9004 Tcy = 4.5ms
 if	HW_I2C
	movlw		.161			; 161 * 5 + 5 = 810 Tcy
 else
	movlw		.112			; 112 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY
DAC_Low
	clrf		DAC_Command
	movlw		DAC_MSB_000h	;Mode1001
	btfsc		Mode,0			; test if Mode1001 or Mode1010
	movlw		DAC_MSB_100h	;Mode1010
	movwf		DAC_MSB
	clrf		DAC_LSB
	call		WriteToTC132X	; takes 186 Tcy or 428 Tcy
						; Need 5000 tcy = 2.5ms.
	movlw		.9
	call		VAR1000TcyDELAY	; 9004Tcy = 4.5ms
 if	HW_I2C
	movlw		.161			; 161 * 5 + 5 = 810 Tcy
 else
	movlw		.112			; 112 * 5 + 5 = 715 Tcy
 endif
	call		VAR5TcyDELAY
	decfsz		ScanCount,f		; scan the inputs every 2.5s
	goto		DAC_High
	incf		Mode,w			; increment Mode back up from 0 & 1 to 1 & 2 respectively
	incf		Mode,f
	return

;***************************************************************************************
;	Mode1011:	DAC = SHDN, PIC = SLEEP
;***************************************************************************************
Mode1011
	call		Init_I2C
	clrf		DAC_LSB
	clrf		DAC_MSB
	movlw		b'00000001'		; DAC SHDN
	movwf		DAC_Command
	call		WriteToTC132X	; takes 186 Tcy or 428 Tcy
	nop
	sleep		; Once asleep... only MCLR (internal) or Vdd BOR will wake up.
	nop
	retlw		b'00001011'	; shouldn't get here

;***************************************************************************************
;	Mode1100:	DAC = 200h & Read w/PIC16F767 10b ADC, "broadcast on USART"
;	Mode1101:	DAC = 200h & Read w/MCP3302 13b single-ended, "broadcast on USART"
;	Mode1110:	Open for user to define their own routine. (Cannot Read VoutC w/MCP3551)
;***************************************************************************************
	#define	DAC_MSB_200h	b'10000000'
Mode1100
	call		Init_I2C
	clrf		DAC_Command
	clrf		DAC_LSB
	movlw		DAC_MSB_200h	; DAC = 200h, SHDN
	movwf		DAC_MSB
	call		WriteToTC132X	; takes 272 Tcy or 32 Tcy
	movlw		.199
	call		VAR5TcyDELAY	; Generate a 500uS some settling time
	movlw		.2			; Measure AN2 = VoutC
	call		ReadPIC10bADC	; 
	call		SendADC_Data	; Use the USART to send the ADC result
	retlw		b'00001100'

Mode1101
	call		Init_I2C
	clrf		DAC_Command
	clrf		DAC_LSB
	movlw		DAC_MSB_200h	; DAC = 200h, SHDN
	movwf		DAC_MSB
	call		WriteToTC132X	; takes 272 Tcy or 32 Tcy
	movlw		.199
	call		VAR5TcyDELAY	; Generate a 500uS some settling time
	movlw		b'00011010'		; Command needs RRF, start bit, single-ended, ch2 = VoutC
	call		ReadMCP3302
	call		SendADC_Data	; Use the USART to send the ADC result
	retlw		b'00001101'

;***************************************************************************************
;	Mode1110:	Open for user to define their own routine.
;***************************************************************************************
Mode1110

	retlw		b'00001110'

;***************************************************************************************
;	Mode1111:	Open for user to define their own routine.
;***************************************************************************************
Mode1111

	retlw		b'00000111'

;***************************************************************************************
SUBROUTINES	CODE
;***************************************************************************************
;	Write to MCP492X subroutines
 if	HW_SPI
WriteToMCP492X				; This entire subroutine takes 15uS from CS low to LDAC high
	bcf		CS1			; drop Chip Select
; SCK idles high
; Data output after falling edge of SCK
; Data sampled before rising edge of SCK
	movf		DAC_MSB,w
	movwf		SSPBUF
	movf		DAC_LSB,w
	btfss		PIR1,SSPIF		; wait to finish TX of MSB
	goto		$-1
	bcf		PIR1,SSPIF
	movwf		SSPBUF
	btfss		PIR1,SSPIF		; wait to finish TX of LSB
	goto		$-1
	bsf		CS1			; raise Chip Select
	bcf		PIR1,SSPIF
	bcf		LDAC			; toggle LDAC
	bsf		LDAC
	return
 endif

;***************************************************************************************
 if	SW_SPI
WriteToMCP492X
	bcf		SCK
	movlw		.16
	movwf		BitCount
	bcf		CS1			; drop Chip Select
; SCK idles low
; Data output after falling edge of SCK
; Data sampled before rising edge of SCK
SPI_Loop
	rlf		DAC_LSB,f		; 16bit rotate left
	rlf		DAC_MSB,f
	btfss		STATUS,C		; output state of C on SDO
	bcf		SDO
	btfsc		STATUS,C
	bsf		SDO
	bsf		SCK			; toggle SCK
	bcf		SCK
	decfsz		BitCount,f		; Loop 16 times
	goto		SPI_Loop
	bsf		CS1			; raise Chip Select
	bcf		LDAC			; toggle LDAC
	bsf		LDAC
	return
 endif

;***************************************************************************************
;	Write to TC132X subroutines
 if	HW_I2C
WriteToTC132X				; takes about 186Tcy = 93us
	movlw		SSPCON2
	movwf		FSR			; allows quick & easy access to Start & Stop commands
	bcf		PIR1,SSPIF
	bsf		INDF,SEN		; generate the START condition
;	btfss		PIR1,SSPIF
;	goto		$-1
	call		QuickDelay

	movlw		b'10010000'		; load the SMBus address for a Write to the TC132X
	movwf		SSPBUF		; send the address byte
	movlw		.10
	call		VAR5TcyDELAY
;	bcf		PIR1,SSPIF
;	btfss		PIR1,SSPIF
;	goto		$-1
	btfsc		INDF,ACKSTAT
	goto		FailedACK		; no ACK, try again

	movf		DAC_Command,w
	movwf		SSPBUF		; send the command byte 
	movlw		.10
	call		VAR5TcyDELAY
;	btfss		PIR1,SSPIF
;	goto		$-1
	btfsc		INDF,ACKSTAT
	goto		FailedACK		; no ACK, try again

	movf		DAC_MSB,w
  if TC1321
	movwf		SSPBUF		; send the most significant databyte
	movlw		.10
	call		VAR5TcyDELAY
;	bcf		PIR1,SSPIF
;	btfss		PIR1,SSPIF
;	goto		$-1
	btfsc		INDF,ACKSTAT
	goto		FailedACK		; no ACK, try again

	movf		DAC_LSB,w
  endif
	movwf		SSPBUF		; send the least significant databyte
	movlw		.10
	call		VAR5TcyDELAY
;	bcf		PIR1,SSPIF
;	btfss		PIR1,SSPIF
;	goto		$-1
	btfsc		INDF,ACKSTAT
	goto		FailedACK		; no ACK, try again

;	bcf		PIR1,SSPIF
	bsf		INDF,PEN		; generate the STOP condition
;	btfss		PIR1,SSPIF
;	goto		$-1
	call		QuickDelay
	return

QuickDelay
	goto		$+1
	return

FailedACK
	call		Init_I2C
	goto		WriteToTC132X	; try again

 endif

;***************************************************************************************
 if	SW_I2C
WriteToTC132X				; takes about 428Tcy = 214us
	movlw		TRISC
	movwf		FSR
	bsf		SDA			; should already be set
	movlw		b'10010000'		; TC1321 SMBus address
	movwf		DAC_Addr
;I2C_START
	bsf		SCL
	goto		$+1
	bcf		SDA
	goto		$+1
	bcf		SCL			; START condition

  if TC1321
	movlw		.4
  else
	movlw		.3
  endif
	movwf		ByteCount
I2C_Loop
	movlw		.8
	movwf		BitCount
I2C_Byte
  if TC1321
	rlf		DAC_LSB,f
  endif
	rlf		DAC_MSB,f
	rlf		DAC_Command,f
	rlf		DAC_Addr,f
	btfss		STATUS,C		; output state of C on SDO
	bcf		SDA
	btfsc		STATUS,C
	bsf		SDA
	goto		$+1
	bsf		SCL			; toggle SCL
	goto		$+1
	bcf		SCL
	decfsz		BitCount,f
	goto		I2C_Byte
I2C_ACK
	bsf		SDA			; pre-condition for ACK
	goto		$+1
	bsf		SCL			; toggle SCL
	goto		$+1
	btfsc		SDI			; need to read the pin... use SDI.  If Low, then ACK... 
	goto		WriteToTC132X	; do it all again, No ACK
	bcf		SCL
	decfsz		ByteCount,f
	goto		I2C_Loop
;I2C_STOP
	bcf		SDA
	goto		$+1
	bsf		SCL
	goto		$+1
	bsf		SDA			; START condition

	return
 endif

;***************************************************************************************
;	PIC16F767 ADC Subroutine
;        byte 2        --        byte 1      --      byte 0
;       M                      LSB,0                    00h
; left justify the 10b result and pad remaining bits w/'0'
;
ReadPIC10bADC				; Read the PIC's ADC
	movwf		Temp
	rlf		Temp,f
	rlf		Temp,f
	rlf		Temp,w
	andlw		b'00111000'		; mask all but channel select bits
	iorlw		b'01000001'		; Fosc/16, ANx, ADON
	movwf		ADCON0		; 
	bsf		STATUS,RP0
	movlw		b'01011010'		; Left Justified, clock/2, Vref-=Vss, Vref+=AN3, AN0-AN4 enabled
	movwf		ADCON1
;	movlw		b'00011000'		; 6Tad acquisition time
;	movwf		ADCON2
;	clrf		CMCON		; disable comparators
;	clrf		CVRCON		; disable CVref
 	bcf		STATUS,RP0

	bsf		ADCON0,GO		; start the conversion (not that this ADC automatically handles the sampling delay)
	btfsc		ADCON0,GO
	goto		$-1
	movf		ADRESH,w
	movwf		ADC_Byte2		; save off the MSB
	bsf		STATUS,RP0
	movf		ADRESL,w
	bcf		STATUS,RP0
	movwf		ADC_Byte1		; save off the Byte1
	clrf		ADC_Byte0
	bcf		ADCON0, ADON	; shut off the ADC to conserve power
	return

;***************************************************************************************
;	MCP3302 (MCP3204) Subroutine
;        byte 2        --        byte 1      --      byte 0
;       MSB                   LSB,0		00
; Note: the 13b (12b) result is shifted Left and least significant bits are initialized to '0'
;
 if	HW_SPI 
ReadMCP3302					; go get the 3302 data
	clrf		ADC_Byte0
	clrf		ADC_Byte1
	movwf		ADC_Byte2		; save command byte
	bcf		STATUS,C		; pre-condition C for rotate
	rrf		ADC_Byte2,f		; shift command byte for TX
	rrf		ADC_Byte1,f
; SCK idles high
; Data output after falling edge of SCK
; Data sampled before rising edge of SCK
	bsf		STATUS,RP0
	movlw		b'11010000'
	movwf		TRISC			; make TX & RX & SDI inputs
	movlw		b'10000000'
	movwf		SSPSTAT		; Sample at the end of the data output time, TX on Rising Edge of SCK
 	bcf		STATUS,RP0
	movlw		b'00110000'
	movwf		SSPCON		; SCK idle high, Turn on SSP, SPI Master w/Fosc/4
	bcf		PIR1,SSPIF

SendMCP3302CommandByte
	movf		ADC_Byte2,w
	movwf		SSPBUF		; initiate a TX of the command byte
	btfss		PIR1,SSPIF		; wait to finish TX of MSB
	goto		$-1
	bcf		PIR1,SSPIF
GetMCP3302Byte2
	movf		ADC_Byte1,w
	movwf		SSPBUF		; initiate a TX of the remaining Command bit & RX most significant 5 bits
	btfss		PIR1,SSPIF		; wait to finish TX of MSB
	goto		$-1
	movf		SSPBUF,w
	andlw		b'00011111'		; mask of the 3 msbs
	movwf		ADC_Byte2		; save off the 5 MSbits
	bcf		PIR1,SSPIF
GetMCP3302Byte1
	clrf		SSPBUF		; initiate an RX of the LSB
	btfss		PIR1,SSPIF		; wait to finish TX of LSB
	goto		$-1
	movf		SSPBUF,w
	movwf		ADC_Byte1		; save off the Byte1
	bcf		PIR1,SSPIF
GetMCP3302Byte0
	clrf		ADC_Byte0		; save off the LSB

	bsf		CS0			; raise Chip Select
	bcf		STATUS,C
	rlf		ADC_Byte1,f
	rlf		ADC_Byte2,f
	rlf		ADC_Byte1,f
	rlf		ADC_Byte2,f
	rlf		ADC_Byte1,f
	rlf		ADC_Byte2,f
	return

 else
ReadMCP3302					; go get the 3551 data
	clrf		ADC_Byte0
	clrf		ADC_Byte1
	movwf		ADC_Byte2		; save command byte
	bcf		STATUS,C		; pre-condition C for rotate
	rrf		ADC_Byte2,f		; shift command byte for TX
	rrf		ADC_Byte1,f

	bsf		SCK			; idle high
	bcf		CS0			; select the MCP3302
	movlw		.24
	movwf		BitCount		; get all 3 bytes
MCP3302SerialLoop
	rlf		ADC_Byte0,f		; shift command byte for TX
	rlf		ADC_Byte1,f
	rlf		ADC_Byte2,f
	btfss		STATUS,C
	bcf		SDO			; output a '0' if needed
	btfsc		STATUS,C
	bsf		SDO			; output a '1' if needed
	bcf		SCK			; drop clock for next bit
	bcf		ADC_Byte0,0		; pre-clear input data bit
	bsf		SCK			; set clock to latch bit
	btfsc		SDI			; check for high or low bit
	bsf		ADC_Byte0,0		; set the input data bit
	decfsz		BitCount, f		; decrement bit counter
	goto		MCP3302SerialLoop	; get next bit

	bsf		CS0			; de-select A/D converter
	bcf		STATUS,C
	rlf		ADC_Byte0,f
	rlf		ADC_Byte1,f
	rlf		ADC_Byte0,f
	rlf		ADC_Byte1,f
	rlf		ADC_Byte0,f
	rlf		ADC_Byte1,w
	movwf		ADC_Byte2
	movf		ADC_Byte0,w
	movwf		ADC_Byte1
	clrf		ADC_Byte0
	return
 endif

;***************************************************************************************
;	MCP3551 Subroutines
;        byte 2        --        byte 1      --      byte 0
;       MSB                                                  LSB
;
; ERRATA:  The conversion time is max. 110ms for Rev B0 devices
  if  !BetaMCP3551
#define	CLK		SCK		; normal connections
#define	DIN		SDI		; normal connections
#define	ADCS		CS0		; normal connections
 else
;BetaMCP3551Patch0
#define	CLK		CS0		; 28p pin-swapped Beta Devices DE018
#define	DIN		SDI		; 28p pin-swapped Beta Devices
#define	ADCS		SCK		; 28p pin-swapped Beta Devices
  endif
 if	HW_SPI 
ReadMCP3551					; go get the 3551 data
; SCK idles high
; Data output after falling edge of SCK
; Data sampled before rising edge of SCK
	bsf		STATUS,RP0
	movlw		b'11010000'
	movwf		TRISC			; make TX & RX & SDI inputs
	movlw		b'10000000'
	movwf		SSPSTAT		; Sample at the end of the data output time, TX on Rising Edge of SCK
 	bcf		STATUS,RP0
	movlw		b'00110000'
	movwf		SSPCON		; SCK idle high, Turn on SSP, SPI Master w/Fosc/4
	bcf		PIR1,SSPIF

	clrf		ADC_Byte2		; reset input buffer
	clrf		ADC_Byte1		; reset input buffer
	clrf		ADC_Byte0		; reset input buffer

	bcf		CS0                		;INITIATE THE CONVERSION
	movlw		.3
	call		VAR1000TcyDELAY	; delay 1.5ms
	bsf		CS0               		 ; CS HIGH (ONE SHOT MODE)
	movlw		.250			; WAIT FOR CONVERSION TO COMPLETE, delay 125ms 
	call		VAR1000TcyDELAY
	bcf		CS0			; GET THE CONVERSION DATA

GetMCP3551Byte2
	movlw		.2
	movwf		SSPBUF		; initiate an RX
	btfss		PIR1,SSPIF		; wait to finish TX of MSB
	goto		$-1
	movf		SSPBUF,w
	movwf		ADC_Byte2		; save off the MSB
	bcf		PIR1,SSPIF
GetMCP3551Byte1
	movlw		.1
	movwf		SSPBUF		; initiate an RX
	btfss		PIR1,SSPIF		; wait to finish TX of LSB
	goto		$-1
	movf		SSPBUF,w
	movwf		ADC_Byte1		; save off the Byte1
	bcf		PIR1,SSPIF
GetMCP3551Byte0
	movlw		.0
	movwf		SSPBUF		; initiate an RX
	btfss		PIR1,SSPIF		; wait to finish TX of LSB
	goto		$-1
	movf		SSPBUF,w
	movwf		ADC_Byte0		; save off the LSB
	bcf		PIR1,SSPIF

	bsf		CS0			; raise Chip Select
	return

 else
ReadMCP3551					; go get the 3551 data
	clrf		SSPCON		; make sure SSP is off
	bsf		STATUS,RP0		; need to set bank 1
	movlw		b'11010000'		; normal silicon
	movwf		TRISC			; make TX & RX & SDI inputs
	clrf		SSPSTAT
	bcf		STATUS,RP0		; need to set bank 0

	clrf		ADC_Byte2		; reset input buffer
	clrf		ADC_Byte1		; reset input buffer
	clrf		ADC_Byte0		; reset input buffer

	bsf		CLK			; idle high
	nop
	bcf		ADCS                		;INITIATE THE CONVERSION
	movlw		.6
	call		VAR1000TcyDELAY	; delay 1.5ms
	bsf		ADCS               		; One Shot ADC conversion
	movlw		.200			; Delay 175ms to wait for conversion to complete
	call		VAR1000TcyDELAY	; 100k * 500ns = 50ms
	call		VAR1000TcyDELAY	; 250k * 500ns = 125ms

	bcf		ADCS			; Conversion Done
	movlw		.24
	movwf		BitCount		; get all 3 bytes
MCP3551ReadBit
	bcf		CLK			; drop clock for next bit
	bcf		STATUS,C		; pre-clear carry
	bsf		CLK			; set clock to latch bit
	btfsc		DIN			; check for high or low bit
	bsf		STATUS,C		; set carry bit
	rlf		ADC_Byte0, f		; rotate bit into position
	rlf		ADC_Byte1, f		; rotate bit into position
	rlf		ADC_Byte2, f		; rotate bit into position
	decfsz		BitCount, f		; decrement bit counter
	goto		MCP3551ReadBit	; get next bit

	bsf		ADCS			; de-select A/D converter
	return
 endif

;***************************************************************************************
InitUART
	bsf		STATUS,RP0		; bank0
	movlw		.25			; 19200 baud @8MHz   internal osc high baud rate mode
	movwf		SPBRG
	movlw		b'11100101'		; 18F = b'01100100' ; Async, 9-bit, high baud rate, TX9D=1
   	movwf		TXSTA
	bcf		STATUS,RP0		; bank0
	btfsc		RCSTA,OERR
	clrf		RCSTA			; toggle CREN to ensure OERR is reset
	movf		RCREG,w
	movf		RCREG,w
	movlw		b'11010000'		; Enable continous reception
	movwf		RCSTA			; 9-bit,spen=1,cren=1 to enable rcv
						; note that RCSTA:RX9D is the 9th Data bit
	movlw		TXSTA
	movwf		FSR
	return

;***************************************************************************************
SendADC_Data
	call		InitUART
	movf		ADC_Byte2,w
	bsf		INDF,TX9D		; indicate MSB, INDF = TXSTA
	btfss		PIR1,TXIF		;check if transmitter busy
	goto		$-1			;wait until transmitter is not busy
	movwf		TXREG			;transmit the MSB

	movf		ADC_Byte1,w
	bcf		INDF,TX9D		; INDF = TXSTA
	btfss		PIR1,TXIF		;check if transmitter busy
	goto		$-1			;wait until transmitter is not busy
	movwf		TXREG			;transmit ADC_Byte1

	movf		ADC_Byte0,w
;	bcf		INDF,TX9D		; INDF = TXSTA
	btfss		PIR1,TXIF		;check if transmitter busy
	goto		$-1			;wait until transmitter is not busy
	movwf		TXREG			;transmit the LSB
	return

;***************************************************************************************
Init_SPI
	clrf		SSPCON		; Turn off SSP
	bsf		STATUS,RP0
	movlw		b'11010000'
	movwf		TRISC			; make TX & RX & SDI inputs
	movlw		b'10000000'
	movwf		SSPSTAT		; Sample at the end of the data output time, TX on Rising Edge of SCK
 	bcf		STATUS,RP0
	movlw		b'00100000'
	movwf		SSPCON		; SCK idle *low*, Turn on SSP, SPI Master w/Fosc/4
	bcf		PIR1,SSPIF
	return

;***************************************************************************************
  if HW_I2C
Init_I2C
	clrf		SSPCON		; turn off SSP
	movlw		b'00011000'
	iorwf		PORTC,f		; set SCL & SDA
	bsf		STATUS,RP0
	iorwf		TRISC,f		; make TX & RX, SCL & SDAinputs
	movlw		b'01000000'
	movwf		SSPSTAT		; enable 400khz slew rate control & SMBus compatible
	movlw		b'01100000'
	movwf		SSPCON2		; disable Gen Call, ACK, RX, Stop, RepStart & Start
 	movlw		.4
	movwf		SSPADD		; 8Mhz/(4*(4+1)) = 8Mhz/20 = 400kHz
	bcf		STATUS,RP0
	movlw		b'00111000'
	movwf		SSPCON		; Turn on SSP, I2C Master w/ Fosc/(4*(SSPADD+1))
	bcf		PIR1,SSPIF
	return
  endif
  if SW_I2C
Init_I2C
	clrf		SSPCON		; Turn off SSP
	movlw		b'11100111'
	andwf		PORTC,f		; clear SCL & SDA
	bsf		STATUS,RP0
	movlw		b'00011000'
	iorwf		TRISC,f		; make TX & RX, SCL & SDAinputs
	bcf		STATUS,RP0
	return
  endif
;***************************************************************************************
FlashLEDs
	clrf		SSPCON		; Make sure SSP module is OFF
	clrf		RCSTA			; Make sure USART is OFF
	movlw		b'10000111'
	movwf		PORTC			; Turn on LED1, Turn off LED0, !SHDN & !CS0 & !CS1 = 1
	movlw		TRISC
	movwf		FSR
	movlw		b'00111111'
	andwf		INDF,f			; mask LEDs to outputs
	movlw		.8
	movwf		EchoCount
FlashLoop
	movlw		.250			; 125mS delay
	call		VAR1000TcyDELAY
	movlw		b'11000000'
	xorwf		PORTC,f
	decfsz		EchoCount,f
	goto		FlashLoop
	movlw		b'11000000'	
	iorwf		INDF,f		; Make the LEDs inputs
	return

;******************* VARIABLE DELAY SUBROUTINES *******************
;		DLYCNT1 = F9h = 249d    DLYCNT2 = W
;		DELAY = T((4 DLYCNT1 + 4) DLYCNT2 + 4)
;
;	ex. To create a 300ms delay when using a 4Mhz osc, 300-250 = 50
;		movlw	.50			; load .50 into WREG
;		call	VAR1000TcyDELAY	; call VAR1000TcyDELAY = 50ms delay w/4MHz Osc
;		call	VAR1000TcyDELAY	; call VAR1000TcyDELAY = 250ms delay w/4MHz Osc
;						; total = 300ms delay
;************
; The value in W at the time of the CALL = x.  Delay = 1000Tcy*x
VAR1000TcyDELAY
		movwf		DLYCNT2	; LOADS CONTROLLING DLY # INTO PRIMARY COUNTER
DLOOP2	movlw		.249		; MAXIMIZES THE SECONDARY DLY COUNTER
		movwf		DLYCNT1	;
DLOOP1	clrwdt		;or NOP
		decfsz		DLYCNT1,f	; DECREMENT AND TEST SECONDARY LOOP FOR ZERO
		goto		DLOOP1	; CONTINUE SECONDARY LOOP
		decfsz		DLYCNT2,f	; DECREMENT AND TEST PRIMARY DLY COUNTER
		goto		DLOOP2	; CONTINUE PRIMARY LOOP
		retlw		.250		; preload W for the next CALL VAR1000TcyDELAY
;************
;  VARIABLE 5 Tcy DELAY UP TO 256*5Tcy+5Tcy
;		DLYCNT1 = W
;		DELAY = T(1 + 5 DLYCNT1 - 1) + CALL + RETLW
;
;	ex. To create a 250us delay, (250/5)-1 = 49
;		movlw	.49			; load .49 into WREG
;		call	VAR5TcyDELAY	; call VAR5TcyDELAY
;************
; The value in W at the time of the CALL = x.  Delay = 5*Tcy + 5Tcy
VAR5TcyDELAY
		movwf		DLYCNT1	; LOADS CONTROLLING DLY # INTO PRIMARY COUNTER
DLOOP3	clrwdt		;or NOP
		nop
		decfsz		DLYCNT1,f	; DECREMENT AND TEST ZERO
		goto		DLOOP3	; CONTINUE LOOP
		retlw		.250		; preload W for the next CALL VAR5TcyDELAY
;***************************************************************************************

	 end

