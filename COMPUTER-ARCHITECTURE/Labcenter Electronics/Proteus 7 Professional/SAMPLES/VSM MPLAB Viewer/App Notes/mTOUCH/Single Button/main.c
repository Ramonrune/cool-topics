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

#include    <pic.h>

__CONFIG(INTIO & WDTDIS & PWRTEN & MCLRDIS & UNPROTECT & BORDIS);


/** Constants **/

// 0x94/0xA0 = Cin0-    ,   0x95/0xA1 = Cin1-   (Sets comparator operation and proper channel.)
const unsigned char	COMP1[4] = {0x94};				// comparator preset values for button on C12IN0
const unsigned char	COMP2[4] = {0xA0};


/** Defines **/

#define ON					1						// Definition for button line, active high
#define OFF					0						// Definition for button line, active high


// Capacitive Button Definitions
#define NUM_BTTNS			1

// Indices of buttons (big deal for lots of buttons, not so much here)
#define iBTN0				0						// Define the indices as the CapISR scans ... just one for this specific project

#define AVG_DELAY			26						// Avg Delay constant, must be multiple of 2


/** Declare Pinouts **/

#define C2OUT				RA5						// Oscillator driver pin
#define TRISC2OUT			TRISA5

// Signal Hi/Low Line
#define SIGNAL				RD0						// Instead of LEDs have a signal line
#define TRISSIGNAL			TRISD0 					// to communicate to external host if button is pressed.



/** Variables **/


// CapISR Var's
unsigned char 	i, j;
unsigned int 	temp;
unsigned char 	AvgIndex;


// Application Flags
struct {
		char	NONE_IN_THIS_APP:1;		// Just for example in this application
} Flags;


// Flags for Capacitive Sensing, BTNx indicates a button down. 
struct {
		char	TRUNK:1;				// Button flag, access by "Buttons.TRUNK"
		//char	BTN1:1;					
		//char	BTN2:1;					// Example if there were more buttons.
		//char	BTN3:1;
} Buttons;


unsigned int	average[NUM_BTTNS];		
unsigned int	trip[NUM_BTTNS];


unsigned char	first;						// first variable to 'discard' first N samples
unsigned char	index;						// Index of what button is being checked.
unsigned int	value;						// current button value





/* Prototypes */

void INIT(void);
void CapInit(void);
void RestartTimers(void);
void SetNextChannel(void);
void CapISR(void);
static void interrupt isr(void);				// Declare functions called from isr above declaration for most efficient context saving.






/*====================================================================
=========================  PROGRAM  ==================================
====================================================================*/





