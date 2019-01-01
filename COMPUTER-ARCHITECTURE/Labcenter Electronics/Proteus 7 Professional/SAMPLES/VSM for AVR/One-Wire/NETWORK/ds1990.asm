;CodeVisionAVR C Compiler V1.24.6 Evaluation
;(C) Copyright 1998-2005 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;e-mail:office@hpinfotech.com

;Chip type              : AT90S8515
;Clock frequency        : 3,686400 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External SRAM size     : 0
;Data Stack size        : 128 byte(s)
;Heap size              : 0 byte(s)
;Promote char to int    : No
;char is unsigned       : Yes
;8 bit enums            : Yes
;Word align FLASH struct: Yes
;Automatic register allocation : On

	.DEVICE AT90S8515
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __se_bit=0x20
	.EQU __sm_mask=0x10

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __CLRD1S
	LDI  R30,0
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+@2
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+@3
	LDS  R@1,@2+@3+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM


	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	RCALL __GETW1PF
	ICALL
	.ENDM


	.MACRO __CALL2EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	RCALL __EEPROMRDW
	ICALL
	.ENDM


	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	RCALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETW1SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOV  R30,R0
	MOV  R31,R1
	.ENDM

	.MACRO __GETB2SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOV  R26,R0
	MOV  R27,R1
	.ENDM

	.MACRO __GETBRSX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __CLRD1SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __PUTB2SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTBSRX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOV  R30,R28
	MOV  R31,R29
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOV  R26,R28
	MOV  R27,R29
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.CSEG
	.ORG 0

	.INCLUDE "ds1990.vec"
	.INCLUDE "ds1990.inc"

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,13
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0x200)
	LDI  R25,HIGH(0x200)
	LDI  R26,0x60
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM
	ADIW R30,1
	MOV  R24,R0
	LPM
	ADIW R30,1
	MOV  R25,R0
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM
	ADIW R30,1
	MOV  R26,R0
	LPM
	ADIW R30,1
	MOV  R27,R0
	LPM
	ADIW R30,1
	MOV  R1,R0
	LPM
	ADIW R30,1
	MOV  R22,R30
	MOV  R23,R31
	MOV  R31,R0
	MOV  R30,R1
__GLOBAL_INI_LOOP:
	LPM
	ADIW R30,1
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOV  R30,R22
	MOV  R31,R23
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0x25F)
	OUT  SPL,R30
	LDI  R30,HIGH(0x25F)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0xE0)
	LDI  R29,HIGH(0xE0)

	RJMP _main

	.ESEG
	.ORG 0
	.DB  0 ; FIRST EEPROM LOCATION NOT USED, SEE ATMEL ERRATA SHEETS

	.DSEG
	.ORG 0xE0
;       1 /* Dallas Semiconductor MicroLan seral numebr recognizer
;       2    1 Wire demo
;       3 
;       4    CodeVisionAVR C Compiler
;       5    (C) 2000-2002 HP InfoTech S.R.L.
;       6    www.hpinfotech.ro
;       7 
;       8    Chip: AT90S8515
;       9    Memory Model: SMALL
;      10    Data Stack Size: 128 bytes
;      11 
;      12    specify the port and bit used for the 1 Wire bus
;      13 
;      14    The 1-wire devices are connected to
;      15    bit 6 of PORTA of the AT90S8515 on the STK500
;      16    development board as follows:
;      17 
;      18    [DS1990]      [PORTA header]
;      19     1 GND         -   9  GND
;      20     2 DATA        -   7  PA6
;      21 
;      22    All the devices must be connected in parallel
;      23    
;      24    A 4.7k PULLUP RESISTOR MUST BE CONNECTED
;      25    BETWEEN DATA (PA6) AND PORTA HEADER PIN 10 (VTG) !
;      26 
;      27    In order to use the RS232 SPARE connector
;      28    on the STK500, the following connections must
;      29    be made:
;      30    [RS232 SPARE header] [PORTD header]
;      31    RXD                - 1 PD0
;      32    TXD                - 2 PD1
;      33 */
;      34 #asm
;      35     .equ __w1_port=0x1b
    .equ __w1_port=0x1b
;      36     .equ __w1_bit=6
    .equ __w1_bit=6
