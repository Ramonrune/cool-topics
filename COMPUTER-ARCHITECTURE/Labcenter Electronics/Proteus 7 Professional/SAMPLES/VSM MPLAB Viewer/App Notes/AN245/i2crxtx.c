/******************************************************************************************/
// Written in HI-TEC PIC C COMPILER By Abdelwahab Fassi-Fihri
//
// Hardware I2C single master routines for PIC16F877A
// for HI-TEC PIC C COMPILER.
//
// i2c_init	  - initialize I2C
// i2c_start	  - issue Start condition
// i2c_repStart   - issue Repeated Start condition
// i2c_write	  - write char - returns ACK
// i2c_read(x)	  - receive char - x=0, Issue a don't acknowledge (NACK)- x=1, Issue an acknowledge (ACK)
// i2c_stop	  - issue Stop condition
//
/******************************************************************************************/

#include <pic.h>
#include "i2crxtx.h"
#include "delay.h"

void i2c_init()
{
  TRISC3=1;		    // set SCL pin as input
  TRISC4=1;		    // set SDA pin as input

  SSPCON = 0x38;	    // set I2C master mode
  SSPCON2 = 0x00;


// SSPADD = 9;		    // 100k at 4Mhz clock
// SSPADD = 1;		    // 400k at 4Mhz clock
// SSPADD = 3;		    // 400k at 8Mhz clock
// SSPADD = 2;		    // 431k at 6Mhz clock
// SSPADD = 10; 	    // 400k at 20Mhz clock
 SSPADD = 9;		  // 500k at 20Mhz clock


 STAT_CKE=1;		    // Data transmitted on falling edge of SCK
 STAT_SMP=1;		    // disable slew rate control

 SSPIF=0;		    // clear SSPIF interrupt flag
 BCLIF=0;		    // clear bus collision flag
}

/******************************************************************************************/

void i2c_waitForIdle()
{
 while ( STAT_RW | ((SSPCON2 & 0x1F )!=0) ) {}; // wait for idle and not writing
}

/******************************************************************************************/

void i2c_start()
{
 i2c_waitForIdle();	    //Wait for the idle condition
 SEN=1; 		    //Initiate START conditon.
}

/******************************************************************************************/

void i2c_repStart()
{
 i2c_waitForIdle();	    //Wait for the idle condition
 DelayUsx(5);		    //wait 12 uS  (Running @ 20 MHz)
 RSEN=1;		    //initiate Repeated START condition

}

/******************************************************************************************/

unsigned char i2c_write( unsigned char i2cWriteData )
{
 i2c_waitForIdle();	    //Wait for the idle condition
 DelayUsx(5);		    //wait 12 uS  (Running @ 20 MHz)
 SSPBUF = i2cWriteData;     //Load SSPBUF with i2cWriteData (the value to be transmitted)

 return ( ! ACKSTAT  );     // function returns '1' if transmission is acknowledged
}
/******************************************************************************************/


int i2c_read( unsigned char ack )
{
 unsigned char i2cReadData;

 i2c_waitForIdle();	    //Wait for the idle condition
 DelayUsx(5);		    //wait 12 uS  (Running @ 20 MHz)

 RCEN=1;		    //Enable receive mode

 i2c_waitForIdle();	    //Wait for the idle condition

 i2cReadData = SSPBUF;	    //Read SSPBUF and put it in i2cReadData

 i2c_waitForIdle();	    //Wait for the idle condition

 if ( ack )		    //if ack=1 (from i2c_read(ack))
  {
      ACKDT=0;		    //then transmit an Acknowledge
  }
 else
  {
      ACKDT=1;		    //otherwise transmit a Not Acknowledge
  }

 ACKEN=1;		    // send acknowledge sequence
 return( i2cReadData );     //return the value read from SSPBUF
}
/******************************************************************************************/
void i2c_stop()
{

 i2c_waitForIdle();	    //Wait for the idle condition
 DelayUsx(5);		    //wait 12 uS  (Running @ 20 MHz)
 PEN=1; 		    //Initiate STOP condition
}
/******************************************************************************************/


