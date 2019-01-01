/*********************************************************************
 *
 *                  Compiler and hardware specific definitions
 *
 *********************************************************************
 * FileName:        Compiler.h
 * Dependencies:    None
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
 * Author               Date    Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Nilesh Rajbharti     11/14/01 Original        (Rev 1.0)
 * Nilesh Rajbharti     2/9/02  Cleanup
 * Nilesh Rajbharti     5/22/02 Rev 2.0 (See version.log for detail)
 * Howard Schlunder		11/30/04 Added some more defines
 * Howard Schlunder		6/14/06	Added hardware definitions
 * Howard Schlunder		8/10/06	Added PICDEMNET, PIC18F97J60_TEST_BOARD, FS_USB hardware definitions
 ********************************************************************/
#ifndef COMPILER_H
#define COMPILER_H

// Clock frequency value.
// This value is used to calculate Tick Counter value
#if defined(__18CXX)		
	// All PIC18 processors
    #include <p18cxxx.h>
	#if defined(PICDEMNET2)
		#define CLOCK_FREQ		(41666667)      // Hz
	#elif defined(FS_USB)
		#define CLOCK_FREQ		(48000000)      // Hz
	#elif defined(PICDEMNET)
//		#define CLOCK_FREQ		(40000000)      // Hz
		#define CLOCK_FREQ		(19660800)      // Hz
	#else
		#define CLOCK_FREQ		(40000000)      // Hz
	#endif
	#define INSTR_FREQ			(CLOCK_FREQ/4)
#elif defined(__PIC24F__)	
	// PIC24F processor
	#include <p24Fxxxx.h>
	#define CLOCK_FREQ			(32000000)      // Hz
	#define INSTR_FREQ			(CLOCK_FREQ/2)
#elif defined(__PIC24H__)	
	// PIC24H processor
	#include <p24Hxxxx.h>
	#define CLOCK_FREQ			(80000000)      // Hz
	#define INSTR_FREQ			(CLOCK_FREQ/2)
#elif defined(__dsPIC33F__)	
	// dsPIC33F processor
	#include <p33Fxxxx.h>
	#define CLOCK_FREQ			(80000000)      // Hz
	#define INSTR_FREQ			(CLOCK_FREQ/2)
#elif defined(__dsPIC30F__)
	// dsPIC30F processor
	#include <p30fxxxx.h>
	#define CLOCK_FREQ			(117920000)      // Hz
	#define INSTR_FREQ			(CLOCK_FREQ/4)
#elif defined(HI_TECH_C)	// Hi Tech PICC18 compiler
	#define __18CXX
	#include <pic18.h>
	#define CLOCK_FREQ			(40000000)      // Hz
	#define INSTR_FREQ			(CLOCK_FREQ/4)
#else
	#error Unknown processor.  See Compiler.h
#endif

// Hardware mappings
#if defined(HPC_EXPLORER) && !defined(HI_TECH_C)
// PICDEM HPC Explorer + Ethernet PICtail
	// I/O pins
	#define LED0_TRIS			(TRISDbits.TRISD0)
	#define LED0_IO				(PORTDbits.RD0)
	#define LED1_TRIS			(TRISDbits.TRISD1)
	#define LED1_IO				(PORTDbits.RD1)
	#define LED2_TRIS			(TRISDbits.TRISD2)
	#define LED2_IO				(PORTDbits.RD2)
	#define LED3_TRIS			(TRISDbits.TRISD3)
	#define LED3_IO				(PORTDbits.RD3)
	#define LED4_TRIS			(TRISDbits.TRISD4)
	#define LED4_IO				(PORTDbits.RD4)
	#define LED5_TRIS			(TRISDbits.TRISD5)
	#define LED5_IO				(PORTDbits.RD5)
	#define LED6_TRIS			(TRISDbits.TRISD6)
	#define LED6_IO				(PORTDbits.RD6)
	#define LED7_TRIS			(TRISDbits.TRISD7)
	#define LED7_IO				(PORTDbits.RD7)
	#define LED_IO				(*((volatile unsigned char*)(&PORTD)))


	#define BUTTON0_TRIS		(TRISBbits.TRISB0)
	#define	BUTTON0_IO			(PORTBbits.RB0)
	#define BUTTON1_TRIS		(TRISBbits.TRISB0)	// No Button1 on this board, remap to Button0
	#define	BUTTON1_IO			(PORTBbits.RB0)
	#define BUTTON2_TRIS		(TRISBbits.TRISB0)	// No Button2 on this board, remap to Button0
	#define	BUTTON2_IO			(PORTBbits.RB0)
	#define BUTTON3_TRIS		(TRISBbits.TRISB0)	// No Button3 on this board, remap to Button0
	#define	BUTTON3_IO			(PORTBbits.RB0)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(TRISBbits.TRISB5)
	#define ENC_RST_IO			(LATBbits.LATB5)
	#define ENC_CS_TRIS			(TRISBbits.TRISB3)
	#define ENC_CS_IO			(LATBbits.LATB3)
	#define ENC_SCK_TRIS		(TRISCbits.TRISC3)
	#define ENC_SDI_TRIS		(TRISCbits.TRISC4)
	#define ENC_SDO_TRIS		(TRISCbits.TRISC5)
	#define ENC_SPI_IF			(PIR1bits.SSPIF)
	#define ENC_SSPBUF			(SSPBUF)
	#define ENC_SPISTAT			(SSP1STAT)
	#define ENC_SPISTATbits		(SSP1STATbits)
	#define ENC_SPICON1			(SSP1CON1)
	#define ENC_SPICON1bits		(SSP1CON1bits)
	#define ENC_SPICON2			(SSP1CON2)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISBbits.TRISB4)
	#define EEPROM_CS_IO		(LATBbits.LATB4)
	#define EEPROM_SCK_TRIS		(TRISCbits.TRISC3)
	#define EEPROM_SDI_TRIS		(TRISCbits.TRISC4)
	#define EEPROM_SDO_TRIS		(TRISCbits.TRISC5)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSP1CON1)
	#define EEPROM_SPICON1bits	(SSP1CON1bits)
	#define EEPROM_SPICON2		(SSP1CON2)
	#define EEPROM_SPISTAT		(SSP1STAT)
	#define EEPROM_SPISTATbits	(SSP1STATbits)

