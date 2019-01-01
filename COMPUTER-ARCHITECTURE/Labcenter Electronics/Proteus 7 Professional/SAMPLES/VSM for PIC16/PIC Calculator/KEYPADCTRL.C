/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                  PIC 16F87X Keypad Scanner                  ****
*****                                                             ****
**********************************************************************
*********************************************************************/

// Rows are connected to Port C 
// Columns are connected to Port A with external pull-up resistors.

#include "calc.h"
#include "io16F876.h"

CHAR keycodes[16] = {'7','8','9','/','4','5','6','*','1','2','3','-','.','0','=','+'};

CHAR keypadread()
// Find a key, wait for
// it to be released and return.
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

   // Disable ADC functionality on Port A
   ADCON1 = 6; 

   // Initialise Port for input, and PORTC for output
   TRISA = PORTC = 0xFF;
   TRISC = 0;

   for (row=0; row < KEYP_NUM_ROWS; row++)
    { // Drive appropriate row low and read columns:
      PORTC = ~(1 << row);
      asm ( "NOP");     
      tmp = PORTA;
    
      // See if any column is active (low):
      for (col=0; col<KEYP_NUM_COLS; ++col)
         if ((tmp & (1<<col)) == 0)
          { INT8 idx = (row*KEYP_NUM_COLS) + col;
            key = keycodes[idx]; 
            goto DONE;
          }
    }
   DONE:

   // Disable Port Drive and return.
   TRISC = 0xFF;
   return key;
 }



