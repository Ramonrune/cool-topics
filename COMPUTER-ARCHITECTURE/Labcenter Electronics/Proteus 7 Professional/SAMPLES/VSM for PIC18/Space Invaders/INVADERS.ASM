;*******************************************************
;*                 Code Produced by the                *
;*             PROTON+ Compiler. Version 3.0           *
;* Copyright Rosetta Technologies/Crownhill Associates *
;*              Written by Les Johnson. 2004           *
;*******************************************************
 NOLIST
 #include "D:\PRODEV\VSM\BASIC\ISIS_DSNS\INVADERS\INVADERS.PBP"
 LIST

 BASE_ENABLED = 61
 Variable BASE_ENABLED#0=61,BASE_ENABLED#1=62,BASE_ENABLED#2=63,BASE_ENABLED#3=64,BASE_ENABLED#4=65,BASE_ENABLED#5=66
 Variable BASE_ENABLED#6=67,BASE_ENABLED#7=68,BASE_ENABLED#8=69
 BASE_HITS = 70
 Variable BASE_HITS#0=70,BASE_HITS#1=71,BASE_HITS#2=72,BASE_HITS#3=73,BASE_HITS#4=74,BASE_HITS#5=75
 Variable BASE_HITS#6=76,BASE_HITS#7=77,BASE_HITS#8=78
 INVADER_XPOS = 79
 Variable INVADER_XPOS#0=79,INVADER_XPOS#1=80,INVADER_XPOS#2=81,INVADER_XPOS#3=82,INVADER_XPOS#4=83,INVADER_XPOS#5=84
 Variable INVADER_XPOS#6=85,INVADER_XPOS#7=86,INVADER_XPOS#8=87,INVADER_XPOS#9=88,INVADER_XPOS#10=89,INVADER_XPOS#11=90
 Variable INVADER_XPOS#12=91,INVADER_XPOS#13=92,INVADER_XPOS#14=93,INVADER_XPOS#15=94,INVADER_XPOS#16=95,INVADER_XPOS#17=96
 INVADER_YPOS = 97
 Variable INVADER_YPOS#0=97,INVADER_YPOS#1=98,INVADER_YPOS#2=99,INVADER_YPOS#3=100,INVADER_YPOS#4=101,INVADER_YPOS#5=102
 Variable INVADER_YPOS#6=103,INVADER_YPOS#7=104,INVADER_YPOS#8=105,INVADER_YPOS#9=106,INVADER_YPOS#10=107,INVADER_YPOS#11=108
 Variable INVADER_YPOS#12=109,INVADER_YPOS#13=110,INVADER_YPOS#14=111,INVADER_YPOS#15=112,INVADER_YPOS#16=113,INVADER_YPOS#17=114
 INVADER_ENABLED = 115
 Variable INVADER_ENABLED#0=115,INVADER_ENABLED#1=116,INVADER_ENABLED#2=117,INVADER_ENABLED#3=118,INVADER_ENABLED#4=119,INVADER_ENABLED#5=120
 Variable INVADER_ENABLED#6=121,INVADER_ENABLED#7=122,INVADER_ENABLED#8=123,INVADER_ENABLED#9=124,INVADER_ENABLED#10=125,INVADER_ENABLED#11=126
 Variable INVADER_ENABLED#12=127,INVADER_ENABLED#13=128,INVADER_ENABLED#14=129,INVADER_ENABLED#15=130,INVADER_ENABLED#16=131,INVADER_ENABLED#17=132
 SHIP_XPOS = 133
 MISSILE_YPOS = 134
 MISSILE_XPOS = 135
 SHIP_SPEED = 136
 INVADER_TICK = 137
 INVADER_MISSILE_TICK = 138
 SHIP_MISSILE_TICK = 139
 TEMP_LOOP = 140
 INVADERS_ENABLED = 141
 INVADER_SPEED = 142
 BASE_XPOS_TEST = 143
 INVADER_MISSILE_YPOS = 144
 INVADER_MISSILE_XPOS = 145
 INVADER_MISSILE_SPEED = 146
 DEFAULT_INVADER_SPEED = 147
 INVADER_MISSILE2_TICK = 148
 INVADER_MISSILE2_YPOS = 149
 INVADER_MISSILE2_XPOS = 150
 INVADER_MISSILE2_SPEED = 151
 SAUCER_XPOS = 152
 SAUCER_SPEED = 153
 SCORE = 154
 SCOREH = 155
 SCOREHH = 156
 SCOREHHH = 157
 LEVEL = 158
 LEVELH = 159
 LIVES = 160
 RANDOM_VALUE = 161
	#Define INVADER_SOUND_ENABLE NOTE_STATUS,0
	#Define MISSILE_SOUND_ENABLE NOTE_STATUS,1
	#Define SAUCER_SOUND_ENABLE NOTE_STATUS,2
	#Define INTERNAL_INVADER_SOUND_ENABLE NOTE_STATUS,4
	#Define MISSILE_FIRED MISSILE_STATUS,0
	#Define MISSILE_HIT MISSILE_STATUS,1
	#Define TIME_TO_MOVE_INVADERS MISSILE_STATUS,7
	#Define BASE_HIT MISSILE_STATUS,2
	#Define TIME_TO_MOVE_SHIP_MISSILE MISSILE_STATUS,3
	#Define TIME_TO_MOVE_BASE _B#VR1,0
	#Define INVADERS_DIRECTION _B#VR1,1
	#Define SHIP_HIT _B#VR1,2
	#Define TIME_TO_MOVE_INV_MISSILE MISSILE_STATUS,4
	#Define INVADER_MISSILE_FIRED MISSILE_STATUS,5
	#Define INVADER_MISSILE_HIT MISSILE_STATUS,6
	#Define TIME_TO_MOVE_INVADERS_DOWN _B#VR1,3
	#Define INVADERS_REACHED_BOTTOM _B#VR1,4
	#Define INVADER_CHARACTER _B#VR1,5
	#Define TIME_TO_MOVE_INV_MISSILE2 _B#VR1,6
	#Define INVADER_MISSILE2_FIRED _B#VR1,7
	#Define INVADER_MISSILE2_HIT _B#VR2,0
	#Define SAUCER_HIT _B#VR2,1
	#Define TIME_TO_MOVE_SAUCER _B#VR2,2
	#Define SAUCER_ENABLED _B#VR2,3
	#Define L_BUTTON PORTB,0
	#Define R_BUTTON PORTB,1
	#Define FIRE_BUTTON PORTB,2
	#Define SPEAKER PORTB,3
	#Define SHIP_WIDTH 9
	#Define INVADER_WIDTH 10
	#Define INVADER_RIGHT_LIMIT 117
	#Define SAUCER_WIDTH 14
	#Define TRUE 1
	#Define FALSE 0
	#Define FORWARD 1
	#Define BACKWARD 0
	#Define T0IF INTCON,2
	#Define GIE INTCON,7
F1_SOF equ $ ; INVADERS.BAS
F2_SOF equ $ ; PROTON18_G8.INT
F2_000068 equ $ ; in [PROTON18_G8.INT] ALL_DIGITAL = True ' Set PORTA and PORTE to all digital
	Movlw 7
	Movwf ADCON1
F2_EOF equ $ ; PROTON18_G8.INT
F1_000137 equ $ ; in [INVADERS.BAS] Input L_BUTTON
	Bsf TRISB,0
F1_000138 equ $ ; in [INVADERS.BAS] Input R_BUTTON
	Bsf TRISB,1
F1_000139 equ $ ; in [INVADERS.BAS] Input FIRE_BUTTON
	Bsf TRISB,2
F1_000140 equ $ ; in [INVADERS.BAS] Delayms 200           ' Wait for the PICmicro to stabilise
	Movlw 200
	F@Call dl@ms
F1_000141 equ $ ; in [INVADERS.BAS] PORTB_PULLUPS = ON
	Bcf INTCON2,7
F1_000142 equ $ ; in [INVADERS.BAS] Cls             ' Clear the LCD
	F@Call GLcd@Cls
F1_000143 equ $ ; in [INVADERS.BAS] Goto MAIN_PROGRAM_LOOP        ' Jump over any subroutines
	F@Jump MAIN_PROGRAM_LOOP
CLEAR_INVADER_MISSILE
F1_000148 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS
	Movff INVADER_MISSILE_YPOS,GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000149 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS + 1
	Movff INVADER_MISSILE_YPOS,GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000150 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS
	Incf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000151 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS + 1
	Incf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000152 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS
	Movlw 2
	Addwf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000153 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS + 1
	Movlw 2
	Addwf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000154 equ $ ; in [INVADERS.BAS] Return
	Return
DRAW_INVADER_MISSILE
F1_000156 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS
	Movff INVADER_MISSILE_YPOS,GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000157 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS + 1
	Movff INVADER_MISSILE_YPOS,GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000158 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS
	Incf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000159 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS + 1
	Incf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000160 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS
	Movlw 2
	Addwf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000161 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS + 1
	Movlw 2
	Addwf INVADER_MISSILE_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000162 equ $ ; in [INVADERS.BAS] Return
	Return
CLEAR_INVADER_MISSILE2
F1_000167 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS
	Movff INVADER_MISSILE2_YPOS,GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000168 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS + 1
	Movff INVADER_MISSILE2_YPOS,GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000169 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS
	Incf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000170 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS + 1
	Incf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000171 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS
	Movlw 2
	Addwf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000172 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS + 1
	Movlw 2
	Addwf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000173 equ $ ; in [INVADERS.BAS] Return
	Return
DRAW_INVADER_MISSILE2
F1_000175 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS
	Movff INVADER_MISSILE2_YPOS,GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000176 equ $ ; in [INVADERS.BAS] UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS + 1
	Movff INVADER_MISSILE2_YPOS,GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@UnPlot
F1_000177 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS
	Incf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@Plot
F1_000178 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS + 1
	Incf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@Plot
F1_000179 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS
	Movlw 2
	Addwf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Movf INVADER_MISSILE2_XPOS,W
	F@Call LCD@Plot
F1_000180 equ $ ; in [INVADERS.BAS] Plot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS + 1
	Movlw 2
	Addwf INVADER_MISSILE2_YPOS,W
	Movwf GEN
	Incf INVADER_MISSILE2_XPOS,W
	F@Call LCD@Plot
F1_000181 equ $ ; in [INVADERS.BAS] Return
	Return
UPDATE_BASES
F1_000185 equ $ ; in [INVADERS.BAS] Print at 6,2,2 + BASE_HITS#0,8 + BASE_HITS#1,14 + BASE_HITS#2,_
	Movlw 6
	Movwf GEN
	Movlw 2
	F@Call GLCD_Cur
	Movlw 2
	Addwf BASE_HITS#0,W
	Movwf PP2
	F@Call Print
	Movlw 8
	Addwf BASE_HITS#1,W
	Movwf PP2
	F@Call Print
	Movlw 14
	Addwf BASE_HITS#2,W
	Movwf PP2
	F@Call Print
	Movlw 6
	Movwf GEN
	Movlw 9
	F@Call GLCD_Cur
	Movlw 2
	Addwf BASE_HITS#3,W
	Movwf PP2
	F@Call Print
	Movlw 8
	Addwf BASE_HITS#4,W
	Movwf PP2
	F@Call Print
	Movlw 14
	Addwf BASE_HITS#5,W
	Movwf PP2
	F@Call Print
	Movlw 6
	Movwf GEN
	Movlw 15
	F@Call GLCD_Cur
	Movlw 2
	Addwf BASE_HITS#6,W
	Movwf PP2
	F@Call Print
	Movlw 8
	Addwf BASE_HITS#7,W
	Movwf PP2
	F@Call Print
	Movlw 14
	Addwf BASE_HITS#8,W
	Movwf PP2
	F@Call Print
F1_000188 equ $ ; in [INVADERS.BAS] Return
	Return
CHECK_BASE_HIT
F1_000194 equ $ ; in [INVADERS.BAS] BASE_HIT = FALSE          ' Default to no hit detected
	Bcf MISSILE_STATUS,2
F1_000195 equ $ ; in [INVADERS.BAS] Select BASE_XPOS_TEST
F1_000196 equ $ ; in [INVADERS.BAS] Case 12 to 17          ' Has the missile XPOS hit BASE 1, ELEMENT 0
	Movlw 11
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL2
	Movlw 18
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL2
F1_000197 equ $ ; in [INVADERS.BAS] If BASE_HITS#0 < 5 AND BASE_ENABLED#0 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#0,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#0,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL5
F1_000198 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#0        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#0,F
F1_000199 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL6
bc@LL5
F1_000200 equ $ ; in [INVADERS.BAS] Else
F1_000201 equ $ ; in [INVADERS.BAS] BASE_ENABLED#0 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#0
F1_000202 equ $ ; in [INVADERS.BAS] Endif
bc@LL6
	F@Jump bc@LL1
bc@LL2
F1_000203 equ $ ; in [INVADERS.BAS] Case 18 to 23          ' Has the missile XPOS hit BASE 1, ELEMENT 1
	Movlw 17
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL8
	Movlw 24
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL8
F1_000204 equ $ ; in [INVADERS.BAS] If BASE_HITS#1 < 5 AND BASE_ENABLED#1 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#1,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#1,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL10
F1_000205 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#1        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#1,F
F1_000206 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL11
bc@LL10
F1_000207 equ $ ; in [INVADERS.BAS] Else
F1_000208 equ $ ; in [INVADERS.BAS] BASE_ENABLED#1 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#1
F1_000209 equ $ ; in [INVADERS.BAS] Endif
bc@LL11
	F@Jump bc@LL1
bc@LL8
F1_000210 equ $ ; in [INVADERS.BAS] Case 24 to 29          ' Has the missile XPOS hit BASE 1, ELEMENT 2
	Movlw 23
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL13
	Movlw 30
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL13
F1_000211 equ $ ; in [INVADERS.BAS] If BASE_HITS#2 < 5 AND BASE_ENABLED#2 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#2,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#2,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL15
F1_000212 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#2        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#2,F
F1_000213 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL16
bc@LL15
F1_000214 equ $ ; in [INVADERS.BAS] Else
F1_000215 equ $ ; in [INVADERS.BAS] BASE_ENABLED#2 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#2
F1_000216 equ $ ; in [INVADERS.BAS] Endif
bc@LL16
	F@Jump bc@LL1
bc@LL13
F1_000217 equ $ ; in [INVADERS.BAS] Case 54 to 59          ' Has the missile XPOS hit BASE 2, ELEMENT 3
	Movlw 53
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL18
	Movlw 60
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL18
F1_000218 equ $ ; in [INVADERS.BAS] If BASE_HITS#3 < 5 AND BASE_ENABLED#3 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#3,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#3,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL20
F1_000219 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#3        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#3,F
F1_000220 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL21
bc@LL20
F1_000221 equ $ ; in [INVADERS.BAS] Else
F1_000222 equ $ ; in [INVADERS.BAS] BASE_ENABLED#3 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#3
F1_000223 equ $ ; in [INVADERS.BAS] Endif
bc@LL21
	F@Jump bc@LL1
bc@LL18
F1_000224 equ $ ; in [INVADERS.BAS] Case 60 to 65          ' Has the missile XPOS hit BASE 2, ELEMENT 4
	Movlw 59
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL23
	Movlw 66
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL23
F1_000225 equ $ ; in [INVADERS.BAS] If BASE_HITS#4 < 5 AND BASE_ENABLED#4 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#4,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#4,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL25
F1_000226 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#4        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#4,F
F1_000227 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL26
bc@LL25
F1_000228 equ $ ; in [INVADERS.BAS] Else
F1_000229 equ $ ; in [INVADERS.BAS] BASE_ENABLED#4 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#4
F1_000230 equ $ ; in [INVADERS.BAS] Endif
bc@LL26
	F@Jump bc@LL1
bc@LL23
F1_000231 equ $ ; in [INVADERS.BAS] Case 66 to 71          ' Has the missile XPOS hit BASE 2, ELEMENT 5
	Movlw 65
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL28
	Movlw 72
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL28
F1_000232 equ $ ; in [INVADERS.BAS] If BASE_HITS#5 < 5 AND BASE_ENABLED#5 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#5,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#5,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL30
F1_000233 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#5        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#5,F
F1_000234 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL31
bc@LL30
F1_000235 equ $ ; in [INVADERS.BAS] Else
F1_000236 equ $ ; in [INVADERS.BAS] BASE_ENABLED#5 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#5
F1_000237 equ $ ; in [INVADERS.BAS] Endif
bc@LL31
	F@Jump bc@LL1
