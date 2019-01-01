 /*===========================================================================
 Written in HI-TEC PIC C COMPILER By Abdelwahab Fassi-Fihri

 this program is using the hardware i2c on the pic 16f877A to read from

 and write to the Microchip MCP23016 I/O Expander.

=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\
This is to test with 16 leds and 16 switchs on same pins with interupt.
=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\


 ===========================================================================

 the project contains 5 files:

 i2crxtx.c  this file contains all the I2C functions are in it include it in your project
 i2crxtx.h  this is the header file for the i2crxtx.c

 16chaser.c this is a test program to show how the MCP23016 works

 delay.c   is a delay routine
 delay.h   is the header file for the delay.c

  to use the files :

  init_i2c();		    Call before the other functions are used

  write_to_MCP(a, c, d1, d2);	Write the bytes "d1" and "d2" to the Command "cmd" at the address" a"


 ===========================================================================

 the test program is writing to the Microchip MCP23016 and turning on one LED at a time.
 this program also reads from the MCP23016 when it issues an interrupt.

*/

/******************************************************************************************/

#include <pic.h>
#include "delay.h"
#include  "i2crxtx.h"
#include "delay.c"

__CONFIG (HS & WDTDIS & PWRTEN & BORDIS & LVPDIS & DUNPROT & WRTDIS & DEBUGDIS & UNPROTECT);

/******************************************************************************************/
/******************************************************************************************/
unsigned char MCP_MSB;
unsigned char MCP_LSB;
unsigned char MCP_MSB_old;
unsigned char MCP_LSB_old;
unsigned char MCP2PORTD;//rc
unsigned char MCP2PORTD1;//rc
unsigned char MCP2PORTD2;//rc
unsigned char MCP2PORTB;//rb
unsigned char MCP2PORTB1;//rb
unsigned char MCP2PORTB2;//rb
unsigned char MCP_MSB_temp;
unsigned char Flags;



void write_to_MCP(unsigned char address, unsigned char cmd,unsigned char data1, unsigned char data2)
 {
   i2c_start(); 		//Generate a START condition
   i2c_write(address);		//Transmit the "ADDRESS and WRITE" byte
   i2c_write(cmd);		//Transmit the COMMAND byte
   i2c_write(data1);		//Transmit first DATA byte
   i2c_write(data2);		//Transmit second DATA byte
   i2c_stop();			//Generate a STOP condition
//   DelayUs(50);		//Some delay may be necessary for back to back transmitions
}



void GetNewValue(unsigned char AddressW, unsigned char Command, unsigned char AddressR)
{
goread:

   MCP_LSB_old = MCP_LSB;    // Hold the current valut of LSB
   MCP_MSB_old = MCP_MSB;    // Hold the current value of MSB
   i2c_start(); 	     // Generate START condition
   i2c_write(AddressW);      // Transmit ADDRESS with WRITE command
   i2c_write(Command);	     // Transmit COMMAND byte
   i2c_repStart();	     // Generate a REPEATED-START condition
   i2c_write(AddressR);      // Transmit ADDRESS with READ command
   MCP_LSB=i2c_read(1);      // Receive first DATA byte  (LSB) and acknowledge
   MCP_MSB=i2c_read(0);      // Receive second DATA byte (MSB) and don't acknowledge
   i2c_stop();		     // Generate a STOP condition



		if ((MCP_MSB == MCP_MSB_old) && (MCP_LSB == MCP_LSB_old))
		{
		       PORTB=MCP2PORTB;       //if the new values received
		       PORTA=MCP2PORTD;       //are the same as the old ones
					      //Then don't change anything
		}
		else
		{
		       MCP2PORTD = MCP_MSB;   //store the MSB in MCP2PORTD		 

		       MCP2PORTB = MCP_LSB;   //store the LSB in MCP2PORTB

		       PORTB=MCP2PORTB;       //load PORTB with LSB
		       PORTD=MCP2PORTD;       //load PORTD with MSB

		}


		if (RC1==0)		      //if RC1 is equal to zero after reading the MCP23016
		{
		       DelayUs(250);	      //Wait 250 us
		       if (RC1==0)	      //if RB0 is still equal to zero
		       {       goto goread;   //then read the MCP23016 again
		       }
		       else;
		}
			else;


}


