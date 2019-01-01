;Software License Agreement                                         
;                                                                    
;The software supplied herewith by Microchip Technology             
;Incorporated (the "Company") is intended and supplied to you, the  
;Company’s customer, for use solely and exclusively on Microchip    
;products. The software is owned by the Company and/or its supplier,
;and is protected under applicable copyright laws. All rights are   
;reserved. Any use in violation of the foregoing restrictions may   
;subject the user to criminal sanctions under applicable laws, as   
;well as to civil liability for the breach of the terms and         
;conditions of this license.                                        
;                                                                    
;THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,  
;WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED  
;TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A       
;PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,  
;IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR         
;CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.   
;**********************************************************************
;
;	Filename:	00010R1.asm
;	Date:		  12/23/2004 day, 2004
;	Version:	1.0
;
;	Author:		Pat Richards
;	Company:	Microchip Technology Inc.
;                                                                     
;                                                                     
;**********************************************************************
;	Description:
;	This is the source code for AN972
; Refer to 00010R1.lkr for details on the linker script  
; 	
;**********************************************************************
;	Revision History: none
;
;**********************************************************************

	#include <p10F202.inc>        ; processor specific variable definitions
;	#include <p10F206.inc>        ; processor specific variable definitions

	__CONFIG   _MCLRE_OFF & _WDT_ON & _IntRC_OSC 

; '__CONFIG' directive is used to embed configuration word within .asm file.
; The lables following the directive are located in the respective .inc file.
; See data sheet for additional information on configuration word settings.

;************************** VARIABLE DEFINITIONS ******************************
  UDATA
Addr        RES   1 ;
DataByte    RES   1 ;
BitCount    RES   1 ;
TempData    RES   1 ;
SerOutData  RES   1 ;
ReadData    RES   1 ; Used to hold serial out data (and can be used to test ACK)
ACKStat     RES   1 ; Holds ACK status. 0 = NACK, 1 = ACK
OldSwitch   RES   1 ; Serial mode 1 = SPI, 0 = I2C
NewSwitch   RES   1 ; Serial mode 1 = SPI, 0 = I2C
n           RES   1 ;
RAMTRIS			RES   1 ; this is a baseline part so have to create
      					    ; own tris register in RAM to keep track of
			      		    ; input and output pins (very important!)

;*************************** DEFINE STATEMENTS ********************************

;; Flag Bit (FlagReg) definitions
#define SerMode   0x00

;; pin definitions
#define	SCL GPIO,0
#define	SCK GPIO,0
#define	nCS GPIO,1    ; Note: will drive both states of nCS
#define	SDA GPIO,2
#define	SI  GPIO,2
#define	SO  GPIO,3

;; MCP23x08 registers
#define IODIR   0x00
#define IPOL    0x01
#define GPINTEN 0x02
#define DEFVAL  0x03
#define INTCON  0x04
#define IOCON   0x05
#define GPPU    0x06
#define INTF    0x07
#define INTCAP  0x08
#define MCPGPIO 0x09
#define OLAT    0x0A


;; GP3 = SI, GP2 = SDA/SO, GP1 = CS, GP0 = SCL/SCK
;; Will modify TRIS register and not GPIO directly
#define	SCL_L		b'11111110'	; AND with this to make SCL an output
#define SCL_H		b'00000001'	; IOR with this to make SCL an input
#define	SDA_L   b'11111011'	; AND with this to make SDA an output
#define	SDA_H   b'00000100'	; IOR with this to make SDA an input

#define	SCK_L		b'11111110'	; AND with this to make SCK an output
#define SCK_H		b'00000001'	; IOR with this to make SCK an input
#define	SI_L    b'11111011'	; AND with this to make SI an output
#define	SI_H    b'00000100'	; IOR with this to make SI an input

#define	CS_OUT  b'11111101'	; AND with this to make CS an output
#define	CS_IN   b'00000010'	; IOR with this to make CS an input

