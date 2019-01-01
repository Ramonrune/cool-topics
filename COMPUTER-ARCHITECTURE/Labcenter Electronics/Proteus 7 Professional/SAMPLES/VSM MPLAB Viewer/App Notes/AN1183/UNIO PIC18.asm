
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;                                                                     
;                     Software License Agreement                      
;                                                                     
; Microchip Technology Inc. (“Microchip”) licenses this software to you
; solely for use with Microchip microcontrollers and Microchip serial
; EEPROM products.  The software is owned by Microchip and/or its
; licensors, and is protected under applicable copyright laws.  All
; rights reserved.
;
; SOFTWARE IS PROVIDED "AS IS."  MICROCHIP AND ITS LICENSOR EXPRESSLY
; DISCLAIM ANY WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR
; NON-INFRINGEMENT. IN NO EVENT SHALL MICROCHIP AND ITS LICENSORS BE
; LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
; DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
; PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
; BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
; ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
;                                                                     
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;   Filename:           UNIO PIC18.asm
;   Dependencies:       p18f1220.inc
;                       UNIO PIC18.inc
;   Processor:          PIC18F1220
;   Assembler:          MPASMWIN 5.13 or higher
;   Linker:             MPLINK 4.13 or higher
;   Date:               April 30, 2008
;   File Version:       1.0
;
;   Author:             Chris Parris
;   Company:            Microchip Technology Inc.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;   Purpose:
;
;   This application note is intended to serve as a reference for
;   manually communicating with Microchip’s UNI/O(TM) bus-compatible
;   11XXXXX family of serial EEPROM devices. Communication is performed
;   through software control.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;   Program Description:
;
;   This program illustrates page write and read operations, as well as
;   the Write Enable instruction and the WIP Polling feature. Note that
;   no action is taken if a SAK bit is not received when one is
;   expected.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;   8MHz internal oscillator is being used, thus each instruction
;   cycle = 500 ns
;
;   PORTB Pin Descriptions:
;
;   SCIO        bit = 2
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LIST P=18F1220
;*******************External definitions**************************
    extern  dataOut, dataIn, flags, StandbyPulse, StartHeader
    extern  OutputByte, AckSequence, InputByte, EndCmd, TssDelay
;*******************RAM register definitions**********************
    UDATA_ACS
count           RES     1               ; 8-bit count variable
buffer          RES     1               ; Read buffer
    UDATA
;*******************Config word***********************************
    config  OSC=INTIO2, FSCM=OFF, IESO=OFF, PWRT=ON, BOR=OFF, WDT=OFF
    config  MCLRE=ON, STVR=OFF, LVP=OFF
;*******************Include file**********************************
    include "p18f1220.inc"              ; this is the include file for a PIC18F1220
    include "UNIO PIC18.inc"            ; this is the include file for the project
    errorlevel  -302                    ; suppress message 302 from list file
;*******************Reset vector**********************************
SECT_reset  CODE    0x000               ; Set the reset vector
    goto        Main                    ; Go to the beginning of Main
;*******************Code section**********************************
PROGSUBS   CODE
Init
    ; Initialize I/O
    movlw       b'01110011'             ; Select 8 MHz internal oscillator
    movwf       OSCCON                  ; Load value into OSCCON
_InitLoop
;    btfss       OSCCON,IOFS             ; Check if oscillator is stable
;    bra         _InitLoop               ; If not stable, keep looping
    movlw       b'11111011'             ; Load new TRIS value into WREG
    movwf       TRISB                   ; Configure SCIO as an output
    ; Generate rising edge on SCIO to release device from POR
    bcf         PORTB,SCIO              ; Set SCIO low
    bsf         PORTB,SCIO              ; Set SCIO high
    retlw       0                       ; Return

