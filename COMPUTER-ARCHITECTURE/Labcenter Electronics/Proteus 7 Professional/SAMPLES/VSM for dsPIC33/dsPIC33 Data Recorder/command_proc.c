#include "p33FJ12GP201.h"
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "serial.h"
#include "i2c_eeprom.h"
#include "command_proc.h"
#include "timer.h"
#include "utilities.h"
#include "common.h"

char consistence_error[] = "Parameter is not within range. ";
char str1[] = " \n\r";
char str2[] = "VSM Proteus 7, dsPIC33 \n\r";
char str3[] = "Labcenter Electronics Ltd. \r";
char str4[] = "DATA RECORDER V1.0. (type h<cr> for a list of available commands)\r";
char prompt[] = "\r\n> ";

void command_processor(void)
 { char host_mode=1;
   char command;  
   char serial_in_buf [32];
   char *p, *p1;
   // Disable timer 1 
   T1CONbits.TON = 0;
   IFS0bits.T1IF = 0;
   
   p = serial_in_buf;
       
   Init_Serial (); 
   Serial_SendString (str1);
   Serial_SendString (str2);
   Serial_SendString (str3);
   Serial_SendString (str4);
   
   do
    { // send prompt ">" character to host. 
      Serial_SendString (prompt);

      while (*(p-1) !=0x0d)
       { // wait until a character is ready  
         *p = toupper(Serial_GetChar());
         // echo typed character out. (upper-case)
         Serial_PutChar(*p);
         p++;
       }   
      // end of string /NULL
      *(p--) = 0; 
      p = serial_in_buf;
      
      p1 = strtok(p, " ,");
      
      command = *p1; 
      /* ********************************************* 
         Commands parser                      
         ********************************************* */
      switch (command) 
       { case 'B':           // Set new Time-base.  <B,xx>    
            set_timebase();
            break;              
         case 'W':           // Set warm-up.     <W,xx>   
            set_warmup();
            break;
         case 'A':           // Num of average for pressure channel.  <A,xx>            
            set_average();
            break;
         case 'Q':           // Exit from host mode.    <Q>                   
            Serial_SendString ("\r\nExit from host mode.\r\n");
            host_mode = 0;
            break;
         case 'H':           // help.    <H>                   
            help();
            break;
         case 'D':           // Date.    <D,DD,MM,YY>            
            set_date();
            break;
         case 'T':           // Time.  <T,hh,mm,ss>            
            set_time();
            break;
         case 'S':           // Actual setup                
            get_setup();
            break;
         case 'E':           // Erase eeprom <E> (NOTE: delete only the address pointer).      
            erase_mem();
            break;
         case 'R':           // Read a measure from transducers.  <R,x>
            read_measure();
            break;
         case 'X':           // Transmitt data from first to last free address location.  <X> 
            dump_data();
            break;
         default:
            Serial_SendString ("\r\nCommand not found.");
            break;
        }   
      Serial_SendString ("\r\nOk");
      p = serial_in_buf;     
     } while (host_mode);
   // Erase memory pointers.
   erase_mem();
   // Close serial interface
   Close_Serial(); 
   // Enable timer 1 to run
   T1CONbits.TON = 1;
   // After this instruction we return to sleeping mode.
 }


// Set the timebase     
// SYNTAX:   <B,xxx>
//           parameter = 1 to 255 seconds
void set_timebase(void)
 { unsigned int par;
   // get the parameter 
   par = get_par();              
   // Check for consistence. Time base must be from 1 to 255. If not, does not change it.
   if ((par>0) && (par<256))
   // Set I2C in master mode and turn it on.
    { I2C_EEPROM_Init(100000);
      I2C_Write(0xff, 2);  
      I2C_Write(par, 2);  
      TMR1_Init(par);
    }
   else
    { Serial_SendString ("\r\nTime-base ");
      Serial_SendString (consistence_error);
      Serial_SendString ("1 to 255 second\r\n");
    }
 }

// Set the warp-up time     
// SYNTAX:   <W,xxx>
//           parameter = 1 to 255 ms
void set_warmup(void)
 { unsigned int par;
   // get the parameter 
   par = get_par();              
   // Check for consistence. Warm-up time must be from 1 to 255. If not, does not change it.
   if ((par>0) && (par<256))
   // Set I2C in master mode and turn it on.
    { I2C_EEPROM_Init(100000);
      I2C_Write(0xff, 3);  
      I2C_Write(par, 3);  
    }
   else
    { Serial_SendString ("\r\nWarm-up time ");
      Serial_SendString (consistence_error);
      Serial_SendString ("1 to 255 ms\r\n");
    }
 }