;; I2C Commands/Opcodes
#define OPCODE    0x40
#define WRITECMD  0
#define READCMD   1
#define AnPINS    b'0000'  ; A2, A1, A0 pins (Shift left by one. A2,A1,A0,X)

;****************************** START OF CODE *********************************
RESET_VECTOR CODE
	goto  Start

;******************************************************************************
;*************************** MAIN  CODE ***************************************
;******************************************************************************
MAIN  CODE
;******************************************************************************
; Start - 
; InitPIC
; Set Mode to I2C
; Init23008
; Set Mode to SPI
; Init23S08
; Check toggle switch
;   Set proper serial mode
;   Make other device all inputs
; Read GP inputs
; Drive outputs to match inputs
; goto Check Toggle Switch
;****************************************************************************** 
Start
;	movlw	0x40 	
	movwf OSCCAL		; load the factory oscillator calibration value

;******************************************************************************
; InitPIC - Initialize PIC
;
;******************************************************************************
InitPIC
;Remove next two lines for PIC10F202 (uncomment for PIC10F206)
;  movlw 0xF1
;  movwf CMCON0
  movlw 0x02          ; Note: CS (GP1) needs to drive H and L due to selector switch resistors
  movwf GPIO          ; Clear latches.. will operate on tris for I2C and SPI (except nCS pin)
  movlw b'00001101'	  ; SI, SDA/SO, CS, SCL/SCK
  movwf RAMTRIS
  tris  GPIO
  movlw b'11001101'   ; 1:64TMR0 prescaler: 1E-6 x 256 x 64 = 16.38 ms, weak pullups disabled
  option
  clrwdt              ; Clear the watchdog timer

  ;*** Init23008
	;*** First clock out 8-bits, No ACK, and then stop to make sure device
	;    is not locked up
  movlw 0xFF            ; Set TempData all '1's to make SDA an input
  movwf TempData        ; so can read the data
  call  I2CClockByte    ; Data is now in ReadData variable
  call  NoACK
  call  I2CStop
  
I2CWriteIODIR
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xFF              ; Initially make all inputs (which is default anyway)
  movwf DataByte
  call  I2CByteWrite      ; Call I2C Byte Write

  ;*** Now verify that the register was correctly written
  movlw IODIR             ; Load Addr
  movwf Addr
  call  I2CByteRead
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  I2CWriteIODIR     ; Otherwise, try again

  ;*** Init23S08
SPIWriteIODIR
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xFF              ; Make all inputs
  movwf DataByte
  call  SPIByteWrite      ; Write byte

  ;*** Now verify that the register was correctly written
  call  SPIByteRead       ; Read byte
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  SPIWriteIODIR

CheckToggleSwitch
  clrwdt                  ; Clear the watchdog timer
  ;*** Set CS = Input (will pull to switch value) (0 = SPI, 1 = I2C)
  movf	RAMTRIS,w
  iorlw	CS_IN             ; make an input 
  movwf	RAMTRIS
  tris	GPIO
  nop
  nop
  nop
  nop

  movf  NewSwitch,w       ; Move to OldSwitch
  movwf OldSwitch
  
  btfss nCS               ; I2C mode if SET, SPI mode if CLEAR
  goto  SetSwitchSPI
  goto  SetSwitchI2C

SetSwitchSPI
  ;*** Set CS = HIGH
  movf	RAMTRIS,w
  andlw	CS_OUT            ; make an output
  movwf	RAMTRIS
  tris	GPIO
  movlw 0x02              ; Need to drive nCS high
  movwf GPIO              ;

  movlw 0x00
  movwf NewSwitch
  xorwf OldSwitch,w       ;
  btfss STATUS,Z          ; Skip if switches differ
  goto  SetSPIMode        ; Need to make I2C device all inputs first
  goto  SPILoop           ; Can jump straight to SPI routines
  
