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
;*  UARTMonitor.asm
;*  Monitor application example using the generic UARTInterface
;******************************************************************************
;*  Microchip Technology Incorporated
;*  
;*  Ver 1.00  24 March 2005
;*    Original code
;*
;******************************************************************************
;*
;*  Application to view and set SFRs and GPRs via the PC.
;*
;******************************************************************************

#define UARTMonitor_M

	include "UARTMonitor.h"

; Define command lookup keys according to table position

#define FirstCharKey	FirstCharIndex-MsgLookup
#define	VersionKey	VersionIndex-MsgLookup
#define	AddrKey		AddrIndex-MsgLookup
#define	ToggleEchoKey	ToggleEchoIndex-MsgLookup
#define	ShowMenuKey	ShowMenuIndex-MsgLookup
#define SrchForCRKey	SrchForCRIndex-MsgLookup

#define TXBuffKey	TXBuffIndex-TXLookup
#define	SendStringKey	SendStringIndex-TXLookup

;******************************************************************************
;*
;*	Variable definitions
;*

	UDATA_SHR

IndirAddr	res	1	; temporary storage for table pointer computation
	
DATA0	UDATA

CmdKey		res	1	; holds index into computed goto command sequence table
ByteWork	res	1	; work area for forming bytes from ASCII characters
B2HWork		res	1	; work area for binary to hex conversion
H2AWork		res	1	; work area for hex to ASCII conversion
Addr		res	1	; storage space for the set/send addr command
RXData		res	1	; storage space for the current command char
TXKey		res	1	; holds index into transmit command sequence table
StringKey	res	1	; holds index into string table
StringPC	res	1	; holds PCLATH for string table

;******************************************************************************
;*
;*	Additional flag definitions for this application
;*

#define	IBankFlag	0	; set/reset by first character in 3 char addr cmd
#define	ValidHexFlag	1	; set/cleared by TestValidHex routine

PROG	code	
MonitorInit:
	call	UARTInit
	call	AppInit
	call	NewLine
	return
	
AppInit:
;******************************************************************************
;*
;*	Initialize flags
;*
;******************************************************************************

	clrf	Flags
	bsf	Flags,EchoFlag	; default to echo on
	
	return

TxmtService:
;******************************************************************************
;*
;*	Send one character in the transmit buffer to the USART
;*	In some cases one character is also loaded into the transmit buffer.
;*
;******************************************************************************
	
; Test if transmit register is ready for another character
;  if not then abort service

	btfss	PIR1,TXIF	;
	return
	
;  Process the transmit buffer according to the next sequence step in TXKey
;  All table destinations return to calling routine

	movlw	HIGH TXLookup
	movwf	PCLATH
	movlw	LOW TXLookup
	addwf	TXKey,w
	btfsc	STATUS,C
	incf	PCLATH,f
	movwf	PCL

TXLookup:
TXBuffIndex:
	goto	TXService	; sends one character from TXBuffer to TXREG
SendStringIndex:
	goto	SendString	; sends the next string char to the TXBuffer

RcvService:
;******************************************************************************
;*
;*	Get character from RCREG and store in buffer.
;*	Perform immediate action of special characters BREAK and ESCAPE.
;*
;******************************************************************************
	
	call	RXService	; gets and buffers RCREG
	btfsc	Flags,BreakFlag	; was break detected?
	goto	ServiceBreak	; yes - immediate break service
				; destination returns to calling routine	
	movf	RXChar,w	; restore received character
	xorlw	EC		; was escape character received?
	btfsc	STATUS,Z	; zero if equal
	goto	ShowEscape	; yes - immediate escape service
				; destination returns to calling routine
	movf	RXChar,w	; restore received character				
	xorlw	0x7E		; is this end of test sequence?
	btfsc	STATUS,Z	; zero if equal
	goto	ResetRXTX	; yes - immediate reset

	return			; no immediate actions - return to main loop

