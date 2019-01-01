/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM GNU CHESS SAMPLE                *****/
/*****                                                          *****/
/*****                  LPC2000 I/O Module 	                    *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <LPC21xx.H>   

#include "graphics.h"
#include "eeprom.h"

// This board structure represents the board as
// it is displayed on the LCD panel.
BOARD gfxboard;
int gocolour;

extern const BYTE lcd_bitmaps[0x4000];

// LCD Driver Routines
VOID lcd_cls ();
VOID lcd_blit (WORD addr, const BYTE *data, unsigned int numbytes);
VOID lcd_wrcmd (BYTE cmd);
VOID lcd_wrcmd1 (BYTE cmd, BYTE arg);
VOID lcd_wrcmd2 (BYTE cmd, WORD arg);
BYTE lcd_read (BOOL ctrl);
VOID lcd_write (BOOL ctrl, BYTE val);

// Keypad Scanner
int scankeypad ();
VOID sleep (INT msecs);
VOID tone (WORD period, WORD cycles);

// LCD Command Codes
#define LCD_CURSOR		0x21
#define LCD_OFFSET   	0x22
#define LCD_ADDRESS		0x24
#define LCD_TEXTHOME	   0x40
#define LCD_TEXTAREA    0x41
#define LCD_GFXHOME		0x42
#define LCD_GFXAREA		0x43
#define LCD_ORMODE		0x80
#define LCD_XORMODE		0x81
#define LCD_ANDMODE		0x83
#define LCD_ATTRMODE	0x84
#define LCD_DISPLAY		0x90
#define LCD_CLINES		0xA0
#define LCD_AUTOWRITE	0xB0
#define LCD_AUTOREAD	0xB1
#define LCD_AUTORESET   0xB2
#define LCD_WRITEINC	0xC0
#define LCD_READINC		0xC1
#define LCD_WRITEDEC	0xC2
#define LCD_READDEC		0xC3
#define LCD_SCREENPEEK	0xE0
#define LCD_SCREENCOPY  0xE8
#define LCD_BITSET		0xF0

// LCD registers
#define  CTRL 1
#define  DATA 0


// Number of timer ticks for flashing piece
#define FLASHTICKS (30)

VOID panel_init ()
 { // Initialize GPIOs
   IOSET0 = 0x0000F080;
   IODIR0 = 0x0000F000;			   /* LCD control lines P0.12 -> P0.15 are outputs */
   IODIR1 = 0xFF000000;			   /* Keypad col drive lines P1.24 -> P1.31 are outputs */

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
    { for (col=0; col<32; col += 4)
       { if ((row & 4) ^ (col & 4))         
          { WORD addr = 0x2000 + row*32 + col;
            lcd_wrcmd2(LCD_ADDRESS, addr);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
            lcd_wrcmd1(LCD_WRITEINC, 128);
          }
         gfxboard[row][col] = EMPTY;
       }
    }
 }
        
VOID panel_update (COORD row, COORD col, PIECE p)
// Draw  piece p at location loc. Only changes
// on the board are updated to the display.
 { if (gfxboard[row][col] != p)
	 { // update the display
      panel_draw(row, col, p);      

      // Test if computer takes us => capture
      if (p != EMPTY && (p & 0x08) != gocolour)                                   
         if (gfxboard[row][col] != EMPTY && (gfxboard[row][col] & 0x08) == gocolour)
            sound_capture();

      gfxboard[row][col] = p;
    }
 }


BOOL panel_getmove (INT colour, LOC from, LOC to)
// Polls for chess move in specified, returns TRUE when move entered.
 { INT key;
   BOOL fstate = FALSE;
   BYTE fdelay;
   PIECE p;
   
   gocolour = colour;

   key = scankeypad();
   if(key < 0)
      return FALSE;

   // Store the 'from' position
   from[0] = key / 8;
   from[1] = key % 8;
 
   // Check moving correct piece.
   p = gfxboard[7-from[0]][from[1]];
   if (p == EMPTY || (colour == WHITE && p & BLACK) || (colour == BLACK && !(p & BLACK)))
      return FALSE;
   
   // Wait for key release
   fdelay = 0;
   while (scankeypad() >= 0)
    { if (fdelay-- == 0)
       { panel_invert(from, fstate ^= 1);
         fdelay = FLASHTICKS;
       }
    }
     
   // Wait for key press
   while ((key=scankeypad()) < 0)
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
   while (scankeypad() >= 0)
      ;

   return from[0] != to[0] || from[1] != to[1];
 }