;      37 #endasm
;      38 
;      39 #include <1wire.h>
;      40 #include <90s8515.h>
;      41 #include <stdio.h>
;      42 
;      43 #define DS1990_FAMILY_CODE 1
;      44 #define DS2405_FAMILY_CODE 5
;      45 #define DS1822_FAMILY_CODE 0x22
;      46 #define DS2430_FAMILY_CODE 0x14
;      47 #define DS1990_FAMILY_CODE 1
;      48 #define DS2431_FAMILY_CODE 0x2d
;      49 #define DS18S20_FAMILY_CODE 0x10
;      50 #define DS2433_FAMILY_CODE 0x23
;      51 #define SEARCH_ROM 0xF0
;      52 
;      53 /* 1-wire devices ROM code storage area,
;      54    9 bytes are used for each device
;      55    (see the w1_search function description),
;      56    but only the first 8 bytes contain the ROM code
;      57    and CRC */
;      58 #define MAX_DEVICES 8
;      59 unsigned char rom_code[MAX_DEVICES,9];
_rom_code:
	.BYTE 0x48
;      60 
;      61 main() {

	.CSEG
_main:
;      62 unsigned char i,j,devices;
;      63 unsigned char n=1;
;      64 // init UART
;      65 UCR=8;
;	i -> R16
;	j -> R17
;	devices -> R18
;	n -> R19
	LDI  R19,1
	LDI  R30,LOW(8)
	OUT  0xA,R30
;      66 UBRR=23; // Baud=9600 @ 3.6864MHz
	LDI  R30,LOW(23)
	OUT  0x9,R30
;      67 // print welcome message
;      68 printf("1-Wire MicroLan Net demo\n\r");
	__POINTW1FN _0,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL SUBOPT_0x0
;      69 
;      70 // detect how many 1 Wire devices are present on the bus
;      71 devices=w1_search(SEARCH_ROM,&rom_code[0,0]);
	LDI  R30,LOW(240)
	ST   -Y,R30
	LDI  R30,LOW(_rom_code)
	LDI  R31,HIGH(_rom_code)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _w1_search
	MOV  R18,R30
;      72 printf("%u device(s) found\n\r",devices);
	__POINTW1FN _0,27
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R18
	RCALL SUBOPT_0x1
	LDI  R24,4
	RCALL SUBOPT_0x2
;      73 for (i=0;i<devices;i++)
	LDI  R16,LOW(0)
_0x4:
	CP   R16,R18
	BRLO PC+2
	RJMP _0x5
;      74   {      
;      75     // Acknowledge DS1990 family code.
;      76     if (rom_code[i,0]==DS1990_FAMILY_CODE)
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x1)
	BRNE _0x6
;      77        printf("DS1990  #%u serial number:",n++);
	__POINTW1FN _0,48
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      78     // Acknowledge DS2405s family code. 
;      79     else if (rom_code[i,0]==DS2405_FAMILY_CODE)
_0x6:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x5)
	BRNE _0x8
;      80        printf("DS2405  #%u serial number:",n++);
	__POINTW1FN _0,75
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      81     // Acknowledge DS1822s family code. 
;      82     else if (rom_code[i,0]==DS1822_FAMILY_CODE)
_0x8:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x22)
	BRNE _0xA
;      83        printf("DS1822  #%u serial number:",n++);
	__POINTW1FN _0,102
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      84     // Acknowledge DS2430s family code. 
;      85     else if (rom_code[i,0]==DS2430_FAMILY_CODE)
_0xA:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x14)
	BRNE _0xC
;      86        printf("DS2430  #%u serial number:",n++);
	__POINTW1FN _0,129
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      87     // Acknowledge DS18S20s family code. 
;      88     else if (rom_code[i,0]==DS18S20_FAMILY_CODE)
_0xC:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x10)
	BRNE _0xE
;      89        printf("DS18S20 #%u serial number:",n++);
	__POINTW1FN _0,156
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      90     // Acknowledge DS2431 family code. 
;      91     else if (rom_code[i,0]==DS2431_FAMILY_CODE)
_0xE:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x2D)
	BRNE _0x10
;      92        printf("DS2431  #%u serial number:",n++);
	__POINTW1FN _0,183
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
	RJMP _0x72
;      93     // Acknowledge DS2433 family code. 
;      94     else if (rom_code[i,0]==DS2433_FAMILY_CODE)
_0x10:
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	RCALL SUBOPT_0x5
	CPI  R26,LOW(0x23)
	BRNE _0x12
