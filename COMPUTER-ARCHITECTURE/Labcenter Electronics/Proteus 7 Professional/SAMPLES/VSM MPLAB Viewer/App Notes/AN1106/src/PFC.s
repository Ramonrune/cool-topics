;**********************************************************************
; © 2005 Microchip Technology Inc. 
;
; FileName:        PFC.s
; Dependencies:    Header (.h) files if applicable, see below
; Processor:       dsPIC30Fxxxx
; Compiler:        MPLAB® C30 v3.00 or higher
;
; SOFTWARE LICENSE AGREEMENT:
; Microchip Technology Incorporated ("Microchip") retains all ownership and 
; intellectual property rights in the code accompanying this message and in all 
; derivatives hereto.  You may use this code, and any derivatives created by 
; any person or entity by or on your behalf, exclusively with Microchip,s 
; proprietary products.  Your acceptance and/or use of this code constitutes 
; agreement to the terms and conditions of this notice.
;
; CODE ACCOMPANYING THIS MESSAGE IS SUPPLIED BY MICROCHIP "AS IS".  NO 
; WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
; TO, IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A 
; PARTICULAR PURPOSE APPLY TO THIS CODE, ITS INTERACTION WITH MICROCHIP,S 
; PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION. 
;
; YOU ACKNOWLEDGE AND AGREE THAT, IN NO EVENT, SHALL MICROCHIP BE LIABLE, WHETHER 
; IN CONTRACT, WARRANTY, TORT (INCLUDING NEGLIGENCE OR BREACH OF STATUTORY DUTY), 
; STRICT LIABILITY, INDEMNITY, CONTRIBUTION, OR OTHERWISE, FOR ANY INDIRECT, SPECIAL, 
; PUNITIVE, EXEMPLARY, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, FOR COST OR EXPENSE OF 
; ANY KIND WHATSOEVER RELATED TO THE CODE, HOWSOEVER CAUSED, EVEN IF MICROCHIP HAS BEEN 
; ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.  TO THE FULLEST EXTENT 
; ALLOWABLE BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO 
; THIS CODE, SHALL NOT EXCEED THE PRICE YOU PAID DIRECTLY TO MICROCHIP SPECIFICALLY TO 
; HAVE THIS CODE DEVELOPED.
;
; You agree that you are solely responsible for testing the code and 
; determining its suitability.  Microchip has no obligation to modify, test, 
; certify, or support the code.
;
; REVISION HISTORY:
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Author          	Date      Comments on this revision
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vinaya Skanda 	12/12/07  First release of source file
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; ADDITIONAL NOTES:
; This code is tested on Explorer 16 Development Board with MC Interface PicTail Plus Daughter
; connected to the High Voltage Power Module. The dsPIC33F device is 
; used as the controller for this application

;***************************************************************************************************************************/



; ============================================================================================================================

; External References

.include "general.inc"
.include "PI.inc"

; ============================================================================================================================

; Define bit values

.equiv flag1, 0x0000
.equiv flag2, 0x0001
.equiv flag3, 0x0002

; ============================================================================================================================

; Declare Initialized local variables

.data

Vdc:			.word	0x0000	
VPIL:			.word	0x0000
VPIH:			.word	0x0000
IPIL:			.word	0x0000
IPIH:			.word	0x0000
flag:			.word 	0x0007

; ============================================================================================================================

; Declare Non Initialized local variables

.bss

SumVacHighTemp:		.space  2	
AverageVacSqr:		.space  2
TempSampleCount:	.space  2
TempSumVac:			.space  4
Vac:				.space 	2
VacByVavgSqr:		.space 	2
Iac:				.space	2
IacRef:				.space	2
VdcReference:		.space	2
VdcSoftStart:		.space	2

pfcVoltBaseAddr:	.space	30		  ; Base address of voltage loop parameters, allocate RAM space for Voltage PI I/O variables
pfcCurrBaseAddr: 	.space	30	 	  ; Base address of current loop parameters, allocate RAM space for Current PI I/O variables

; ============================================================================================================================


; Declare globals


.global Vdc
.global AverageVacSqr
.global VPIH
.global VPIL
.global IPIH
.global IPIL
.global IacRef
.global Vac
.global Vdc
.global Iac
.global VacByVavgSqr
.global VdcSoftStart
.global VdcReference
.global MinimumVavg

; ======================================================================

