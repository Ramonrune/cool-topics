/*****************************************************************************
*
* Atmel Corporation
*
* File              : LCD_main.c
* Compiler          : GCC
* Revision          : $Revision: 1.1 $
* Date              : $Date: 28. april 2004 15:17:02 $
* Updated by        : $Author: ltwa/JKJ $
*
* Support mail      : avr@atmel.com
*
* Supported devices : ATmega128
*
* AppNote           : AVR241: Direct driving of LCD display using general IO
*
* Description       : The file contains an example program using the LCD driver
*                     functions provided with this application note. The 
*                     program drives a 2x7 segment LCD display using general
*                     IO.  
*
****************************************************************************/

//Include definition 
#include <avr/io.h>
#include <avr/interrupt.h>
#include "LCD_drive.h"



int main(void)
{
    TCCR0 = (1 << CS00) | (1 << CS01) | (1 << CS02) | (1 << WGM01);
    // Clear TIMER0 on compare match, CK/1024
    OCR0 = 17;
    MCUCR = (1 << SE);   // TCNT0 Compare Match IRQ app. 60 Hz using 1MHz clock
    TIMSK = (1 << OCIE0);
    DDRE = 0xFF;
    DDRD = 0xFF;
    LCD_print(1, 'A');         // Will print "A" to digit 1, function returns 1
    LCD_print(2, 'B');         // Will print "B" to digit 1, function returns 1
    sei();
    for(;;);
}

ISR(TIMER0_COMP_vect)
{   
	LCD_update();
}


/******************************************************************************
* Examples of calling the LCD_print() function
******************************************************************************/
    //LCD_print(2, '3' | (1 << 7) ); // Prints "3." to digit 2, function returns 1
    //LCD_print(2, '3');             // Prints "3" to digit 2, function returns 1
    
    //LCD_print(1, 'D' | (1 << 7) );
    /* Failure! Will not print to display.
       Function returns 0 due to atempt 
       setting dot on digit 1 */
       
   //LCD_print(1, 'H');
   /* Failure! Will not write to display.
      Function resturns 0 due to input argument
      'H' out of range*/
      
   //LCD_print(0, 'A');
   /* Failure! Will not write to display. 
      Function returns 0 due to input argument 
      out of range */
      
/*******************************************************************************/
