//---------------------------------------------------------------------
//
//							 Software License Agreement
//
// The software supplied herewith by Microchip Technology Incorporated 
// (the “Company”) for its PICmicro® Microcontroller is intended and 
// supplied to you, the Company’s customer, for use solely and 
// exclusively on Microchip PICmicro Microcontroller products. The 
// software is owned by the Company and/or its supplier, and is 
// protected under applicable copyright laws. All rights are reserved. 
//  Any use in violation of the foregoing restrictions may subject the 
// user to criminal sanctions under applicable laws, as well as to 
// civil liability for the breach of the terms and conditions of this 
// license.
//
// THIS SOFTWARE IS PROVIDED IN AN “AS IS” CONDITION. NO WARRANTIES, 
// WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
// TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
// PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, 
// IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR 
// CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
//
//---------------------------------------------------------------------
//	File:		SensoredBLDC.c
//
//	Written By:		Bill Anderson, Microchip Technology
//						
// 
// The following files should be included in the MPLAB project:
//
//		SensoredBLDC.c		-- Main source code file
//		Interrupts.c
//		Init.c
//		SensoredBLDC.h		-- Header file
//		p33FJ256MC710.gld	-- Linker script file
//				
//
//--------------------------------------------------------------------
//
// Revision History
//
// 06/30/07 -- first version 
//---------------------------------------------------------------------- 

#include "p33FJ12MC202.h"
#include "SensoredBLDC.h"
_FGS(GWRP_OFF & GCP_OFF);
_FOSCSEL(FNOSC_PRIPLL);
_FOSC(FCKSM_CSDCMD & OSCIOFNC_OFF & POSCMD_XT);
_FWDT(FWDTEN_OFF);

void InitADC10(void);
void DelayNmSec(unsigned int N);
void InitMCPWM(void);
void InitUART(void);
void InitTMR3(void);
void InitIC(void);
void CalculateDC(void);
void ResetPowerModule(void);
void InitTMR1(void);
void UART_CRLF(void);

struct MotorFlags Flags;

unsigned int HallValue;
unsigned int timer3value;
unsigned int timer3avg;
unsigned char polecount;
 
char *UartRPM,UartRPMarray[5];
int RPM, rpmBalance;

/*************************************************************
	Low side driver table is as below.  In the StateLoTableClk
	and the StateLoTableAntiClk tables, the Low side driver is
	PWM while the high side driver is either on or off.  
*************************************************************/

unsigned int StateTableFwd[] = {0x0000, 0x0210, 0x2004, 0x0204,
									0x0801, 0x0810, 0x2001, 0x0000};
unsigned int StateTableRev[] = {0x0000, 0x2001, 0x0810, 0x0801,
									0x0204, 0x2004, 0x0210, 0x0000};



int main(void)
{
	CLKDIV = 0x30C0;
	PLLFBD = 0x0026;

	TRISB |= 0x000C;					// S3/S6 as input RB2/RB3
	// Analog pin for POT already initialized in ADC init subroutine

	_LOCK = 0;
	RPINR10bits.IC7R = 0x7; 
	RPINR7bits.IC1R = 0x5;
	RPINR7bits.IC2R = 0x6;
	_LOCK = 1;

 
	//PORTF = 0x0008;						// RS232 Initial values
	//TRISF = 0xFFF7;						// TX as output
	InitADC10();
	InitTMR1();
	InitTMR3();
	timer3avg = 0;
	InitMCPWM();
	InitIC();
	Flags.Direction = 1;				// initialize direction CW

	//TRISE &= 0xfdff;
	//TRISD &= 0xf7ff;
	//PORTDbits.RD11 = 0;					// Hold PWM OE low
	
	/* set LEDs (D3-D10/RA0-RA7) drive state low */
	//LATA = 0xFF00; 
	/* set LED pins (D3-D10/RA0-RA7) as outputs */
	//TRISA &= 0xFFF8; 
	//TRISAbits.TRISA3=0;
	//InitUART();

	unsigned int i;
	for(i=0;i<1000;i++);
	

	

	ResetPowerModule();

	while(1)
	{	
		while(S3)					// wait for start key hit
		{
			if (!S6)				// check for direction change
			{
				while (!S6)			// wait till key is released
					DelayNmSec(10);
				Flags.Direction ^= 1;
			}
			Nop();
		}
		while (!S3)					// wait till key is released
			DelayNmSec(10);
			
			// read hall position sensors on PORTD
		HallValue = (unsigned int)((PORTB >> 8) & 0x0007);
		if (Flags.Direction)
			OVDCON = StateTableFwd[HallValue];
		else
			OVDCON = StateTableRev[HallValue];
			
		PWMCON1 = 0x0777;			// enable PWM outputs
		Flags.RunMotor = 1;			// set flag
		T3CONbits.TON = 1;			// start tmr3
		polecount = 1;
		DelayNmSec(100);
		ResetPowerModule();

		while (Flags.RunMotor)				// while motor is running
		{
			if (!S3)						// if S2 is pressed
				{
				PWMCON1 = 0x0700;			// disable PWM outputs
  				OVDCON = 0x0000;			// overide PWM low.
				Flags.RunMotor = 0;			// reset run flag
				while (!S3)					// wait for key release
					DelayNmSec(10);
				}
			Nop();
		}
	}
}
//---------------------------------------------------------------------
// This is a generic 1ms delay routine to give a 1mS to 65.5 Seconds delay
// For N = 1 the delay is 1 mS, for N = 65535 the delay is 65,535 mS. 
// Note that FCY is used in the computation.  Please make the necessary
// Changes(PLLx4 or PLLx8 etc) to compute the right FCY as in the define
// statement above.

void DelayNmSec(unsigned int N)
{
unsigned int j;
while(N--)
 	for(j=0;j < MILLISEC;j++);
}



void ResetPowerModule(void)
{
	int i;
	
	TRISBbits.TRISB9 = 0;	
	LATBbits.LATB9 = 1;
	LATBbits.LATB9 = 1;
	for(i=0;i<10;i++);
	LATBbits.LATB9 = 0;
}

/*****************************************************************************
CalculateDC, uses the PI algorithm to calculate the new DutyCycle value which
will get loaded into the PDCx registers.

****************************************************************************/

/*
void UART_CRLF(void)
{
	while (U2STAbits.UTXBF);
		U2TXREG = 0x0d;
	while (U2STAbits.UTXBF);
		U2TXREG = 0x0a;
}
		
*/




