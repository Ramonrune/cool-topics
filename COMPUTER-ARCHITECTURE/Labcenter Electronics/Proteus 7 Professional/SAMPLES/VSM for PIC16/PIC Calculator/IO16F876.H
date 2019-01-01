/**********************************************************
 *
 * This file contains definitions                         
 * of the Special Function Registers                      
 *                                                        
 * Copyright 1999 IAR Systems. All rights reserved.
 *     
 * $Revision: 1.4 $
 *                                                   
 * $Log: IO16F876.H $                                      
 * Revision 1.4  2000/06/07 10:34:57  ILAK                                      
 * Removed PORTD/E, TRISD/E and PSPIF/PSPIF as they                                       
 * do not exist on this device                                      
 * Revision 1.3  1999/11/15 13:27:21  ILAK                                      
 * Fixed missing bitnames for PORTA/B/C/D/E.                                      
 * Revision 1.2  1999/08/13 09:31:36  ILAK                                      
 * Fixed configuration bits                                      
 * Revision 1.1  1999/08/10 14:17:55  ILAK                                      
 * Initial revision                                      
 *                                                        
 **********************************************************/


#ifndef __IO16F876_H__
#define __IO16F876_H__

#ifndef __CPU_16F876__
#error "This I/O-file is for the 16F876 controller only"
#endif

#pragma language=extended
/* Bank 0 */

