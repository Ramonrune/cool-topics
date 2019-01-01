LIST p=18F458 ;PIC18F458 is the target processor

#include "P18f458.INC" ;Include header file

;====================================================================
; Macros
;--------------------------------------------------------------------

#define CLK_FREQ	D'20000000'
#define BAUD(x)	((CLK_FREQ/x)/D'64')-1

#define BRG_VAL	BAUD(D'9600')	;Baud rate configuration value

;====================================================================
; Uninitialised data
;--------------------------------------------------------------------

; General temps
TMP1		equ	0x000000
TMP2		equ	0x000001

; Current LBA sector address for reading/wring
ATA_A0		equ	0x000002
ATA_A1		equ	0x000003
ATA_A2		equ	0x000004
ATA_A3		equ	0x000005

; Counter used to track data words read/written to/from ATA
ATA_CNT		equ	0x000006

; High priority interrupt temps
STATUS_TEMP_H	equ	0x000007
WREG_TEMP_H	equ	0x000008
BSR_TEMP_H	equ	0x000009

; Low priority interrupt temps
STATUS_TEMP_L	equ	0x00000A
WREG_TEMP_L	equ	0x00000B
BSR_TEMP_L	equ	0x00000C

; Countdown number of timer 0 overflows
T0COUNT		equ	0x00000D

; End of logged data
END_POSL	equ	0x00000E
END_POSH	equ	0x00000F
END_ATA_A0	equ	0x000010
END_ATA_A1	equ	0x000011
END_ATA_A2	equ	0x000012
END_ATA_A3	equ	0x000013

; Temp for log data to be displayed
INPDATA_L	equ	0x000014
INPDATA_H	equ	0x000015

; Countdoen the number of log entries on a display line
OUT_COUNT	equ	0x000016

; ATA data transfer buffer
ATA_BUF		equ	0x000400
ATA_BUF_END	equ	0x000600

;====================================================================
; Interrupt vectors
;--------------------------------------------------------------------
	org	0x000000	;Reset vector
	bra	START

	org	0x000008	;High priority interrupt vector
	bra	INT_HIGH

	org	0x000018	;Low priority interrupt vector
	bra	INT_LOW

;====================================================================
; Main program
;--------------------------------------------------------------------
START
	rcall	INIT		; Program initialisation
	rcall	OUT_VERSION	; Version message
REHELP
	rcall	OUT_HELP	; Help message
MLOOP
	rcall	OUT_COMMAND	; Command prompt

	rcall	UART_Getch	; Get user input
	movwf	TMP1		; and store

	rcall	OUT_CRLF	; Newline
	movlw	'h'		; Check for help
	xorwf	TMP1, W
	bz	REHELP
	movlw	'H'
	xorwf	TMP1, W
	bz	REHELP
	movlw	'v'		; Check for version
	xorwf	TMP1, W
	bz	VERSION
	movlw	'V'
	xorwf	TMP1, W
	bz	VERSION
	movlw	'l'		; Check for log start
	xorwf	TMP1, W
	bz	LOG
	movlw	'L'
	xorwf	TMP1, W
	bz	LOG
	movlw	'd'		; Check for log dump
	xorwf	TMP1, W
	bz	DUMP
	movlw	'D'
	xorwf	TMP1, W
	bz	DUMP
	rcall	OUT_UNKNOWN	; Command is unknown
	goto	MLOOP

VERSION	rcall	OUT_VERSION	; Version message
	goto	MLOOP

LOG	rcall	OUT_LOG		; Log start message
	rcall	LOG_START	; Enable logging under interrupt
	rcall	UART_Getch	; Wait for any user input
	rcall	LOG_STOP	; Terminate logging
	rcall	OUT_CRLF
	goto	MLOOP

DUMP	rcall	OUT_DUMP	; Dump start message
	rcall	DUMP_ALL	; Dump data
	goto	MLOOP

