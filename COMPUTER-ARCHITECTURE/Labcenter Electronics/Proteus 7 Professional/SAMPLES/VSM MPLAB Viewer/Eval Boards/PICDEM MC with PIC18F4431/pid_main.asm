
;********************************************************************
;                                                                   *
;   Filename:	    pid_main.asm                                    *
;   Date:  			9/2/03                                     		*
;   File Version: 	2.00                                            *
;   Author: 		Chris Valenti                                   *
;  	Company:  		Microchip Technology Inc.                       *
;																	*
;                                                                   *
;********************************************************************
;    Files required:                                                *
;					pic18_math.asm									*
;                                                                   *
;********************************************************************

;--------------------------------------------------------------------
;PID Notes:

;	PROPORTIONAL= 	(system error * Pgain )
;	System error = error0:error1

;	INTEGRAL 	= 	(ACUMULATED ERROR  * Igain)
;	Accumulated error (a_error) = error0:error1 + a_error0:a_error1:a_error2

;	DERIVATIVE	=	((CURRENT ERROR  - PREVIOUS ERROR) * Dgain) 
;	delta error(d_error) = errro0:error1 - p_error0:p_error1

;	Integral & Derivative control will be based off sample periods of "x" time.
;	The above sample period should be based off the PLANT response
;	to control inputs. 
;		SLOW Plant response = LONGER sample periods
;		FAST Plant response = SHORTER sample periods

;	If the error is equal to zero then no PID calculations are completed.

;	The PID routine is passed the 16- bit errror data by the main application
;	code through the "	error0:error1	" variables.
;	The sign of this error is passed through the error sign bit: 
;		"	pid_stat1,err_sign	"

;	Current PID Limits
;	Max Input (error0:error1) 		+/- 0 - 4000d (0xFA0)
;	Max	Output (pid_out0:pid_out2)	+/- 0 - 160000 (0x27100)
;	Max accumulated error is defined below.
;-----------------------------------------------------------------------

;        list		p=18F452       
;        #include	<p18f452.inc>  
		
;	__CONFIG	_CONFIG1H, _OSCS_OFF_1H & _HSPLL_OSC_1H
;	__CONFIG	_CONFIG2L, _BOR_OFF_2L & _BORV_20_2L & _PWRT_OFF_2L
;	__CONFIG	_CONFIG2H, _WDT_OFF_2H & _WDTPS_128_2H
;	__CONFIG	_CONFIG3H, _CCP2MX_ON_3H
;	__CONFIG	_CONFIG4L, _STVR_OFF_4L & _LVP_OFF_4L & _DEBUG_OFF_4L
;	__CONFIG	_CONFIG5L, _CP0_OFF_5L & _CP1_OFF_5L & _CP2_OFF_5L & _CP3_OFF_5L 
;	__CONFIG	_CONFIG5H, _CPB_OFF_5H & _CPD_OFF_5H
;	__CONFIG	_CONFIG6L, _WRT0_OFF_6L & _WRT1_OFF_6L & _WRT2_OFF_6L & _WRT3_OFF_6L 
;	__CONFIG	_CONFIG6H, _WRTC_OFF_6H & _WRTB_OFF_6H & _WRTD_OFF_6H
;	__CONFIG	_CONFIG7L, _EBTR0_OFF_7L & _EBTR1_OFF_7L & _EBTR2_OFF_7L & _EBTR3_OFF_7L
;	__CONFIG	_CONFIG7H, _EBTRB_OFF_7H
;	
;	errorlevel	-302 

	include 	"BLDC_DATA.inc"

;***** SYSTEM CONSTANTS
#define	a_err_1_lim	0x0F	;accumulative error limits (4000d)
#define	a_err_2_lim	0xA0

#define	timer1_lo	0x9B	;4D	;0x00	;Timer1 timeout defined by timer1_lo & timer1_hi
#define	timer1_hi	0xEC	;F6	;0x80	;this timout is based on Fosc/4

#define P_GAIN .96			;Kp has a X16 multiplication factor
#define I_GAIN .80			;Ki has a X16 multiplication factor
#define D_GAIN .16			;Kd has a X16 multiplication factor

