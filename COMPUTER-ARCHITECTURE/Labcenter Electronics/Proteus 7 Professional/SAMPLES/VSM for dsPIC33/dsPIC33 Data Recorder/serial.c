/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                       UART1 module                      *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/
#include "p33FJ12GP201.h"

// Init and open the serial interface for Tx and Rx operations.
void Init_Serial (void)
 { // Baudrate is set to 19200 (@ 7.37MHz) 
   U1BRG  = 0x0B;
   // 8-bits, 1 bit stop, Flow ctrl mode
   U1MODE = 0;
   U1STA  = 0;
   // Enable UART1
   U1MODEbits.UARTEN = 1;
   // Enable Transmit
   U1STAbits.UTXEN   = 1;
   // reset RX flag
   IFS0bits.U1RXIF = 0;
 }

void Close_Serial (void)
 { // Disable Transmit
   U1STAbits.UTXEN   = 0;
   // Disable UART1
   U1MODEbits.UARTEN = 0;
 }

// Send a character out to the serial interface.
void  Serial_PutChar(char Ch)
 { // wait for empty buffer 
   while(U1STAbits.UTXBF == 1);
      U1TXREG = Ch;
 }

// Send a string out to the serial interface.
void Serial_SendString (char *str)
 { char * p;
   p = str; 
   while (*p)
      Serial_PutChar(*p++);
 }

// Get a character in from the serial interface.
char Serial_GetChar(void)
 { char buff;
   // wait until a character is ready in the buffer.
   while(IFS0bits.U1RXIF == 0);
   buff = U1RXREG;
   IFS0bits.U1RXIF = 0;
   return buff;
 }

// Send a decimal number to the serial interface 
void Serial_PutDec(unsigned int value)
 {  if(value/10000) 
        Serial_PutChar(value/10000+'0');
    value = value - (value/10000)*10000;

    if(value/1000) 
        Serial_PutChar(value/1000+'0');
    value = value - (value/1000)*1000;

    if(value/100) 
        Serial_PutChar(value/100+'0');
    value = value - (value/100)*100;

    if(value/10) 
        Serial_PutChar(value/10+'0');
    
    value = value - (value/10)*10;
    Serial_PutChar(value+'0');
 }

// Send a byte in hexadecimal format to the serial interface.
void Serial_Hexbyte (unsigned char value)
 { unsigned char hnibble=0, lnibble=0;
   
   // Convert low nibble     
   lnibble = value & 0x0f;
   if (lnibble > 9) 
      lnibble = lnibble + 55;
   else 
      lnibble = lnibble + 48;

   // Convert low nibble     
   hnibble = (value >> 4) & 0x0f;
   if (hnibble > 9) 
      hnibble = hnibble + 55;
   else 
      hnibble = hnibble + 48;

   // Send byte in hex format
   Serial_PutChar (hnibble);
   Serial_PutChar (lnibble);
}

// Send a word in hexadecimal format to the serial interface.
void Serial_Hexword (unsigned int value)
 { unsigned int byte;
   
   // Send high byte
   byte = (value >> 8) & 0x0ff;
   Serial_Hexbyte (byte);
   // Send low byte
   byte = value & 0x0ff;
   Serial_Hexbyte (byte);
 }