WORD panel_pollbtns() 
// Return bits for button states.
 { return (~IOPIN0 >> 27) & (BTN_ALL);
 }

BOOL panel_polltty() 
// Returns TRUE if UART 0 has keyboard input waiting.
 { return U0LSR & 0x01;
 }

BOOL panel_save ()
// Save position to EEPROM.
// This could be re-coded to use full FEN/EPD notation, which would
// then correctly store castling status etc.
 { INT r, c;
   for (r=0; r<8; ++r)
      for (c=0; c<8; ++c)
         eeprom_write(r*8+c, gfxboard[r][c]);
   eeprom_write(64, gocolour);
   return TRUE;
 }

BOOL panel_load ()
// Restore gfxboard from EEPRPOM
 { INT r, c;
   if (eeprom_read(0) == 0xFF)
      return FALSE;
   for (r=0; r<8; ++r)
    { for (c=0; c<8; ++c)
       { gfxboard[r][c] = eeprom_read(r*8+c);
         panel_draw(r, c, gfxboard[r][c]);
       }
    }
   gocolour = eeprom_read(64);
   return TRUE;
 }

CHAR *panel_getEPD ()
// Return the current board position in EPD notation.
 { static CHAR pcodes[16] = " PRNBQK  prnbqk ";
   static CHAR fen[64];
   CHAR *p = fen;
   INT r, c, b;
   for (r=7; r>=0; --r)
    { for (c=0; c<8; ++c)
  	   { for (b=0; c<8 && gfxboard[r][c] == 0; c++, b++)
            ;
         if (b != 0)
		    *p++ = b+'0';
		 if (c < 8)
		    *p++ = pcodes[gfxboard[r][c]];
	   }
      if (r > 0)
        *p++ = '/';
    }

   *p++ = ' ';
   *p++ = (gocolour == BLACK) ? 'b' : 'w';
   strcat(p, " KQkq - 0 1"); // Castling. en-passent info and move numbers are faked for now.
   return fen;  
 }

/*********************************************************************
**** Medium Level Support Routines ****
**************************************/