#elif defined(HPC_EXPLORER) && defined(HI_TECH_C)
// PICDEM HPC Explorer + Ethernet PICtail
	typedef struct
	{
	    unsigned char BF:1;
	    unsigned char UA:1;
	    unsigned char R_W:1;
	    unsigned char S:1;
	    unsigned char P:1;
	    unsigned char D_A:1;
	    unsigned char CKE:1;
	    unsigned char SMP:1;
	} SSPSTATbits;
	typedef struct 
	{
	    unsigned char RBIF:1;
	    unsigned char INT0IF:1;
	    unsigned char TMR0IF:1;
		unsigned char RBIE:1;
	    unsigned char INT0IE:1;
	    unsigned char TMR0IE:1;
	    unsigned char GIEL:1;
	    unsigned char GIEH:1;
	} INTCONbits;
	typedef struct 
	{
	    unsigned char RBIP:1;
	    unsigned char INT3IP:1;
	    unsigned char TMR0IP:1;
	    unsigned char INTEDG3:1;
	    unsigned char INTEDG2:1;
	    unsigned char INTEDG1:1;
	    unsigned char INTEDG0:1;
	    unsigned char RBPU:1;
	} INTCON2bits;
	typedef struct 
	{
	    unsigned char ADON:1;
	    unsigned char GO:1;
	    unsigned char CHS0:1;
	    unsigned char CHS1:1;
	    unsigned char CHS2:1;
	    unsigned char CHS3:1;
	} ADCON0bits;
	typedef struct 
	{
		unsigned char ADCS0:1;
		unsigned char ADCS1:1;
		unsigned char ADCS2:1;
		unsigned char ACQT0:1;
		unsigned char ACQT1:1;
		unsigned char ACQT2:1;
		unsigned char :1;
		unsigned char ADFM:1;
	} ADCON2bits;
	typedef struct 
	{
	    unsigned char TMR1IF:1;
	    unsigned char TMR2IF:1;
	    unsigned char CCP1IF:1;
	    unsigned char SSPIF:1;
	    unsigned char TXIF:1;
	    unsigned char RCIF:1;
	    unsigned char ADIF:1;
	    unsigned char PSPIF:1;
	} PIR1bits;
	typedef struct 
	{
	    unsigned char TMR1IE:1;
	    unsigned char TMR2IE:1;
	    unsigned char CCP1IE:1;
	    unsigned char SSPIE:1;
	    unsigned char TXIE:1;
	    unsigned char RCIE:1;
	    unsigned char ADIE:1;
	    unsigned char PSPIE:1;
	} PIE1bits;
	typedef struct
	{
	    unsigned char T0PS0:1;
	    unsigned char T0PS1:1;
	    unsigned char T0PS2:1;
	    unsigned char PSA:1;
	    unsigned char T0SE:1;
	    unsigned char T0CS:1;
	    unsigned char T08BIT:1;
	    unsigned char TMR0ON:1;
	} T0CONbits;
	typedef struct
	{
	    unsigned char TX9D:1;
	    unsigned char TRMT:1;
	    unsigned char BRGH:1;
	    unsigned char SENDB:1;
	    unsigned char SYNC:1;
	    unsigned char TXEN:1;
	    unsigned char TX9:1;
	    unsigned char CSRC:1;
	} TXSTAbits;
	typedef struct
	{
	    unsigned char RX9D:1;
	    unsigned char OERR:1;
	    unsigned char FERR:1;
	    unsigned char ADDEN:1;
	    unsigned char CREN:1;
	    unsigned char SREN:1;
	    unsigned char RX9:1;
	    unsigned char SPEN:1;
	} RCSTAbits;
	
	#define TXSTA				TXSTA1
	#define RCSTA				RCSTA1
	#define SPBRG				SPBRG1
	#define RCREG				RCREG1
	#define TXREG				TXREG1

	// I/O pins
	#define LED0_TRIS			(TRISD0)
	#define LED0_IO				(RD0)
	#define LED1_TRIS			(TRISD1)
	#define LED1_IO				(RD1)
	#define LED2_TRIS			(TRISD2)
	#define LED2_IO				(RD2)
	#define LED3_TRIS			(TRISD3)
	#define LED3_IO				(RD3)
	#define LED4_TRIS			(TRISD4)
	#define LED4_IO				(RD4)
	#define LED5_TRIS			(TRISD5)
	#define LED5_IO				(RD5)
	#define LED6_TRIS			(TRISD6)
	#define LED6_IO				(RD6)
	#define LED7_TRIS			(TRISD7)
	#define LED7_IO				(RD7)
	#define LED_IO				(*((volatile unsigned char*)(&PORTD)))

	#define BUTTON0_TRIS		(TRISB0)
	#define	BUTTON0_IO			(RB0)
	#define BUTTON1_TRIS		(TRISB0)	// No Button1 on this board, remap to Button0
	#define	BUTTON1_IO			(RB0)
	#define BUTTON2_TRIS		(TRISB0)	// No Button2 on this board, remap to Button0
	#define	BUTTON2_IO			(RB0)
	#define BUTTON3_TRIS		(TRISB0)	// No Button3 on this board, remap to Button0
	#define	BUTTON3_IO			(RB0)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(TRISB5)
	#define ENC_RST_IO			(LATB5)
	#define ENC_CS_TRIS			(TRISB3)
	#define ENC_CS_IO			(LATB3)
	#define ENC_SCK_TRIS		(TRISC3)
	#define ENC_SDI_TRIS		(TRISC4)
	#define ENC_SDO_TRIS		(TRISC5)
	#define ENC_SPI_IF			(SSP1IF)
	#define ENC_SSPBUF			(SSP1BUF)
	#define ENC_SPISTAT			(SSP1STAT)
	#define ENC_SPISTATbits		(*((SSPSTATbits*)&SSP1STAT))
	#define ENC_SPICON1			(SSP1CON1)
	#define ENC_SPICON1bits		(*((SSPCON1bits*)&SSP1CON))
	#define ENC_SPICON2			(SSP1CON2)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISB4)
	#define EEPROM_CS_IO		(LATB4)
	#define EEPROM_SCK_TRIS		(TRISC3)
	#define EEPROM_SDI_TRIS		(TRISC4)
	#define EEPROM_SDO_TRIS		(TRISC5)
	#define EEPROM_SPI_IF		(SSP1IF)
	#define EEPROM_SSPBUF		(SSP1BUF)
	#define EEPROM_SPICON1		(SSP1CON1)
	#define EEPROM_SPICON1bits	(*((SSPCON1bits*)&SSP1CON))
	#define EEPROM_SPICON2		(SSP1CON2)
	#define EEPROM_SPISTAT		(SSP1STAT)
	#define EEPROM_SPISTATbits	(*((SSPSTATbits*)&SSP1STAT))

	#define INTCONbits			(*((INTCONbits*)&INTCON))
	#define INTCON2bits			(*((INTCON2bits*)&INTCON2))
	#define ADCON0bits			(*((ADCON0bits*)&ADCON0))
	#define ADCON2bits			(*((ADCON2bits*)&ADCON2))
	#define PIR1bits			(*((PIR1bits*)&PIR1))
	#define PIE1bits			(*((PIE1bits*)&PIE1))
	#define T0CONbits			(*((T0CONbits*)&T0CON))
	#define TXSTAbits			(*((TXSTAbits*)&TXSTA1))
	#define RCSTAbits			(*((RCSTAbits*)&RCSTA1))