#define deriv_cnt	.4		;determies how often the derivative term will be executed.

;#define	pid_100				;comment out if not using 0 - 100% scale

		
	EXTERN	FXM1616U,FXD2416U,_24_BitAdd,_24_bit_sub	
	EXTERN	AARGB0,AARGB1,AARGB2,AARGB3		
	EXTERN	BARGB0,BARGB1,BARGB2,BARGB3
	EXTERN	ZARGB0,ZARGB1,ZARGB2
	EXTERN	REMB0,REMB1
	EXTERN	TEMP,TEMPB0,TEMPB1,TEMPB2,TEMPB3
	EXTERN	LOOPCOUNT,AEXP,CARGB2
	
;---------------------------------------------------
	GLOBAL	error0
	GLOBAL	error1
	GLOBAL	pid_out0
	GLOBAL	pid_out1
	GLOBAL	pid_out2
	GLOBAL	pid_stat1
	GLOBAL	kp
	GLOBAL	ki
;***** VARIABLE DEFINITIONS 

;pid_data	UDATA
PID_VAR		UDATA	0x60	
#ifdef	pid_100
percent_err	RES	1			;8-bit error input, 0 - 100% (0 - 100d)
percent_out	RES	1			;8-bit output, 0 - 100% (0 - 100d)
#endif		

pid_out0	RES	1			;24-bit Final Result of PID for the "Plant"
pid_out1	RES	1
pid_out2	RES	1

error0		RES	1			;16-bit error, passed to the PID
error1		RES	1			
a_error0	RES	1			;24-bit accumulated error 
a_error1	RES	1			
a_error2	RES	1
p_error0	RES	1			;16-bit previous error 
p_error1	RES	1			
d_error0	RES	1			;16-bit delta error (error - previous error)
d_error1	RES	1

prop0		RES	1			;24-bit proportional value 
prop1		RES	1
prop2		RES	1
integ0		RES 1			;24-bit Integral value 
integ1		RES	1
integ2		RES	1
deriv0		RES 1			;24-bit Derivative value 
deriv1		RES	1
deriv2		RES	1

kp			RES	1			;8-bit proportional Gain
ki			RES	1			;8-bit integral Gain
kd			RES	1			;8-bit derivative Gain

pid_stat1	RES	1			;PID bit-status register
pid_stat2	RES	1			;PID bit-status register2
deriv_count	RES	1			;derivative count register
temp_reg	RES	1			;temporary register
t_temp_reg	RES	1			;interrupt temp register

T_WREG		RES	1
T_STATUS	RES	1
T_BSR		RES	1
T_AARGB0	RES	1			;temporary registers for ISR
T_AARGB1	RES	1
T_AARGB2	RES	1
T_AARGB3	RES	1
T_BARGB0	RES	1
T_BARGB1	RES	1
T_BARGB2	RES	1
T_BARGB3	RES	1
T_REMBO		RES	1
T_REMB1		RES	1
T_TEMP		RES	1
T_LOOPCOUNT	RES	1
T_TEMPB0	RES	1
T_TEMPB1	RES	1
T_TEMPB2	RES	1
T_TEMPB3	RES	1
T_ZARGB0	RES	1
T_ZARGB1	RES	1
T_ZARGB2	RES	1
T_CARGB2	RES	1

	;***** pid_stat1 Bit Names
err_z		equ	0			;error zero flag, Zero = set
a_err_z		equ	1			;a_error zero flag, Zero = set
err_sign	equ	2			;error sign flag, Pos = set/ Neg = clear
a_err_sign	equ	3			;a_error sign flag, Pos = set/ Neg = clear
p_err_sign	equ	4			;a_error sign flag, Pos = set/ Neg = clear
mag			equ	5			;set = AARGB magnitude, clear = BARGB magnitude
d_err_sign	equ	6			;d_error sign flag, Pos = set/ Neg = clear
pid_sign	equ	7			;PID result sign flag, Pos = set/ Neg = clear
	;***** pid_stat2 Bit Names
