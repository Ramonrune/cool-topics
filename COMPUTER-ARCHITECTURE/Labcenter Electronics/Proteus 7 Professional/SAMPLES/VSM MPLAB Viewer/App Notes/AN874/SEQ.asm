;******************************************************************************
;* Software License Agreement                                                 *
;* The software supplied herewith by Microchip Technology Incorporated        *
;* (the "Company") is intended and supplied to you, the Company's             *
;* customer, for use solely and exclusively on Microchip products.            *
;*                                                                            *
;* The software is owned by the Company and/or its supplier, and is           *
;* protected under applicable copyright laws. All rights are reserved.        *
;* Any use in violation of the foregoing restrictions may subject the         *
;* user to criminal sanctions under applicable laws, as well as to            *
;* civil liability for the breach of the terms and conditions of this         *
;* license.                                                                   *
;*                                                                            *
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,          *
;* WHETHER EXPRESS, IMPLIED OR STATU-TORY, INCLUDING, BUT NOT LIMITED         *
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                *
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,          *
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR                 *
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                          *
;*                                                                            *
;******************************************************************************
;*                                                                            *
;* data storage format                                                        *
;*                                                                            *
;* Address	Value                                                         *
;*  0x00	Default intensity 00-3F                                       *
;*  0x01	Default mode 1-5                                              *
;*  0x02	Number of modes 1-5                                           *
;*  0x03	Start address of mode 2                                       *
;*  0x04	Start address of mode 3                                       *
;*  0x05	Start address of mode 4                                       *
;*  0x06	Start address of mode 5                                       *
;* 0x07-0x7F	sequence commands                                             *
;******************************************************************************

;***** INITIALIZE EEPROM LOCATIONS

	ORG	0x2100
	DE	0x00, 0x01, 0x01, 0x07, 0x07, 0x07, 0x07, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
	DE	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0