SetSwitchI2C
  ;*** Set CS = HIGH so SPI device is not disturbed if switch is flipped
  ;    during I2C operation
  movf	RAMTRIS,w
  andlw	CS_OUT            ; make an output
  movwf	RAMTRIS
  tris	GPIO
  movlw 0x02              ; Need to drive nCS high
  movwf GPIO              ;

  movlw 0x01
  movwf NewSwitch
  xorwf OldSwitch,w       ;
  btfss STATUS,Z          ; Skip if switches differ
  goto  SetI2CMode        ; Need to make SPI device all inputs first
  goto  I2CLoop           ; Can jump straight to I2C routines

;*** IF SWITCHED TO I2C MODE ***
;*******************************
SetI2CMode
  ;*** First make the other device all inputs
SPIWriteIODIR_1
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xFF              ; Make all inputs
  movwf DataByte
  call  SPIByteWrite      ; Write byte

  ;*** Now verify that the register was correctly written
  call  SPIByteRead       ; Read byte
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  SPIWriteIODIR_1

  ;***Now configure the I/O
I2CLoop
I2CWriteIODIR_2
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xF0              ; GP7:4 = Inputs; GP3:0 = Outputs
  movwf DataByte
  call  I2CByteWrite      ; Call I2C Byte Write

  ;*** Now verify that the register was correctly written
  call  I2CByteRead
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  I2CWriteIODIR_2   ; Otherwise, try again
  
  ;*** Read Inputs (I2C)
  movlw MCPGPIO           ; Load Addr
  movwf Addr
  call  I2CByteRead       ; Data will be stored in "ReadData"
  movf  ReadData,w        ; Move Read data...
  movwf DataByte          ; into the write data

  ;*** Set outputs to match inputs
  swapf DataByte,f        ; Swap nibbles so switch data can be written to LEDs
  movlw OLAT              ; Load Addr
  movwf Addr
  call  I2CByteWrite      ; Call I2C Byte Write ("DataByte" is already loaded);

  ;*** Start Over
  goto  CheckToggleSwitch ; Start over
  

;*** ELSE IF SWITCHED TO SPI MODE ***
;************************************
SetSPIMode  
;*** First make the other device all inputs
I2CWriteIODIR_1
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xFF              ; Initially make all inputs (which is default anyway)
  movwf DataByte
  call  I2CByteWrite      ; Call I2C Byte Write

  call  I2CByteRead
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  I2CWriteIODIR_1   ; Otherwise, try again
  
SPILoop
  ;*** Now configure the I/O
SPIWriteIODIR_2
  movlw IODIR             ; Load Addr
  movwf Addr
  movlw 0xF0              ; GP7:4 = Inputs; GP3:0 = Outputs
  movwf DataByte
  call  SPIByteWrite      ; Write byte

  call  SPIByteRead       ; Read byte
  movf  DataByte,w        ; Load data written to be
  xorwf ReadData,w        ; compared to data read
  btfss STATUS,Z          ; If the same, skip
  goto  SPIWriteIODIR_2

  ;*** Read Inputs (SPI)
  movlw MCPGPIO           ; Load Addr
  movwf Addr
  call  SPIByteRead       ; Data will be stored in "ReadData"
  movf  ReadData,w        ; Move Read data...
  movwf DataByte          ; into the write data
  
  swapf DataByte,f        ; Swap nibbles so switch data can be written to LEDs

  ;*** Set outputs to match inputs
  movlw OLAT              ; Load Addr
  movwf Addr
  call  SPIByteWrite      ; Call I2C Byte Write ("DataByte" is already loaded);

  ;*** Start Over
  goto  CheckToggleSwitch ; Start over


