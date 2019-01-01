#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/wdt.h>
#include <util/delay.h>

int main(void)
 { DDRD = 0x00;
   DDRB = 0xFF;

   while (1)
    { PORTB = PIND;
    }
 
 
   return 0;
 }
