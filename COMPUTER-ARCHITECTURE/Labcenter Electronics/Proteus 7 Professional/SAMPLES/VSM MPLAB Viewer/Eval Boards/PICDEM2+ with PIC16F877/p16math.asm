;************************************************************************
;*	Microchip Technology Inc. 2002					*
;*	Assembler version: 2.0000					*
;*	Filename: 							*
;*		p16math.asm						*
;************************************************************************

	list		p=16F877
	#include	P16F877.inc

	#define	_C	STATUS,0

MATH_VAR	UDATA	0X50
AARGB0		RES 1
AARGB1		RES 1
AARGB5		RES 1
BARGB0		RES 1
BARGB1		RES 1
REMB0		RES 1
REMB1		RES 1
TEMP		RES 1
LOOPCOUNT	RES 1

	GLOBAL	AARGB0, AARGB1, BARGB0

PROG2	CODE
;---------------- 8 * 8 UNSIGNED MULTIPLY -----------------------

;       Max Timing:     3+12+6*8+7 = 70 clks
;       Min Timing:     3+7*6+5+3 = 53 clks
;       PM: 19            DM: 4
UMUL0808L
		CLRF    AARGB1
                MOVLW   0x08
                MOVWF   LOOPCOUNT
                MOVF    AARGB0,W

LOOPUM0808A
                RRF     BARGB0, F
                BTFSC   _C
                GOTO    LUM0808NAP
                DECFSZ  LOOPCOUNT, F
                GOTO    LOOPUM0808A

                CLRF    AARGB0
                RETLW   0x00

LUM0808NAP
                BCF     _C
                GOTO    LUM0808NA

LOOPUM0808
                RRF             BARGB0, F
                BTFSC   _C
                ADDWF   AARGB0, F
LUM0808NA       RRF    AARGB0, F
                RRF    AARGB1, F
                DECFSZ          LOOPCOUNT, F
                GOTO            LOOPUM0808
		return
		GLOBAL	UMUL0808L
;----------------  16/8 UNSIGNED DIVIDE	  ------------------------
              
;       Max Timing: 2+7*12+11+3+7*24+23 = 291 clks
;       Min Timing: 2+7*11+10+3+7*17+16 = 227 clks
;       PM: 39                                  DM: 7

UDIV1608L
		GLOBAL		UDIV1608L
		CLRF            REMB0
                MOVLW           8
                MOVWF           LOOPCOUNT

LOOPU1608A      RLF             AARGB0,W
                RLF             REMB0, F
                MOVF            BARGB0,W
                SUBWF           REMB0, F

                BTFSC           _C
                GOTO            UOK68A          
                ADDWF           REMB0, F
                BCF             _C
UOK68A          RLF             AARGB0, F

                DECFSZ          LOOPCOUNT, F
                GOTO            LOOPU1608A

                CLRF            TEMP

                MOVLW           8
                MOVWF           LOOPCOUNT

LOOPU1608B      RLF             AARGB1,W
                RLF             REMB0, F
                RLF             TEMP, F
                MOVF            BARGB0,W
                SUBWF           REMB0, F
                CLRF            AARGB5
                CLRW
                BTFSS           _C
                INCFSZ          AARGB5,W
                SUBWF           TEMP, F

                BTFSC           _C
                GOTO            UOK68B          
                MOVF            BARGB0,W
                ADDWF           REMB0, F
                CLRF            AARGB5
                CLRW
                BTFSC           _C
                INCFSZ          AARGB5,W
                ADDWF           TEMP, F

                BCF             _C
UOK68B          RLF             AARGB1, F

                DECFSZ          LOOPCOUNT, F
                GOTO            LOOPU1608B
		return
		GLOBAL	UDIV1608L

		end
