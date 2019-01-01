//******************************************************************************
// Software License Agreement
//
// The software supplied herewith by Microchip Technology
// Incorporated (the "Company") is intended and supplied to you, the
// Company’s customer, for use solely and exclusively on Microchip
// products. The software is owned by the Company and/or its supplier,
// and is protected under applicable copyright laws. All rights are
// reserved. Any use in violation of the foregoing restrictions may
// subject the user to criminal sanctions under applicable laws, as
// well as to civil liability for the breach of the terms and
// conditions of this license.
//
// THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
// TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
// IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
// CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
//
//******************************************************************************


#include	"main.h"
#include	"ssp.h"


__CONFIG(INTIO & WDTDIS & PWRTEN & MCLRDIS & UNPROTECT & BORDIS);


/** Defines **/
/** Define Pinouts **/
/*
 See header file 
*/


/** Variables **/

// I2C Communications
unsigned char	ByteCount;	
unsigned char	EEIndex;  
unsigned char	TempIndex; 
unsigned int	TempInt;  

FFlags Flags;
BButtons Buttons;

unsigned int	RAW	   [NUM_BTTNS];
unsigned int	AVERAGE[NUM_BTTNS];		// Can't fit all in one bank. Only 96 bytes per Banks 2|3, (Max 24 bttns)


unsigned char	AvgIndex;
long 			percent;

unsigned char	FIRST;					// first variable to 'discard' first N samples
unsigned char	INDEX;					// Index of what button is being checked.

unsigned int	VALUE;					// current button value
unsigned int	BIGVAL;							
unsigned int	SMALLAVG;
unsigned int	j;						// Global incrementer variable.. use with caution to interrupts.


/** Constants **/

// 0x94/0xA0 = Cin0-    ,   0x95/0xA1 = Cin1-   (Sets comparator operation and proper channel.)
const unsigned char	COMP1[4] = {0x94, 0x95, 0x96, 0x97};				// comparator preset values for each button
const unsigned char	COMP2[4] = {0xA0, 0xA1, 0xA2, 0xA3};




/*====================================================================
========================  PROGRAM CODE  ==============================
====================================================================*/

/*....................................................................
. 	main()
.
.		Entry point of program.
....................................................................*/
void main(void) {
	unsigned int tep;

	INIT();											// Launch Device Initializations

	LED_LOGO = OFF;									//  Turn all LEDs off
	LED_MIC  = OFF;
	LED_RO   = OFF;
	LED_CHIP = OFF;


	while (1) {										// Loop forever, illum LED if button is down.

		// Illuminate Keypad LEDs
		LED_LOGO = (Buttons.LOGO == 1) ? ON : OFF;	// (if : else)
		LED_MIC  = (Buttons.MIC  == 1) ? ON : OFF;
		LED_RO   = (Buttons.RO   == 1) ? ON : OFF;
		LED_CHIP = (Buttons.CHIP == 1) ? ON : OFF;

	}
}







/*....................................................................
. INIT()
.
.		Initialization Routine to set up part's variables and
.	peripherals.
....................................................................*/
void INIT(void) {


	// Pin I/O Direction

	// Capacitive
	TRISC2OUT  = 0;				// C2OUT = output
	TRISC12IN0 = 1;				// Comparator Cin- input
	TRISC12IN1 = 1;				// Comparator Cin- input
	TRISC12IN2 = 1;				// Comparator Cin- input
	TRISC12IN3 = 1;				// Comparator Cin- input
	
	// LEDs
	TRISLED_LOGO = 0;			// Set LEDs as outputs
	TRISLED_MIC  = 0;
	TRISLED_RO   = 0;
	TRISLED_CHIP = 0;
	
	
	CapInit();					// Initialize Capacitive Sensing
	SSPInit();					// Initialize I2C Communications



	GIE = 1;					// turn on the global interrupts once done w/inits

}






/*....................................................................
.	isr()
.
.		Interrupt Service Routine - is the function called when any
.	interrupt is received on the 16F part.  The device context saves, 
.	and then redirects flow here. Program flow will be returned at
.	the end of this function.  The flagging interrupt MUST be
.	cleared in software! (or you will be stuck forever).
....................................................................*/
void interrupt isr(void)
{																		
	
	// Timer 0 Interrupt
	if (T0IF == 1 && T0IE == 1) {									// Timer 0 Overflow Occurred, 
		// Service Capacitive Routine
		// .. pending not interfering with I2C
		TMR1ON	= 0;												// stop Timer1
	
		if (Flags.SSPBF == 1)										// SSP is busy, and can not interrupt it.
			RestartTimers();										// Clear timers
		else 														// SSP is not busy, do cap. stuff
			CapISR();												// Service Routine {resets/restarts tmrs}			
	}


	// SSP Interrupt
	if (SSPIF == 1 && SSPIE == 1)									// SSP Interrupt Detected
		SSPISR();


	// Timer Interrupt During Non-TMR0 Intpt?
	if (T0IF == 1)													// Catch if timer interrupt during other interrupt?  Handled at end of ISR.
		RestartTimers();											// (Clears T0IF)
}





/*....................................................................
. RestartTimers()
.
.		Resets and restarts timers 0 & 1 used for capacitive sensing.
....................................................................*/
void RestartTimers(void) {

	TMR1L	= 0;								// reset Timer1
	TMR1H	= 0;								//   "     "
	TMR1ON	= 1;								// restart Timer1
	TMR0	= 0;								// reset Timer0
	T0IF	= 0;								// clear the interrupt
}