;******************************************************************************
;***************************** SUBROUTINES CODE *******************************
;******************************************************************************
SUBROUTINES CODE
;****************************** I2C Routines **********************************
;******************************************************************************
; I2CByteWrite - Writes an I2C byte
; OPCODE w/ An pins (R/W = 0)
; ADDR
; Write Data 
;******************************************************************************
I2CByteWrite
  call  I2CStart

  ;*** OPCODE
  movlw OPCODE          ; Load Opcode
  iorlw AnPINS          ; IOR An pins
  movwf TempData        ; Place in data byte
  movlw WRITECMD        ; Write command
  iorwf TempData, 1     ; IOR write command and place results in TempData
  call  I2CClockByte
  
  call  IsACK?

  ;*** Address
  movf  Addr,w          ; Load Address
  movwf TempData        ; Place in data byte
  call  I2CClockByte
  
  call  IsACK?

  ;*** Data
  movf  DataByte,w      ; Load Data (was configured outside of subroutine)
  movwf TempData        ; Place in data byte
  call  I2CClockByte

  call  IsACK?
  call  I2CStop
  
  retlw 0

;******************************************************************************
; I2CByteRead - Reads an I2C byte
; S
; OPCODE w/ An pins (R/W = 0)
; ADDR
; ReStart
; OPCODE w/ An pins (R/W = 1)
; Read Data
;******************************************************************************
I2CByteRead
  call  I2CStart

  ;*** OPCODE (R/W = 0)
  movlw OPCODE          ; Load Opcode
  iorlw AnPINS          ; IOR An pins
  movwf TempData        ; Place in data byte
  movlw WRITECMD        ; WRITE command
  iorwf TempData, 1     ;IOR write command and place results in TempData
  call  I2CClockByte
  
  call  IsACK?

  ;*** Address
  movf  Addr,w          ; Load Address
  movwf TempData        ; Place in data byte
  call  I2CClockByte
  
  call  IsACK?

  call  I2CStart        ; ReStart

  ;*** OPCODE (R/W = 1)
  movlw OPCODE          ; Load Opcode
  iorlw AnPINS          ; IOR An pins
  movwf TempData        ; Place in data byte
  movlw READCMD         ; READ command
  iorwf TempData, 1     ; IOR write command and place results in TempData
  call  I2CClockByte
  
  call  IsACK?
  
  ;*** Read data
  clrf  ReadData

  movlw 0xFF            ; Set TempData all '1's to make SDA an input
  movwf TempData        ; so can read the data
  call  I2CClockByte    ; Data is now in ReadData variable
  
  call  NoACK
  call  I2CStop

  retlw 0

;******************************************************************************
; I2CClockByte - Clocks a byte.
;******************************************************************************
I2CClockByte
  movlw	  0x08          ; For looping on 1 byte
  movwf   BitCount
NextBit                 ; Loop through data
  rlf     TempData,f	  ; Else, shift bits through C bit. MSB first, Note TempData is lost
  goto    I2CClockBit
ContinueI2C
  decfsz  BitCount,f
  goto    NextBit       ; END of loop
  
  retlw 0


;******************************************************************************
; I2CClockBit - Clock a bit MCP23008 (I2C)
; W reg contains data bit level
; Set SDA level
; SCL = HIGH
; SCL = LOW
;
; This is not actually a subroutine, however, it was split from the
; I2CClockByte routing for clarity.
;******************************************************************************
I2CClockBit
  btfsc	STATUS,C        ; Check if a '1' or '0'
  goto  SDAHigh

SDALow
  ;*** Either Set SDA = LOW
  movf	RAMTRIS,w
  andlw	SDA_L		        ; make SDA an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO			
  goto  PulseSCL

SDAHigh
  ;*** OR Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		        ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

PulseSCL
  ;*** Set clock = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		        ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

	;*** First check SDA value (this is for I2C reads)
  movlw 0               ; Check status of SDA pin
  btfsc SDA             ; Make sure SDAbit is cleared by the calling routine first
  movlw 1
  bcf   STATUS,C
  rlf   ReadData,f      ; Shift left by one bit (for next time through)
  addwf ReadData,f      ; Place value into variable

  ;*** Set clock = LOW
  movf	RAMTRIS,w
  andlw	SCL_L		        ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  goto  ContinueI2C