VOID panel_draw (COORD row, COORD col, PIECE p)
// Draw  piece p at location loc. Only changes
// on the board are updated to the display.
 { const BYTE *sprite = lcd_bitmaps;
   row = (CHAR)7-row;                               // Adjust row to board matrix.  
   if ((row & 1) ^ (col & 1))
    { if ((p & 8) == WHITE)
         sprite += (p & 7) * 4 + 0x0400;              // White piece on black square
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
 
VOID panel_blit (COORD row, COORD col, const BYTE *sprite)
// Low level function to draw specified sprite onto the board.
 { WORD addr = row * 1024 + col * 4;
   INT i;
   for (i=0; i<32; ++i)
    { lcd_blit(addr, sprite, 4);
      addr += 32;
      sprite += 32;
    }         
 }


VOID panel_invert (LOC loc, BOOL flag)
// Set the graphical inversion state of the specified square.
 { WORD addr = 0x2000 + loc[0]*128 + loc[1]*4;
   unsigned int i, data;
   
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
    { while ((lcd_read(CTRL) & 8) == 0)
	 	;
      lcd_write(DATA, 0);
    }    
   lcd_wrcmd(LCD_AUTORESET); 
   lcd_wrcmd(LCD_DISPLAY+0x0C);
 }
   
VOID lcd_blit (WORD addr, const BYTE *data, unsigned int numbytes)
// Copy a sprite bitmap to the display
 { lcd_wrcmd2(LCD_ADDRESS, addr);
   lcd_wrcmd(LCD_AUTOWRITE);
   while (numbytes--)
    { while ((lcd_read(CTRL) & 8) == 0)
         ;
      lcd_write(DATA, *data++);
    }
   lcd_wrcmd(LCD_AUTORESET);
 }

VOID lcd_wrcmd (BYTE cmd)
// Send a simple command
 { while ((lcd_read(CTRL) & 1) == 0)
      ;
   lcd_write(CTRL, cmd);
 }


VOID lcd_wrcmd1 (BYTE cmd, BYTE data)
// Send a command with a byte argument
 { while ((lcd_read(CTRL) & 2) == 0)
      ;
   lcd_write(DATA, data);
   while ((lcd_read(CTRL) & 1) == 0)
      ;
   lcd_write(CTRL, cmd);
 }

VOID lcd_wrcmd2 (BYTE cmd, WORD arg)
// Send a command with a word argument
 { while ((lcd_read(CTRL) & 2) == 0)
     ;
   lcd_write(DATA, arg & 0xFF);
   while ((lcd_read(CTRL) & 2) == 0)
      ;
   lcd_write(DATA, arg >> 8);
   while ((lcd_read(CTRL) & 1) == 0)
      ;
   lcd_write(CTRL, cmd);
 }

BYTE lcd_read (BOOL ctrl)
// Read and return value in LCD register (ctrl or data)
 { BYTE result;
   if (ctrl)
      IOSET0 = 0x8000;
   else
      IOCLR0 = 0x8000;
   IOCLR0 = 0x6000;    // CE = 0, RD = 0
   result = IOPIN0 >> 16;
   IOSET0 |= 0x6000;    // RD = 1, CE = 1
   return result;
 }
 
VOID lcd_write (BOOL ctrl, BYTE val)
// Write value to LCD register.
 { IODIR0 |= 0x00FF0000;  // LCD data port is output
   IOCLR0 = 0x00FF0000;
   IOSET0 = val << 16;
   if (ctrl)
      IOSET0 = 0x8000;
   else
      IOCLR0 = 0x8000;
   IOCLR0 = 0x5000;       // CE, WR = 0
   IOSET0 = 0x5000;       // CE, WR = 1
   IODIR0 &= ~0x00FF0000; // LCD data port is input
 }

/*********************************************************************
**** Sound Effects ****
**********************/

VOID sound_yourmove ()
 { tone(1000, 100);
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
// This is implemented using PWM channel 2
 { PWMTCR = 0;     // Clear PWM whilst setting match registers
   PWMPR = period/2;
   PWMMCR = 0x03; // Reset and interrupt on MR0
   PWMMR0 = 10;  // Set up 50% duty cycle
   PWMMR2 = 5;   
   PWMPCR = 0x400; // Enable PWM2
   PWMTCR = 0x09;  // PWM Enable and go

   PINSEL0 |= 0x00008000;
 
   while (cycles--)
    { while ((PWMIR & 0x1) == 0)
         ;
      PWMIR = ~0;
    }

   PWMTCR = 0x0A;  // Reset

   PINSEL0 &= ~0x00008000;

 }


/*********************************************************************
**** Keyboard Scanner ****
*************************/

int scankeypad ()
// Scan the keypad for a keypress.
// Return -1 for no press or the char pressed.
 { unsigned int row,col,tmp;
   unsigned int key;
   
   for(col=0; col<8; ++col)
    { // Drive appropriate column low and read off the rows; we rely on P1 pullup resistors
      // to pull row inputs high.
      IOSET1 = 0xFF000000;
      IOCLR1 = 0x01000000<<col;
      sleep(1); // allow settling time
      tmp = (IOPIN1 >> 16) & 0xFF;
    
      // See if any row is active (low):
      for(row=0; row<8; tmp>>=1, ++row)
       { if (!(tmp & 1))
          { key = row*8+col;
            return key;
          }
       }
    }

   return -1;
}

VOID sleep (INT msecs)
// Sleep for specified number of milliseconds.
// Implemented using timer 1.
 { T1PR  = 3000;  // Prescaler makes us count in milli seconds
   T1TC  = 0;
   T1TCR = 1;     // Ensable timer 0.

   while (T1TC <= msecs)
      ;

   T1TCR = 0;
 }