#elif defined(FS_USB) && !defined(HI_TECH_C)
// NOTE: THIS IS A WORK IN PROGRESS
// PICDEM FS USB demo board support still needs more work
// PICDEM FS USB + Ethernet PICtail
// To use the PICDEM FS USB board, you must :
// 1. On Ethernet PICtail, cut the traces under J5, J6, and J7, install jumper headers, and place jumper shunts on pins 2-3, 2-3, and 2-3.
// 2. On PICDEM FS USB, cut trace under JP3 to prevent SDO and MAX232 RX output bus contention
// 3. Remove all UART code in the stack.  The SPI and UART share the same PIC18F4550 pins, so you must disable the UART and not use it.
// 4. RAM and ROM are tight on the PIC18F4550.  Need to unprotect several USB RAM banks and enable all C18 compiler optimizations (especially procedural abstraction), or remove a bunch of stack modules.

	// I/O pins
	#define LED0_TRIS			(TRISDbits.TRISD3)
	#define LED0_IO				(PORTDbits.RD3)
	#define LED1_TRIS			(TRISDbits.TRISD2)
	#define LED1_IO				(PORTDbits.RD2)
	#define LED2_TRIS			(TRISDbits.TRISD1)
	#define LED2_IO				(PORTDbits.RD1)
	#define LED3_TRIS			(TRISDbits.TRISD0)
	#define LED3_IO				(PORTDbits.RD0)
	#define LED4_TRIS			(TRISDbits.TRISD3)	// No LED remap to LED0
	#define LED4_IO				(PORTDbits.RD3)
	#define LED5_TRIS			(TRISDbits.TRISD2)	// No LED remap to LED1
	#define LED5_IO				(PORTDbits.RD2)
	#define LED6_TRIS			(TRISDbits.TRISD1)	// No LED remap to LED2
	#define LED6_IO				(PORTDbits.RD1)
	#define LED7_TRIS			(TRISDbits.TRISD0)	// No LED remap to LED3
	#define LED7_IO				(PORTDbits.RD0)


	#define BUTTON0_TRIS		(TRISBbits.TRISB5)
	#define	BUTTON0_IO			(PORTBbits.RB5)
	#define BUTTON1_TRIS		(TRISBbits.TRISB4)
	#define	BUTTON1_IO			(PORTBbits.RB4)
	#define BUTTON2_TRIS		(TRISBbits.TRISB5)	// No Button2 on this board, remap to Button0
	#define	BUTTON2_IO			(PORTBbits.RB5)
	#define BUTTON3_TRIS		(TRISBbits.TRISB4)	// No Button3 on this board, remap to Button0
	#define	BUTTON3_IO			(PORTBbits.RB4)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(TRISBbits.TRISB5)
	#define ENC_RST_IO			(LATBbits.LATB5)
	#define ENC_CS_TRIS			(TRISBbits.TRISB3)
	#define ENC_CS_IO			(LATBbits.LATB3)
	#define ENC_SCK_TRIS		(TRISBbits.TRISB1)
	#define ENC_SDI_TRIS		(TRISBbits.TRISB0)
	#define ENC_SDO_TRIS		(TRISCbits.TRISC7)
	#define ENC_SPI_IF			(PIR1bits.SSPIF)
	#define ENC_SSPBUF			(SSPBUF)
	#define ENC_SPISTAT			(SSPSTAT)
	#define ENC_SPISTATbits		(SSPSTATbits)
	#define ENC_SPICON1			(SSPCON1)
	#define ENC_SPICON1bits		(SSPCON1bits)
	#define ENC_SPICON2			(SSPCON2)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISBbits.TRISB4)
	#define EEPROM_CS_IO		(LATBbits.LATB4)
	#define EEPROM_SCK_TRIS		(TRISBbits.TRISB1)
	#define EEPROM_SDI_TRIS		(TRISBbits.TRISB0)
	#define EEPROM_SDO_TRIS		(TRISCbits.TRISC7)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSPCON1)
	#define EEPROM_SPICON1bits	(SSPCON1bits)
	#define EEPROM_SPICON2		(SSPCON2)
	#define EEPROM_SPISTAT		(SSPSTAT)
	#define EEPROM_SPISTATbits	(SSPSTATbits)

#elif defined(PICDEMNET) && !defined(HI_TECH_C)
// PICDEM.net (classic) board with Realtek RTL8019AS Ethernet controller
// It is strongly recommended that the PIC18F452 that came installed 
// on the PICDEM.net be removed and a PIC18F4620 be installed in its 
// place.  The PIC18F4620 has twice the FLASH, substantially more 
// RAM, and as a result can support all of the latest TCP/IP stack 
// modules compiled all at once.  The PIC18F4620 also has superior 
// peripherals that are natively supported by the stack.
//
// If using the PIC18F452, you most likely have to use the modified 
// 18f452i.lkr linker script and turn on all C18 compiler optimizations, 
// including procedural abstraction to get the project to compile.  The 
// stack ROM/RAM memory usage is right at the limits of the 18F452.
	// I/O pins
	#define LED0_TRIS			(TRISAbits.TRISA4)
	#define LED0_IO				(PORTAbits.RA4)
	#define LED1_TRIS			(TRISAbits.TRISA3)
	#define LED1_IO				(PORTAbits.RA3)
	#define LED2_TRIS			(TRISAbits.TRISA2)
	#define LED2_IO				(PORTAbits.RA2)
	#define LED3_TRIS			(TRISAbits.TRISA4)
	#define LED3_IO				(PORTAbits.RA4)
	#define LED4_TRIS			(TRISAbits.TRISA3)
	#define LED4_IO				(PORTAbits.RA3)
	#define LED5_TRIS			(TRISAbits.TRISA2)
	#define LED5_IO				(PORTAbits.RA2)
	#define LED6_TRIS			(TRISAbits.TRISA4)
	#define LED6_IO				(PORTAbits.RA4)
	#define LED7_TRIS			(TRISAbits.TRISA3)
	#define LED7_IO				(PORTAbits.RA3)

	#define BUTTON0_TRIS		(TRISBbits.TRISB5)
	#define	BUTTON0_IO			(PORTBbits.RB5)
	#define BUTTON1_TRIS		(TRISBbits.TRISB5)	// No Button1 on this board, remap to Button0
	#define	BUTTON1_IO			(PORTBbits.RB5)
	#define BUTTON2_TRIS		(TRISBbits.TRISB5)	// No Button2 on this board, remap to Button0
	#define	BUTTON2_IO			(PORTBbits.RB5)
	#define BUTTON3_TRIS		(TRISBbits.TRISB5)	// No Button3 on this board, remap to Button0
	#define	BUTTON3_IO			(PORTBbits.RB5)

	// RTL8019AS I/O pins
	#define NIC_CTRL_TRIS       (TRISE)
	#define NIC_RESET_IO        (PORTEbits.RE2)
	#define NIC_IOW_IO          (PORTEbits.RE1)
	#define NIC_IOR_IO          (PORTEbits.RE0)
	#define NIC_ADDR_IO         (PORTB)
        #define NIC_ADDR_TRIS	    (TRISB)
	#define NIC_DATA_IO         (PORTD)
        #define NIC_DATA_TRIS	    (TRISD)

	// 24LC256 I/O pins
	#define EEPROM_SCL_TRIS		(TRISCbits.TRISC3)
	#define EEPROM_SDA_TRIS		(TRISCbits.TRISC4)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSPCON1)
	#define EEPROM_SPICON1bits	(SSPCON1bits)
	#define EEPROM_SPICON2		(SSPCON2)
	#define EEPROM_SPICON2bits	(SSPCON2bits)
	#define EEPROM_SPISTAT		(SSPSTAT)
	#define EEPROM_SPISTATbits	(SSPSTATbits)

	// LCD
	// LCD Module I/O pins
	typedef struct
	{
		unsigned char data : 4;	// Bits 0 through 3
		unsigned char : 4;		// Bits 4 through 7
	} LCD_DATA;
	#define LCD_DATA_TRIS		(((volatile LCD_DATA*)&TRISD)->data)
	#define LCD_DATA_IO			(((volatile LCD_DATA*)&LATD)->data)
	#define LCD_RD_WR_TRIS		(TRISDbits.TRISD5)
	#define LCD_RD_WR_IO		(LATDbits.LATD5)
	#define LCD_RS_TRIS			(TRISDbits.TRISD4)
	#define LCD_RS_IO			(LATDbits.LATD4)
	#define LCD_E_TRIS			(TRISAbits.TRISA5)
	#define LCD_E_IO			(LATAbits.LATA5)

	// Do not use the DMA and other goodies that Microchip Ethernet modules have
	#define NON_MCHP_MAC

	#if defined(__18F452)
		#define OSCTUNE				PRODL
		#define ADCON2				PRODL
	#endif