CmdService:
;******************************************************************************
;*
;*	Interpret the command in the RX buffer. All messages are terminated
;*	by a CR.
;*
;******************************************************************************

; Get one character from the buffer and decode it.

	call	GetRX	
	movwf	RXData		; save it
	
;  Process the message according to the next sequence step in CmdKey
;  All table destinations return to calling routine

	movlw	HIGH MsgLookup
	movwf	PCLATH
	movlw	LOW MsgLookup
	addwf	CmdKey,w
	btfsc	STATUS,C
	incf	PCLATH,f
	movwf	PCL

MsgLookup:
FirstCharIndex:
	goto	DecodeFirstChar		
VersionIndex:				; first step in Version command
	goto	SendVersion		; second step in Version command
ShowMenuIndex:				; first step in Version command
	goto	ShowMenu		; second step in Show menu command
AddrIndex:
	goto	DecodeIBank		; IBank bit of Addr
	goto	DecodeMSNyb		; MS Nybble of Addr
	goto	DecodeLSNyb		; LS Nybble of Addr
	goto	SendAddrData		; if CR detected then send data at address
					;  else if '=' then input byte to set data
	goto	DecodeMSNyb		; Ms Nybble of Data
	goto	DecodeLSNyb		; LS Nybble of Data
	goto	SetAddrData		; validate and set Addr with Data received	
SrchForCRIndex:				; default when invalid command detected
	goto	SrchForCR		;  repeats until CR detected
ToggleEchoIndex:
	goto	ToggleEcho		; toggle echo on/off on E command

DecodeFirstChar:
;******************************************************************************
;*
;*	Interpret first character in the message
;*
;******************************************************************************

; If the first character is a CR then ignore the decode sequence
; and respond with a prompt

	movf	RXData,w
	xorlw	CR
	btfsc	STATUS,Z
	goto	SendPrompt	; CR detected - follow with a prompt
				; destination returns to calling routine
	
; If the first character is a V then setup to decode the version
; command sequence

	movf	RXData,W
	xorlw	'V'
	movlw	VersionKey
	btfsc	STATUS,Z
	goto	CmdDetected

; If the first character is an A then setup to decode the 
; Alter Memory command sequence

	movf	RXData,W
	xorlw	'A'
	movlw	AddrKey
	btfsc	STATUS,Z
	goto	CmdDetected

; If the first character is an E then setup to decode the 
; Toggle Echo command sequence

	movf	RXData,W
	xorlw	'E'
	movlw	ToggleEchoKey
	btfsc	STATUS,Z
	goto	CmdDetected

; If the first character is a ? then setup to decode the 
; Show menu command sequence

	movf	RXData,W
	xorlw	'?'
	movlw	ShowMenuKey
	btfsc	STATUS,Z
	goto	CmdDetected

IgnoreSeq:
; If the character is not valid then ignore all other characters

	movlw	SrchForCRKey

CmdDetected:
; Command detected, put the next decode sequence step in the CmdKey

	movwf	CmdKey
	return
		
SrchForCR:
;******************************************************************************
;*
;*	Ignore everything in the RX buffer except a CR.
;* 	When the CR is found, setup to send a prompt.
;*
;******************************************************************************

	movf	RXData,w
	xorlw	CR
	btfss	STATUS,Z
	return
	
	goto	SendPrompt	; CR detected - follow with the prompt
				; destination returns to calling routine

DecodeIBank:
;******************************************************************************
;*
;*	The first character in an address command is the upper/lower
;*	bank select. This routine determines if the character is valid
;*	and, if so, which bank is selected.
;*
;******************************************************************************

	incf	CmdKey,f	; next step in command sequence

	movf	RXData,w	; restore input character
	xorlw	A'1'		; is character a 1?
	btfsc	STATUS,Z		;
	goto	SetIBank	; yes - set IBank to 1
	
	movf	RXData,w	; restore input character
	xorlw	A'0'		; is character a 0?
	btfsc	STATUS,Z		;
	goto	ClearIBank	; yes - set IBank to 0
	
	goto	IgnoreSeq	; no - ignore all other entries
				; destination returns to calling routine

