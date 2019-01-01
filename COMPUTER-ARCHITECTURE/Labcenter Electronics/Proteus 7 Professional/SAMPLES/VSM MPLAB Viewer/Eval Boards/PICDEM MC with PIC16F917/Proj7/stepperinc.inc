#include <p16f917.inc>

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Definitions/Masks
#define	SW2 	PORTA,4
#define	POT		PORTA,0
#define	PWM1	PORTC,5
#define	PWM2	PORTD,2
#define	CTRL1FWD	0x80	; mask for RD7
#define	CTRL1REV	0x40	; mask for RD6
#define	CTRL2FWD	0x20	; mask for RD5
#define	CTRL2REV	0x10	; mask for RD4

; Variable Declarations
	cblock	0x25
		State
		Index
		SpeedSave
		Speed
		StepModeScaler
		Counter
		DutyCycle
		ButtonState
		Mode
	endc






