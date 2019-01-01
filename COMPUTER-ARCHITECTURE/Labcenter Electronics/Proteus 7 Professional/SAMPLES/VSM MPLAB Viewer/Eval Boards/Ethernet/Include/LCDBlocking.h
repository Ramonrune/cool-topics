/*********************************************************************
 *
 *   LCD Access Routines header
 *
 *********************************************************************
 * FileName:        LCDBlocking.h
 * Dependencies:    None
 * Processor:       PIC24F
 * Complier:        MCC30 v2.01 or higher
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
 * Howard Schlunder     4/03/06		Original 
 ********************************************************************/
#ifndef __LCDBLOCKING_H
#define __LCDBLOCKING_H

// Do not include this source file if there is no LCD on the 
// target board
#ifdef USE_LCD


extern BYTE LCDText[16*2+1];
void LCDInit(void);
void LCDUpdate(void);
void LCDErase(void);

#endif
#endif

