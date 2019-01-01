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


#include "main.h"
#include "ssp.h"

void SSPInit(void);
void SSPISR(void);					
void LoadSSPBUF(void);
void UnloadSSPBUF(void);

/*....................................................................
.	SSPInit()
.
.		Initializes pins and registers for SSP use.
....................................................................*/
void SSPInit(void) {

	int i;

	// SSP Pins
	TRISSDA = 1;								// SDA = 1nput  (digital i/p, ANSEL set by Cap. init)
	TRISSCL = 1;								// SCL = 1nput  (digital i/p, ANSEL set by Cap. init)

	// Initialize Module
	SSPCON 	= 0x00;								// Clear Reg, then set appropriate bits.
	SSPEN 	= 1;								// Enable module
	CKP		= 1;								// Enable Clock
	SSPM3	= 1;								// Set for I2C slave, 7-bit addr, S & P intpts
	SSPM2	= 1;								//      "
	SSPM1	= 1;								//      "

	// commented for 677 no GCEN
	//GCEN 	= 0;								// Clear general call enable interrupt (only react to device address)
	SSPADD 	= DEVICE_ADDR;						// Set device address to respond to, mask bits default 0xFF to match all.
	SMP 	= 1;								// Set for sample rate ~100kHz

	SSPIF	= 0;								// Clear flag in case prexists as set PIR1
	SSPIE	= 1;								// Enable SSP Interrupt
	PEIE	= 1;								// Enable Peripheral Interrupts
	/* GIE										Needs to be set when ready to enable all interrupts. */
	

	// Init Ram Variables
	EEIndex		= 0;
	Flags.SSPBF = 0;
	ByteCount 	= 0;
}



/*....................................................................
.		High level call that determines what action to take. Call
.	this function whenever an SSPIF flag is detected whether under
.	read or write conditions.  The condition will be sorted out,
.	and the appropriate action will be taken to make the device
.	act as EEPROM.
....................................................................*/
void SSPISR(void) {


	SSPIF = CLEAR;								// Clear interrupt flag right away

	// 1. Check if I have a start or stop condition
	// 2. Service Starts and Stops differently
	// 3. Service byte transmissions read/write as appropriate

	if (STOP == 1) {
		// Stop Condition
		Flags.SSPBF = CLEAR;

		// Wrap-up Transmission
		SSPOV = CLEAR;							// Clear overflow err if applicable		
		CKP	  = SET;							// Enable clock again
		return;									// Return to end SSP use
		
	} else if (RW == 0 && BF == 0) {
		// Start Condition
		Flags.SSPBF = SET;						// Set SSP Busy Flag

		SSPOV = CLEAR;							// Clear overflow err if applicable		
		CKP	  = SET;							// Enable clock again
		return;									// Return to finish start interrupt
	}
	
	// If not a Start or Stop, perform the read or write of a byte

	if (DA == 0) {								// DEVICE ADDRESS BYTE, determine if R/W
		
		if (RW == 0) {							// Write byte
			ByteCount = SSPBUF;					// Read SSPBUF to clear BF flag (destination not critical)
			ByteCount = 0;						// Clear ByteCount for start of Write(s)

		} else {								// Read Byte
												// { Master expecting data to be sent from address at SSPBUF }
			CKP = 0;							// Ensure clock disabled
			LoadSSPBUF();						// Load SSPBUF and prep for next pass
		}

	} else {									// DATA BYTE
		
		if (RW == 0) {							// Write Byte
			
			if (ByteCount == 0) {				// 2nd Byte received by slave, (address to write to/read from)
				EEIndex = SSPBUF;				// Index for where to read is byte received over SSP.
				ByteCount++;					// BC = 1 for next pass to signify real data byte.

			} else {							// Receiving data byte
												// { Note no bounds checking }
				UnloadSSPBUF();					// Take Contents of SSPBUF and place into data arrays
			}

		} else {								// Read Byte
												// { Send data to master. }
			CKP    = CLEAR;						// disable clock line
			LoadSSPBUF();						// Load SSPBUF and prep for next pass
		}	
	}

	// Finished servicing byte		
				
	SSPOV = CLEAR;								// Clear overflow err if applicable		
	CKP	  = SET;								// Enable clock again
	return;	
}




/*....................................................................
.	LoadSSPBUF()
.
.		Loads the SSPBUF register with the appropriate data.  Since
.	the data is stored as 2-byte integers, and only 1 byte may be sent
.	over the SSP at a time, this makes the PIC act like EEPROM.
....................................................................*/
void LoadSSPBUF(void) {

	TempIndex = EEIndex/sizeof(unsigned int);				// Get Index into RAW, AVG, etc. Arrays. by integer, not byte

	// LOAD CORRECT DATA
	if (TempIndex < NUM_BTTNS)
		SSPBUF = (EEIndex % 2) ? RAW[TempIndex] : RAW[TempIndex] >> 8;			// Load SSPBUF with raw data
	else if (TempIndex < 2*NUM_BTTNS)
		SSPBUF = (EEIndex % 2) ? AVERAGE[TempIndex - NUM_BTTNS] : AVERAGE[TempIndex - NUM_BTTNS] >> 8;	// Load SSPBUF with average values (reindex at 0)


	EEIndex++;
}




/*....................................................................
.	UnloadSSPBUF()
.
.		Unloads the SSPBUF register into the appropriate data.  Since
.	the data is stored as 2-byte integers, and only 1 byte may be sent
.	over the SSP at a time, this makes the PIC act like EEPROM.
.
.	CAVEAT!!!  	If you write an odd # of bytes starting at an even
.				location other than 0 to the "EEPROM PIC" an 
.				additional 00 will be written to the index of last
.				byte plus one.  Example Write 55 56 57 58 59 to 0x02
.				Writes:  00 01 02 03 04 05 06 07 08   'EE' Index
.						 ?? ?? 55 56 57 58 59 00 ??   ??=no change
.				This is due to integer handling, and you should 
.				always be writing 2 byte integers on the even indices
....................................................................*/
void UnloadSSPBUF(void) {

	TempIndex = EEIndex/sizeof(unsigned int);				// Get Index into RAW, AVG, etc. Arrays. by integer, not byte

	TempInt = SSPBUF;

	// Store Data to Array
	
	if ( !(EEIndex % 2) ) {									// High Byte...
	
		if (TempIndex < NUM_BTTNS)
			RAW[TempIndex] = TempInt*256;					// Store SSPBUF to raw data
		else if (TempIndex < 2*NUM_BTTNS)
			AVERAGE[TempIndex - NUM_BTTNS] = TempInt*256;	// Load SSPBUF with average values (reindex at 0)
	
	} else {												// Low Byte...
	
		if (TempIndex < NUM_BTTNS) {
			RAW[TempIndex] &= 0xFF00;						// Clear Low byte 
			RAW[TempIndex] |= TempInt;						// Store SSPBUF (Low byte) to raw data
		} else if (TempIndex < 2*NUM_BTTNS) {
			AVERAGE[TempIndex - NUM_BTTNS] &= 0xFF00;
			AVERAGE[TempIndex - NUM_BTTNS] |= TempInt;		// Load SSPBUF with average values (reindex at 0)
		} 
	}

	EEIndex++;						// Increment index for next pass
}