;====================================================================
; Program initialisation
;--------------------------------------------------------------------
INIT
	;Setup serial comms
	movlw	b'10010000'	;Enable USART in continous receive mode
	movwf	RCSTA
	movlw	b'00100010'	;Async, TX enabled, low baud rate
	movwf	TXSTA
	movlw	BRG_VAL		;Set baud rate
	movwf	SPBRG
	movf	RCREG, W	;Flush out RX buffer
	movf	RCREG, W

	;Setup I/O ports
	clrf	PORTA
	setf	TRISA		; Port A all input
	clrf	PORTB
	setf	TRISB		; Port B all input, ATA D0-7
	clrf	PORTC
	movlw	B'11100000'	; Port C lower bits for ATA adressing
	movwf	TRISC
	movlw	B'00000111'	; Turn off comparitor
	movwf	CMCON		; On PORTD bits 0-3
	clrf	PORTD
	setf	TRISD		; Port D all input, ATA D8-15
	movlw	B'00000011'
	movwf	PORTE
	movlw	B'00000100'	; Port E lower two bits output for ATA
	movwf	TRISE		; read and write
	rcall	LOG_RESET	; Reset log pointers
	rcall	LOG_UPDATE
	return

;====================================================================
; High priority intrrupt handler
;--------------------------------------------------------------------
INT_HIGH
	movff	STATUS, STATUS_TEMP_H
	movff	BSR, BSR_TEMP_H
	movwf	WREG_TEMP_H

	bcf	INTCON, TMR0IF	;Clear timer 0 overflow interrupt flag
	decfsz	T0COUNT
	bra	INT_HIGH_EXIT1
	movlw	D'20'		;Only start conversion every 20 timer 0 timeouts
	movwf	T0COUNT
	bsf	ADCON0, GO	;Start ADC conversion

INT_HIGH_EXIT1
	movf	WREG_TEMP_H, W
	movff	BSR_TEMP_H, BSR
	movff	STATUS_TEMP_H, STATUS
	retfie

;====================================================================
; Low prority interrupt handler
;--------------------------------------------------------------------
INT_LOW
	movff	STATUS, STATUS_TEMP_L
	movff	BSR, BSR_TEMP_L
	movwf	WREG_TEMP_L

	movf	ADRESL, W	;Copy ADC result to buffer
	movwf	POSTINC2
	movf	ADRESH, W	;Copy ADC result to buffer
	movwf	POSTINC2

	bcf	PIR1, ADIF	;Clear ADC interrupt flag

	movlw	HIGH(ATA_BUF_END)	; Check if at end of buffer
	cpfseq	FSR2H
	bra	INT_LOW_EXIT1
	movlw	LOW(ATA_BUF_END)
	cpfseq	FSR2L
	bra	INT_LOW_EXIT1

	rcall	ATA_Block_Write
	rcall	ATA_A_INC
	lfsr	FSR2, ATA_BUF	; Point to start of data capture buffer

INT_LOW_EXIT1
	movf	WREG_TEMP_L, W
	movff	BSR_TEMP_L, BSR
	movff	STATUS_TEMP_L, STATUS
	retfie

;====================================================================
; Read a byte from the serial port
;--------------------------------------------------------------------
; W contains the byte that was received
;--------------------------------------------------------------------
UART_Getch
	clrwdt
	btfss	PIR1, RCIF	; Wait for RX buffer full
	bra	UART_Getch
	movf	RCREG, W
	return

;====================================================================
; Write a byte to the serial port
;--------------------------------------------------------------------
; W contains the byte to be sent
;--------------------------------------------------------------------
UART_Putch
	btfss	PIR1, TXIF	; Wait for TX buffer empty
	bra	UART_Putch
	movwf	TXREG
	return

;====================================================================
; Write null terminated string to serial port from
; program memory
;--------------------------------------------------------------------
; TBLPTR Points to the start of the string
;--------------------------------------------------------------------
UART_Puts_loop
	rcall	UART_Putch	
UART_Puts
	tblrd*+
	movf	TABLAT, W
	bnz	UART_Puts_loop
	return

