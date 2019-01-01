; #############################################################################
;                            Software License Agreement
;
;  The software supplied herewith by Microchip Technology Incorporated 
;  (the "Company") is intended and supplied to you, the Company's customer,
;  for use solely and exclusively on Microchip products.
;
;  The software is owned by the Company and/or its supplier, and is 
;  protected under applicable copyright laws. All rights are reserved.
;  Any use in violation of the foregoing restrictions may subject the user
;  to criminal sanctions under applicable laws, as well as to civil 
;  liability for the breach of the terms and conditions of this license.
;
;  THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,
;  WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO,
;  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;  PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, IN ANY
;  CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR CONSEQUENTIAL
;  DAMAGES, FOR ANY REASON WHATSOEVER.
;
; #############################################################################
;******************************************************************************
;*  UARTInterface.asm
;*  Serial communications via UART
;******************************************************************************
;*  Microchip Technology Incorporated
;*  
;*  Ver 1.00  10 March 2005
;*    Original code
;*  Ver 1.01  03 May 2005	w.r.brown
;*    Added Break sense to Autobaud
;*
;******************************************************************************
;*
;*  Serial communications interface between UART and application.
;*
;******************************************************************************

#define	UARTInterface_M

	include	"UARTInterface.h"
			
	UDATA_SHR

TXPut		res	1	; pointer to next available TX buffer location
TXGet		res	1	; pointer to next TX character to be sent
RXPut		res	1	; pointer to next available RX buffer location
RXGet		res	1	; pointer to next received RX character
Flags		res	1	; 8 general purpose flags
RXChar		res	1	; receive character from RCREG
	
DATA1	UDATA
	
RXBuffer	res	RXBuffSize-1
RXBuffEnd	res	1
TXBuffer	res	TXBuffSize-1
TXBuffEnd	res	1

		
PROG	code
PutTX:
;******************************************************************************
;*
;*	Move the contents of the W register to the TX buffer.
;*	Increment the TX buffer pointer and enable the UART for transmission.
;*
;******************************************************************************

; Put W into the TX buffer

	movwf	FSR		; save W in FSR
	bankisel TXPut
	movf	TXPut,w		; put pointer in W
	xorwf	FSR,f		; swap W with FSR
	xorwf	FSR,w		;
	xorwf	FSR,f		;
	movwf	INDF		; move data to buffer
	
; Increment the transmit buffer pointer. If the new value is equal to one past
; the buffer then reset the pointer to the first buffer location.

	incf	TXPut,f		; increment the pointer
	movf	TXPut,w		; compare the new value with
	xorlw	TXBuffEnd + 1	; one past the buffer space
	movlw	TXBuffer	; prepare for reset
	btfsc	STATUS,Z	; is pointer past buffer space?
	movwf	TXPut		; yes - reset pointer

TXStart:	
; enable UART for transmit

	banksel	TXCTRL		; user defined: Flags for polled and
				;   PIE1 for interrupt driven
	bsf	TXCTRL,TXON	; user defined: Flag bit for polled and
				;   TXIE for interrupt driven.
	banksel	Bank0
	return
		
TXService:
;******************************************************************************
;*
;*	Move a character from the TX buffer space to the TX output
;*	register. Disable the serial transmitter if the TX buffer is empty.
;*
;******************************************************************************

; Compare the TX buffer output pointer to the TX buffer input pointer.
; If they are equal then the complete message has been sent. 
; If that is the case then turn off the transmitter and clear the TXIF flag.

	movf	TXPut,w		; compare buffer input pointer to
	xorwf	TXGet,w		; buffer output pointer
	btfsc	STATUS,Z	; 
	goto	TXStop		; stop transmitting if equal

; TX buffer is not empty, get the next character from the TX buffer and 
; put it in the TX output register then update the buffer pointer and return.

	bankisel TXGet
	movf	TXGet,w		; get TX buffer output pointer
	movwf	FSR		; set indirect pointer
	movf	INDF,w		; get the character from buffer memory
	movwf	TXREG		; put it in the TX output register

; Increment the transmit buffer pointer. If the new value is equal to one past
; the buffer then reset the pointer to the first buffer location.

	incf	TXGet,f		; increment the pointer
	movf	TXGet,w		; compare the new value with
	xorlw	TXBuffEnd + 1	; one past the buffer space
	movlw	TXBuffer	; prepare for reset
	btfsc	STATUS,Z	; is pointer past buffer space?
	movwf	TXGet		; yes - reset pointer
	return

TXStop:	
; TX output buffer is empty. If the output shift register is empty then
; disable the TXON bit (Flag for polled, TXIE for interrupt driven).

	banksel	TXSTA
	btfss	TXSTA,TRMT	;
	goto	TXSvcExit
	
	banksel	TXCTRL
	bcf	TXCTRL,TXON
