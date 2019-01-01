;-----------------------------------------------------------------
;This program controls a BLDC motor using PIC18Fxx31 devices. 
;Hardware used is PICDEM MC development board 
;Hall sensors are used for commutation. Hall sensors sre connected to Input Capture pins 1,2,3 
;-----------------------------------------------------------------
;	Author	: Padmaraja Yedamale
;			: Home Appliance Solutions Group
;			: Microchip Technology Inc
; Version 	:1.0
;******************************************************************
;For Fundamentals of brushless DC motors, read app note AN885 from Microchip Technology
;This program is part of app note AN899-BLDC motor control using PIC18Fxx31 MCUs
;-----------------------------------------------------------------
;Description: 
;Up on reset, the LED1 to 4 display the potentiometer R44(REF) level. 
;LEDs will turn on for every 25% of the potentiometer level from counter clockwise(minimum)
;to clockwise(max) position. 
;Potentiometer R44(REF)connected to ADChannel AN1 is used for varying the speed.
;Switch SW1 is used for toggling between RUN and STOP  
;Switch SW2 is used for toggling between FORWARD and REVERSE direction of rotation
;Study blinking LED1 indicates a overcurrent fault condition 
;Study blinking LED2 indicates a overvoltage fault condition(based on Jumper JP5 setting either 200V or 400V.
;Study blinking LED1 indicates a overtemparature fault condition 
;Pressing any of the switches clear the fault.

;--------------------------------------------------
	include 	"BLDC_DATA.inc"		;Include file, all compile time options are defined in this file

;Include following files into the project
;This file(open_bldcHalIC.asm)
;motor_com1.asm
;BLDC_DATA.inc
;Apropriate linker script file
;--------------------------------------------------
;Setting configuration bits
	LIST p=18f4431,f=INHX32

	__CONFIG _CONFIG1H, 0x02 ;_OSC_HS_1H &_FCMEN_OFF_1H&_IESO_OFF_1H
	__CONFIG _CONFIG2L, 0x0E ;_PWRTEN_ON_2L & _BOREN_ON_2L & _BORV_20_2L  
	__CONFIG _CONFIG2H, 0x1E ;_WDTEN_OFF_2H
	__CONFIG _CONFIG3L, 0x3C ;0x24 _PWMPIN_OFF_3L & _LPOL_HIGH_3L & _HPOL_HIGH_3L & _GPTREN_ON_3L
	__CONFIG _CONFIG3H, 0x9D ;_FLTAMX_RC1_3H & _PWM4MX_RB5_3H
	__CONFIG _CONFIG4L, 0x01 
	__CONFIG _CONFIG5L, 0x0F 
	__CONFIG _CONFIG5H, 0xC0  
	__CONFIG _CONFIG6L, 0x0F 
	__CONFIG _CONFIG6H, 0xE0 
	__CONFIG _CONFIG7L, 0x0F 
	__CONFIG _CONFIG7H, 0x40    
;--------------------------------------------------
#define		HALL_60_DEGREE			
;Bodine motor has Hall sensor signals @ 60 degrees phase shift to each other 	
;#define		HALL_120_DEGREE	
;HURST motor has Hall sensor signals @ 120 degrees phase shift to each other 	

#define	SEND_TO_HYPERTERMINAL	
;Few Key parameters sent to hyper terminal at fixed interval, for debug purpose


#define	CYCLE_COUNT_MAXH	0x4E
#define	CYCLE_COUNT_MAXL	0x20
#define	MAX_FLTA_COUNT	.20				;Over current fault
#define	MAX_FLTB_COUNT	.25				;Over voltage fault
#define	MAX_HEATSINKTEMP	.180		;;Over Temparature fault

;----------------------------------------------
;FLAGS bits
#define	HALL_FLAG		0
#define	FLAG_FAULT		1
#define	PARAM_DISPLAY 	2
#define CALC_PWM		6

;FLAGS1 bits
#define	DEBOUNCE	0
#define	KEY_RS		1
#define	KEY_FR		2
#define	KEY_PRESSED 3
#define	RUN_STOP 4
#define	FWD_REV	5

;FLT_FLAGS bits
#define	OCUR	0
#define	OVOLT	1
#define	OTEMP	2


;Keys parameters
#define KEY_PORT PORTD
#define RUN_STOP_KEY 6
#define FWD_REV_KEY 7
#define DEBOUNCE_COUNT 0x4F
;Delay parameters
#define	DELAY_COUNT1	0x1F
#define	DELAY_COUNT2	0xFF
;LED parameters
#define LED_PORT PORTD
#define RUN_STOP_LED 1
#define FWD_REV_LED 2

#define	LED1	PORTD,0
#define	LED2	PORTD,1
#define	LED3	PORTD,2
#define	LED4	PORTC,0

;******************************************************************
;Routines used for displaying few key parameters 
;on the screen using Hyper terminal(serial port), refer to the motor_com1.asm
	extern		INITIALIZE_SERIAL_PORT
	extern		WELCOME_MESSAGE
	extern		DISPLAY_PARAMETERS
;----------------------------------------------------------------
	extern	DISPLAY_SPEED_REF	
	extern	DISPLAY_SPEED_ACTH	
	extern	DISPLAY_SPEED_ACTL	
	extern	DISPLAY_CURRENT_Iu	
	extern	DISPLAY_CURRENT_Iv	
	extern	DISPLAY_CURRENT_Iw	
	extern	DISPLAY_MISC_PARAH
	extern	DISPLAY_MISC_PARAL
	extern	DISPLAY_MISC_PARA2H
	extern	DISPLAY_MISC_PARA2L
;******************************************************************
BLDC_MOTOR_CONTROL	UDATA_ACS	;Variable definition in RAM, access bank

TEMP			res	1			;Temp registers
TEMP1			res	1
SPEED_REFH			res	1		;Speed referance read from ADC
SPEED_REFL			res	1
FLAGS				res	1		;Flag bits for vaious status indications
FLAGS1				res	1
DEBOUNCE_COUNTER	res	1		;Debounce Counter for toggle switches
COUNTER			res	1			; Counter for Delay routine
COUNTER1			res	1

POSITION_TABLE_FWD	res	8		;Sequence table for forward direction 
POSITION_TABLE_REV	res	8		;reverse direction

CURRENT_UH			res	1		;Current Phase H or DC bus current value stored 
CURRENT_UL			res	1
CURRENT_VH			res	1
CURRENT_VL			res	1
HEATSINK_TEMPH		res	1		;Heatsink temparature
HEATSINK_TEMPL		res	1

PDC_TEMPH			res	1
PDC_TEMPL			res	1

CYCLE_COUNTH		res	1		;PWM cycle count for various purposes	
CYCLE_COUNTL		res	1
FAULTA_COUNT		res	1		;FLTA count in cycle by cycle mode
FAULTB_COUNT		res	1		;FLTB count in cycle by cycle mode
PWM_CYCLE_COUNT		res	1		;PWM count for monitoring Fault window
FLT_FLAGS			res	1		;Flgs indicating faults
;----------------------------------------------------------------
STARTUP	code 0x00
	goto	Start		;Reset Vector address 
	
	CODE	0x08
	goto	ISR_HIGH	;Higher priority ISR at 0x0008

PRG_LOW	CODE	0x018
	goto	ISR_LOW		;Lower priority ISR at 0x0018
	
;****************************************************************
PROG	code
Start
;****************************************************************
	clrf	PDC_TEMPH				;Clear parameters
	clrf	PDC_TEMPL		
	clrf	SPEED_REFH		
	clrf	FLAGS
	clrf	FLAGS1
	
	call	FIRST_ADC_INIT			;Initialize ADC for first test

#ifdef	SEND_TO_HYPERTERMINAL
	call	INITIALIZE_SERIAL_PORT	;If serial communication is enabled, the serial port is initialized to communicate with hyper terminal
	call	WELCOME_MESSAGE			;dispaly "BLDC motor control"
#endif

WAIT_HERE
	call	LED_ON_OFF				;LED1-4 are turnedON/OFF based on pot R44(REF)level.
	call	KEY_CHECK
	btfss	FLAGS1,KEY_PRESSED
	bra		WAIT_HERE				; A press of SW1 or SW2 will take the control to motor control firmware 

	call	INIT_PERPHERALS			;Initialize ADCs, PWMs and ports for motor control application
	
	bcf		LED1					;OFF all LEDs
	bcf		LED2
	bcf		LED3
	bcf		LED4
	
	clrf	FLAGS
	clrf	FLAGS1
	clrf	FLT_FLAGS
	
	
	bsf		INTCON,PEIE				;Peripheral interrupts enable
	bsf		INTCON,GIE				;Global interrupt enable
;End of initialization 
;-------------------------------------------------------------------------
;Main loop: Control stays in this main loop.
;PWM duty cycle calculation,Checking for key activities 
;and sending parameters on serial port is done in this loop 
;-------------------------------------------------------------------------
MAIN_LOOP
	btfss	FLAGS,CALC_PWM			;Is new Speed referance ready?  
	bra		KEEP_SAME_PWM			;No, No need to update PWM duty cycle
	call	UPDATE_PWM				;Yes, Calculate new PWM duty cycle
	bcf		FLAGS,CALC_PWM			;Clear the flag

KEEP_SAME_PWM	
	call	KEY_CHECK				;Check for key activity
	call	PROCESS_KEY_PRESSED		;Process Key activity, if any

	btfss	ADCON0,GO				;Is ADC go bit set?
	bsf		ADCON0,GO				;Set GO bit for ADC conversion start	

DO_NEXT1
	btfss	FLAGS,PARAM_DISPLAY		;Check is it time for display parameters?
	goto	MAIN_LOOP
#ifdef	SEND_TO_HYPERTERMINAL
	call	DISPLAY_PARAMETERS		;Yes, display the slelcted parameters
#endif
	bcf		FLAGS,PARAM_DISPLAY
	goto	MAIN_LOOP
;--------------------------------------------------------------
;High priority interrupt service routine
;Input Capture 1,2,3, ADC and PWM interrupts are serviced in this 
;--------------------------------------------------------------
ISR_HIGH
	btfsc	PIR3,IC1IF				;Input capture 1, HallA state change?
	bra		HALL_A_HIGH
	btfsc	PIR3,IC2QEIF			;Input capture 2, HallB state change?
	bra		HALL_B_HIGH
	btfsc	PIR3,IC3DRIF			;Input capture 3, HallC state change?
	bra		HALL_C_HIGH

	btfsc	PIR1,ADIF				;ADC convertion over?
	bra		AD_CONV_COMPLETE	

	btfsc	PIR3,PTIF				;PWM interrupt?
	bra		PWM_INTERRUPT
	
	RETFIE	FAST

;******************************************************************
AD_CONV_COMPLETE			;ADC interrupt
	movff	ADRESL,CURRENT_UL	;Sample A = Iu
	movff	ADRESH,CURRENT_UH

	movff	ADRESL,SPEED_REFL	;Sample B = speed ref
	movff	ADRESH,SPEED_REFH

	movff	ADRESL,CURRENT_VL	;Sample C=Iv;Dummy, if all 3 current sensors are installed, 
	movff	ADRESH,CURRENT_VH	;check for phase current V

	movff	ADRESL,HEATSINK_TEMPL	;Sample D = Heatsink temparature
	movff	ADRESH,HEATSINK_TEMPH

	movff	CURRENT_UL,DISPLAY_CURRENT_Iu 	;Display current on hyper terminal
	movff	CURRENT_UH,DISPLAY_CURRENT_Iv  
	movff	HEATSINK_TEMPH,DISPLAY_CURRENT_Iw ;Display Heatsink temparature
	movff	SPEED_REFH,DISPLAY_SPEED_REF 		;Display Speed referance

	bsf		FLAGS,CALC_PWM		
	bcf		PIR1,ADIF		;ADIF flag is cleared for next interrupt
	RETFIE	FAST		

;******************************************************************
HALL_A_HIGH
	call	UPDATE_SEQUENCE		;Update the commutation sequence 
	btg		PORTD,0				;Turn on LED1 accordingly
	bcf		PIR3,IC1IF	
	RETFIE	FAST

HALL_B_HIGH
	call	UPDATE_SEQUENCE		;Update the commutation sequence 
	btg		PORTD,1				;Turn on LED2 accordingly
	bcf		PIR3,IC2QEIF
	RETFIE	FAST


HALL_C_HIGH
	call	UPDATE_SEQUENCE		;Update the commutation sequence 
	btg		PORTD,2				;Turn on LED3 accordingly
	bcf		PIR3,IC3DRIF	
	RETFIE	FAST

;-----------------------------------------
;This routine updates the commutation sequence based on the Hall sensor input state
;Hall sensors are connected to IC1,IC2 and IC3 pins on PORTA<4:2>
;----------------------------------------
UPDATE_SEQUENCE
;init table again
	btfss	FLAGS1,FWD_REV			;Is the command reverse?
	bra		ITS_REVERSE				;Yes, 
	lfsr	0,POSITION_TABLE_FWD	;No forward, Initialize FSR0 to the beginning of the Forward Table
	bsf		PORTC,0					;Turn ON LED4 to indicate Forward direction
	bra		PICK_FROM_TABLE
ITS_REVERSE
	lfsr	0,POSITION_TABLE_REV	;Initialize FSR0 to the beginning of the Reverse Table
	bcf		PORTC,0					;Turn OFF LED4 to indicate Forward direction
;--
PICK_FROM_TABLE
	movf	PORTA,W					;Read Hall input state
	andlw	0x1C					;IC1/IC2/IC3
	rrncf	WREG,W
	rrncf	WREG,W					;Shift Hall states to LSBits 
	movf	PLUSW0,W				;Read the value from table
	movwf	OVDCOND					;Load OVDCOND to allow rewuired PWMs and mask other PWMs
	return

;******************************************************************
ISR_LOW

	RETFIE	FAST		

;******************************************************************
;This routine checks for the Faults. Also sets the flag for parameter display
;Over current (Fault A),Over voltage(FaultB) is initialized in cycle-by-cycle mode. 
;If these faults occur very frequently, the mode is changed to catestriphic mode and PWMs are shut down
;The occurence of these faults are checked every PWM interrupt with a limit and if it exeeds the limit
;in 256 PWM cycles, the mode is changed to catestrophic.
;Heatsink temperature is compared with a pre defined limit and PWMs shut down, if the temp crosses the limit.
;LED1 is blinked at fixed rate, if the Overcurrent fault is detected in catestrophic mode 
;LED2 is blinked at fixed rate, if the Overvoltage fault is detected in catestrophic mode 
;LED3 is blinked at fixed rate, if the Overtemparature is detected 
PWM_INTERRUPT
	incfsz	PWM_CYCLE_COUNT,F
	bra		CHECK_FOR_FAULTS
	clrf	FAULTA_COUNT
	clrf	FAULTB_COUNT
	bra		CHECK_PARAMETER_DISPLAY	
	
CHECK_FOR_FAULTS
	btfss	FLTCONFIG,FLTAS
	bra		CHECK_FLTB
	incf	FAULTA_COUNT,F
	movlw	MAX_FLTA_COUNT
	cpfsgt	FAULTA_COUNT
	bra		CHECK_FLTB
	bcf		FLTCONFIG,FLTAMOD
	bsf		FLT_FLAGS,OCUR
CHECK_FLTB
	btfss	FLTCONFIG,FLTBS
	bra		CHECK_HEATSINK_TEMP
	incf	FAULTB_COUNT,F
	movlw	MAX_FLTB_COUNT
	cpfsgt	FAULTB_COUNT
	bra		CHECK_HEATSINK_TEMP
	bcf		FLTCONFIG,FLTBMOD
	bsf		FLT_FLAGS,OVOLT
CHECK_HEATSINK_TEMP
	movlw	MAX_HEATSINKTEMP
	cpfsgt	HEATSINK_TEMPH
	bra		CHECK_PARAMETER_DISPLAY		
	call	STOP_MOTOR
	bsf		FLT_FLAGS,OTEMP
;----------------------------------
CHECK_PARAMETER_DISPLAY
	movlw	CYCLE_COUNT_MAXH
	cpfseq	CYCLE_COUNTH
	bra		NOT_YET_THERE
	movlw	CYCLE_COUNT_MAXL
	cpfsgt	CYCLE_COUNTL
	bra		NOT_YET_THERE
	bsf		FLAGS,PARAM_DISPLAY
	clrf	CYCLE_COUNTH
	clrf	CYCLE_COUNTL
	btfsc	FLT_FLAGS,OCUR
	btg		LED1
	btfsc	FLT_FLAGS,OVOLT
	btg		LED2
	btfsc	FLT_FLAGS,OTEMP
	btg		LED3
	bcf		PIR3,PTIF
	retfie	FAST
NOT_YET_THERE
	incfsz	CYCLE_COUNTL,F
	retfie	FAST
	incf	CYCLE_COUNTH,F
	bcf		PIR3,PTIF
	retfie	FAST

;******************************************************************
;This routine calcuclates the PWM duty cycle based on the speed referance input from potentiometer
;Compile time constant gives a ratio of the DC bus voltage input and motor rated voltage wrt to the speed referance

UPDATE_PWM
	movlw	0x30					;Setting a minimum speed ref of 0x30
	cpfsgt	SPEED_REFH				
	bra		RESET_DUTY_CYCLE		;If the Speed ref<0x30, reset the PWM duty cycle
	
	movlw	0xF8
	cpfslt	SPEED_REFH	
	movwf	SPEED_REFH

;PWM = [(MotorVoltage/DCbus voltage)*(PTPER*4)]*[SpeedRef/255] *16
;16 is the multiplication factor; 
	movf	SPEED_REFH,W	
	mullw	(MAIN_PWM_CONSTANT)		;Compile time calculation, in .inc file
	swapf	PRODL,W
	andlw	0x0F
	movwf	PDC_TEMPL				;Devide the result by 16
	swapf	PRODH,W
	andlw	0xF0
	iorwf	PDC_TEMPL,F
	swapf	PRODH,W
	andlw	0x0F
	movwf	PDC_TEMPH
 
	bsf		PWMCON1,UDIS		;Disable the PWM buffer update

	movf	PDC_TEMPH,W			;Load the  duty cycles to all PWM duty cycle registers 
	movwf	PDC0H
	movwf	PDC1H
	movwf	PDC2H	
	movwf	PDC3H	

	movf	PDC_TEMPL,W
	movwf	PDC0L	
	movwf	PDC1L
	movwf	PDC2L
	movwf	PDC3L

	bcf		PWMCON1,UDIS	;Enable the PWM buffer update

	RETURN



;---------------------------------------------
RESET_DUTY_CYCLE
	clrf	PDC0H			;All duty cycles reset to zero
	clrf	PDC1H
	clrf	PDC2H
	clrf	PDC3H	
	clrf	PDC0L
	clrf	PDC1L
	clrf	PDC2L
	clrf	PDC3L

	call	UPDATE_SEQUENCE	;The sequence is updated even when the motor is not running
	RETURN					;The rotor may have moved by hand



;******************************************************************
INIT_PERPHERALS

;ADC initialization
;ADC is initialized to read 
;The Potentiometer connected to AN1
;Motor current Phase R or DC bus current connected to AN0
;Motor current Phase Y connected to AN6
;Motor current Phase B or Heatsink hermisotr connected to AN7

	movlw	0x07			
	movwf	TRISE			;RE0/1/2 are inputs
	movlw	b'00010101'		;ADC set in multiple channel sequential mode2(SEQM2)
	movwf	ADCON0
	movlw	b'00010000'		;FIFO buffer enabled
	movwf	ADCON1
	movlw	b'00110010'		;Left justified result,12 TAD acquisition time, ADC clock = FOsc/32
	movwf	ADCON2
	movlw	b'10000000'		;Interrupt generated when 4th word is written to bufeer
	movwf	ADCON3
	movlw	b'01000100' 	;AN0,AN1,AN6,AN7 are selected for conversion  
	movwf	ADCHS
	movlw	b'11000011'		;AN0,AN1,AN6,AN7 are selected as analog inputs  
	movwf	ANSEL0
	movlw	b'00000000'		;All other inputs set to digital
	movwf	ANSEL1
;-----------------------------------------------------------------
;PCPWM initalization
;PCPWM outputs initialized in independent mode. PWM<0:5> are enabled
	
	movlw	b'00000000'			;PWM timer is in free running mode(Edge aligned) with Fosc/4 input clock  
	movwf	PTCON0
	
	movlw	LOW(PTPER_VALUE)	; 20KHz = 0xFA		;20KHz of PWM frequency			
	movwf	PTPERL				;16KHz = 0x137
								;12KHz = 0x1A0	
	movlw	HIGH(PTPER_VALUE)
	movwf	PTPERH
	
	movlw	b'01001111'			;PWM0-5 enabled in independent mode
	movwf	PWMCON0
	
	movlw	b'00000001'			;Output overides synched wrt PWM timebase
	movwf	PWMCON1
	
	movlw	b'00000000'			;No dead time inserted		
	movwf	DTCON
	
	movlw	b'00000000'			;PWM<0:5> PWM Duty cycle on overide 
	movwf	OVDCOND
	
	movlw	b'00000000'			; All PWMs = 0 on init
	movwf	OVDCONS
	
	movlw	b'10110011'			;FaultA = Over current,cycle by cycle mode  
	movwf	FLTCONFIG			;FaultbB = Over voltage,cycle by cycle mode
	
	movlw	0x00				;Special event not used
	movwf	SEVTCMPL
	movlw	0x00
	movwf	SEVTCMPH

	clrf	PDC0L				;Clear all PWM duty cycle registers
	clrf	PDC1L	
	clrf	PDC2L	
	clrf	PDC3L	
	clrf	PDC0H	
	clrf	PDC1H	
	clrf	PDC2H	
	clrf	PDC3H	

	movlw	b'10000000'			;PWM timer ON
	movwf	PTCON1
;-----------------------------------------------------------------
;Initializing the motion feedback module to read Hall sensors using InputCapture 
;HallA/B/C @ IC1/IC2/IC3
	bsf		TRISA,2				;IC1/2/3 inputs
	bsf		TRISA,3
	bsf		TRISA,4
	movlw	b'00011001'			;Timer5 ON with prescale 1:8
	movwf	T5CON
	movlw	b'01001000'			;Cap1/2/3-capture every input state change
	movwf	CAP1CON
	movlw	b'01001000'			;Cap1/2/3-capture every input state change
	movwf	CAP2CON
	movlw	b'01001000'			;Cap1/2/3-capture every input state change
	movwf	CAP3CON
	movlw	b'00000000'			;Digital filters disabled
	movwf	DFLTCON
	movlw	b'00000000'			;Disable QEI
	movwf	QEICON

;-----------------------------------------------------------------
;init PORTC
;PortC<0> LED4 : Output
;PortC<1> FaultA(Overcurrent): Input
;PortC<2> FaultB(Overcurrent): Input
;PortC<6> TX: Output
;PortC<7> RX: Input

	movlw	b'10111110'			;PortC<0> LED4 used for LEDs,FaultA and FaultB
	movwf	TRISC
	bsf		PORTC,0
;-----------------------------------------------------------------
;init PORTD
;LED1,LED2,LED3 are connected to PORTD<0:2>
	movlw	0xD0
	movwf	TRISD
	bsf		PORTD,0
	bsf		PORTD,1
	bsf		PORTD,2

;-----------------------------------------------------------------
;The sequence table is enetered for two different types of motors.
;If Bodine-Electric motor is used, the Hall sensors are @ 60 deg phase shift to each other
;The secone sequence takes Hall sensor inputs at 120 degrees phase shift 
LOAD_SEQUENCE_TABLE

 ifdef	HALL_60_DEGREE	
;Forward sequence
	movlw	POSITION2
	movwf	POSITION_TABLE_FWD
	movlw	POSITION3
	movwf	POSITION_TABLE_FWD+1
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_FWD+2
	movlw	POSITION4
	movwf	POSITION_TABLE_FWD+3
	movlw	POSITION1
	movwf	POSITION_TABLE_FWD+4
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_FWD+5
	movlw	POSITION6
	movwf	POSITION_TABLE_FWD+6
	movlw	POSITION5
	movwf	POSITION_TABLE_FWD+7
;Reverse sequence
	movlw	POSITION5
	movwf	POSITION_TABLE_REV	
	movlw	POSITION6
	movwf	POSITION_TABLE_REV+1
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_REV+2
	movlw	POSITION1
	movwf	POSITION_TABLE_REV+3
	movlw	POSITION4
	movwf	POSITION_TABLE_REV+4
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_REV+5
	movlw	POSITION3
	movwf	POSITION_TABLE_REV+6
	movlw	POSITION2
	movwf	POSITION_TABLE_REV+7
 endif
 ifdef	HALL_120_DEGREE	
;Forward sequence
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_FWD
	movlw	POSITION2
	movwf	POSITION_TABLE_FWD+1
	movlw	POSITION6
	movwf	POSITION_TABLE_FWD+2
	movlw	POSITION1
	movwf	POSITION_TABLE_FWD+3
	movlw	POSITION4
	movwf	POSITION_TABLE_FWD+4
	movlw	POSITION3
	movwf	POSITION_TABLE_FWD+5
	movlw	POSITION5
	movwf	POSITION_TABLE_FWD+6
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_FWD+7
;Reverse sequence
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_REV
	movlw	POSITION5	
	movwf	POSITION_TABLE_REV+1
	movlw	POSITION3	
	movwf	POSITION_TABLE_REV+2
	movlw	POSITION4	
	movwf	POSITION_TABLE_REV+3
	movlw	POSITION1	
	movwf	POSITION_TABLE_REV+4
	movlw	POSITION6	
	movwf	POSITION_TABLE_REV+5
	movlw	POSITION2	
	movwf	POSITION_TABLE_REV+6
	movlw	DUMMY_POSITION
	movwf	POSITION_TABLE_REV+7
 endif 
;-----------------------------------------------------------------
	clrf	SPEED_REFH			
	clrf	CURRENT_UH	
	clrf	CURRENT_UL	
	clrf	CURRENT_VH	
	clrf	CURRENT_VL	
	clrf	HEATSINK_TEMPH		
	clrf	HEATSINK_TEMPL			
;-----------------------------------------------------------------
;Enable required interrupt

	bsf	PIE1,ADIE		;AD Converter over Interrupt enable
	bsf	PIE3,IC1IE		;Input Capture1 interrupt enabled
	bsf	PIE3,IC2QEIE	;Input Capture2 interrupt enabled
	bsf	PIE3,IC3DRIE	;Input Capture3 interrupt enabled
	bsf	PIE3,PTIE		;PWM interrupt enebled

	movlw	0x093		;Power ON reset status bit/Brownout reset status bit
	movwf	RCON		;and Instruction flag bits are set
						
	RETURN
	

;*******************************************************************************
;This routine checks for the keys status. 2 keys are checked, Run/Stop and 
;Forward(FWD)/Reverse(REV)  
;*******************************************************************************
KEY_CHECK
	btfsc	KEY_PORT,RUN_STOP_KEY			;Is key pressed "RUN/STOP"?
	goto	CHECK_FWD_REV_KEY
	btfsc	FLAGS1,DEBOUNCE
	return
	call	KEY_DEBOUNCE
	btfss	FLAGS1,DEBOUNCE
	return
	bsf		FLAGS1,KEY_RS
	return
	
CHECK_FWD_REV_KEY
	btfsc	KEY_PORT,FWD_REV_KEY			;Is key pressed "RUN/STOP"?
	goto	SET_KEYS
	btfsc	FLAGS1,DEBOUNCE
	return
	call	KEY_DEBOUNCE
	btfss	FLAGS1,DEBOUNCE
	return
	bsf		FLAGS1,KEY_FR
	return

SET_KEYS
	btfss	FLAGS1,DEBOUNCE
	return
	bcf		FLAGS1,DEBOUNCE
	bsf		FLAGS1,KEY_PRESSED	
	btfss	FLAGS1,KEY_RS
	bra		ITS_FWD_REV	
	btg		FLAGS1,RUN_STOP
	return
ITS_FWD_REV	
	btg		FLAGS1,FWD_REV
	return


;*******************************************************************************
KEY_DEBOUNCE
	decfsz	DEBOUNCE_COUNTER,F		;Key debounce time checked
	return
	bsf		FLAGS1,DEBOUNCE
	movlw	DEBOUNCE_COUNT
	movwf	DEBOUNCE_COUNTER
	return
;*******************************************************************************
;This routine takes action for the keys pressed
;If SW1(RUN/STOP) Key is pressed, the state toggles between RUN and STOP
;If SW2(FWD/REV) Key is pressed, the state toggles between FORWARD and REVERSE

PROCESS_KEY_PRESSED
	btfss	FLAGS1,KEY_PRESSED			;Is there a key press waiting?
	return
	btfss	FLAGS1,KEY_RS				;Is it RUN/STOP?
	goto	CHECK_FWD_REV
	btfss	FLAGS1,RUN_STOP				;Yes,Was the previous state a Stop?
	goto	STOP_MOTOR_NOW
	call	RUN_MOTOR_AGAIN				;Yes, Then RUN the motor 
	bcf		FLAGS1,KEY_PRESSED			;Clear the Flag
	bcf		FLAGS1,KEY_RS
	bsf		LED_PORT,RUN_STOP_LED		;Turn on LED to indicate motor running	
	return

STOP_MOTOR_NOW							
	call	STOP_MOTOR					;Was the previous state a RUN?, Then stop the motor
	bcf		FLAGS1,KEY_PRESSED
	bcf		FLAGS1,KEY_RS
	bcf		LED_PORT,RUN_STOP_LED		;Clear Flags and indicate motor stopped on LED
	return

CHECK_FWD_REV
	btfss	FLAGS1,KEY_FR				;Is the Key pressed = FWD/REV?
	return

	btg		LED_PORT,FWD_REV_LED		;Yes,
	bcf		LED_PORT,RUN_STOP_LED	
	call	STOP_MOTOR					;Stop the motor before reversing
	call	DELAY
	call	RUN_MOTOR_AGAIN				;Run the motor in Reverse direction
	bcf		FLAGS1,KEY_PRESSED			;Clear Flags
	bcf		FLAGS1,KEY_FR
	bsf		LED_PORT,RUN_STOP_LED	
	return

;*******************************************************************************
;This routine stops the motor by driving the PWMs to 0% duty cycle.
;*******************************************************************************
STOP_MOTOR
	bcf		PIE1,ADIE		;Disable all used interrupts 
	bcf		PIE3,IC1IE		
	bcf		PIE3,IC3DRIE	
	bcf		PIE3,IC2QEIE	
	bcf		PIE3,PTIE		
	clrf	OVDCOND			;Clear the over ride
	clrf	PDC0H			;Clear all PWM duty cycles
	clrf	PDC1H
	clrf	PDC2H	
	clrf	PDC3H	
	clrf	PDC0L	
	clrf	PDC1L
	clrf	PDC2L
	clrf	PDC3L
	bcf		FLAGS,CALC_PWM	;Clear the FLAG indicating the pending PWM calculation 
	clrf	SPEED_REFH		;Clear SPEED_REF 
	return
;*******************************************************************************
;This routine starts motor from previous stop with motor parameters initialized
;This routine may be called from Stop to run or while reversing the direction
;*******************************************************************************
RUN_MOTOR_AGAIN
;Re-initialize all variables and flags
	bsf		FLAGS1,RUN_STOP	
;-----------------------------------------------------------------
	clrf	SPEED_REFH
	clrf	CURRENT_UH	
	clrf	CURRENT_UL	
	clrf	CURRENT_VH	
	clrf	CURRENT_VL	
	clrf	HEATSINK_TEMPH		
	clrf	HEATSINK_TEMPL			
;-----------------------------------------------------------------
;Enable all used interrupt
	bsf		PIE1,ADIE
	bsf		PIE3,IC1IE		
	bsf		PIE3,IC3DRIE	
	bsf		PIE3,IC2QEIE	
	bsf		PIE3,PTIE		;PWM interrupt
	clrf	FLAGS

	movlw	b'10110011'		;Re initialize FaultA and FaultB in cycle by cycle mode 
	movwf	FLTCONFIG
	bcf		FLT_FLAGS,OCUR		;Clear Fault indicator bits
	bcf		FLT_FLAGS,OVOLT
	bcf		FLT_FLAGS,OTEMP

	call	UPDATE_SEQUENCE
	return


;------------------------------------------
;This routine is used only when the part comes out of a hard reset.
;The ADC in initialized to read the potentiometer continuously 
;and display the level on 4 LEDs(25% each)

FIRST_ADC_INIT
	movlw	0x03	
	movwf	TRISE	
	movlw	b'00100111'
	movwf	ADCON0
	movlw	b'00000000'
	movwf	ADCON1
	movlw	b'00110010'
	movwf	ADCON2
	movlw	b'00000000'
	movwf	ADCON3
	movlw	b'00000000' 
	movwf	ADCHS
	movlw	b'00000010'	
	movwf	ANSEL0
	movlw	b'00000000'
	movwf	ANSEL1

	bcf		TRISC,0
	bcf		TRISD,0
	bcf		TRISD,1
	bcf		TRISD,2
	return
	
LED_ON_OFF
	bcf		LED1
	bcf		LED2
	bcf		LED3
	bcf		LED4
	movlw	0X40
	cpfsgt	ADRESH	
	return
	bsf		LED4
	movlw	0x70
	cpfsgt	ADRESH
	return
	bsf		LED3
	movlw	0XA0
	cpfsgt	ADRESH	
	return
	bsf		LED2
	movlw	0XE0
	cpfsgt	ADRESH	
	return
	bsf		LED1
	return

;*******************************************************************************
;Delay routine.
;*******************************************************************************
DELAY
	movlw	DELAY_COUNT1
	movwf	COUNTER
dec_count	
	movlw	DELAY_COUNT2
	movwf	COUNTER1
dec_count1
	decfsz	COUNTER1,F
	goto	dec_count1
	decfsz	COUNTER,F
	goto	dec_count
	clrf	COUNTER
	clrf	COUNTER1
	return		

;******************************************************************

	END

