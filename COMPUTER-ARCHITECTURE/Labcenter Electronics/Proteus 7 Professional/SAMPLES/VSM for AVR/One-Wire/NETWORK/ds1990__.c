/* Dallas Semiconductor MicroLan seral numebr recognizer
   1 Wire demo

   CodeVisionAVR C Compiler
   (C) 2000-2002 HP InfoTech S.R.L.
   www.hpinfotech.ro

   Chip: AT90S8515
   Memory Model: SMALL
   Data Stack Size: 128 bytes

   specify the port and bit used for the 1 Wire bus

   The 1-wire devices are connected to
   bit 6 of PORTA of the AT90S8515 on the STK500
   development board as follows:

   [DS1990]      [PORTA header]
    1 GND         -   9  GND
    2 DATA        -   7  PA6

   All the devices must be connected in parallel
   
   A 4.7k PULLUP RESISTOR MUST BE CONNECTED
   BETWEEN DATA (PA6) AND PORTA HEADER PIN 10 (VTG) !

   In order to use the RS232 SPARE connector
   on the STK500, the following connections must
   be made:
   [RS232 SPARE header] [PORTD header]
   RXD                - 1 PD0
   TXD                - 2 PD1
*/
#asm
    .equ __w1_port=0x1b
    .equ __w1_bit=6
#endasm

#include <1wire.h>
#include <90s8515.h>
#include <stdio.h>

#define DS1990_FAMILY_CODE 1
#define DS2405_FAMILY_CODE 5
#define DS1822_FAMILY_CODE 0x22
#define DS2430_FAMILY_CODE 0x14
#define DS1990_FAMILY_CODE 1
#define DS2431_FAMILY_CODE 0x2d
#define DS18S20_FAMILY_CODE 0x10
#define DS2433_FAMILY_CODE 0x23
#define SEARCH_ROM 0xF0

/* 1-wire devices ROM code storage area,
   9 bytes are used for each device
   (see the w1_search function description),
   but only the first 8 bytes contain the ROM code
   and CRC */
#define MAX_DEVICES 8
unsigned char rom_code[MAX_DEVICES,9];

main() {
unsigned char i,j,devices;
unsigned char n=1;
// init UART
UCR=8;
UBRR=23; // Baud=9600 @ 3.6864MHz
// print welcome message
printf("1-Wire MicroLan Net demo\n\r");

// detect how many 1 Wire devices are present on the bus
devices=w1_search(SEARCH_ROM,&rom_code[0,0]);
printf("%u device(s) found\n\r",devices);
for (i=0;i<devices;i++)
  {      
    // Acknowledge DS1990 family code.
    if (rom_code[i,0]==DS1990_FAMILY_CODE)
       printf("DS1990  #%u serial number:",n++);
    // Acknowledge DS2405s family code. 
    else if (rom_code[i,0]==DS2405_FAMILY_CODE)
       printf("DS2405  #%u serial number:",n++);
    // Acknowledge DS1822s family code. 
    else if (rom_code[i,0]==DS1822_FAMILY_CODE)
       printf("DS1822  #%u serial number:",n++);
    // Acknowledge DS2430s family code. 
    else if (rom_code[i,0]==DS2430_FAMILY_CODE)
       printf("DS2430  #%u serial number:",n++);
    // Acknowledge DS18S20s family code. 
    else if (rom_code[i,0]==DS18S20_FAMILY_CODE)
       printf("DS18S20 #%u serial number:",n++);
    // Acknowledge DS2431 family code. 
    else if (rom_code[i,0]==DS2431_FAMILY_CODE)
       printf("DS2431  #%u serial number:",n++);
    // Acknowledge DS2433 family code. 
    else if (rom_code[i,0]==DS2433_FAMILY_CODE)
       printf("DS2433  #%u serial number:",n++);
      
    for (j=1;j<=6;j++)
        printf(" %02X",rom_code[i,j]); 
    
    printf("\n\r");
    }
}