TXSvcExit:
	banksel	Bank0
	return

GetRX:
;******************************************************************************
;*
;*	Move one byte of the receive buffer to the W register.
;*	Increment the RX buffer pointer then check if buffer is empty.
;*	Reset the MsgFlag when the last character is retrieved.
;*
;******************************************************************************

; Set the FSR to the buffer pointer to retrieve the character

	bankisel RXGet
	movf	RXGet,w
	movwf	FSR

; Increment the buffer pointer but keep it in the circular buffer range
	
	incf	RXGet,f		; increment output pointer in place
	movf	RXGet,w		; compare output pointer to end of buffer
	xorlw	RXBuffEnd+1	; see if it went past the end of buffer
	movlw	RXBuffer	; prepare to reset the pointer to the start
	btfsc	STATUS,Z	;
	movwf	RXGet		; reset pointer on buffer over run

; Clear the MsgFlag if the input buffer is empty 
;  (i.e. RXGet equals RXPut)
	
	movf	RXPut,w		; compare buffer input pointer
	xorwf	RXGet,w		; to buffer output pointer
	btfsc	STATUS,Z	;
	bcf	Flags,MsgFlag	; indicate that the RX buff is empty

; Retrieve the character from the RX buffer and return with it in W

	movf	INDF,w
	return

RXService:
;******************************************************************************
;*
;*	Move a character from the RX input register to the RX buffer space.
;*	All characters are placed in the input buffer space except 
;*	backspace, which deletes the last character. A carrige return 
;*	terminates the receive message and sets the MsgFlag to indicate
;* 	that a new message is in the receive buffer.
;*	This routine will also echo the received character if the echo flag
;*	is true.
;*	Received character is also returned in RXChar for immediate processing.
;*
;******************************************************************************
	
; Test framing flag and preset break flag if it is set
	
	btfsc	RCSTA,FERR	; test framing error
	bsf	Flags,BreakFlag	; set break flag on framing error
	
; Put the received character into the receive buffer space.

	bankisel RXPut
	movf	RXPut,w		; get current buffer pointer
	movwf	FSR		; set the indirect memory pointer
	movf	RCREG,w		; get the received character
	movwf	RXChar		; save for easy retrieval
	btfss	STATUS,Z	; is received character a null?
	bcf	Flags,BreakFlag	; not null - clear break flag
	
	btfsc	Flags,BreakFlag	; break detected if flag is still set
	return			; ignore receive if break
	
	movwf	INDF		; put received character in buffer memory

; Compare the received charactrer to a backspace. If it is equal then decrement
; the receive buffer pointer, but no further than the start of message.

	xorlw	BS		; compare received character with backspace
	btfsc	STATUS,Z
	goto	RXDelete	; process input correction

; Compare the received character to a carrige return. If it is equal then set
; the MsgFlag
	
	movlw	CR		; carrige return
	xorwf	INDF,w		; compare with received character
	btfsc	STATUS,Z
	bsf	Flags,MsgFlag	; message complete and ready for processing

	movf	INDF,w		; restore the received character
	btfsc	Flags,EchoFlag
	call	PutTX		; echo
	
; Increment the receive buffer pointer. If the new value is equal to one past
; the buffer end then reset the pointer to the first buffer location.

	incf	RXPut,f		; increment the pointer
	movf	RXPut,w		; compare the new value with
	xorlw	RXBuffEnd + 1	; one past the buffer space
	movlw	RXBuffer	; prepare for reset
	btfsc	STATUS,Z	; is pointer past buffer space?
	movwf	RXPut		; yes - reset pointer
	return
	
RXDelete:
	movf	INDF,w		; restore the received character
	btfsc	Flags,EchoFlag
	call	PutTX		; echo

; Remove the last received character from the receive input buffer.

	movf	RXGet,w		; beginning of message
	xorwf	RXPut,w		; compare to current pointer
	btfsc	STATUS,Z	; ignore character if pointers are equal
	return
	
; Decrement the receive buffer pointer. If the new value is equal to one below
; the buffer start then reset the pointer to the last buffer location.

	decf	RXPut,f		; decrement the pointer
	movf	RXPut,w		; compare the new value with
	xorlw	RXBuffer - 1	; one below the buffer space
	movlw	RXBuffEnd	; prepare for reset
	btfsc	STATUS,Z	; is pointer below buffer space?
	movwf	RXPut		; yes - reset pointer
	return

ResetRXPointers:
;******************************************************************************
;*
;*	All preceeding characters in the buffer will be effectively flushed 
;*	by moving the GetRX pointer to the RXPut and clearing the MsgFlag.
;*
;******************************************************************************

	movf	RXPut,w		; reset get pointer
	movwf	RXGet
	bcf	Flags,MsgFlag	; clear message flag
	return