integ_go	equ	0			;1 = integral term should be included in the PID result
deriv_go	equ	1			;1 = derivative term should be included in the PID result
d_err_z		equ	2			;d_error zero flag, Zero = set

timer_expire equ	7
;-----------------------------------------------------------------------
;R_VECTOR	CODE	0x0000	;processor reset vector
;	goto    start           ;go to beginning of program

;HI_INT_VEC	CODE	0x0008	;interrupt vector location
;	bra		highInt

;--------------------------- INITALIZATION ------------------------------
pid_code	CODE	;0x010	;start PID code here
;start		

PID_INIT
	GLOBAL	PID_INIT	
	clrf	BSR

	clrf	error0,1			
	clrf	error1,1	
	clrf	a_error0,1	
	clrf	a_error1,1		
	clrf	a_error2,1
	clrf	p_error0,1
	clrf	p_error1,1
	clrf	d_error0,1
	clrf	d_error1,1
	
	clrf	prop0,1
	clrf	prop1,1
	clrf	prop2,1
	clrf	integ0,1
	clrf	integ1,1
	clrf	integ2,1
	clrf	deriv0,1
	clrf	deriv1,1
	clrf	deriv2,1
	
	clrf	kp,1
	clrf	ki,1
	clrf	kd,1
	
	clrf	pid_out0,1
	clrf	pid_out1,1
	clrf	pid_out2,1
	
	clrf	AARGB0,1
	clrf	AARGB1,1
	clrf	AARGB2,1
	clrf	BARGB0,1
	clrf	BARGB1,1
	clrf	BARGB2,1
	
;	clrf	PORTA			;clear PORTS
;	clrf	PORTB
;	clrf	TRISA			;make I/O outputs
;	clrf	TRISB
	
	movlw	b'00000001'		;configure T1 for Timer operation from Fosc/4
	movwf	T1CON
	movlw	timer1_hi		;load T1 registers with 5ms count
	movwf	TMR1H
	movlw	timer1_lo
	movwf	TMR1L
			
	movlw	P_GAIN		;10 x 16, Kp, Ki & Kd are 8-bit vlaues that cannot exceed 255
	movwf	kp,1			;Enter the PID gains scaled by a factor of 16, max = 255

	movlw	I_GAIN   ;80 ;10 x 16
	movwf	ki,1
	
	movlw	D_GAIN	;10 x 16
	movwf	kd,1
	
	movlw	deriv_cnt
	movwf	deriv_count,1				;derivative action = TMR1H:TMR1L * deriv_count
	bcf		pid_stat1,err_z,1			;start w/error not equal to zero
	bsf		pid_stat1,p_err_sign,1	;start w/ previous error = positive
	bsf		pid_stat1,a_err_sign,1	;start w/ accumulated error = positive	
	bcf		pid_stat2,integ_go,1		;initalize integral go bit to 0
	bcf		pid_stat2,deriv_go,1		;initalize derivative go bit to 0
	
	bcf		PIR1,TMR1IF				;clear T1 flag
	bsf		INTCON,PEIE				;enable peripheral interrupts
	bsf		INTCON,GIE				;enable global interrupts
	bsf		PIE1,TMR1IE				;enable T1 interrupt
	
	return	
;------------------------------PID MAIN ------------------------------------		
PID_MAIN		
	GLOBAL	PID_MAIN	

pid_main		

#ifdef		pid_100				;if using % scale then scale up PLANT error
	movlw	.40					; 0 - 100% == 0 - 4000d			
	mulwf	percent_err,1		;40 * percent_err --> PRODH:PRODL
	movff	PRODH,error0		
	movff	PRODL,error1		;percentage has been scaled and available in error0:error1
#endif	
	
			;---START PROPORTIONAL			
	movlw	0
	cpfseq	error0,1				;Is error0 = 00 ?		
	bra		call_prop			;NO, done checking
	
	cpfseq	error1,1				;YES, Is error1 = 00 ?		
	bra		call_prop			;NO, start proportional term
	bsf		pid_stat1,err_z,1		;YES, set error zero flag
	return
