/*********************************************************************
 *
 *     UART access routines for C18 and C30
 *
 *********************************************************************
 * FileName:        UART.h
 * Processor:       PIC18, PIC24F/H, dsPIC30F, dsPIC33F
 * Complier:        Microchip C18 v3.03 or higher
 * Complier:        Microchip C30 v2.01 or higher
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
 * Author               Date   		Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Howard Schlunder		6/16/06		Original
********************************************************************/
#ifndef __UART_H
#define __UART_H

#include "..\Include\Compiler.h"


#if defined(__dsPIC33F__) || defined(__dsPIC30F__) || defined(__PIC24H__) || defined(__PIC24F__)

#include <uart.h>

void putsUART2(unsigned int *buffer);
unsigned int getsUART2(unsigned int length,unsigned int *buffer,
                       unsigned int uart_data_wait);
char DataRdyUART2(void);
char BusyUART2(void);
unsigned int ReadUART2(void);
void WriteUART2(unsigned int data);

#elif defined(__18CXX)
//
// PIC18
//

char BusyUSART(void);
void CloseUSART(void);
char DataRdyUSART(void);
char ReadUSART(void);
void WriteUSART(char data);
void getsUSART(char *buffer, unsigned char len);
void putsUSART(char *data);
void putrsUSART(const rom char *data);

#endif

#endif
