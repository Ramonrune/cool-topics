/*****************************************************************************
*   Filename:   SPEECH.C                                                     *
******************************************************************************
*   Author:     Rodger Richey                                                *
*   Title:      Senior Applications Manager                                  *
*   Company:    Microchip Technology Incorporated                            *
*   Revision:   1                                                            *
*   Date:       12-1-04                                                      *
******************************************************************************
*   Include files:                                                           *
*      stdio.h - Standard input/output header file                           *
*      string.h - Standard string header file                                *
*      adpcm.h - ADPCM related information header file                       *
******************************************************************************
*   This file contains the code to:                                          *
*      - Open the input and output files                                     *
*      - Read data from the input file                                       *
*      - Call the appropriate encode/decode routines                         *
*      - Write data to the output file                                       *
******************************************************************************
*   Revision 0  1/11/96                                                      *
*      Original release supporting only ADPCM using signed raw data          *
*      Compiled with Borland C++ Version 3.1                                 *
*   Revision 1  11/10/04                                                     *
*      Add CVSD, change ADPCM to support unsigned raw data                   *
*      Compiled using Borland C++ 6.0                                        *
*****************************************************************************/
#include <p24fj128ga010.h>

#include "adpcm.h"
#include "mpfs.h"
#include "stacktsk.h"
#include <string.h>

_CONFIG1(0x03E2);
_CONFIG2(0x3D1F);

int main (void);
void PlayClip(MPFS hfile);						// Play specified audio clip
void Transistion(void);							// Transition between clips

struct  ADPCMstate   state;         			// ADPCM state variable
unsigned char bin,hundreds,tens_ones;