bc@LL28
F1_000238 equ $ ; in [INVADERS.BAS] Case 90 to 95          ' Has the missile XPOS hit BASE 3, ELEMENT 6
	Movlw 89
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL33
	Movlw 96
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL33
F1_000239 equ $ ; in [INVADERS.BAS] If BASE_HITS#6 < 5 AND BASE_ENABLED#6 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#6,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#6,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL35
F1_000240 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#6        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#6,F
F1_000241 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL36
bc@LL35
F1_000242 equ $ ; in [INVADERS.BAS] Else
F1_000243 equ $ ; in [INVADERS.BAS] BASE_ENABLED#6 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#6
F1_000244 equ $ ; in [INVADERS.BAS] Endif
bc@LL36
	F@Jump bc@LL1
bc@LL33
F1_000245 equ $ ; in [INVADERS.BAS] Case 96 to 101          ' Has the missile XPOS hit BASE 3, ELEMENT 7
	Movlw 95
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL38
	Movlw 102
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL38
F1_000246 equ $ ; in [INVADERS.BAS] If BASE_HITS#7 < 5 AND BASE_ENABLED#7 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#7,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#7,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL40
F1_000247 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#7        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#7,F
F1_000248 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL41
bc@LL40
F1_000249 equ $ ; in [INVADERS.BAS] Else
F1_000250 equ $ ; in [INVADERS.BAS] BASE_ENABLED#7 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#7
F1_000251 equ $ ; in [INVADERS.BAS] Endif
bc@LL41
	F@Jump bc@LL1
bc@LL38
F1_000252 equ $ ; in [INVADERS.BAS] Case 102 to 107          ' Has the missile XPOS hit BASE 3, ELEMENT 8
	Movlw 101
	Cpfsgt BASE_XPOS_TEST
	F@Jump bc@LL43
	Movlw 108
	Cpfslt BASE_XPOS_TEST
	F@Jump bc@LL43
F1_000253 equ $ ; in [INVADERS.BAS] If BASE_HITS#8 < 5 AND BASE_ENABLED#8 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
	Movlw 5
	Subwf BASE_HITS#8,W
	Movlw 1
	Btfsc STATUS,0
	Clrw
	Movwf SP#P9
	Movff BASE_ENABLED#8,PP0
	Movlw 1
	F@Call t@eb
	Andwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL45
F1_000254 equ $ ; in [INVADERS.BAS] Inc BASE_HITS#8        ' Increment the amount of hits the base element has sustained
	Incf BASE_HITS#8,F
F1_000255 equ $ ; in [INVADERS.BAS] BASE_HIT = TRUE        ' Indicate a missile has hit a target
	Bsf MISSILE_STATUS,2
	F@Jump bc@LL46
bc@LL45
F1_000256 equ $ ; in [INVADERS.BAS] Else
F1_000257 equ $ ; in [INVADERS.BAS] BASE_ENABLED#8 = FALSE      ' Disable the base element
	Clrf BASE_ENABLED#8
F1_000258 equ $ ; in [INVADERS.BAS] Endif
bc@LL46
F1_000259 equ $ ; in [INVADERS.BAS] End Select
bc@LL43
bc@LL1
F1_000260 equ $ ; in [INVADERS.BAS] If BASE_HIT = TRUE Then Gosub UPDATE_BASES   ' Update the base shapes if a hit was detected
	Btfss MISSILE_STATUS,2
	Go@to bc@LL48
	F@Call UPDATE_BASES
bc@LL48
F1_000261 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_INVADER_MISSILE
F1_000268 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_FIRED = TRUE Then          ' Don't enter the routine if the invader's missile is already flying
	Btfss MISSILE_STATUS,5
	Go@to bc@LL50
F1_000269 equ $ ; in [INVADERS.BAS] If TIME_TO_MOVE_INV_MISSILE = TRUE Then       ' Is it time to move the invader's missile ?
	Btfss MISSILE_STATUS,4
	Go@to bc@LL52
F1_000270 equ $ ; in [INVADERS.BAS] Gosub DRAW_INVADER_MISSILE
	F@Call DRAW_INVADER_MISSILE
F1_000271 equ $ ; in [INVADERS.BAS] Inc INVADER_MISSILE_YPOS
	Incf INVADER_MISSILE_YPOS,F
F1_000272 equ $ ; in [INVADERS.BAS] Endif
bc@LL52
F1_000273 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_YPOS >= 63 OR INVADER_MISSILE_HIT = TRUE Then ' Has the invader's missile reached the bottom of the display or hit something ?
	Movlw 63
	Subwf INVADER_MISSILE_YPOS,W
	Clrw
	Btfsc STATUS,0
	Movlw 1
	Movwf SP#P9
	Clrw
	Btfsc MISSILE_STATUS,6
	Movlw 1
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL54
F1_000274 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_FIRED = FALSE        ' Yes. So signal the invader's missile is finished
	Bcf MISSILE_STATUS,5
F1_000275 equ $ ; in [INVADERS.BAS] Gosub CLEAR_INVADER_MISSILE         ' Clear the invader's missile
	F@Call CLEAR_INVADER_MISSILE
F1_000276 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_HIT = FALSE
	Bcf MISSILE_STATUS,6
F1_000277 equ $ ; in [INVADERS.BAS] Endif
bc@LL54
F1_000278 equ $ ; in [INVADERS.BAS] Endif
bc@LL50
F1_000279 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_INVADER_MISSILE2
F1_000286 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_FIRED = TRUE Then          ' Don't enter the routine if the invader's missile is already flying
	Btfss _B#VR1,7
	Go@to bc@LL56
F1_000287 equ $ ; in [INVADERS.BAS] If TIME_TO_MOVE_INV_MISSILE2 = TRUE Then       ' Is it time to move the invader's missile ?
	Btfss _B#VR1,6
	Go@to bc@LL58
F1_000288 equ $ ; in [INVADERS.BAS] Gosub DRAW_INVADER_MISSILE2
	F@Call DRAW_INVADER_MISSILE2
F1_000289 equ $ ; in [INVADERS.BAS] Inc INVADER_MISSILE2_YPOS
	Incf INVADER_MISSILE2_YPOS,F
F1_000290 equ $ ; in [INVADERS.BAS] Endif
bc@LL58
F1_000291 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_YPOS >= 63 OR INVADER_MISSILE2_HIT = TRUE Then ' Has the invader's missile reached the bottom of the display or hit something ?
	Movlw 63
	Subwf INVADER_MISSILE2_YPOS,W
	Clrw
	Btfsc STATUS,0
	Movlw 1
	Movwf SP#P9
	Clrw
	Btfsc _B#VR2,0
	Movlw 1
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL60
F1_000292 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_FIRED = FALSE        ' Yes. So signal the invader's missile is finished
	Bcf _B#VR1,7
F1_000293 equ $ ; in [INVADERS.BAS] Gosub CLEAR_INVADER_MISSILE2         ' Clear the invader's missile
	F@Call CLEAR_INVADER_MISSILE2
F1_000294 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_HIT = FALSE
	Bcf _B#VR2,0
F1_000295 equ $ ; in [INVADERS.BAS] Endif
bc@LL60
F1_000296 equ $ ; in [INVADERS.BAS] Endif
bc@LL56
F1_000297 equ $ ; in [INVADERS.BAS] Return
	Return
FIRE_INVADER_MISSILE
F1_000306 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_FIRED = FALSE Then          ' Is it OK to fire an invader missile ?
	Btfsc MISSILE_STATUS,5
	Go@to bc@LL62
F1_000307 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000308 equ $ ; in [INVADERS.BAS] Repeat                       ' Create a loop for all the invaders
bc@LL63
F1_000309 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then       ' Is this invader enabled ?
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL66
F1_000310 equ $ ; in [INVADERS.BAS] Select INVADER_XPOS[INVADER_LOOP] + 5
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movlw 5
	Addwf PBP#VAR1,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
F1_000311 equ $ ; in [INVADERS.BAS] Case SHIP_XPOS to SHIP_XPOS + 8        ' Is the invader over the ship ?
	Movf PBP#VAR0H,W
	Bnz cp@lb2
	Movf SHIP_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL68
cp@lb2
	Movlw 8
	Addwf SHIP_XPOS,W
	Clrf PBP#VAR1H
	Movwf PBP#VAR1
	Rlcf PBP#VAR1H,F
	Movf PBP#VAR0,W
	Subwf PBP#VAR1,W
	Movf PBP#VAR0H,W
	Subwfb PBP#VAR1H,W
	Btfss STATUS,0
	Go@to bc@LL68
F1_000312 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_FIRED = TRUE       ' Signal that an invader's  missile is in the air
	Bsf MISSILE_STATUS,5
F1_000313 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_XPOS = INVADER_XPOS[INVADER_LOOP] + 5 ' Move missile XPOS to the middle of the invader
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movlw 5
	Addwf PBP#VAR1,W
	Movwf INVADER_MISSILE_XPOS
F1_000314 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_YPOS = (INVADER_YPOS[INVADER_LOOP] * 8) + 8 ' Move missile YPOS to below the invader
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movf PBP#VAR1,W
	Mullw 8
	Movff PRODL,PP7
	Movff PRODH,PP7H
	Movlw 8
	Addwf PP7,W
	Movwf INVADER_MISSILE_YPOS
F1_000315 equ $ ; in [INVADERS.BAS] End Select
bc@LL68
bc@LL67
F1_000316 equ $ ; in [INVADERS.BAS] Endif
bc@LL66
F1_000317 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000318 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17             ' Close the loop when all invaders have been scanned
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL63
bc@LL64
F1_000319 equ $ ; in [INVADERS.BAS] Endif
bc@LL62
F1_000320 equ $ ; in [INVADERS.BAS] Return
	Return
FIRE_INVADER_MISSILE2
F1_000330 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_FIRED = FALSE Then ' Is it OK to fire an invader second missile ?
	Btfsc _B#VR1,7
	Go@to bc@LL71
F1_000332 equ $ ; in [INVADERS.BAS] Select SHIP_XPOS
	Movf INVADER_MISSILE_XPOS,W
	Addwf RANDOM_VALUE,W
	Movwf PBP#VAR0
	Clrf PBP#VAR0H
	Rlcf PBP#VAR0H,F
F1_000333 equ $ ; in [INVADERS.BAS] Case > INVADER_MISSILE_XPOS + RANDOM_VALUE , < INVADER_MISSILE_XPOS - RANDOM_VALUE
	Movf PBP#VAR0H,W
	Bnz cp@lb4
	Movf SHIP_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL74
cp@lb4
	Movf RANDOM_VALUE,W
	Subwf INVADER_MISSILE_XPOS,W
	Movwf PBP#VAR0
	Clrf PBP#VAR0H
	Skpc
	Decf PBP#VAR0H,F
	Movf PBP#VAR0H,W
	Bnz cp@lb5
	Movf PBP#VAR0,W
	Cpfslt SHIP_XPOS
	F@Jump bc@LL73
cp@lb5
bc@LL74
F1_000334 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000335 equ $ ; in [INVADERS.BAS] Repeat                       ' Create a loop for all the invaders
bc@LL75
F1_000336 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then       ' Is this invader enabled ?
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL78
F1_000337 equ $ ; in [INVADERS.BAS] Select INVADER_XPOS[INVADER_LOOP] + 5
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movlw 5
	Addwf PBP#VAR1,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
F1_000338 equ $ ; in [INVADERS.BAS] Case SHIP_XPOS to SHIP_XPOS + 8        ' Is the invader over the ship ?
	Movf PBP#VAR0H,W
	Bnz cp@lb6
	Movf SHIP_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL80
cp@lb6
	Movlw 8
	Addwf SHIP_XPOS,W
	Clrf PBP#VAR1H
	Movwf PBP#VAR1
	Rlcf PBP#VAR1H,F
	Movf PBP#VAR0,W
	Subwf PBP#VAR1,W
	Movf PBP#VAR0H,W
	Subwfb PBP#VAR1H,W
	Btfss STATUS,0
	Go@to bc@LL80
F1_000339 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_FIRED = TRUE       ' Signal that an invader's  missile is in the air
	Bsf _B#VR1,7
F1_000340 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_XPOS = INVADER_XPOS[INVADER_LOOP] + 5 ' Move missile XPOS to the middle of the invader
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movlw 5
	Addwf PBP#VAR1,W
	Movwf INVADER_MISSILE2_XPOS
F1_000341 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_YPOS = (INVADER_YPOS[INVADER_LOOP] * 8) + 8 ' Move missile YPOS to below the invader
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movf PBP#VAR1,W
	Mullw 8
	Movff PRODL,PP7
	Movff PRODH,PP7H
	Movlw 8
	Addwf PP7,W
	Movwf INVADER_MISSILE2_YPOS
F1_000342 equ $ ; in [INVADERS.BAS] End Select
bc@LL80
bc@LL79
F1_000343 equ $ ; in [INVADERS.BAS] Endif
bc@LL78
F1_000344 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000345 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17             ' Close the loop when all invaders have been scanned
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL75
bc@LL76
F1_000346 equ $ ; in [INVADERS.BAS] EndSelect
bc@LL73
bc@LL72
F1_000348 equ $ ; in [INVADERS.BAS] Endif
bc@LL71
F1_000349 equ $ ; in [INVADERS.BAS] Return
	Return
CHECK_FOR_INVADER_MISSILE_HIT
F1_000354 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_HIT = FALSE            ' Default to not hit
	Bcf MISSILE_STATUS,6
F1_000355 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_FIRED = TRUE Then            ' First make sure that a missile is actually launched
	Btfss MISSILE_STATUS,5
	Go@to bc@LL83
F1_000357 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_YPOS >= 45 Then
	Movlw 44
	Cpfsgt INVADER_MISSILE_YPOS
	F@Jump bc@LL85
F1_000358 equ $ ; in [INVADERS.BAS] BASE_XPOS_TEST = INVADER_MISSILE_XPOS       ' Transfer the invader's missile XPOS for testing
	Movff INVADER_MISSILE_XPOS,BASE_XPOS_TEST
F1_000359 equ $ ; in [INVADERS.BAS] Gosub CHECK_BASE_HIT           ' Check if a base was hit
	F@Call CHECK_BASE_HIT
F1_000360 equ $ ; in [INVADERS.BAS] If BASE_HIT = TRUE Then
	Btfss MISSILE_STATUS,2
	Go@to bc@LL87
F1_000361 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_HIT = TRUE         ' Transfer the hit detector into the invader's missile detector
	Bsf MISSILE_STATUS,6
F1_000362 equ $ ; in [INVADERS.BAS] Return              ' Return from the subroutine prematurely
	Return
F1_000363 equ $ ; in [INVADERS.BAS] Endif
bc@LL87
F1_000364 equ $ ; in [INVADERS.BAS] Endif
bc@LL85
F1_000367 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_YPOS >= 56 Then
	Movlw 55
	Cpfsgt INVADER_MISSILE_YPOS
	F@Jump bc@LL89
F1_000368 equ $ ; in [INVADERS.BAS] Select INVADER_MISSILE_XPOS
	Movlw low (-1)
	Addwf SHIP_XPOS,W
	Movwf PBP#VAR0
	Movlw low ((-1) >> 8)
	Skpnc
	Addlw 1
	Movwf PBP#VAR0H
F1_000369 equ $ ; in [INVADERS.BAS] Case SHIP_XPOS - 1 To SHIP_XPOS + SHIP_WIDTH
	Movf PBP#VAR0H,W
	Btfss STATUS,2
	Go@to bc@LL91
	Movf PBP#VAR0,W
	Subwf INVADER_MISSILE_XPOS,W
	Btfss STATUS,0
	Go@to bc@LL91
	Movlw 9
	Addwf SHIP_XPOS,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
	Movf PBP#VAR0H,W
	Bnz cp@lb9
	Movf INVADER_MISSILE_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL91
cp@lb9
F1_000370 equ $ ; in [INVADERS.BAS] Gosub DRAW_SHIP
	F@Call DRAW_SHIP
F1_000371 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_HIT = TRUE        ' Indicate the invader's missile has hit something
	Bsf MISSILE_STATUS,6
F1_000372 equ $ ; in [INVADERS.BAS] SHIP_HIT = TRUE           ' Indicate that it is the ship that has been hit
	Bsf _B#VR1,2
F1_000373 equ $ ; in [INVADERS.BAS] End Select
bc@LL91
bc@LL90
F1_000374 equ $ ; in [INVADERS.BAS] Endif
bc@LL89
F1_000375 equ $ ; in [INVADERS.BAS] Endif
bc@LL83
F1_000376 equ $ ; in [INVADERS.BAS] Return
	Return
CHECK_FOR_INVADER_MISSILE2_HIT
F1_000381 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_HIT = FALSE           ' Default to not hit
	Bcf _B#VR2,0
F1_000382 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_FIRED = TRUE Then           ' First make sure that a second missile is actually launched
	Btfss _B#VR1,7
	Go@to bc@LL94