#elif defined(PICDEMNET) && defined(HI_TECH_C)
// PICDEM.net (classic) board with Realtek RTL8019AS Ethernet controller
// It is strongly recommended that the PIC18F452 that came installed 
// on the PICDEM.net be removed and a PIC18F4620 be installed in its 
// place.  The PIC18F4620 has twice the FLASH, substantially more 
// RAM, and as a result can support all of the latest TCP/IP stack 
// modules compiled all at once.  The PIC18F4620 also has superior 
// peripherals that are natively supported by the stack.
//
// If using the PIC18F452, you most likely will not be able to compile
// the stack with the HI-TECH compiler due to excessive code space needed.
// You must remove unneeded modules or use a bigger microcontroller.
	typedef struct
	{
	    unsigned char BF:1;
	    unsigned char UA:1;
	    unsigned char R_W:1;
	    unsigned char S:1;
	    unsigned char P:1;
	    unsigned char D_A:1;
	    unsigned char CKE:1;
	    unsigned char SMP:1;
	} SSPSTATbits;
	typedef struct
	{
	    unsigned char SSPM0:1;
	    unsigned char SSPM1:1;
	    unsigned char SSPM2:1;
	    unsigned char SSPM3:1;
	    unsigned char CKP:1;
	    unsigned char SSPEN:1;
	    unsigned char SSPOV:1;
	    unsigned char WCOL:1;
	} SSPCON1bits;
	typedef struct
	{
	    unsigned char SEN:1;
	    unsigned char RSEN:1;
	    unsigned char PEN:1;
	    unsigned char RCEN:1;
	    unsigned char ACKEN:1;
	    unsigned char ACKDT:1;
	    unsigned char ACKSTAT:1;
	    unsigned char GCEN:1;
	} SSPCON2bits;
	typedef struct 
	{
	    unsigned char RBIF:1;
	    unsigned char INT0IF:1;
	    unsigned char TMR0IF:1;
		unsigned char RBIE:1;
	    unsigned char INT0IE:1;
	    unsigned char TMR0IE:1;
	    unsigned char GIEL:1;
	    unsigned char GIEH:1;
	} INTCONbits;
	typedef struct 
	{
	    unsigned char RBIP:1;
	    unsigned char INT3IP:1;
	    unsigned char TMR0IP:1;
	    unsigned char INTEDG3:1;
	    unsigned char INTEDG2:1;
	    unsigned char INTEDG1:1;
	    unsigned char INTEDG0:1;
	    unsigned char RBPU:1;
	} INTCON2bits;
	typedef struct 
	{
	    unsigned char ADON:1;
	    unsigned char GO:1;
	    unsigned char CHS0:1;
	    unsigned char CHS1:1;
	    unsigned char CHS2:1;
	    unsigned char CHS3:1;
	} ADCON0bits;
	typedef struct 
	{
		unsigned char ADCS0:1;
		unsigned char ADCS1:1;
		unsigned char ADCS2:1;
		unsigned char ACQT0:1;
		unsigned char ACQT1:1;
		unsigned char ACQT2:1;
		unsigned char :1;
		unsigned char ADFM:1;
	} ADCON2bits;
	typedef struct 
	{
	    unsigned char TMR1IF:1;
	    unsigned char TMR2IF:1;
	    unsigned char CCP1IF:1;
	    unsigned char SSPIF:1;
	    unsigned char TXIF:1;
	    unsigned char RCIF:1;
	    unsigned char ADIF:1;
	    unsigned char PSPIF:1;
	} PIR1bits;
	typedef struct 
	{
	    unsigned char CCP2IF:1;
	    unsigned char TMR3IF:1;
	    unsigned char HLVDIF:1;
	    unsigned char BCLIF:1;
	    unsigned char EEIF:1;
	    unsigned char :1;
	    unsigned char CMIF:1;
	    unsigned char OSCFIF:1;
	} PIR2bits;
	typedef struct 
	{
	    unsigned char TMR1IE:1;
	    unsigned char TMR2IE:1;
	    unsigned char CCP1IE:1;
	    unsigned char SSPIE:1;
	    unsigned char TXIE:1;
	    unsigned char RCIE:1;
	    unsigned char ADIE:1;
	    unsigned char PSPIE:1;
	} PIE1bits;
	typedef struct
	{
	    unsigned char T0PS0:1;
	    unsigned char T0PS1:1;
	    unsigned char T0PS2:1;
	    unsigned char PSA:1;
	    unsigned char T0SE:1;
	    unsigned char T0CS:1;
	    unsigned char T08BIT:1;
	    unsigned char TMR0ON:1;
	} T0CONbits;
	typedef struct
	{
	    unsigned char TX9D:1;
	    unsigned char TRMT:1;
	    unsigned char BRGH:1;
	    unsigned char SENDB:1;
	    unsigned char SYNC:1;
	    unsigned char TXEN:1;
	    unsigned char TX9:1;
	    unsigned char CSRC:1;
	} TXSTAbits;
	typedef struct
	{
	    unsigned char RX9D:1;
	    unsigned char OERR:1;
	    unsigned char FERR:1;
	    unsigned char ADDEN:1;
	    unsigned char CREN:1;
	    unsigned char SREN:1;
	    unsigned char RX9:1;
	    unsigned char SPEN:1;
	} RCSTAbits;

	
	#define SSPSTATbits			(*((SSPSTATbits*)&SSPSTAT))
	#define INTCONbits			(*((INTCONbits*)&INTCON))
	#define INTCON2bits			(*((INTCON2bits*)&INTCON2))
	#define ADCON0bits			(*((ADCON0bits*)&ADCON0))
	#define ADCON2bits			(*((ADCON2bits*)&ADCON2))
	#define PIR1bits			(*((PIR1bits*)&PIR1))
	#define PIR2bits			(*((PIR2bits*)&PIR2))
	#define PIE1bits			(*((PIE1bits*)&PIE1))
	#define T0CONbits			(*((T0CONbits*)&T0CON))
	#define TXSTAbits			(*((TXSTAbits*)&TXSTA))
	#define RCSTAbits			(*((RCSTAbits*)&RCSTA))
	#define SSPCON1bits			(*((SSPCON1bits*)&SSPCON1))
	#define SSPCON2bits			(*((SSPCON2bits*)&SSPCON2))

	// I/O pins
	#define LED0_TRIS			(TRISA4)
	#define LED0_IO				(RA4)
	#define LED1_TRIS			(TRISA3)
	#define LED1_IO				(RA3)
	#define LED2_TRIS			(TRISA2)
	#define LED2_IO				(RA2)
	#define LED3_TRIS			(TRISA4)
	#define LED3_IO				(RA4)
	#define LED4_TRIS			(TRISA3)
	#define LED4_IO				(RA3)
	#define LED5_TRIS			(TRISA2)
	#define LED5_IO				(RA2)
	#define LED6_TRIS			(TRISA4)
	#define LED6_IO				(RA4)
	#define LED7_TRIS			(TRISA3)
	#define LED7_IO				(RA3)

	#define BUTTON0_TRIS		(TRISB5)
	#define	BUTTON0_IO			(RB5)
	#define BUTTON1_TRIS		(TRISB5)	// No Button1 on this board, remap to Button0
	#define	BUTTON1_IO			(RB5)
	#define BUTTON2_TRIS		(TRISB5)	// No Button2 on this board, remap to Button0
	#define	BUTTON2_IO			(RB5)
	#define BUTTON3_TRIS		(TRISB5)	// No Button3 on this board, remap to Button0
	#define	BUTTON3_IO			(RB5)

	// RTL8019AS I/O pins
	#define NIC_CTRL_TRIS       (TRISE)
	#define NIC_RESET_IO        (RE2)
	#define NIC_IOW_IO          (RE1)
	#define NIC_IOR_IO          (RE0)
	#define NIC_ADDR_IO         (PORTB)
	#define NIC_DATA_IO         (PORTD)

	// 24LC256 I/O pins
	#define EEPROM_SCL_TRIS		(TRISC3)
	#define EEPROM_SDA_TRIS		(TRISC4)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSPCON1)
	#define EEPROM_SPICON1bits	(SSPCON1bits)
	#define EEPROM_SPICON2		(SSPCON2)
	#define EEPROM_SPICON2bits	(SSPCON2bits)
	#define EEPROM_SPISTAT		(SSPSTAT)
	#define EEPROM_SPISTATbits	(SSPSTATbits)

	// LCD
	// LCD Module I/O pins
	typedef struct
	{
		unsigned char data : 4;	// Bits 0 through 3
		unsigned char : 4;		// Bits 4 through 7
	} LCD_DATA;
	#define LCD_DATA_TRIS		(((volatile LCD_DATA*)&TRISD)->data)
	#define LCD_DATA_IO			(((volatile LCD_DATA*)&LATD)->data)
	#define LCD_RD_WR_TRIS		(TRISD5)
	#define LCD_RD_WR_IO		(LATD5)
	#define LCD_RS_TRIS			(TRISD4)
	#define LCD_RS_IO			(LATD4)
	#define LCD_E_TRIS			(TRISA5)
	#define LCD_E_IO			(LATA5)

	// Do not use the DMA and other goodies that Microchip Ethernet modules have
	#define NON_MCHP_MAC