;	bra		pid_main			;look for error again
call_prop
;	btfss		pid_stat2,timer_expire,1
;	return

;	call	PID_INT_CALC


	call	proportional		;NO
	call	get_a_error			;get a_error, is a_error = 00? reached limits?

	call 	get_pid_result
;	goto 	pid_main			;testing  do again
	Return		
		
;-------------------------- PROPORTIONAL TERM --------------------------																	
;	Proportional value = error0:error1 * Proportional gain
;	Propoertional term sign = error sign
proportional	
	clrf	BARGB0,1			
	movff	kp,BARGB1	
	movff	error0,AARGB0						
	movff	error1,AARGB1
	call	FXM1616U		;proportional gain * error	

	movff	AARGB1,prop0	;AARGB2 --> prop0
	movff	AARGB2,prop1	;AARGB3 --> prop1	
	movff	AARGB3,prop2	;AARGB4 --> prop2			
	return					;return to mainline code
	
	
;-------------------------- START INTEGRAL TERM ------------------------------								
;	Integral value = (a_erro1:a_error2 * Integral gain)
;	Integral term sign = a_error sign
start_integral		
	clrf	BARGB0,1			
	movff	ki,BARGB1
	movff	a_error1,AARGB0							
	movff	a_error2,AARGB1			
	call	FXM1616U		;Integral gain * accumulated error
		
	movff	AARGB1,integ0	;AARGB1 --> integ0	
	movff	AARGB2,integ1	;AARGB2 --> integ1	
	movff	AARGB3,integ2	;AARGB3 --> integ2	
	return					;return to ISR	
	
		
;----------------------- START DERIVATIVE TERM -----------------------------
;	Derivative value = ((current error - previous error) * Derivative gain)
;	Derivative term sign = result of current error - previous error
start_deriv
	call	get_delta_error		;error - p_error
	btfsc	pid_stat2,d_err_z,1	;Is d_error = 0?	
	return						;YES, return to ISR
	bsf		pid_stat2,deriv_go,1	;NO, set derivative go bit for PID calculation	
	
	movff	d_error1,BARGB1		;result ---> BARGB1			
	movff	d_error0,BARGB0		;result ---> BARGB0									
	movff	kd,AARGB1	
	clrf	AARGB0,1
	call	FXM1616U			;Derivative gain * (error_l - prv_error1)
	
	movff	AARGB1,deriv0		;AARGB1 --> deriv0
	movff	AARGB2,deriv1		;AARGB2 --> deriv1	
	movff	AARGB3,deriv2		;AARGB3 --> deriv2			
	return						;return to ISR
		
		
;-------------------------- Final result of PID ---------------------------------
get_pid_result
	movff	prop0,AARGB0		;load Prop term & Integral term
	movff	prop1,AARGB1
	movff	prop2,AARGB2			
	movff	integ0,BARGB0
	movff	integ1,BARGB1
	movff	integ2,BARGB2
	
	bcf		PIE1,TMR1IE			;Timer 1 interrupt disabled to avoid PID result corruption
	
;	btfss	pid_stat2,integ_go,1	;is the integral ready?
;	bra		scale_down			;NO, just calculate proportional

	call	spec_sign			;YES, call routine for add/sub sign numbers
	btfss	pid_stat1,mag,1		;which is greater in magnitude ?
	bra		integ_mag			;BARGB is greater in magnitude
	bra		prop_mag			;AARGB is greater in magnitude
	
integ_mag						;integ > prop
	bcf		pid_stat1,pid_sign,1	;PID result is negative
	btfsc	pid_stat1,a_err_sign,1			
	bsf		pid_stat1,pid_sign,1	;PID result is positive
	bra 	add_derivative		;(Prop + Integ) + derivative
	
prop_mag						;integ < prop
	bcf		pid_stat1,pid_sign,1	;PID result is negative
	btfsc	pid_stat1,err_sign,1			
	bsf		pid_stat1,pid_sign,1	;PID result is positive