__no_init volatile __nonbanked  unsigned char INDF   @ 0x00;
__no_init volatile __bank0      unsigned char TMR0   @ 0x01;
__no_init volatile __nonbanked  unsigned char PCL    @ 0x02;
__no_init volatile __nonbanked  union 
{
  unsigned char STATUS;
  struct 
  {
    unsigned char C:1;
    unsigned char DC:1;
    unsigned char Z:1;
    unsigned char PD:1;
    unsigned char TO:1;
    unsigned char RP0:1;
    unsigned char RP1:1;
    unsigned char IRP:1;
  };
} @ 0x03;
__no_init volatile __nonbanked  unsigned char FSR    @ 0x04;
__no_init volatile __bank0  union
{
  unsigned char PORTA;
  struct
  {
    unsigned char RA0:1;
    unsigned char RA1:1;
    unsigned char RA2:1;
    unsigned char RA3:1;
    unsigned char RA4:1;
    unsigned char RA5:1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x05;
__no_init volatile __bank0  union
{
  unsigned char PORTB;
  struct
  {
    unsigned char RB0:1;
    unsigned char RB1:1;
    unsigned char RB2:1;
    unsigned char RB3:1;
    unsigned char RB4:1;
    unsigned char RB5:1;
    unsigned char RB6:1;
    unsigned char RB7:1;
  }; 
} @ 0x06;
__no_init volatile __bank0  union
{
  unsigned char PORTC;
  struct
  {
    unsigned char RC0:1;
    unsigned char RC1:1;
    unsigned char RC2:1;
    unsigned char RC3:1;
    unsigned char RC4:1;
    unsigned char RC5:1;
    unsigned char RC6:1;
    unsigned char RC7:1;
  }; 
} @ 0x07;
__no_init volatile __nonbanked  unsigned char PCLATH @ 0x0A;
__no_init volatile __nonbanked  union
{
  unsigned char INTCON;
  struct
  {
    unsigned char RBIF:1;
    unsigned char INTF:1;
    unsigned char T0IF:1;
    unsigned char RBIE:1;
    unsigned char INTE:1;
    unsigned char T0IE:1;
    unsigned char PEIE:1;
    unsigned char GIE:1;
  }; 
} @ 0x0B;
__no_init volatile __bank0  union
{
  unsigned char PIR1;
  struct
  {
    unsigned char TMR1IF:1;
    unsigned char TMR2IF:1;
    unsigned char CCP1IF:1;
    unsigned char SSPIF:1;
    unsigned char TXIF:1;
    unsigned char RCIF:1;
    unsigned char ADIF:1;
    unsigned char :1;
  }; 
} @ 0x0C;
__no_init volatile __bank0  union
{
  unsigned char PIR2;
  struct
  {
    unsigned char CCP2IF:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char BCLIF:1;
    unsigned char EEIF:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x0D;
__no_init volatile __bank0      unsigned char TMR1L   @ 0x0E;
__no_init volatile __bank0      unsigned char TMR1H   @ 0x0F;
__no_init volatile __bank0  union
{
  unsigned char T1CON;
  struct
  {
    unsigned char TMR1ON:1;
    unsigned char TMR1CS:1;
    unsigned char T1SYNC:1;
    unsigned char T1OSCEN:1;
    unsigned char T1CKPS0:1;
    unsigned char T1CKPS1:1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x10;
__no_init volatile __bank0      unsigned char TMR2    @ 0x11;
__no_init volatile __bank0  union
{
  unsigned char T2CON;
  struct
  {
    unsigned char T2CKPS0:1;
    unsigned char T2CKPS1:1;
    unsigned char TMR2ON:1;
    unsigned char TOUTPS0:1;
    unsigned char TOUTPS1:1;
    unsigned char TOUTPS2:1;
    unsigned char TOUTPS3:1;
    unsigned char :1;
  }; 
} @ 0x12;
__no_init volatile __bank0      unsigned char SSPBUF  @ 0x13;
__no_init volatile __bank0  union
{
  unsigned char SSPCON;
  struct
  {
    unsigned char SSPM0:1;
    unsigned char SSPM1:1;
    unsigned char SSPM2:1;
    unsigned char SSPM3:1;
    unsigned char CKP:1;
    unsigned char SSPEN:1;
    unsigned char SSPOV:1;
    unsigned char WCOL:1;
  }; 
} @ 0x14;
__no_init volatile __bank0      unsigned char CCPR1L  @ 0x15;
__no_init volatile __bank0      unsigned char CCPR1H  @ 0x16;
__no_init volatile __bank0  union
{
  unsigned char CCP1CON;
  struct
  {
    unsigned char CCP1M0:1;
    unsigned char CCP1M1:1;
    unsigned char CCP1M2:1;
    unsigned char CCP1M3:1;
    unsigned char CCP1Y:1;
    unsigned char CCP1X:1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x17;
__no_init volatile __bank0  union
{
  unsigned char RCSTA;
  struct
  {
    unsigned char RX9D:1;
    unsigned char OERR:1;
    unsigned char FERR:1;
    unsigned char ADDEN:1;
    unsigned char CREN:1;
    unsigned char SREN:1;
    unsigned char RX9:1;
    unsigned char SPEN:1;
  }; 
} @ 0x18;
__no_init volatile __bank0      unsigned char TXREG   @ 0x19;
__no_init volatile __bank0      unsigned char RCREG   @ 0x1A;
__no_init volatile __bank0      unsigned char CCPR2L  @ 0x1B;
__no_init volatile __bank0      unsigned char CCPR2H  @ 0x1C;
__no_init volatile __bank0  union
{
  unsigned char CCP2CON;
  struct
  {
    unsigned char CCP2M0:1;
    unsigned char CCP2M1:1;
    unsigned char CCP2M2:1;
    unsigned char CCP2M3:1;
    unsigned char CCP2Y:1;
    unsigned char CCP2X:1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x1D;
__no_init volatile __bank0      unsigned char ADRESH  @ 0x1E;
__no_init volatile __bank0  union
{
  unsigned char ADCON0;
  struct
  {
    unsigned char ADON:1;
    unsigned char :1;
    unsigned char GO:1;
    unsigned char CHS0:1;
    unsigned char CHS1:1;
    unsigned char CHS2:1;
    unsigned char ADCS0:1;
    unsigned char ADCS1:1;
  }; 
} @ 0x1F;
#define DONE GO

/* Bank 1 */

__no_init volatile __bank1  union
{
  unsigned char OPTION;
  struct
  {
    unsigned char PS0:1;
    unsigned char PS1:1;
    unsigned char PS2:1;
    unsigned char PSA:1;
    unsigned char T0SE:1;
    unsigned char T0CS:1;
    unsigned char INTEDG:1;
    unsigned char RBPU:1;
  }; 
} @ 0x81;
__no_init volatile __bank1      unsigned char TRISA   @ 0x85;
__no_init volatile __bank1      unsigned char TRISB   @ 0x86;
__no_init volatile __bank1      unsigned char TRISC   @ 0x87;
__no_init volatile __bank1  union
{
  unsigned char PIE1;
  struct
  {
    unsigned char TMR1IE:1;
    unsigned char TMR2IE:1;
    unsigned char CCP1IE:1;
    unsigned char SSPIE:1;
    unsigned char TXIE:1;
    unsigned char RCIE:1;
    unsigned char ADIE:1;
    unsigned char :1;
  }; 
} @ 0x8C;
__no_init volatile __bank1  union
{
  unsigned char PIE2;
  struct
  {
    unsigned char CCP2IE:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char BCLIE:1;
    unsigned char EEIE:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x8D;
__no_init volatile __bank1  union
{
  unsigned char PCON;
  struct
  {
    unsigned char BOR:1;
    unsigned char POR:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
  }; 
} @ 0x8E;
__no_init volatile __bank1  union
{
  unsigned char SSPCON2;
  struct
  {
    unsigned char SEN:1;
    unsigned char RSEN:1;
    unsigned char PEN:1;
    unsigned char RCEN:1;
    unsigned char ACKEN:1;
    unsigned char ACKDT:1;
    unsigned char ACKSTAT:1;
    unsigned char GCEN:1;
  }; 
} @ 0x91;
__no_init volatile __bank1      unsigned char PR2     @ 0x92;
__no_init volatile __bank1      unsigned char SSPADD  @ 0x93;
__no_init volatile __bank1  union
{
  unsigned char SSPSTAT;
  struct
  {
    unsigned char BF:1;
    unsigned char UA:1;
    unsigned char R:1;
    unsigned char S:1;
    unsigned char P:1;
    unsigned char D:1;
    unsigned char CKE:1;
    unsigned char SMP:1;
  }; 
} @ 0x94;
#define W R
#define A D
__no_init volatile __bank1  union
{
  unsigned char TXSTA;
  struct
  {
    unsigned char TX9D:1;
    unsigned char TRMT:1;
    unsigned char BRGH:1;
    unsigned char :1;
    unsigned char SYNC:1;
    unsigned char TXEN:1;
    unsigned char TX9:1;
    unsigned char CSRC:1;
  }; 
} @ 0x98;
__no_init volatile __bank1      unsigned char SPBRG   @ 0x99;
__no_init volatile __bank1      unsigned char ADRESL  @ 0x9E;
__no_init volatile __bank1  union
{
  unsigned char ADCON1;
  struct
  {
    unsigned char PCFG0:1;
    unsigned char PCFG1:1;
    unsigned char PCFG2:1;
    unsigned char PCFG3:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
    unsigned char ADFM:1;
  }; 
} @ 0x9F;

/* Bank 2 */

__no_init volatile __bank2      unsigned char EEDATA  @ 0x10C;
__no_init volatile __bank2      unsigned char EEADR   @ 0x10D;
__no_init volatile __bank2      unsigned char EEDATH  @ 0x10E;
__no_init volatile __bank2      unsigned char EEADRH  @ 0x10F;

/* Bank 3 */

__no_init volatile __bank3 union
{
  unsigned char EECON1;
  struct
  {
    unsigned char RD:1;
    unsigned char WR:1;
    unsigned char WREN:1;
    unsigned char WRERR:1;
    unsigned char :1;
    unsigned char :1;
    unsigned char :1;
    unsigned char EEPGD:1;
  }; 
} @ 0x18C;
__no_init volatile __bank3      unsigned char EECON2  @ 0x18D;

// Constants for Configuration Word intrinsic

#define CP_ALL          0x0FCF
#define CP_75           0x1FDF
#define CP_50           0x2FEF
#define CP_OFF          0x3FFF

#define WRT_ENABLE_ON   0x3FFF
#define WRT_ENABLE_OFF  0x3DFF

#define PWRTE_ON        0x3FF7
#define PWRTE_OFF       0x3FFF

#define WDT_ON          0x3FFF
#define WDT_OFF         0x3FFB

#define LP_OSC          0x3FFC
#define XT_OSC          0x3FFD
#define HS_OSC          0x3FFE
#define RC_OSC          0x3FFF

#define BODEN_ON        0x3FFF
#define BODEN_OFF       0x3FBF


#define DEBUG_ON        0x37FF
#define DEBUG_OFF       0x3FFF

#define CPD_ON          0x3EFF
#define CPD_OFF         0x3FFF

#define LVP_ON          0x3FFF
#define LVP_OFF         0x3F7F

#pragma language=default

#endif

