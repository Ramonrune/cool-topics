/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                     TIMER1 module                       *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"  

void TMR1_Init (unsigned int tbase) 
 { // Timer 1 to async external clock and prescaler 1:256. 
   T1CONbits.TCKPS = 0b11; 
   T1CONbits.TCS   = 1;
   T1CONbits.TSYNC = 0;
   
   // Clear timer 1 register and load preset with actual time base.
   TMR1 = 0;
   PR1  = 128*tbase-1;

   // Reset Timer 1 interrupt flag. 
   IFS0bits.T1IF = 0;
   // Enable Timer 1 interrupt.
   IEC0bits.T1IE = 1;
 } 
 