add_derivative
;	btfss	pid_stat2,deriv_go,1	;is the derivative ready?
;	bra		scale_down			;NO, only calculate Proportional & Integral
	movff	deriv0,BARGB0		;YES, AARGB0:AARGB2 has result of Prop + Integ	
	movff	deriv1,BARGB1		;load derivative term
	movff	deriv2,BARGB2				
	
	movff	pid_stat1,temp_reg	;pid_stat1 ---> temp_reg				
	movlw	b'11000000'			;prepare for sign check of bits 7 & 6
	andwf	temp_reg,f,1
	
	movf	temp_reg,w,1			;check error sign & a_error sign bits
	sublw	0x00
	btfsc	STATUS,Z
	bra		add_neg_d			;bits 7 & 6 (00) are NEGATIVE, add them
	bra		other_combo_d		;bits 7 & 6 not equal to 00
add_neg_d			
	call	_24_BitAdd			;add negative sign values	
	bra		scale_down			;scale result
	
other_combo_d	
	movf	temp_reg,w,1
	sublw	0xC0
	btfsc	STATUS,Z
	bra		add_pos_d			;bits 7 & 6 (11) are POSITIVE, add them
	bra		find_mag_sub_d		;bits 7 & 6 (xx) are different signs , subtract them
add_pos_d
	call	_24_BitAdd			;add positive sign values
	bra		scale_down			;scale result
find_mag_sub_d
	call	mag_and_sub			;subtract unlike sign numbers	
	btfss	pid_stat1,mag,1		;which is greater in magnitude ?
	bra		deriv_mag			;BARGB is greater in magnitude
	bra		scale_down			;derivative term < part pid term, leave pid_sign as is
	
deriv_mag						;derivative term > part pid term
	bcf		pid_stat1,pid_sign,1	;PID result is negative
	btfsc	pid_stat1,d_err_sign,1			
	bsf		pid_stat1,pid_sign,1	;PID result is positive
		
scale_down
	clrf	BARGB0,1				;(Prop + Integ + Deriv) / 16 = FINAL PID RESULT to plant
	movlw	0x10	
	movwf	BARGB1,1
	call	FXD2416U
	movff	AARGB2,pid_out2		;final result ---> pid_out2
	movff	AARGB1,pid_out1		;final result ---> pid_out1
	movff	AARGB0,pid_out0		;final result ---> pid_out0
	
#ifdef		pid_100				;Final result needs to be scaled down to  0 - 100%
	movlw	0x01				;% ratio for propotional only
	movwf	BARGB0,1
	movlw	0x90
	movwf	BARGB1,1
	
	btfss	pid_stat2,integ_go,1	;if integral is included then change % conversion 
	bra		conv_percent		;no do proportional only	
	bcf		pid_stat2,integ_go,1	;clear integral go bit for next operation
	movlw	0x03				;% ratio for propotional & integral only
	movwf	BARGB0,1
	movlw	0x20
	movwf	BARGB1,1
	
	btfss	pid_stat2,deriv_go,1	;if derivative is included then change % conversion
	bra		conv_percent		;no do proportional & integral only	
	bcf		pid_stat2,deriv_go,1	;clear derivative go bit for next operation
	movlw	0x06				;% ratio for propotional & integral & derivative 
	movwf	BARGB0,1
	movlw	0x40
	movwf	BARGB1,1
	
conv_percent	
	call	FXD2416U			;pid_out0:pid_out2 / % ratio = 0 - 100% value	
	movf	AARGB2,W,1			;AARGB2 --> percent_out			
	movwf	percent_out,1		;error has been scaled down and is now available in a 0 -100% range
#endif	

	movff	error0,p_error0				;maintain previous error for derivative term		
	movff	error1,p_error1				;maintain previous error for derivative term
	bcf		pid_stat1,p_err_sign,1		;make p_error negative
	btfsc	pid_stat1,err_sign,1			;make p_error the same sign as error	
	bsf		pid_stat1,p_err_sign,1		;make p_error positive	
		
	bsf		PIE1,TMR1IE					;re-enable Timer 1 interrupt
	return								;return to mainline code

	