interrupt isr()
{
	if (CCP2IE && CCP2IF)	 
	{
		CCP2IF=0;		      //clear interrupt flag
		Flags=0x01;		      //set software interrupt
	}
}


void Check_CCP_status()
{
if (Flags != 0x00)			      //if software flag has been set
{
   GetNewValue(0x40, 0x00, 0x41);	      //read the MCP23016
   Flags = 0x00;			      //Clear software flag
}
else
{  return;
}
}
/***********************************************************/

void main()
{
  unsigned char i=1;
  unsigned char j=128;

//initialize variables
MCP2PORTB=0xff;
MCP2PORTD=0xff;
MCP_MSB == 0xff;
MCP_LSB == 0xff;


//initialize PORTS
 TRISB=0x00;				      //portb output
 TRISD=0x00;				      //portd output
 TRISC=0x02;

 PORTB=0xff;
 PORTD=0xff;
 PORTC=0xff;


//initialize I2C module
 i2c_init();				      // init i2c


//initialize A/D module
 ADCON0=0x00;				      // disable A/D module
 ADCON1=0x07;				      // select PORTA to be all digital


//initialize CCP2 module
 CCP2CON = 0x04;			      //configure CCP2 module to capture on every falling edge

//Enable interrupts
 CCP2IE = 1;				      //enable CCP2 interrupt
 PEIE = 1;				      //enable Peripheral interrupt
 GIE = 1;				      //enable Global interrupt


  DelayMs(250); 			      //Wait for MCP23016 power_up timer
  DelayMs(250);
    DelayMs(250);
//this is for the Microchip MCP23016 initialization

//  write_to_MCP(0x40,0x04,0xFF,0xFF);	  //invert all input polarities
//  write_to_MCP(0x40,0x0A,0x01,0x01);	  //initialize IARES, for fast input scan mode

  
//  write_to_MCP(0x40,0x06,0x00,0x00);	  //initiallize it so that both LSBs & MSBs are outputs
//  write_to_MCP(0x40,0x06,0xFF,0xFF);	  //initiallize it so that both LSBs & MSBs are inputs

//  DelayUs(30);			  //@ 20MHz each DelayUs(1)=1.4 uS

write_to_MCP(0x40,0x02,0xFF,0xFF);	  //initiallize the ouput latch
write_to_MCP(0x40,0x06,0x00,0xFF);	  //initiallize it so the LSBs outputs are  & MSBs are inputs


do{

i=1;
j=128;

up:	while(i<=128)
 {

  Check_CCP_status();		 //check if an interrupt was received from the slave devices
  DelayMs(40);			 //wait

  write_to_MCP(0x40,0x02,~i,~j); //this writes to the Microchip MCP23016 (The data is inverted
				 //because the I/Os on the test board are configured as active low)
//  write_to_MCP(0x40,0x02,i,j);
  DelayMs(40);			 //wait


if (i<128)
{
  i<<=1;			//shift left
  j>>=1;			//shift right
}
else
 {
  i>>=1;			//shift right
  j<<=1;			//shift left
  goto down;
 }
  }
down:	while(i>=1)
  {

  Check_CCP_status();
  DelayMs(40);

 write_to_MCP(0x40,0x02,~i,~j); //this writes to the Microchip MCP23016 (The data is inverted
				//because the I/Os on the test board are configured as active low)
//  write_to_MCP(0x40,0x02,i,j);
  DelayMs(40);


if (i>1)
{
  i>>=1;
  j<<=1;
}
else
 {
  i<<=1;
  j>>=1;
  goto up;
 }
  }
  }while(1);
}
/******************************************************************************************/


