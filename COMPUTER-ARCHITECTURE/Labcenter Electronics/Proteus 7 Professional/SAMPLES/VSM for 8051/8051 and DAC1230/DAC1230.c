/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****       LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                                                          *****/
/*****        Simple test program for DAC1230 and 80C51         *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <reg51.h>

unsigned char xdata DACOUT _at_ 0xF000;

void main(void)
 { unsigned int i, data_word, steps; 
   // Simple staircase generation.
   data_word = 0x0000;
   // we want 
   steps = 0xfff/32;
   while (1)
    { // Data words have to be presented byte per byte, hi byte first. The low byte should be left justified.
      // This is a feature of DAC1230.
      //  |  HI Byte | LO BYTE  |      
      //  |MSB-------|---LSBxxxx|
      DACOUT = (data_word >> 4) & 0xff; 
      DACOUT = (data_word << 4) & 0xf0;
      // do a step every 50ms (with actual crystal value).
      for (i=0; i<10000; i++);
      // increment data_word of the programmed step
      data_word += steps;
      if (data_word & 0xf000)
         data_word = 0;      
    }
 }
