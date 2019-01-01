;This file is used for defining the variables and compile time options
;This file should be included in all .asm/.c files
;Author : Padmaraja Yedamale
;Version: V1.1

	include		"P18F4431.inc"
	

;User defined variables
;---------------------------------------------------------------------------------------
;Oscillator frequency
#define OSCILLATOR	d'5000000'
;---------------------------------------------------------------------------------------
;Enter the PPR of the Optical Encoder on the motor
#define ENCODER_PPR d'1024'
;---------------------------------------------------------------------------------------
;Claculating RPM based on the encoder type. The QEI should be in velocity measurement mode
;Timer5 prescaler
#define	TIMER5_PRESCALE	d'1'
;---------------------------------------------------------------------------------------
;Define the QEI mode of operation. 
;If the velocity conter is updated only on QEA transition, then enable 2x mode
;If the velocity conter is updated every QEA and QEB transition, then enable 4x mode
#define QEI_X_UPDATE d'2'
;#define QEI_X_UPDATE d'4'
;---------------------------------------------------------------------------------------
;Define Velocity pulse decimation ratio(Only one line should be selected)
#define VELOCITY_PULSE_DECIMATION d'1' 
;#define VELOCITY_PULSE_DECIMATION d'4' 
;#define VELOCITY_PULSE_DECIMATION d'16' 
;#define VELOCITY_PULSE_DECIMATION d'64' 
;---------------------------------------------------------------------------------------
;Calculate the constant to be divided by the Velocity counter value will give RPS
INSTRUCTION_CYCLE = (OSCILLATOR)/d'4'
RPM_CONSTANT_QEI = 8*((INSTRUCTION_CYCLE)/(ENCODER_PPR*QEI_X_UPDATE*VELOCITY_PULSE_DECIMATION*TIMER5_PRESCALE))
;The value is multiplied by 8 to increase the accuracy of division. After devision, the result is devided by 8
RPM_CONSTANT_HALL = INSTRUCTION_CYCLE/(d'12'*d'8')
;60 to convert RPM to RPS, 12= # of Hall pulses/revolution
;---------------------------------------------------------------------------------------
;PWM frequency definition
#define PWM_TIMER_PRESCALE	d'01'
#define	PWM_FREQUENCY	d'1000'
PTPER_VALUE = (OSCILLATOR/(4*PWM_FREQUENCY*PWM_TIMER_PRESCALE))-1
;---------------------------------------------------------------------------------------
;Defining the PWM duty cycle constant based on the Motor voltage, DC bus voltage and PWM period register value
#define MOTOR_VOLTAGE d'130'
#define AC_INPUT_VOLTAGE	d'115'
#define MOTOR_RATED_SPEED d'2300'

MAIN_PWM_CONSTANT =(MOTOR_VOLTAGE*PTPER_VALUE*4*d'16')/(AC_INPUT_VOLTAGE*d'360')
;1.414*256 = 360
;Multiplication factor = 16
ERROR_PWM_CONSTANT = (MAIN_PWM_CONSTANT * d'256')/MOTOR_RATED_SPEED
MAX_PWM_VALUE = (MOTOR_VOLTAGE*PTPER_VALUE*4*d'100')/(AC_INPUT_VOLTAGE* d'141')
;---------------------------------------------------------------------------------------
ESTIMATE_TIMER_CONSTANT = ((d'60'* INSTRUCTION_CYCLE)/(MOTOR_RATED_SPEED*d'12'))+1

;-------------------------------
;Commutation table. loaded to OVDCOND
;-------------------------------
; The Hall sensor makes a transition every 60 degrees
; For other type of motors with different Hall sensor combination, the table has to be modified.
#define	POSITION1	b'00010010'
#define	POSITION2	b'00000110'
#define	POSITION3	b'00100100'
#define	POSITION4	b'00100001'
#define	POSITION5	b'00001001'
#define	POSITION6	b'00011000'
#define	DUMMY_POSITION	b'00000000'
;---------------------------------------------------------------------------------------

err_sign	equ	2			;error sign flag, Pos = set/ Neg = clear
pid_sign	equ	7			;PID result sign flag, Pos = set/ Neg = clear










