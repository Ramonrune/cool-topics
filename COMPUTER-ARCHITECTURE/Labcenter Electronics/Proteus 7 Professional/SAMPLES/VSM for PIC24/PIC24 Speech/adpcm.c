/*****************************************************************************
*   Filename:   ADPCM.C                                                      *
******************************************************************************
*   Author:    Rodger Richey                                                 *
*   Title:     Senior Applications Manager                                   *
*   Company:   Microchip Technology Incorporated                             *
*   Revision:  1                                                             *
*   Date:      12-1-04                                                       *
******************************************************************************
*   Include files:                                                           *
*      stdio.h - Standard input/output header file                           *
*      adpcm.h - ADPCM related information header file                       *
******************************************************************************
*   This file contains the ADPCM encode and decode routines.  These          *
*   routines were obtained from the Interactive Multimedia Association's     *
*   Reference ADPCM algorithm.  This algorithm was first implemented by      *
*   Intel/DVI.                                                               *
******************************************************************************
*   Revision 0  1/11/96                                                      *
*      Original release supporting only ADPCM using signed raw data          *
*      Compiled with Borland C++ Version 3.1                                 *
*   Revision 1  11/11/04                                                     *
*      Change ADPCM to support unsigned raw data                             *
*      Compiled using Borland C++ 6.0                                        *
*****************************************************************************/

#include "adpcm.h"

/* Table of index changes */
signed char IndexTable[16] = {
    -1, -1, -1, -1, 2, 4, 6, 8,
    -1, -1, -1, -1, 2, 4, 6, 8,
};

/* Quantizer step size lookup table */
unsigned short StepSizeTable[89] = {
   7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
   19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
   50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
   130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
   337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
   876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
   2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
   5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
   15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};


/*****************************************************************************
*   ADPCMDecoder - ADPCM decoder routine                                     *
******************************************************************************
*   Input variables:                                                         *
*      unsigned char code - 8-bit number containing the 4-bit ADPCM code     *
*      struct ADPCMstate *state - ADPCM structure                            *
*   Return variables:                                                        *
*      unsigned short - 16-bit unsigned speech sample                        *
*****************************************************************************/
unsigned short ADPCMDecoder(unsigned char code, struct ADPCMstate *state)
{
   long step;		/* Quantizer step size */
   long predsample;		/* Output of ADPCM predictor */
   long diffq;		/* Dequantized predicted difference */
   char index;		/* Index into step size table */

   /* Restore previous values of predicted sample and quantizer step size index */
   predsample = (long)(state->prevsample);
   index = state->previndex;

   /* Find quantizer step size from lookup table using index */
   step = StepSizeTable[index];

   /* Inverse quantize the ADPCM code into a difference using the quantizer step size */
   diffq = step >> 3;
   if( code & 4 )
      diffq += step;
   if( code & 2 )
      diffq += step >> 1;
   if( code & 1 )
      diffq += step >> 2;

   /* Add the difference to the predicted sample */
   if( code & 8 )
      predsample -= diffq;
   else
      predsample += diffq;

   /* Check for overflow of the new predicted sample */
   if( predsample > 65535 )
      predsample = 65535;
   else if( predsample < 0 )
      predsample = 0;

   /* Find new quantizer step size by adding the old index and a
      table lookup using the ADPCM code */
   index += IndexTable[code];

   /* Check for overflow of the new quantizer step size index */
   if( index < 0 )
      index = 0;
   if( index > 88 )
      index = 88;


   /* Save predicted sample and quantizer step size index for next iteration */
   state->prevsample = (unsigned short)(predsample);
   state->previndex = index;

   /* Return the new speech sample */
   return( (unsigned short)(predsample) );

}

