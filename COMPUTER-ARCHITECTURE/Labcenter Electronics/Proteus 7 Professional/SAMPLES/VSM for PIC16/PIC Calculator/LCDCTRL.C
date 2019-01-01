/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                    PIC 16F87X LCD Driver                     ****
*****                                                             ****
**********************************************************************
*********************************************************************/

#include "calc.h"
#include "io16F876.h"

VOID lcd_init ()
// Initialise the LCD Display. 
 { PORTB = TRISB = 0; 
   TRISC = PORTC = 0xFF;
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

VOID wrcmd (CHAR cmdcode)
// Write a command to the LCD display.
 { TRISC = 0;
   PORTC = cmdcode;

   // Write to PORTB to latch data into the display.
   // Toggle Pin 'E' to send the command.
   PORTB  = LCD_CMD_WR;
   PORTB |= E_PIN_MASK;
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
   
   lcd_wait();
 }
     
VOID wrdata (CHAR data)
// Write a Character to the LCD Display. 
 { TRISC = 0;
   PORTC = data;
   
   PORTB = LCD_DATA_WR;
   PORTB |= E_PIN_MASK;
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
   
   lcd_wait();
 }

VOID lcd_wait ()
// Wait for the LCD busy flag to clear. 
 { BYTE status;
   TRISC = 0xFF;
   
   PORTB = LCD_BUSY_RD;
   do
    { PORTB |= E_PIN_MASK;
      asm("NOP");
      status = PORTC;
      PORTB &= ~E_PIN_MASK;
    } while (status & 0x80);
 }


