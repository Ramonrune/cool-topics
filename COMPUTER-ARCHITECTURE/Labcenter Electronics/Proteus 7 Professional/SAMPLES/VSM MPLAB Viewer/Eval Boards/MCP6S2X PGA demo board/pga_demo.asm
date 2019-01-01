
;--------------------------------------------------------------------------
;       This firmware is developed for the MCP6S2X PGA demo board.
;
;       The firmware reads the user interface dip and push-button switch 
;       settings and programs the PGA accordingly.
;
;
;       File name:      pga_demo.asm
;       Date:           08/09/04
;       File Version:   1.00
;
;       Programmer:     MPLAB ICE 2
;       File Required:  PIC16F676.inc
;       
;       Demo Board:
;               Name:   MCP6S2X Eval. Bd.
;               Number: 102-00018R4
;               Rev.:   R4
;               PGAs:   MCP6S21 (or MCP6S91), MCP6S26
;
;       Author:         Ezana Haile
;       Company:        Microchip Technology, Inc.
;
;--------------------------------------------------------------------------

        ERRORLEVEL -302
        ERRORLEVEL -305

          LIST    p=16F676
 
#INCLUDE <P16F676.INC>          

        __CONFIG        _MCLRE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _PWRTE_OFF & _BODEN_OFF & _CPD_OFF

; definitions

                #DEFINE                 CS                              PORTC, 4                ; CHIP SELECT
                #DEFINE                 SCK                     PORTC, 5                ; CLOCK
                #DEFINE                 DO                              PORTC, 3                ; DATA OUT
                #DEFINE                 PUSH                    PORTA, 0                ; READ PUSH BUTTON
                #DEFINE                 SW1                     PORTC, 2                ; SWITCH 1
                #DEFINE         SW2                     PORTC, 1                ; SWITCH 2
                #DEFINE                 SW3                     PORTC, 0                ; SWITCH 3
                #DEFINE                 SW4                     PORTA, 2                ; SWITCH 4
                #DEFINE                 SW5                     PORTA, 5                ; SWITCH 5
                #DEFINE                 PRG_GAIN                B'01000000'     ; PROGRAM GAIN
                #DEFINE                 PRG_CHANNEL     B'01000001'     ; PROGRAM CHANNEL
                #DEFINE                 PGA_SHDN                B'00100000'     ; SHUTDOWN PGA

; reserve memory byte

                CBLOCK  0X20
                COUNTER, BUFFER
                ENDC


;============================================================
;==========     PROGRAM         =============================
;============================================================

PGA_DEMO                                                        ; CODE NAME
                ORG             0X00
                GOTO            START

START   ORG             0X05
        
                BCF             STATUS, RP0     ; BANK 0
                MOVLW           H'07'
                MOVWF           CMCON                   ; DIGITAL I/O
                BSF             STATUS, RP0     ; BANK 1        
                CLRF            ANSEL                   ; DIGITAL I/O
                CLRF            WPUA
                MOVLW           H'3F'
                MOVWF           TRISA                   ; SET PORT A AS INPUT
                MOVLW           H'07'                   ; SET RC<5,4,3> OUTPUT AND RC<2,1,0> INPUT
                MOVWF           TRISC                   ; SET PORT C AS INPUT
                BCF             STATUS, RP0     ; BANK 0

READ    BTFSC           PUSH                    ; CHECK TO SEE IF THE READ BUTTON IS PRESSED
                GOTO            READ
RDING   BTFSS           PUSH                    ; WAIT UNTIL THE BUTTON IS RELEASED
                GOTO            RDING                   ; LOOP

                BSF             CS                              ; UNSELECT THE DEVICES
                BCF             DO                              ; KEEP THE DATAOUT (DO) LOW
                BCF             SCK                     ; SET CLOCK
                CLRF            BUFFER          ; CLEAR BUFFER
        
                BTFSC           SW5     
                GOTO            CHANNEL_SHDN    ; DETERMINE IF IT'S FOR CHANNEL OR 
                                                                ; SHUTDOWN OTHERWISE PROGRAM GAIN

; PROGRAM THE GAIN OF PGA 1 (MCP6S26) OR PGA 2 (MCP6S21)

                BTFSC           SW4
                GOTO            PGA_2_GAIN      ; DETERMINE THE DEVICE

PGA_1_GAIN      
                BCF             CS                              ; SELECT PGA
                MOVLW           PRG_GAIN                ; PROGRAM GAIN CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THROUGH SPI
                CALL            READ_SWITCH     ; READ SWITCH SETTINGS
                CALL            BITBANG         ; SEND IT THROUGH SPI AND PROGRAM PGA
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ    