;--------- Find Accumulative Error for Integral, Zero? Limits? --------------------
get_a_error				
	movff	a_error0,BARGB0			;load error & a_error 
	movff	a_error1,BARGB1
	movff	a_error2,BARGB2
	movff	error0,AARGB1
	movff	error1,AARGB2
	
	call	spec_sign				;call routine for add/sub sign numbers	
	btfss	pid_stat1,mag,1			;which is greater in magnitude ?
	bra		a_err_zero				;bargb, keep sign as is or both are same sign
	
	bcf		pid_stat1,a_err_sign,1	;aargb, make sign same as error, a_error is negative
	btfsc	pid_stat1,err_sign,1			
	bsf		pid_stat1,a_err_sign,1	;a_error is positive	
	
a_err_zero
	bcf		pid_stat1,a_err_z,1		;clear a_error zero flag	
	movlw	0
	cpfseq	AARGB0,1					;is byte 0 = 00		
	bra		chk_a_err_limit			;NO, done checking
	
	cpfseq	AARGB1					;is byte 1 = 00				
	bra		chk_a_err_limit			;NO, done checking
	
	cpfseq	AARGB2,1					;is byte 2 = 00		
	bra		chk_a_err_limit			;NO, done checking
	bsf		pid_stat1,a_err_z,1		;YES, set zero flag
	movff	AARGB0,a_error0			;store the a_error	
	movff	AARGB1,a_error1	
	movff	AARGB2,a_error2	
	return							;a_error = 00, return 
	
chk_a_err_limit
	movff	AARGB0,a_error0			;store the a_error	
	movff	AARGB1,a_error1	
	movff	AARGB2,a_error2	
	
	movlw	0						;a_error reached limits?
	cpfseq	a_error0,1				;Is a_error0 > 0 ??, if yes limit has been exceeded
	bra		restore_limit			;YES, restore limit value
	
	cpfseq	a_error1,1				;Is a_error1 = 0 ??, if yes, limit not exceeded
	bra		chk_a_error1			;NO
	return							;YES
chk_a_error1	
	movlw	a_err_1_lim			
	cpfsgt	a_error1,1				;Is a_error1 > a_err_1_lim??
	return							;NO
	bra		restore_limit			;YES, restore limit value
chk_a_error2	
	movlw	a_err_2_lim			
	cpfsgt	a_error2,1				;Is a_error2 > a_err_2_lim ??
	return							;NO, return to mainline code	
	
restore_limit
	clrf	a_error0,1					;YES, a_error limit has been exceeded
	movlw	0x0F				
	movwf	a_error1,1		
	movlw	0xA0
	movwf	a_error2,1	
	return							;return to mainline code
	
	
;-------------- Find Delta Error for Derivative, Zero? --------------------
get_delta_error
	clrf	AARGB0,1					;load error and p_error
	movff	error0,AARGB1		
	movff	error1,AARGB2
	clrf	BARGB0,1
	movff	p_error0,BARGB1
	movff	p_error1,BARGB2
	
	movf	pid_stat1,w,1				;pid_stat1 ---> temp_reg
	movwf	temp_reg,1				;prepare for sign check of bits 4 & 2
	movlw	b'00010100'
	andwf	temp_reg,f,1
		
	movf	temp_reg,w,1				;check error sign & a_error sign bits	
	sublw	0x00
	btfsc	STATUS,Z		
	bra		p_err_neg				;bits 4 & 2 (00) are NEGATIVE, 
	bra		other_combo2			;bits 4 & 2 not equal to 00
p_err_neg
	call	mag_and_sub			
	bcf		pid_stat1,d_err_sign,1	;d_error is negative
	btfsc	pid_stat1,p_err_sign,1	;make d_error sign same as p_error sign
	bsf		pid_stat1,d_err_sign,1	;d_error is positive
	bra		d_error_zero_chk		;check if d_error = 0

other_combo2	
	movf	temp_reg,w,1
	sublw	0x14
	btfsc	STATUS,Z
	bra		p_err_pos				;bits 4 & 2 (11) are POSITIVE
	bra 	p_err_add				;bits 4 & 2 (xx) are different signs
	
