/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                    PIC 18F452 LCD Driver                    ****
*****                                                             ****
**********************************************************************
*********************************************************************/

#include "calc.h"
#include "pic18.h"

VOID lcd_init ()
// Initialise the LCD Display. 
 { PORTA = TRISA = 0; 
   TRISB = PORTB = 0xFF;
   ADCON1 = 7;
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
 { TRISB = 0;
   PORTB = cmdcode;

   // Write to PORTB to latch data into the display.
   // Toggle Pin 'E' to send the command.
   PORTA  = LCD_CMD_WR;
   PORTA |= E_PIN_MASK;
   asm("NOP");
   PORTA &= ~E_PIN_MASK;
   
   lcd_wait();
 }
     
VOID wrdata (CHAR data)
// Write a Character to the LCD Display. 
 { TRISB = 0;
   PORTB = data;
   
   PORTA = LCD_DATA_WR;
   PORTA |= E_PIN_MASK;
   asm("NOP");
   PORTA &= ~E_PIN_MASK;
   
   lcd_wait();
 }

VOID lcd_wait ()
// Wait for the LCD busy flag to clear. 
 { BYTE status;
   TRISB = 0xFF;
   
   PORTA = LCD_BUSY_RD;
   do
    { PORTA |= E_PIN_MASK;
      asm("NOP");
      status = PORTB;
      PORTA &= ~E_PIN_MASK;
    } while (status & 0x80);
 }