;====================================================================
; Read a sector from the ATA drive
;--------------------------------------------------------------------
ATA_Block_Read
	rcall	ATA_BSY_Wait	; Drive ready for command
	rcall	ATA_Send_LBA
	movlw	0x20		; Read sectors command
	movwf	TMP1
	movlw	0x17		; ATA Command regsiter
	rcall	ATA_Reg8_Write
	clrf	ATA_CNT
	lfsr	FSR0, ATA_BUF
ATA_Block_Read_Lp1
	rcall	ATA_DRQ_Wait	; Drive data waiting
	movlw	0x10
	rcall	ATA_Reg16_Read
	movf	TMP1, W
	movwf	POSTINC0
	movf	TMP2, W
	movwf	POSTINC0
	incfsz	ATA_CNT
	bra	ATA_Block_Read_Lp1
	return

;====================================================================
; Write a sector too the ATA drive
;--------------------------------------------------------------------
ATA_Block_Write
	rcall	ATA_BSY_Wait	; Drive ready for command
	rcall	ATA_Send_LBA
	movlw	0x30		; Write sectors command
	movwf	TMP1
	movlw	0x17		; ATA Command regsiter
	rcall	ATA_Reg8_Write
	clrf	ATA_CNT
	lfsr	FSR0, ATA_BUF

ATA_Block_Write_Lp1
	rcall	ATA_DRQ_Wait	; Drive ready for data
	movf	POSTINC0, W
	movwf	TMP1
	movf	POSTINC0, W
	movwf	TMP2
	movlw	0x10
	rcall	ATA_Reg16_Write
	incfsz	ATA_CNT
	bra	ATA_Block_Write_Lp1

	return

;====================================================================
; Wait for DRQ to indicate drive is ready for data
;--------------------------------------------------------------------
ATA_DRQ_Wait
	movlw	0x17		; Drive status register
	rcall	ATA_Reg8_Read
	btfss	TMP1, 3		; DRQ bit (data request)
	bra	ATA_DRQ_Wait
	return

;====================================================================
; Wait for BSY to indicate drive is ready for a command
;--------------------------------------------------------------------
ATA_BSY_Wait
	movlw	0x17		; Drive status register
	rcall	ATA_Reg8_Read
	btfsc	TMP1, 7		; BSY bit (busy)
	bra	ATA_BSY_Wait
	return

;====================================================================
; Zero out LBA address
;--------------------------------------------------------------------
ATA_A_RESET
	clrf	ATA_A0		; Point to first sector
	clrf	ATA_A1
	clrf	ATA_A2
	clrf	ATA_A3
	return

;====================================================================
; Increment LBA address by one
;--------------------------------------------------------------------
ATA_A_INC
	incfsz	ATA_A0		; Point to next sector
	bra	ATA_A_INC_EXIT
	incfsz	ATA_A1
	bra	ATA_A_INC_EXIT
	infsnz	ATA_A2
	incf	ATA_A3
ATA_A_INC_EXIT
	return

;====================================================================
; Transfer LBA address to drive
;--------------------------------------------------------------------
ATA_Send_LBA
	movlw	0x01		; Sector count
	movwf	TMP1
	movlw	0x12		; ATA Sector count
	rcall	ATA_Reg8_Write
	movff	ATA_A0, TMP1
	movlw	0x13		; ATA LBA 0-7 register
	rcall	ATA_Reg8_Write
	movff	ATA_A1, TMP1
	movlw	0x14		; ATA LBA 8-15 register
	rcall	ATA_Reg8_Write
	movff	ATA_A2, TMP1
	movlw	0x15		; ATA LBA 16-23 register
	rcall	ATA_Reg8_Write
	movf	ATA_A3, W
	iorlw	B'01000000'	; Indicate address is LBA not CHS
	movwf	TMP1
	movlw	0x16		; ATA LBA 24-27 register
	rcall	ATA_Reg8_Write
	return