F1_000384 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_YPOS >= 45 Then
	Movlw 44
	Cpfsgt INVADER_MISSILE2_YPOS
	F@Jump bc@LL96
F1_000385 equ $ ; in [INVADERS.BAS] BASE_XPOS_TEST = INVADER_MISSILE2_XPOS       ' Transfer the invader's second missile XPOS for testing
	Movff INVADER_MISSILE2_XPOS,BASE_XPOS_TEST
F1_000386 equ $ ; in [INVADERS.BAS] Gosub CHECK_BASE_HIT           ' Check if a base was hit
	F@Call CHECK_BASE_HIT
F1_000387 equ $ ; in [INVADERS.BAS] If BASE_HIT = TRUE Then
	Btfss MISSILE_STATUS,2
	Go@to bc@LL98
F1_000388 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_HIT = TRUE         ' Transfer the hit detector into the invader's second missile detector
	Bsf _B#VR2,0
F1_000389 equ $ ; in [INVADERS.BAS] Return              ' Return from the subroutine prematurely
	Return
F1_000390 equ $ ; in [INVADERS.BAS] Endif
bc@LL98
F1_000391 equ $ ; in [INVADERS.BAS] Endif
bc@LL96
F1_000394 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_YPOS >= 56 Then
	Movlw 55
	Cpfsgt INVADER_MISSILE2_YPOS
	F@Jump bc@LL100
F1_000395 equ $ ; in [INVADERS.BAS] Select INVADER_MISSILE2_XPOS
	Movlw low (-1)
	Addwf SHIP_XPOS,W
	Movwf PBP#VAR0
	Movlw low ((-1) >> 8)
	Skpnc
	Addlw 1
	Movwf PBP#VAR0H
F1_000396 equ $ ; in [INVADERS.BAS] Case SHIP_XPOS - 1 To SHIP_XPOS + SHIP_WIDTH
	Movf PBP#VAR0H,W
	Btfss STATUS,2
	Go@to bc@LL102
	Movf PBP#VAR0,W
	Subwf INVADER_MISSILE2_XPOS,W
	Btfss STATUS,0
	Go@to bc@LL102
	Movlw 9
	Addwf SHIP_XPOS,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
	Movf PBP#VAR0H,W
	Bnz cp@lb11
	Movf INVADER_MISSILE2_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL102
cp@lb11
F1_000397 equ $ ; in [INVADERS.BAS] Gosub DRAW_SHIP
	F@Call DRAW_SHIP
F1_000398 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_HIT = TRUE        ' Indicate the invader's second missile has hit something
	Bsf _B#VR2,0
F1_000399 equ $ ; in [INVADERS.BAS] SHIP_HIT = TRUE           ' Indicate that it is the ship that has been hit
	Bsf _B#VR1,2
F1_000400 equ $ ; in [INVADERS.BAS] End Select
bc@LL102
bc@LL101
F1_000401 equ $ ; in [INVADERS.BAS] Endif
bc@LL100
F1_000402 equ $ ; in [INVADERS.BAS] Endif
bc@LL94
F1_000403 equ $ ; in [INVADERS.BAS] Return
	Return
CLEAR_MISSILE
F1_000407 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS, MISSILE_XPOS
	Movff MISSILE_YPOS,GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000408 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS, MISSILE_XPOS + 1
	Movff MISSILE_YPOS,GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000409 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 1, MISSILE_XPOS
	Incf MISSILE_YPOS,W
	Movwf GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000410 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 1, MISSILE_XPOS + 1
	Incf MISSILE_YPOS,W
	Movwf GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000411 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 2, MISSILE_XPOS
	Movlw 2
	Addwf MISSILE_YPOS,W
	Movwf GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000412 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 2, MISSILE_XPOS + 1
	Movlw 2
	Addwf MISSILE_YPOS,W
	Movwf GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000413 equ $ ; in [INVADERS.BAS] Return
	Return
DRAW_MISSILE
F1_000415 equ $ ; in [INVADERS.BAS] Plot MISSILE_YPOS, MISSILE_XPOS
	Movff MISSILE_YPOS,GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000416 equ $ ; in [INVADERS.BAS] Plot MISSILE_YPOS, MISSILE_XPOS + 1
	Movff MISSILE_YPOS,GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000417 equ $ ; in [INVADERS.BAS] Plot MISSILE_YPOS + 1, MISSILE_XPOS
	Incf MISSILE_YPOS,W
	Movwf GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000418 equ $ ; in [INVADERS.BAS] Plot MISSILE_YPOS + 1, MISSILE_XPOS + 1
	Incf MISSILE_YPOS,W
	Movwf GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@Plot
F1_000419 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 2, MISSILE_XPOS
	Movlw 2
	Addwf MISSILE_YPOS,W
	Movwf GEN
	Movf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000420 equ $ ; in [INVADERS.BAS] UnPlot MISSILE_YPOS + 2, MISSILE_XPOS + 1
	Movlw 2
	Addwf MISSILE_YPOS,W
	Movwf GEN
	Incf MISSILE_XPOS,W
	F@Call LCD@UnPlot
F1_000421 equ $ ; in [INVADERS.BAS] Return
	Return
DRAW_SHIP
F1_000425 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$00,$E0,$F0,$F0,$F8,$FC,$F8,$F0,$F0,$E0,$00]
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 252
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000426 equ $ ; in [INVADERS.BAS] Return
	Return
CHECK_FOR_MISSILE_HIT
F1_000431 equ $ ; in [INVADERS.BAS] MISSILE_HIT = FALSE            ' Default to not hit
	Bcf MISSILE_STATUS,1
F1_000432 equ $ ; in [INVADERS.BAS] SAUCER_HIT = FALSE            ' Default to saucer not hit
	Bcf _B#VR2,1
F1_000433 equ $ ; in [INVADERS.BAS] If MISSILE_FIRED = TRUE Then         ' First make sure a missile is actually launched
	Btfss MISSILE_STATUS,0
	Go@to bc@LL105
F1_000435 equ $ ; in [INVADERS.BAS] If MISSILE_YPOS  = 53 Then
	Movlw 53
	Cpfseq MISSILE_YPOS
	F@Jump bc@LL107
F1_000436 equ $ ; in [INVADERS.BAS] BASE_XPOS_TEST = MISSILE_XPOS       ' Transfer the ship's missile XPOS for testing
	Movff MISSILE_XPOS,BASE_XPOS_TEST
F1_000437 equ $ ; in [INVADERS.BAS] Gosub CHECK_BASE_HIT         ' Check if a base was hit
	F@Call CHECK_BASE_HIT
F1_000438 equ $ ; in [INVADERS.BAS] If BASE_HIT = TRUE Then
	Btfss MISSILE_STATUS,2
	Go@to bc@LL109
F1_000439 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 0       ' Disable the missile's sound
	Bcf NOTE_STATUS,1
F1_000440 equ $ ; in [INVADERS.BAS] MISSILE_HIT = TRUE         ' Transfer the hit detector into the missile detector
	Bsf MISSILE_STATUS,1
F1_000441 equ $ ; in [INVADERS.BAS] Return            ' And return from the subroutine prematurely
	Return
F1_000442 equ $ ; in [INVADERS.BAS] Endif
bc@LL109
F1_000443 equ $ ; in [INVADERS.BAS] Endif
bc@LL107
F1_000446 equ $ ; in [INVADERS.BAS] If MISSILE_XPOS = INVADER_MISSILE_XPOS Then If MISSILE_YPOS = INVADER_MISSILE_YPOS Then
	Movf MISSILE_XPOS,W
	Cpfseq INVADER_MISSILE_XPOS
	F@Jump bc@LL111
	Movf MISSILE_YPOS,W
	Cpfseq INVADER_MISSILE_YPOS
	F@Jump bc@LL113
F1_000447 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 0       ' Disable the missile's sound
	Bcf NOTE_STATUS,1
F1_000448 equ $ ; in [INVADERS.BAS] MISSILE_HIT = TRUE          ' Indicate the ship's missile has hit a target
	Bsf MISSILE_STATUS,1
F1_000449 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_HIT = TRUE        ' Indicate the invader's missile has also been hit
	Bsf MISSILE_STATUS,6
F1_000450 equ $ ; in [INVADERS.BAS] Inc SCORE            ' Increment the score by one
	Incf SCORE,F
	Movlw 0
	Addwfc SCOREH,F
	Addwfc SCOREHH,F
	Addwfc SCOREHHH,F
F1_000451 equ $ ; in [INVADERS.BAS] Return             ' And return from the subroutine prematurely
	Return
F1_000452 equ $ ; in [INVADERS.BAS] Endif
bc@LL113
bc@LL111
F1_000455 equ $ ; in [INVADERS.BAS] If SAUCER_ENABLED = TRUE Then
	Btfss _B#VR2,3
	Go@to bc@LL115
F1_000456 equ $ ; in [INVADERS.BAS] If MISSILE_YPOS < 7 Then
	Movlw 7
	Cpfslt MISSILE_YPOS
	F@Jump bc@LL117
F1_000457 equ $ ; in [INVADERS.BAS] Select MISSILE_XPOS
F1_000458 equ $ ; in [INVADERS.BAS] Case SAUCER_XPOS To SAUCER_XPOS  + SAUCER_WIDTH
	Movf SAUCER_XPOS,W
	Subwf MISSILE_XPOS,W
	Btfss STATUS,0
	Go@to bc@LL119
	Movlw 14
	Addwf SAUCER_XPOS,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
	Movf PBP#VAR0H,W
	Bnz cp@lb12
	Movf MISSILE_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL119
cp@lb12
F1_000459 equ $ ; in [INVADERS.BAS] MISSILE_HIT = TRUE       ' Indicate the ship's missile has hit a target
	Bsf MISSILE_STATUS,1
F1_000460 equ $ ; in [INVADERS.BAS] SAUCER_HIT = TRUE
	Bsf _B#VR2,1
F1_000461 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = TRUE
	Bsf NOTE_STATUS,2
F1_000462 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 30
	Movlw 30
	Movwf SAUCER_FREQ
F1_000463 equ $ ; in [INVADERS.BAS] LCDWRITE 0,SAUCER_XPOS,[$8C,$C5,$6B,$36,$0C,$20,$68,$CC,$96,$33,$69,$CC,$86,$02]
	Clrf GEN
	Movff SAUCER_XPOS,GENH
	Movlw 140
	F@Call Glcd@p
	Movlw 197
	F@Call Glcd@p
	Movlw 107
	F@Call Glcd@p
	Movlw 54
	F@Call Glcd@p
	Movlw 12
	F@Call Glcd@p
	Movlw 32
	F@Call Glcd@p
	Movlw 104
	F@Call Glcd@p
	Movlw 204
	F@Call Glcd@p
	Movlw 150
	F@Call Glcd@p
	Movlw 51
	F@Call Glcd@p
	Movlw 105
	F@Call Glcd@p
	Movlw 204
	F@Call Glcd@p
	Movlw 134
	F@Call Glcd@p
	Movlw 2
	F@Call Glcd@p
F1_000464 equ $ ; in [INVADERS.BAS] Delayms 10
	Movlw 10
	F@Call dl@ms
F1_000465 equ $ ; in [INVADERS.BAS] LCDWRITE 0,SAUCER_XPOS,[$7F,$08,$08,$08,$7F,$00,$00,$41,$7F,$41,$00,$00,$01,$01,$7F,$01,$01] ' Display text HIT
	Clrf GEN
	Movff SAUCER_XPOS,GENH
	Movlw 127
	F@Call Glcd@p
	Movlw 8
	F@Call Glcd@p
	Movlw 8
	F@Call Glcd@p
	Movlw 8
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 65
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Movlw 65
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 1
	F@Call Glcd@p
	Movlw 1
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Movlw 1
	F@Call Glcd@p
	Movlw 1
	F@Call Glcd@p
F1_000466 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 20
	Movlw 20
	Movwf SAUCER_FREQ
F1_000467 equ $ ; in [INVADERS.BAS] Delayms 5
	Movlw 5
	F@Call dl@ms
F1_000468 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 10
	Movlw 10
	Movwf SAUCER_FREQ
F1_000469 equ $ ; in [INVADERS.BAS] Delayms 10
	Movlw 10
	F@Call dl@ms
F1_000470 equ $ ; in [INVADERS.BAS] SCORE = SCORE + (100 + SAUCER_XPOS)    ' Add 100 + xpos to the score for hitting the saucer
	Clrf PP7HH
	Clrf PP7HHH
	Movlw 100
	Addwf SAUCER_XPOS,W
	Movwf PP7
	Movlw 0
	Clrf PP7H
	Addwfc PP7H,F
	Movf PP7,W
	Addwf SCORE,F
	Movf PP7H,W
	Addwfc SCOREH,F
	Movf PP7HH,W
	Addwfc SCOREHH,F
	Movf PP7HHH,W
	Addwfc SCOREHHH,F
F1_000471 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = FALSE
	Bcf NOTE_STATUS,2
F1_000472 equ $ ; in [INVADERS.BAS] Return
	Return
F1_000473 equ $ ; in [INVADERS.BAS] EndSelect
bc@LL119
bc@LL118
F1_000474 equ $ ; in [INVADERS.BAS] Endif
bc@LL117
F1_000475 equ $ ; in [INVADERS.BAS] Endif
bc@LL115
F1_000478 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000479 equ $ ; in [INVADERS.BAS] Repeat
bc@LL121
F1_000480 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then     ' Only check if the invader is enabled
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL124
F1_000481 equ $ ; in [INVADERS.BAS] If INVADER_YPOS[INVADER_LOOP] = MISSILE_YPOS / 8 Then
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Clrc
	Rrcf MISSILE_YPOS,W
	Movwf PBP#VAR1
	Clrc
	Rrcf PBP#VAR1,F
	Clrc
	Rrcf PBP#VAR1,F
	Clrf PBP#VAR1H
	Movf PBP#VAR1,W
	Cpfseq PBP#VAR0
	F@Jump bc@LL126
	Tstfsz PBP#VAR1H
	F@Jump bc@LL126
F1_000482 equ $ ; in [INVADERS.BAS] Select MISSILE_XPOS
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
F1_000483 equ $ ; in [INVADERS.BAS] Case INVADER_XPOS[INVADER_LOOP] to INVADER_XPOS[INVADER_LOOP] + INVADER_WIDTH
	Movf PBP#VAR0,W
	Subwf MISSILE_XPOS,W
	Btfss STATUS,0
	Go@to bc@LL128
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Movlw 10
	Addwf PBP#VAR1,W
	Clrf PBP#VAR0H
	Movwf PBP#VAR0
	Rlcf PBP#VAR0H,F
	Movf PBP#VAR0H,W
	Bnz cp@lb13
	Movf MISSILE_XPOS,W
	Subwf PBP#VAR0,W
	Btfss STATUS,0
	Go@to bc@LL128
cp@lb13
F1_000484 equ $ ; in [INVADERS.BAS] INVADER_ENABLED[INVADER_LOOP] = FALSE
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Clrf INDF0
F1_000485 equ $ ; in [INVADERS.BAS] MISSILE_HIT = TRUE       ' Indicate the ship's missile has hit a target
	Bsf MISSILE_STATUS,1
F1_000486 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 1
	Bsf NOTE_STATUS,1
F1_000487 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 30
	Movlw 30
	Movwf MISSILE_FREQ
F1_000488 equ $ ; in [INVADERS.BAS] Select INVADER_LOOP       ' Decide on the score depending on which invader is hit
F1_000489 equ $ ; in [INVADERS.BAS] Case 0 to 5        ' Top layer of invaders score 20
	Movlw 6
	Cpfslt INVADER_LOOP
	F@Jump bc@LL131
F1_000490 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$42,$61,$51,$49,$46,$00,$3E,$51,$49,$45,$3E,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Movlw 66
	F@Call Glcd@p
	Movlw 97
	F@Call Glcd@p
	Movlw 81
	F@Call Glcd@p
	Movlw 73
	F@Call Glcd@p
	Movlw 70
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 81
	F@Call Glcd@p
	Movlw 73
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000491 equ $ ; in [INVADERS.BAS] SCORE = SCORE + 20
	Movlw 20
	Addwf SCORE,F
	Movlw 0
	Addwfc SCOREH,F
	Addwfc SCOREHH,F
	Addwfc SCOREHHH,F
	F@Jump bc@LL130
bc@LL131
F1_000492 equ $ ; in [INVADERS.BAS] Case 6 to 11       ' Middle layer of invaders score 10
	Movlw 5
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL134
	Movlw 12
	Cpfslt INVADER_LOOP
	F@Jump bc@LL134
