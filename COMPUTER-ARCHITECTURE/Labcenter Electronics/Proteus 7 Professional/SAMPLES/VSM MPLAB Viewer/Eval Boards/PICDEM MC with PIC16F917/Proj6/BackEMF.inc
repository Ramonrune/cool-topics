#include <p16f917.inc>
#include lcd.inc

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Declarations
#define	POT		PORTA,0
#define	BEMF	PORTA,5
#define	N2		PORTD,2
#define	P1		PORTD,7


; Variable Declarations
bank0	udata
DutyCycle		res 1
BackEMFValue	res .64
Math_High		res 1
Math_Low		res	1
RPM_High		res	1
RPM_Low			res 1
Counter			res 1
Pointer			res 1
TimeKeeper		res 1

; These variables are required for the BinaryToBCD routine (take from AN526)
count 		res 1
temp		res 1
H_byte  	res	1
L_byte  	res 1
R0          res 1
R1      	res 1
R2      	res 1






