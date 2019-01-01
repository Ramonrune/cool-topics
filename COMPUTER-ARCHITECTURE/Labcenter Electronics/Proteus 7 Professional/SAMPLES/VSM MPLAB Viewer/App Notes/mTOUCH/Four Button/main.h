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



/** Part Definitions **/
#include    <pic.h>

/** Defines **/

#define	CLEAR			0						// Bit Clear/Set Definitions
#define SET				1

#define DEVICE_ADDR		0x42					// Device's I2C Address

#define NUM_BTTNS		4						// Number of capacitive buttons

#define AVG_DELAY		10						// Delay max count for 'slow averaging'

#define	ON				1						// LED ON Definition  (Active Low)
#define OFF				0						// LED OFF Definition (Active Low) 


/** Declare Pinouts **/

// I2C Comms.
#define TRISSDA			TRISC4					// Match these to the pins of your device
#define TRISSCL			TRISC3

// Capacitive I/O
#define TRISC2OUT			TRISA5					// Match these to the pins of your device
#define TRISC12IN0			TRISA0					
#define TRISC12IN1			TRISA1					
#define TRISC12IN2			TRISB3					
#define TRISC12IN3			TRISB1		

// Capacitive Decoding
#define PCT_ON			200						// Percent 'on', 'off' a button is relative to its norm
#define PCT_OFF			150						// e.g. 70 = 7.0%
#define PCT_AVG			150						// Percent range to average before ceasing average.
// NOTE:
//  PCT_ON 200 = 20.0% for no glass
//  above board, for using 
//  glass/acrylic, lower the
//  PCT_ON svalue.  Glass/acrylic
//  will decrease sensing ability.
//  Also lower the off & avg values.


// LED Definitions
//
// Pictoral:
//     0         0    0    0           
//    __        __   __   __            
//   |  |      |  | |  | |  |                        
//   |__|      |__| |__| |__|                          
//
// LED:
//    LOGO      MIC  RO  CHIP

// Ports
#define LED_LOGO		RD0
#define LED_MIC			RD1
#define LED_RO			RD2
#define LED_CHIP		RD3
// Tris
#define TRISLED_LOGO	TRISD0
#define TRISLED_MIC		TRISD1
#define TRISLED_RO		TRISD2
#define TRISLED_CHIP	TRISD3



// Index Definitions (Important!! to make easier flowing software)
#define iLOGO		0		// Leftmost button
#define iMIC		1		//   .
#define iRO			2		//  ...
#define iCHIP		3		// Rightmost button




//////////////////////////////////////////////////////////////////////


#ifndef TYPEDEFS_MAIN_H
#define TYPEDEFS_MAIN_H


// To make global must make typedefs... slightly awkward.
typedef struct {
						char	LOGO:1;			// { byte 0 }
						char	MIC: 1;
						char	RO:  1;
						char	CHIP:1;

					} BButtons;


typedef struct {
						char	SSPBF:1;											// Flag if SSP Module is busy (Comm in progress)
						char	SLEEP:1;											// Flag to indicate sleep operation
					} FFlags;


#endif /* TYPEDEFS_MAIN_H */



//////////////////////////////////////////////////////////////////////

// I2C Communications
extern unsigned char	ByteCount;	
extern unsigned char	EEIndex;
extern unsigned char	TempIndex;
extern unsigned int		TempInt;

// Flag variable with SSP Busy Flag bit.
extern FFlags Flags;

// Flags for Capacitive Sensing, indicates a button down. 
extern BButtons Buttons;


extern unsigned int	RAW	   [NUM_BTTNS];
extern unsigned int	AVERAGE[NUM_BTTNS];		// Can't fit all in one bank. Only 96 bytes per Banks 2|3, (Max 24 bttns)


// Capacitive
extern unsigned char	AvgIndex;
extern long 			percent;

extern unsigned char	FIRST;					// first variable to 'discard' first N samples
extern unsigned char	INDEX;					// Index of what button is being checked.

extern unsigned int		VALUE;					// current button value

extern unsigned int		j;						// Global incrementer variable.. use with caution to interrupts.






/* Prototypes */

// Main file prototypes
void INIT(void);
void CapInit(void);
void RestartTimers(void);
void SetNextChannel(void);
void CapISR(void);
void interrupt isr(void);				// Declare functions called from isr above for best context saving.