F1_000493 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$42,$7F,$40,$00,$00,$3E,$51,$49,$45,$3E,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 66
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Movlw 64
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 81
	F@Call Glcd@p
	Movlw 73
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000494 equ $ ; in [INVADERS.BAS] SCORE = SCORE + 10
	Movlw 10
	Addwf SCORE,F
	Movlw 0
	Addwfc SCOREH,F
	Addwfc SCOREHH,F
	Addwfc SCOREHHH,F
	F@Jump bc@LL130
bc@LL134
F1_000495 equ $ ; in [INVADERS.BAS] Case 12 to 17       ' Bottom layer of invaders score 5
	Movlw 11
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL136
	Movlw 18
	Cpfslt INVADER_LOOP
	F@Jump bc@LL136
F1_000496 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$3E,$51,$49,$45,$3E,$00, $27,$45,$45,$45,$39,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Movlw 62
	F@Call Glcd@p
	Movlw 81
	F@Call Glcd@p
	Movlw 73
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 39
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 69
	F@Call Glcd@p
	Movlw 57
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000497 equ $ ; in [INVADERS.BAS] SCORE = SCORE + 5
	Movlw 5
	Addwf SCORE,F
	Movlw 0
	Addwfc SCOREH,F
	Addwfc SCOREHH,F
	Addwfc SCOREHHH,F
F1_000498 equ $ ; in [INVADERS.BAS] EndSelect
bc@LL136
bc@LL130
F1_000499 equ $ ; in [INVADERS.BAS] Delayms 10
	Movlw 10
	F@Call dl@ms
F1_000500 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 20
	Movlw 20
	Movwf MISSILE_FREQ
F1_000501 equ $ ; in [INVADERS.BAS] Delayms 10
	Movlw 10
	F@Call dl@ms
F1_000502 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 10
	Movlw 10
	Movwf MISSILE_FREQ
F1_000503 equ $ ; in [INVADERS.BAS] Delayms 20
	Movlw 20
	F@Call dl@ms
F1_000504 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00] ' Erase the INVADER that was hit
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000507 equ $ ; in [INVADERS.BAS] Dec INVADERS_ENABLED      ' Decrement the hits counter
	Decf INVADERS_ENABLED,F
F1_000509 equ $ ; in [INVADERS.BAS] If INVADERS_ENABLED = 1 Then    ' Increase the speed substantially if only one invader left
	Decfsz INVADERS_ENABLED,W
	F@Jump bc@LL138
F1_000510 equ $ ; in [INVADERS.BAS] INVADER_SPEED = 5
	Movlw 5
	Movwf INVADER_SPEED
	F@Jump bc@LL137
F1_000511 equ $ ; in [INVADERS.BAS] Else if INVADERS_ENABLED = 2 Then
bc@LL138
	Movlw 2
	Cpfseq INVADERS_ENABLED
	F@Jump bc@LL139
F1_000512 equ $ ; in [INVADERS.BAS] INVADER_SPEED = 10      ' Increase the speed to fast if there are only two invaders left
	Movlw 10
	Movwf INVADER_SPEED
	F@Jump bc@LL140
bc@LL139
F1_000513 equ $ ; in [INVADERS.BAS] Else
F1_000515 equ $ ; in [INVADERS.BAS] If INVADER_SPEED >= 3 Then      ' Is the inveders speed greater than 3 ?
	Movlw 2
	Cpfsgt INVADER_SPEED
	F@Jump bc@LL142
F1_000516 equ $ ; in [INVADERS.BAS] If INVADERS_ENABLED <= 4 Then   ' Are there 4 or less invaders left ?
	Movlw 5
	Cpfslt INVADERS_ENABLED
	F@Jump bc@LL144
F1_000517 equ $ ; in [INVADERS.BAS] INVADER_SPEED = INVADER_SPEED - 3 ' Yes.. So increase their speed by a factor of three
	Movlw 3
	Subwf INVADER_SPEED,F
	F@Jump bc@LL145
bc@LL144
F1_000518 equ $ ; in [INVADERS.BAS] Else
F1_000519 equ $ ; in [INVADERS.BAS] Dec INVADER_SPEED     ' Otherwise.. Increase the speed of the remaining invaders
	Decf INVADER_SPEED,F
F1_000520 equ $ ; in [INVADERS.BAS] Endif
bc@LL145
F1_000521 equ $ ; in [INVADERS.BAS] Endif
bc@LL142
F1_000522 equ $ ; in [INVADERS.BAS] Endif
bc@LL140
bc@LL137
F1_000523 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 0     ' Disable the missile's sound
	Bcf NOTE_STATUS,1
F1_000524 equ $ ; in [INVADERS.BAS] Return          ' And return from the subroutine prematurely
	Return
F1_000525 equ $ ; in [INVADERS.BAS] Endselect
bc@LL128
bc@LL127
F1_000526 equ $ ; in [INVADERS.BAS] Endif
bc@LL126
F1_000527 equ $ ; in [INVADERS.BAS] Endif
bc@LL124
F1_000528 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000529 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL121
bc@LL122
F1_000530 equ $ ; in [INVADERS.BAS] Endif
bc@LL105
F1_000531 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_MISSILE
F1_000538 equ $ ; in [INVADERS.BAS] If MISSILE_FIRED = TRUE Then          ' Don't enter the routine if the ship's missile is already flying
	Btfss MISSILE_STATUS,0
	Go@to bc@LL147
F1_000539 equ $ ; in [INVADERS.BAS] If TIME_TO_MOVE_SHIP_MISSILE = TRUE Then    ' Is it time to move the ship's missile ?
	Btfss MISSILE_STATUS,3
	Go@to bc@LL149
F1_000540 equ $ ; in [INVADERS.BAS] Gosub DRAW_MISSILE
	F@Call DRAW_MISSILE
F1_000541 equ $ ; in [INVADERS.BAS] Dec MISSILE_YPOS
	Decf MISSILE_YPOS,F
F1_000542 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 63 - MISSILE_YPOS
	Movf MISSILE_YPOS,W
	Sublw 63
	Movwf MISSILE_FREQ
F1_000543 equ $ ; in [INVADERS.BAS] Endif
bc@LL149
F1_000544 equ $ ; in [INVADERS.BAS] If MISSILE_YPOS = 0 OR MISSILE_HIT = TRUE Then    ' Has the missile reached the top of the display or hit something ?
	Movff MISSILE_YPOS,PP0
	Clrw
	F@Call t@eb
	Movwf SP#P9
	Clrw
	Btfsc MISSILE_STATUS,1
	Movlw 1
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL151
F1_000545 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 0
	Bcf NOTE_STATUS,1
F1_000546 equ $ ; in [INVADERS.BAS] MISSILE_FIRED = FALSE        ' Yes. So signal the missile is finished
	Bcf MISSILE_STATUS,0
F1_000547 equ $ ; in [INVADERS.BAS] Gosub CLEAR_MISSILE         ' Clear the missile
	F@Call CLEAR_MISSILE
F1_000548 equ $ ; in [INVADERS.BAS] MISSILE_YPOS = 63 - 9             ' Reset the missile to the bottom of the display
	Movlw 54
	Movwf MISSILE_YPOS
F1_000549 equ $ ; in [INVADERS.BAS] Endif
bc@LL151
F1_000550 equ $ ; in [INVADERS.BAS] Endif
bc@LL147
F1_000551 equ $ ; in [INVADERS.BAS] Return
	Return
SHIP_RIGHT
F1_000555 equ $ ; in [INVADERS.BAS] If SHIP_XPOS > 117 Then Return
	Movlw 117
	Cpfsgt SHIP_XPOS
	F@Jump bc@LL153
	Return
bc@LL153
F1_000556 equ $ ; in [INVADERS.BAS] Gosub DRAW_SHIP
	F@Call DRAW_SHIP
F1_000557 equ $ ; in [INVADERS.BAS] Inc SHIP_XPOS
	Incf SHIP_XPOS,F
F1_000558 equ $ ; in [INVADERS.BAS] Return
	Return
SHIP_LEFT
F1_000562 equ $ ; in [INVADERS.BAS] If SHIP_XPOS = 0 Then Return
	Tstfsz SHIP_XPOS
	F@Jump bc@LL155
	Return
bc@LL155
F1_000563 equ $ ; in [INVADERS.BAS] Gosub DRAW_SHIP
	F@Call DRAW_SHIP
F1_000564 equ $ ; in [INVADERS.BAS] Dec SHIP_XPOS
	Decf SHIP_XPOS,F
F1_000565 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_INVADERS_DOWN
F1_000571 equ $ ; in [INVADERS.BAS] INVADERS_REACHED_BOTTOM = FALSE         ' Default to the invaders not at bottom of the screen
	Bcf _B#VR1,4
F1_000572 equ $ ; in [INVADERS.BAS] TEMP_LOOP = 18
	Movlw 18
	Movwf TEMP_LOOP
F1_000573 equ $ ; in [INVADERS.BAS] Repeat
bc@LL156
F1_000574 equ $ ; in [INVADERS.BAS] Dec TEMP_LOOP
	Decf TEMP_LOOP,F
F1_000575 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[TEMP_LOOP] = TRUE Then
	Lfsr 0,INVADER_ENABLED
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL159
F1_000576 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[TEMP_LOOP],INVADER_XPOS[TEMP_LOOP],[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00]
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000577 equ $ ; in [INVADERS.BAS] INVADER_YPOS[TEMP_LOOP] = INVADER_YPOS[TEMP_LOOP] + 1
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Incf PBP#VAR1,W
	Movwf PBP#VAR0
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000578 equ $ ; in [INVADERS.BAS] If INVADER_YPOS[TEMP_LOOP] = 6 Then      ' Have the invaders hit the bases ?
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Movlw 6
	Cpfseq PBP#VAR0
	F@Jump bc@LL161
F1_000579 equ $ ; in [INVADERS.BAS] Str BASE_ENABLED = 0,0,0,0,0,0,0,0,0     ' Yes.. So disable them all
	Clrf BASE_ENABLED#0
	Clrf BASE_ENABLED#1
	Clrf BASE_ENABLED#2
	Clrf BASE_ENABLED#3
	Clrf BASE_ENABLED#4
	Clrf BASE_ENABLED#5
	Clrf BASE_ENABLED#6
	Clrf BASE_ENABLED#7
	Clrf BASE_ENABLED#8
F1_000580 equ $ ; in [INVADERS.BAS] Str BASE_HITS = 5,5,5,5,5,5,5,5,5     ' And move their hit counters to past their thresholds
	Movlw 5
	Movwf BASE_HITS#0
	Movlw 5
	Movwf BASE_HITS#1
	Movlw 5
	Movwf BASE_HITS#2
	Movlw 5
	Movwf BASE_HITS#3
	Movlw 5
	Movwf BASE_HITS#4
	Movlw 5
	Movwf BASE_HITS#5
	Movlw 5
	Movwf BASE_HITS#6
	Movlw 5
	Movwf BASE_HITS#7
	Movlw 5
	Movwf BASE_HITS#8
F1_000581 equ $ ; in [INVADERS.BAS] Endif
bc@LL161
F1_000582 equ $ ; in [INVADERS.BAS] If INVADER_YPOS[TEMP_LOOP] >= 7 Then INVADERS_REACHED_BOTTOM = TRUE ' Set a flag if the invaders have reached the bottom
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Movlw 6
	Cpfsgt PBP#VAR0
	F@Jump bc@LL163
	Bsf _B#VR1,4
bc@LL163
F1_000583 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[TEMP_LOOP],INVADER_XPOS[TEMP_LOOP],[$00,$06,$0C,$9C,$EA,$36,$36,$EA,$9C,$0C,$06,$00]
	Lfsr 0,INVADER_YPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 6
	F@Call Glcd@p
	Movlw 12
	F@Call Glcd@p
	Movlw 156
	F@Call Glcd@p
	Movlw 234
	F@Call Glcd@p
	Movlw 54
	F@Call Glcd@p
	Movlw 54
	F@Call Glcd@p
	Movlw 234
	F@Call Glcd@p
	Movlw 156
	F@Call Glcd@p
	Movlw 12
	F@Call Glcd@p
	Movlw 6
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000584 equ $ ; in [INVADERS.BAS] Endif
bc@LL159
F1_000585 equ $ ; in [INVADERS.BAS] Until TEMP_LOOP = 0
	Tstfsz TEMP_LOOP
	F@Jump bc@LL156
bc@LL157
F1_000586 equ $ ; in [INVADERS.BAS] Inc INVADER_MISSILE_SPEED          ' Slow down the invader's missile speed as they approach the bottom of the screen
	Incf INVADER_MISSILE_SPEED,F
F1_000587 equ $ ; in [INVADERS.BAS] If INVADER_SPEED >= 3 Then Dec INVADER_SPEED     ' Increase the speed of the invaders
	Movlw 2
	Cpfsgt INVADER_SPEED
	F@Jump bc@LL165
	Decf INVADER_SPEED,F
bc@LL165
F1_000588 equ $ ; in [INVADERS.BAS] Return
	Return
RESET_INVADERS
F1_000595 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000596 equ $ ; in [INVADERS.BAS] Repeat
bc@LL166
F1_000597 equ $ ; in [INVADERS.BAS] INVADER_ENABLED[INVADER_LOOP] = TRUE      ' Set all invaders to active and image 1
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movlw 1
	Movwf INDF0
F1_000598 equ $ ; in [INVADERS.BAS] Select INVADER_LOOP
F1_000599 equ $ ; in [INVADERS.BAS] Case 0 to 5
	Movlw 6
	Cpfslt INVADER_LOOP
	F@Jump bc@LL169
F1_000600 equ $ ; in [INVADERS.BAS] INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP + 1) * 16
	Movlw 1
	Addwf INVADER_LOOP,W
	Clrf PP7H
	Movwf PP7
	Rlcf PP7H,F
	Movf PP7,W
	Mullw 16
	Movff PRODL,PBP#VAR0
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000601 equ $ ; in [INVADERS.BAS] INVADER_YPOS[INVADER_LOOP] = 1
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movlw 1
	Movwf INDF0
	F@Jump bc@LL168
bc@LL169
F1_000602 equ $ ; in [INVADERS.BAS] Case 6 to 11
	Movlw 5
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL172
	Movlw 12
	Cpfslt INVADER_LOOP
	F@Jump bc@LL172
F1_000603 equ $ ; in [INVADERS.BAS] INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP - 5) * 16
	Movlw low (-5)
	Addwf INVADER_LOOP,W
	Movwf PP7
	Movlw low ((-5) >> 8)
	Skpnc
	Addlw 1
	Movwf PP7H
	Movf PP7,W
	Mullw 16
	Movff PRODL,PBP#VAR0
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000604 equ $ ; in [INVADERS.BAS] INVADER_YPOS[INVADER_LOOP] = 2
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movlw 2
	Movwf INDF0
	F@Jump bc@LL168
bc@LL172
F1_000605 equ $ ; in [INVADERS.BAS] Case 12 to 17
	Movlw 11
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL174
	Movlw 18
	Cpfslt INVADER_LOOP
	F@Jump bc@LL174
F1_000606 equ $ ; in [INVADERS.BAS] INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP - 11) * 16
	Movlw low (-11)
	Addwf INVADER_LOOP,W
	Movwf PP7
	Movlw low ((-11) >> 8)
	Skpnc
	Addlw 1
	Movwf PP7H
	Movf PP7,W
	Mullw 16
	Movff PRODL,PBP#VAR0
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000607 equ $ ; in [INVADERS.BAS] INVADER_YPOS[INVADER_LOOP] = 3
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movlw 3
	Movwf INDF0
F1_000608 equ $ ; in [INVADERS.BAS] End Select
bc@LL174
bc@LL168
F1_000609 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000610 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL166
bc@LL167
F1_000611 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_INVADERS
F1_000617 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INVADERS_DOWN = FALSE
	Bcf _B#VR1,3
F1_000618 equ $ ; in [INVADERS.BAS] If INVADERS_DIRECTION = FORWARD Then       ' Are the invaders to move forward (right) ?
	Btfss _B#VR1,1
	Go@to bc@LL176
F1_000619 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0          ' Yes.. So reset the invader loop
	Clrf INVADER_LOOP
F1_000620 equ $ ; in [INVADERS.BAS] Repeat             ' Create a loop for all the invaders
bc@LL177
F1_000621 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then     ' Is this invader enabled ?
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL180
F1_000622 equ $ ; in [INVADERS.BAS] INVADER_XPOS[INVADER_LOOP] = INVADER_XPOS[INVADER_LOOP] + 1 ' Yes.. So increment its XPOS
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Incf PBP#VAR1,W
	Movwf PBP#VAR0
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000623 equ $ ; in [INVADERS.BAS] If INVADER_XPOS[INVADER_LOOP] >= INVADER_RIGHT_LIMIT Then  ' Have we hit the right side of the screen ?
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Movlw 116
	Cpfsgt PBP#VAR0
	F@Jump bc@LL182
