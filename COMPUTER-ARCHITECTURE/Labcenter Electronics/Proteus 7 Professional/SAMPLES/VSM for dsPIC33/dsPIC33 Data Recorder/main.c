/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                                                         *****/
/*****      Source for SOLID STATE Recorder using dsPIC33      *****/
/*****                                                         *****/
/***** Author    : EA                                          *****/
/***** Date      : 22 July 2008                                *****/
/***** Version   : V1.0                                        *****/
/***** Copyright : Labcenter Electronics Ltd.                  *****/
/*****                                                         *****/
/***** NOTE: for tutorial purposes only.                       *****/
/*******************************************************************/
/*******************************************************************/

#include "p33FJ12GP201.h"
#include "timer.h"
#include "utilities.h"
#include "analog.h"
#include "i2c_eeprom.h"
#include "SHTxx_drivers.h"
#include "serial.h"
#include "command_proc.h"
#include "common.h"

_FGS     ( GSS_STD )
_FOSC    ( POSCMD_NONE & IOL1WAY_OFF )
_FOSCSEL ( FNOSC_FRC )
_FWDT    ( FWDTEN_OFF & WDTPRE_PR32 & WDTPOST_PS1 )

static unsigned char naverage;
static unsigned int timebase, warmup;
static unsigned int pressure, temperature, rel_humidity;
// Start memory address at cold start. 
static unsigned int rec_address; 

/********************************************************************
**** INT0 interrupt ****
***********************/

// A terminal is connected. 
// Interrupt any recording operation and wait for any character from terminal. 
void __attribute__((interrupt, auto_psv)) _INT0Interrupt(void)
 { // Clear interrupt flag
   IFS0bits.INT0IF = 0;
   command_processor();
 }

/********************************************************************
**** TIMER1 interrupt ****
*************************/

// Once we have woken up from sleeping mode the power current rises drammatically up.
// The CPU power current is a function of the operating voltage and frequency but 
// different other factors will affect that value. As we are clocking at 3.8MIPS then 
// the power current is expected to be a little smaller than the value reported as 
// 27mA @ 10MIPS and 25°C.
// The CPU demands current for a total of 300ms in this application.  
// 
// The SHT sensor requires a current of 4mA @ 5V and 25°C.  
// The SHT sensor will sink current for 260ms and then switches off to 10uA.  

// In addition to that, we need to consider the analog circuitry. 
// The absolute pressure transducer needs a typical current of 7mA @ 5V and 25°C.
// An high efficiency, step-up DC-DC converter provides the 5 volt from the 3.3V  
// Battery. However, even with 90% efficiency the current from the battery is 
// expected to be in the range of 12mA @ 3.3V. The good news is this section is 
// enabled for just 25ms (default) and then disabled.
//
// The last section is the non volatile memory. The memory we use is a ferroelectric 
// non volatile, i2c RAM which exhibits very low power operations with 75uA active 
// current @ 100KHz and 1uA in standby. 
// This device is enabled for as less as 7ms and then switches to standby current.         
//
// In order to predict which the battery life will be, we can compute the everage 
// value of the current at power on as a sum of the different current components in a 
// time slot of 300ms, the total time the CPU is powered on. So:
//
// 27mA + (260/300)ms * 4mA + (25/300)ms * 12mA + (7/300)ms * 0.075mA = 32mA.
//
// An 1.5V alkaline-manganise AA element exhibit an energy of typically 1500mA/hour 
// and is designed to drain a continuous current of 50mA, typical. The computation of 
// the battery life is not that an easy job, though, depending it from a number of 
// several conditions. 
// An algorithm offered from a battery manufacturer helps to define this as:
//
// life(hours) = Time-base_Period(s) * Capacity(Ah) / (24 * switch_on_time(s) * current (A)).
//
// For instance, with one sample every minute we can have:
// life = 60*1.5/(24*0.3*0.032) = 390 hours, 
//
// the non volatile memory is fully filled before than that!      
  
void __attribute__((interrupt, auto_psv)) _T1Interrupt(void)
 { // get warm-up time
   warmup = get_header(3);
   // get new free address 
   rec_address = get_header(0) * 256 + get_header(1); 
   // get number of average readings for pressure.
   naverage = get_header(7); 
   
   // Get and record data until we have not reached the max size of the eeprom.
   if (rec_address < MAX_SIZE)
    { 
      // Switch off I2C master module. This helps to get not interference between the
      // eeprom and SHT sensor as they share the same SCL pin.
      I2C_Off();
 
      // Get all measures from digital sensors
      temperature  = get_temperature();
      rel_humidity = get_humidity();
      
      // Turn analog circuitry on.
      AN_SW_ON;
      // Wait for analogs to stabilize.
      delay_ms (warmup);   
      // Get the pressure value from ADC. 
      pressure = get_pressure(naverage); 
      // Switch analog circuitry off.
      AN_SW_OFF;
      
      // Write the new header and the acquired measures in the next free location of eeprom. 
      ee_write ();
      // Switch off I2C master module. 
      I2C_Off();
    }
   // Reset interrupt flag. 
   // This also notificates to command processor the end of record status.  
   IFS0bits.T1IF = 0;     
 }



/********************************************************************
**** Cold start ****
*******************/

