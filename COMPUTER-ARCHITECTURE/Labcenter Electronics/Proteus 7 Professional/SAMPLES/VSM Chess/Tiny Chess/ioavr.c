/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM TINY CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                  Atmel AVR I/O Module                    *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <iom103.h>
#include "chess.h"

// LCD Driver Routines
VOID lcd_cls ();
VOID lcd_blit (WORD addr, BYTE *data, BYTE numbytes);
VOID lcd_wrcmd (BYTE cmd);
VOID lcd_wrcmd1 (BYTE cmd, BYTE arg);
VOID lcd_wrcmd2 (BYTE cmd, WORD arg);

// Keypad Scanner
BYTE scankeypad ();
VOID sleep (INT msecs);
VOID tone (WORD period, WORD cycles);

// BAUD rates for debug console
#define BAUD_9600_80		(0x30)    /* 9600 @ 8.0 MHz */
#define BAUD_2400_80            (0x32)    /* 2400 @ 8.0 MHz */

// LCD Command Codes
#define LCD_CURSOR	0x21
#define LCD_OFFSET   	0x22
#define LCD_ADDRESS	0x24
#define LCD_TEXTHOME	0x40
#define LCD_TEXTAREA    0x41
#define LCD_GFXHOME	0x42
#define LCD_GFXAREA	0x43
#define LCD_ORMODE	0x80
#define LCD_XORMODE	0x81
#define LCD_ANDMODE	0x83
#define LCD_ATTRMODE	0x84
#define LCD_DISPLAY	0x90
#define LCD_CLINES	0xA0
#define LCD_AUTOWRITE	0xB0
#define LCD_AUTOREAD	0xB1
#define LCD_AUTORESET   0xB2
#define LCD_WRITEINC	0xC0
#define LCD_READINC	0xC1
#define LCD_WRITEDEC	0xC2
#define LCD_READDEC	0xC3
#define LCD_SCREENPEEK	0xE0
#define LCD_SCREENCOPY  0xE8
#define LCD_BITSET	0xF0

// Location of LCD Hardware in external RAM
#define LCD_STATUS      *(BYTE *)(0x4100)
#define LCD_COMMAND     *(BYTE *)(0x4100)
#define LCD_DATA        *(BYTE *)(0x4000)

// Location of Chess Piece Bitmap ROM
#define LCD_BITMAPS (BYTE *)(0x2000)

// Number of timer ticks for flashing piece
#define FLASHTICKS 30

/*********************************************************************
**** Panel Interface Fuctions ****
*********************************/

VOID panel_init ()
 { // Initialize the I/O Ports and other stuff:
   MCUCR = 0xC0; // Ext RAM enable 1 wait state
   DDRB =  0xFF; // Port B is output
   DDRE =  0xE0; // Port E bits 5-7 output
   PORTD = 0xFF; // Port D Inputs, Pull-Up Mode

   TCCR0 = 3;    // Timer 0 runs at 57600 kHz
   
   // Initialize the debug console:
   UBRR = 12;		/* 4800 @ 1MHz */
   UCR = 0x08;	        /* Enable transmitter */

   // Initialize the main timer - prescaler = 8
   // TMSK2 = 2;
   
   printf("\nProteus VSM Tiny Chess\n");
 
   // Graphics screen has 32 bytes per row, and resides at address 0
   lcd_wrcmd2(LCD_GFXHOME,  0x0000);
   lcd_wrcmd2(LCD_GFXAREA, 32);
   lcd_wrcmd2(LCD_TEXTHOME, 0x2000);
   lcd_wrcmd2(LCD_TEXTAREA, 32);
   lcd_wrcmd2(LCD_OFFSET,   0x3000>>11);

   // Load custom graphic for a black square
   lcd_wrcmd2(LCD_ADDRESS,  0x3400);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);   
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);
   lcd_wrcmd1(LCD_WRITEINC, 0xFF);


   // Enable text and graphics modes, with XOR mode
   lcd_wrcmd(LCD_DISPLAY+0x0C); 
   lcd_wrcmd(LCD_XORMODE);   

 }

