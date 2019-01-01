; This file contains functions for lighting the segments of the following LCD:
;	Manufacturer: Varitronix
;	Part Number:  VIM-332-DP	

; ******************** IMPORTANT: Read Below ************************
; The end of your linker file must contain the following SECTION declarations:
;
;SECTION    NAME=bank0    RAM=gpr0
;SECTION    NAME=bank1    RAM=gpr1
;SECTION    NAME=bank2    RAM=gpr2
;SECTION    NAME=bank3    RAM=gpr3
;SECTION    NAME=unbanked RAM=gprnobnk


#include	<p16f917.inc>

	errorlevel  -302              ; suppress message 302 from list file

; Available Functions
; All functions return with the BANK bits in the same state as when the function was entered
	global	InitLCD				; Call to initialize the PICmicro LCD registers 
	global	DisplayDigit1		; Displays digit 1: Enter with a number 0x00 to 0x0F in the W register
	global	DisplayDigit2		; Displays digit 2: Enter with a number 0x00 to 0x0F in the W register
	global	DisplayDigit3 		; Displays digit 3: Enter with a number 0x00 to 0x0F in the W register
	global	DisplayDigit4		; Displays digit 4: Enter with a number 0x00 or 0x01 in the W register
	global	DisplayA			; Displays "A"
	global	DisplayV			; Displays "V"
	global	DisplayK			; Displays "K"
	global	DisplayOmega		; Displays the Omega symbol
	global	DisplayRC			; Displays "RC"
	global	DisplayBATT			; Displays "BATT"
	global	DisplayNeg			; Displays "-"
	global	DisplayAC			; Displays "AC"
	global	Display2DP			; Displays the decimal point between Digit 1 and 2
	global	Display3DP			; Displays the decimal point between Digit 2 and 3
	global	Display4DP			; Displays the decimal point between Digit 3 and 4
	global	DisplayDH			; Displays "DH"
	global	DisplayRH			; Displays "RH"
	global	DisplayS1			; Displays symbol 1 (antenna radiating?)
	global	DisplayS2			; Displays symbol 2 (diode?)
	global	Displaym			; Displays "m"
	global	DisplayM			; Displays "M"

; assign variables
unbanked	udata_shr			; put in unbanked registers
W_Save		res		1			; register for saving W 

bank2		udata
STATUS_Save res 	1			; register for saving STATUS

; The following figure shows the letter designation given to the
; segments in a 7-segment display
;
;    ----a----
;   |         |	
;   f         b
;   |         |
;    ----g----
;   |         |
;   e         c
;   |         |
;    ----d----
;
; define segments
#define s1a LCDDATA2,6			;define segments for digit 1
#define s1b LCDDATA2,7
#define s1c LCDDATA8,7
#define s1d LCDDATA11,6
#define s1e LCDDATA8,6
#define s1f LCDDATA5,6
#define s1g LCDDATA5,7

#define s2a LCDDATA0,6			;define segments for digit 2
#define s2b LCDDATA2,5
#define s2c LCDDATA8,5
#define s2d LCDDATA9,6
#define s2e LCDDATA6,6
#define s2f LCDDATA3,6
#define s2g LCDDATA5,5

#define s3a LCDDATA0,3			;define the segments for digit 3
#define s3b LCDDATA1,3
#define s3c LCDDATA7,3
#define s3d LCDDATA9,3
#define s3e LCDDATA6,3
#define s3f LCDDATA3,3
#define s3g LCDDATA4,3

#define s4bc LCDDATA6,2			;define segnent for digit 4