#elif defined(EXPLORER_16)
// Explorer 16 + Ethernet PICtail Plus

	#define LED0_TRIS			(TRISAbits.TRISA0)	// Ref D3
	#define LED0_IO				(PORTAbits.RA0)	
	#define LED1_TRIS			(TRISAbits.TRISA1)	// Ref D4
	#define LED1_IO				(PORTAbits.RA1)
	#define LED2_TRIS			(TRISAbits.TRISA2)	// Ref D5
	#define LED2_IO				(PORTAbits.RA2)
	#define LED3_TRIS			(TRISAbits.TRISA3)	// Ref D6
	#define LED3_IO				(PORTAbits.RA3)
	#define LED4_TRIS			(TRISAbits.TRISA4)	// Ref D7
	#define LED4_IO				(PORTAbits.RA4)
	#define LED5_TRIS			(TRISAbits.TRISA5)	// Ref D8
	#define LED5_IO				(PORTAbits.RA5)
	#define LED6_TRIS			(TRISAbits.TRISA6)	// Ref D9
	#define LED6_IO				(PORTAbits.RA6)
	#define LED7_TRIS			(TRISAbits.TRISA7)	// Ref D10	// Note: This is multiplexed with BUTTON1
	#define LED7_IO				(PORTAbits.RA7)
	#define LED_IO				(*((volatile unsigned char*)(&PORTA)))


	#define BUTTON0_TRIS		(TRISDbits.TRISD13)	// Ref S4
	#define	BUTTON0_IO			(PORTDbits.RD13)
	#define BUTTON1_TRIS		(TRISAbits.TRISA7)	// Ref S5	// Note: This is multiplexed with LED7
	#define	BUTTON1_IO			(PORTAbits.RA7)
	#define BUTTON2_TRIS		(TRISDbits.TRISD7)	// Ref S6
	#define	BUTTON2_IO			(PORTDbits.RD7)
	#define BUTTON3_TRIS		(TRISDbits.TRISD6)	// Ref S3
	#define	BUTTON3_IO			(PORTDbits.RD6)

	#define UARTTX_TRIS			(TRISFbits.TRISF5)
	#define UARTTX_IO			(PORTFbits.RF5)
	#define UARTRX_TRIS			(TRISFbits.TRISF4)
	#define UARTRX_IO			(PORTFbits.RF4)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(TRISDbits.TRISD15)	// Not connected by default
	#define ENC_RST_IO			(PORTDbits.RD15)
	#define ENC_CS_TRIS			(TRISDbits.TRISD14)
	#define ENC_CS_IO			(PORTDbits.RD14)
	#define ENC_SCK_TRIS		(TRISFbits.TRISF6)
	#define ENC_SDI_TRIS		(TRISFbits.TRISF7)
	#define ENC_SDO_TRIS		(TRISFbits.TRISF8)
	#define ENC_SPI_IF			(IFS0bits.SPI1IF)
	#define ENC_SSPBUF			(SPI1BUF)
	#define ENC_SPISTAT			(SPI1STAT)
	#define ENC_SPISTATbits		(SPI1STATbits)
	#define ENC_SPICON1			(SPI1CON1)
	#define ENC_SPICON1bits		(SPI1CON1bits)
	#define ENC_SPICON2			(SPI1CON2)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISDbits.TRISD12)
	#define EEPROM_CS_IO		(PORTDbits.RD12)
	#define EEPROM_SCK_TRIS		(TRISGbits.TRISG6)
	#define EEPROM_SDI_TRIS		(TRISGbits.TRISG7)
	#define EEPROM_SDO_TRIS		(TRISGbits.TRISG8)
	#define EEPROM_SPI_IF		(IFS2bits.SPI2IF)
	#define EEPROM_SSPBUF		(SPI2BUF)
	#define EEPROM_SPICON1		(SPI2CON1)
	#define EEPROM_SPICON1bits	(SPI2CON1bits)
	#define EEPROM_SPICON2		(SPI2CON2)
	#define EEPROM_SPISTAT		(SPI2STAT)
	#define EEPROM_SPISTATbits	(SPI2STATbits)

	// LCD Module I/O pins
	typedef struct
	{
		unsigned char data : 8;	// Bits 0 through 7
		unsigned char : 8;		// Bits 8 through 15
	} LCD_DATA;
	#define LCD_DATA_TRIS		(((LCD_DATA*)&TRISE)->data)
	#define LCD_DATA_IO			(((LCD_DATA*)&LATE)->data)
	#define LCD_RD_WR_TRIS		(TRISDbits.TRISD5)
	#define LCD_RD_WR_IO		(LATDbits.LATD5)
	#define LCD_RS_TRIS			(TRISBbits.TRISB15)
	#define LCD_RS_IO			(LATBbits.LATB15)
	#define LCD_E_TRIS			(TRISDbits.TRISD4)
	#define LCD_E_IO			(LATDbits.LATD4)