/*....................................................................
. 	main()
.
.		Entry point of program.
....................................................................*/
void main(void) {


	INIT();
	

	while (1) {								// Loop forever	
		
		// Set or clear signal pin for button pressed
		SIGNAL = (Buttons.TRUNK) ? ON : OFF;
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

	/* Capacitive */
	TRISC2OUT = 0;					// C2OUT = oscillator output
	TRISC0	= 1;					// T1CKI = input
	// Button Inputs
	TRISA2  = 1;					// C2in+
	TRISA0  = 1;					// Button Input for C12IN0-
	// Signal Outputs
	TRISSIGNAL = 0;					// Signal line as output	

	// Clear Variables
	Buttons.TRUNK = 0;				// Ensure off at start
	
	CapInit();						// Initialize Capacitive Sensing
	
	GIE = 1;						// turn on the global interrupts once done w/inits

}






/*....................................................................
.	isr()
.
.		Interrupt Service Routine - is the function called when any
.	interrupt is received on the part.  The device context saves, 
.	and then redirects flow here. Program flow will be returned at
.	the end of this function.  The flagging interrupt MUST be
.	cleared in software! (or you will be stuck for-ev-er).
....................................................................*/
static void interrupt isr(void)
{																		
	
	/* Timer 0 Interrupt */
	/*********************/
	if (T0IF == 1 && T0IE == 1) {			// Timer 0 Overflow Occurred, 
		// Service Capacitive Routine
		TMR1ON	= 0;						// stop Timer1
		CapISR();							// Service Routine {resets/restarts tmrs}			
	}
	

	/* Any Other ISR Code Here             */
	/* be mindful to not corrupt a reading */
	/* by making an inconsistent period.   */


	if (T0IF == 1)
		RestartTimers();					// If T0IF occured during other intpt, clear it as reading is not fixed period timebase
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
	for (index=0; index<NUM_BTTNS; index++) 
		average[index] = 0;
	

	// Individually Set trip Level for buttons
	trip[iBTN0] = 180;				// Threshold of 180 below the running average

	

	first	= 1;					// first pass flag to allow stabilization of average


	// All TRIS Registers set up in INIT() Routine
	// Cap needs to set up C2OUT as o/p, and T1CKI=i/p, and C12INx- pins used = i/p.
		

	VRCON   = 0x8F;					// setup the CVref for 2/3VDD
	CM1CON0 = COMP1[0];				// preset the comparators for first channel (and set appropriate enable bits)
	CM2CON0 = COMP2[0];
	CM2CON1 = 0x32;
	index	= 0;					// Init to start on button 0. { index =button state machine state variable }

	ANSEL   = 0x07;					// configure the button inputs for analog, along with the 1/3VDD reference input
	ANSELH  = 0x06;					// configure the button inputs for analog, along with the 1/3VDD reference input

	SRCON   = 0xF0;					// turn on the SR flip flop mode

	T1CON	= 0x06;					// enable timer1
	OPTION	= 0x84;					// setup the timer0 prescaler

	TMR0	= 0;					// reset Timer0
	TMR1L	= 0;					// reset Timer1
	TMR1H	= 0;
	TMR1ON	= 1;					// restart Timer1

	INTCON	= 0;					// clear the interrupt register
	T0IE	= 1;					// turn on the timer0 interrupt

}





/*....................................................................
.	CapISR()
.
.		Service Routine for handling TMR0 interrupts for capacitive
.	sensing.
....................................................................*/
void CapISR(void) {

	// Get a reading
	value = TMR1L + (unsigned int)(TMR1H << 8);			// Get the frequency count for the current sensor
	

	// During power-up, system must be initialized, set average ea. pass
	if (first > 0) {
		first--;										// Decr. N # times to establish startup
		average[index] = value;							// During start up time, set average each pass.
		SetNextChannel();													
		RestartTimers();								// Restart the timers
		return;											// .. and exit
	}													// else perform capacitive sensing.
	


	// Check for Button Press/Release					(Used fixed value trip and hysteresis.)

	// ...
	if (value < (average[index] - trip[index])) {	
		// .. button is on.
		switch(index) {
			case iBTN0:	Buttons.TRUNK = 1; break;
			default:		break;
		}
		
	} else if (value > (average[index] - trip[index] + 64) ) {
		// .. button is off.
		switch(index) {
			case iBTN0:	Buttons.TRUNK = 0; break;
			default:		break;
		}
	}

			


	// Check for Quick Release

	// ...
	if (value > average[index])
		average[index] = value;		// Don't average, just reset to higher value (ok unless fluke high value, then returns low immediately.)



	// Perform average Always (slowly)

	// ...
	if (AvgIndex < AVG_DELAY)		AvgIndex++;
	else							AvgIndex = 0;

		if (AvgIndex == AVG_DELAY)
			average[index] = average[index] + ((long)(value) - (long)(average[index]))/8;

	

	// Set next button to drive oscillator
	SetNextChannel();

	// Reset Timers for next pass
	RestartTimers();
}




/*....................................................................
.	SetNextChannel()
.
.		Sets the comparators, index, and i/o for the next channel
.	to scan.
....................................................................*/
void SetNextChannel(void) {

		//index = (++index) & 0x03;						// Set next sensor to test (saved for reference)

		index = iBTN0;									// Single sensor does not need to change indices
		CM1CON0 = COMP1[index];							// Configure comparators for the new sensor
		CM2CON0 = COMP2[index];							//                   "
}
