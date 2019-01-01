#include <p16f917.inc>

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Declarations
#define	POT		PORTA,0
#define SENSE	PORTA,3
#define LED		PORTD,7

; Variable Declarations
	cblock	0x20
		OnCntr	; Counter for giving some hysteresis to the comparator
		OffCntr ; Counter for giving some hysteresis to the comparator
	endc






