/******************************************************************************/
/*  This file is part of the uVision/ARM development tools                    */
/*  Copyright KEIL ELEKTRONIK GmbH 2002-2004                                  */
/******************************************************************************/
/*                                                                            */
/*  SERIAL.C:  Low Level Serial Routines                                      */
/*                                                                            */
/******************************************************************************/

#include <LPC21xx.H>                     /* LPC21xx definitions               */

#define CR     0x0D


int putchar (int ch)  {                  /* Write character to Serial Port    */

  if (ch == '\n')  {
    while (!(U1LSR & 0x20));
    U1THR = CR;                          /* output CR */
  }
  while (!(U1LSR & 0x20));
  return (U1THR = ch);
}


int getchar (void)  {                    /* Read character from Serial Port   */

  while (!(U1LSR & 0x01));

  return (U1RBR);
}