p_err_pos
	call	mag_and_sub
	bcf		pid_stat1,d_err_sign,1	;d_error is negative
	btfsc	pid_stat1,p_err_sign,1	;make d_error sign same as p_error sign
	bsf		pid_stat1,d_err_sign,1	;d_error is positive
	bra		d_error_zero_chk		;check if d_error = 0
p_err_add
	call	_24_BitAdd				;errors are different sign	
	bcf		pid_stat1,d_err_sign,1	;d_error is negative
	btfsc	pid_stat1,err_sign,1		;make d_error sign same as error sign
	bsf		pid_stat1,d_err_sign,1	;d_error is positive

d_error_zero_chk
	movff	AARGB1,d_error0	
	movff	AARGB2,d_error1	
	bcf		pid_stat2,d_err_z,1
	
	movlw	0
	cpfseq	d_error0,1			;is d_error0 = 00		
	return						;NO, done checking
	
	cpfseq	d_error1,1			;YES, is d_error1 = 00		
	return						;NO, done checking
	bsf		pid_stat2,d_err_z,1	;set delta error zero bit	
	return						;YES, return to ISR
		
	
;---------------------- Special Sign Routine ---------------------------------
spec_sign
	movff	pid_stat1,temp_reg	;pid_stat1 ---> temp_reg				
	movlw	b'00001100'			;prepare for sign check of bits 3 & 2
	andwf	temp_reg,f,1
	
	movf	temp_reg,w,1			;check error sign & a_error sign bits
	sublw	0x00
	btfsc	STATUS,Z
	bra		add_neg				;bits 3 & 2 (00) are NEGATIVE, add them
	bra		other_combo			;bits 3 & 2 not equal to 00
add_neg			
	call	_24_BitAdd			;add negative sign values	
	return
	
other_combo	
	movf	temp_reg,w,1
	sublw	0x0C
	btfsc	STATUS,Z
	bra		add_pos				;bits 3 & 2 (11) are POSITIVE, add them
	bra		find_mag_sub		;bits 3 & 2 (xx) are different signs , subtract them
add_pos
	call	_24_BitAdd			;add positive sign values
	return
find_mag_sub
	call	mag_and_sub			;subtract unlike sign numbers	
	return
	
	
;------------------- Find Magnitude and Subtract -------------------------	
mag_and_sub			
	movf	BARGB0,w,1
	subwf	AARGB0,w,1			;AARGB0 - BARGB0 --> W
	btfsc	STATUS,Z			;= zero ?
	bra		check_1				;YES
	btfsc	STATUS,C			;borrow ?
	bra		aargb_big			;AARGB0 > BARGB0, no borrow			
	bra		bargb_big			;BARGB0 > AARGB0, borrow
check_1	
	movf	BARGB1,w,1
	subwf	AARGB1,w,1			;AARGB1 - BARGB1 --> W
	btfsc	STATUS,Z			;= zero ?
	bra		check_2				;YES
	btfsc	STATUS,C			;borrow ?
	bra		aargb_big			;AARGB1 > BARGB1, no borrow			
	bra		bargb_big			;BARGB1 > AARGB1, borrow
			
check_2
	movf	BARGB2,w,1			;AARGB2 - BARGB2 --> W
	subwf	AARGB2,w,1
	btfsc	STATUS,C			;borrow ?
	bra		aargb_big			;AARGB2 > BARGB2, no borrow		
	bra		bargb_big			;BARGB2 > AARGB2, borrow
	
aargb_big
	call	_24_bit_sub		
	bsf		pid_stat1,mag,1		;AARGB is greater in magnitude
	return
	
bargb_big
	movf	BARGB1,W,1			;swap AARGB1 with BARGB1
	movff	AARGB1,temp_reg
	movwf	AARGB1,1
	movff	temp_reg,BARGB1	
	movf	BARGB2,W,1			;swap AARGB2 with BARGB2
	movff	AARGB2,temp_reg
	movwf	AARGB2,1
	movff	temp_reg,BARGB2
	call	_24_bit_sub			;BARGB > AARGB	
	bcf		pid_stat1,mag,1		;BARGB is greater in magnitude					
	return	

