/*********************************************************************
 *
 *                  Compiler specific defs.
 *
 *********************************************************************
 * FileName:        Compiler.h
 * Dependencies:    None
 * Processor:       PIC18
 * Complier:        MCC18 v1.00.50 or higher
 *                  HITECH PICC-18 V8.10PL1 or higher
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
 * Author               Date    Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Nilesh Rajbharti     11/14/01 Original        (Rev 1.0)
 * Nilesh Rajbharti     2/9/02  Cleanup
 * Nilesh Rajbharti     5/22/02 Rev 2.0 (See version.log for detail)
 * Howard Schlunder		11/30/04 Added some more defines
 ********************************************************************/
#ifndef COMPILER_H
#define COMPILER_H

// Clock frequency value.
// This value is used to calculate Tick Counter value
#if defined(__18CXX)
    #include <p18cxxx.h>
	#define CLOCK_FREQ              (40000000)      // Hz
#elif defined(__PIC24F__)
	#include <p24Fxxxx.h>
	#define CLOCK_FREQ              (32000000)      // Hz
#elif defined(__PIC24H__)
	#include <p24Hxxxx.h>
	#define CLOCK_FREQ              (80000000)      // Hz
#elif defined(__dsPIC33F__)
	#include <p33Fxxxx.h>
	#define CLOCK_FREQ              (79872000)      // Hz
#elif defined(__dsPIC30__)
	#include <p30fxxxx.h>
	#define CLOCK_FREQ              (60000000)      // Hz
#else
	#error Unknown processor.  See Compiler.h
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <spi.h>
#ifdef __C30__
	#include <stdlib.h>
	#include <uart.h>
#else
	#include <usart.h>
#endif

#if defined(__18CXX)
    #define ROM                 	rom
	#define	__attribute__(a)

	#define BusyUART()				Busy1USART()
	#define CloseUART()				Close1USART()
	#define ConfigIntUART(a)		Config1IntUSART(a)
	#define DataRdyUART()			DataRdy1USART()
	#define OpenUART(a,b,c)			Open1USART(a,b,c)
	#define ReadUART()				Read1USART()
	#define WriteUART(a)			Write1USART(a)
	#define getsUART(a,b,c)			gets1USART(b,a)
	#define putsUART(a)				puts1USART(a)
	#define getcUART()				getc1USART()
	#define putcUART()				putc1USART()
	#define putrsUART(a)			putrs1USART((far rom char*)a)

	#if defined(__18F8720) || defined(__18F87J10)
	    #define TXSTAbits       	TXSTA1bits
	    #define TXREG           	TXREG1
	    #define TXSTA           	TXSTA1
	    #define RCSTA           	RCSTA1
	    #define SPBRG           	SPBRG1
	    #define RCREG           	RCREG1
	#endif
#elif defined(__C30__)
    #define ROM						const

	#define SSPCON1					SSP1CON1

	#define BusyUART()				BusyUART2()
	#define CloseUART()				CloseUART2()
	#define ConfigIntUART(a)		ConfigIntUART2(a)
	#define DataRdyUART()			DataRdyUART2()
	#define OpenUART(a,b,c)			OpenUART2(a,b,c)
	#define ReadUART()				ReadUART2()
	#define WriteUART(a)			WriteUART2(a)
	#define getsUART(a,b,c)			getsUART2(a,b,c)
	#define putsUART(a)				putsUART2(a)
	#define getcUART()				getcUART2()
	#define putcUART()				putcUART2()
	#define putrsUART(a)			putsUART2(a)

	#define memcmppgm2ram(a,b,c)	memcmp(a,b,c)
	#define memcpypgm2ram(a,b,c)	memcpy(a,b,c)

	#if __dsPIC33F__
		#define AD1PCFGbits			AD1PCFGLbits
		#define AD1CHS				AD1CHS0
	#endif
#endif

#endif
