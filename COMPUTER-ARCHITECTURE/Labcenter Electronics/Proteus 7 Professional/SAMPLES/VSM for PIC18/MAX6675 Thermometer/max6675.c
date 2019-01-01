/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****       LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                                                          *****/
/*****               Test Sample PIC18 & MAX6675                *****/
/*****         K type thermocouple high temperature meter       *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <system.h>
#include "max6675lib.h"

#pragma DATA _CONFIG2H, _WDT_OFF_2H
#pragma CLOCK_FREQ 4000000


bit disoff_tris   @ TRISB.0;
bit disoff_out    @ PORTB.0;

static char tbuff[4];
static char digit = 0;
static int  interrupt_timer = 0;
char isthcopen;
// Segments                      0     1     2     3     4     5     6     7     8     9  
unsigned char const map[10] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10};
// THC open message              N     E     P     O 
unsigned char const open[4] = {0x48, 0x06, 0x0c, 0x40};


// Interrupt servicing
void interrupt( void )
 { char mask;
   disoff_out = 1;
   // Clear Timer0 register. 
   tmr0l       = 0x00; 
   // Clear TMR0 overflow flag
   intcon.T0IF = 0;                             
   // Let's see if we've multiplexed all digits ??
   if (digit > 5) digit = 0, portc = 0x00;
   // No, we come multiplexing the actual one.
   portc = (1 << digit); 
   // Search for any trailing zero
   if      (tbuff[3] == 0 && tbuff[2] == 0) mask = 0x0c;
   else if (tbuff[3] == 0 && tbuff[2] != 0) mask = 0x08;
   else mask = 0;
   // Print relevant digit on the seven segments display   
   if (digit < 4 /*&& isthcopen == 0*/) 
    { if ((1<<digit) & mask)  portd = 0xff;   
      else                    portd = map[tbuff[digit]] | (digit == 1 ? 0: 0x80); 
    
      if (isthcopen == 1)
         portd = open[digit];  
   }
   // Print C° characters
   else if (digit == 4) portd = 0x9c;
   else if (digit == 5) portd = 0xc6;
   // Segments must be on for at least 1ms   
   delay_100us(5);
   // ...and then switch them off 
   portd = 0xff;
   // Next digit
   digit++;
   // Advance interrupt timer. 
   interrupt_timer++;
   disoff_out = 0;
   // disoff stays low for a while then goes high again. This helps getting high duty cycle.   
   delay_100us(1);
   disoff_out = 1;
 }

void init_Timer0 (void)
 { // configure Timer0
   t0con.TMR0ON  = 1;      // Enable timer
   t0con.T08BIT  = 1;      // Set 8-bit mode
   t0con.T0CS    = 0;      // Select internal clock
   t0con.PSA     = 0;      // Select prescaler
   t0con.T0PS0   = 0;      // Set 1:8 prescaler ratio
   t0con.T0PS1   = 1;  
   t0con.T0PS2   = 0;
   // Initialize timer0 counting registers
   tmr0l         = 0x00 ;  
   // enable interrupts
   intcon.T0IF   = 0;
   intcon.TMR0IE = 1;      // let's TMR0 overflow bit being enabled. 
   intcon.GIE    = 1;      // enable global interrupts
 }

// Convert an int value in four bytes bcd 
// - store bcd value in tbuff
void format (unsigned int value)
 { int tmp;
   value *= 10;
   value /= 4;
   tbuff[0] = value        % 10;
   tbuff[1] = (value/10)   % 10;
   tbuff[2] = (value/100)  % 10;
   tbuff[3] = (value/1000) % 10;
 }

void main()
 { static int data @ 0x03;
   trisd = 0;
   portd = 0xff;
   trisc = 0;
   portc = 0x00;
   // Display off output protects display being burned if anything goes wrong with microcontroller. 
   // disoff output is toggled into the Timer0 isr, unless microcontroller stops to work. 
   // In that case display drivers are disabled. 
   disoff_tris = 0;
   disoff_out  = 1;
   // initialize the Timer0.
   init_Timer0();
   // Initialize MAX6675 interface   
   max6675_init();
   while (1)
    { // Do a conversion every 450ms. The normal delay macros would have been disturbed from interrupts  
      while (interrupt_timer < 150);   
      interrupt_timer = 0;
      // We disable timer0 interrupts for a short while, such way the temperature 
      // readings acquired from MAX6675 are not disturbed from interrupts. 
      intcon.TMR0IE = 0 ;              
      data = max6675_read_temp();
      format(data);
      intcon.TMR0IE = 1;               // enable timer0 interrupts
    }
 }