#elif defined(DSPICDEM11)
// dsPICDEM 1.1 Development Board + Ethernet PICtail airwired. There 
// is no PICtail header on this development board.  The following 
// airwires must be made:
// 1. dsPICDEM GND <-> PICtail GND (PICtail pin 27)
// 2. dsPICDEM Vdd <- PICtail VPIC (PICtail pin 25)
// 3. dsPICDEM RG2 -> PICtail ENC28J60 CS (PICtail pin 22)
// 4. dsPICDEM RF6 -> PICtail SCK (PICtail pin 11)
// 5. dsPICDEM RF7 <- PICtail SDI (PICtail pin 9)
// 6. dsPICDEM RF8 -> PICtail SDO (PICtail pin 7)
// 7. dsPICDEM RG3 -> PICtail 25LC256 CS (PICtail pin 20)

	#define LED0_TRIS			(TRISDbits.TRISD3)	// Ref LED4
	#define LED0_IO				(PORTDbits.RD3)	
	#define LED1_TRIS			(TRISDbits.TRISD2)	// Ref LED3
	#define LED1_IO				(PORTDbits.RD2)
	#define LED2_TRIS			(TRISDbits.TRISD1)	// Ref LED2
	#define LED2_IO				(PORTDbits.RD1)
	#define LED3_TRIS			(TRISDbits.TRISD0)	// Ref LED1
	#define LED3_IO				(PORTDbits.RD0)
	#define LED4_TRIS			(TRISDbits.TRISD3)	// No LED, Remapped to Ref LED4
	#define LED4_IO				(PORTDbits.RD3)	
	#define LED5_TRIS			(TRISDbits.TRISD2)	// No LED, Remapped to Ref LED3
	#define LED5_IO				(PORTDbits.RD2)
	#define LED6_TRIS			(TRISDbits.TRISD1)	// No LED, Remapped to Ref LED2
	#define LED6_IO				(PORTDbits.RD1)
	#define LED7_TRIS			(TRISDbits.TRISD0)	// No LED, Remapped to Ref LED1
	#define LED7_IO				(PORTDbits.RD0)

	#define BUTTON0_TRIS		(TRISAbits.TRISA15)	// Ref SW4
	#define	BUTTON0_IO			(PORTAbits.RA15)
	#define BUTTON1_TRIS		(TRISAbits.TRISA14)	// Ref SW3
	#define	BUTTON1_IO			(PORTAbits.RA14)
	#define BUTTON2_TRIS		(TRISAbits.TRISA13)	// Ref SW2
	#define	BUTTON2_IO			(PORTAbits.RA13)
	#define BUTTON3_TRIS		(TRISAbits.TRISA12)	// Ref SW1
	#define	BUTTON3_IO			(PORTAbits.RA12)

	#define UARTTX_TRIS			(TRISFbits.TRISF3)
	#define UARTTX_IO			(PORTFbits.RF3)
	#define UARTRX_TRIS			(TRISFbits.TRISF2)
	#define UARTRX_IO			(PORTFbits.RF2)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(0)	// Not connected
	#define ENC_RST_IO			(0)
	#define ENC_CS_TRIS			(TRISGbits.TRISG2)		// User must airwire this
	#define ENC_CS_IO			(PORTGbits.RG2)
	#define ENC_SCK_TRIS		(TRISFbits.TRISF6)		// User must airwire this
	#define ENC_SDI_TRIS		(TRISFbits.TRISF7)		// User must airwire this
	#define ENC_SDO_TRIS		(TRISFbits.TRISF8)		// User must airwire this
	#define ENC_SPI_IF			(IFS0bits.SPI1IF)
	#define ENC_SSPBUF			(SPI1BUF)
	#define ENC_SPICON1			(SPI1CON)
	#define ENC_SPICON1bits		(SPI1CONbits)
	#define ENC_SPICON2			(SPI1BUF)				// SPI1CON2 doesn't exist, remap to unimportant register
	#define ENC_SPISTAT			(SPI1STAT)
	#define ENC_SPISTATbits		(SPI1STATbits)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISGbits.TRISG3)	// User must airwire this
	#define EEPROM_CS_IO		(PORTGbits.RG3)
	#define EEPROM_SCK_TRIS		(TRISGbits.TRISG6)
	#define EEPROM_SDI_TRIS		(TRISGbits.TRISG7)
	#define EEPROM_SDO_TRIS		(TRISGbits.TRISG8)
	#define EEPROM_SPI_IF		(IFS0bits.SPI1IF)
	#define EEPROM_SSPBUF		(SPI1BUF)
	#define EEPROM_SPICON1		(SPI1CON)
	#define EEPROM_SPICON1bits	(SPI1CONbits)
	#define EEPROM_SPICON2		(SPI1BUF)			// SPI1CON2 doesn't exist, remap to unimportant register
	#define EEPROM_SPISTAT		(SPI1STAT)
	#define EEPROM_SPISTATbits	(SPI1STATbits)

	// SI3000 codec pins
	#define CODEC_RST_TRIS		(TRISFbits.TRISF6)
	#define CODEC_RST_IO		(PORTFbits.RF6)
	
	// PIC18F252 LCD Controller
	#define LCDCTRL_CS_TRIS		(TRISGbits.TRISG9)
	#define LCDCTRL_CS_IO		(PORTGbits.RG9)