#define s2dp LCDDATA11,5		;decimal point between digit 1 and 2
#define s3dp LCDDATA10,3		;decimal point between digit 2 and 3
#define	s4dp LCDDATA9,2			;decimal point between digit 3 and 4
#define	sA   LCDDATA0,0			; A
#define	sV   LCDDATA3,0			; V
#define	sK   LCDDATA6,0			; K
#define	sOmg LCDDATA9,0			; Omega
#define	sRC  LCDDATA0,1			; RC
#define	sBAT LCDDATA3,1			; BATT
#define	sNeg LCDDATA6,1			; Neg sign/Dash
#define sAC  LCDDATA9,1			; AC
#define sDH  LCDDATA0,2			; DH
#define	sRH  LCDDATA3,2			; RH
#define	sS1  LCDDATA2,0			; S1
#define	sS2  LCDDATA5,0			; S2
#define	sm   LCDDATA8,0			; m
#define	sM   LCDDATA11,0		; M


PORT1	code

InitLCD
	movf	STATUS,w
	banksel	STATUS_Save
	movwf	STATUS_Save

	MOVLW	B'01001111'			
	MOVWF	LCDSE0
	MOVLW	B'00001000'	
	movwf	LCDSE1
	movlw	B'11100001'
	movwf	LCDSE2

	CLRF	LCDDATA0
	CLRF	LCDDATA1
	CLRF	LCDDATA2
	CLRF	LCDDATA3
	CLRF	LCDDATA4
	CLRF	LCDDATA5
	CLRF	LCDDATA6
	CLRF	LCDDATA7
	CLRF	LCDDATA8
	CLRF	LCDDATA9
	CLRF	LCDDATA10
	CLRF	LCDDATA11

	MOVLW	B'00100000'			;WAVEFORM TYPE A, LCD MODULE IS ACTIVE
	MOVWF	LCDPS				;PRESCALER IS 1:1,  BIAS IS 0 (CAN BE STATIC OR 1/3)

	MOVLW	B'10010011'			;LDC MODULE IS ON, DRIVER MODULE IS ENABLED DURING SLEEP
	MOVWF	LCDCON				;NO WRITE FAIL ERROR, VLDC PINS ARE ENABLED, MULTIPLEX 1/4 BIAS 1/3

	goto	done

DisplayDigit1
; w has the digit to display
	movwf	W_Save				; Store pointer
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	movlw	high d1_table
	movwf	PCLATH
	movf	W_Save,w
	andlw	0x0F				; mask off jump table pointer
	addlw	low d1_table
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
d1_table
	goto	d10
	goto	d11
	goto	d12
	goto	d13
	goto	d14
	goto	d15
	goto	d16
	goto	d17
	goto	d18
	goto	d19
	goto	d1A
	goto	d1B
	goto	d1C
	goto	d1D
	goto	d1E
	goto	d1F
d10	
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bsf	s1d
	bsf	s1e
	bsf	s1f
	bcf	s1g
	goto	done	
d11
	bcf	s1a
	bsf	s1b
	bsf	s1c
	bcf	s1d
	bcf	s1e
	bcf	s1f
	bcf	s1g
	goto	done	
d12
	bsf	s1a
	bsf	s1b
	bcf	s1c
	bsf	s1d
	bsf	s1e
	bcf	s1f
	bsf	s1g
	goto	done	
d13
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bsf	s1d
	bcf	s1e
	bcf	s1f
	bsf	s1g
	goto	done	
d14
	bcf	s1a
	bsf	s1b
	bsf	s1c
	bcf	s1d
	bcf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d15
	bsf	s1a
	bcf	s1b
	bsf	s1c
	bsf	s1d
	bcf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d16
	bsf	s1a
	bcf	s1b
	bsf	s1c
	bsf	s1d
	bsf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d17
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bcf	s1d
	bcf	s1e
	bcf	s1f
	bcf	s1g
	goto	done	
d18
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bsf	s1d
	bsf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d19
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bsf	s1d
	bcf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d1A
	bsf	s1a
	bsf	s1b
	bsf	s1c
	bcf	s1d
	bsf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d1B						
	bcf	s1a
	bcf	s1b
	BsF	s1c
	BsF	s1d
	BsF	s1e
	BsF	s1f
	BsF	s1g
	goto	done	
