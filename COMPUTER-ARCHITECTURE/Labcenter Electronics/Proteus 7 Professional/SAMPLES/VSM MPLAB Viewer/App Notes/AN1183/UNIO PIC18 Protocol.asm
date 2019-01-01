
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
;   8MHz internal oscillator is being used, thus each instruction
;   cycle = 500 ns
;
;   PORTB Pin Descriptions:
;
;   SCIO        bit = 2
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LIST P=18F1220
;*******************RAM register definitions**********************
    UDATA_ACS
counter         RES     1               ; 8-bit counter variable
delayCount      RES     1               ; Delay counter
dataOut         RES     1               ; Data output byte
dataIn          RES     1               ; Data input byte
flags           RES     1               ; Bit flags
    global dataOut, dataIn, flags
    UDATA
;*******************Include file**********************************
  include "p18f1220.inc"                ; this is the include file for a PIC18F1220
  include "UNIO PIC18.inc"              ; this is the include file for the project
  errorlevel  -302                      ; suppress message 302 from list file
;*******************Macro definitions*****************************
DELAYLOOP   MACRO numinsts, looplabel
    movlw       (numinsts-.1)/.3        ; Load count into WREG
    movwf       delayCount              ; Copy WREG to delayCount
looplabel                               ; Each loop is 3 inst. (2 for last loop)
    decfsz      delayCount,F            ; Decrement delayCount, check if 0
    bra         looplabel               ; If not 0, keep looping
    ; Now account for miscalculations by adding instructions. This also
    ;   accounts for the loop executing only 2 instructions for the last
    ;   count value.
#if (numinsts%.3)==.0                   ; Account for 2-inst miscalculation
    bra         $+2
#else
#if (numinsts%.3)==.2                   ; Account for 1-inst miscalculation
    nop
#endif
#endif
    endm
    
;*******************Code section**********************************
PROGSUBS    CODE

;********************************************************************
; Function:     StandbyPulse
;
; PreCondition: None
;
; Side Effects: WREG is modified
;               counter is modified
;
; Stack Requirements: 1 level deep
;
; Overview:     Hold SCIO high for Tstby time period to generate reset
;               pulse. This subroutine will delay for a total of 600 us
;               (1200 insts.) from setting SCIO high to returning.
;*********************************************************************
StandbyPulse
    global      StandbyPulse            ; Make function available to other modules

    ; Ensure SCIO is high for Tstby
    bsf         LATB,SCIO               ; Ensure SCIO is high
    bcf         TRISB,SCIO              ; Ensure SCIO is an output
    movlw       .240                    ; Load 240 into WREG
    movwf       counter                 ; Copy WREG to counter
_StandbyPulseLoop                       ; Each loop is 5 inst. (4 for last loop)
    bra         $+2                     ; Delay for 2 insts.
    decfsz      counter,F               ; Decrement counter & check if 0
    bra         _StandbyPulseLoop       ; If not 0, keep looping
    return                              ; Return

;********************************************************************
; Function:     StartHeader
;
; PreCondition: SCIO pin must be configured as an output
;
; Side Effects: WREG is modified
;               delayCount is modified
;               counter is modified
;               dataOut is modified
;               dataIn is modified
;
; Stack Requirements: 2 levels deep
;
; Overview:     Hold SCIO low for Thdr time period and prepare the
;               necessary registers for outputting the Start header
;               ('01010101').  
;*********************************************************************
StartHeader
    global      StartHeader             ; Make function available to other modules
    bcf         LATB,SCIO               ; Hold SCIO low

    bsf         flags,SEND_MAK          ; Select to send MAK bit
    bcf         flags,CHECK_SAK         ; Select to not check SAK bit
    movlw       STARTHDR                ; Load STARTHDR into WREG
    bra         OutputByte              ; Go to output Start header byte

;********************************************************************
; Function:     OutputByte
;
; Precondition: WREG must be loaded with value to output
;
; Overhead:     13 insts. before boundary edge (including call)
;               11 insts. after middle edge (including return)
;
; Side Effects: WREG is modified
;               delayCount is modified
;               counter is modified
;               dataOut is modified
;               dataIn is modified
;
; Stack Requirements: 2 levels deep
;
; Overview:     Manchester-encodes & outputs the value in WREG to
;               SCIO.
;*********************************************************************
OutputByte
    global      OutputByte              ; Make function available to other modules

    movwf       dataOut                 ; Copy WREG to dataOut
    movlw       .8                      ; Load 8 into WREG
    movwf       counter                 ; Copy WREG to counter