SetIBank:			; ninth bit of FSR access
	bsf	Flags,IBankFlag	; set the IBank bit
	return			;

ClearIBank:			; ninth bit of FSR access
	bcf	Flags,IBankFlag	; clear the IBank bit
	return

DecodeNybble:
;******************************************************************************
;*
;*	Decodes the ASCII character representing the Nybble of a byte.
;*	The hex nybble is returned in W.
;*	Invalid ASCII characters will trigger the command state machine
;*	to ignore the rest of the command. 
;*
;******************************************************************************

	call	TestValidHex	; allow only valid hex character here
	btfss	Flags,ValidHexFlag ; flag is set if RXData is valid
	return			; ignore conversion if not valid hex

	movf	RXData,w	; retrieve from input buffer
	goto	Ascii2Hex	; convert to hex nybble
				; destination returns to calling routine

DecodeMSNyb:
;******************************************************************************
;*
;*	Decodes the ASCII character representing the MS Nybble of a byte
;*	and stores it for combination with the Ls Nybble later.
;*	Invalid ASCII characters will trigger the command state machine
;*	to ignore the rest of the command.
;*
;******************************************************************************

	call	DecodeNybble	; convert the ASCII char in RXChar to hex
	btfss	Flags,ValidHexFlag ; flag is set if RXChar is valid
	goto	IgnoreSeq	; ignore command sequence if not valid hex
				; destination returns to calling routine

	movwf	ByteWork	; save converted character in work space
	incf	CmdKey,f	; next command in sequence
	return

DecodeLSNyb:
;******************************************************************************
;*
;*	Decodes the ASCII character representing the LS Nybble of a byte
;*	and combines it with a previously decoded MS Nybble.
;*	Invalid ASCII characters will trigger the command state machine
;*	to ignore the rest of the command.
;*
;******************************************************************************

	call	DecodeNybble	; convert the ASCII char in RXChar to hex
	btfss	Flags,ValidHexFlag ; flag is set if RXChar is valid
	goto	IgnoreSeq	; ignore command sequence if not valid hex
				; destination returns to calling routine

	swapf	ByteWork,f	; flip nybbles in workspace
	iorwf	ByteWork,f	; merge with second nybble

	incf	CmdKey,f	; next command in sequence
	return

SetAddrData:
;******************************************************************************
;*
;*	Verify that the last character is a CR and if so then set the
;*	previoulsly decoded address stored in Addr to the previously decoded 
;*	data which is stored in ByteWork.
;*	If the last character is not a CR then ignore the present command
;*	and all other characters until a CR is received.
;*
;******************************************************************************

; Validate command sequence by verifying that last character is a CR

	movf	RXData,w	;
	xorlw	CR		;
	btfss	STATUS,Z	;
	goto	IgnoreSeq	; ignore entire sequence if CR not detected
				; destination returns to calling routine

; Restore the decoded address and set FSR

	movf	Addr,w		; restore target address
	movwf	FSR		; set SFR/GPR pointer

; Set the 9th SFR/GPR address bit

	bsf	STATUS,IRP	; preload bank select bit with 1
	btfss	Flags,IBankFlag	; is IBank select bit set?
	bcf	STATUS,IRP	; no - clear bank select bit

	movf	ByteWork,w	; restore data byte
	movwf	INDF		; set file
	goto	SendPrompt	; terminate command with new line sequence
				; destination returns to calling routine

