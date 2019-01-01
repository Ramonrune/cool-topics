#include <p16f690.inc>

	__CONFIG    _CP_OFF & _CPD_OFF  & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Definitions/Masks
#define	SW2 	PORTA,5
#define	POT		PORTA,2
#define	P1A		PORTC,5
#define	P1B		PORTC,4
#define	P1C		PORTC,3
#define	P1D		PORTC,2

; Variable Declarations
	cblock	0x25
		DutyCycle
		Mode
		ButtonState
	endc