; Declare constants
/*		
.equ pfcMaxDuty, 866					; 	Saturate the maximum duty cycle value: 320
.equ voltMinRef, 200  					; 	Corresponds to 40V reference
.equ pfcVoltKp, 30000					;	Kp for voltage compensator
.equ pfcVoltKi, 1600					;	Ki for voltage compensator
.equ pfcVoltKc, 107						;	Kc for voltage compensator
.equ pfcVoltOutMax, 32767				;	Maximum Value for VPI output
.equ pfcVoltOutMin,	0					;	Minimum Value for VPI output
.equ VdcRef, 28736;28736				; 	Vdc Output Reference corresponds to 400 volt
.equ pfcCurrKp,	1400;1200				;	Kp for current compensator
.equ pfcCurrKi,	7000					;	Ki for current compensator
.equ pfcCurrKc,	50						;	Kc for current compensator
.equ pfcCurrOutMax, 32767				;   Maximum Value for IPI output
.equ pfcCurrOutMin, 800					;	Minimum Value for IPI output
.equ MinimumVavg,3000					;	Minimum Value of Vavg
.equ DutyScalingFactor, 40;100			;	Scaling Factor for PWM Duty Cycle
.equ AdcConvFactor, 0x8000				;	Factor for scaling the ADC Results
.equ SoftStartIncrement, 10				;	Softstart count to slowly rise the DC Bus Voltage
.equ Km1, 2								; 	Scaling constant
.equ Km2, 1								;	Scaling constant
*/
.equ pfcMaxDuty, 866					; 	Saturate the maximum duty cycle value: 320
.equ voltMinRef, 200  					; 	Corresponds to 40V reference
.equ pfcVoltKp, 30000					;	Kp for voltage compensator
.equ pfcVoltKi, 1600					;	Ki for voltage compensator
.equ pfcVoltKc, 107						;	Kc for voltage compensator
.equ pfcVoltOutMax, 32767				;	Maximum Value for VPI output
.equ pfcVoltOutMin,	0					;	Minimum Value for VPI output
.equ VdcRef, 28736;28736				; 	Vdc Output Reference corresponds to 400 volt
.equ pfcCurrKp,	1400;1200				;	Kp for current compensator
.equ pfcCurrKi,	7000					;	Ki for current compensator
.equ pfcCurrKc,	50						;	Kc for current compensator
.equ pfcCurrOutMax, 32767				;   Maximum Value for IPI output
.equ pfcCurrOutMin, 800					;	Minimum Value for IPI output
.equ MinimumVavg,3000					;	Minimum Value of Vavg
.equ DutyScalingFactor, 40;100			;	Scaling Factor for PWM Duty Cycle
.equ AdcConvFactor, 0x8000				;	Factor for scaling the ADC Results
.equ SoftStartIncrement, 50				;	Softstart count to slowly rise the DC Bus Voltage
.equ Km1, 2								; 	Scaling constant
.equ Km2, 1								;	Scaling constant

; ======================================================================

; Declare references to registers 

.equ PfcPwm, 		P2DC1	  ; Output Compare Duty Cycle	

; ======================================================================

.section  .text

; Read ADC Channel values

;	AN2 - Vdc - ADCBUF0	- DC Bus Voltage
;	AN3 - Iac - ADCBUF1/5 - Rectified AC Current
;	AN4 - Vac - ADCBUF4	- Rectified AC Voltage


; ======================================================================
; ======================================================================

; Compute AverageVac = (1/N)*(SUM(|Vac|)) for N samples

.global   _calcVsumAndFreq
.global   calcVsumAndFreq


_calcVsumAndFreq:
calcVsumAndFreq:



push.d w0
push.d w2
push.d w4
push.d w6
push.d w8

			mov.w ADCBUF4, w0
			mov.w #AdcConvFactor,w1
			xor w0,w1,w0
			lsr w0,#6,w0
		
compare:	mov.w #voltMinRef, w2
			cp w0,w2
			bra N, tempsum

; Execute if Vac > VREF
; Check status of flag1 and flag2 for clear condition

			btss flag,#flag1
			btsc flag,#flag2
			bra case2

; Execute if both flag1 and flag2 are clear


case1:		mov.w TempSampleCount, w0
			
; Saturate SampleCount


					mov.w _SampleCountMin, w1
					cp w0,w1
					bra N, SaturateMinCount
					bra DontSaturate

SaturateMinCount:	mov.w _SampleCountMin, w0
					bra continueSumVac	

DontSaturate:
					mov.w TempSampleCount, w0
						

continueSumVac:	
					mov.w w0,_SampleCount
					mov #TempSumVac, w0
					mov.d [w0],w2
					mov w3,ACCAH
					mov w2,ACCAL
					sftac A,#-5
					
		 
					mov.w ACCAL,w1
					mov.w ACCAH,w0
					
					mov.w w1, _SumVacLow
					mov.w w0, SumVacHighTemp

