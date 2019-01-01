;*******************************************************
;*                 Code Produced by the                *
;*           PROTON+ LITE Compiler. Version 3.0        *
;* Copyright Rosetta Technologies/Crownhill Associates *
;*              Written by Les Johnson. 2004           *
;*******************************************************
 NOLIST
 #include "D:\PROTEUS\MYFILES\LABCENTER\1WIRE\DS2405\MACHROM.PBP"
 LIST

	#Define DQ PORTB,7
	#Define STAT _B#VR1,0
F1_SOF equ $ ; MACHROM.BAS
BEGIN
F1_000011 equ $ ; in [MACHROM.BAS] delayms 300             ' Wait .3 seconds
	Movlw 1
	Movwf PP1H
	Movlw 44
	Call dly@w
F1_000013 equ $ ; in [MACHROM.BAS] Rsout cls, "DS2405 NETWORK TEST" ' Clear LCD on power-up
	Movlw 64
	Movwf BPFH
	Call Cls
	Movlw 68
	Call Rsout
	Movlw 83
	Call Rsout
	Movlw 50
	Call Rsout
	Movlw 52
	Call Rsout
	Movlw 48
	Call Rsout
	Movlw 53
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 78
	Call Rsout
	Movlw 69
	Call Rsout
	Movlw 84
	Call Rsout
	Movlw 87
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 82
	Call Rsout
	Movlw 75
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 84
	Call Rsout
	Movlw 69
	Call Rsout
	Movlw 83
	Call Rsout
	Movlw 84
	Call Rsout
SWITCH_1
F1_000016 equ $ ; in [MACHROM.BAS] OWrite DQ, 1, [$55,$05,$C5,$C3,$08,$00,$00,$00,$CD]
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 1
	Movwf GPR
	Call Ow@rst2
	Movlw 85
	Call ow@out
	Movlw 5
	Call ow@out
	Movlw 197
	Call ow@out
	Movlw 195
	Call ow@out
	Movlw 8
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Movlw 205
	Call ow@out
F1_000017 equ $ ; in [MACHROM.BAS] Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 4
	Movwf GPR
	Call Ow@in
	Andlw 1
	Skpnz
	Bcf _B#VR1,0
	Skpz
	Bsf _B#VR1,0
F1_000018 equ $ ; in [MACHROM.BAS] IF Stat = 0 THEN
	Btfsc _B#VR1,0
	Goto bc@LL2
F1_000019 equ $ ; in [MACHROM.BAS] rsout at 2, 1 , "Switch #1 = OFF"
	Movlw 64
	Movwf BPFH
	Movlw 192
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 49
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 70
	Call Rsout
	Call Rsout
	Goto bc@LL3
bc@LL2
F1_000020 equ $ ; in [MACHROM.BAS] ELSE
F1_000021 equ $ ; in [MACHROM.BAS] rsout at 2, 1 , "Switch #1 = ON "
	Movlw 64
	Movwf BPFH
	Movlw 192
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 49
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 78
	Call Rsout
	Movlw 32
	Call Rsout
F1_000022 equ $ ; in [MACHROM.BAS] ENDIF
bc@LL3
F1_000024 equ $ ; in [MACHROM.BAS] delayms 500
	Movlw 1
	Movwf PP1H
	Movlw 244
	Call dly@w
SWITCH_2
F1_000027 equ $ ; in [MACHROM.BAS] OWrite DQ, 1, [$55,$05,$B3,$BF,$08,$00,$00,$00,$AB]
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 1
	Movwf GPR
	Call Ow@rst2
	Movlw 85
	Call ow@out
	Movlw 5
	Call ow@out
	Movlw 179
	Call ow@out
	Movlw 191
	Call ow@out
	Movlw 8
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Movlw 171
	Call ow@out
F1_000028 equ $ ; in [MACHROM.BAS] Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 4
	Movwf GPR
	Call Ow@in
	Andlw 1
	Skpnz
	Bcf _B#VR1,0
	Skpz
	Bsf _B#VR1,0
F1_000029 equ $ ; in [MACHROM.BAS] IF Stat = 0 THEN
	Btfsc _B#VR1,0
	Goto bc@LL5
F1_000030 equ $ ; in [MACHROM.BAS] rsout at 3, 1 , "Switch #2 = OFF"
	Movlw 64
	Movwf BPFH
	Movlw 148
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 50
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 70
	Call Rsout
	Call Rsout
	Goto bc@LL6
bc@LL5
F1_000031 equ $ ; in [MACHROM.BAS] ELSE
F1_000032 equ $ ; in [MACHROM.BAS] rsout at 3, 1 , "Switch #2 = ON "
	Movlw 64
	Movwf BPFH
	Movlw 148
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 50
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 78
	Call Rsout
	Movlw 32
	Call Rsout
F1_000033 equ $ ; in [MACHROM.BAS] ENDIF
bc@LL6
F1_000035 equ $ ; in [MACHROM.BAS] delayms 500
	Movlw 1
	Movwf PP1H
	Movlw 244
	Call dly@w
SWITCH_3
F1_000038 equ $ ; in [MACHROM.BAS] OWrite DQ, 1, [$55,$05,$B4,$BF,$08,$00,$00,$00,$2E]
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 1
	Movwf GPR
	Call Ow@rst2
	Movlw 85
	Call ow@out
	Movlw 5
	Call ow@out
	Movlw 180
	Call ow@out
	Movlw 191
	Call ow@out
	Movlw 8
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Clrw
	Call ow@out
	Movlw 46
	Call ow@out
F1_000039 equ $ ; in [MACHROM.BAS] Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
	Movlw PORTB
	Movwf GEN
	Movlw 128
	Movwf GENH
	Movlw 4
	Movwf GPR
	Call Ow@in
	Andlw 1
	Skpnz
	Bcf _B#VR1,0
	Skpz
	Bsf _B#VR1,0
F1_000040 equ $ ; in [MACHROM.BAS] IF Stat = 0 THEN
	Btfsc _B#VR1,0
	Goto bc@LL8
F1_000041 equ $ ; in [MACHROM.BAS] rsout at 4, 1 , "Switch #3 = OFF"
	Movlw 64
	Movwf BPFH
	Movlw 212
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 51
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 70
	Call Rsout
	Call Rsout
	Goto bc@LL9
bc@LL8
F1_000042 equ $ ; in [MACHROM.BAS] ELSE
F1_000043 equ $ ; in [MACHROM.BAS] rsout at 4, 1 , "Switch #3 = ON "
	Movlw 64
	Movwf BPFH
	Movlw 212
	Call curs@
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
	Movlw 35
	Call Rsout
	Movlw 51
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 61
	Call Rsout
	Movlw 32
	Call Rsout
	Movlw 79
	Call Rsout
	Movlw 78
	Call Rsout
	Movlw 32
	Call Rsout
F1_000044 equ $ ; in [MACHROM.BAS] ENDIF
bc@LL9
F1_000046 equ $ ; in [MACHROM.BAS] delayms 500
	Movlw 1
	Movwf PP1H
	Movlw 244
	Call dly@w
F1_000048 equ $ ; in [MACHROM.BAS] Goto Switch_1
	Goto SWITCH_1
F1_000049 equ $ ; in [MACHROM.BAS] END
Pb@lb11
	Sleep
	Goto Pb@lb11
F1_EOF equ $ ; MACHROM.BAS
	END

