#ifndef _MAX6675LIB_H_
#define _MAX6675LIB_H_

#include <system.h>

// global variables
bit ck_tris  @ TRISB.6;
bit cs_tris  @ TRISB.7;
bit so_tris  @ TRISB.5;
bit ck_out   @ LATB.6;
bit cs_out   @ LATB.7;
bit so_in    @ PORTB.5;
extern char isthcopen = 0;

// Macros
#define shift_left(d,in)   (d) |= (in);  (d) = (d) << 1;  

void max6675_init(void);            // MAX6675 initialization. Starts a conversion 
int max6675_read_temp (void);       // MAX6675 conversion           


#endif // _MAX6675LIB_H_
