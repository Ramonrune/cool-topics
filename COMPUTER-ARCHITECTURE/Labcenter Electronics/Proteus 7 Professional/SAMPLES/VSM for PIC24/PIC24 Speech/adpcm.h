/*****************************************************************************
*   Filename:   PCADPCM.H                                                    *
******************************************************************************
*   Author:   Rodger Richey                                                  *
*   Title:    Senior Applications Manager                                    *
*   Company:  Microchip Technology Incorporated                              *
*   Revision: 1                                                              *
*   Date:     11-11-04                                                       *
******************************************************************************
*   This is the header file that contains the ADPCM structure definition     *
*   and the function prototypes.                                             *
******************************************************************************
*   Revision 0  1/11/96                                                      *
*      Original release supporting only ADPCM using signed raw data          *
*      Compiled with Borland C++ Version 3.1                                 *
*   Revision 1  11/11/04                                                     *
*      Add CVSD, change ADPCM to support unsigned raw data                   *
*      Compiled using Borland C++ 6.0                                        *
*****************************************************************************/

struct ADPCMstate {
   unsigned short   prevsample;             /* Predicted sample */
   unsigned char   previndex;               /* Index into step size table */
};

/* Function prototype for the ADPCM Encoder routine */
unsigned char ADPCMEncoder(unsigned short , struct ADPCMstate *);

/* Function prototype for the ADPCM Decoder routine */
unsigned short ADPCMDecoder(unsigned char , struct ADPCMstate *);

