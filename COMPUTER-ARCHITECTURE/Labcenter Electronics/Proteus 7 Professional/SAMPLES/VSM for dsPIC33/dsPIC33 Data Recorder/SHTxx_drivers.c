/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****              SHTxx digital sensors drivers              *****/
/*****             NOTE: not standard I2C protocol             *****/
/*****                                                         *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"  
#include "utilities.h"
#include "SHTxx_drivers.h"

// Get a measure from SHT sensor. Big-endian WORD. 
unsigned int get_measure (void)
 { unsigned int value;
   // DATA line is input.
   SDADIR = in;
   // wait until sda returns low
   while (SDA) ;
   // return the MSB of the value
   value = get_byte(0) << 8;
   // return the LSB of the value
   value |= get_byte(0);
   
   return value;   
 }

// Get a byte from SHT sensor. 
// ack=0 -  get the MSB/LSB of the current measure. Need to be called twicely.
// ack=1 -  get the crc computed for current measure. Need to be called once.
// NOTE: the transaction closes once ack is sent from the sensor. 
unsigned char get_byte (char ack)
 { // Written to be optimized for speed.
   unsigned char value=0;
   SDADIR = in;
   value |= SDA<<7;
   scl_tick;
   value |= SDA<<6;
   scl_tick;
   value |= SDA<<5;
   scl_tick;
   value |= SDA<<4;
   scl_tick;
   value |= SDA<<3;
   scl_tick;
   value |= SDA<<2;
   scl_tick;
   value |= SDA<<1;
   scl_tick;
   value |= SDA<<0;
   scl_tick;
   
   SDADIR = out;
   SDA = ack;
   scl_tick;
 
   return value;
 }
// Send a command to SHT sensor. 
void send_command (unsigned char command)
 { // Written to be optimized for speed.
   SDADIR = out;
   scl_low;
   SDA = command & (1<<7) ? 1: 0;
   scl_tick;
   SDA = command & (1<<6) ? 1: 0;
   scl_tick;
   SDA = command & (1<<5) ? 1: 0;
   scl_tick;
   SDA = command & (1<<4) ? 1: 0;
   scl_tick;
   SDA = command & (1<<3) ? 1: 0;
   scl_tick;
   SDA = command & (1<<2) ? 1: 0;
   scl_tick;
   SDA = command & (1<<1) ? 1: 0;
   scl_tick;
   SDA = command & (1<<0) ? 1: 0;
   scl_hi; 
   // this pulls DATA line floating and prevents contention  
   SDADIR = in;
   scl_low;
   // ack bit. SHTxx should control DATA line low to acknowledge 
   // the address and command as valid. 
   scl_low;
   scl_tick;
 }  
