	TITLE "PIC with Flash EE data memory Interface"
;
;       Program:          FL51XINC.ASM  V1.10
;       Revision Date:   
;                         09-09-97      Adapted to 12C51x parts
;			  01-Apr-1999	Added emulation hooks
;

; #define EMULATED    ; comment this line out for use on real part

; PIC12C51X EEPROM communication code.  This code should be included in
; with the application.  These routines provide the following functionality:
; write a byte to a specified address.
; read a byte from a specified address.
; read a byte from the next address.
;
; Emulation Requires:
;     MPLAB-ICE
;     PCM16XA0 processor module
;     DVA12XP80 Device Adapter.
; Define EMULATOR at the top of this file  (#define EMULATOR)
;     This will set the I2C_PORT, SDA and SCL lines to communicate over 
;     Port A, pins 0 and 1.  It also assembles in the necessary TRIS 
;     instructions to allow reading from the SDA line.
;
; To convert the code for the actual part, simply comment out the #define EMULATOR
; line and reassemble. 
;
; FL51XTST.ASM is also provided for linker users.
;
; INTRODUCTION:
; The Microchip 12c51x family of microntrollers are multichip modules 
; which contain a PIC12C508 microcontroller and a 24LC00 EEPROM.
; This application note is intended to provide users with highly compressed
; assembly code for communication between the EEPROM and the Microcontroller,
; which will leave the user a maximum amount of code space for the core 
; application.
;
;***************************************************************************
;***************************  EEPROM Subroutines  **************************
;***************************************************************************
; Communication for EEPROM based on I2C protocall, with Acknowledge.
;
; Byte_Write: Byte write routine
;       Inputs:  EEPROM Address   EEADDR
;                EEPROM Data      EEDATA
;       Outputs: Return 01 in W if OK, else return 00 in W
;
; Read_Current: Read EEPROM at address currently held by EE device. 
;       Inputs:  NONE
;       Outputs: EEPROM Data       EEDATA
;                Return 01 in W if OK, else return 00 in W
;
; Read_Random: Read EEPROM byte at supplied address
;       Inputs:  EEPROM Address    EEADDR
;       Outputs: EEPROM Data       EEDATA
;                Return 01 in W if OK, else return 00 in W
;
; Note: EEPROM subroutines will set bit 7 in PC_OFFSET register if the
;       EEPROM acknowledged OK, else that bit will be cleared.  This bit 
;       can be checked instead of refering to the value returned in W
;***************************************************************************

; OPERATION:
; For detailed operating information and other important information about 
; this code, see AN571.  This code was derived from AN571, with changes
; as appropriate for the specific hardware in the PIC12C51x parts.
;********************************************************************** 


;***************************************************************************
;***************************  Variable Listing  ****************************
;***************************************************************************
OK          EQU     01H
NO          EQU     00H

#ifdef	EMULATED
I2C_PORT    EQU     5		; Port A control register, used for I2C
SCL         EQU     01H         ; EEPROM Clock, SCL (I/O bit 7)
SDA         EQU     00H         ; EEPROM Data,  SDA (I/O bit 6)
#else
I2C_PORT    EQU     GPIO        ; Port B control register, used for I2C
SCL         EQU     07H         ; EEPROM Clock, SCL (I/O bit 7)
SDA         EQU     06H         ; EEPROM Data,  SDA (I/O bit 6)
#endif

EE_OK       EQU     07H         ; Bit 7 in PC_OFFSET used as OK flag for EE

	cblock 0x1A
PC_OFFSET		        ; PC offset register (low order 4 bits), 
				;  value based on operating mode of EEPROM.
				;  Also, bit 7 used for EE_OK flag
EEADDR    		        ; EEPROM Address
EEDATA      		        ; EEPROM Data
EEBYTE    		        ; Byte sent to or received from
				; EEPROM (control, address, or data)
COUNTER    		        ; Bit counter for serial transfer
	endc
        

;***************************************************************************
;***************************  EEPROM Subroutines  **************************
;***************************************************************************
; Communication for EEPROM based on I2C protocall, with Acknowledge.
;
; WRITE_BYTE: Byte write routine
;       Inputs:  EEPROM Address   EEADDR
;                EEPROM Data      EEDATA
;       Outputs: Return 01 in W if OK, else return 00 in W
;
; READ_CURRENT: Read EEPROM at address currently held by EE device. 
;       Inputs:  NONE
;       Outputs: EEPROM Data       EEDATA
;                Return 01 in W if OK, else return 00 in W
;
; READ_RANDOM: Read EEPROM byte at supplied address
;       Inputs:  EEPROM Address    EEADDR
;       Outputs: EEPROM Data       EEDATA
;                Return 01 in W if OK, else return 00 in W
;
; Note: EEPROM subroutines will set bit 7 in PC_OFFSET register if the
;       EEPROM acknowledged OK, else that bit will be cleared.  This bit 
;       can be checked instead of refering to the value returned in W
;***************************************************************************
;********************** Set up EEPROM control bytes ************************
;***************************************************************************
READ_CURRENT
	MOVLW   B'10000100'   ; PC offset for read current addr.  EE_OK bit7='1'
	MOVWF   PC_OFFSET     ; Load PC offset
	GOTO    INIT_READ_CONTROL

WRITE_BYTE
	MOVLW   B'10000000'   ; PC offset for write byte.  EE_OK: bit7 = '1'
	GOTO    INIT_WRITE_CONTROL

READ_RANDOM
	MOVLW   B'10000011'   ; PC offset for read random.  EE_OK: bit7 = '1'

INIT_WRITE_CONTROL
	MOVWF   PC_OFFSET     ; Load PC offset register, value preset in W
	MOVLW   B'10100000'   ; Control byte with write bit, bit 0 = '0'
  
START_BIT
	BCF     I2C_PORT,SDA  ; Start bit, SDA and SCL preset to '1'


;******* Set up output data (control, address, or data) and counter ********
;***************************************************************************
PREP_TRANSFER_BYTE
	MOVWF   EEBYTE        ; Byte to transfer to EEPROM already in W
	MOVLW   .8            ; Counter to transfer 8 bits
	MOVWF   COUNTER
#ifdef	EMULATED
	movlw	0x00		; make sure both are outputs
	tris	I2C_PORT
#endif


;************  Clock out data (control, address, or data) byte  ************
;***************************************************************************
OUTPUT_BYTE
        BCF     I2C_PORT,SCL  ; Set clock low during data set-up
        RLF     EEBYTE, F     ; Rotate left, high order bit into carry bit
        BCF     I2C_PORT,SDA  ; Set data low, if rotated carry bit is
        SKPNC                 ;   a '1', then:
        BSF     I2C_PORT,SDA  ; reset data pin to a one, otherwise leave low
	NOP
        BSF     I2C_PORT,SCL  ; clock data into EEPROM
        DECFSZ  COUNTER, F    ; Repeat until entire byte is sent
        GOTO    OUTPUT_BYTE
	NOP

;**************************  Acknowledge Check *****************************
;***************************************************************************
        BCF     I2C_PORT,SCL  ; Set SCL low, 0.5us < ack valid < 3us
	NOP
        BSF     I2C_PORT,SDA
#ifdef	EMULATED
    	movlw	(0x01 << SDA)	; make SDA an input
	tris	I2C_PORT
#endif
        GOTO	$+1             ; May be necessary for SCL Tlow  at low voltage,
        BSF     I2C_PORT,SCL  ; Raise SCL, EEPROM acknowledge still valid
        BTFSC   I2C_PORT,SDA  ; Check SDA for acknowledge (low)
        BCF     PC_OFFSET,EE_OK ; If SDA not low (no ack), set error flag
        BCF     I2C_PORT,SCL    ; Lower SCL, EEPROM release bus
        BTFSS   PC_OFFSET,EE_OK ; If no error continue, else stop bit
        GOTO    STOP_BIT
#ifdef	EMULATED
    	movlw	0x00		; SDA back to an output
	tris	I2C_PORT
#endif


;*****  Set up program counter offset, based on EEPROM operating mode  *****
;***************************************************************************
        MOVF    PC_OFFSET,W
        ANDLW   B'00001111'
        ADDWF   PCL, F
        GOTO    INIT_ADDRESS      ;PC offset=0, write control done, send address
        GOTO    INIT_WRITE_DATA   ;PC offset=1, write address done, send data
        GOTO    STOP_BIT          ;PC offset=2, write done, send stop bit
        GOTO    INIT_ADDRESS      ;PC offset=3, write control done, send address
        GOTO    INIT_READ_CONTROL ;PC offset=4, send read control
        GOTO    READ_BIT_COUNTER  ;PC offset=5, set counter and read byte
        GOTO    STOP_BIT          ;PC offset=6, random read done, send stop


;**********  Initalize EEPROM data (address, data, or control) bytes  ******
;***************************************************************************
INIT_ADDRESS
        INCF    PC_OFFSET, F ; Increment PC offset to 2 (write) or to 4 (read)
        MOVF    EEADDR,W     ; Put EEPROM address in W, ready to send to EEPROM
        GOTO    PREP_TRANSFER_BYTE


INIT_WRITE_DATA
        INCF    PC_OFFSET, F ; Increment PC offset to go to STOP_BIT next
        MOVF    EEDATA,W     ; Put EEPROM data in W, ready to send to EEPROM
        GOTO    PREP_TRANSFER_BYTE

INIT_READ_CONTROL
        BSF     I2C_PORT,SCL ; Raise SCL
	nop
        BSF     I2C_PORT,SDA ; raise SDA
        INCF    PC_OFFSET, F ; Increment PC offset to go to READ_BIT_COUNTER next
        MOVLW   B'10100001'  ; Set up read control byte, ready to send to EEPROM
        GOTO    START_BIT    ;   bit 0 = '1' for read operation


;**************************  Read EEPROM data  *****************************
;***************************************************************************
READ_BIT_COUNTER
        BSF     I2C_PORT,SDA
	NOP
        BSF     I2C_PORT,SCL ; set data bit to 1 so we're not pulling bus down.
        MOVLW   .8           ; Set counter so 8 bits will be read into EEDATA
        MOVWF   COUNTER
#ifdef	EMULATED
    	movlw	(0x01 << SDA)
	tris	I2C_PORT
#endif

READ_BYTE
        BSF     I2C_PORT,SCL ; Raise SCL, SDA valid.  SDA still input from ack
        SETC                 ; Assume bit to be read = 1
        BTFSS   I2C_PORT,SDA ; Check if SDA = 1
        CLRC                 ; if SDA not = 1 then clear carry bit
        RLF     EEDATA, F    ; rotate carry bit (=SDA) into EEDATA;
        BCF     I2C_PORT,SCL ; Lower SCL
        BSF     I2C_PORT,SDA ; reset SDA
        DECFSZ  COUNTER, F   ; Decrement counter
        GOTO    READ_BYTE    ; Read next bit if not finished reading byte

        BSF     I2C_PORT,SCL
        NOP
        BCF     I2C_PORT,SCL
;******************  Generate a STOP bit and RETURN  ***********************
;***************************************************************************
STOP_BIT
#ifdef	EMULATED
	movlw	0x00	; set SDA as output
	tris	I2C_PORT
#endif
        BCF     I2C_PORT,SDA ; SDA=0, on TRIS, to prepare for transition to '1' 
        BSF     I2C_PORT,SCL ; SCL = 1 to prepare for STOP bit
        GOTO	$+1          ; 4 NOPs neccessary for I2C spec Tsu:sto = 4.7us                  
	GOTO	$+1
        BSF     I2C_PORT,SDA ; Stop bit, SDA transition to '1' while SCL high
    
        BTFSS   PC_OFFSET,EE_OK ; Check for error
        RETLW   NO              ; if error, send back NO 
        RETLW   OK              ; if no error, send back OK

;Note: SDA and SCL still being driven by master, both set to outputs.
;****************************************************************************
;************************  End EEPROM Subroutines  **************************

