/********************************************************************
********************************************************************
*****                                                          *****
*****        L A B C E N T E R    E L E C T R O N I C S        *****
*****                                                          *****
*****       LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****
*****                                                          *****
*****             PIC16877 with LCD in 4-bit mode              *****
*****                                                          *****
********************************************************************
********************************************************************/

#include "io16F877.h"
#include "lcd4bit.h"

CHAR text[] = {'4','-','B','i','t',' ','L','C','D',' ','M','o','d','e', ' ','\n'};

VOID main(VOID)
// Program Control Function.
 { CHAR *textptr = text;
   
   lcd_init();                             // Initialise the LCD Display 
   for (;;)                                // Loop Forever. 
    { textptr = text;
      while (*textptr != '\n')             // Write the String.
       { wrdata(*textptr++);
         pause(2000);
       }
      pause(5000);
      eat();                               // Show and Animate the pacman. 
      pause(5000);
    }  
 }

VOID eat ()
// Show the pacman and 'eat' the text.
 { INT count = MAX_DISPLAY_CHAR-1, eatflag = 0 , tmp;
   while (count >= 0)
    { TRISC = PORTC = 0xFF;
      wrcmd(LCD_SETDDADDR + count);                       // Work from right to left.        
      eatflag ? wrdata(0x00):  wrdata(0x01);              // Toggle the custom graphics between mouth open and mouth shut. 
      eatflag ^= 1;                                       
      
      for (tmp = count; tmp <=MAX_DISPLAY_CHAR; ++tmp)    // Anything to the right of pacman is wiped.
         wrdata(' ');

      count--;                                            // Decrement the count (moving us 1 to the left).                
      pause(4000);
    }
   clearscreen();                                         // Clear the final pacman graphic when we are done.
 }
 
 VOID pause(INT num)
 // Utility routine to pause for
 // a period of time.
  { while(num--)
     {/*do nothing */
     }
  } 