#elif defined(PICDEMNET2)
// PICDEM.net 2 (PIC18F97J60 + ENC28J60)

	// I/O pins
	#define LED0_TRIS			(TRISJbits.TRISJ0)
	#define LED0_IO				(PORTJbits.RJ0)
	#define LED1_TRIS			(TRISJbits.TRISJ1)
	#define LED1_IO				(PORTJbits.RJ1)
	#define LED2_TRIS			(TRISJbits.TRISJ2)
	#define LED2_IO				(PORTJbits.RJ2)
	#define LED3_TRIS			(TRISJbits.TRISJ3)
	#define LED3_IO				(PORTJbits.RJ3)
	#define LED4_TRIS			(TRISJbits.TRISJ4)
	#define LED4_IO				(PORTJbits.RJ4)
	#define LED5_TRIS			(TRISJbits.TRISJ5)
	#define LED5_IO				(PORTJbits.RJ5)
	#define LED6_TRIS			(TRISJbits.TRISJ6)
	#define LED6_IO				(PORTJbits.RJ6)
	#define LED7_TRIS			(TRISJbits.TRISJ7)
	#define LED7_IO				(PORTJbits.RJ7)
	#define LED_IO				(*((volatile unsigned char*)(&PORTJ)))

	#define BUTTON0_TRIS		(TRISBbits.TRISB3)
	#define	BUTTON0_IO			(PORTBbits.RB3)
	#define BUTTON1_TRIS		(TRISBbits.TRISB2)
	#define	BUTTON1_IO			(PORTBbits.RB2)
	#define BUTTON2_TRIS		(TRISBbits.TRISB1)
	#define	BUTTON2_IO			(PORTBbits.RB1)
	#define BUTTON3_TRIS		(TRISBbits.TRISB0)
	#define	BUTTON3_IO			(PORTBbits.RB0)

	// ENC28J60 I/O pins
	#define ENC_RST_TRIS		(TRISDbits.TRISD2)	// Not connected by default
	#define ENC_RST_IO			(LATDbits.LATD2)
	#define ENC_CS_TRIS			(TRISDbits.TRISD3)
	#define ENC_CS_IO			(LATDbits.LATD3)
	#define ENC_SCK_TRIS		(TRISCbits.TRISC3)
	#define ENC_SDI_TRIS		(TRISCbits.TRISC4)
	#define ENC_SDO_TRIS		(TRISCbits.TRISC5)
	#define ENC_SPI_IF			(PIR1bits.SSPIF)
	#define ENC_SSPBUF			(SSP1BUF)
	#define ENC_SPISTAT			(SSP1STAT)
	#define ENC_SPISTATbits		(SSP1STATbits)
	#define ENC_SPICON1			(SSP1CON1)
	#define ENC_SPICON1bits		(SSP1CON1bits)
	#define ENC_SPICON2			(SSP1CON2)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISDbits.TRISD7)
	#define EEPROM_CS_IO		(LATDbits.LATD7)
	#define EEPROM_SCK_TRIS		(TRISCbits.TRISC3)
	#define EEPROM_SDI_TRIS		(TRISCbits.TRISC4)
	#define EEPROM_SDO_TRIS		(TRISCbits.TRISC5)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSP1CON1)
	#define EEPROM_SPICON1bits	(SSP1CON1bits)
	#define EEPROM_SPICON2		(SSP1CON2)
	#define EEPROM_SPISTAT		(SSP1STAT)
	#define EEPROM_SPISTATbits	(SSP1STATbits)

	#define LCD_DATA_TRIS		(TRISE)
	#define LCD_DATA_IO			(LATE)
	#define LCD_RD_WR_TRIS		(TRISHbits.TRISH1)
	#define LCD_RD_WR_IO		(LATHbits.LATH1)
	#define LCD_RS_TRIS			(TRISHbits.TRISH2)
	#define LCD_RS_IO			(LATHbits.LATH2)
	#define LCD_E_TRIS			(TRISHbits.TRISH0)
	#define LCD_E_IO			(LATHbits.LATH0)

#elif defined(PIC18F97J60_TEST_BOARD)
// PIC18F97J60 Test board for early Adopters and beta customers

	// I/O pins
	#define LED0_TRIS			(TRISDbits.TRISD7)
	#define LED0_IO				(PORTDbits.RD7)
	#define LED1_TRIS			(TRISDbits.TRISD6)
	#define LED1_IO				(PORTDbits.RD6)
	#define LED2_TRIS			(TRISDbits.TRISD5)
	#define LED2_IO				(PORTDbits.RD5)
	#define LED3_TRIS			(TRISDbits.TRISD4)
	#define LED3_IO				(PORTDbits.RD4)
	#define LED4_TRIS			(TRISDbits.TRISD3)
	#define LED4_IO				(PORTDbits.RD3)
	#define LED5_TRIS			(TRISDbits.TRISD2)
	#define LED5_IO				(PORTDbits.RD2)
	#define LED6_TRIS			(TRISDbits.TRISD1)
	#define LED6_IO				(PORTDbits.RD1)
	#define LED7_TRIS			(TRISDbits.TRISD0)
	#define LED7_IO				(PORTDbits.RD0)

	#define BUTTON0_TRIS		(TRISBbits.TRISB3)
	#define	BUTTON0_IO			(PORTBbits.RB3)
	#define BUTTON1_TRIS		(TRISBbits.TRISB2)
	#define	BUTTON1_IO			(PORTBbits.RB2)
	#define BUTTON2_TRIS		(TRISBbits.TRISB1)
	#define	BUTTON2_IO			(PORTBbits.RB1)
	#define BUTTON3_TRIS		(TRISBbits.TRISB0)
	#define	BUTTON3_IO			(PORTBbits.RB0)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISBbits.TRISB4)
	#define EEPROM_CS_IO		(LATBbits.LATB4)
	#define EEPROM_SCK_TRIS		(TRISCbits.TRISC3)
	#define EEPROM_SDI_TRIS		(TRISCbits.TRISC4)
	#define EEPROM_SDO_TRIS		(TRISCbits.TRISC5)
	#define EEPROM_SPI_IF		(PIR1bits.SSPIF)
	#define EEPROM_SSPBUF		(SSPBUF)
	#define EEPROM_SPICON1		(SSP1CON1)
	#define EEPROM_SPICON1bits	(SSP1CON1bits)
	#define EEPROM_SPICON2		(SSP1CON2)
	#define EEPROM_SPISTAT		(SSP1STAT)
	#define EEPROM_SPISTATbits	(SSP1STATbits)

#elif defined(EXPLORER16_RTL)
// Define your own board hardware profile here

	#define LED0_TRIS			(TRISAbits.TRISA0)	// Ref D3
	#define LED0_IO				(PORTAbits.RA0)	
	#define LED1_TRIS			(TRISAbits.TRISA1)	// Ref D4
	#define LED1_IO				(PORTAbits.RA1)
	#define LED2_TRIS			(TRISAbits.TRISA2)	// Ref D5
	#define LED2_IO				(PORTAbits.RA2)
	#define LED3_TRIS			(TRISAbits.TRISA3)	// Ref D6
	#define LED3_IO				(PORTAbits.RA3)
	#define LED4_TRIS			(TRISAbits.TRISA4)	// Ref D7
	#define LED4_IO				(PORTAbits.RA4)
	#define LED5_TRIS			(TRISAbits.TRISA5)	// Ref D8
	#define LED5_IO				(PORTAbits.RA5)
	#define LED6_TRIS			(TRISAbits.TRISA6)	// Ref D9
	#define LED6_IO				(PORTAbits.RA6)
	#define LED7_TRIS			(TRISAbits.TRISA7)	// Ref D10	// Note: This is multiplexed with BUTTON1
	#define LED7_IO				(PORTAbits.RA7)
	#define LED_IO				(*((volatile unsigned char*)(&PORTA)))

	#define BUTTON0_TRIS		(TRISDbits.TRISD13)	// Ref S4
	#define	BUTTON0_IO			(PORTDbits.RD13)
	#define BUTTON1_TRIS		(TRISAbits.TRISA7)	// Ref S5	// Note: This is multiplexed with LED7
	#define	BUTTON1_IO			(PORTAbits.RA7)
	#define BUTTON2_TRIS		(TRISDbits.TRISD7)	// Ref S6
	#define	BUTTON2_IO			(PORTDbits.RD7)
	#define BUTTON3_TRIS		(TRISDbits.TRISD6)	// Ref S3
	#define	BUTTON3_IO			(PORTDbits.RD6)

	#define UARTTX_TRIS			(TRISFbits.TRISF5)
	#define UARTTX_IO			(PORTFbits.RF5)
	#define UARTRX_TRIS			(TRISFbits.TRISF4)
	#define UARTRX_IO			(PORTFbits.RF4)

	// RTL8019AS I/O pins
	#define NIC_CTRL_TRIS       (TRISF)
	#define NIC_RESET_IO        (PORTFbits.RF2)
	#define NIC_IOW_IO          (PORTFbits.RF1)
	#define NIC_IOR_IO          (PORTFbits.RF0)
	#define NIC_ADDR_IO         (PORTB)
	#define NIC_ADDR_TRIS	    (TRISB)
	#define NIC_DATA_IO         (PORTE)
    #define NIC_DATA_TRIS       (TRISE)

	// 25LC256 I/O pins
	#define EEPROM_CS_TRIS		(TRISDbits.TRISD12)
	#define EEPROM_CS_IO		(PORTDbits.RD12)
	#define EEPROM_SCK_TRIS		(TRISGbits.TRISG6)
	#define EEPROM_SDI_TRIS		(TRISGbits.TRISG7)
	#define EEPROM_SDO_TRIS		(TRISGbits.TRISG8)
	#define EEPROM_SPI_IF		(IFS2bits.SPI2IF)
	#define EEPROM_SSPBUF		(SPI2BUF)
	#define EEPROM_SPICON1		(SPI2CON1)
	#define EEPROM_SPICON1bits	(SPI2CON1bits)
	#define EEPROM_SPICON2		(SPI2CON2)
	#define EEPROM_SPISTAT		(SPI2STAT)
	#define EEPROM_SPISTATbits	(SPI2STATbits)

	// LCD Module I/O pins
	typedef struct
	{
		unsigned char data : 8;	// Bits 0 through 7
		unsigned char : 8;		// Bits 8 through 15
	} LCD_DATA;
	#define LCD_DATA_TRIS		(((LCD_DATA*)&TRISE)->data)
	#define LCD_DATA_IO			(((LCD_DATA*)&LATE)->data)
	#define LCD_RD_WR_TRIS		(TRISDbits.TRISD5)
	#define LCD_RD_WR_IO		(LATDbits.LATD5)
	#define LCD_RS_TRIS			(TRISBbits.TRISB15)
	#define LCD_RS_IO			(LATBbits.LATB15)
	#define LCD_E_TRIS			(TRISDbits.TRISD4)
	#define LCD_E_IO			(LATDbits.LATD4)

	// Do not use the DMA and other goodies that Microchip Ethernet modules have
	#define NON_MCHP_MAC