/*****************************************************************************
*   main - controls file I/O and ADPCM calls                                 *
*****************************************************************************/
int main(void)
{
	char filename[13];							// filename to play
	MPFS hFile;									// file pointer
	char string[13];
	unsigned char Temperature;
	long time;

	CORCONbits.PSV = 1;							// enable PSV usage

	// Setup ports
	PORTA = 0;
	TRISA = 0x0080;
	PORTB = 0;
	TRISB = 0x0030;
	PORTC = 0;
	TRISC = 0xc000;
	PORTD = 0x1080;
	TRISD = 0x2040;
	PORTE = 0;
	TRISE = 0;
	PORTF = 0;
	TRISF = 0x1010;
	PORTG = 0;
	TRISG = 0x0080;

	AD1CON1 = 0x80E4;				//Turn on, auto sample start, auto-convert
	AD1CON2 = 0;					//AVdd, AVss, int every conversion, MUXA only
	AD1CON3 = 0x1F05;				//31 Tad auto-sample, Tad = 5*Tcy
   AD1CHS = 4;
	AD1PCFGbits.PCFG5 = 0;			//Disable digital input on AN5
	AD1PCFGbits.PCFG4 = 0;          //Disable digital input on AN4
	AD1CSSL = 0;					//No scanned inputs

	// Setup PWM for 16KHz at 6.144MHz * 4 (using PLL)
	OC1CON          = 0x0000; // Turn off Output Compare 1 Module
	OC1RS           = 0; 	  // Initialize Secondary Compare Register1 
							  // with first PWM value
	OC1CON          = 0x0006; // Load PWM mode to OC1CON

	T2CONbits.TON   = 0;      // Turn off timer 3
	T2CONbits.TCS   = 0;      // Select the timer clock source. Fosc/4 in this case
	T2CONbits.T32   = 0;      // Configure timer 2 for 16 bit mode
	T2CONbits.TCKPS = 0;      // Select the prescaler ratio using TCKPS1:TCKPS0 bits
	T2CONbits.TGATE = 0;      // Gated time accumulation mode disabled
	PR2             = 768;    // Initialize PR2 with the calculated decimal value
	TMR2            = 0;      // Clear timer 2 or preload with required value if needed
	IFS0bits.T2IF   = 0;      // Clear Output Compare 1 interrupt flag
	T2CONbits.TON   = 1;      // Start Timer2 with assumed settings
	
	MPFSInit();								// Initialize "FAT" for audio clips

   while(1)
   {
	   PORTAbits.RA3 = 1;					// Put audio driver in low power mode
		OC1RS = 512;							// Reset PWM duty cycle to 1/2 supply

		while(PORTDbits.RD13);				// Wait for pushbutton to be pressed

		while(!PORTDbits.RD13);				// Wait for pushbutton to be released

		PORTAbits.RA3 = 0;					// Enable audio amplifier

		if(PORTDbits.RD13)					// If pushbutton has been released
		{
			while(!AD1CON1bits.DONE);		// Perform A/D conversion on TC1047A
			   Temperature = ((ADC1BUF0*10)/31)-50;	// Calculate temperature

			// Convert temperature value into the speech files to play
			if(Temperature/100)				// If hundreds non-zero
			{
				filename[0] = '1';			// filename = "100.dat"
				filename[1] = '0';
				filename[2] = '0';
				filename[3] = '.';
				filename[4] = 'd';
				filename[5] = 'a';
				filename[6] = 't';
				filename[7] = 0;
				hFile = MPFSOpen(filename);	// Open file
				PlayClip(hFile);			// Play audio clip
				Temperature -= 100;			// Decrement by 100 leaves only tens/ones digits
				for(time=0;time<65534;time++);	// Delay
			}

			if(Temperature>19)				// If remaining two digits are > 19
			{
				filename[0] = (Temperature/10)+0x30;		// filename = "x0.dat" where x is the tens digit
				filename[1] = '0';
				filename[2] = '.';
				filename[3] = 'd';
				filename[4] = 'a';
				filename[5] = 't';
				filename[6] = 0;
				hFile = MPFSOpen(filename);	// Open file
				PlayClip(hFile);			// Play audio clip
				Temperature -= (Temperature/10)*10;		// subtract tens digit
				for(time=0;time<65534;time++);	//Delay

				filename[0] = Temperature+0x30;	// filename = "x.dat" where x is the ones digit
				filename[1] = '.';
				filename[2] = 'd';
				filename[3] = 'a';
				filename[4] = 't';
				filename[5] = 0;
				hFile = MPFSOpen(filename);				// Open file
				PlayClip(hFile);						// Play audio clip
			}
			else if(Temperature>9)			// remaining two digits < 20
			{
				filename[0] = '1';			// filename = "xy.dat" where x is the tens digit
				filename[1] = (Temperature-10)+0x30;	//  and y is the ones digit
				filename[2] = '.';
				filename[3] = 'd';
				filename[4] = 'a';
				filename[5] = 't';
				filename[6] = 0;
				hFile = MPFSOpen(filename);	// Open file
				PlayClip(hFile);			// Play audio clip
				for(time=0;time<65534;time++);	// delay
			}
			else							// single digit temperature
			{
				filename[0] = Temperature+0x30;	// filename = "x.dat" where x is the ones digit
				filename[1] = '.';
				filename[2] = 'd';
				filename[3] = 'a';
				filename[4] = 't';
				filename[5] = 0;
				hFile = MPFSOpen(filename);	// Open file
				PlayClip(hFile);			// Play audio clip
				for(time=0;time<65534;time++);
			}

			filename[0] = 'd';				// filename = "deg.dat"
			filename[1] = 'e';
			filename[2] = 'g';
			filename[3] = '.';
			filename[4] = 'd';
			filename[5] = 'a';
			filename[6] = 't';
			filename[7] = 0;
			hFile = MPFSOpen(filename);		// Open file
			PlayClip(hFile);				// Play audio clip
			for(time=0;time<65534;time++);	// delay

			filename[0] = 'c';				// load filename with "cel.dat"
			filename[1] = 'e';
			filename[2] = 'l';
			filename[3] = '.';
			filename[4] = 'd';
			filename[5] = 'a';
			filename[6] = 't';
			filename[7] = 0;
			hFile = MPFSOpen(filename);		// Open file
			PlayClip(hFile);				// Play audio clip
			for(time=0;time<65534;time++);	// delay
		}
	}
}

//----------------------------------------------------------------------------


void PlayClip(MPFS hfile)
{
	unsigned char code;
	unsigned short sample,ocrtemp;
	
	state.prevsample=32768;                 		// configure initial state for ADPCM
	state.previndex=0;                  			//  same

	if(hfile != MPFS_INVALID)						// if file is valid
	{
		if(MPFSGetBegin(hfile))						// data in file
		{
			while(!MPFSIsEOF())						// Is character end of file
			{
				code = MPFSGet();					// read code from memory
			    IFS0bits.T2IF  = 0;					// clear timer overflow flag
				// Send the upper 4-bits of code to decoder
				sample = ADPCMDecoder((code>>4)&0x0f, &state);
				ocrtemp = sample>>6;				// write duty cycle
				OC1RS = ocrtemp;
				while(!IFS0bits.T2IF);			// Wait for Timer2 interrupt flag
				IFS0bits.T2IF = 0;				// do this twice, 2 interrupts = 8KHz
				while(!IFS0bits.T2IF);

				IFS0bits.T2IF = 0;				// clear Timer2 interrupt flag
				// Send the lower 4-bits of code to decoder	
				sample = ADPCMDecoder(code&0x0f,&state);
				ocrtemp = sample>>6;
				OC1RS = ocrtemp;
				while(!IFS0bits.T2IF);			//Wait for Timer2 interrupt flag (8KHz)
				IFS0bits.T2IF = 0;
				while(!IFS0bits.T2IF);
			}
			hfile = MPFSGetEnd();					// End access to file
		}
	}
	MPFSClose();									// Close file
	return;
}


