#include <p16f917.inc>
#include LCD.inc

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Declarations
#define	SW2		PORTA,3
#define SW3		PORTA,4
#define SW4		PORTA,5
#define	OSCI	PORTA,7
#define	OSCO	PORTA,6

; Flag Definitions
#define DisplayMode 0
#define	ServiceSW2 1
#define	ServiceSW3 2
#define	ServiceSW4 3
#define AMorPM 4
#define	Blink 5

; Variable Declarations
bank0	udata
Hour		res 1
Minute		res	1
Second		res 1
HourBCD		res 1
MinuteBCD	res	1
SecondBCD	res 1
Temp		res 1
BCDValue	res 1
Flag		res 1
TimeBaseMultiple	res 1
StateSW2	res 1
StateSW3	res 1
StateSW4	res 1
Counter		res 1