d1C
	bsf	s1a
	bcf	s1b
	bcf	s1c
	bsf	s1d
	bsf	s1e
	bsf	s1f
	bcf	s1g
	goto	done	
d1D
	bcf	s1a
	bsf	s1b
	bsf	s1c
	bsf	s1d
	bsf	s1e
	bcf	s1f
	bsf	s1g
	goto	done	
d1E
	bsf	s1a
	bcf	s1b
	bcf	s1c
	bsf	s1d
	bsf	s1e
	bsf	s1f
	bsf	s1g
	goto	done	
d1F								
	bsf	s1a
	bcf	s1b
	bcf	s1c
	bcf	s1d
	bsf	s1e
	bsf	s1f
	bsf	s1g
	goto	done

DisplayDigit2
; w has the digit to display
	movwf	W_Save				; Store pointer
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	movlw	high d2_table
	movwf	PCLATH
	movf	W_Save,w
	andlw	0x0F				; mask off jump table pointer
	addlw	low d2_table
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
d2_table
	goto	d20
	goto	d21
	goto	d22
	goto	d23
	goto	d24
	goto	d25
	goto	d26
	goto	d27
	goto	d28
	goto	d29
	goto	d2A
	goto	d2B
	goto	d2C
	goto	d2D
	goto	d2E
	goto	d2F
d20	
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bsf	s2d
	bsf	s2e
	bsf	s2f
	bcf	s2g
	goto	done	
d21
	bcf	s2a
	bsf	s2b
	bsf	s2c
	bcf	s2d
	bcf	s2e
	bcf	s2f
	bcf	s2g
	goto	done	
d22
	bsf	s2a
	bsf	s2b
	bcf	s2c
	bsf	s2d
	bsf	s2e
	bcf	s2f
	bsf	s2g
	goto	done	
d23
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bsf	s2d
	bcf	s2e
	bcf	s2f
	bsf	s2g
	goto	done	
d24
	bcf	s2a
	bsf	s2b
	bsf	s2c
	bcf	s2d
	bcf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d25
	bsf	s2a
	bcf	s2b
	bsf	s2c
	bsf	s2d
	bcf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d26
	bsf	s2a
	bcf	s2b
	bsf	s2c
	bsf	s2d
	bsf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d27
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bcf	s2d
	bcf	s2e
	bcf	s2f
	bcf	s2g
	goto	done	
d28
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bsf	s2d
	bsf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d29
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bsf	s2d
	bcf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d2A
	bsf	s2a
	bsf	s2b
	bsf	s2c
	bcf	s2d
	bsf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d2B						
	bcf	s2a
	bcf	s2b
	BsF	s2c
	BsF	s2d
	BsF	s2e
	BsF	s2f
	BsF	s2g
	goto	done	
d2C
	bsf	s2a
	bcf	s2b
	bcf	s2c
	bsf	s2d
	bsf	s2e
	bsf	s2f
	bcf	s2g
	goto	done	
d2D
	bcf	s2a
	bsf	s2b
	bsf	s2c
	bsf	s2d
	bsf	s2e
	bcf	s2f
	bsf	s2g
	goto	done	
d2E
	bsf	s2a
	bcf	s2b
	bcf	s2c
	bsf	s2d
	bsf	s2e
	bsf	s2f
	bsf	s2g
	goto	done	
d2F								
	bsf	s2a
	bcf	s2b
	bcf	s2c
	bcf	s2d
	BSF	s2e
	bsf	s2f
	bsf	s2g
	goto	done

DisplayDigit3
; w has the digit to display
	movwf	W_Save				; Store pointer
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	movlw	high d3_table
	movwf	PCLATH
	movf	W_Save,w
	andlw	0x0F				; mask off jump table pointer
	addlw	low d3_table
	btfsc	STATUS,C	
	incf	PCLATH,f
	movwf	PCL
d3_table
	goto	d30
	goto	d31
	goto	d32
	goto	d33
	goto	d34
	goto	d35
	goto	d36
	goto	d37
	goto	d38
	goto	d39
	goto	d3A
	goto	d3B
	goto	d3C
	goto	d3D
	goto	d3E
	goto	d3F