;====================================================================
; Read a register from the ATA drive (8 bit)
;--------------------------------------------------------------------
; W    contains address
; TMP1 contains data
;--------------------------------------------------------------------
ATA_Reg8_Read
	btfss	PORTC, 5	; Wait until ready
	bra	ATA_Reg8_Read
	andlw	B'00011111'	; Set address
	movwf	PORTC
	bcf	LATE, 0		; DIOR low
	nop			; Wait
	nop
	movf	PORTB, W	; Get data
	movwf	TMP1
	bsf	LATE, 0		; DIOR high
	return

; +-----------------------------------+
; | PORTC 4-0 to ATA register - Read  |
; +------+----------------------------+
; | Addr | Register                   |
; +------+----------------------------+
; | 0x0E | Alternate status           |
; | 0x0F | Drive address              |
; | 0x10 | Data (16 bit reg)          |
; | 0x11 | Features                   |
; | 0x12 | Sector count               |
; | 0x13 | LBA 0-7                    |
; | 0x14 | LBA 8-15                   |
; | 0x15 | LBA 16-23                  |
; | 0x16 | LBA 24-27                  |
; | 0x17 | Status                     |
; +------+----------------------------+

;====================================================================
; Write a register to the ATA drive (8 bit)
;--------------------------------------------------------------------
; W    contains address
; TMP1 contains data
;--------------------------------------------------------------------
ATA_Reg8_Write
	btfss	PORTC, 5	; Wait until ready
	bra	ATA_Reg8_Write
	andlw	B'00011111'	; Set address
	movwf	PORTC
	movf	TMP1, W		; Set data
	movwf	PORTB
	clrf	TRISB		; Port for output
	bcf	LATE, 1		; DIOW low
	nop			; Wait
	nop
	bsf	LATE, 1		; DIOW high
	setf	TRISB		; Port for input
	return

; +-----------------------------------+
; | PORTC 4-0 to ATA register - Write |
; +------+----------------------------+
; | Addr | Register                   |
; +------+----------------------------+
; | 0x0E | Device control             |
; | 0x10 | Data (16 bit reg)          |
; | 0x11 | Features                   |
; | 0x12 | Sector count               |
; | 0x13 | LBA 0-7                    |
; | 0x14 | LBA 8-15                   |
; | 0x15 | LBA 16-23                  |
; | 0x16 | LBA 24-27                  |
; | 0x17 | Command                    |
; +------+----------------------------+

;====================================================================
; Read a register from the ATA drive (16 bit)
;--------------------------------------------------------------------
; W    contains address
; TMP1 contains data low
; TMP2 contains data high
;--------------------------------------------------------------------
ATA_Reg16_Read
	btfss	PORTC, 5	; Wait until ready
	bra	ATA_Reg16_Read
	andlw	B'00011111'	; Set address
	movwf	PORTC
	bcf	LATE, 0		; DIOR low
	nop			; Wait
	nop
	movf	PORTB, W	; Get data
	movwf	TMP1
	movf	PORTD, W
	movwf	TMP2
	bsf	LATE, 0		; DIOR high
	return

;====================================================================
; Write a register to the ATA drive (16 bit)
;--------------------------------------------------------------------
; W    contains address
; TMP1 contains data low
; TMP2 contains data high
;--------------------------------------------------------------------
ATA_Reg16_Write
	btfss	PORTC, 5	; Wait until ready
	bra	ATA_Reg16_Write
	andlw	B'00011111'	; Set address
	movwf	PORTC
	movf	TMP1, W		; Set data
	movwf	PORTB
	movf	TMP2, W
	movwf	PORTD
	clrf	TRISB		; Port for output
	clrf	TRISD
	bcf	LATE, 1		; DIOW low
	nop			; Wait
	nop
	bsf	LATE, 1		; DIOW high
	setf	TRISB		; Ports for input
	setf	TRISD
	return

