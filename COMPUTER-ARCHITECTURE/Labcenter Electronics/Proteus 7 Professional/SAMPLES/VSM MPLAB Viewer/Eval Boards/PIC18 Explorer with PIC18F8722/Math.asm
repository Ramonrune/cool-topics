;************************************************************************
;*	Microchip Technology Inc. 2008										*
;*	Assembler version: x.xx												*
;*	Filename: 															*
;*		Math.asm (main routine)   										*
;*	Dependents:															*
;*		LCD.asm															*
;*		Main.asm														*
;*		18F8722.lkr	or18F87J11											*													*
;* HPC DEMO code. The following functions are included 					*
;*	with this code:														*
;*		1. Voltmeter													*
;*			The center tap of R3 is connected to RA0, the				*
;*			A/D converter converts this analog voltage and				*
;*			the result is displayed on the LCD in a range				*
;*			from 0.00V - 5.00V.											*
;*		2. Temperature													*
;*			The MCP9701A Analog  Thermal Sensor is used to    			*
;*			measure ambient temperature. 								*
;*		3. Clock														*
;*			This function is a real-time clock. When the				*
;*			mode is entered, time begins at 00:00:00. The 				*
;*			user can set the time if desired.							*
;************************************************************************
#ifdef __18F8722
	list p=18F8722
	#include p18F8722.inc
#endif
#ifdef __18F87J11
	list p=18F87J11
	#include p18F87J11.inc
#endif

	#define	_C	STATUS,0

MATH_VAR	UDATA_ACS
AARGB0		RES 1
AARGB1		RES 1
AARGB5		RES 1
BARGB0		RES 1
BARGB1		RES 1
REMB0		RES 1
REMB1		RES 1
TEMP		RES 1
LOOPCOUNT	RES 1

RES0  res	1
RES1  res	1
RES2  res	1
RES3  res	1

ARG1H res	1
ARG1L res	1
ARG2H res	1
ARG2L res	1


	GLOBAL	AARGB0, AARGB1, BARGB0,ARG1H,ARG1L,ARG2H,ARG2L,RES0,RES1,RES2,RES3,Mul16 

PROG2	CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;16*16 unsigned multiplication routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mul16
	MOVF 	ARG1L, W
	MULWF 	ARG2L ; ARG1L * ARG2L ->
	; PRODH:PRODL
	MOVFF 	PRODH, RES1 ;
	MOVFF 	PRODL, RES0 ;
	;
	MOVF 	ARG1H, W
	MULWF 	ARG2H ; ARG1H * ARG2H ->
	; PRODH:PRODL
	MOVFF 	PRODH, RES3 ;
	MOVFF 	PRODL, RES2 ;
	;
	MOVF 	ARG1L, W
	MULWF 	ARG2H ; ARG1L * ARG2H ->
	; PRODH:PRODL
	MOVF 	PRODL, W ;
	ADDWF 	RES1, F ; Add cross
	MOVF 	PRODH, W ; products
	ADDWFC 	RES2, F ;
	CLRF 	WREG ;
	ADDWFC 	RES3, F ;
	;
	MOVF 	ARG1H, W ;
	MULWF 	ARG2L ; ARG1H * ARG2L ->
	; PRODH:PRODL
	MOVF 	PRODL, W ;
	ADDWF 	RES1, F ; Add cross
	MOVF 	PRODH, W ; products
	ADDWFC 	RES2, F ;
	CLRF 	WREG ;
	ADDWFC 	RES3, F ;
	return
;----------------  16/8 UNSIGNED DIVIDE	  ------------------------
              
;       Max Timing: 2+7*12+11+3+7*24+23 = 291 clks
;       Min Timing: 2+7*11+10+3+7*17+16 = 227 clks
;       PM: 39                                  DM: 7

UDIV1608L
		GLOBAL		UDIV1608L
		CLRF            REMB0
                MOVLW           8
                MOVWF           LOOPCOUNT

LOOPU1608A      RLCF             AARGB0,W
                RLCF             REMB0, F
                MOVF            BARGB0,W
                SUBWF           REMB0, F

                BTFSC           _C
                bra            UOK68A          
                ADDWF           REMB0, F
                BCF             _C
UOK68A          RLCF             AARGB0, F

                DECFSZ          LOOPCOUNT, F
                bra            LOOPU1608A

                CLRF            TEMP

                MOVLW           8
                MOVWF           LOOPCOUNT

LOOPU1608B      RLCF             AARGB1,W
                RLCF             REMB0, F
                RLCF             TEMP, F
                MOVF            BARGB0,W
                SUBWF           REMB0, F
                CLRF            AARGB5
;                CLRW
				movlw	0x00
                BTFSS           _C
                INCFSZ          AARGB5,W
                SUBWF           TEMP, F

                BTFSC           _C
                bra            UOK68B          
                MOVF            BARGB0,W
                ADDWF           REMB0, F
                CLRF            AARGB5
       ;         CLRW
				movlw		0x00
                BTFSC           _C
                INCFSZ          AARGB5,W
                ADDWF           TEMP, F

                BCF             _C
UOK68B          RLCF             AARGB1, F

                DECFSZ          LOOPCOUNT, F
                bra            LOOPU1608B
		return
		GLOBAL	UDIV1608L

		end
