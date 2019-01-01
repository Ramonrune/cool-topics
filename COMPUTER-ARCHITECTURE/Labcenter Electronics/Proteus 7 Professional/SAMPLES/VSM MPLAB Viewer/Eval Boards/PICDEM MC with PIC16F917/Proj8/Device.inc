;	Device.inc
;
;  Generic device and configuration word information.
;  To use a different device, change this file instead 
;  of lines in the target main application.
;

	include	"p16F917.inc"

#ifdef MAIN_H
; assemble configuration word only once in the main application routine

	__CONFIG _FCMEN_OFF & _IESO_OFF & _BOD_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT

#endif	
