/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                     ADC module                          *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"  
#include "utilities.h"

void ADC_Init(void)
 { AD1PCFGL = 0xFFFF;
   
   // AN0, AN1 as analog input for VREF+ and VREF- . AN2 is analog input for pressure.
   AD1PCFGLbits.PCFG0 = 0; 
   AD1PCFGLbits.PCFG1 = 0; 
   AD1PCFGLbits.PCFG2 = 0; 
    
    /* Configure sample clock source and conversion trigger mode.
      12bit operation mode.
      Integer format (FORM<1:0>=00),
      Manual conversion trigger (SSRC<3:0>=000),
      Manual start of sampling (ASAM=0),
      No operation in Idle mode (ADSIDL=1), 
      Samples multiple channels individually in sequence. */
   AD1CON1 = 0x2400;    
   
   /* Configure A/D voltage reference and buffer fill modes.
      External VREF+ and VREF- to AN0 and AN1,
      Do not scan inputs,
      Interrupt on every sample, result is ADCBUF0  */ 
   AD1CON2      = 0;
   AD1CON2bits.VCFG = 0b011;         
   
   // Configure A/D conversion clock as 1 Tcy 
   AD1CON3 = 0x0000;    
   
   /* Configure input channels,
      CH0+ input is AN2,
      CH0- input is VREF-. 
      NOTE: as AN1 coincides with the external VREF- then
            it makes no difference whether CH0NA is 0 or 1. */
   AD1CHS0bits.CH0SA = 2;         
   AD1CHS0bits.CH0NA = 0; 
   
   // No scan list.
   AD1CSSL = 0;         
   
   // Clear A/D conversion interrupt.
   IFS0bits.AD1IF = 0;  
 }   



unsigned int ADC_Conversion (void)
 { // ADC module is operating. 
   AD1CON1bits.ADON = 1;
   // wait for ADC to stabilize.
   bdelay_1ms();
   // Sample the input
   AD1CON1bits.SAMP = 1;         
   // Wait just a little bit.
   bdelay_10us();
   // End A/D sampling and start conversion
   AD1CON1bits.SAMP = 0;         
   // wait for a conversion done 
   while (!AD1CON1bits.DONE) ;
   
   return ADC1BUF0;
 }

void ADC_Off (void)
 { // ADC module is shutted off. 
   AD1CON1bits.ADON = 0;
 } 