// Set the averages for the pressure channel.    
// SYNTAX:   <A,xx>
//           parameter = 1 to 20 averages
void set_average(void)
 { unsigned int par;
   // get the parameter 
   par = get_par();              
   // Check for consistence. Averages must be from 1 to 20. If not, does not change it.
   if ((par>0) && (par<21))
   // Set I2C in master mode and turn it on.
    { I2C_EEPROM_Init(100000);
      I2C_Write(0xff, 7);  
      I2C_Write(par, 7);  
    }
   else
    { Serial_SendString ("\r\nAverages ");
      Serial_SendString (consistence_error);
      Serial_SendString ("1 to 20\r\n");
    }
 }

// Set date. The recorder has not any built-in real time clock. It is a business of the host 
// program to sinchronize recording time to Date, Time and time-base which were programmed. 
// SYNTAX:   <D,DD,MM,YY>                   
//                      DD = 1 to 31    day  
//                      MM = 1 to 12    month
//                      YY = 0 to 99    year
void set_date(void)
 { unsigned int month, day, year;
   day = get_par();             // get month
   month = get_par();           // get month
   year = get_par();            // get year
   
   I2C_EEPROM_Init(100000);
   I2C_Write(0xff,  4);  
   I2C_Write(day,   4);  
   I2C_Write(0xff,  5);  
   I2C_Write(month, 5);  
   I2C_Write(0xff,  6);  
   I2C_Write(year,  6);  
}

// Set time. The recorder has not any built-in real time clock. It is a business of the host 
// program to synchronize recording time to Date, Time and time-base which were programmed. 
// SYNTAX:   <D,hh,mm,ss>                   
//                      hh = 0 to 23   hours  
//                      mm = 0 to 59   minutes
//                      ss = 0 to 59   seconds
void set_time(void)
 { unsigned int hours, minutes, seconds;
   char err=1;

   hours=get_par();             // get hours
   minutes=get_par();           // get minutes
   seconds=get_par();           // get seconds
   if (hours<60)
      if (minutes<60)
         if (seconds<60)
            err = 0;
   
   if (err==0)
    { I2C_EEPROM_Init(100000);
      I2C_Write(0xff,    8);  
      I2C_Write(hours,   8);  
      I2C_Write(0xff,    9);  
      I2C_Write(minutes, 9);  
      I2C_Write(0xff,    10);  
      I2C_Write(seconds, 10);  
    }
   else
    { Serial_SendString ("\r\nTime format is wrong.");
    }
 }

void get_setup(void)
 { unsigned int timebase, warmup, averages, day, month, year, hours, minutes, seconds, address;
  
   address  = get_header(0) * 256 + get_header(1);
   timebase = get_header(2);
   warmup   = get_header(3);
   averages = get_header(7);   
   day      = get_header(4); 
   month    = get_header(5); 
   year     = get_header(6); 
   hours    = get_header(8); 
   minutes  = get_header(9); 
   seconds  = get_header(10);
   
   Serial_SendString ("Free address .... = ");
   Serial_PutDec(address);
   Serial_SendString ( "(0x");
   Serial_Hexword(address);
   Serial_SendString (")\r\n");

   Serial_SendString ("Time-base ....... = ");
   Serial_PutDec(timebase);
   Serial_SendString (" seconds\r\n");
   
   Serial_SendString ("Warm-up time .... = ");
   Serial_PutDec(warmup);
   Serial_SendString (" ms\r\n");
    
   Serial_SendString ("Averages ........ = ");
   Serial_PutDec(averages);
   Serial_SendString (" averages\r\n");
   
   Serial_SendString ("Initial Date .... = ");
   Serial_PutDec(day);
   Serial_SendString (",");
   Serial_PutDec(month);
   Serial_SendString (",");
   
   if (year < 10)
      Serial_SendString ("200");
   else
      Serial_SendString ("20");
   Serial_PutDec(year);
   Serial_SendString ("\r\n");

   Serial_SendString ("Initial Time .... = ");
   if (hours < 10)
      Serial_SendString ("0");
   Serial_PutDec(hours);
   Serial_SendString (":");
   
   if (minutes < 10)
      Serial_SendString ("0");
   Serial_PutDec(minutes);
   Serial_SendString (":");
   
   if (seconds < 10)
      Serial_SendString ("0");
   Serial_PutDec(seconds);
   Serial_SendString ("\r\n");
 }


