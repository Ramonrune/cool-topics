#include <p16f917.inc>
#include LCD.inc
	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message



; Pin Declarations
#define	TempSensor	PORTA,0

; Flag Declarations
#define Overflow 0
#define InvalidTemp 1
#define Negative 2

; Variable Declarations
bank0	udata
Counter		res	1
Temp		res 1
TempLow 	res 1
TempHigh 	res 1
Flag		res 1
TempSave	res 1
TempBCD		res 1
BCDValue	res 1
MathHigh	res 1
MathLow		res 1







