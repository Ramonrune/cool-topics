/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                     I2C Master module                   *****/
/*****        Source for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"  
#include <i2c.h>
#include "utilities.h"

void _Helper_I2C_Write(unsigned char data);

#define OSC          7360000UL
#define FCY          OSC/2
#define SLAVE_ADDR   0xA0
#define MEM_SIZE     8192

void I2C_EEPROM_Init (unsigned long baudrate) 
 { unsigned int brg = ((FCY)/baudrate - ((FCY)/10000000UL))-1;
   OpenI2C1 (I2C1_ON & 
             I2C1_IDLE_STOP & 
             I2C1_CLK_REL &
             I2C1_IPMI_DIS & 
             I2C1_7BIT_ADD &
             I2C1_SLW_DIS & 
             I2C1_SM_DIS &
             I2C1_GCALL_DIS & 
             I2C1_STR_DIS &
             I2C1_NACK & 
             I2C1_ACK_DIS & 
             I2C1_RCV_DIS &
             I2C1_STOP_DIS & 
             I2C1_RESTART_DIS &
             I2C1_START_DIS , brg);  
 }

void I2C_Off (void)
 { CloseI2C1();
 }

void I2C_Write (unsigned char data, unsigned int address)
 { // Generate wait condition 
   IdleI2C1();
   // Send start
   StartI2C1();
   // Wait till Start sequence is completed
   while(I2C1CONbits.SEN);
   // Clear interrupt flag 
   IFS1bits.MI2C1IF = 0; 

   _Helper_I2C_Write (SLAVE_ADDR);
   _Helper_I2C_Write( address>>8);
   _Helper_I2C_Write( address);
   _Helper_I2C_Write(data);
 
   StopI2C1();
   // Wait till stop sequence is completed 
   while(I2C1CONbits.PEN);
 }

unsigned char I2C_Read (unsigned int address)
 { unsigned char data;
   // Generate wait condition 
   IdleI2C1();
   // Send start
   StartI2C1();
   // Wait till Start sequence is completed
   while(I2C1CONbits.SEN);
   // Clear interrupt flag 
   IFS1bits.MI2C1IF = 0; 
   
   _Helper_I2C_Write (SLAVE_ADDR);
   _Helper_I2C_Write(address>>8);
   _Helper_I2C_Write(address);
   // Generate wait condition 
   IdleI2C1();
   // Send a Repeated Start 
   RestartI2C1();
   // Wait till Repeated Start sequence is completed
   while(I2C1CONbits.RSEN);
   IFS1bits.MI2C1IF = 0;     // Clear interrupt flag 

   // Write the slave read address 
   _Helper_I2C_Write (SLAVE_ADDR | 1);
   
   I2C1CONbits.ACKDT = 1; 
   IFS1bits.MI2C1IF = 0;     // Clear interrupt flag 
   
   I2C1CONbits.RCEN = 1;
   while (!I2C1STATbits.RBF);
   data = I2C1RCV;  
   
   IFS1bits.MI2C1IF = 0;     // Clear interrupt flag 
   I2C1CONbits.ACKEN = 1; 
   while (I2C1CONbits.ACKEN);
   
   // Send Stop
   I2C1CONbits.PEN = 1;
   // Wait till stop sequence is completed 
   while(!I2C1STATbits.P); 
   IFS1bits.MI2C1IF = 0;     // Clear interrupt flag 

   return data;  
 }


void _Helper_I2C_Write(unsigned char data)
 { // Write data 
   MasterWriteI2C1(data);
   // Wait till data is transmitted 
   while(I2C1STATbits.TBF);  // 8 clock cycles
   while(!IFS1bits.MI2C1IF); // Wait for 9th clock cycle
   IFS1bits.MI2C1IF = 0;     // Clear interrupt flag 
   while(I2C1STATbits.ACKSTAT);
 }
 
void I2C_Erase (void)
 { unsigned int i;
   
   // Initialize I2C in master mode and turn it on.
   I2C_EEPROM_Init(100000);
   
   for (i=0; i<MEM_SIZE; i++)
      I2C_Write(0xff, i);    
 } 