// Erase non volatile memory. 
// NOTE: it does not erase physically the whole memory, rather clears the address 
// pointer at header block address 0x0000 and 0x0001.    
// SINTAX:   <E>
//           parameter : none
void erase_mem (void)
 { I2C_EEPROM_Init(100000);
   I2C_Write(0,    0);  
   I2C_Write(0xff, 1);  
   I2C_Write(16,   1);  
 }


// Send the list of available command and their syntax.    
// SINTAX:   <H>
//           parameter : none
void help (void)
 { Serial_SendString ("\r\nSyntax of accepted commands: \r\r\n");
   Serial_SendString ("<B,xxx> ...... Set new time base. xxx=1 to 255 seconds.\r\n");
   Serial_SendString ("<W,xxx> ...... Set new warm-up time. xxx=1 to 255 ms.\r\n");
   Serial_SendString ("<A,xx> ....... Set averages number. Only for pressure channel. xxx=1 to 20 averages.\r\n");
   Serial_SendString ("<D,DD,MM,YY> . Set new Date. DD=day, MM=month, YY=year.\r\n");
   Serial_SendString ("<T,hh,mm,ss> . Set new Time. hh=hours, MM=minutes, YY=seconds.\r\n");
   Serial_SendString ("<X> .......... Sent data to host. From first to last free memory location.\r\n");
   Serial_SendString ("<S> .......... Read actual parameters setup.\r\n");
   Serial_SendString ("<E> .......... Erase eeprom.\r\n");
   Serial_SendString ("<R,x> ........ Read a transducer value. (in raw format)  x=1) Abs. Press, 2) RH, 3) Temp.\r\n");
   Serial_SendString ("<Q> .......... Exist from host mode.\r\n");
   Serial_SendString ("<H> .......... This list of commands.\r\r\n");
   Serial_SendString ("NOTE: Exit from host mode implies that eeprom is automatically erased.\r\r\n");
 }

// Read a value from selected transducer. (in raw format)     
// SYNTAX:   <R,x>
//           parameter = 1 Absolute Pressurre
//                       2 Relative Humidity
//                       3 Temperature.
void read_measure(void)
 { unsigned int par;
   unsigned int press, rh, temp;
   unsigned char avr = get_header(7); 
   // get the parameter 
   par = get_par();              
 
   switch (par)
    { case 1: 
         // Turn analog circuitry on.
         AN_SW_ON;
         // Wait for analogs to stabilize.
         delay_ms (50);   
         press = get_pressure(avr);
         Serial_SendString ( "0x");
         Serial_Hexword(press);
         Serial_SendString (" 12-bit res. scaling from 76kPa (0x0000) to 122kPa (0x0FFF)\r\n");
         break;
      case 2:
         I2C_Off();
         rh = get_humidity();
         Serial_SendString ( "0x");
         Serial_Hexword(rh);
         Serial_SendString (" 12-bit res. scaling from 1%RH (0x00C6) to 99%RH (0x0CC5)\r\n");
         break;
      case 3:    
         I2C_Off();
         temp = get_temperature();
         Serial_SendString ( "0x");
         Serial_Hexword(temp);
         Serial_SendString (" 14-bit res. scaling from -40°C (0x0062) to 120°C (0x3DBB)\r\n");
         break;
      default:
         Serial_SendString ("\r\nTransducer ");
         Serial_SendString (consistence_error);
         Serial_SendString ("1 to 3\r\n");
         break; 
    }   
 }


// Transmitt data from first to the last free address location 
// Format:  addr  press HR Temp    (data are in hex format)
// SYNTAX:   <X>
//           parameter = none
void dump_data (void)
 { unsigned int last_address, addr, value;
   last_address  = get_header(0) * 256 + get_header(1);
   
   for (addr=16; addr<last_address; addr++)
    { if (((addr-16)%6)==0)
       { // Send address 
         Serial_SendString ( "\r\n");
         Serial_SendString ( "0x");
         Serial_Hexword(addr);
         Serial_SendString ( " ");
       }  
      value = get_header(addr);
      Serial_Hexbyte(value);
      if (addr%2)
         Serial_SendString ( " ");
    }
 }

/********************************************************************
**** Low level functions ****
****************************/

// Get a parameter from command queue and returns it in decimal form
int get_par(void)
{ char * p;
  p=strtok('\0', " ,");   // p points to the string rappresenting the parameter                                /* stringa che rappresenta il parametro */
  return (atoi(p));       // return parameter as an integer  
}                   

