#include <p16f917.inc>
#include lcd.inc

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Declarations
#define	POT1	PORTA,0
#define	Optical	PORTC,5
#define	N2		PORTD,2
#define	P1		PORTD,7

; Variable Declarations
bank0	udata
DutyCycle	res 1
Counter		res 1
TimeL		res 1
TimeH		res 1

; These variables are required for the BinaryToBCD routine (take from AN526)
count 		res 1
temp		res 1
H_byte  	res	1
L_byte  	res 1
R0          res 1
R1      	res 1
R2      	res 1