#else
	#error "Hardware profile not defined.  See available profiles in Compiler.h.  Add the appropriate macro definition to your project [ex: Project -> Build Options... -> Project -> MPLAB C18 -> Add (macro) -> HPC_EXPLORER]"
#endif

#if defined(DEBUG)
	#define DebugPrint(a)		{putrsUART(a);}
#else
	#define DebugPrint(a)		{}
#endif


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __C30__
	#include <stdlib.h>
#endif

#if defined(__18CXX) && !defined(HI_TECH_C)
    #define ROM                 	rom
	#define strcpypgm2ram(a, b)		strcpypgm2ram(a,(far rom char*)b)
#elif defined(__18CXX) && defined(HI_TECH_C)
    #define ROM                 	const
	#define rom
    #define Nop()               	asm("NOP");
    #define Reset()					asm("RESET");
	#define memcmppgm2ram(a,b,c)	memcmp(a,b,c)
	#define memcpypgm2ram(a,b,c)	memcpy(a,b,c)
	#define strcpypgm2ram(a, b)		strcpy(a,b)
	#define strcpypgm2ram(a, b)		strcpy(a,b)
#endif

#if defined(__18CXX)
	#define	__attribute__(a)
	#define BusyUART()				BusyUSART()
	#define CloseUART()				CloseUSART()
	#define ConfigIntUART(a)		ConfigIntUSART(a)
	#define DataRdyUART()			DataRdyUSART()
	#define OpenUART(a,b,c)			OpenUSART(a,b,c)
	#define ReadUART()				ReadUSART()
	#define WriteUART(a)			WriteUSART(a)
	#define getsUART(a,b,c)			getsUSART(b,a)
	#define putsUART(a)				putsUSART(a)
	#define getcUART()				ReadUSART()
	#define putcUART(a)				WriteUSART(a)
	#define putrsUART(a)			putrsUSART((far rom char*)a)

	#if defined(__18F8720) || defined(__18F87J10) || defined(__18F97J60)
	    #define TXSTAbits       	TXSTA1bits
	    #define TXREG           	TXREG1
	    #define TXSTA           	TXSTA1
	    #define RCSTA           	RCSTA1
	    #define SPBRG           	SPBRG1
	    #define RCREG           	RCREG1
		#define SPICON				SSP1CON1
		#define SPISTATbits			SPI1STATbits
	#endif

#elif defined(__C30__)
    #define ROM						const

	#define BusyUART()				BusyUART2()
	#define CloseUART()				CloseUART2()
	#define ConfigIntUART(a)		ConfigIntUART2(a)
	#define DataRdyUART()			DataRdyUART2()
	#define OpenUART(a,b,c)			OpenUART2(a,b,c)
	#define ReadUART()				ReadUART2()
	#define WriteUART(a)			WriteUART2(a)
	#define getsUART(a,b,c)			getsUART2(a,b,c)
	#define putsUART(a)				putsUART2((unsigned int *)a)
	#define getcUART()				getcUART2()
	#define putcUART(a)				WriteUART2(a)
	#define putrsUART(a)			putsUART2((unsigned int *)a)

	#define memcmppgm2ram(a,b,c)	memcmp(a,b,c)
	#define memcpypgm2ram(a,b,c)	memcpy(a,b,c)
	#define strcpypgm2ram(a, b)		strcpy(a,b)

	#define Reset()					asm("reset")

	#if defined(__dsPIC33F__) || defined(__PIC24H__)
		#define AD1PCFGbits			AD1PCFGLbits
		#define AD1CHS				AD1CHS0
	#elif defined(__dsPIC30F__)
		#define ADC1BUF0			ADCBUF0
		#define AD1CHS				ADCHS
		#define	AD1CON1				ADCON1
		#define AD1CON2				ADCON2
		#define AD1CON3				ADCON3
		#define AD1PCFGbits			ADPCFGbits
		#define AD1CSSL				ADCSSL
		#define AD1IF				ADIF
		#define AD1IE				ADIE
		#define _ADC1Interrupt		_ADCInterrupt
	#endif
#endif

// Various compilation warnings
#if defined(__18F97J60) && !(defined(PICDEMNET2) || defined(PIC18F97J60_TEST_BOARD)) || \
	(defined(__18F18F8722) || defined(__18F87J10)) && !defined(HPC_EXPLORER) || \
	(defined(__PIC24F__) || defined(__PIC24H__) || defined(__dsPIC33F__)) && !defined(PICDEMNET) && !defined(EXPLORER_16) && !defined(EXPLORER16_RTL) || \
	defined(__dsPIC30F__) && !defined(DSPICDEM11)
	#error "Warning: The board profile may not be configured correctly."
	#error
	#error "Make sure that a proper board profile macro (HPC_EXPLORER, "
	#error "EXPLORER_16, PICDEMNET2, DSPICDEM11, etc) is defined in your "
	#error "project settings (Project -> Build Options... -> Project -> "
	#error "MPLAB Cxx -> Add (macro)"
#endif


#endif