SendAddrData:
;******************************************************************************
;*
;*	If RXData is a CR then the two ASCII characters that represent
;*	the MS and LS nybbles of the address previously decoded in the first 
;*	part of the command are created and sent to the TX buffer.
;*	If RXData is an '=' then return an continue to decode the command.
;*
;******************************************************************************

	movf	ByteWork,w	; save in preparation for possible
	movwf	Addr		;  Set Addr Command
	incf	CmdKey,f	; next command in sequence
	movf	RXData,w	; 
	xorlw	'='		; is request to set address data?
	btfsc	STATUS,Z
	return			; yes - return to continue decode

	movf	RXData,w	; 
	xorlw	CR		; is request to send address data?
	btfss	STATUS,Z
	goto	IgnoreSeq	; no - ignore command sequence
				; destination returns to calling routine
	
	movf	ByteWork,w	; restore target address
	movwf	FSR		; set pointer to target address
	bsf	STATUS,IRP	; preload ibank control bit with 1
	btfss	Flags,IBankFlag	; is IBank select bit set?
	bcf	STATUS,IRP	; no - clear ibank control bit

	movf	INDF,w		; get the target byte
	call	Bin2Hex		; convert to two character ascii for TX

	goto	NewLine		; terminate command with new line sequence
				; destination returns to calling routine
	
Bin2Hex
;************************************************************************
;*
;*	Convert the byte in W to two ascii characters which are
;*	stuffed into the TX buffer 
;*
	banksel B2HWork
	movwf	B2HWork		; save byte in work register
	swapf	B2HWork,w	; ms nybble in W
	andlw	H'0F'		; clear ms nybble
	call	Hex2Ascii	; convert to ascii
	call	PutTX		; transmit it

	banksel B2HWork
	movf	B2HWork,w	; restore byte
	andlw	H'0F'		; clear ms nybble
	call	Hex2Ascii	; convert to ascii
	goto	PutTX		; transmit it and return to calling routine
	
Hex2Ascii
;************************************************************************
;*
;*	Adjust the nybble in W to represent the ascii equivalent
;*
	banksel	H2AWork
	movwf	H2AWork		; save W
	sublw	H'9'		; subtract W from test value
	movf	H2AWork,w	; restore W
	btfss	STATUS,C	; carry is 0 if W is > 9
	addlw	A'A'-A'9'-1	; pre boost to A thru F range
	addlw	A'0'		; ascii adjust
	banksel	PORTA
	return

Ascii2Hex
;************************************************************************
;*
;*	Adjust the (hex) ascii in W to the hex equivalent. Result is
;*	stored in the ls nybble of W.
;*	(hex) Ascii is 0 thru 9 and A thru F. Non-Ascii characters
;*	will also be converted and the result will a garbage nybble
;*	Lower case letters are converted to upper case

	banksel	H2AWork
	movwf	H2AWork		; save W
	sublw	A'a'-1		; test lower case
	btfsc	STATUS,C	; carry is clear if w is >= 'a'
	goto	A2H20		; it's not - skip conversion

	movlw	A'a'-A'A'	; lower case offset in W
	subwf	H2AWork,f	; subtract offset from workspace

A2H20
	movf	H2AWork,w	; restore W
	sublw	A'9'		; subtract W from test value
	movf	H2AWork,w	; restore W
	btfss	STATUS,C	; carry is 0 if W is > '9'
	addlw	-(A'A'-A'9'-1)	; pre adjust for A thru F range
	addlw	-(A'0')		; subtract out ascii offset
	andlw	H'0F'		; clear upper nybble
	banksel	PORTA
	return