;******************************************************************************
; I2CStart - Send a START bit MCP23008 (I2C)
; SCL = LOW
; SDA = HIGH
; SCL = HIGH
; SDA = LOW
;******************************************************************************
I2CStart
  ;*** Set SCL = LOW ...Just in case it is not already
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		      ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
  
  ;*** Set SCL = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		      ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SDA = LOW
  movf	RAMTRIS,w
  andlw	SDA_L		      ; make SDA an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO
			
  ;*** Set SCL = LOW before exiting
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  retlw 0	
  
;******************************************************************************
; I2CStop - Send a STOP bit MCP23008 (I2C)
; SCL = LOW
; SDA = LOW
; SCL = HIGH
; SDA = HIGH
;******************************************************************************
I2CStop
  ;*** Set SCL = LOW ...Just in case it is not already
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SDA = LOW
  movf	RAMTRIS,w
  andlw	SDA_L		      ; make SDA an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO			

	;*** Set SCL = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		      ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		      ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
  
  retlw 0

;******************************************************************************
; I2CACK - Send an ACK bit to the MCP23008 (I2C)
;
;******************************************************************************
I2CACK
  ;*** Set SDA = LOW
  movf	RAMTRIS,w
  andlw	SDA_L		      ; make SDA an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO			

  ;*** Set SCL = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		      ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SCL = LOW ...Just in case it is not already
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		      ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
  
  retlw 0

;******************************************************************************
; NoACK - Send a NACK (no ACK) bit to the MCP23008 (I2C)
;
;******************************************************************************
NoACK
  ;*** Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		      ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

  ;*** Set clock = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		      ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
	
  ;*** Set clock = LOW
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  retlw 0

;******************************************************************************
; IsACK? - Check if device ACKed
;
;******************************************************************************
IsACK?
  ;*** Set SDA = HIGH
  movf	RAMTRIS,w
  iorlw	SDA_H		      ; make SDA an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO

  movfw GPIO          ; Will check SDA pin level later
  movwf ACKStat       ; Place in variable

  ;*** Pulse SCL to clear ACK slot
  ;*** Set clock = HIGH
  movf	RAMTRIS,w
  iorlw	SCL_H		      ; make SCL an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
  ;*** Set clock = LOW
  movf	RAMTRIS,w
  andlw	SCL_L		      ; make SCL an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO

  btfsc ACKStat,2     ; Test ACK status (on GP2)
  goto  ACK_F
  goto  ACK_T

ACK_F                 ; No ACK
  retlw 0 
ACK_T                 ; ACK
  retlw 1 
;END*END*END******************* I2C Routines ***********************END*END*END
;END*END*END******************* I2C Routines ***********************END*END*END


;****************************** SPI Routines **********************************
;******************************************************************************
; SPIByteWrite - Writes an SPI byte
; Load "DataByte" defore calling this routine
;
; OPCODE w/ An pins (R/W = 0)
; ADDR
; Write Data 
;******************************************************************************
SPIByteWrite

  ;*** Set clock = LOW for MODE 00
  call  ClockMode00
  
  ;*** Set CS = LOW
  movf	RAMTRIS,w
  andlw	CS_OUT        ; make an output
  movwf	RAMTRIS
  tris	GPIO

  movlw 0x00          ; Drive nCS low
  movwf GPIO          ;

  ;*** Send OPCODE
  movlw OPCODE        ; Load Opcode
  iorlw AnPINS        ; IOR An pins
  movwf TempData      ; Place in data byte
  movlw WRITECMD      ; WRITE command
  iorwf TempData, 1   ; IOR write command and place results in TempData
  call  SPIClockByte

  ;*** Send Address
  movf  Addr,w        ; Load Address
  movwf TempData      ; Place in data byte
  call  SPIClockByte

  ;*** Send Data
  movf  DataByte,w    ; Load Data (was configured outside of subroutine)
  movwf TempData      ; Place in data byte
  call  SPIClockByte

  ;*** Set clock = LOW for MODE 00
  call  ClockMode00

	;*** Set CS = HIGH
  movlw 0x02          ; Drive nCS high
  movwf GPIO          ;

  retlw 0