int main(void)
 { // Enable the LP secondary oscillator. 
   __builtin_write_OSCCONL(OSCCON | 0x02);
 
   // Unlock the pin remap (not necessary at POR)
   __builtin_write_OSCCONL(OSCCON & 0xbf); 
   // Map output U1TX to RP14
   RPOR7bits.RP14R = 3;   
   // Max input U1RX to RP15
   RPINR18bits.U1RXR = 15;
   // Lock the pin remap
   __builtin_write_OSCCONL(OSCCON | 0x40);
   
   // Initialize the address. 
   rec_address = 16;
   
   // Check for signature at cold start. 
   // If first time or memory has been erased then create the header block. 
   header_Initialize();
   // Get the programmed time base.
   timebase = get_header(2);
   
   // Initialize peripherals.
   TMR1_Init(timebase);
   ADC_Init();
   
   // Select INT0 interrupy priority 
   IPC0bits.INT0IP = 1;  
   // Enable INT0
   IEC0bits.INT0IE = 1;

   // Enable timer 1 to run
   T1CONbits.TON = 1;
   
   // All is done ! We can get sleeping now. 
   // In sleeping mode the CPU power down current is limited to 63uA typical @ 3.3V 
   // and 25°C. The Low Power Oscillator is the only module enabled in this mode. 
   // We therefore use LPO to drive TIMER1 and wake the recorder up periodically. 
   while (1)
    { // Configure port B to high impedence inputs. 
      TRISB = -1;
      // Let's dsPIC can go sleeping.
      asm ("PWRSAV #0");
    }
 }



/********************************************************************
**** Main functions ****
***********************/

// Return the value of the ambient pressure. raw data in 12 bits resolution.
unsigned int get_pressure(unsigned char navr)
 { unsigned int result=0, i;
   
   for (i=0; i<navr; i++) 
      result = (result + ADC_Conversion()) >> 1; 
   
   // Switch ADC off when conversion completed.
   ADC_Off();
 
   return result;  
 }

// Return the value of the ambient temperature. raw data in 14 bits resolution.
unsigned int get_temperature (void)
 { unsigned int result;
   unsigned char crc_value;

   reset();
   // new transmission start. 
   start();
   // send address (000) and a read temperature command.      
   send_command(MEAS_TEMP);
   // return the temperature value
   result = get_measure();
   // return the checksum and close transmission
   crc_value = get_byte(1);
   
   return result; 
 }

// Return the value of the relative humidity. raw data in 10 bits resolution.
unsigned int get_humidity (void)
 { unsigned int result;
   unsigned char crc_value;
   
   reset();
   // new transmission start. 
   start();
   // send address (000) and a read relative humidity command.      
   send_command(MEAS_RH);
   // return the humidity value
   result = get_measure();
   // return the checksum and close transmission
   crc_value = get_byte(1);

   return result; 
 } 

// Write header and data in the non volatile memory.
void ee_write (void)
 { unsigned int i;
   unsigned char buffer[6];
   
   // Save all measures in a temporary buffer
   buffer[0] = pressure     >> 8;
   buffer[1] = pressure;
   buffer[2] = rel_humidity >> 8;
   buffer[3] = rel_humidity;
   buffer[4] = temperature  >> 8;
   buffer[5] = temperature;
   
   // Initialize I2C in master mode and turn it on.
   I2C_EEPROM_Init(100000);
   
   /* Write a block of values, high byte first, rappresenting in this order:
      1) pressure (12-bit, big-endian WORD) 
      2) relative humidity (12-bit, big-endian WORD)  
      3) temperature (14-bit, big-endian WORD) */
   for (i=0; i<6; i++)
    { I2C_Write(0xff, rec_address+i);
      I2C_Write(buffer[i], rec_address+i);
    }
   // Address counter is advanced of six positions.
   rec_address = rec_address+6;
   
   // Write new memory header.
   I2C_Write(0xff, 0);   
   I2C_Write(0xff, 1);   
   
   I2C_Write(rec_address >> 8, 0);
   I2C_Write(rec_address, 1);
   
   // Finally, switch off I2C module.
   I2C_Off();
 } 

// Check for a signature into the non volatile ram. If not found then writes it 
// and initializes the memory header block with default parameters.
 
void header_Initialize (void)
 { int i;
   unsigned char header_block[16]; 
   // Set I2C in master mode and turn it on.
   I2C_EEPROM_Init(100000);
   // Check header block for first time power on.
   for (i=0; i<16; i++)
      header_block[i] = I2C_Read (i);    
   
   if (header_block[12] == 0xAA)
    { if (header_block[13] == 0xAA)
         if (header_block[14] == 0xEA)
            if (header_block[15] == 0x05)
               ;  // do nothing
    }
   else
    { header_block[0]  = 0;      // pointer to high address free memory 
      header_block[1]  = 16;     // pointer to low address free memory
      header_block[2]  = 10;     // counter time base. (from 1 to 255 second)
      header_block[3]  = 25;     // analog circuitry warm-up time     
      header_block[4]  = 22;     // day
      header_block[5]  = 6;      // month
      header_block[6]  = 8;      // year (0 to 99 from year 2000)
      header_block[7]  = 10;     // number of average readings for pressure
      header_block[8]  = 18;     // hours
      header_block[9]  = 43;     // minutes
      header_block[10] = 0;      // seconds
      header_block[11] = 0;      // reserved for future use  
      header_block[12] = 0xAA;   // start of signature. 
      header_block[13] = 0xAA;   
      header_block[14] = 0xEA; 
      header_block[15] = 0x05; 

      // write default memory header
      for (i=0; i<16; i++)
       { I2C_Write(0xff, i);   
         I2C_Write(header_block[i], i);
       }
    }
 }

// Read a parameter from the non volatile memory.
unsigned char get_header (unsigned int address)
 { // Initialize I2C in master mode and turn it on.
   I2C_EEPROM_Init(100000);
   // Read eeprom
   return I2C_Read (address);
 } 

