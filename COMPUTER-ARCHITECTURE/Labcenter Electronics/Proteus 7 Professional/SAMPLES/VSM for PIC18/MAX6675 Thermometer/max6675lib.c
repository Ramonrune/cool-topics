#include "max6675lib.h"


// MAX6675 initialization. Starts a conversion 
void max6675_init(void)
 { ck_tris = 0;                           // make clock bit as an output pin
   ck_out  = 0;                           // initialize it low
   cs_tris = 0;                           // make chip select as an output pin 
   cs_out  = 1;                           // initialize conversion
   so_tris = 1;                           // make serial output as an input pin
 }

// MAX6675 conversion 
int max6675_read_temp (void)              
 { static char i; 
   static int temp = 0; 
   cs_out = 0;                            // Stop a conversion in progress 
   nop();                                 //  
   for (i=0;i<16;i++)
    { shift_left(temp, so_in);
      ck_out = 1; 
      nop();                                 
      ck_out = 0; 
    } 
   if (temp.2)                           // Thermocouple continuity check. 
      isthcopen = 1;
   else 
      isthcopen = 0;
   cs_out = 1;                            // Initiate a new conversion  
   return (temp>>3); 
 }