TestValidHex:
;************************************************************************
;*
;*	Determine if the character in RXChar is within the following
;*	ranges: 
;*
;*	0 <= RXData <=9 or A <= RXData <= F or a <= RXData <= f
;*
;*	If it is then set the ValidHexFlag otherwise reset
;*	the flag.
;*
	movf	RXData,w	; restore received character
	sublw	A'0'-1		; subtract RXChar from '0'-1
	btfsc	STATUS,C	; CARRY = 0 if RXChar > '0'-1
	goto	NotValidHex	; not valid - return with flag reset

	movf	RXData,w	; restore received character
	sublw	A'9'		; subtract RXChar from '9'
	btfsc	STATUS,C	; CARRY = 1 if RXChar <= '9'
	goto	ValidHex	; OK - RXChar is between 0 and 9

	movf	RXData,w	; restore received character
	sublw	A'A'-1		; subtract RXChar from 'A'-1
	btfsc	STATUS,C	; CARRY = 0 if RXChar > 'A'-1
	goto	NotValidHex	; not valid - return with flag reset

	movf	RXData,w	; restore received character
	sublw	A'F'		; subtract RXChar from 'F'
	btfsc	STATUS,C	; CARRY = 1 if RXChar <= 'F'
	goto	ValidHex	; OK - RXChar is between A and F

	movf	RXData,w	; restore received character
	sublw	A'a'-1		; subtract RXChar from 'a'-1
	btfsc	STATUS,C	; CARRY = 0 if RXChar > 'a'-1
	goto	NotValidHex	; not valid - return with flag reset

	movf	RXData,w	; restore received character
	sublw	A'f'		; subtract RXChar from 'f'
	btfsc	STATUS,C	; CARRY = 1 if RXChar <= 'f'
	goto	ValidHex	; OK - RXChar is between a and f

NotValidHex
	bcf	Flags,ValidHexFlag ;
	return			;
ValidHex
	bsf	Flags,ValidHexFlag ;
	return			;

ResetRXTX:
;******************************************************************************
;*
;*	Reset the RX and TX buffer pointers.
;*	Reset the receive and transmit state machines.
;*
;******************************************************************************

	call	ResetRXPointers		;
	bcf	Flags,BreakFlag		;
	movlw	FirstCharKey		; reset the command lookup index
	movwf	CmdKey
	movlw	TXBuffKey		; reset the transmit service index
	movwf	TXKey
	return

ShowEscape:
;******************************************************************************
;*
;*	Reset the RX buffer pointers.
;*	Stuff the ESC string in the TXBuffer and send it.
;* 	Follow with a new line and prompt.
;*
;******************************************************************************

	call	ResetRXPointers		;
	movlw	low ESCDataTable	; set table pointer
	movwf	IndirAddr		;
	movlw	high ESCDataTable	; set upper PC bits for table indexing
	goto	StartString		; destination returns to calling routine

ServiceBreak:
;******************************************************************************
;*
;*	Reset the buffer pointers, reset the receive and transmit
;*	state machine pointers, and clear the Break flag.
;*	If autobaud enabled, call Autobaud to recalibrate the baud rate,
;*      otherwise display BREAK message.
;*
;******************************************************************************

#ifdef 	ENABLE_AUTOBAUD	
	call	ResetRXTX	;
	goto	Autobaud	; recalibrate baud rate
				; return to calling routine through destination
#else
	call	ResetRXPointers		;
	bcf	Flags,BreakFlag		;
	movlw	low BreakDataTable	; set table pointer
	movwf	IndirAddr		;
	movlw	high BreakDataTable	; set upper PC bits for table indexing
	goto	StartString		; destination returns to calling routine
BreakDataTable:
	DT	CR,"BREAK",0
#endif						
	
ToggleEcho:
;******************************************************************************
;*
;*	Verify that command is terminated with a CR.
;*	Toggle the EchoFlag on/off
;*
;******************************************************************************

; Validate command sequence by verifying that last character is a CR

	movf	RXData,w		;
	xorlw	CR			;
	btfss	STATUS,Z		;
	goto	IgnoreSeq		; ignore command if CR not detected

	movlw	1<<EchoFlag
	xorwf	Flags,f
	
	btfss	Flags,EchoFlag
	goto	ShowEchoOff		; 
	goto	ShowEchoOn		; 

ShowEchoOff:
;******************************************************************************
;*
;*	Stuff the echo off string in the TXBuffer and send it
;*
;******************************************************************************

	movlw	low EchoOffTable	; set table pointer
	movwf	IndirAddr		;
	movlw	high EchoOffTable	; set upper PC bits for table indexing
	goto	StartString

