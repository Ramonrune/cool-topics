;****************************************************************************
;*                                                                          *
;* DC/DC Power Supply Pulse generator.  Software provides Soft Start,       *
;* undervoltage lockout, overtemp shutdown, and an external active low      *
;* shutdown input.  The pulse rate is 250 kHz generater, with the softstart *
;* providing 0 to 100% over a 5 mS timeframe.  Over temperature and a supply*
;* voltage input below 0.6V ath the GP0 input will shut down the pulses and *
;* restart the softstart when both conditions change.                       *
;* PIC10F206 Pinout Definition:                                             *
;*                                                                          *
;* #	Name	Function                                                    *
;* 1	GP0	externally scaled supply voltage                            *
;* 2 	Vss	Ground                                                      *
;* 3 	GP1	digital output of temperature sensor                        *
;* 4	GP2 	250 kHz output for MCP1630                                  *
;* 5	Vdd	+2.5 to 5.5 Volts Power Supply (linear regulator)           *
;* 6	GP3 	MCLR input for !Shutdown control                            *
;****************************************************************************
;* Written by                                                               *
;*                                                                          *
;* Keith Curtis                                                             *
;* Pricipal Applications Engineer SMTD                                      *
;* Microchip Technology, Inc.                                               *
;* 2355 W. Chandler Blvd                                                    *
;* Chandler AZ, 85224-6199                                                  *
;*                                                                          *
;****************************************************************************
;* "ALL RIGHTS RESERVED.  COPYRIGHT 2004, MICROCHIP TECHNOLOGY INCORPORATED *
;* USA.  INFORMATION CONTAINED IN THIS PUBLICATION REGUARDING DEVICE 	    *
;* APPLICATIONS AND THE LIKE IS INTENDED THROUGH SUGGESTION ONLY AND MAY BE *
;* SUPERSEDED BY UPDATES.  NO REPRESENTATION OR WARRANTY IS GIVEN AND NO    *
;* LIABILITY IS ASSUMED BY MICROCHIP TECHNOLOGY INCORPORATED WITH RESPECT   *
;* TO THE ACCURACY OR USE OF SUCH INFORMATION, OR INFRINGMENT OF PATENTS    *
;* ARISING FROM SUCH USE OR OTHERWISE.  USE OF MICROCHIP'S PRODUCTS AS      *
;* CRITICAL COMPONENTS IN LIFE SUPPORT SYSTEMS IS NOT AUTHORIZED EXCEPT     *
;* WITH EXPRESS WRITTEN APPROVAL BY MICROCHIP.  NO LICENSES ARE CONVEYED,   *
;* IMPLICITLY OR OTHERWISE, UNDER ANY INTELLECTUAL PROPERTY RIGHTS"         *
;****************************************************************************
        
	#include p10f206.inc

	__CONFIG _MCLRE_ON & _CP_OFF & _WDT_ON & _IntRC_OSC

	ERRORLEVEL -302				; Get rid of banking messages...

	cblock 0x10				; Define all user varables starting at location 0x7
	counter					; delay timer value for softstart
	count					; delay timer for softstart
	pointer					; pointer into pulse table for softstart
	endc

#define PWM	GPIO,2				; pulse output for MCP1630
#define TMPSNS	GPIO,1				; input from TC6501

;****************************************************************************
;***** RESET VECTOR
	org 0x0					; Reset vector is at 0x0000

;****************************************************************************
;***** MAIN LINE CODE

Power_up
	clrf	GPIO				; preset port to zero

	movlw	b'11111011'			; configure Pulse output, all other input
	tris	GPIO

	movlw	b'01111011'			; enable comparator, vref on -, no output
	movwf	CMCON0

	movlw	b'10000000'			; set WDT for 18ms timeout
	option

	clrf	counter
StCt_delay					; wait for comparator output to stabalize
	decfsz	counter,f
	goto	StCt_delay

Start
	btfss	CMCON0,CMPOUT			; test for low supply voltage
	goto	Low_voltage			; if low, wait for supply to rise

Soft_start					; when voltage is high enough then softstart
	movlw	.32				; table has 32 softstart pulses maximum
	movwf	counter
	movlw	Last_pulse - Table		; set pointer to start with 1 pulse
	movwf	pointer
Loop
	movf	counter,w			; reset count variable with current delay time
	movwf	count
Delay						; generate no pulse delay
	nop
	decfsz	count,f
	goto	Delay
	movf	pointer,w			; load pointer for jump into pulse table
	addwf	PCL,f

;****************************************************************************
;***** PULSE GENERATING TABLE FOR SOFTSTART
Table
	bsf	PWM				; 32 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 31 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 30 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 29 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 28 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 27 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 26 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 25 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 24 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 23 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 22 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 21 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 20 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 19 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 18 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 17 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 16 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 15 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 14 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 13 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 12 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 11 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 10 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 9 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 8 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 7 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 6 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 5 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 4 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 3 pulses
	bcf	PWM
	goto	$+1

	bsf	PWM				; 2 pulses
	bcf	PWM
	goto	$+1

Last_pulse
	bsf	PWM				; last pulse
	bcf	PWM
	goto	$+1

	decf	pointer,f			; add another pulse to the chain
	decf	pointer,f
	decf	pointer,f
	decfsz	counter,f			; decrement the delay time
	goto	Loop				; do next burst of pulses

;****************************************************************************
;***** MAIN PULSE GENERATING LOOP

loop_forever					; main pulse generating loop
	bsf	PWM
	bcf	PWM
	btfss	CMCON0,CMPOUT			; test for low supply voltage
	goto	Low_voltage
	bsf	PWM
	bcf	PWM
	btfss	TMPSNS				; test for over temperature
	goto	High_temp
	bsf	PWM
	bcf	PWM
	clrwdt					; clear the watch dog timer
	nop
	bsf	PWM
	bcf	PWM
	goto	loop_forever

;****************************************************************************
;***** LOW VOLTAGE HANDLER ROUTINE

Low_voltage					; if a low supply voltage condition is found
	clrf	counter
LoVo_delay					; delay between supply voltage tests
	clrwdt
	decfsz	counter,f
	goto	LoVo_delay
	btfss	CMCON0,CMPOUT			; wait for the end of low supply voltage
	goto	Low_voltage			; if not the end then wait and test again
	goto	Start				; else startup soft start

;****************************************************************************
;***** HIGH TEMPERATURE HANDLER ROUTINE
High_temp					; if a high temperature condition is found
	clrf	counter
HiTmp_delay					; delay between temperature tests
	clrwdt
	decfsz	counter,f
	goto	HiTmp_delay
	btfss	TMPSNS				; wait for the end of low supply voltage
	goto	High_temp			; if still high, wait and test again
	goto	Start				; if not then start up soft start

	end