PGA_2_GAIN
                BCF             CS                              ; SELECT PGA
                MOVLW           PRG_GAIN                ; PROGRAM GAIN CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THROUGH SPI AND PROGRAM PGA
                CALL            READ_SWITCH     ; READ SWITCH SETTINGS
                CALL            BITBANG         ; SEND IT THROUGH SPI
                CLRF            BUFFER          ; SEND ZEROS TO PUSH OUT THE DATA TO PGA 2
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ
        
; PROGRAM THE CHANNEL OR SHUTDOWN PGA 1 (MCP6S26) OR PGA 2 (MCP6S21)

CHANNEL_SHDN
                BTFSC           SW4
                GOTO            SHDN                    ; GOTO SHUTDOWN

CHANNEL 
                BCF             CS                              ; SELECT PGA
                MOVLW           PRG_CHANNEL     ; PROGRAM CHANNEL CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THROUGH SPI
                CALL            READ_SWITCH     ; READ SWITCH SETTINGS
                CALL            BITBANG         ; SEND IT THROUGH SPI AND PROGRAM PGA
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ

SHDN    
                BTFSC           SW3                     ; IF THE 3RD SWITCH IS HIGH THEN DON'T SHUTDOWN
                GOTO            READ
        
                BTFSC           SW2                     ; DETERMINE WHICH DEVICE
                GOTO            SHDN_BOTH       ; SHUTDOWN BOTH PGAS
                BTFSC           SW1
                GOTO            SHDN_PGA_2      ; IF THE 1RD SWITCH IS HIGH THEN DON'T SHUTDOWN
        
SHDN_PGA_1                                              ; SHUTDOWN THE FIRST PGA
                BCF             CS                              ; SELECT PGA
                MOVLW           PGA_SHDN                ; PROGRAM SHUTDOWN CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THROUGH SPI AND PROGRAM PGA
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ    
        
SHDN_PGA_2                                              ; SHUTDOWN THE SECOND PGA
                BCF             CS                              ; SELECT PGA
                MOVLW           PGA_SHDN                ; PROGRAM SHUTDOWN CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THROUGH SPI AND PROGRAM PGA
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                CLRF            BUFFER
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ

SHDN_BOTH                                               ; SHUTDOWN BOTH PGAs
                BCF             CS                              ; SELECT PGA
                MOVLW           PGA_SHDN                ; PROGRAM SHUTDOWN CONFIGURATION
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THRU SPI AND SHUTDOWN PGA
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                MOVLW           PGA_SHDN                ; PROGRAM SHUTDOWN CONFIGURATION (again)
                MOVWF           BUFFER  
                CALL            BITBANG         ; SEND IT THRU SPI AND SHUTDOWN PGA
                CALL            BITBANG         ; SEND 8 DUMMY BITS
                BSF             CS                              ; UNSELECT THE DEVICES
                GOTO            READ
        
;--------------------------------------------------------------------------
;--- READ THE SWITCH SETTINGS
;--------------------------------------------------------------------------

READ_SWITCH
                CLRF            BUFFER          ; PROGRAM BUFFER FROM SWITCHES
                BTFSC           SW3                     ; CHECK THE 3RD SWITCH
                BSF             BUFFER, 2
                BTFSC           SW2                     ; CHECK THE 2RD SWITCH
                BSF             BUFFER, 1
                BTFSC           SW1                     ; CHECK THE 1RD SWITCH
                BSF             BUFFER, 0
                RETURN

;--------------------------------------------------------------------------
;---- BIT BANG SPI COMMUNICATION
;--------------------------------------------------------------------------

BITBANG
                CLRC
                MOVLW   H'08'
                MOVWF           COUNTER         ; SET THE BIT BANG COUNTER
SEND    BTFSC           BUFFER, 7       ; SEE THE LAST BIT OF THE BUFFER
                BSF             DO                              ; THE SWITCH IS SET, THEN SET THE BUFFER HIGH
                BSF             SCK                     ; SET CLOCK
                BCF             SCK                     ; CLEAR CLOCK
                BCF             DO                              ; CLEAR THE DATA
                RLF             BUFFER,F                ; ROLL THE BITS
                DECFSZ  COUNTER, F      ; CHECK END OF COUNTER
                GOTO            SEND                    ; LOOP
                RETURN
;--------------------------------------------------------------------------

        END
