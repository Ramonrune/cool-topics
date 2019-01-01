/*********************************************************************
 *
 *                  Tick Manager for PIC18
 *
 *********************************************************************
 * FileName:        Tick.c
 * Dependencies:    stackTSK.h
 *                  Tick.h
 * Processor:       PIC18, PIC24F, PIC24H, dsPIC30F, dsPIC33F
 * Complier:        Microchip C18 v3.02 or higher
 *					Microchip C30 v2.01 or higher
 * Company:         Microchip Technology, Inc.
 *
 * Software License Agreement
 *
 * This software is owned by Microchip Technology Inc. ("Microchip") 
 * and is supplied to you for use exclusively as described in the 
 * associated software agreement.  This software is protected by 
 * software and other intellectual property laws.  Any use in 
 * violation of the software license may subject the user to criminal 
 * sanctions as well as civil liability.  Copyright 2006 Microchip
 * Technology Inc.  All rights reserved.
 *
 * This software is provided "AS IS."  MICROCHIP DISCLAIMS ALL 
 * WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE, NOT LIMITED 
 * TO MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND 
 * INFRINGEMENT.  Microchip shall in no event be liable for special, 
 * incidental, or consequential damages.
 *
 *
 * Author               Date        Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Nilesh Rajbharti     6/28/01     Original        (Rev 1.0)
 * Nilesh Rajbharti     2/9/02      Cleanup
 * Nilesh Rajbharti     5/22/02     Rev 2.0 (See version.log for detail)
********************************************************************/

#define TICK_INCLUDE

#include "..\Include\StackTsk.h"
#include "..\Include\Tick.h"

#define TICK_TEMP_VALUE_1       \
        ((INSTR_FREQ) / (TICKS_PER_SECOND * TICK_PRESCALE_VALUE))

#if TICK_TEMP_VALUE_1 > 60000
#error TICK_PER_SECOND value cannot be programmed with current CLOCK_FREQ
#error Either lower TICK_PER_SECOND or manually configure the Timer
#endif

#define TICK_TEMP_VALUE         (65535 - TICK_TEMP_VALUE_1)

#define TICK_COUNTER_HIGH       ((TICK_TEMP_VALUE >> 8) & 0xff)
#define TICK_COUNTER_LOW        (TICK_TEMP_VALUE & 0xff)

#if (TICK_PRESCALE_VALUE == 2)
    #define TIMER_PRESCALE  (0)
#elif ( TICK_PRESCALE_VALUE == 4 )
    #define TIMER_PRESCALE  (1)
#elif ( TICK_PRESCALE_VALUE == 8 )
    #define TIMER_PRESCALE  (2)
#elif ( TICK_PRESCALE_VALUE == 16 )
    #define TIMER_PRESCALE  (3)
#elif ( TICK_PRESCALE_VALUE == 32 )
    #define TIMER_PRESCALE  (4)
#elif ( TICK_PRESCALE_VALUE == 64 )
    #define TIMER_PRESCALE  (5)
#elif ( TICK_PRESCALE_VALUE == 128 )
    #define TIMER_PRESCALE  (6)
#elif ( TICK_PRESCALE_VALUE == 256 )
    #define TIMER_PRESCALE  (7)
#else
    #error Invalid TICK_PRESCALE_VALUE specified.
#endif




TICK TickCount = 0;	// 10ms/unit


/*********************************************************************
 * Function:        void TickInit(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          Tick manager is initialized.
 *
 * Side Effects:    None
 *
 * Overview:        Initializes Timer0 as a tick counter.
 *
 * Note:            None
 ********************************************************************/
#define PERIOD (INSTR_FREQ/256/1000)*TICK_PERIOD_MS
void TickInit(void)
{
#ifdef __C30__
	// Set up timer1 to wake up by timeout
	// 1:256 prescale
	T1CONbits.TCKPS = 3;
	// Base
	PR1 = (unsigned)PERIOD;
	// Clear counter
	TMR1 = 0;
	// Enable timer interrupt
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;
	// Start timer
	T1CONbits.TON = 1;
#else
    // Start the timer.
    TMR0L = TICK_COUNTER_LOW;
    TMR0H = TICK_COUNTER_HIGH;

    // 16-BIT, internal timer, PSA set to 1:256
    T0CON = 0b00000000 | TIMER_PRESCALE;

    // Start the timer.
    T0CONbits.TMR0ON = 1;

    INTCONbits.TMR0IF = 1;
    INTCONbits.TMR0IE = 1;
#endif
}


/*********************************************************************
 * Function:        TICK TickGet(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          Current tick value is given
 *					1 tick represents approximately 10ms
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
TICK TickGet(void)
{
    return TickCount;
}


/*********************************************************************
 * Function:        void TickUpdate(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        Internal Tick and Seconds count are updated.
 *
 * Note:            None
 ********************************************************************/
#ifdef __18CXX
void TickUpdate(void)
{
    if(INTCONbits.TMR0IF)
    {
        TMR0H = TICK_COUNTER_HIGH;
        TMR0L = TICK_COUNTER_LOW;

        TickCount++;

        INTCONbits.TMR0IF = 0;
    }
}

#else
/*********************************************************************
 * Function:        void _ISR _T1Interrupt(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          TickCount variable is updated
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
void _ISR _T1Interrupt(void)
{
	TickCount++;
	// Reset interrupt flag
	IFS0bits.T1IF = 0;
	return;
}
#endif
