/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM GNU CHESS SAMPLE                *****/
/*****                                                          *****/
/*****               LPC2000 I2C EEPROM Module 				       *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <LPC21xx.H>   

#include "eeprom.h"

extern VOID sleep (INT);

#define AA       0x04
#define SI       0x08
#define STO      0x10
#define STA      0x20
#define I2CEN    0x40

VOID eeprom_init ()
// Initialize the I2C Interface
 { PINSEL0 |= 0x00000050;
   I2SCLL = 15; // I2C bus will run at 100kHz with 12MHz clock
   I2SCLH = 15;
   I2CONSET = I2CEN;   
 }

BYTE eeprom_read (INT addr)
// Read single byte of the EEPROM.
 { BYTE data;
   i2c_start(0xA0); // Select write mode
   i2c_write(addr);
   i2c_start(0xA1); // Select read mode
   data = i2c_read(FALSE);   
   i2c_stop();   
   return data;
 }

VOID eeprom_write (INT addr, BYTE data)
// Write single byte of the EEPROM.
 { i2c_start(0xA0); // Select write mode
   i2c_write(addr);
   i2c_write(data);
   i2c_stop();   
   sleep(2); 
 }

BOOL i2c_start (INT addr)
 { // Send the start condition:
   I2DAT = addr;
   I2CONSET = STA;
   while (!(I2CONSET & SI))
      ;
   if ((I2STAT & 0xF8) != 0x08 && (I2STAT & 0xF8) != 0x10) // Start or restart
      return FALSE;
   
   // Send the slave address and read/write bit
   //I2CONCLR |= STA; 
   I2CONCLR = SI;
   while (!(I2CONSET & SI))
      ;
   if (addr & 1)
    { if (((I2STAT & 0xF8) != 0x40))
         return FALSE;
    }
   else
    { if ((I2STAT & 0xF8) != 0x18)
         return FALSE;
    }

   // start condition and slave address are acknowledged:
   return TRUE;
 }

BOOL i2c_stop ()
 { // Send a stop:
   I2CONSET = STO;
   I2CONCLR = SI;
   return TRUE;
 }

INT i2c_read (BOOL ack)
 { if (ack)
      I2CONSET = AA;
   I2CONCLR = SI;
   while (!(I2CONSET & SI))
      ;
   return (I2STAT & 0xF0) == 0x50 ? I2DAT : -1;
 }
 
INT i2c_write (BYTE data)
 { I2DAT = data;
   I2CONCLR = SI;
   while (!(I2CONSET & SI))
      ;
   return (I2STAT & 0xF8) == 0x28 ? data : -1;
 }
   

