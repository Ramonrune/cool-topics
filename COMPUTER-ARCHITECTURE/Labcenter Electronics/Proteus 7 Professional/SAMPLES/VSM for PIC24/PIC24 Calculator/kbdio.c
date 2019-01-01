/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                  PIC 24FJ64GA006 Keypad Scanner             ****
*****                                                             ****
**********************************************************************
*********************************************************************/

// Rows are connected to Port B 
// Columns are connected to Port D with external pull-up resistors.

#include "p24FJ64GA006.h"
#include "calc.h"

CHAR keycodes[16] = {'7','8','9','/','4','5','6','*','1','2','3','-','.','0','=','+'};

CHAR keypadread()
// Find a key, wait for it to be released and return.
 { CHAR key = scankeypad();
   if (key)
      while (scankeypad() != 0)
         /* Nothing */  ;  
   return key;
 } 

CHAR scankeypad()
// Scan the keypad for a keypress.
// Return 0 for no press or the char pressed.
 { INT8 row,col,tmp;
   CHAR key=0;
	INT wait;


   // Initialise Port Dfor input, and PORTC for output   
   TRISG = 0xFFFF;
   TRISD = 0x0000;
   TRISB = 0;

   for (row=0; row < KEYP_NUM_ROWS; row++)
    { // Drive appropriate row low and read columns:
      PORTD = (~(1 << row)) & 0xFF;
      for (wait=0; wait<100; ++wait)
         ;
      tmp = (PORTG & G_MASK) >> G_SHIFT;
    
      // See if any column is active (low):
      for (col=0; col<KEYP_NUM_COLS; ++col)
         if ((tmp & (1<<col)) == 0)
          { INT idx = (row*KEYP_NUM_COLS) + col;
            key = keycodes[idx]; 
            PORTB = idx;
            goto DONE;
          }

    }
   DONE:

   // Disable Port Drive and return.
   PORTD = 0x00FF;
   TRISD = 0x00FF;
   return key;
 }



