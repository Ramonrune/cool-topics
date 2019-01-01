 /*                     - PUTCHAR.C -

  $Id: putchar.c 1.2 1997/09/23 15:12:31 dan Exp $

  The ANSI "putchar" function delivered here is supposed to be tailored
  for the actual target hardware.  This version of putchar writes
  the argument character to a port assumed to be initiated elsewhere.
*/


#include <io6811.h>


/*
 * Use built-in serial port SCI:
 */

#define TDRE            (0x80) /* TX data empty */


/*
 * This routine must be tailored to suit the specific hardware.
 */

static int _low_level_putc(int c)
 { if (c == '\n')
      c = '\r';     

  while ((SCSR & TDRE) == 0)
    ;
  SCDR = (char) c;
  return(c);
}

/*
 * The putchar routine:
 */


int putchar(int value)
  {
    return(_low_level_putc(value));
  }
