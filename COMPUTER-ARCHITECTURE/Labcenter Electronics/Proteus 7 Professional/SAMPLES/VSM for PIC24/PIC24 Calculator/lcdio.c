/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                    PIC PIC 24FJ64GA006 LCD Driver           ****
*****                                                             ****
**********************************************************************
*********************************************************************/

#include "p24FJ64GA006.h"
#include "calc.h"

VOID lcd_init ()
// Initialise the LCD Display. 
 { PORTD = 0;
   TRISD = 0; 
   wrcmd(0x30);                  // 8-bit mode - 1 line.
   wrcmd(LCD_SETVISIBLE+0x04);   // Display only - no cursors.
   wrcmd(LCD_SETMODE+0x03);      // Automatic Increment - Display shift left.
   wrcmd(LCD_SETDDADDR+0x0F);    // Initial Position far right.
 }

VOID clearscreen ()
// Clear the LCD Screen and reset
// initial position.
 { wrcmd(LCD_CLS);
   wrcmd(LCD_SETDDADDR+0x0F);
 }

/***** Utility Functions *****/

VOID wrcmd (BYTE cmdcode)
// Write a command to the LCD display.
 { TRISD = 0x0000; 
   PORTD = LCD_CMD_WR | cmdcode;

   // Toggle Pin 'E' to send the command.
   PORTD |= E_PIN_MASK;
   nop();
   PORTD &= ~E_PIN_MASK;
   
   lcd_wait();
 }
     
VOID wrdata (BYTE data)
// Write a Character to the LCD Display. 
 { TRISD = 0x0000;
   PORTD = LCD_DATA_WR | data;

   // Toggle Pin 'E' to send the command.
   PORTD |= E_PIN_MASK;
   nop(); 
   nop();
   nop();
   nop();
   PORTD &= ~E_PIN_MASK;
   
   lcd_wait();
 }

VOID lcd_wait ()
// Wait for the LCD busy flag to clear. 
 { BYTE status;
   TRISD |= 0x00FF;
   PORTD = LCD_BUSY_RD;
   do
    { PORTD |= E_PIN_MASK;
	   nop(); 
	   nop();
	   nop();
	   nop();
      status = PORTD;
      PORTD &= ~E_PIN_MASK;
    } while (status & 0x80);
 }