; Saturate SumVacHigh

					mov.w _SumVacHighMinimum, w1
					cp w0,w1
					bra N, SaturateMinSum
					bra DontSaturateSum

SaturateMinSum:		mov.w _SumVacHighMinimum, w0
					bra continueLoop


DontSaturateSum:	mov.w SumVacHighTemp,w0
					

continueLoop:	
			mov.w w0,_SumVacHigh	
		
			bset flag, #flag1
			bset flag, #flag2
			clr w0
			mov.w w0,TempSampleCount
			clr A

			clr w2
			clr w3
			mov.w #TempSumVac, w4
			mov.d w2, [w4]
						
			bra outofloop


case2:		mov.w ADCBUF4, w0
			mov.w #AdcConvFactor,w1
			xor w0,w1,w0
			lsr w0,#6,w0

			mov.w TempSampleCount, w6
			mov.w  w0,w8
			mov #TempSumVac, w0
			mov.d [w0],w2

			add w8,w2,w2
			addc #0,w3

			inc w6,w6
			mov.w w6, TempSampleCount
		
			mov.w #TempSumVac, w4
			mov.d w2, [w4]

			bclr flag, #flag1
			bra outofloop


tempsum:	;Check Condition
			btsc flag, #flag1
			bra outofloop

			mov.w ADCBUF4, w0
			mov.w #AdcConvFactor,w1
			xor w0,w1,w0
			lsr w0,#6,w0

			mov.w w0,w8
			mov.w TempSampleCount, w6

			mov #TempSumVac, w0
			mov.d [w0],w2

			add w8,w2,w2
			addc #0,w3

			inc w6,w6
			mov.w w6, TempSampleCount
		
			mov.w #TempSumVac, w4
			mov.d w2, [w4]
			bclr flag, #flag2
			


outofloop:

pop.d w8
pop.d w6
pop.d w4
pop.d w2
pop.d w0
;	
return

; ================================================================================================
; ================================================================================================


; Update AverageVac, 1/Vavg^2, read Iac, update IacRef
; IacRef = (VPI * Veff * |Vac|)
; Inputs to the function are SumVac, SampleCount


.global   _calcIacRef
.global   calcIacRef


_calcIacRef:
calcIacRef:

push.d w0
push.d w2
push.d w4
push.d w6
push.d w8

			
; Calculate Vavg=sum(Vac)/N
			mov.w _SumVacLow, w0
			mov.w _SumVacHigh,w1
			mov.w _SampleCount, w3
				
			repeat #17
			div.ud w0,w3
			mov  w0,_AverageVac	

Vavgcalc:		
			mov	 w0,w4


; Calculate Vavg^2
 			mpy	w4*w4,A
			mov	ACCAH,w3

			mov w3,AverageVacSqr
	
; Get the Vac in required format
			mov.w ADCBUF4, w0
			mov.w #AdcConvFactor,w1
			xor w0,w1,w0
			lsr w0,#1,w0
			
			mov	w0,Vac	

			mov Vac, w0
		
; Calculate Vac/Vavg^2
; Scale the input to get max value after division
			lac	w0,A
			sftac 	A,#7
			mov	ACCAL,w0
			mov	ACCAH,w1			

			repeat #17
			div.ud w0,w3		
		
			mov.w	 w0,VacByVavgSqr
			mov.w	 VacByVavgSqr,w4

; IacRef calculation and scaling to meet Iac(actual)

			mov.w VPIH, w5
			mpy	w4*w5,A									; IacRef = (Vac/Vavg^2) * Vpih

			mov.w ACCAH, w0
			mov.w w0,w2

			sl w2,#Km1,w2
			sl w0,#Km2,w0								; IacRef * Km where Km = 6 to get Po(max) at Vac(min)

			add w0,w2,w0
			
			mov.w w0, IacRef


pop.d w8
pop.d w6
pop.d w4
pop.d w2
pop.d w0

return



; ================================================================================================
; ================================================================================================


; PI Controller
; Inputs to the PI Controller are pfcVoltKp, pfcVoltKi, pfcVoltKc, pfcVoltOutMax, pfcVoltOutMin, VdcRef
; Output VPI


.global   _VoltagePIControl
.global   VoltagePIControl


_VoltagePIControl:
VoltagePIControl:

push.d w0
push.d w2
push.d w4
push.d w6
push.d w8
push.d w10
			
; Measured value of DC Bus Voltage
			
			mov.w  ADCBUF0, w0
			mov.w #AdcConvFactor,w1
			xor w0,w1,w0
			lsr w0,#1,w0

			mov.w  w0,Vdc
			