;      95        printf("DS2433  #%u serial number:",n++);
	__POINTW1FN _0,210
	RCALL SUBOPT_0x6
	SUBI R19,-1
	RCALL SUBOPT_0x1
	LDI  R24,4
_0x72:
	RCALL _printf
	ADIW R28,6
;      96       
;      97     for (j=1;j<=6;j++)
_0x12:
	LDI  R17,LOW(1)
_0x14:
	LDI  R30,LOW(6)
	CP   R30,R17
	BRLO _0x15
;      98         printf(" %02X",rom_code[i,j]); 
	__POINTW1FN _0,237
	ST   -Y,R31
	ST   -Y,R30
	RCALL SUBOPT_0x3
	PUSH R27
	PUSH R26
	RCALL SUBOPT_0x4
	POP  R26
	POP  R27
	ADD  R26,R30
	ADC  R27,R31
	MOV  R30,R17
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	RCALL SUBOPT_0x1
	LDI  R24,4
	RCALL SUBOPT_0x2
;      99     
;     100     printf("\n\r");
	SUBI R17,-1
	RJMP _0x14
_0x15:
	__POINTW1FN _0,24
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL SUBOPT_0x0
;     101     }
	SUBI R16,-1
	RJMP _0x4
_0x5:
;     102 }
_0x16:
	RJMP _0x16

_getchar:
     sbis usr,rxc
     rjmp _getchar
     in   r30,udr
	RET
_putchar:
     sbis usr,udre
     rjmp _putchar
     ld   r30,y
     out  udr,r30
	ADIW R28,1
	RET
__put_G2:
	put:
	RCALL SUBOPT_0x7
	SBIW R30,0
	BREQ _0x17
	RCALL SUBOPT_0x7
	ADIW R30,1
	ST   X+,R30
	ST   X,R31
	SBIW R30,1
	LDD  R26,Y+2
	STD  Z+0,R26
	RJMP _0x18
_0x17:
	LDD  R30,Y+2
	ST   -Y,R30
	RCALL _putchar
_0x18:
	ADIW R28,3
	RET
__print_G2:
	SBIW R28,6
	RCALL __SAVELOCR6
	LDI  R16,0
_0x19:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	ADIW R30,1
	STD  Y+16,R30
	STD  Y+16+1,R31
	RCALL SUBOPT_0x8
	MOV  R19,R30
	CPI  R30,0
	BRNE PC+2
	RJMP _0x1B
	MOV  R30,R16
	CPI  R30,0
	BRNE _0x1F
	CPI  R19,37
	BRNE _0x20
	LDI  R16,LOW(1)
	RJMP _0x21
_0x20:
	RCALL SUBOPT_0x9
_0x21:
	RJMP _0x1E
_0x1F:
	CPI  R30,LOW(0x1)
	BRNE _0x22
	CPI  R19,37
	BRNE _0x23
	RCALL SUBOPT_0x9
	LDI  R16,LOW(0)
	RJMP _0x1E
_0x23:
	LDI  R16,LOW(2)
	LDI  R21,LOW(0)
	LDI  R17,LOW(0)
	CPI  R19,45
	BRNE _0x24
	LDI  R17,LOW(1)
	RJMP _0x1E
_0x24:
	CPI  R19,43
	BRNE _0x25
	LDI  R21,LOW(43)
	RJMP _0x1E
_0x25:
	CPI  R19,32
	BRNE _0x26
	LDI  R21,LOW(32)
	RJMP _0x1E
_0x26:
	RJMP _0x27
_0x22:
	CPI  R30,LOW(0x2)
	BRNE _0x28
_0x27:
	LDI  R20,LOW(0)
	LDI  R16,LOW(3)
	CPI  R19,48
	BRNE _0x29
	ORI  R17,LOW(128)
	RJMP _0x1E
_0x29:
	RJMP _0x2A
_0x28:
	CPI  R30,LOW(0x3)
	BREQ PC+2
	RJMP _0x1E
_0x2A:
	CPI  R19,48
	BRLO _0x2D
	CPI  R19,58
	BRLO _0x2E
_0x2D:
	RJMP _0x2C
_0x2E:
	MOV  R18,R20
	LSL  R20
	LSL  R20
	ADD  R20,R18
	LSL  R20
	MOV  R30,R19
	SUBI R30,LOW(48)
	ADD  R20,R30
	RJMP _0x1E