_OutputByteBitLoop
    ; Output first half of bit
    rcall       _OutputHalfBit          ; Output first half of bit

    ; Delay to ensure proper timing
    DELAYLOOP   (POST+USERCODE+.2), _OutputByteDelayLoop1

    ; Output second half of bit
    rcall       _OutputHalfBit          ; Output second half of bit

_OutputByteDecrCount
    ; Prepare for next bit of data
    rlcf        dataOut,F               ; Rotate dataOut left for next bit
    decfsz      counter,F               ; Decrement counter & check if 0
    bra         _OutputByteBitDelay     ; If not 0, keep looping

    ; Delay to ensure proper timing
    DELAYLOOP   (POST+USERCODE-.6), _OutputByteDelayLoop2
    bra         AckSequence             ; Otherwise, perform Acknowledge Sequence
                                        ;   (includes return)

_OutputByteBitDelay
    ; Ensure proper delays are met between bits
    DELAYLOOP   (POST+USERCODE-.4), _OutputByteDelayLoop3
    bra         _OutputByteBitLoop      ; Go to output next bit

;********************************************************************
; Function:     _OutputHalfBit
;
; PreCondition: MSb of dataOut must be loaded with value to output
;
; Overhead:     11 insts. total (including call and return)
;               8  insts. before modifying SCIO (including call)
;               3  insts. after modifying SCIO (including return)
;
; Side Effects: dataOut is inverted
;
; Stack Requirements: 1 level deep
;
; Overview:     Ensures SCIO is configured as an output, then outputs
;               the next half of the current bit period. The value
;               used is specified by the MSb of dataOut.
;*********************************************************************
_OutputHalfBit
    ; Ensure SCIO is configured as an output
    movf        PORTB,F                 ; Update PORTB latches
    bcf         TRISB,SCIO              ; Ensure SCIO is an output

    ; Output half of bit period
    btfss       dataOut,7               ; Check if next data bit is a 1
    bra         _OutputHalfBitOut0      ; If not 1, go to output a 0
    nop                                 ; Delay to even out both sides
    bcf         LATB,SCIO               ; Bring SCIO low for half
    comf        dataOut,F               ; Invert dataOut
    return                              ; Return

_OutputHalfBitOut0
    bsf         LATB,SCIO               ; Bring SCIO high for half
    comf        dataOut,F               ; Invert dataOut
    return                              ; Return

;********************************************************************
; Function:     AckSequence
;
; PreCondition: MAK/SAK flags must be set up for desired actions
;
; Overhead:     13 insts. before boundary edge (including call)
;               11 insts. after middle edge (including return)
;
; Side Effects: WREG is modified
;               delayCount is modified
;               counter is modified
;               dataOut is modified
;               dataIn is modified
;
; Stack Requirements: 2 levels deep
;
; Overview:     Performs Acknowledge sequence, including MAK/NoMAK as
;               specified by SEND_MAK flag, and SAK. Depending on
;               value of CHECK_SAK flag, the SAK bit will either be
;               checked or ignored. This provides for the special case
;               which occurs right after the Start header.
;*********************************************************************
AckSequence
    global      AckSequence             ; Make function available to other modules

    ; Prepare dataOut for sending the MAK bit
    bsf         dataOut,7               ; Assume 1 will be sent
    btfss       flags,SEND_MAK          ; Check if MAK is to be sent
    bcf         dataOut,7               ; If not, send 0 (NoMAK)

    ; Output first half of the bit
    rcall       _OutputHalfBit          ; Output first half of bit

    ; Delay to ensure proper timing
    DELAYLOOP   (POST+USERCODE+.2), _AckSequenceDelayLoop1

    ; Output second half of the bit
    rcall       _OutputHalfBit          ; Output second half of bit

    ; Delay to ensure proper timing
    DELAYLOOP   ((PRE+POST+USERCODE)-.4), _AckSequenceDelayLoop2

    ; Release SCIO
    bsf         TRISB,SCIO              ; Ensure SCIO is an input

    ; Determine if SAK is to be checked
    btfss       flags,CHECK_SAK         ; Check if SAK is to be checked
    bra         _AckSequenceSkipSAK     ; If not, jump to skip SAK

    ; Delay until 1/4th way into bit period
    DELAYLOOP   (((PRE+POST+USERCODE)/.2)-.4), _AckSequenceDelayLoop3

    rcall       _InputBit               ; If checking SAK, input bit

    bra         _AckSequenceReturn      ; Go to return (needed for proper delay)

    ; If SAK is not to be checked, delay and return