ShowEchoOn:
;******************************************************************************
;*
;*	Stuff the echo on string in the TXBuffer and send it
;*
;******************************************************************************

	movlw	low EchoOnTable		; set table pointer
	movwf	IndirAddr		;
	movlw	high EchoOnTable	; set upper PC bits for table indexing
	goto	StartString

ShowMenu:
;******************************************************************************
;*
;*	Verify that command is terminated with a CR.
;*	Stuff the menu string in the TXBuffer and send it
;*
;******************************************************************************

; Validate command sequence by verifying that last character is a CR

	movf	RXData,w		;
	xorlw	CR			;
	btfss	STATUS,Z		;
	goto	IgnoreSeq		; ignore command if CR not detected

	movlw	low MenuDataTable	; set table pointer
	movwf	IndirAddr		;
	movlw	high MenuDataTable	; set upper PC bits for table indexing
	goto	StartString

SendVersion:
;******************************************************************************
;*
;*	Verify that command is terminated with a CR.
;*	Stuff the version string in the TXBuffer and send it
;*
;******************************************************************************

; Validate command sequence by verifying that last character is a CR

	movf	RXData,w		;
	xorlw	CR			;
	btfss	STATUS,Z		;
	goto	IgnoreSeq		; ignore command if CR not detected

	movlw	low VersionDataTable	; set table pointer
	movwf	IndirAddr		;
	movlw	high VersionDataTable	; set upper PC bits for table indexing
	goto	StartString
		
StartString:
;******************************************************************************
;*
;*	Enter with the target string PCLATH in W.
;*	Initializes the transmit state table key and starts the string
;*	transmission by sending the first character.
;*
;******************************************************************************

	movwf	StringPC		; save target string PCLATH
	movlw	SendStringKey		;
	movwf	TXKey			;
	goto	SendString		; generic transmit table routine
					; destination returns to calling routine
	
NewLine:
;******************************************************************************
;*
;*	Same as SendPrompt except the prompt character is preceeded by
;*	a CR. This routine falls through to SendPrompt.
;*
;******************************************************************************

	movlw	CR
	call	PutTX
	
SendPrompt:
;******************************************************************************
;*
;*	Reset the CmdKey for first characer decoding then
;*	put the prompt character in W and return through PutTX.
;*
;******************************************************************************

; reset CmdKey for first character decoding

	movlw	FirstCharKey		; reset the command lookup index
	movwf	CmdKey
	movlw	TXBuffKey		; reset the transmit service index
	movwf	TXKey

	movlw	'>'			; prompt character in W
	goto	PutTX			; return through TX buffer routine

SendString:
;******************************************************************************
;*
;*	Send one character of the string at IndirAddr to the TXREG
;*
;******************************************************************************

	movf	StringPC,w		; restore PCLATH for string
	movwf	PCLATH			;
	movf	IndirAddr,w		; restore the table index
	call	ReadTable		; call table read
	addlw	0			; test for zero termination
	btfsc	STATUS,Z		; 
	goto	NewLine			; zero - transfer is complete

	call	PutTX			; put it in the TX buffer
	call	TXService		; transmit one buffer character
	incfsz	IndirAddr,f		; update table pointer
	return				; loop back

	incf	StringPC,f		; adjust for table address wrap
	return				; loop back

ReadTable
	movwf	PCL

VersionDataTable
	DT	"UART Mac 0.4",0
ESCDataTable
	DT	CR,"ESC",0
MenuDataTable
	DT	CR,"Axxx    : View addr xxx"
	DT	CR,"Axxx=yy : Change addr xxx to yy"
	DT	CR,"V       : Show version"
	DT	CR,"E       : Toggle echo off/on"
	DT	CR,"<esc>   : Abort command"
	DT	CR,"<bkspc> : Remove last character"	
	DT	CR,"?       : Show menu",0
EchoOffTable
	DT	CR,"Echo Off",0
EchoOnTable	
	DT	CR,"Echo On",0		

#undefine UARTMonitor_M

	end
	