;------------------- High Interrupt Routine -------------------------	
;highInt
;	btfss	PIR1,TMR1IF					;has T1 overflowed?
;	retfie								;NO, exit ISR

PID_INT
	GLOBAL	PID_INT		

	bcf		PIR1,TMR1IF					;YES, clear T1 interrupt flag

	movlw	timer1_hi					;reload T1 registers with 1ms count
	movwf	TMR1H
	movlw	timer1_lo
	movwf	TMR1L

	bsf		pid_stat2,timer_expire,1

	call	PID_INT_CALC		
	retfie	FAST							;YES
	
PID_INT_CALC

	bcf		pid_stat2,timer_expire,1
	
	btfsc	pid_stat1,err_z,1				;Is error = 00 ?
	return


	
	movwf	T_WREG,1
	movff	STATUS,T_STATUS
	movff	BSR,T_BSR					;if needed
	
	movff	AARGB0,T_AARGB0			;NO, context save Math varialbes
	movff	AARGB1,T_AARGB1
	movff	AARGB2,T_AARGB2
	movff	AARGB3,T_AARGB3
	movff	BARGB0,T_BARGB0
	movff	BARGB1,T_BARGB1
	movff	BARGB2,T_BARGB2
	movff	BARGB3,T_BARGB3
	movff	REMB0,T_REMBO
	movff	REMB1,T_REMB1
	movff	TEMP,T_TEMP
	movff	TEMPB0,T_TEMPB0
	movff	TEMPB1,T_TEMPB1
	movff	TEMPB2,T_TEMPB2
	movff	TEMPB3,T_TEMPB3
	movff	ZARGB0,T_ZARGB0
	movff	ZARGB1,T_ZARGB1
	movff	ZARGB2,T_ZARGB2
	movff	CARGB2,T_CARGB2
	movff	LOOPCOUNT,T_LOOPCOUNT
	movff	temp_reg,t_temp_reg
	
	btfsc	pid_stat1,a_err_z,1			;Is a_error = 0
	bra		derivative_ready?			;YES, check if derivative is ready
	bsf		pid_stat2,integ_go,1			;NO, set intergral go bit for PID calculation
	call	start_integral				;find integral
	
derivative_ready?
	decfsz	deriv_count,f,1 				;is it time for derivative term ?
	bra		skip_deriv					;NO, finish ISR
	call	start_deriv					;YES, find derivative

			;---Get ready for Next Derivative Term	
	movlw	deriv_cnt
	movwf	deriv_count,1					;derivative action = TMR1H:TMR1L * deriv_count

skip_deriv	
;	movlw	timer1_hi					;reload T1 registers with 1ms count
;	movwf	TMR1H
;	movlw	timer1_lo
;	movwf	TMR1L
	
	movf	T_WREG,w,1
	movff	T_STATUS,STATUS
	movff	T_BSR,BSR					;if needed
	
	movff	T_AARGB0,AARGB0				;restore Math variables
	movff	T_AARGB1,AARGB1
	movff	T_AARGB2,AARGB2
	movff	T_AARGB3,AARGB3
	movff	T_BARGB0,BARGB0
	movff	T_BARGB1,BARGB1
	movff	T_BARGB2,BARGB2
	movff	T_BARGB3,BARGB3
	movff	T_REMBO,REMB0
	movff	T_REMB1,REMB1
	movff	T_TEMP,TEMP
	movff	T_TEMPB0,TEMPB0
	movff	T_TEMPB1,TEMPB1
	movff	T_TEMPB2,TEMPB2
	movff	T_TEMPB3,TEMPB3
	movff	T_ZARGB0,ZARGB0
	movff	T_ZARGB1,ZARGB1
	movff	T_ZARGB2,ZARGB2
	movff	T_CARGB2,CARGB2
	movff	T_LOOPCOUNT,LOOPCOUNT
	movff	t_temp_reg,temp_reg
	
;	RETFIE			        			;return from interrupt	
	return
	
	END               					;directive 'end of program'
	
	
