/******************************************************************************            
************                 LABCENTER ELECTRONICS                  ************            
************           Proteus VSM Sample Design Code               ************            
************                   IAR 'C' Calculator                   ************            
*******************************************************************************/       

#include "calc.h"
#include "stddef.h"
#include "math.h"
#include "stdlib.h"
#include "string.h"
          
//Variables
static FLOAT lvalue = 0;
static FLOAT rvalue = 0;
static CHAR lastop;


VOID main (VOID)
// Initialise our variables and call the 
// Assembly routine to initialise the LCD display. 
 { lcd_init();
   calc_evaluate();
 }   

VOID calc_evaluate()
 { CHAR number[MAX_DISPLAY_CHAR+1], key;
   INT8 pos;
   FLOAT tmp;
   
   // Initialize static values:
   lvalue = 0;
   rvalue = 0;
   lastop = 0;
   
   // Display a Zero to start:
   calc_format(0);
   
   // Clear the buffer before we start.
   pos = 0;

   for (;;)
    { key = calc_getkey();
      if (calc_testkey(key))
       { // Key test positive for digit so we read it into the
         // buffer and then write the buffer to the screen/LCD.
         // Size limit the number of digits - allow for termination
         // and possible negative results.
         if (pos != MAX_DISPLAY_CHAR - 2)
          { number[pos++] = key;
            number[pos] = 0;
            calc_display(number);
          }
       }
      else       
       { // If a number has been entered, then evaulate it.
         // The number is stored to lvalue if we have no current operator,
         // or else rvalue if we do.
         if (pos != 0)
          { tmp = atof(number);
            if (lastop == 0)
               lvalue = tmp;
            else
               rvalue = tmp;
          }

         // Reset the input buffer.
         pos = 0;
       
         // Process the Command - LastOp holds the last actual operator;          
         if (lastop != 0)
            calc_opfunctions(lastop);
         if (key != '=')
            lastop = key;
         else 
            lastop = 0;  
       }
    }
 }

VOID calc_opfunctions (CHAR token)
// Handle the operations. Lvalue holds the result and we test for
// consecutive operator presses.
 { INT8 result = OK;
   switch (token)
    { case '+' : lvalue += rvalue; break;
      case '-' : lvalue -= rvalue; break;
      case '*' : lvalue *= rvalue; break;
      case '/' : 
         if (rvalue != 0) 
            lvalue /= rvalue;
         else
            result = ERROR;
         break;      
     }

   if (result == OK)
      calc_format(lvalue);
   else if (result == ERROR)
    { char buf[] = "*ERROR*";
      calc_display(buf);
    }
 }

 
/************************************************************************
***** Utility Routines *****
***************************/

VOID calc_format (FLOAT f)
// Microchip C18's math libraries are not as accurate as
// they should be, so we have to use a table of divisors.
 { static const float divisors[] = 
    { 100000000,
		10000000,
		1000000,
		100000,
		10000,
		1000,
	   100,
		10,
      1,
		0.1,
		0.01,
		0.001,
		0.0001,
		0.00001,
		0.000001,
		0.0000001,
		0
    };
   CHAR dbuf [MAX_DISPLAY_CHAR+1];
   FLOAT divisor, tmp;
   INT count = 0, digit;
   INT pad=0, p=0;

   // Sort out minus sign:   
   if (f >= 0)
      dbuf[p++] = ' ';
   else
    { dbuf[p++] = '-';
      f = -f;
    }

   if (f >= divisors[0])
      dbuf[p++] = 'E';
   else
      while (p < MAX_DISPLAY_CHAR && ((divisor=divisors[count++]) >= 1 || f > 0.0000001))
       { digit = f/divisor+0.05;
         if (divisor == 0.1)
            dbuf[p++] = '.';
         if (digit != 0 || divisor < 10)
          { dbuf[p++] = digit + '0';
            pad = TRUE;        
          }
         else if (pad)
            dbuf[p++] = '0';
			tmp = digit*divisor;
         f -= tmp;
       }
   dbuf[p] = 0;           
   calc_display(dbuf);
 }

BOOL calc_testkey (CHAR key)
// Test whether the key is a digit, a decimal point or an operator. 
// Return 1 for digit or decimal point, 0 for op.
 { if ((key == '.')|| ((key >= '0') && (key <= '9')))
      return TRUE;
   else
      return FALSE;
 }

/************************************************************************
***** I/O Routines *****
************************/

CHAR calc_getkey (VOID)
// Use the input routine from the *Keypad_Read* assembly file to 
// Scan for a key and return ASCII value of the Key pressed.
{ CHAR mykey;
  while ((mykey = keypadread()) == 0x00)
     /* Poll again */;
  return mykey;
 }

VOID calc_display (CHAR *buf)
// Use the Output and Clearscreen routines from the 
// *LCD_Write* assembly file to output ASCII values to the LCD.
 { INT8 i;
   clearscreen();
   for (i=0 ; buf[i] != 0; i++)
//    { if (buf[calc_testkey(buf[i]) || buf[i] == 0x2D)
       { wrdata(buf[i]); }
//    }   
 }