UARTInit:
;******************************************************************************
;*
;*	Initialize UART peripheral registers and buffer pointers
;*	See UARTComm.h for initialization values
;*
;******************************************************************************
	
; Initialize UART SFRs

	banksel	TXSTA		;
	movlw	TXSTAInit	;
	movwf	TXSTA		;
	bsf	TRIS232,TXBitNum ;
	bsf	TRIS232,RXBitNum
	banksel	RCSTA		;
	movlw	RCSTAInit	;
	movwf	RCSTA		;
	
; Initialize buffer pointers to beginning of buffer space

	movlw	RXBuffer
	movwf	RXGet
	movwf	RXPut
	movlw	TXBuffer
	movwf	TXPut
	movwf	TXGet

#ifdef ENABLE_AUTOBAUD
; RC Fosc needs baud rate calibration
				; fall through to autobaud which sets SPBRG
Autobaud:
;******************************************************************************
;
; ___    __________            ________
;    \__/          \__________/
;       |                     |
;       |-------- X ----------|
;
;   X = The number of Timer increments between the first and last
;       rising edge of the RS232 calibration character 0x3F (ASCII '?'). Other 
;       possible calibration characters are 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x7F.
;   [0]  Fosc = CPU oscillator frequency
;   [1]  Pre  = Timer0 Prescale
;   [2]  Tclk = Timer0 clock = Fosc/4
;   [3]  Ti = Timer Interval = Pre/Tclk
;   [4]  Bits = Number of data bits in X
;   [5]  Baud = Baud rate (i.e. Bits/Second)
;   [6]  X = (Bits/Baud)/Ti = Bits/Baud * Tclk/Pre
;   [8]  Baud = Bits/X * Fosc/(4*Pre)             ; from [6] and [2]
;   [9]  SPBRG = [Fosc/(16*(Baud))]-1             ; by definition when BRGH = 1
;   [10] SPBRG = [Fosc/16 * X/Bits * (4*Pre)/Fosc]-1  ; from [8] & [9]
;   [11] SPBRG = [(X*Pre)/(4*Bits)]-1             ; [10] reduced
;   [12] SPBRG = (X/2)-1                          ; from [11] assuming Pre = 2*Bits = 2*8 = 16
; Note: X/2 allows rounding up which changes the SPBRG uncertainty from +0/-1 bit to +/- 0.5 bit
;
;******************************************************************************

	bcf     RCSTA, CREN             ; Stop receiving
	banksel OPTION_REG
	movlw   0xFF & ~( 1 << T0CS | 1 << PSA | 1 << PS0 | 1 << PS1 | 1 << PS2)
	andwf   OPTION_REG,w
	iorlw   0 << PS2 | 1 << PS1 | 1 << PS0   ; 16:1 Prescale
	movwf   OPTION_REG
	banksel Bank0
	call    SenseBreak              ; cal character follows a break
	call    WaitForRise             ; find first rising edge 
	clrf    TMR0                    ; Reset timer
	call    WaitForRise             ; find second rising edge
	movlw   D'1'
	addwf   TMR0,w		    	; Round timer0 up
	banksel SPBRG
	movwf   SPBRG                   ; set baud rate generator
	rrf     SPBRG,f                 ; divide by 2
	decf    SPBRG,f                 ; minus 1
	banksel Bank0    
	bsf     RCSTA, CREN             ; Start receiving
	movf    RCREG, W                ; Empty the buffer
	movf    RCREG, W
	return
	
WaitForRise:
	btfsc	PORT232, RXBitNum       ; Wait for a low on pin
	goto	WaitForRise
WtSR:
	btfss   PORT232, RXBitNum       ; Look for rising edge
	goto    WtSR
	return

SenseBreak:
; This is either a cal character or a break character
; We need to ensure that it is the Break
; A break will stay low for at least one Timer0 overflow
; At Fosc=4MHz and 16:1 prescale, this will be about 4 ms.
; 
	btfsc	PORT232,RXBitNum	; Wait for Break low
	goto	SenseBreak
SB10:	
	clrf	TMR0			; reset Timer0 for the count
	bcf	INTCON,T0IF		;
SB20:
	btfss	PORT232,RXBitNum	; look for Break trailing edge
	goto	SB20
	
	btfss	INTCON,T0IF		; not a break if no TMR0 overflow
	goto	SenseBreak		; keep looking for Break

	return				; end of Break detected
	
#else
; crystal Fosc has fixed stable baud rate
	banksel	SPBRG
	movlw	BaudRate
	movwf	SPBRG
	banksel	Bank0
	return
#endif		
#undefine	UARTInterface_M

	end