;====================================================================
; Output string routines
;--------------------------------------------------------------------
OUT_VERSION
	movlw	UPPER(MSG_VERSION)
	movwf	TBLPTRU
	movlw	HIGH(MSG_VERSION)
	movwf	TBLPTRH
	movlw	LOW(MSG_VERSION)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_HELP
	movlw	UPPER(MSG_HELP)
	movwf	TBLPTRU
	movlw	HIGH(MSG_HELP)
	movwf	TBLPTRH
	movlw	LOW(MSG_HELP)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_COMMAND
	movlw	UPPER(MSG_COMMAND)
	movwf	TBLPTRU
	movlw	HIGH(MSG_COMMAND)
	movwf	TBLPTRH
	movlw	LOW(MSG_COMMAND)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_CRLF
	movlw	UPPER(MSG_CRLF)
	movwf	TBLPTRU
	movlw	HIGH(MSG_CRLF)
	movwf	TBLPTRH
	movlw	LOW(MSG_CRLF)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_UNKNOWN
	movlw	UPPER(MSG_UNKNOWN)
	movwf	TBLPTRU
	movlw	HIGH(MSG_UNKNOWN)
	movwf	TBLPTRH
	movlw	LOW(MSG_UNKNOWN)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_LOG
	movlw	UPPER(MSG_LOG)
	movwf	TBLPTRU
	movlw	HIGH(MSG_LOG)
	movwf	TBLPTRH
	movlw	LOW(MSG_LOG)
	movwf	TBLPTRL
	goto	UART_Puts
OUT_DUMP
	movlw	UPPER(MSG_DUMP)
	movwf	TBLPTRU
	movlw	HIGH(MSG_DUMP)
	movwf	TBLPTRH
	movlw	LOW(MSG_DUMP)
	movwf	TBLPTRL
	goto	UART_Puts

;====================================================================
; Output value to USART as two hexadecimal digits
;--------------------------------------------------------------------
; W contains value to be output
;--------------------------------------------------------------------
OUT_HEX
	movwf	TMP1
	swapf	TMP1, W
	rcall	OUT_HEX_SUB1
	movf	TMP1, W
OUT_HEX_SUB1
	andlw	0x0F
	addlw	0xF6
	btfsc	STATUS, C
	addlw	0x07
	addlw	0x3A
	bra	UART_Putch

;====================================================================
; Start logging
;--------------------------------------------------------------------
LOG_START
	rcall	LOG_RESET
	rcall	INIT_ADC
	rcall	INIT_TIMER
	rcall	START_TIMER
	bsf	RCON, IPEN	; Enable interrupt priority
	bsf	INTCON, GIEH	; Enable high prority interrupts
	bsf	INTCON, GIEL	; Enable low prority interrupts
	return

;====================================================================
; Stop logging
;--------------------------------------------------------------------
LOG_STOP
	bcf	INTCON, 7	; Disable interrupts
	rcall	STOP_TIMER
	rcall	STOP_ADC
	rcall	ATA_Block_Write	; Flush buffer to disk
LOG_UPDATE
	movff	FSR2L, END_POSL	; Copy over to end log pointers
	movff	FSR2H, END_POSH
	movff	ATA_A0, END_ATA_A0
	movff	ATA_A1, END_ATA_A1
	movff	ATA_A2, END_ATA_A2
	movff	ATA_A3, END_ATA_A3
	return

;====================================================================
; Reset log ready for start of logging
;--------------------------------------------------------------------
LOG_RESET
	lfsr	FSR2, ATA_BUF	; Point to start of data capture buffer
	rcall	ATA_A_RESET
	return

;====================================================================
; Initialise ADC converter
;--------------------------------------------------------------------
INIT_ADC
	movlw	B'00001110'
	movwf	ADCON1
	movlw	B'11000001'
	movwf	ADCON0
	bcf	IPR1, ADIP	; Low priority
	bcf	PIR1, ADIF	; Clear any pending interrupt
	bsf	PIE1, ADIE	; Enable ADC conversion interrupt

	return

;====================================================================
; Initialise timer 0
;--------------------------------------------------------------------
INIT_TIMER
	movlw	B'01000110'
	movwf	T0CON
	movlw	D'1'		; Setup countdown on TMR0 for ADC trigger
	movwf	T0COUNT
	bcf	INTCON, TMR0IF	; Clear any pending TMR0 overflow interrupt
	bsf	INTCON, TMR0IE	; Enable timer 0 overflow interrupt
	return