F1_000624 equ $ ; in [INVADERS.BAS] INVADERS_DIRECTION = BACKWARD    ' Yes.. So indicate that we need to go backwards
	Bcf _B#VR1,1
F1_000625 equ $ ; in [INVADERS.BAS] SAUCER_ENABLED = TRUE
	Bsf _B#VR2,3
F1_000626 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INVADERS_DOWN = TRUE   ' and signal that we need to move the invaders down
	Bsf _B#VR1,3
F1_000627 equ $ ; in [INVADERS.BAS] Endif
bc@LL182
F1_000628 equ $ ; in [INVADERS.BAS] Endif
bc@LL180
F1_000629 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000630 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17         ' Close the loop after all the invader elements have been scanned
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL177
bc@LL178
	F@Jump bc@LL183
bc@LL176
F1_000631 equ $ ; in [INVADERS.BAS] Else              ' Otherwise we go backwards (left)
F1_000632 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0          ' Reset the invader loop
	Clrf INVADER_LOOP
F1_000633 equ $ ; in [INVADERS.BAS] Repeat             ' Create a loop for all the invaders
bc@LL184
F1_000634 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then        ' Is this invader enabled ?
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL187
F1_000635 equ $ ; in [INVADERS.BAS] INVADER_XPOS[INVADER_LOOP] = INVADER_XPOS[INVADER_LOOP] - 1 ' Yes.. So decrement its XPOS
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR1
	Decf PBP#VAR1,W
	Movwf PBP#VAR0
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movff PBP#VAR0,INDF0
F1_000636 equ $ ; in [INVADERS.BAS] If INVADER_XPOS[INVADER_LOOP] <= 1 Then      ' Have we hit the left side of the screen ?
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Movlw 2
	Cpfslt PBP#VAR0
	F@Jump bc@LL189
F1_000637 equ $ ; in [INVADERS.BAS] INVADERS_DIRECTION = FORWARD    ' Yes.. So indicate that we need to go forwards
	Bsf _B#VR1,1
F1_000638 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INVADERS_DOWN = TRUE   ' and signal that we need to move the invaders down
	Bsf _B#VR1,3
F1_000639 equ $ ; in [INVADERS.BAS] Endif
bc@LL189
F1_000640 equ $ ; in [INVADERS.BAS] Endif
bc@LL187
F1_000641 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000642 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17         ' Close the loop after all the invader elements have been scanned
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL184
bc@LL185
F1_000643 equ $ ; in [INVADERS.BAS] Endif
bc@LL183
F1_000644 equ $ ; in [INVADERS.BAS] If TIME_TO_MOVE_INVADERS_DOWN = TRUE Then Gosub MOVE_INVADERS_DOWN ' Do we need to move the invaders down ?
	Btfss _B#VR1,3
	Go@to bc@LL191
	F@Call MOVE_INVADERS_DOWN
bc@LL191
DRAW_INVADERS
F1_000660 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000661 equ $ ; in [INVADERS.BAS] Repeat
bc@LL192
F1_000662 equ $ ; in [INVADERS.BAS] If INVADER_ENABLED[INVADER_LOOP] = TRUE Then
	Lfsr 0,INVADER_ENABLED
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf PBP#VAR0
	Decfsz PBP#VAR0,W
	F@Jump bc@LL195
F1_000663 equ $ ; in [INVADERS.BAS] If INVADER_CHARACTER = 0 Then
	Btfsc _B#VR1,5
	Go@to bc@LL197
F1_000664 equ $ ; in [INVADERS.BAS] INVADER_SOUND_ENABLE = 0
	Bcf NOTE_STATUS,0
F1_000665 equ $ ; in [INVADERS.BAS] INVADER_FREQ = 90
	Movlw 90
	Movwf INVADER_FREQ
F1_000666 equ $ ; in [INVADERS.BAS] Select INVADER_LOOP       ' Decide on the score depending on which invader is hit
F1_000667 equ $ ; in [INVADERS.BAS] Case 0 to 5
	Movlw 6
	Cpfslt INVADER_LOOP
	F@Jump bc@LL199
F1_000668 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$18,$4C,$2E,$5B,$2F,$2F,$5B,$2E,$4C,$18,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 24
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 46
	F@Call Glcd@p
	Movlw 91
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 91
	F@Call Glcd@p
	Movlw 46
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 24
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	F@Jump bc@LL198
bc@LL199
F1_000669 equ $ ; in [INVADERS.BAS] Case 6 to 11
	Movlw 5
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL202
	Movlw 12
	Cpfslt INVADER_LOOP
	F@Jump bc@LL202
F1_000670 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$38,$0D,$3E,$5A,$1E,$1E,$5A,$3E,$0D,$38,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 56
	F@Call Glcd@p
	Movlw 13
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 90
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 90
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 13
	F@Call Glcd@p
	Movlw 56
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	F@Jump bc@LL198
bc@LL202
F1_000671 equ $ ; in [INVADERS.BAS] Case 12 to 17
	Movlw 11
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL204
	Movlw 18
	Cpfslt INVADER_LOOP
	F@Jump bc@LL204
F1_000672 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$4C,$6E,$3A,$1B,$2F,$2F,$1B,$3A,$6E,$4C,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 110
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 110
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000673 equ $ ; in [INVADERS.BAS] EndSelect
bc@LL204
bc@LL198
F1_000675 equ $ ; in [INVADERS.BAS] INVADER_SOUND_ENABLE = 1
	Bsf NOTE_STATUS,0
	F@Jump bc@LL205
bc@LL197
F1_000676 equ $ ; in [INVADERS.BAS] Else
F1_000677 equ $ ; in [INVADERS.BAS] INVADER_SOUND_ENABLE = 0
	Bcf NOTE_STATUS,0
F1_000678 equ $ ; in [INVADERS.BAS] INVADER_FREQ = 105
	Movlw 105
	Movwf INVADER_FREQ
F1_000679 equ $ ; in [INVADERS.BAS] Select INVADER_LOOP       ' Decide on the score depending on which invader is hit
F1_000680 equ $ ; in [INVADERS.BAS] Case 0 to 5
	Movlw 6
	Cpfslt INVADER_LOOP
	F@Jump bc@LL207
F1_000681 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$08,$2C,$5E,$0B,$1F,$1F,$0B,$5E,$2C,$08,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 8
	F@Call Glcd@p
	Movlw 44
	F@Call Glcd@p
	Movlw 94
	F@Call Glcd@p
	Movlw 11
	F@Call Glcd@p
	Movlw 31
	F@Call Glcd@p
	Movlw 31
	F@Call Glcd@p
	Movlw 11
	F@Call Glcd@p
	Movlw 94
	F@Call Glcd@p
	Movlw 44
	F@Call Glcd@p
	Movlw 8
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	F@Jump bc@LL206
bc@LL207
F1_000682 equ $ ; in [INVADERS.BAS] Case 6 to 11
	Movlw 5
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL210
	Movlw 12
	Cpfslt INVADER_LOOP
	F@Jump bc@LL210
F1_000683 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$06,$48,$7F,$1A,$1E,$1E,$1A,$7F,$48,$06,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 6
	F@Call Glcd@p
	Movlw 72
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Movlw 26
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 26
	F@Call Glcd@p
	Movlw 127
	F@Call Glcd@p
	Movlw 72
	F@Call Glcd@p
	Movlw 6
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	F@Jump bc@LL206
bc@LL210
F1_000684 equ $ ; in [INVADERS.BAS] Case 12 to 17
	Movlw 11
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL212
	Movlw 18
	Cpfslt INVADER_LOOP
	F@Jump bc@LL212
F1_000685 equ $ ; in [INVADERS.BAS] LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$0C,$0E,$3A,$4B,$1F,$1F,$4B,$3A,$0E,$0C,$00]
	Lfsr 0,INVADER_YPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GEN
	Lfsr 0,INVADER_XPOS
	Movf INVADER_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movf INDF0,W
	Movwf GENH
	Clrw
	F@Call Glcd@p
	Movlw 12
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 75
	F@Call Glcd@p
	Movlw 31
	F@Call Glcd@p
	Movlw 31
	F@Call Glcd@p
	Movlw 75
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 12
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000686 equ $ ; in [INVADERS.BAS] EndSelect
bc@LL212
bc@LL206
F1_000687 equ $ ; in [INVADERS.BAS] INVADER_SOUND_ENABLE = 1
	Bsf NOTE_STATUS,0
F1_000688 equ $ ; in [INVADERS.BAS] Endif
bc@LL205
F1_000689 equ $ ; in [INVADERS.BAS] Endif
bc@LL195
F1_000690 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000691 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 17
	Movlw 17
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL192
bc@LL193
F1_000692 equ $ ; in [INVADERS.BAS] Return
	Return
CLEAR_SAUCER
F1_000696 equ $ ; in [INVADERS.BAS] Lcdwrite 0,SAUCER_XPOS,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	Clrf GEN
	Movff SAUCER_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000697 equ $ ; in [INVADERS.BAS] Return
	Return
DRAW_SAUCER
F1_000701 equ $ ; in [INVADERS.BAS] Lcdwrite 0,SAUCER_XPOS,[$00,$04,$0E,$3A,$1B,$0F,$1B,$1B,$0F,$1B,$3A,$0E,$04,$00]
	Clrf GEN
	Movff SAUCER_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Movlw 4
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 15
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 15
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 4
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000702 equ $ ; in [INVADERS.BAS] Return
	Return
MOVE_SAUCER
F1_000707 equ $ ; in [INVADERS.BAS] If SAUCER_ENABLED = TRUE Then          ' Don't enter the routine if the saucer is already flying
	Btfss _B#VR2,3
	Go@to bc@LL214
F1_000708 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = 1         ' Enable the saucer's sound channel
	Bsf NOTE_STATUS,2
F1_000709 equ $ ; in [INVADERS.BAS] If TIME_TO_MOVE_SAUCER = TRUE Then      ' Is it time to move the saucer ?
	Btfss _B#VR2,2
	Go@to bc@LL216
F1_000710 equ $ ; in [INVADERS.BAS] Dec SAUCER_XPOS          ' Move the saucer accross the screen
	Decf SAUCER_XPOS,F
F1_000711 equ $ ; in [INVADERS.BAS] if SAUCER_XPOS // 2 = 0 Then
	Movlw 1
	Andwf SAUCER_XPOS,W
	Movwf PBP#VAR0
	Clrf PBP#VAR0H
	Movf PBP#VAR0H,W
	Iorwf PBP#VAR0,W
	Btfss STATUS,2
	Go@to bc@LL218
F1_000712 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 10
	Movlw 10
	Movwf SAUCER_FREQ
	F@Jump bc@LL219
bc@LL218
F1_000713 equ $ ; in [INVADERS.BAS] Else
F1_000714 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 12
	Movlw 12
	Movwf SAUCER_FREQ
F1_000715 equ $ ; in [INVADERS.BAS] Endif
bc@LL219
F1_000716 equ $ ; in [INVADERS.BAS] Gosub DRAW_SAUCER         ' Display the saucer
	F@Call DRAW_SAUCER
F1_000717 equ $ ; in [INVADERS.BAS] Endif
bc@LL216
F1_000718 equ $ ; in [INVADERS.BAS] If SAUCER_XPOS = 0 OR SAUCER_HIT = TRUE Then    ' Has the saucer reached the left of the display or been hit ?
	Movff SAUCER_XPOS,PP0
	Clrw
	F@Call t@eb
	Movwf SP#P9
	Clrw
	Btfsc _B#VR2,1
	Movlw 1
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL221
F1_000719 equ $ ; in [INVADERS.BAS] SAUCER_ENABLED = FALSE        ' Yes. So signal the sacucer is finished
	Bcf _B#VR2,3
F1_000720 equ $ ; in [INVADERS.BAS] Gosub CLEAR_SAUCER         ' Clear the saucer
	F@Call CLEAR_SAUCER
F1_000721 equ $ ; in [INVADERS.BAS] SAUCER_XPOS = 127 - SAUCER_WIDTH           ' Reset the saucer to the right of the display
	Movlw 113
	Movwf SAUCER_XPOS
F1_000722 equ $ ; in [INVADERS.BAS] Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES ' And display the score because it was erased by the saucer
	Clrf GEN
	Clrw
	F@Call GLCD_Cur
	Movlw 128
	Movwf BPFH
	Clrf GEN4H
	Movff LEVELH,PP2H
	Movff LEVEL,PP2
	F@Call out@dec
	Movlw 32
	F@Call Print
	Clrf GEN4H
	Movff SCOREHHH,PP7HHH
	Movff SCOREHH,PP7HH
	Movff SCOREH,PP7H
	Movff SCORE,PP7
	F@Call out@dec32
	Clrf GEN
	Movlw 20
	F@Call GLCD_Cur
	Movf LIVES,W
	F@Call Print
F1_000723 equ $ ; in [INVADERS.BAS] Endif
bc@LL221
	F@Jump bc@LL222
bc@LL214
F1_000724 equ $ ; in [INVADERS.BAS] Else
F1_000725 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = 0        ' Disable the saucer's sound channel
	Bcf NOTE_STATUS,2
F1_000726 equ $ ; in [INVADERS.BAS] Endif
bc@LL222
F1_000727 equ $ ; in [INVADERS.BAS] Return
	Return
GOVERN_SPEEDS
F1_000733 equ $ ; in [INVADERS.BAS] Dec SAUCER_SPEED
	Decf SAUCER_SPEED,F
F1_000734 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_SAUCER = FALSE
	Bcf _B#VR2,2
F1_000735 equ $ ; in [INVADERS.BAS] If SAUCER_SPEED = 0 Then
	Tstfsz SAUCER_SPEED
	F@Jump bc@LL224
F1_000736 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_SAUCER = TRUE
	Bsf _B#VR2,2
F1_000737 equ $ ; in [INVADERS.BAS] SAUCER_SPEED = 3
	Movlw 3
	Movwf SAUCER_SPEED
F1_000738 equ $ ; in [INVADERS.BAS] Endif
bc@LL224
F1_000741 equ $ ; in [INVADERS.BAS] Dec SHIP_SPEED
	Decf SHIP_SPEED,F
F1_000742 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_BASE = FALSE
	Bcf _B#VR1,0
F1_000743 equ $ ; in [INVADERS.BAS] If SHIP_SPEED = 0 Then
	Tstfsz SHIP_SPEED
	F@Jump bc@LL226
F1_000744 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_BASE = TRUE
	Bsf _B#VR1,0
F1_000745 equ $ ; in [INVADERS.BAS] SHIP_SPEED = 3
	Movlw 3
	Movwf SHIP_SPEED
F1_000746 equ $ ; in [INVADERS.BAS] Endif
bc@LL226
F1_000749 equ $ ; in [INVADERS.BAS] Inc INVADER_MISSILE_TICK
	Incf INVADER_MISSILE_TICK,F
F1_000750 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INV_MISSILE = FALSE
	Bcf MISSILE_STATUS,4
F1_000751 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE_TICK >= INVADER_MISSILE_SPEED Then    ' Set the speed for the invader's missile
	Movf INVADER_MISSILE_SPEED,W
	Subwf INVADER_MISSILE_TICK,W
	Btfss STATUS,0
	Go@to bc@LL228
F1_000752 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INV_MISSILE = TRUE
	Bsf MISSILE_STATUS,4
F1_000753 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_TICK = 0
	Clrf INVADER_MISSILE_TICK
F1_000754 equ $ ; in [INVADERS.BAS] Endif
bc@LL228
F1_000756 equ $ ; in [INVADERS.BAS] Inc INVADER_MISSILE2_TICK
	Incf INVADER_MISSILE2_TICK,F
F1_000757 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INV_MISSILE2 = FALSE
	Bcf _B#VR1,6
F1_000758 equ $ ; in [INVADERS.BAS] If INVADER_MISSILE2_TICK >= INVADER_MISSILE2_SPEED Then   ' Set the speed for the invader's second missile
	Movf INVADER_MISSILE2_SPEED,W
	Subwf INVADER_MISSILE2_TICK,W
	Btfss STATUS,0
	Go@to bc@LL230
F1_000759 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INV_MISSILE2 = TRUE
	Bsf _B#VR1,6
F1_000760 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_TICK = 0
	Clrf INVADER_MISSILE2_TICK
F1_000761 equ $ ; in [INVADERS.BAS] Endif
bc@LL230
F1_000764 equ $ ; in [INVADERS.BAS] Dec SHIP_MISSILE_TICK
	Decf SHIP_MISSILE_TICK,F
F1_000765 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_SHIP_MISSILE = FALSE
	Bcf MISSILE_STATUS,3