;******************************************************************************
; SPIByteRead - Reads an SPI byte
; OPCODE w/ An pins (R/W = 0)
; ADDR
; Read Data 
;******************************************************************************
SPIByteRead
  ;*** Set clock = LOW for MODE 00
  call  ClockMode00

  ;*** Set CS = LOW
  movf	RAMTRIS,w
  andlw	CS_OUT        ; make an output
  movwf	RAMTRIS
  tris	GPIO

  movlw 0x00          ; Drive nCS low
  movwf GPIO          ;

  ;*** Send OPCODE
	movlw OPCODE        ; Load Opcode
  iorlw AnPINS        ; IOR An pins
  movwf TempData      ; Place in data byte
  movlw READCMD       ; READ command
  iorwf TempData, 1   ; IOR write command and place results in TempData
  call  SPIClockByte

  ;*** Send Address
  movf Addr,w         ; Load Address
  movwf TempData      ; Place in data byte
  call  SPIClockByte
  
  ;*** Read Data
  clrf  ReadData      ; Clear byte that holds data
  
  movlw 0xFF          ; Make TempData all ones so SI stays high
  movf  TempData,f    ; during the read of SO
  call  SPIClockByte  ; Data is now in ReadData variable

  ;*** Set clock = LOW for MODE 00
  call  ClockMode00

	;*** Set CS = HIGH

  movlw 0x02          ; Drive nCS High
  movwf GPIO          ;

  retlw 0

;******************************************************************************
; SPIClockByte - Clocks a byte
; 
;******************************************************************************
SPIClockByte
  movlw	0x08            ; For looping on 1 byte
  movwf BitCount
NextSPIBit              ; Loop through data
  rlf     TempData,f	  ; MSB first, Note TempData is lost
  goto    SPIClockBit   ;
ContinueSPI
  decfsz  BitCount,f
  goto    NextSPIBit    ; END of loop

  retlw 0

;******************************************************************************
; SPIClockBit - Clocks a bit
; 
; This is not actually a subroutine, however, it was split from the
; SPIClockByte routing for clarity.
;******************************************************************************
SPIClockBit
  btfsc	STATUS,C        ; Check if a '1' or '0'
  goto  SIHigh

  ;*** Set SI = LOW
SILow
  movf	RAMTRIS,w
  andlw	SI_L	  	      ; make an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO
  goto  PulseSCK			

SIHigh
  ;*** Set SI = HIGH
  movf	RAMTRIS,w
  iorlw	SI_H  		      ; make an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
  goto  PulseSCK

PulseSCK
  ;*** Set clock = HIGH
  movf	RAMTRIS,w
  iorlw	SCK_H  		      ; make an input (float HIGH)
  movwf	RAMTRIS
  tris	GPIO
	
  ;*** First check SDA value
  movlw 0x00            ; Check status of SO pin
  btfsc SO              ; Test pin state, skip if LOW
  movlw 0x01
  bcf   STATUS,C
  rlf   ReadData,1      ; Shift left by one bit (for next time through)
  iorwf ReadData,1      ; Place value into variable
  
  ;*** Set clock = LOW
  movf	RAMTRIS,w
  andlw	SCK_L	  	      ; make an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO			

  goto  ContinueSPI

;END*END*END******************* SPI Routines ***********************END*END*END
;END*END*END******************* SPI Routines ***********************END*END*END


;*************************** Low Level Pin Control ***************************
;*************************** Low Level Pin Control ***************************

;******************************************************************************
; ClockMode00 - Sets SCK LOW
;
; Note: Cannot call from Byte level or Bit level routines due to stack
;       limitation.
;******************************************************************************
ClockMode00
  movf	RAMTRIS,w
  andlw	SCK_L	  	      ; make an output (drive LOW)
  movwf	RAMTRIS
  tris	GPIO			
	
  retlw 0

;END*END*END**************** Low Level Pin Control ****************END*END*END
;END*END*END**************** Low Level Pin Control ****************END*END*END
  
  END                       	; directive 'end of program'