SECT_main   CODE
Main
    rcall       Init                    ; Call Init subroutine

    rcall       StandbyPulse            ; Generate Standby Pulse

    ; Perform Write Enable
    ; Tss delay not required here because Standby Pulse was just generated
    rcall       StartHeader             ; Output Start pulse
    movlw       DEVICEADDR              ; Load device address into WREG
    bsf         flags,CHECK_SAK         ; Set to check for SAK
        nop
    rcall       OutputByte              ; Output byte
    movlw       WREN_CMD                ; Load command into WREG
    bcf         flags,SEND_MAK          ; Don't send MAK bit
        nop
    rcall       OutputByte              ; Output byte
        bra     $+2
        nop
    rcall       EndCmd                  ; Gracefully end command

    ; Perform write of 1 page
    rcall       TssDelay                ; Delay for Tss time
    rcall       StartHeader             ; Output Start pulse
    movlw       DEVICEADDR              ; Load device address into WREG
    bsf         flags,CHECK_SAK         ; Set to check for SAK
        nop
    rcall       OutputByte              ; Output byte
    movlw       WRITE_CMD               ; Load command into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .0                      ; Load 0 into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .0                      ; Load 0 into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .15                     ; Load 15 into WREG
    movwf       count                   ; Copy WREG to count
_MainWriteLoop
    movf        count,W                 ; Copy count to WREG
    rcall       OutputByte              ; Output byte
    decfsz      count,F                 ; Decrement count and check if 0
    bra         _MainWriteLoop          ; If not 0, keep looping
    movlw       .0                      ; Load 0 into WREG
    bcf         flags,SEND_MAK          ; Don't send MAK bit
    rcall       OutputByte              ; Output byte
        bra     $+2
        nop
    rcall       EndCmd                  ; Gracefully end command

    ; Perform WIP Polling
    rcall       TssDelay                ; Delay for Tss time
    rcall       StartHeader             ; Output Start pulse
    movlw       DEVICEADDR              ; Load device address into WREG
    bsf         flags,CHECK_SAK         ; Set to check for SAK
        nop
    rcall       OutputByte              ; Output byte
    movlw       RDSR_CMD                ; Load command into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
        bra     $+2
_WIPPoll
        nop
    rcall       InputByte               ; Input byte
    btfss       dataIn,0                ; Check if WIP bit is set
    bra         _WIPPollEnd             ; If not set, go to end of polling
        nop
    rcall       AckSequence             ; Else, perform Acknowledge sequence
    bra         _WIPPoll                ; And keep looping
_WIPPollEnd
    bcf         flags,SEND_MAK          ; Don't send MAK bit
    rcall       AckSequence             ; Perform Acknowledge sequence
        bra     $+2
        nop
    rcall       EndCmd                  ; Gracefully end command

    ; Perform read of page just written
_MainRead
    rcall       TssDelay                ; Delay for Tss time
    rcall       StartHeader             ; Output Start pulse
    movlw       DEVICEADDR              ; Load device address into WREG
    bsf         flags,CHECK_SAK         ; Set to check for SAK
        nop
    rcall       OutputByte              ; Output byte
    movlw       READ_CMD                ; Load command into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .0                      ; Load 0 into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .0                      ; Load 0 into WREG
        bra     $+2
    rcall       OutputByte              ; Output byte
    movlw       .15                     ; Load 15 into WREG
    movwf       count                   ; Copy WREG to count
        nop
_MainReadLoop
    rcall       InputByte               ; Input byte
    movf        dataIn,W                ; Copy dataIn to WREG
    movwf       buffer                  ; Copy WREG to buffer
        nop
    rcall       AckSequence             ; Perform Acknowledge sequence
    decfsz      count,F                 ; Decrement count and check if 0
    bra         _MainReadLoop           ; If not 0, keep looping
        nop
    rcall       InputByte               ; Input byte
    movf        dataIn,W                ; Copy dataIn to WREG
    movwf       buffer                  ; Copy WREG to buffer
    bcf         flags,SEND_MAK          ; Don't send MAK bit
    rcall       AckSequence             ; Perform Acknowledge sequence
        bra     $+2
        nop
    rcall       EndCmd                  ; Gracefully end command

_InfLoop
    bra         _InfLoop                ; Loop here forever

    END