_0x2C:
	MOV  R30,R19
	CPI  R30,LOW(0x63)
	BRNE _0x32
	RCALL SUBOPT_0xA
	LD   R30,X
	RCALL SUBOPT_0xB
	RJMP _0x33
_0x32:
	CPI  R30,LOW(0x73)
	BRNE _0x35
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0xC
	RCALL _strlen
	MOV  R16,R30
	RJMP _0x36
_0x35:
	CPI  R30,LOW(0x70)
	BRNE _0x38
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0xC
	RCALL _strlenf
	MOV  R16,R30
	ORI  R17,LOW(8)
_0x36:
	ORI  R17,LOW(2)
	ANDI R17,LOW(127)
	LDI  R18,LOW(0)
	RJMP _0x39
_0x38:
	CPI  R30,LOW(0x64)
	BREQ _0x3C
	CPI  R30,LOW(0x69)
	BRNE _0x3D
_0x3C:
	ORI  R17,LOW(4)
	RJMP _0x3E
_0x3D:
	CPI  R30,LOW(0x75)
	BRNE _0x3F
_0x3E:
	LDI  R30,LOW(_tbl10_G2*2)
	LDI  R31,HIGH(_tbl10_G2*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R16,LOW(5)
	RJMP _0x40
_0x3F:
	CPI  R30,LOW(0x58)
	BRNE _0x42
	ORI  R17,LOW(8)
	RJMP _0x43
_0x42:
	CPI  R30,LOW(0x78)
	BREQ PC+2
	RJMP _0x71
_0x43:
	LDI  R30,LOW(_tbl16_G2*2)
	LDI  R31,HIGH(_tbl16_G2*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R16,LOW(4)
_0x40:
	SBRS R17,2
	RJMP _0x45
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0xD
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	SBIW R26,0
	BRGE _0x46
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	RCALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R21,LOW(45)
_0x46:
	CPI  R21,0
	BREQ _0x47
	SUBI R16,-LOW(1)
	RJMP _0x48
_0x47:
	ANDI R17,LOW(251)
_0x48:
	RJMP _0x49
_0x45:
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0xD
_0x49:
_0x39:
	SBRC R17,0
	RJMP _0x4A
_0x4B:
	CP   R16,R20
	BRSH _0x4D
	SBRS R17,7
	RJMP _0x4E
	SBRS R17,2
	RJMP _0x4F
	ANDI R17,LOW(251)
	MOV  R19,R21
	SUBI R16,LOW(1)
	RJMP _0x50
_0x4F:
	LDI  R19,LOW(48)
_0x50:
	RJMP _0x51
_0x4E:
	LDI  R19,LOW(32)
_0x51:
	RCALL SUBOPT_0x9
	SUBI R20,LOW(1)
	RJMP _0x4B
_0x4D:
_0x4A:
	MOV  R18,R16
	SBRS R17,1
	RJMP _0x52
_0x53:
	CPI  R18,0
	BREQ _0x55
	SBRS R17,3
	RJMP _0x56
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RCALL SUBOPT_0x8
	RJMP _0x73
_0x56:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R30,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x73:
	ST   -Y,R30
	RCALL SUBOPT_0xE
	CPI  R20,0
	BREQ _0x58
	SUBI R20,LOW(1)
_0x58:
	SUBI R18,LOW(1)
	RJMP _0x53
_0x55:
	RJMP _0x59
_0x52:
_0x5B:
	LDI  R19,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
	SBIW R30,2
	RCALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
                                      ldd  r26,y+10  ;R26,R27=n
                                      ldd  r27,y+11
                                  calc_digit:
                                      cp   r26,r30
                                      cpc  r27,r31
                                      brlo calc_digit_done
	SUBI R19,-LOW(1)
	                                  sub  r26,r30
	                                  sbc  r27,r31
	                                  brne calc_digit
                                  calc_digit_done:
                                      std  Y+10,r26 ;n=R26,R27
                                      std  y+11,r27
	LDI  R30,LOW(57)
	CP   R30,R19
	BRSH _0x5D
	SBRS R17,3
	RJMP _0x5E
	SUBI R19,-LOW(7)
	RJMP _0x5F
_0x5E:
	SUBI R19,-LOW(39)
_0x5F:
_0x5D:
	SBRC R17,4
	RJMP _0x61
	LDI  R30,LOW(48)
	CP   R30,R19
	BRLO _0x63
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CPI  R26,LOW(0x1)
	LDI  R30,HIGH(0x1)
	CPC  R27,R30
	BRNE _0x62
_0x63:
	ORI  R17,LOW(16)
	RJMP _0x65
_0x62:
	CP   R20,R18
	BRLO _0x67
	SBRS R17,0
	RJMP _0x68
_0x67:
	RJMP _0x66
_0x68:
	LDI  R19,LOW(32)
	SBRS R17,7
	RJMP _0x69
	LDI  R19,LOW(48)
	ORI  R17,LOW(16)
_0x65:
	SBRS R17,2
	RJMP _0x6A
	ANDI R17,LOW(251)
	ST   -Y,R21
	RCALL SUBOPT_0xE
	CPI  R20,0
	BREQ _0x6B
	SUBI R20,LOW(1)
_0x6B:
_0x6A:
_0x69:
_0x61:
	RCALL SUBOPT_0x9
	CPI  R20,0
	BREQ _0x6C
	SUBI R20,LOW(1)
_0x6C:
_0x66:
	SUBI R18,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CP   R30,R26
	CPC  R31,R27
	BRSH _0x5C
	RJMP _0x5B
_0x5C:
_0x59:
	SBRS R17,0
	RJMP _0x6D
_0x6E:
	CPI  R20,0
	BREQ _0x70
	SUBI R20,LOW(1)
	LDI  R30,LOW(32)
	RCALL SUBOPT_0xB
	RJMP _0x6E
_0x70:
_0x6D:
_0x71:
_0x33:
	LDI  R16,LOW(0)
_0x1E:
	RJMP _0x19
_0x1B:
	RCALL __LOADLOCR6
	ADIW R28,18
	RET
_printf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,2
	RCALL __SAVELOCR2
	MOV  R26,R28
	MOV  R27,R29
	RCALL __ADDW2R15
	__PUTW2R 16,17
	LDI  R30,0
	STD  Y+2,R30
	STD  Y+2+1,R30
	MOV  R26,R28
	MOV  R27,R29
	ADIW R26,4
	RCALL __ADDW2R15
	RCALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	MOV  R30,R28
	MOV  R31,R29
	ADIW R30,6
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G2
	RCALL __LOADLOCR2
	ADIW R28,4
	POP  R15
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x0:
	RCALL _printf
	ADIW R28,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 9 TIMES
SUBOPT_0x1:
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x2:
	RCALL _printf
	ADIW R28,6
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES
SUBOPT_0x3:
	MOV  R30,R16
	LDI  R26,LOW(_rom_code)
	LDI  R27,HIGH(_rom_code)
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES
SUBOPT_0x4:
	LDI  R26,LOW(9)
	LDI  R27,HIGH(9)
	RCALL __MULW12U
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES
SUBOPT_0x5:
	ADD  R26,R30
	ADC  R27,R31
	LD   R26,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES
SUBOPT_0x6:
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R19
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x7:
	LD   R26,Y
	LDD  R27,Y+1
	RCALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x8:
	SBIW R30,1
	LPM
	MOV  R30,R0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES
SUBOPT_0x9:
	ST   -Y,R19
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	RJMP __put_G2

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES
SUBOPT_0xA:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	SBIW R26,4
	STD  Y+14,R26
	STD  Y+14+1,R27
	ADIW R26,4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xB:
	ST   -Y,R30
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	RJMP __put_G2

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xC:
	RCALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xD:
	RCALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xE:
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	RJMP __put_G2

_strlen:
	ld   r26,y+
	ld   r27,y+
	clr  r30
	clr  r31
__strlen0:
	ld   r22,x+
	tst  r22
	breq __strlen1
	adiw r30,1
	rjmp __strlen0
__strlen1:
	ret

_strlenf:
	clr  r26
	clr  r27
	ld   r30,y+
	ld   r31,y+
__strlenf0:
	lpm 
	tst  r0
	breq __strlenf1
	adiw r26,1
	adiw r30,1
	rjmp __strlenf0
__strlenf1:
	mov  r30,r26
	mov  r31,r27
	ret

_w1_init:
	clr  r30
	cbi  __w1_port,__w1_bit
	sbi  __w1_port-1,__w1_bit
	__DELAY_USW 0x1BA
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x11
	sbis __w1_port-2,__w1_bit
	ret
	__DELAY_USB 0x5D
	sbis __w1_port-2,__w1_bit
	inc  r30
	__DELAY_USW 0x167
	ret

__w1_read_bit:
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x2
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0xE
	clc
	sbic __w1_port-2,__w1_bit
	sec
	ror  r30
	__DELAY_USB 0x62
	ret

__w1_write_bit:
	clt
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x2
	sbrc r23,0
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x10
	sbic __w1_port-2,__w1_bit
	rjmp __w1_write_bit0
	sbrs r23,0
	rjmp __w1_write_bit1
	ret
__w1_write_bit0:
	sbrs r23,0
	ret
__w1_write_bit1:
	__DELAY_USB 0x5C
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x6
	set
	ret

_w1_write:
	ldi  r22,8
	ld   r23,y+
	clr  r30
__w1_write0:
	rcall __w1_write_bit
	brtc __w1_write1
	ror  r23
	dec  r22
	brne __w1_write0
	inc  r30
__w1_write1:
	ret

_w1_search:
	push r20
	push r21
	clr  r1
	clr  r20
	ld   r26,y
	ldd  r27,y+1
__w1_search0:
	mov  r0,r1
	clr  r1
	rcall _w1_init
	tst  r30
	breq __w1_search7
	ldd  r30,y+2
	st   -y,r30
	rcall _w1_write
	ldi  r21,1
__w1_search1:
	cp   r21,r0
	brsh __w1_search6
	rcall __w1_read_bit
	sbrc r30,7
	rjmp __w1_search2
	rcall __w1_read_bit
	sbrc r30,7
	rjmp __w1_search3
	rcall __sel_bit
	and  r24,r25
	brne __w1_search3
	mov  r1,r21
	rjmp __w1_search3
__w1_search2:
	rcall __w1_read_bit
__w1_search3:
	rcall __sel_bit
	and  r24,r25
	ldi  r23,0
	breq __w1_search5
__w1_search4:
	ldi  r23,1
__w1_search5:
	rcall __w1_write_bit
	rjmp __w1_search13
__w1_search6:
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search9
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search8
__w1_search7:
	mov  r30,r20
	pop  r21
	pop  r20
	adiw r28,3
	ret
__w1_search8:
	set
	rcall __set_bit
	rjmp __w1_search4
__w1_search9:
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search10
	rjmp __w1_search11
__w1_search10:
	cp   r21,r0
	breq __w1_search12
	mov  r1,r21
__w1_search11:
	clt
	rcall __set_bit
	clr  r23
	rcall __w1_write_bit
	rjmp __w1_search13
__w1_search12:
	set
	rcall __set_bit
	ldi  r23,1
	rcall __w1_write_bit
__w1_search13:
	inc  r21
	cpi  r21,65
	brlt __w1_search1
	rcall __w1_read_bit
	rol  r30
	rol  r30
	andi r30,1
	adiw r26,8
	st   x,r30
	sbiw r26,8
	inc  r20
	tst  r1
	breq __w1_search7
	ldi  r21,9
__w1_search14:
	ld   r30,x
	adiw r26,9
	st   x,r30
	sbiw r26,8
	dec  r21
	brne __w1_search14
	rjmp __w1_search0

__sel_bit:
	mov  r30,r21
	dec  r30
	mov  r22,r30
	lsr  r30
	lsr  r30
	lsr  r30
	clr  r31
	add  r30,r26
	adc  r31,r27
	ld   r24,z
	ldi  r25,1
	andi r22,7
__sel_bit0:
	breq __sel_bit1
	lsl  r25
	dec  r22
	rjmp __sel_bit0
__sel_bit1:
	ret

__set_bit:
	rcall __sel_bit
	brts __set_bit2
	com  r25
	and  r24,r25
	rjmp __set_bit3
__set_bit2:
	or   r24,r25
__set_bit3:
	st   z,r24
	ret

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ANEGW1:
	COM  R30
	COM  R31
	ADIW R30,1
	RET

__MULW12U:
	MOV  R0,R26
	MOV  R1,R27
	LDI  R24,17
	CLR  R26
	SUB  R27,R27
	RJMP __MULW12U1
__MULW12U3:
	BRCC __MULW12U2
	ADD  R26,R0
	ADC  R27,R1
__MULW12U2:
	LSR  R27
	ROR  R26
__MULW12U1:
	ROR  R31
	ROR  R30
	DEC  R24
	BRNE __MULW12U3
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETW1PF:
	LPM
	ADIW R30,1
	MOV  R1,R0
	LPM 
	MOV  R31,R0
	MOV  R30,R1
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