F1_000766 equ $ ; in [INVADERS.BAS] If SHIP_MISSILE_TICK = 0 Then          ' Set the speed for the ship's missile
	Tstfsz SHIP_MISSILE_TICK
	F@Jump bc@LL232
F1_000767 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_SHIP_MISSILE = TRUE
	Bsf MISSILE_STATUS,3
F1_000768 equ $ ; in [INVADERS.BAS] SHIP_MISSILE_TICK = 2
	Movlw 2
	Movwf SHIP_MISSILE_TICK
F1_000769 equ $ ; in [INVADERS.BAS] Endif
bc@LL232
F1_000770 equ $ ; in [INVADERS.BAS] Return
	Return
DISPLAY_SPASH_SCREEN
F1_000776 equ $ ; in [INVADERS.BAS] Cls
	F@Call GLcd@Cls
F1_000777 equ $ ; in [INVADERS.BAS] SCORE = 0
	Clrf SCOREHHH
	Clrf SCOREHH
	Clrf SCOREH
	Clrf SCORE
F1_000778 equ $ ; in [INVADERS.BAS] TEMP_LOOP = 0
	Clrf TEMP_LOOP
F1_000779 equ $ ; in [INVADERS.BAS] Repeat
bc@LL233
F1_000780 equ $ ; in [INVADERS.BAS] INVADER_LOOP = 0
	Clrf INVADER_LOOP
F1_000781 equ $ ; in [INVADERS.BAS] Repeat
bc@LL235
F1_000782 equ $ ; in [INVADERS.BAS] LEVEL = CREAD INVADER_SPLASH_SCREEN + SCORE
	Movlw high INVADER_SPLASH_SCREEN
	Movwf PBP#VAR0H
	Movlw low INVADER_SPLASH_SCREEN
	Movwf PBP#VAR0
	Movf SCORE,W
	Addwf PBP#VAR0,W
	Movwf TBLPTRL
	Movf SCOREH,W
	Addwfc PBP#VAR0H,W
	Movwf TBLPTRLH
	Clrf EECON1
	Bsf EECON1,EEPGD
	Tblrd*+
	Movff TABLAT,LEVEL
	Tblrd*
	Movff TABLAT,LEVELH
F1_000783 equ $ ; in [INVADERS.BAS] LcdWrite TEMP_LOOP,INVADER_LOOP,[LEVEL]
	Movff TEMP_LOOP,GEN
	Movff INVADER_LOOP,GENH
	Movf LEVEL,W
	F@Call Glcd@p
F1_000784 equ $ ; in [INVADERS.BAS] Inc SCORE
	Incf SCORE,F
	Movlw 0
	Addwfc SCOREH,F
	Addwfc SCOREHH,F
	Addwfc SCOREHHH,F
F1_000785 equ $ ; in [INVADERS.BAS] Inc INVADER_LOOP
	Incf INVADER_LOOP,F
F1_000786 equ $ ; in [INVADERS.BAS] Until INVADER_LOOP > 127
	Movlw 127
	Cpfsgt INVADER_LOOP
	F@Jump bc@LL235
bc@LL236
F1_000787 equ $ ; in [INVADERS.BAS] Inc TEMP_LOOP
	Incf TEMP_LOOP,F
F1_000788 equ $ ; in [INVADERS.BAS] Until TEMP_LOOP > 7
	Movlw 7
	Cpfsgt TEMP_LOOP
	F@Jump bc@LL233
bc@LL234
F1_000789 equ $ ; in [INVADERS.BAS] Return
	Return
MAIN_PROGRAM_LOOP
F1_000793 equ $ ; in [INVADERS.BAS] Gosub DISPLAY_SPASH_SCREEN
	F@Call DISPLAY_SPASH_SCREEN
F1_000794 equ $ ; in [INVADERS.BAS] Delayms 1000
	Movlw 3
	Movwf PP1H
	Movlw 232
	F@Call dly@w
F1_000795 equ $ ; in [INVADERS.BAS] Print at 4,1,"PRESS FIRE TO START"
	Movlw 4
	Movwf GEN
	Movlw 1
	F@Call GLCD_Cur
	Movlw high str@lb1
	Movwf GEN4H
	Movlw low str@lb1
	Movwf GEN4
	F@Call print@mstr
F1_000796 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 1 : Wend
bc@LL237
	Btfss PORTB,2
	Go@to bc@LL238

	F@Jump bc@LL237
bc@LL238
F1_000797 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 0 : Wend
bc@LL239
	Btfsc PORTB,2
	Go@to bc@LL240

	F@Jump bc@LL239
bc@LL240
F1_000798 equ $ ; in [INVADERS.BAS] Delayms 50
	Movlw 50
	F@Call dl@ms
F1_000800 equ $ ; in [INVADERS.BAS] Cls
	F@Call GLcd@Cls
F1_000801 equ $ ; in [INVADERS.BAS] Print at 0,7,"Scoring"
	Clrf GEN
	Movlw 7
	F@Call GLCD_Cur
	Movlw high str@lb2
	Movwf GEN4H
	Movlw low str@lb2
	Movwf GEN4
	F@Call print@mstr
F1_000802 equ $ ; in [INVADERS.BAS] Lcdwrite 2,0,[$00,$04,$0E,$3A,$1B,$0F,$1B,$1B,$0F,$1B,$3A,$0E,$04,$00]
	Movlw 2
	Movwf GEN
	Clrf GENH
	Clrw
	F@Call Glcd@p
	Movlw 4
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 15
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 15
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 14
	F@Call Glcd@p
	Movlw 4
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000803 equ $ ; in [INVADERS.BAS] Print at 2,2," = 100+ Points"
	Movlw 2
	Movwf GEN
	Movlw 2
	F@Call GLCD_Cur
	Movlw high str@lb3
	Movwf GEN4H
	Movlw low str@lb3
	Movwf GEN4
	F@Call print@mstr
F1_000805 equ $ ; in [INVADERS.BAS] LCDWRITE 3,0,[$00,$18,$4C,$2E,$5B,$2F,$2F,$5B,$2E,$4C,$18,$00]
	Movlw 3
	Movwf GEN
	Clrf GENH
	Clrw
	F@Call Glcd@p
	Movlw 24
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 46
	F@Call Glcd@p
	Movlw 91
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 91
	F@Call Glcd@p
	Movlw 46
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 24
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000806 equ $ ; in [INVADERS.BAS] Print at 3,2," = 20 Points"
	Movlw 3
	Movwf GEN
	Movlw 2
	F@Call GLCD_Cur
	Movlw high str@lb4
	Movwf GEN4H
	Movlw low str@lb4
	Movwf GEN4
	F@Call print@mstr
F1_000807 equ $ ; in [INVADERS.BAS] LCDWRITE 4,0,[$00,$38,$0D,$3E,$5A,$1E,$1E,$5A,$3E,$0D,$38,$00]
	Movlw 4
	Movwf GEN
	Clrf GENH
	Clrw
	F@Call Glcd@p
	Movlw 56
	F@Call Glcd@p
	Movlw 13
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 90
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 30
	F@Call Glcd@p
	Movlw 90
	F@Call Glcd@p
	Movlw 62
	F@Call Glcd@p
	Movlw 13
	F@Call Glcd@p
	Movlw 56
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000808 equ $ ; in [INVADERS.BAS] Print at 4,2," = 10 Points"
	Movlw 4
	Movwf GEN
	Movlw 2
	F@Call GLCD_Cur
	Movlw high str@lb5
	Movwf GEN4H
	Movlw low str@lb5
	Movwf GEN4
	F@Call print@mstr
F1_000809 equ $ ; in [INVADERS.BAS] LCDWRITE 5,0,[$00,$4C,$6E,$3A,$1B,$2F,$2F,$1B,$3A,$6E,$4C,$00]
	Movlw 5
	Movwf GEN
	Clrf GENH
	Clrw
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Movlw 110
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 47
	F@Call Glcd@p
	Movlw 27
	F@Call Glcd@p
	Movlw 58
	F@Call Glcd@p
	Movlw 110
	F@Call Glcd@p
	Movlw 76
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000810 equ $ ; in [INVADERS.BAS] Print at 5,2," = 5 Points"
	Movlw 5
	Movwf GEN
	Movlw 2
	F@Call GLCD_Cur
	Movlw high str@lb6
	Movwf GEN4H
	Movlw low str@lb6
	Movwf GEN4
	F@Call print@mstr
F1_000811 equ $ ; in [INVADERS.BAS] Print at 7,1,"PRESS FIRE TO START"
	Movlw 7
	Movwf GEN
	Movlw 1
	F@Call GLCD_Cur
	Movlw high str@lb7
	Movwf GEN4H
	Movlw low str@lb7
	Movwf GEN4
	F@Call print@mstr
F1_000812 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 1 : Wend
bc@LL241
	Btfss PORTB,2
	Go@to bc@LL242

	F@Jump bc@LL241
bc@LL242
F1_000813 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 0 : Wend
bc@LL243
	Btfsc PORTB,2
	Go@to bc@LL244

	F@Jump bc@LL243
bc@LL244
F1_000814 equ $ ; in [INVADERS.BAS] Delayms 50
	Movlw 50
	F@Call dl@ms
F1_000816 equ $ ; in [INVADERS.BAS] LEVEL = 0          ' Start at level 0
	Clrf LEVELH
	Clrf LEVEL
F1_000817 equ $ ; in [INVADERS.BAS] LIVES = "3"          ' Set the initial lives counter to 3
	Movlw 51
	Movwf LIVES
F1_000818 equ $ ; in [INVADERS.BAS] SHIP_SPEED = 3
	Movlw 3
	Movwf SHIP_SPEED
F1_000819 equ $ ; in [INVADERS.BAS] SCORE = 0
	Clrf SCOREHHH
	Clrf SCOREHH
	Clrf SCOREH
	Clrf SCORE
F1_000820 equ $ ; in [INVADERS.BAS] SHIP_XPOS = 64
	Movlw 64
	Movwf SHIP_XPOS
F1_000821 equ $ ; in [INVADERS.BAS] SAUCER_SPEED = 7        ' Speed of the saucer
	Movlw 7
	Movwf SAUCER_SPEED
F1_000822 equ $ ; in [INVADERS.BAS] INVADER_SPEED = 70        ' The initial speed of the invaders
	Movlw 70
	Movwf INVADER_SPEED
F1_000823 equ $ ; in [INVADERS.BAS] DEFAULT_INVADER_SPEED = INVADER_SPEED
	Movff INVADER_SPEED,DEFAULT_INVADER_SPEED
F1_000825 equ $ ; in [INVADERS.BAS] TEMP_LOOP = 0
	Clrf TEMP_LOOP
F1_000826 equ $ ; in [INVADERS.BAS] Repeat
bc@LL245
F1_000827 equ $ ; in [INVADERS.BAS] BASE_ENABLED[TEMP_LOOP] = TRUE
	Lfsr 0,BASE_ENABLED
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Movlw 1
	Movwf INDF0
F1_000828 equ $ ; in [INVADERS.BAS] BASE_HITS[TEMP_LOOP] = 0
	Lfsr 0,BASE_HITS
	Movf TEMP_LOOP,W
	Addwf FSR0L,F
	Movlw 0
	Addwfc FSR0H,F
	Clrf INDF0
F1_000829 equ $ ; in [INVADERS.BAS] Inc TEMP_LOOP
	Incf TEMP_LOOP,F
F1_000830 equ $ ; in [INVADERS.BAS] Until TEMP_LOOP > 8
	Movlw 8
	Cpfsgt TEMP_LOOP
	F@Jump bc@LL245
bc@LL246
F1_000833 equ $ ; in [INVADERS.BAS] INTERRUPT_COUNTER1 = 0
	Clrf INTERRUPT_COUNTER1
F1_000834 equ $ ; in [INVADERS.BAS] NOTE_STATUS = 0
	Clrf NOTE_STATUS
F1_000835 equ $ ; in [INVADERS.BAS] INVADER_SOUND_COUNTER = 0
	Clrf INVADER_SOUND_COUNTER
F1_000836 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_COUNTER = 0
	Clrf MISSILE_SOUND_COUNTER
F1_000837 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_COUNTER = 0
	Clrf SAUCER_SOUND_COUNTER
F1_000838 equ $ ; in [INVADERS.BAS] INVADER_SOUND_DURATION_COUNTER = 0
	Clrf INVADER_SOUND_DURATION_COUNTER
F1_000840 equ $ ; in [INVADERS.BAS] INVADER_SOUND_ENABLE = 1      ' Enable the Invaders sound channel
	Bsf NOTE_STATUS,0
F1_000841 equ $ ; in [INVADERS.BAS] INVADER_SOUND_DURATION = 20      ' Set the note duration to 20
	Movlw 20
	Movwf INVADER_SOUND_DURATION
NEW_SHEET
F1_000849 equ $ ; in [INVADERS.BAS] Inc LEVEL
	Incf LEVEL,F
	Clrw
	Addwfc LEVELH,F
F1_000850 equ $ ; in [INVADERS.BAS] Cls
	F@Call GLcd@Cls
F1_000851 equ $ ; in [INVADERS.BAS] Gosub UPDATE_BASES           ' Draw the bases (or what's left of them)
	F@Call UPDATE_BASES
F1_000852 equ $ ; in [INVADERS.BAS] SHIP_HIT = FALSE           ' Default to no hit on the ship by a missile
	Bcf _B#VR1,2
F1_000853 equ $ ; in [INVADERS.BAS] SAUCER_ENABLED = FALSE          ' Disable the saucer
	Bcf _B#VR2,3
F1_000854 equ $ ; in [INVADERS.BAS] SAUCER_XPOS = 127 - SAUCER_WIDTH       ' Position saucer at top tight of the screen
	Movlw 113
	Movwf SAUCER_XPOS
F1_000855 equ $ ; in [INVADERS.BAS] MISSILE_XPOS = 0
	Clrf MISSILE_XPOS
F1_000856 equ $ ; in [INVADERS.BAS] MISSILE_YPOS = 63 - 9
	Movlw 54
	Movwf MISSILE_YPOS
F1_000857 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_XPOS = 0
	Clrf INVADER_MISSILE_XPOS
F1_000858 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_YPOS = 0
	Clrf INVADER_MISSILE_YPOS
F1_000859 equ $ ; in [INVADERS.BAS] MISSILE_STATUS = 0
	Clrf MISSILE_STATUS
F1_000860 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_YPOS = 0         ' Y position of Invader's second MISSILE
	Clrf INVADER_MISSILE2_YPOS
F1_000861 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_XPOS = 0         ' X position of Invader's second MISSILE
	Clrf INVADER_MISSILE2_XPOS
F1_000862 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INV_MISSILE2 = FALSE       ' Indicate time to move the invader's second missile
	Bcf _B#VR1,6
F1_000863 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_FIRED = FALSE        ' TRUE if Invader's second MISSILE in the air
	Bcf _B#VR1,7
F1_000864 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_HIT = FALSE        ' Default to not hit anything
	Bcf _B#VR2,0
F1_000865 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_BASE = FALSE
	Bcf _B#VR1,0
F1_000867 equ $ ; in [INVADERS.BAS] Gosub CLEAR_INVADER_MISSILE
	F@Call CLEAR_INVADER_MISSILE
F1_000868 equ $ ; in [INVADERS.BAS] Gosub CLEAR_MISSILE
	F@Call CLEAR_MISSILE
F1_000869 equ $ ; in [INVADERS.BAS] Gosub DRAW_SHIP            ' Draw the initial ship
	F@Call DRAW_SHIP
F1_000871 equ $ ; in [INVADERS.BAS] Dec DEFAULT_INVADER_SPEED         ' Speed up the invaders every new sheet
	Decf DEFAULT_INVADER_SPEED,F
F1_000872 equ $ ; in [INVADERS.BAS] INVADER_SPEED = DEFAULT_INVADER_SPEED      ' Transfer the speed into the actual speed altering variable
	Movff DEFAULT_INVADER_SPEED,INVADER_SPEED
F1_000873 equ $ ; in [INVADERS.BAS] Clear INVADER_TICK
	Clrf INVADER_TICK
F1_000874 equ $ ; in [INVADERS.BAS] Clear INVADER_MISSILE_TICK
	Clrf INVADER_MISSILE_TICK
F1_000875 equ $ ; in [INVADERS.BAS] Clear INVADER_MISSILE2_TICK
	Clrf INVADER_MISSILE2_TICK
F1_000876 equ $ ; in [INVADERS.BAS] SHIP_MISSILE_TICK = 2
	Movlw 2
	Movwf SHIP_MISSILE_TICK
F1_000877 equ $ ; in [INVADERS.BAS] INVADERS_REACHED_BOTTOM = FALSE        ' Default to the invaders not at the bottom of the screen
	Bcf _B#VR1,4
