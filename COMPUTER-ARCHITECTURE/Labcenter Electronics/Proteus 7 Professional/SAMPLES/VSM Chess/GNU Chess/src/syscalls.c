/***********************************************************************/
/*  This file is part of the uVision/ARM development tools             */
/*  Copyright KEIL ELEKTRONIK GmbH 2002-2004                           */
/***********************************************************************/
/*                                                                     */
/*  SYSCALLS.C:  System Calls Remapping                                */
/*                                                                     */
/***********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys\time.h>
#include <LPC21xx.H>   

#include "graphics.h"
#include "eeprom.h"

void InitSystem (void)
 { PINSEL0 = 0x00050055;           /* Enable RxD0, TxD0, RxD1 and TxD1, PWM2, SCL/SDA */
   PINSEL1 = 0x00000000;           /* No analog inputs */

   // Initialize Timer 0 to give us a simple run time meter.
   // The max run time is around 50 days!
   T0PR  = 3000;  // Prescaler makes us count in milli seconds
   T0TCR = 1;     // Ensable timer 0.

   // Initialize UART 0
   U0LCR = 0x83;                   /* 8 bits, no Parity, 1 Stop bit            */
   U0DLL = 19;                     /* 9600 Baud Rate @ 3.0MHz VPB Clock        */
   U0LCR = 0x03;                   /* DLAB = 0                                 */

   #if DEBUG
   // Initialize UART 1
   U1LCR = 0x83;                   /* 8 bits, no Parity, 1 Stop bit            */
   U1DLL = 19;                     /* 9600 Baud Rate @ 3.0MHz VPB Clock        */
   U1LCR = 0x03;                   /* DLAB = 0                                 */
   #endif

   // Initialize I2C eeprom
   eeprom_init();


   // Initialize to control the LCD panel and keypad
   panel_init();
   panel_cls();

   
 }

extern int outchar (int fd, int ch);
extern int getchar (void);

int write (int file, char * ptr, int len) {
  int i;
	
  if (file == fileno(stdout))
  	 for (i = 0; i < len; i++) outchar (0, *ptr++); 
  else if (file == fileno(stderr))
  	 for (i = 0; i < len; i++) outchar (1, *ptr++);

  return len;
}

char *gets (char *s)
 { char *p = s; 
   int c;
	do
	 { c = getchar();
	   *p++ = c;
	 }
	while (c != '\n');
	*p = 0;

	return s;
 } 

int isatty (int fd) {
  return 1;
}

int gettimeofday (struct timeval *tv, __timezone_ptr_t __tz) 
// Fake up a crude time of day result from Timer 0 which is
// set to count in milliseconds. T
 { unsigned long t = T0TC;
   tv->tv_sec = t/1000;
   tv->tv_usec = (t%1000) * 1000;
   return 0;
 }

void _exit (int n) {
label:  goto label; /* endless loop */
}


register char * stack_ptr asm ("sp");

caddr_t sbrk (int incr) {
  extern char   end asm ("end");	/* Defined by the linker */
  static char * heap_end;
         char * prev_heap_end;

  if (heap_end == NULL) heap_end = &end;
  prev_heap_end = heap_end;

  if (heap_end + incr > stack_ptr) {
    write (1, "sbrk: Heap and stack collision\n", 32);
    abort ();
  }

  heap_end += incr;

  return (caddr_t) prev_heap_end;
}
/********************************************************************
**** Low Level Serial I/O ****
*****************************/

#define CR     0x0D

int outchar (int fd, int ch)  {                  /* Write character to Serial Port    */

  switch (fd)
   { case 0 :
 	  	if (ch == '\n')  
	   	 { while (!(U0LSR & 0x20));
	    	 U0THR = CR;                          /* output CR */
	     }
	    while (!(U0LSR & 0x20));
		return (U0THR = ch);
  
     case 1 :
	  	if (ch == '\n')  
	   	 { while (!(U1LSR & 0x20));
	    	 U1THR = CR;                          /* output CR */
	     }
	    while (!(U1LSR & 0x20));
		return (U1THR = ch);
   }

  return -1;
 }


	  


int getchar (void)                      /* Read character from Serial Port   */
 { int ch;

  while (!(U0LSR & 0x01))
     ;

  if ((ch = U0RBR) == CR)
     ch = '\n';

  outchar(0, ch);

  return ch;
}
