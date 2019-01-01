;*******************************************************
;*                 Code Produced by the                *
;*           PROTON+ LITE Compiler. Version 3.0        *
;* Copyright Rosetta Technologies/Crownhill Associates *
;*              Written by Les Johnson. 2004           *
;*******************************************************
 NOLIST
 #include "D:\PROTEUS\MYFILES\LABCENTER\1WIRE\DS1822_DESIGN\IDENTIF.PBP"
 LIST

 SN = 53
 Variable SN#0=53,SN#1=54,SN#2=55,SN#3=56,SN#4=57,SN#5=58
 Variable SN#6=59,SN#7=60
	#Define DQ PORTB,7
F1_SOF equ $ ; IDENTIF.BAS
BEGIN
F1_000014 equ $ ; in [IDENTIF.BAS] delayms 500             ' Wait for 500 ms to initialize display
	Movlw 1
	Movwf PP1H
	Movlw 244
	Call dly@w
F1_000015 equ $ ; in [IDENTIF.BAS] Rsout cls
	Movlw 64
	Movwf BPFH
	Call Cls
DO_AGAIN
F1_000018 equ $ ; in [IDENTIF.BAS] OWrite DQ, 1, [$33]     ' Issue a READ ROM command [33H]
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 1
	Movwf GPR
	Call Ow@rst2
	Movlw 51
	Call ow@out
F1_000022 equ $ ; in [IDENTIF.BAS] ORead DQ, 0, [STR SN\8] ' Read 64-bit device data into the 8-byte array "SN"
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Clrf GPR
	Clrf PBP#VAR0
Pb@lb4
	Setc
	Call Ow@in
	Movf PBP#VAR0,W
	Addlw SN
	Movwf FSR
	Movf PP1,W
	Movwf INDF
	Incf PBP#VAR0,F
	Movf PBP#VAR0,W
	Sublw 8
	Btfss STATUS,2
	Goto Pb@lb4
F1_000023 equ $ ; in [IDENTIF.BAS] Rsout at 1, 1, "Family Code = ",HEX2 SN[0],"h"
	Movlw 64
	Movwf BPFH
	Movlw 128
	Call curs@
	Movlw 70
	Call Rsout
	Movlw 97
	Call Rsout
	Movlw 109
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 108
	Call Rsout
	Movlw 121
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 67
	Call Rsout
	Movlw 111
	Call Rsout
	Movlw 100
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 2
	Movwf GEN4H
	Movf SN#0,W
	Call out@hexc
	Movlw 104
	Call Rsout
F1_000024 equ $ ; in [IDENTIF.BAS] Rsout at 2, 1, "Ser# = ",HEX2 SN[1],HEX2 SN[2],HEX2 SN[3],HEX2 SN[4],HEX2 SN[5],HEX2 SN[6],"h"
	Movlw 64
	Movwf BPFH
	Movlw 192
	Call curs@
	Movlw 83
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 114
	Call Rsout
	Movlw 35
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 2
	Movwf GEN4H
	Movf SN#1,W
	Call out@hexc
	Movlw 2
	Movwf GEN4H
	Movf SN#2,W
	Call out@hexc
	Movlw 2
	Movwf GEN4H
	Movf SN#3,W
	Call out@hexc
	Movlw 2
	Movwf GEN4H
	Movf SN#4,W
	Call out@hexc
	Movlw 2
	Movwf GEN4H
	Movf SN#5,W
	Call out@hexc
	Movlw 2
	Movwf GEN4H
	Movf SN#6,W
	Call out@hexc
	Movlw 104
	Call Rsout
F1_000025 equ $ ; in [IDENTIF.BAS] Rsout at 3, 1, "CRC Value = ",HEX2 SN[7],"h"
	Movlw 64
	Movwf BPFH
	Movlw 148
	Call curs@
	Movlw 67
	Call Rsout
	Movlw 82
	Call Rsout
	Movlw 67
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 86
	Call Rsout
	Movlw 97
	Call Rsout
	Movlw 108
	Call Rsout
	Movlw 117
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 2
	Movwf GEN4H
	Movf SN#7,W
	Call out@hexc
	Movlw 104
	Call Rsout
F1_000029 equ $ ; in [IDENTIF.BAS] IF SN[0] = $5 Then
	Movf SN#0,W
	Movwf PBP#VAR0
	Movlw 5
	Subwf PBP#VAR0,W
	Btfss STATUS,2
	Goto bc@LL5
F1_000030 equ $ ; in [IDENTIF.BAS] Rsout at 4, 1, "Device = Switch     "
	Movlw 64
	Movwf BPFH
	Movlw 212
	Call curs@
	Movlw 68
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 118
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 99
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 83
	Call Rsout
	Movlw 119
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 116
	Call Rsout
	Movlw 99
	Call Rsout
	Movlw 104
	Call Rsout
	Movlw 32
	Call Rsout
	Call Rsout
	Call Rsout
	Call Rsout
	Call Rsout
F1_000031 equ $ ; in [IDENTIF.BAS] EndIF
bc@LL5
F1_000033 equ $ ; in [IDENTIF.BAS] IF SN[0] = $28 OR SN[0] = $22 Then
	Movf SN#0,W
	Movwf PBP#VAR0
	Movlw 40
	Subwf PBP#VAR0,W
	Btfsc STATUS,2
	Movlw 1
	Btfss STATUS,2
	Clrw
	Movwf SP#P9
	Movf SN#0,W
	Movwf PBP#VAR0
	Movlw 34
	Subwf PBP#VAR0,W
	Btfsc STATUS,2
	Movlw 1
	Btfss STATUS,2
	Clrw
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Goto bc@LL7
F1_000034 equ $ ; in [IDENTIF.BAS] Rsout at 4, 1, "Device = Temp Sensor"
	Movlw 64
	Movwf BPFH
	Movlw 212
	Call curs@
	Movlw 68
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 118
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 99
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 84
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 109
	Call Rsout
	Movlw 112
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 83
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 110
	Call Rsout
	Movlw 115
	Call Rsout
	Movlw 111
	Call Rsout
	Movlw 114
	Call Rsout
F1_000035 equ $ ; in [IDENTIF.BAS] EndIF
bc@LL7
F1_000037 equ $ ; in [IDENTIF.BAS] IF SN[0] = $01 Then
	Movf SN#0,W
	Movwf PBP#VAR0
	Movlw 1
	Subwf PBP#VAR0,W
	Btfss STATUS,2
	Goto bc@LL9
F1_000038 equ $ ; in [IDENTIF.BAS] Rsout at 4, 1, "Device = Serial #   "
	Movlw 64
	Movwf BPFH
	Movlw 212
	Call curs@
	Movlw 68
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 118
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 99
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 83
	Call Rsout
	Movlw 101
	Call Rsout
	Movlw 114
	Call Rsout
	Movlw 105
	Call Rsout
	Movlw 97
	Call Rsout
	Movlw 108
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 35
	Call Rsout
	Movlw 32
	Call Rsout
	Call Rsout
	Call Rsout
F1_000039 equ $ ; in [IDENTIF.BAS] EndIF
bc@LL9
F1_000040 equ $ ; in [IDENTIF.BAS] delayms 10000          ' wait for 10-second
	Movlw 39
	Movwf PP1H
	Movlw 16
	Call dly@w
F1_000041 equ $ ; in [IDENTIF.BAS] GoTo Do_again
	Goto DO_AGAIN
F1_000042 equ $ ; in [IDENTIF.BAS] End
Pb@lb11
	Sleep
	Goto Pb@lb11
F1_EOF equ $ ; IDENTIF.BAS
	END

