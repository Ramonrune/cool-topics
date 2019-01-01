; ###############################################################################
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
; ###############################################################################
;***************************************************************
;*
;*	File: UARTInterface.h
;*
;*	header file for the generic UART interface program
;*
;*	Modified: 
;*	Ver 1.00	10 March 2005
;*	  Original code
;*
;***************************************************************

	errorlevel -302


; Define the device and configuration
	include "Device.inc"

; Comment the following line out to use fixed baud rate
;#define ENABLE_AUTOBAUD

#ifdef	UARTInterface_M
; Global variables
	GLOBAL	Flags
	GLOBAL	RXChar
; Global routines	
	GLOBAL	UARTInit
	GLOBAL	TXService
	GLOBAL	RXService
	GLOBAL	PutTX
	GLOBAL	GetRX
	GLOBAL	ResetRXPointers
;	GLOBAL	Autobaud
#else
; External variables
	EXTERN	Flags
	EXTERN	RXChar
; External routines	
	EXTERN	UARTInit
	EXTERN	TXService
	EXTERN	RXService
	EXTERN	PutTX
	EXTERN	GetRX
	EXTERN	ResetRXPointers
	;EXTERN	Autobaud
#endif

#ifndef	UARTComm_H
#define UARTComm_H

;**********************************************************
;* 
;*	Define circular buffer space
;*

#define RXBuffSize	(0xF0-0xA0)/2
#define TXBuffSize	RXBuffSize

;**********************************************************
;* 
;*	Define serial communications control bits
;*

#define BaudRate	D'52' 		; SPBRG value for 9600 Baud when 
					;  Fosc=20MHz and BRGH=1
#define TXSTAInit	B'00100110'	; Asychronous, 8 bit, BRGH=1
#define RCSTAInit	B'10010000'	; Asychronous, 8 bit, continuous receive, serial enable

;**********************************************************
;* 
;* Define the serial IO bits
;* 

#define PORT232	 	PORTC
#define TRIS232		TRISC

#define RXBitNum	7
#define TXBitNum	6

#define RX		PORT232,RXBitNum	; receive pin
#define TX		PORT232,TXBitNum	; transmit pin

;**********************************************************
;* 
;* Define general purpose flag bits: register name Flags
;* 

#define Bank0	0x00

#define	MsgFlag		7 	; 1 = a message is in the RX buffer
#define BreakFlag	6	; 1 = a break was detected
#define EchoFlag	5	; 1 = all received characters will be echoed
#define TXON		4	; 1 = transmit enabled

#define TXCTRL		Flags	; in polled operation, Flags indicate TX ready

#define	CR		0x0D	; ASCII carriage return
#define	BS		0x08	; ASCII backspace
#define EC		0x1B	; ASCII escape

#endif