;====================================================================
; Start timer 0
;--------------------------------------------------------------------
START_TIMER
	bsf	T0CON, 7	; Start timer 0
	return

;====================================================================
; Stop timer 0
;--------------------------------------------------------------------
STOP_TIMER
	bcf	INTCON, TMR0IE	; Disable timer 0 overflow interrupt
	bcf	INTCON, TMR0IF	; Clear any pending TMR0 overflow interrupt
	bcf	T0CON, 7	; Stop timer 0
	return

;====================================================================
; Stop ADC conversion
;--------------------------------------------------------------------
STOP_ADC
	bcf	PIE1, ADIE	; Diasable ADC conversion interrupt
	bcf	PIR1, ADIF	; Clear any pending interrupt
	bcf	ADCON0, ADON	; Turn off ADC module
	return

;====================================================================
; Dump data from ATA to USART in hex
;--------------------------------------------------------------------
DUMP_ALL
	rcall	ATA_A_RESET
	lfsr	FSR2, ATA_BUF_END
	movlw	0x10
	movwf	OUT_COUNT

	movf	ATA_A3, W	; Exit if no data to display
	iorwf	ATA_A2, W
	iorwf	ATA_A1, W
	iorwf	ATA_A0, W
	btfss	STATUS, Z
	bra	DUMP_ALL_JP1
	movlw	HIGH(ATA_BUF)
	cpfseq	END_POSH
	bra	DUMP_ALL_JP1
	movlw	LOW(ATA_BUF)
	cpfseq	END_POSL
	bra	DUMP_ALL_JP1
	bra	DUMP_ALL_EXIT

DUMP_ALL_LP1
	movlw	HIGH(ATA_BUF_END)	; Check if next sector required
	cpfseq	FSR2H
	bra	DUMP_ALL_JP2
	movlw	LOW(ATA_BUF_END)
	cpfseq	FSR2L
	bra	DUMP_ALL_JP2
	rcall	ATA_A_INC
DUMP_ALL_JP1
	rcall	ATA_Block_Read		; Get a new sector
	lfsr	FSR2, ATA_BUF		; Point buffer to start of sector
DUMP_ALL_JP2

	movlw	0x20
	rcall	UART_Putch

	movff	POSTINC2, TMP2
	movf	POSTINC2, W
	rcall	OUT_HEX
	movf	TMP2, W
	rcall	OUT_HEX

	decfsz	OUT_COUNT
	bra	DUMP_ALL_JP3
	movlw	0x10
	movwf	OUT_COUNT
	rcall	OUT_CRLF
DUMP_ALL_JP3
	movf	END_POSH, W		; Check not at the end of data
	cpfseq	FSR2H
	bra	DUMP_ALL_LP1
	movf	END_POSL, W
	cpfseq	FSR2L
	bra	DUMP_ALL_LP1
	movf	END_ATA_A3, W
	cpfseq	ATA_A3
	bra	DUMP_ALL_LP1
	movf	END_ATA_A2, W
	cpfseq	ATA_A2
	bra	DUMP_ALL_LP1
	movf	END_ATA_A1, W
	cpfseq	ATA_A1
	bra	DUMP_ALL_LP1
	movf	END_ATA_A0, W
	cpfseq	ATA_A0
	bra	DUMP_ALL_LP1
DUMP_ALL_EXIT
	return

;====================================================================
; Program messages
;--------------------------------------------------------------------
MSG_VERSION
	DATA	"Labcenter Data Logger v1.0\r\n", 0
MSG_COMMAND
	DATA	"\r\nCommand? ", 0
MSG_CRLF
	DATA	"\r\n", 0
MSG_HELP
	DATA	"Help:\r\nH - This help\r\nV - Version\r\nL - Start logging\r\nD - Dump log\r\n", 0
MSG_UNKNOWN
	DATA	"Unknown command.\r\n", 0
MSG_LOG
	DATA	"Logging...\r\nPress any key to stop.", 0
MSG_DUMP
	DATA	"Start of dump.\r\n", 0
;====================================================================
END