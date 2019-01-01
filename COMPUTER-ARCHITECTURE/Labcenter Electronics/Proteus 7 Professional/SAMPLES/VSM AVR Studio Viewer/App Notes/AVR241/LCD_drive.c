/*****************************************************************************
*
* Atmel Corporation
*
* File              : LCD_drive.c
* Compiler          : GCC
* Revision          : $Revision: 1.1 $
* Date              : $Date: 28. april 2004 15:17:00 $
* Updated by        : $Author: ltwa / JKJ$
*
* Support mail      : avr@atmel.com
*
* Supported devices : ATmega128
*
* AppNote           : AVR241: Direct driving of LCD display using general IO
*
* Description       : The file contains LCD driver functions for driving a 2x7 
                      segment LCD display using general IO. The functions may be 
                      used with any AVR microcontroller having sufficient number 
                      of IO.
*
******************************************************************************/

#include <avr/io.h>
#include <avr/interrupt.h>
#include "LCD_drive.h"

/******************************************************************************
Global variables      
******************************************************************************/        

struct LCDtype
       { 
            char digit1;
            char digit2;
       } LCD;                       // Global variables for printing to display
        
/******************************************************************************
Function Print_lcd()      
******************************************************************************/        

char LCD_print(char digit, char ASCII_data){
    
    char    Data_var;
    
    /* Input argument test. Checks if input argument Digit is outside the range 
       [1,2] and if "dot-segment" is tempted to be turned on when writing to 
       digit 1. Returns 0 (failure) if any of these conditions are true. 
    */    
       
    if( !(digit == 1 || digit == 2) || 
    ( (ASCII_data & (1 << 7)) && digit == 1 )  )return 0; 
    else{
        switch(ASCII_data & ~(1 << 7)){ //Find output pattern according to input
            case    '0':    Data_var = 0x3F;
                            break;  
            case    '1':    Data_var = 0x06;
                            break;
            case    '2':    Data_var = 0x5b;  
                            break;
            case    '3':    Data_var = 0x4f;
                            break;
            case    '4':    Data_var = 0x66;  
                            break;
            case    '5':    Data_var = 0x6d;
                            break;
            case    '6':    Data_var = 0x7d;  
                            break;
            case    '7':    Data_var = 0x07;
                            break;
            case    '8':    Data_var = 0x7f;  
                            break;
            case    '9':    Data_var = 0x6f;
                            break;
            case    'A':    Data_var = 0x77;
                            break;
            case    'B':    Data_var = 0x7C;  
                            break;
            case    'C':    Data_var = 0x39;
                            break;
            case    'D':    Data_var = 0x5e;  
                            break;
            case    'E':    Data_var = 0x79;
                            break;
            case    'F':    Data_var = 0x71;
                            break;
            case    ' ':    Data_var = 0;
                            break;
            default:        return 0;            /* Returns 0 if input argument 
                                                  ASCII_data is out of range */                  
        }
    }    
    if(digit == 1){
        LCD.digit1 = Data_var;             //Updates global register LCD.digit1  
    }    
    else{ 
        LCD.digit2 = Data_var | (ASCII_data & (1 << 7));
                    //Updates global register LCD.digit2 and adds "dot"-segment
    }
    return 1;                             //Returns 1 if input arguments are OK
}

/******************************************************************************
Function LCD_update()      
******************************************************************************/        

void LCD_update(void){
    static char sequence=0;          
        if(!sequence){                 //Enters routine for first half of frame
			PORTD = LCD.digit1 & 0x7f;           // Sets COM bit
            PORTE = LCD.digit2;                    //Writes outputs to segments
            sequence = 1;               
        }
        else{                         //Enters routine for second half of frame
            PORTD = PORTD ^ 0Xff;           // Inverts levels on segement lines
            PORTE = PORTE ^ 0Xff;            //Inverts levels on segement lines
            sequence=0; 
        }

}
