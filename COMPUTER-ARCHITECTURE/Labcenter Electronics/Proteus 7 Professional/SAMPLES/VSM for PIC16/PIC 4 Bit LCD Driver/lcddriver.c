/*******************************************************************
********************************************************************
********************************************************************
*****                                                          *****
*****        L A B C E N T E R    E L E C T R O N I C S        *****
*****                                                          *****
*****       LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****
*****                                                          *****
*****          PIC1687* Driver for LCD in 4-bit mode           *****
*****                                                          *****
********************************************************************
********************************************************************/
// These driver routines implement the functionality necessary to drive
// a HD44780 controlled Alphameric LCD in 4-bit mode.
// PORT C pins 4-7 are used for data transmission and PORT B pins 0-2 are used 
// for command control.

// The Custom Graphic characters are written in 8-bytes blocks to the CGRAM. Subsequent
// to writing they are accessed via an index in DDRAM - that is, the custom graphic located
// at CGRAM address 40h-47h is accessed by writing to character font location 0x00 in DDRAM,
// the custom graphic located at 48-4F is accessed by writing to character font location 0x01
// in DDRAM and so on.

#include "lcd4bit.h"
#include "io16F877.h"

BYTE pacmanopen[] = {0x0E,0x07,0x03,0x01,0x03,0x07,0x0E,0x00,'\n'}; 
BYTE pacmanshut[] = {0x00,0x0F,0x1F,0x01,0x1F,0x0F,0x00,0x00,'\n'};

VOID lcd_init ()
// Initialise the LCD Display. 
 { TRISC = PORTC = 0xFF;
   wrcmd(LCD_SETFUNCTION);                    // 4-bit mode - 1 line - 5x7 font. 
   wrcmd(LCD_SETVISIBLE+0x04);                // Display no cursor - no blink.
   wrcmd(LCD_SETMODE+0x02);                   // Automatic Increment - No Display shift.
   
   // Write Custom Character to CG RAM.
   wrcgchr(pacmanopen, 0);                    // Offset 0 - 40h-47h in CGRAM.
   wrcgchr(pacmanshut, 8);                    // Offset 8 - 48h-4Fh in CGRAM.
   
   wrcmd(LCD_SETDDADDR);                      // Address DDRAM with 0 offset 80h.
 }
 
VOID clearscreen ()
// Clear the LCD Screen and reset
// initial position.
 { wrcmd(LCD_CLS);
   wrcmd(LCD_SETDDADDR+0x00);
 }

VOID wrcmd (CHAR cmdcode)
// Write a command to the LCD display.
// In 4-bit mode we send the MSN first and then
// the LSN. We then call the wait routine to hold
// until the busy flag is cleared.
 { TRISC = 0;
   PORTC = (cmdcode & 0xF0);                  // Get the most significant nibble first.
   PORTB = TRISB = 0; 
   PORTB  = LCD_CMD_WR;                       // Specify a command write operation.
   PORTB |= E_PIN_MASK;                       // Toggle the 'E' pin to send the command.
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
 
   TRISC = 0;
   PORTC = (cmdcode << 4);                     // Repeat for least significant nibble.
   PORTB  = LCD_CMD_WR;
   PORTB |= E_PIN_MASK;
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
  
   lcd_wait();                                 // Call the wait routine.
 }
     
VOID wrdata (CHAR data)
// Write a Character to the LCD Display. 
// In 4-bit mode we send the MSN first and then
// the LSN. We then call the wait routine to hold
// until the busy flag is cleared.
 { TRISC = 0;
   PORTC = data & 0xF0;                         // Get the most significant nibble first. 
   PORTB = LCD_DATA_WR;                         // Specify a data write operation.
   PORTB |= E_PIN_MASK;                         // Toggle the 'E' pin to send the command.
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
   
   TRISC = 0;
   PORTC = (data << 4);                         // Repeat for least significant nibble.
   PORTB = LCD_DATA_WR;
   PORTB |= E_PIN_MASK;
   asm("NOP");
   PORTB &= ~E_PIN_MASK;
  
   lcd_wait();                                  // Call the wait routine.
 }

VOID wrcgchr(BYTE *arrayptr, INT offset)
// Subroutine to write a custom graphic character
// into CGRAM. We take a pointer to the array of bytes
// and an offset into CGRAM at which to place the character.
 { TRISC = PORTC = 0xFF;
   wrcmd(LCD_SETCGADDR + offset);               // Set the CG RAM address.
    
   while (*arrayptr != '\n') 
    { wrdata (*arrayptr++);
    }
 }

VOID lcd_wait ()
// Wait for the LCD busy flag to clear. 
// Crucially in 4-bit mode we must perform 2 read operations
// to retrieve both the high and the low nibble of the return
// byte. We then amalgamate the two nibbles and test the busy flag.
 { BYTE lownibble = 0, highnibble = 0,status = 0;
   do
    { TRISC = 0xFF;                 
      PORTB = LCD_BUSY_RD;              
      PORTB |= E_PIN_MASK;
      asm("NOP");
      highnibble = PORTC & 0xF0;                // read the high nibble.
      PORTB &= ~E_PIN_MASK;

      PORTB = TRISB = 0;                        // reset.
      TRISC = 0xFF; 
      PORTB = LCD_BUSY_RD;          
      PORTB |= E_PIN_MASK;
      asm("NOP");
      lownibble = (PORTC & 0xF0) >> 4;          // read the low nibble. 
      PORTB &= ~E_PIN_MASK;
      status = highnibble + lownibble;          // combine to form busy status and ddaddress.
    } while (status & 0x80);                    // test busy flag.
 }