F1_000878 equ $ ; in [INVADERS.BAS] INVADER_CHARACTER = 0
	Bcf _B#VR1,5
F1_000879 equ $ ; in [INVADERS.BAS] INVADER_MISSILE_SPEED = 5         ' Default speed of the invader's missile
	Movlw 5
	Movwf INVADER_MISSILE_SPEED
F1_000880 equ $ ; in [INVADERS.BAS] INVADER_MISSILE2_SPEED = 4
	Movlw 4
	Movwf INVADER_MISSILE2_SPEED
F1_000881 equ $ ; in [INVADERS.BAS] INVADERS_DIRECTION = FORWARD        ' Default to the invaders moving right
	Bsf _B#VR1,1
F1_000882 equ $ ; in [INVADERS.BAS] INVADERS_ENABLED = 18          ' All 18 invaders are enabled
	Movlw 18
	Movwf INVADERS_ENABLED
F1_000883 equ $ ; in [INVADERS.BAS] Gosub RESET_INVADERS           ' Reset all the invaders positions
	F@Call RESET_INVADERS
F1_000884 equ $ ; in [INVADERS.BAS] Gosub DRAW_INVADERS           ' Place all the invaders on the screen
	F@Call DRAW_INVADERS
F1_000886 equ $ ; in [INVADERS.BAS] Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
	Clrf GEN
	Clrw
	F@Call GLCD_Cur
	Movlw 128
	Movwf BPFH
	Clrf GEN4H
	Movff LEVELH,PP2H
	Movff LEVEL,PP2
	F@Call out@dec
	Movlw 32
	F@Call Print
	Clrf GEN4H
	Movff SCOREHHH,PP7HHH
	Movff SCOREHH,PP7HH
	Movff SCOREH,PP7H
	Movff SCORE,PP7
	F@Call out@dec32
	Clrf GEN
	Movlw 20
	F@Call GLCD_Cur
	Movf LIVES,W
	F@Call Print
F1_000888 equ $ ; in [INVADERS.BAS] While 1 = 1
bc@LL247
F1_000889 equ $ ; in [INVADERS.BAS] RANDOM_VALUE = RANDOM
	F@Call rn@dm
	Movwf RANDOM_VALUE
F1_000890 equ $ ; in [INVADERS.BAS] RANDOM_VALUE = RANDOM_VALUE & %00111000
	Movlw 56
	Andwf RANDOM_VALUE,F
F1_000891 equ $ ; in [INVADERS.BAS] Inc INVADER_TICK
	Incf INVADER_TICK,F
F1_000892 equ $ ; in [INVADERS.BAS] TIME_TO_MOVE_INVADERS = FALSE
	Bcf MISSILE_STATUS,7
F1_000893 equ $ ; in [INVADERS.BAS] If INVADER_TICK > INVADER_SPEED Then
	Movf INVADER_TICK,W
	Cpfslt INVADER_SPEED
	F@Jump bc@LL250
F1_000894 equ $ ; in [INVADERS.BAS] INVADER_TICK = 0
	Clrf INVADER_TICK
F1_000897 equ $ ; in [INVADERS.BAS] Gosub MOVE_INVADERS
	F@Call MOVE_INVADERS
F1_000898 equ $ ; in [INVADERS.BAS] Gosub MOVE_INVADERS
	F@Call MOVE_INVADERS
F1_000899 equ $ ; in [INVADERS.BAS] INVADER_CHARACTER = ~INVADER_CHARACTER    ' Use a new invader character
	Clrw
	Btfss _B#VR1,5
	Addlw 1
	Btfsc STATUS,2
	Bcf _B#VR1,5
	Btfss STATUS,2
	Bsf _B#VR1,5
F1_000900 equ $ ; in [INVADERS.BAS] If INVADERS_REACHED_BOTTOM  = TRUE Then GAME_OVER
	Btfss _B#VR1,4
	Go@to bc@LL252
	F@Jump GAME_OVER
bc@LL252
F1_000901 equ $ ; in [INVADERS.BAS] Endif
bc@LL250
F1_000902 equ $ ; in [INVADERS.BAS] Gosub MOVE_SAUCER          ' Move the flying saucer (if required)
	F@Call MOVE_SAUCER
F1_000904 equ $ ; in [INVADERS.BAS] Gosub GOVERN_SPEEDS          ' Check whether a piece should be moving
	F@Call GOVERN_SPEEDS
F1_000906 equ $ ; in [INVADERS.BAS] If L_BUTTON = 0 Then Gosub SHIP_LEFT       ' Move ship left if LEFT button pressed
	Btfsc PORTB,0
	Go@to bc@LL254
	F@Call SHIP_LEFT
bc@LL254
F1_000907 equ $ ; in [INVADERS.BAS] If R_BUTTON = 0 Then Gosub SHIP_RIGHT     ' Move ship right if RIGHT button pressed
	Btfsc PORTB,1
	Go@to bc@LL256
	F@Call SHIP_RIGHT
bc@LL256
F1_000910 equ $ ; in [INVADERS.BAS] If FIRE_BUTTON = 0 Then If MISSILE_FIRED = FALSE Then  ' Has the FIRE button been pressed and the ship's missile not already flying ?
	Btfsc PORTB,2
	Go@to bc@LL258
	Btfsc MISSILE_STATUS,0
	Go@to bc@LL260
F1_000911 equ $ ; in [INVADERS.BAS] SEED INVADER_SOUND_COUNTER
	Clrf PBP#RNDH
	Movff INVADER_SOUND_COUNTER,PBP#RND
F1_000912 equ $ ; in [INVADERS.BAS] MISSILE_FIRED = TRUE        ' Yes.. So signal we need the ship's missile FIRED
	Bsf MISSILE_STATUS,0
F1_000913 equ $ ; in [INVADERS.BAS] MISSILE_XPOS = SHIP_XPOS + 4      ' Place the ship's missile's xpos at the middle of the ship's shape
	Movlw 4
	Addwf SHIP_XPOS,W
	Movwf MISSILE_XPOS
F1_000914 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 1       ' Enable the missile's sound
	Bsf NOTE_STATUS,1
F1_000915 equ $ ; in [INVADERS.BAS] Endif
bc@LL260
bc@LL258
F1_000918 equ $ ; in [INVADERS.BAS] Gosub MOVE_MISSILE          ' Move the ship's missile if OK to do so
	F@Call MOVE_MISSILE
F1_000919 equ $ ; in [INVADERS.BAS] Gosub CHECK_FOR_MISSILE_HIT        ' Check if the ship's missile has hit anything
	F@Call CHECK_FOR_MISSILE_HIT
F1_000921 equ $ ; in [INVADERS.BAS] If MISSILE_HIT = TRUE OR SAUCER_HIT = TRUE Then
	Clrw
	Btfsc MISSILE_STATUS,1
	Movlw 1
	Movwf SP#P9
	Clrw
	Btfsc _B#VR2,1
	Movlw 1
	Iorwf SP#P9,W
	Btfsc STATUS,2
	Go@to bc@LL262
F1_000922 equ $ ; in [INVADERS.BAS] If BASE_HIT = FALSE Then
	Btfsc MISSILE_STATUS,2
	Go@to bc@LL264
F1_000924 equ $ ; in [INVADERS.BAS] Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
	Clrf GEN
	Clrw
	F@Call GLCD_Cur
	Movlw 128
	Movwf BPFH
	Clrf GEN4H
	Movff LEVELH,PP2H
	Movff LEVEL,PP2
	F@Call out@dec
	Movlw 32
	F@Call Print
	Clrf GEN4H
	Movff SCOREHHH,PP7HHH
	Movff SCOREHH,PP7HH
	Movff SCOREH,PP7H
	Movff SCORE,PP7
	F@Call out@dec32
	Clrf GEN
	Movlw 20
	F@Call GLCD_Cur
	Movf LIVES,W
	F@Call Print
F1_000925 equ $ ; in [INVADERS.BAS] Endif
bc@LL264
F1_000926 equ $ ; in [INVADERS.BAS] Endif
bc@LL262
F1_000928 equ $ ; in [INVADERS.BAS] If INVADER_CHARACTER = 1 Then
	Btfss _B#VR1,5
	Go@to bc@LL266
F1_000929 equ $ ; in [INVADERS.BAS] Gosub FIRE_INVADER_MISSILE       ' Fire an invader missile is possible
	F@Call FIRE_INVADER_MISSILE
F1_000930 equ $ ; in [INVADERS.BAS] Endif
bc@LL266
F1_000931 equ $ ; in [INVADERS.BAS] Gosub MOVE_INVADER_MISSILE        ' Move the invader's missile (if fired)
	F@Call MOVE_INVADER_MISSILE
F1_000932 equ $ ; in [INVADERS.BAS] Gosub CHECK_FOR_INVADER_MISSILE_HIT      ' Check if the invader's missile has hit anything
	F@Call CHECK_FOR_INVADER_MISSILE_HIT
F1_000934 equ $ ; in [INVADERS.BAS] If INVADERS_ENABLED = 0 Then        ' Have all the invaders been destroyed ?
	Tstfsz INVADERS_ENABLED
	F@Jump bc@LL268
F1_000935 equ $ ; in [INVADERS.BAS] INVADERS_ENABLED = 18        ' Yes.. So enable them all again
	Movlw 18
	Movwf INVADERS_ENABLED
F1_000936 equ $ ; in [INVADERS.BAS] If INVADER_SPEED >= 3 Then Dec INVADER_SPEED  ' Increase the speed of the invaders
	Movlw 2
	Cpfsgt INVADER_SPEED
	F@Jump bc@LL270
	Decf INVADER_SPEED,F
bc@LL270
F1_000937 equ $ ; in [INVADERS.BAS] Goto NEW_SHEET          ' and start a new sheet
	F@Jump NEW_SHEET
F1_000938 equ $ ; in [INVADERS.BAS] Endif
bc@LL268
F1_000940 equ $ ; in [INVADERS.BAS] If LEVEL > 10 Then          ' Add a second invader missile after level 10
	Movf LEVELH,W
	Bnz cp@lb15
	Movlw 10
	Cpfsgt LEVEL
	F@Jump bc@LL272
cp@lb15
F1_000941 equ $ ; in [INVADERS.BAS] If INVADER_CHARACTER = 0 then
	Btfsc _B#VR1,5
	Go@to bc@LL274
F1_000942 equ $ ; in [INVADERS.BAS] Gosub FIRE_INVADER_MISSILE2      ' Fire an invader missile is possible
	F@Call FIRE_INVADER_MISSILE2
F1_000943 equ $ ; in [INVADERS.BAS] Endif
bc@LL274
F1_000944 equ $ ; in [INVADERS.BAS] Gosub MOVE_INVADER_MISSILE2       ' Move the invader's missile (if fired)
	F@Call MOVE_INVADER_MISSILE2
F1_000945 equ $ ; in [INVADERS.BAS] Gosub CHECK_FOR_INVADER_MISSILE2_HIT    ' Check if the invader's missile has hit anything
	F@Call CHECK_FOR_INVADER_MISSILE2_HIT
F1_000946 equ $ ; in [INVADERS.BAS] Endif
bc@LL272
F1_000948 equ $ ; in [INVADERS.BAS] If SHIP_HIT = TRUE Then         ' Has the ship been hit ?
	Btfss _B#VR1,2
	Go@to bc@LL276
F1_000949 equ $ ; in [INVADERS.BAS] SHIP_HIT = FALSE
	Bcf _B#VR1,2
F1_000951 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = 1        ' Yes. So enable SAUCER sound channel
	Bsf NOTE_STATUS,2
F1_000952 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 1             ' Enable MISSILE sound channel
	Bsf NOTE_STATUS,1
F1_000953 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 70         ' Set MISSILE channel frequency to 70
	Movlw 70
	Movwf MISSILE_FREQ
F1_000954 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 90             ' Set SAUCER channel frequency to 90
	Movlw 90
	Movwf SAUCER_FREQ
F1_000955 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$10,$24,$AC,$F8,$F0,$E0,$F0,$F8,$AC,$24,$10] ' Draw first part of ship exploding
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Movlw 16
	F@Call Glcd@p
	Movlw 36
	F@Call Glcd@p
	Movlw 172
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 172
	F@Call Glcd@p
	Movlw 36
	F@Call Glcd@p
	Movlw 16
	F@Call Glcd@p
F1_000956 equ $ ; in [INVADERS.BAS] Delayms 40           ' Leave the graphic on the screen for 40ms
	Movlw 40
	F@Call dl@ms
F1_000957 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 100         ' Increase the SAUCER channel's frequency
	Movlw 100
	Movwf SAUCER_FREQ
F1_000958 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 120         ' Increase the MISSILE channel's frequency
	Movlw 120
	Movwf MISSILE_FREQ
F1_000959 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$00,$20,$28,$F0,$A8,$C0,$E0,$F0,$28,$04,$00] ' Draw second part of ship exploding
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Movlw 32
	F@Call Glcd@p
	Movlw 40
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 168
	F@Call Glcd@p
	Movlw 192
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 40
	F@Call Glcd@p
	Movlw 4
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000960 equ $ ; in [INVADERS.BAS] Delayms 40           ' Leave the graphic on the screen for 40ms
	Movlw 40
	F@Call dl@ms
F1_000961 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 150         ' Increase the SAUCER channel's frequency
	Movlw 150
	Movwf SAUCER_FREQ
F1_000962 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 135         ' Increase the MISSILE channel's frequency
	Movlw 135
	Movwf MISSILE_FREQ
F1_000963 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$00,$00,$30,$60,$80,$C0,$60,$30,$00,$00,$00] ' Draw third part of ship exploding
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Movlw 48
	F@Call Glcd@p
	Movlw 96
	F@Call Glcd@p
	Movlw 128
	F@Call Glcd@p
	Movlw 192
	F@Call Glcd@p
	Movlw 96
	F@Call Glcd@p
	Movlw 48
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000964 equ $ ; in [INVADERS.BAS] Delayms 100
	Movlw 100
	F@Call dl@ms
F1_000965 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00] ' Clear the ship graphic
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000966 equ $ ; in [INVADERS.BAS] Delayms 100           ' Leave the graphic on the screen for 100ms
	Movlw 100
	F@Call dl@ms
F1_000967 equ $ ; in [INVADERS.BAS] LIVES = LIVES - 1         ' Decrement the lives counter
	Decf LIVES,F
F1_000968 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = 0       ' Disable the MISSILE sound channel
	Bcf NOTE_STATUS,1
F1_000969 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = 0        ' Disable the SAUCER sound channel
	Bcf NOTE_STATUS,2
F1_000970 equ $ ; in [INVADERS.BAS] If LIVES > "0" Then         ' Do we have any lives left ?
	Movlw 48
	Cpfsgt LIVES
	F@Jump bc@LL278
F1_000971 equ $ ; in [INVADERS.BAS] LCDWRITE 7,SHIP_XPOS,[$00,$E0,$F0,$F0,$F8,$FC,$F8,$F0,$F0,$E0,$00] ' Yes. So Re-draw the ship and carry on
	Movlw 7
	Movwf GEN
	Movff SHIP_XPOS,GENH
	Clrw
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 252
	F@Call Glcd@p
	Movlw 248
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 240
	F@Call Glcd@p
	Movlw 224
	F@Call Glcd@p
	Clrw
	F@Call Glcd@p
F1_000972 equ $ ; in [INVADERS.BAS] Print at 0,20,LIVES        ' Update the Display for the amount of lives
	Clrf GEN
	Movlw 20
	F@Call GLCD_Cur
	Movf LIVES,W
	F@Call Print
	F@Jump bc@LL279
bc@LL278
F1_000973 equ $ ; in [INVADERS.BAS] Else            ' Otherwise, we don't have any lives left
F1_000974 equ $ ; in [INVADERS.BAS] Goto GAME_OVER         ' So game over
	F@Jump GAME_OVER
F1_000975 equ $ ; in [INVADERS.BAS] Endif
bc@LL279
F1_000976 equ $ ; in [INVADERS.BAS] Endif
bc@LL276
F1_000977 equ $ ; in [INVADERS.BAS] Delayms 6            ' Main game speed setting
	Movlw 6
	F@Call dl@ms
F1_000978 equ $ ; in [INVADERS.BAS] Wend
	F@Jump bc@LL247
bc@LL248
GAME_OVER
F1_000982 equ $ ; in [INVADERS.BAS] Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
	Clrf GEN
	Clrw
	F@Call GLCD_Cur
	Movlw 128
	Movwf BPFH
	Clrf GEN4H
	Movff LEVELH,PP2H
	Movff LEVEL,PP2
	F@Call out@dec
	Movlw 32
	F@Call Print
	Clrf GEN4H
	Movff SCOREHHH,PP7HHH
	Movff SCOREHH,PP7HH
	Movff SCOREH,PP7H
	Movff SCORE,PP7
	F@Call out@dec32
	Clrf GEN
	Movlw 20
	F@Call GLCD_Cur
	Movf LIVES,W
	F@Call Print