/*....................................................................
.	CapInit()
.
.		Performs Initializations for capacitive sensing.
....................................................................*/
void CapInit(void) {


	// Load defaults for buttons
	for (INDEX=0; INDEX < NUM_BTTNS; INDEX++) {			// Load Default GB/TRP
		RAW[INDEX]		= 0;
		AVERAGE[INDEX] 	= 0;
	}


	FIRST	= 60;					// first pass flag to reach steady state average before enabling detection

	// All TRIS Registers set up in INIT() Routine
	// Capacitively this requires to set up C2OUT as o/p, and T1CKI=i/p, C12INx- pins used = analog i/p., C2+ pin = analog i/p
		
	OSCCON	= 0x7F;					// (Optional) Set for 8MHz internal clock.

	INDEX	= 0;					// Init to start on button 0. { INDEX =button state machine state variable }
	CM1CON0 = COMP1[INDEX];			// preset the comparators for first channel (and set appropriate enable bits)
	CM2CON0 = COMP2[INDEX];
	CM2CON1 = 0x32;

	ANSEL   = 0x07;					// configure the button inputs for analog, along with the 1/4VDD reference input
	ANSELH  = 0x06;					// Set all other i/o as digital

	VRCON   = 0x87;					// setup the CVref for 2/3VDD
	SRCON   = 0xF0;					// turn on the SR flip flop mode

	T1CON	= 0x06;					// enable timer1
	OPTION	= 0x84;					// setup the timer0 prescaler

	RestartTimers();				// Turn on and start timers

	INTCON	= 0;					// clear the interrupt register
	T0IE	= 1;					// turn on the timer0 interrupt

}





/*....................................................................
.	CapISR(void)
.
.		Capacitive service routine for ISR.  This function should be
.	called on each overflow of Timer0 which indicates a measurement
.	is ready to be taken.
.
.		It takes the measurement, determines if the button under test
.	is pressed or not (setting a flag accordingly), and it then will
.	average the new reading appropriately and then set the comparators
.	to scan the next button in sequence.
....................................................................*/
void CapISR(void) {


	// 1. Get the raw sensor reading.

	// ...
	VALUE = TMR1L + (unsigned int)(TMR1H << 8);								// Get the frequency count for the current sensor
	RAW[INDEX] = VALUE;														// Raw array holds raw readings for ea. pass
	

	// 2. On power-up, reach steady-state readings

	// ...
	// During power-up, system must be initialized, set average ea. pass
	if (FIRST > 0) {
		FIRST--;															// Decr. N # times to establish startup
		AVERAGE[INDEX] = VALUE;												// During start up time, set Average each pass.
		SetNextChannel();
		RestartTimers();													// Restart the timers
		return;																// .. and exit
	}

	// 3. Compute Percent Shift
	
	// ...
	percent = ((long)AVERAGE[INDEX] - (long)VALUE);							// Need to cast AVG & RAW or result is not negative.
	if (percent < 0){														// If negative set to 0 (Means RAW > AVG, either release or steady state avg error)
		percent = 0;														// It is easiest to deal with negatives here rather than later if statements. 
	} else {
		percent = percent * 1000;											//              (AVG - RAW)  *1000
		percent = percent / AVERAGE[INDEX];									// now div by:        AVG	     	= percent (whole percent and 1 decimal)
	}


	// 4. Is a button pressed?

	// ...
	if (percent > PCT_ON) {
		switch (INDEX) {
			case iLOGO:		Buttons.LOGO = 1; break;		// Button under Logo - pressed
			case iMIC:		Buttons.MIC  = 1; break;		// Buttons under word Microchip
			case iRO:		Buttons.RO   = 1; break;		//  ..
			case iCHIP:		Buttons.CHIP = 1; break;		//  ..
			default:	break;								// Default unexpected case
		}
	} else if (percent < PCT_OFF) {
		switch (INDEX) {
			case iLOGO:		Buttons.LOGO = 0; break;		// Button under Logo - unpressed
			case iMIC:		Buttons.MIC  = 0; break;		// Buttons under word Microchip
			case iRO:		Buttons.RO   = 0; break;		//  ..
			case iCHIP:		Buttons.CHIP = 0; break;		//  ..
			default:	break;								// Default unexpected case
		}
	}


	// 5. Implement quick-release for a released button

	// ...
	if (VALUE > AVERAGE[INDEX])
		AVERAGE[INDEX] = VALUE;		// Don't average, just reset to higher value (ok unless fluke high value, then returns low immediately.)


	// 6. Average in the new value

	// ...
	if (percent < PCT_AVG) { 
		if (AvgIndex < AVG_DELAY)			AvgIndex++;
		else								AvgIndex = 0;
		
		if (AvgIndex == AVG_DELAY)
			AVERAGE[INDEX] = AVERAGE[INDEX] + ((long)(VALUE) - (long)(AVERAGE[INDEX]))/8;
			// Do the Average on time at Slow Rate
	}


	// Determine next sensor to test.
	SetNextChannel();

	// Restart timers for next pass
	RestartTimers();			
}






/*....................................................................
.	SetNextChannel()
.
.		The SetNextChannel function will set the next channel in
.	sequence to be scanned based off of the current index value.
....................................................................*/
void SetNextChannel(void) {

	// 8. Complete code to change channels

	// ...
	// Set next button to drive oscillator
	INDEX = (++INDEX) & 0x03;												// Set next sensor to test (Max is 3, thus & 0x03 rolls over 3->0)
	
	CM1CON0 = COMP1[INDEX];													// configure comparators for the new sensor
	CM2CON0 = COMP2[INDEX];
}




