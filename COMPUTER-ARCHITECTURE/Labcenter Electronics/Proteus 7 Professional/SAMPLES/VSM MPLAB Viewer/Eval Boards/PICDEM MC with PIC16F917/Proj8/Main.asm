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
;*  Main.asm
;*  Monitor application example using the generic UARTInterface
;******************************************************************************
;*  Microchip Technology Incorporated
;*  
;*  Ver 1.00  24 March 2005
;*    Original code
;*
;******************************************************************************
;*
;*  Main application to call UARTMonitor and other applications.
;*
;******************************************************************************

#define	MAIN_H

	include	"UARTMonitor.h"

#undefine MAIN_H

;******************************************************************************
;*
;*	Start of code space
;*

STARTUP	code
	goto	Start
	
PROG	code
Start:
	call	MonitorInit
	
Main:
;******************************************************************************
;*
;*	Main loop - poll for RX and TX ready
;*
;******************************************************************************

	btfsc	Flags,TXON	;
	call	TxmtService	; send next character when TX is ready
	btfsc	PIR1,RCIF	;
	call	RcvService	; get and analyze received character 
	btfsc	Flags,MsgFlag	;
	call	CmdService	; process received message
	goto	Main		;

	end