d30						
	BsF	s3a
	BsF	s3b
	BsF	s3c
	BsF	s3d
	BsF	s3e
	BsF	s3f
	BCF	s3g
	goto	done	
d31						
	BCF	s3a
	BsF	s3b
	BsF	s3c
	BCF	s3d
	BCF	s3e
	BCF	s3f
	BcF	s3g
	goto	done	
d32
	bsf	s3a
	bsf	s3b
	bcf	s3c
	bsf	s3d
	bsf	s3e
	bcf	s3f
	bsf	s3g
	goto	done	
d33
	bsf	s3a
	bsf	s3b
	bsf	s3c
	bsf	s3d
	bcf	s3e
	bcf	s3f
	bsf	s3g
	goto	done	
d34
	bcf	s3a
	bsf	s3b
	bsf	s3c
	bcf	s3d
	bcf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d35
	bsf	s3a
	bcf	s3b
	bsf	s3c
	bsf	s3d
	bcf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d36
	bsf	s3a
	bcf	s3b
	bsf	s3c
	bsf	s3d
	bsf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d37
	bsf	s3a
	bsf	s3b
	bsf	s3c
	bcf	s3d
	bcf	s3e
	bcf	s3f
	bcf	s3g
	goto	done	
d38
	bsf	s3a
	bsf	s3b
	bsf	s3c
	bsf	s3d
	bsf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d39
	bsf	s3a
	bsf	s3b
	bsf	s3c
	bsf	s3d
	bcf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d3A
	bsf	s3a
	bsf	s3b
	bsf	s3c
	bcf	s3d
	bsf	s3e
	bsf	s3f
	bsf	s3g
	goto	done	
d3B						
	bcf	s3a
	bcf	s3b
	BsF	s3c
	BsF	s3d
	BsF	s3e
	BsF	s3f
	BsF	s3g
	goto	done	
d3C
	bsf	s3a
	bcf	s3b
	bcf	s3c
	bsf	s3d
	bsf	s3e
	bsf	s3f
	bcf	s3g
	goto	done	
d3D
	bcf	s3a
	bsf	s3b
	bsf	s3c
	bsf	s3d
	bsf	s3e
	bcf	s3f
	bsf	s3g
	goto	done	
d3E
	bsf	s3a
	bcf	s3b
	bcf	s3c
	bsf	s3d
	bsf	s3e
	bsf	s3f
	bsf	s3g
	goto	done
d3F							
	bsf	s3a
	bcf	s3b
	bcf	s3c
	bcf	s3d
	bsf	s3e
	bsf	s3f
	bsf	s3g
	goto	done

DisplayDigit4
	movwf	W_Save				; Store pointer
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	movf	W_Save,w
	xorlw	0x00
	btfss	STATUS,Z
	bsf		s4bc
	btfsc	STATUS,Z
	bcf		s4bc
	goto	done

Display2DP
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		s2dp
	goto	done

Display3DP
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		s3dp
	goto	done

Display4DP
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		s4dp
	goto	done

DisplayA
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sA
	goto	done

DisplayV
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sV
	goto	done

DisplayK
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sK
	goto	done

DisplayOmega
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sOmg
	goto	done

DisplayRC
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sRC
	goto	done

DisplayBATT
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sBAT
	goto	done

DisplayNeg
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sNeg
	goto	done

DisplayAC
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sAC
	goto	done

DisplayDH
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sDH
	goto	done

DisplayRH
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sRH
	goto	done

DisplayS1
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sS1
	goto	done

DisplayS2
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sS2
	goto	done

Displaym
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sm
	goto	done

DisplayM
	movf	STATUS,w			; Save off STATUS
	banksel	STATUS_Save
	movwf	STATUS_Save
	bsf		sM
	goto	done
	
done
	movf	STATUS_Save,w
	movwf	STATUS
	return

	end