; SoftStart calculation for raising the DC Bus Voltage gradually upto the rated value of 400volt
					btsc flag,#flag3
					mov.w w0, VdcSoftStart
					
					bclr flag,#flag3
					mov.w VdcSoftStart, w0			
					mov.w #VdcRef, w1
					cp w0,w1
					bra GE, SteadyState
					mov.w #SoftStartIncrement, w0
					mov.w VdcSoftStart, w1
					add w0,w1,w0
					mov.w w0, VdcSoftStart
					mov.w w0, VdcReference
					bra PIController
					
				
SteadyState:			
					mov.w #VdcRef, w0
					mov.w w0, VdcReference

			
; Load PI input parameters to RAM locations
			
PIController:

			mov.w #pfcVoltKp, w0
			mov.w w0, pfcVoltBaseAddr+PI_qKp
			
			mov.w #pfcVoltKi, w0
			mov.w w0, pfcVoltBaseAddr+PI_qKi
			
			mov.w #pfcVoltKc, w0
			mov.w w0, pfcVoltBaseAddr+PI_qKc
			
			mov.w #pfcVoltOutMax, w0
			mov.w w0, pfcVoltBaseAddr+PI_qOutMax
			
			mov.w #pfcVoltOutMin, w0
			mov.w w0, pfcVoltBaseAddr+PI_qOutMin
			
			mov.w VdcReference, w0
			mov.w w0, pfcVoltBaseAddr+PI_qInRef
			
			mov.w Vdc, w0
			mov.w w0, pfcVoltBaseAddr+PI_qInMeas
			
			
; Send a handle to the PI subroutine for base address
			
			mov.w #pfcVoltBaseAddr, w0
			
			
; Call PI Controller Subroutine
			
			call _CalcPI
			
			mov.w pfcVoltBaseAddr+PI_qOut, w1
			mov.w w1,VPIH

back:	

pop.d w10
pop.d w8
pop.d w6
pop.d w4
pop.d w2
pop.d w0

	return


; ================================================================================================
; ================================================================================================


; PI Controller
; Inputs to the PI controller are pfcCurrKp, pfcCurrKi, pfcCurrKc, Outmax, Outmin, IacRef, Iac
; Output IPI
; Update PFC Duty Cycle 
; Write into the Output Compare Channel 6


.global   _CurrentPIControl
.global   CurrentPIControl


_CurrentPIControl:
CurrentPIControl:

push.d w0
push.d w2
push.d w4
push.d w6
push.d w8
push.d w10

; Measured value of Rectified AC Current
			
			mov.w  ADCBUF1, w0
mov.w w0, Iac
clr w1
btss w0, #15			
bra next
mov.w  w1,Iac


; Load PI input parameters to RAM locations
			
next:		mov.w #pfcCurrKp, w0
			mov.w w0,pfcCurrBaseAddr+PI_qKp
			
			mov.w #pfcCurrKi, w0
			mov.w w0,pfcCurrBaseAddr+PI_qKi
			
			mov.w #pfcCurrKc, w0
			mov.w w0,pfcCurrBaseAddr+PI_qKc
			
			mov.w #pfcCurrOutMax, w0
			mov.w w0,pfcCurrBaseAddr+PI_qOutMax
			
			mov.w #pfcCurrOutMin, w0
			mov.w w0,pfcCurrBaseAddr+PI_qOutMin
				
			mov.w IacRef, w0
			mov.w w0,pfcCurrBaseAddr+PI_qInRef
			
			mov.w Iac, w0
			sl w0,#1,w0
			mov.w w0,pfcCurrBaseAddr+PI_qInMeas
			
; Send a handle to the PI subroutine for base address
			
			mov.w #pfcCurrBaseAddr, w0
			
			
; Call PI Controller Subroutine
			
			call _CalcPI
			mov.w pfcCurrBaseAddr+PI_qOut, w0

; Scaling IPIH to match the duty cycle

			mov.w w0,w2
			mov.w #DutyScalingFactor, w3
			repeat #17
			div.u w2,w3
			mov.w w0,IPIH

;sl w0,#1,w0
;mov.w w0,IPIH

						mov.w #pfcMaxDuty, w1
						cp w1,w0
						bra LE, saturatePfc
						mov.w IPIH, w0
						mov.w w0, PfcPwm
						bra goback
			
saturatePfc:			mov.w #pfcMaxDuty, w1			
						mov.w w1, PfcPwm



goback:	

pop.d w10
pop.d w8
pop.d w6
pop.d w4
pop.d w2
pop.d w0


	return