F1_000983 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = TRUE          ' Enable SAUCER sound channel
	Bsf NOTE_STATUS,2
F1_000984 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = TRUE               ' Enable MISSILE sound channel
	Bsf NOTE_STATUS,1
F1_000985 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = 70           ' Set MISSILE channel frequency to 70
	Movlw 70
	Movwf MISSILE_FREQ
F1_000986 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = 90               ' Set SAUCER channel frequency to 90
	Movlw 90
	Movwf SAUCER_FREQ
F1_000987 equ $ ; in [INVADERS.BAS] TEMP_LOOP = 1
	Movlw 1
	Movwf TEMP_LOOP
F1_000988 equ $ ; in [INVADERS.BAS] Repeat
bc@LL280
F1_000989 equ $ ; in [INVADERS.BAS] MISSILE_FREQ = MISSILE_FREQ - TEMP_LOOP
	Movf TEMP_LOOP,W
	Subwf MISSILE_FREQ,F
F1_000990 equ $ ; in [INVADERS.BAS] SAUCER_FREQ = SAUCER_FREQ - TEMP_LOOP
	Movf TEMP_LOOP,W
	Subwf SAUCER_FREQ,F
F1_000991 equ $ ; in [INVADERS.BAS] Delayms 10 + TEMP_LOOP
	Movlw 10
	Addwf TEMP_LOOP,W
	Clrf PP1H
	Movwf PP1
	Rlcf PP1H,F
	Movf PP1,W
	F@Call dly@w
F1_000992 equ $ ; in [INVADERS.BAS] Circle 1,SHIP_XPOS + 5,63,TEMP_LOOP
	Bsf BPF,2
	Movlw 5
	Addwf SHIP_XPOS,W
	Movwf GEN2
	Movlw 63
	Movwf GEN2H
	Movf TEMP_LOOP,W
	F@Call cir@cle
F1_000993 equ $ ; in [INVADERS.BAS] If TEMP_LOOP > 10 Then
	Movlw 10
	Cpfsgt TEMP_LOOP
	F@Jump bc@LL283
F1_000994 equ $ ; in [INVADERS.BAS] Circle 0,SHIP_XPOS + 5,63,TEMP_LOOP - 10
	Bcf BPF,2
	Movlw 5
	Addwf SHIP_XPOS,W
	Movwf GEN2
	Movlw 63
	Movwf GEN2H
	Movlw 10
	Subwf TEMP_LOOP,W
	F@Call cir@cle
F1_000995 equ $ ; in [INVADERS.BAS] Endif
bc@LL283
F1_000996 equ $ ; in [INVADERS.BAS] TEMP_LOOP = TEMP_LOOP + 2
	Movlw 2
	Addwf TEMP_LOOP,F
F1_000997 equ $ ; in [INVADERS.BAS] Until TEMP_LOOP > 24
	Movlw 24
	Cpfsgt TEMP_LOOP
	F@Jump bc@LL280
bc@LL281
F1_000998 equ $ ; in [INVADERS.BAS] SAUCER_SOUND_ENABLE = FALSE          ' Disable SAUCER sound channel
	Bcf NOTE_STATUS,2
F1_000999 equ $ ; in [INVADERS.BAS] MISSILE_SOUND_ENABLE = FALSE               ' Disable MISSILE sound channel
	Bcf NOTE_STATUS,1
F1_001000 equ $ ; in [INVADERS.BAS] TEMP_LOOP = 1
	Movlw 1
	Movwf TEMP_LOOP
F1_001001 equ $ ; in [INVADERS.BAS] Repeat
bc@LL284
F1_001002 equ $ ; in [INVADERS.BAS] Circle 0,SHIP_XPOS + 5,63,TEMP_LOOP
	Bcf BPF,2
	Movlw 5
	Addwf SHIP_XPOS,W
	Movwf GEN2
	Movlw 63
	Movwf GEN2H
	Movf TEMP_LOOP,W
	F@Call cir@cle
F1_001003 equ $ ; in [INVADERS.BAS] TEMP_LOOP = TEMP_LOOP + 2
	Movlw 2
	Addwf TEMP_LOOP,F
F1_001004 equ $ ; in [INVADERS.BAS] Until TEMP_LOOP > 24
	Movlw 24
	Cpfsgt TEMP_LOOP
	F@Jump bc@LL284
bc@LL285
F1_001006 equ $ ; in [INVADERS.BAS] Print at 3,6,INVERSE 1,"GAME OVER", INVERSE 0
	Movlw 3
	Movwf GEN
	Movlw 6
	F@Call GLCD_Cur
	Bsf _GLCD_FLAG,0
	Movlw high str@lb8
	Movwf GEN4H
	Movlw low str@lb8
	Movwf GEN4
	F@Call print@mstr
	Bcf _GLCD_FLAG,0
F1_001007 equ $ ; in [INVADERS.BAS] Delayms 500
	Movlw 1
	Movwf PP1H
	Movlw 244
	F@Call dly@w
F1_001008 equ $ ; in [INVADERS.BAS] Print at 4,1,"PRESS FIRE TO START"
	Movlw 4
	Movwf GEN
	Movlw 1
	F@Call GLCD_Cur
	Movlw high str@lb9
	Movwf GEN4H
	Movlw low str@lb9
	Movwf GEN4
	F@Call print@mstr
F1_001009 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 1 : Wend
bc@LL286
	Btfss PORTB,2
	Go@to bc@LL287

	F@Jump bc@LL286
bc@LL287
F1_001010 equ $ ; in [INVADERS.BAS] Delayms 50
	Movlw 50
	F@Call dl@ms
F1_001011 equ $ ; in [INVADERS.BAS] While FIRE_BUTTON = 0 : Wend
bc@LL288
	Btfsc PORTB,2
	Go@to bc@LL289

	F@Jump bc@LL288
bc@LL289
F1_001012 equ $ ; in [INVADERS.BAS] Delayms 50
	Movlw 50
	F@Call dl@ms
F1_001013 equ $ ; in [INVADERS.BAS] Goto MAIN_PROGRAM_LOOP
	F@Jump MAIN_PROGRAM_LOOP
FONT
	DB 0,0,0,0,0,0
	DB 255,255,255,255,255,255
	DB 224,240,248,252,252,254
	DB 192,176,176,112,236,248
	DB 192,160,176,112,172,40
	DB 64,160,176,112,160,32
	DB 64,128,128,64,160,32
	DB 0,0,0,0,0,0
	DB 254,254,254,254,254,254
	DB 254,222,236,240,248,254
	DB 248,222,228,240,216,158
	DB 184,222,164,176,72,180
	DB 52,88,164,184,72,52
	DB 0,0,0,0,0,0
	DB 254,252,252,248,240,224
	DB 192,176,176,112,236,248
	DB 192,160,176,112,172,40
	DB 64,160,176,112,160,32
	DB 64,128,128,64,160,32
	DB 0,0,0,0,0,0
	DB 255,0,0,0,0,0
	DB 0,0,0,0,0,255
	DB 255,1,1,1,1,1
	DB 1,1,1,1,1,255
	DB 255,128,128,128,128,128
	DB 128,128,128,128,128,255
	DB 0,0,0,0,240,240
	DB 0,0,0,0,15,15
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,79,0,0,0
	DB 0,7,0,7,0,0
	DB 20,127,20,127,20,0
	DB 36,42,127,42,18,0
	DB 35,19,8,100,98,0
	DB 54,73,85,34,80,0
	DB 0,5,3,0,0,0
	DB 28,34,65,0,0,0
	DB 0,0,65,34,28,0
	DB 20,8,62,8,20,0
	DB 8,8,62,8,8,0
	DB 0,80,48,0,0,0
	DB 8,8,8,8,8,0
	DB 0,96,96,0,0,0
	DB 32,16,8,4,2,0
	DB 62,81,73,69,62,0
	DB 0,66,127,64,0,0
	DB 66,97,81,73,70,0
	DB 33,65,69,75,49,0
	DB 24,20,18,127,16,0
	DB 39,69,69,69,57,0
	DB 60,74,73,73,48,0
	DB 1,113,9,5,3,0
	DB 54,73,73,73,54,0
	DB 6,73,73,73,62,0
	DB 0,54,54,0,0,0
	DB 0,86,54,0,0,0
	DB 8,20,34,65,0,0
	DB 20,20,20,20,20,0
	DB 0,65,34,20,8,0
	DB 2,1,81,9,6,0
	DB 50,73,121,65,62,0
	DB 126,17,17,17,126,0
	DB 127,73,73,73,54,0
	DB 62,65,65,65,34,0
	DB 127,65,65,34,28,0
	DB 127,73,73,73,65,0
	DB 127,9,9,9,1,0
	DB 62,65,73,73,122,0
	DB 127,8,8,8,127,0
	DB 0,65,127,65,0,0
	DB 32,64,65,63,1,0
	DB 127,8,20,34,65,0
	DB 127,64,64,64,64,0
	DB 127,2,12,2,127,0
	DB 127,4,8,16,127,0
	DB 62,65,65,65,62,0
	DB 127,9,9,9,6,0
	DB 62,65,81,33,94,0
	DB 127,9,25,41,70,0
	DB 70,73,73,73,49,0
	DB 1,1,127,1,1,0
	DB 63,64,64,64,63,0
	DB 31,32,64,32,31,0
	DB 63,64,56,64,63,0
	DB 99,20,8,20,99,0
	DB 7,8,112,8,7,0
	DB 97,81,73,69,67,0
	DB 127,65,65,0,0,0
	DB 2,4,8,16,32,0
	DB 0,0,65,65,127,0
	DB 4,2,1,2,4,0
	DB 64,64,64,64,64,0
	DB 0,1,2,4,0,0
	DB 32,84,84,84,120,0
	DB 127,72,68,68,56,0
	DB 56,68,68,68,32,0
	DB 56,68,68,72,127,0
	DB 56,84,84,84,24,0
	DB 8,126,9,1,2,0
	DB 12,82,82,82,62,0
	DB 127,8,4,4,120,0
	DB 0,68,125,64,0,0
	DB 0,32,64,68,61,0
	DB 127,16,40,68,0,0
	DB 0,65,127,64,0,0
	DB 124,4,24,4,120,0
	DB 124,8,4,4,120,0
	DB 56,68,68,68,56,0
	DB 124,20,20,20,8,0
	DB 8,20,20,24,124,0
	DB 124,8,4,4,8,0
	DB 72,84,84,84,32,0
	DB 4,63,68,64,32,0
	DB 60,64,64,32,124,0
	DB 28,32,64,32,28,0
	DB 60,64,48,64,60,0
	DB 68,40,16,40,68,0
	DB 12,80,80,80,60,0
	DB 68,100,84,76,68,0
	DB 8,54,65,0,0,0
	DB 0,0,127,0,0,0
	DB 0,0,65,54,8,0
	DB 0,8,4,8,4,0
INVADER_SPLASH_SCREEN
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,64
	DB 112,120,124,124,124,124
	DB 124,252,248,240,224,192
	DB 192,124,124,124,124,124
	DB 124,124,124,124,124,124
	DB 248,240,224,192,0,0
	DB 128,124,124,124,124,124
	DB 124,124,124,112,128,0
	DB 0,0,128,192,240,248
	DB 62,62,62,62,62,62
	DB 62,62,62,124,248,224
	DB 192,254,254,62,62,62
	DB 62,62,62,62,62,62
	DB 62,62,32,160,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,96,240,12,6
	DB 6,6,6,134,134,134
	DB 6,6,6,12,25,243
	DB 199,63,255,2,2,2
	DB 2,2,130,130,130,130
	DB 2,6,12,25,51,231
	DB 248,0,255,2,2,2
	DB 2,2,2,2,2,6
	DB 255,0,0,254,255,243
	DB 113,8,12,6,2,2
	DB 130,130,130,2,2,2
	DB 7,15,255,63,192,252
	DB 30,2,2,2,3,195
	DB 195,195,195,195,195,67
	DB 115,31,3,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,3
	DB 60,224,128,0,0,3
	DB 30,97,94,88,88,88
	DB 88,153,191,64,3,255
	DB 192,0,0,0,1,255
	DB 131,255,0,0,0,0
	DB 0,255,7,254,15,0
	DB 0,0,248,127,224,0
	DB 0,0,15,252,0,255
	DB 1,255,0,0,0,0
	DB 0,254,31,12,15,8
	DB 8,8,248,126,7,252
	DB 31,3,0,0,0,0
	DB 15,15,13,232,56,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,1,99
	DB 230,44,40,40,104,232
	DB 152,240,0,1,1,7
	DB 254,131,127,240,0,0
	DB 0,1,225,33,96,48
	DB 48,12,6,1,0,255
	DB 0,0,0,0,143,140
	DB 143,0,0,0,0,63
	DB 248,63,254,7,0,0
	DB 0,128,255,193,254,14
	DB 2,2,130,251,31,224
	DB 255,3,0,0,0,240
	DB 190,131,131,227,130,131
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 0,192,64,64,92,124
	DB 124,252,252,240,64,76
	DB 124,124,124,252,252,248
	DB 32,0,12,60,60,124
	DB 252,252,243,6,12,24
	DB 48,113,241,241,241,208
	DB 24,12,63,61,60,255
	DB 252,248,24,24,223,30
	DB 60,60,60,60,60,60
	DB 63,248,8,8,8,14
	DB 15,60,63,63,56,56
	DB 56,56,63,62,125,243
	DB 236,8,248,248,120,56
	DB 56,56,60,63,63,62
	DB 62,63,56,56,56,232
	DB 136,248,120,56,56,60
	DB 63,62,62,56,48,32
	DB 64,128,192,240,248,252
	DB 254,126,62,30,30,30
	DB 30,30,28,16,0,64
	DB 128,0,0,0,0,6
	DB 14,54,198,130,2,6
	DB 28,48,198,143,59,227
	DB 130,2,6,12,48,110
	DB 251,195,3,2,2,2
	DB 30,115,159,115,195,131
	DB 3,7,28,112,193,7
	DB 127,195,3,3,3,3
	DB 127,192,255,255,255,255
	DB 3,3,3,3,3,3
	DB 3,7,62,195,127,224
	DB 0,0,255,3,3,1
	DB 225,225,33,225,1,1
	DB 3,6,143,248,255,63
	DB 252,7,1,1,1,1
	DB 225,225,161,161,161,33
	DB 225,241,63,227,60,7
	DB 1,1,1,193,97,225
	DB 97,1,1,1,1,199
	DB 127,153,112,60,6,2
	DB 3,193,49,177,113,49
	DB 1,1,129,193,118,24
	DB 0,0,0,0,0,1
	DB 6,12,48,64,128,1
	DB 6,12,49,198,156,112
	DB 192,0,0,1,7,0
	DB 128,0,0,0,7,30
	DB 240,131,14,56,224,128
	DB 0,7,12,127,128,0
	DB 0,0,0,255,7,255
	DB 255,255,0,0,0,0
	DB 255,224,0,0,0,7
	DB 248,143,252,128,255,0
	DB 0,0,255,7,0,255
	DB 0,0,0,128,255,255
	DB 143,126,3,0,0,0
	DB 0,228,167,166,166,38
	DB 254,126,207,249,15,1
	DB 0,0,192,200,206,9
	DB 7,1,48,240,104,44
	DB 39,57,62,195,64,64
	DB 200,78,11,8,10,155
	DB 242,3,3,3,1,0
	DB 0,0,0,0,0,0
	DB 0,0,0,0,0,0
	DB 1,2,12,48,96,192
	DB 193,198,93,247,204,48
	DB 224,192,192,71,94,108
	DB 48,96,64,67,94,116
	DB 4,5,6,24,112,64
	DB 64,64,64,64,64,71
	DB 126,7,1,127,64,64
	DB 64,64,121,9,9,112
	DB 64,64,64,79,116,1
	DB 127,64,64,64,71,68
	DB 70,65,64,32,16,15
	DB 1,67,127,64,64,64
	DB 64,64,79,72,72,72
	DB 120,8,112,94,67,64
	DB 64,96,56,71,123,71
	DB 65,64,112,28,7,3
	DB 62,97,65,97,105,111
	DB 109,102,97,48,16,28
	DB 6,3,0,0,0,0
	DB 0,0,0,0
F1_EOF equ $ ; INVADERS.BAS

 #include "D:\PRODEV\VSM\BASIC\ISIS_DSNS\INVADERS\INVADERS.STR"
	END