VOID panel_cls (VOID)
// Draw an empty board
 { COORD row, col;

   lcd_cls();

   for (row=0; row<32; row += 1)
      for (col=0; col<32; col += 4)
         if ((row & 4) ^ (col & 4))         
          { WORD addr = 0x2000 + row*32 + col;
            lcd_wrcmd2(LCD_ADDRESS, addr);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
          }

 }
        
VOID panel_draw (COORD row, COORD col, PIECE p)
// Draw  piece p at location loc.
 { BYTE *sprite = LCD_BITMAPS;
   row = (CHAR)7-row;                               // Adjust row to board matrix.  
   if ((row & 1) ^ (col & 1))
    { if ((p & 8) == WHITE)
         sprite += (p & 7) * 4 + 0x0400;            // White piece on black square
      else
         sprite += (p & 7) * 4 + 0x0000;            // Black piece on black square
    }
   else
    { if ((p & 8) == WHITE)
         sprite += (p & 7) * 4 + 0x0000;            // White piece on white square
      else
         sprite += (p & 7) * 4 + 0x0400;            // Black piece on white square
    }
   panel_blit(row, col, sprite);
 }
 
VOID panel_blit (COORD row, COORD col, BYTE *sprite)
// Low level function to draw specified sprite onto the board.
 { WORD addr = row * 1024 + col * 4;
   INT i;
   for (i=0; i<32; ++i)
    { lcd_blit(addr, sprite, 4);
      addr += 32;
      sprite += 32;
    }         
 }

BOOL panel_getmove (LOC from, LOC to)
// Polls for chess move, returns TRUE when move entered.
 { BYTE key, fdelay, fstate=0;
   PIECE p;
   
   // seed a random number generator after first user move.
   if (movecount == 1) srand (TCNT0);

   if (key=scankeypad(), key == 0xFF)
      return FALSE;

   // Store the 'from' position
   from[0] = (key / 8);
   from[1] = key % 8;
 
   // Check moving correct piece.
   p = board[7-from[0]][from[1]];
   if (p == EMPTY || p & BLACK)
      return FALSE;
   

   // Wait for key release
   fdelay = 0;
   while (scankeypad() != 0xFF)
    { if (fdelay-- == 0)
       { panel_invert(from, fstate ^= 1);
         fdelay = FLASHTICKS;
       }
    }
     
   // Wait for key press
   while ((key=scankeypad()) == 0xFF)
    { if (fdelay-- == 0)
       { panel_invert(from, fstate ^= 1);
         fdelay = FLASHTICKS;
       }
    }

   // Clear any left over inversion       
   if (fstate)
      panel_invert(from, FALSE);

   to[0] = key / 8;
   to[1] = key % 8;    

   // Convert rows from Physical Layout coords to internal
   // board matrix. 
   from[0] = 7 - from[0];
   to[0]   = 7 - to[0];

   // Wait for key release
   while (scankeypad() != 0xFF)
      ;

   return from[0] != to[0] || from[1] != to[1];
 }

VOID panel_invert (LOC loc, BYTE flag)
// Set the graphical inversion state of the specified square.
 { WORD addr = 0x2000 + loc[0]*128 + loc[1]*4;
   BYTE i, data;
   
   if ((loc[0] & 1) ^ (loc[1] & 1))         
      data = flag ? 0 : 128;  // Invert/normal for black square
   else
      data = flag ? 128 : 0;  // Invert/normal for white square 
   
   for (i=0; i<4; ++i)
    { lcd_wrcmd2(LCD_ADDRESS, addr);
      lcd_wrcmd1(LCD_WRITEINC, data);
      lcd_wrcmd1(LCD_WRITEINC, data);
      lcd_wrcmd1(LCD_WRITEINC, data);
      lcd_wrcmd1(LCD_WRITEINC, data);
      addr += 32;
    }
 }

/*********************************************************************
**** Low Level LCD Driver ****
*****************************/

VOID lcd_cls ()
// Clear graphics and text areas.
 { INT i;
   lcd_wrcmd(LCD_DISPLAY+0x00);
   lcd_wrcmd2(LCD_ADDRESS, 0);
   lcd_wrcmd(LCD_AUTOWRITE);
   for (i=0; i<0x2400; ++i)
    { while ((LCD_STATUS & 8) == 0)
        ;
      LCD_DATA = 0;
    }    
   lcd_wrcmd(LCD_AUTORESET); 
   lcd_wrcmd(LCD_DISPLAY+0x0C);
 }
   