_AckSequenceSkipSAK
    ; Delay to ensure proper timing
    DELAYLOOP   (PRE+(.2*POST)+USERCODE-.5), _AckSequenceDelayLoop4

_AckSequenceReturn
    return                              ; Return

;********************************************************************
; Function:     InputByte
;
; Overhead:     13 insts. before boundary edge (including call)
;               11 insts. after middle edge (including return)
;
; Side Effects: WREG is modified
;               delayCount is modified
;               counter is modified
;               dataIn is modified
;
; Stack Requirements: 2 levels deep
;
; Overview:     Inputs and Manchester-decodes from SCIO a byte of data
;               and stores it in dataIn.
;*********************************************************************
InputByte
    global      InputByte               ; Make function available to other modules
    movlw       .8                      ; Load 8 into WREG
    movwf       counter                 ; Copy WREG to counter
_InputByteLoop
    ; Delay until 1/4th way into bit period
    DELAYLOOP   (PRE+((PRE+POST+USERCODE)/.2)-.7), _InputByteDelayLoop1

    ; Rotate dataIn and input next bit
    rlcf        dataIn,F                ; Shift dataIn left to prepare for next bit
    rcall       _InputBit               ; Input next bit of data

    decfsz      counter,F               ; Decrement counter and check if 0
    bra         _InputByteBitDelay      ; If not 0, keep looping
    return                              ; Otherwise, return

_InputByteBitDelay
    ; Ensure proper delays are met between bits
    DELAYLOOP   (USERCODE+.5), _InputByteDelayLoop2
    bra         _InputByteLoop          ; Go to input next bit

;********************************************************************
; Function:     _InputBit
;
; PreCondition: Must be 1/4*Te into current bit period, including
;               call.
;
; Overhead:     7 insts. after middle edge (including return)
;
; Side Effects: WREG is modified
;               delayCount is modified
;               dataIn is modified
;
; Stack Requirements: 1 level deep
;
; Overview:     Inputs and Manchester-decodes from SCIO a bit of data
;               and stores it in the LSb of dataIn.
;*********************************************************************
_InputBit
    ; Determine which edge to expect
    btfss       PORTB,SCIO              ; Check if SCIO is high
    bra         _InputBitRecv1          ; If not high, received '1'
    nop                                 ; Nop to balance both paths of btfss

_InputBitRecv0                          ; Received '0' bit
    bcf         dataIn,0                ; Clear LSb of dataIn, indicating 0 was read
    bra         _InputBitReturn         ; Jump to return

_InputBitRecv1                          ; Received '1' bit
    bsf         dataIn,0                ; Set LSb of dataIn, indicating 1 was read
    bra         _InputBitReturn         ; Jump to return

_InputBitReturn
    ; Ensure proper delays are met
    DELAYLOOP   (((PRE+POST+USERCODE)/.2)-.1), _InputBitDelayLoop

    return                              ; Return

;********************************************************************
; Function:     EndCmd
;
; Overhead:     13 insts. before boundary edge (including call)
;
; Side Effects: WREG is modified
;               delayCount is modified
;
; Stack Requirements: 1 level deep
;
; Overview:     Waits until end of current bit period has been
;               reached and ensures SCIO is high for bus idle.
;*********************************************************************
EndCmd
    global      EndCmd                  ; Make function available to other modules

    ; Delay to ensure proper timing
    DELAYLOOP   (PRE-.2), _EndCmdDelayLoop

    ; Ensure SCIO is driving high
    bsf         LATB,SCIO               ; Ensure SCIO is high
    bcf         TRISB,SCIO              ; Ensure SCIO is an output

    return                              ; Return

;********************************************************************
; Function:     Tss
;
; Side Effects: WREG is modified
;               delayCount is modified
;
; Stack Requirements: 1 level deep
;
; Overview:     Delays for 10 us (including call & return) to ensure
;               proper Tss time.
;*********************************************************************
TssDelay
    global      TssDelay                ; Make function available to other modules

    DELAYLOOP   (.16), _TssDelayLoop    ; Delay for remaining time

    return                              ; Return

    END
