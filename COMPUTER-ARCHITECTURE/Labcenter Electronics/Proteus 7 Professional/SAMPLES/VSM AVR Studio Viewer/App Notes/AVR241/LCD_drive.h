/*****************************************************************************
*
* Atmel Corporation
*
* File              : LCD_drive.h
* Compiler          : IAR EWAAVR 2.28a/3.10a
* Revision          : $Revision: 1.1 $
* Date              : $Date: 28. april 2004 15:17:02 $
* Updated by        : $Author: ltwa $
*
* Support mail      : avr@atmel.com
*
* Supported devices : ATmega16 
*
* AppNote           : AVR241: Direct driving of LCD display using general IO
*
* Description       : The file contains prototypes for LCD driver functions. 
*                     The function bodies are contained in the file LCD_drive.c.  
*
******************************************************************************/
        
/******************************************************************************
Function prototypes     
******************************************************************************/        

char LCD_print(char digit, char ASCII_data);
void LCD_update(void);

/*****************************************************************************/
