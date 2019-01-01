/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                     Timing utilitlies                   *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"  

// Basic 1ms Delay. 4000 repeats are about 1ms @ 8MHz clock
void bdelay_1ms(void)
 { asm volatile("repeat #3680"); 
   Nop();
 }

// Basic 100us Delay. 400 repeats are about 100u @ 8MHz clock
void bdelay_100us(void)
 { asm volatile("repeat #368"); 
   Nop();
 }

// Basic 10us Delay. 40 repeats are about 10u @ 8MHz clock
void bdelay_10us(void)
 { asm volatile("repeat #37"); 
   Nop();
 }

void delay_ms (unsigned int time)
 { unsigned int i;
   for (i=0; i<time; i++)
      bdelay_1ms();
 } 