VOID lcd_blit (WORD addr, BYTE *data, BYTE numbytes)
// Copy a sprite bitmap to the display
 { lcd_wrcmd2(LCD_ADDRESS, addr);
   lcd_wrcmd(LCD_AUTOWRITE);
   while (numbytes--)
    { while ((LCD_STATUS & 8) == 0)
        ;
      LCD_DATA = *data++;
    }
   lcd_wrcmd(LCD_AUTORESET);
 }



VOID lcd_wrcmd (BYTE cmd)
// Send a simple command
 { while ((LCD_STATUS & 1) == 0)
      ;
   LCD_COMMAND = cmd;   
 }

VOID lcd_wrcmd1 (BYTE cmd, BYTE data)
// Send a command with a byte argument
 { while ((LCD_STATUS & 2) == 0)
      ;
   LCD_DATA = data;
   while ((LCD_STATUS & 1) == 0)
      ;
   LCD_COMMAND = cmd;   
 }

VOID lcd_wrcmd2 (BYTE cmd, WORD arg)
// Send a command with a word argument
 { while ((LCD_STATUS & 2) == 0)
      ;
   LCD_DATA = arg & 0xFF;
   while ((LCD_STATUS & 2) == 0)
      ;
   LCD_DATA = arg >> 8;
   while ((LCD_STATUS & 1) == 0)
      ;
   LCD_COMMAND = cmd;   
 }


/*********************************************************************
**** Sound Effects ****
**********************/

// The Tone Generator operates using the OC1 control mechanisms on
// pins PA3 and PA7.

VOID sound_yourmove ()
 { tone(1000, 100);
//   tone(500, 200);
 }   

VOID sound_capture ()
 { tone(500, 100);
   tone(750, 75);
   tone(1000, 50);
   sleep(2000);
 }
     

VOID sound_illegal ()
 { tone(4000, 100);
 }
 
VOID tone (WORD period, WORD cycles)
// Play a simple tone.
// Use Timer 1 and its Output Capture for this purpose
 { TCCR1A = 0;
   TCCR1B = 1; 
   PORTB = 0xC0;
   while (cycles--)
    { TIFR = 0x10;
      OCR1A = TCNT1 + period;
      while ((TIFR & 0x10) == 0)
         ;
      PORTB ^= 0xF0;
    }   
   TCCR1B = 0; 
   PORTB = 0; 
 }

/*********************************************************************
**** Keyboard Scanner ****
*************************/

BYTE scankeypad ()
// Scan the keypad for a keypress.
// Return 0xFF for no press or the char pressed.
 { BYTE row,col,tmp;
   BYTE key=0xFF;

   for (col=0; col < 8; col++)
    { // Drive appropriate column low and read off the rows:
      PORTE = col<<5;
      sleep(1); // allow settling time
      tmp = PIND;
    
      // See if any row is active (low):
      for (row=0; row<8; ++row)
         if ((tmp & (1<<row)) == 0)
          { key = ((row)*8) + col;
            goto done;
          }
    }

   done: return key;
 }

VOID sleep (INT msecs)
// Sleep for specified number of milliseconds.
// We use Timer 0 and its output compare latch for this purpose.
 { while (msecs--)
    { TIFR = 0x02;      // Reset OCF0
      OCR0 = TCNT0+32;
      while ((TIFR & 0x02) == 0)
         ;
    }
 }


/*********************************************************************
**** Keyboard Scanner ****
*************************/

/*
 * Use built-in serial port SCI:
 */

#define UDRE            (0x20) /* TX data empty */


/*
 * This routine must be tailored to suit the specific hardware.
 */

static int _low_level_putc(int c)
 { if (c == '\n')
      c = '\r';     

  while ((USR & UDRE) == 0)
    ;
  UDR = (char) c;
  return(c);
}

/*
 * The putchar routine:
 */


int putchar(int value)
  {
    return(_low_level_putc(value));
  }

