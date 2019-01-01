/*-------------------------------------------------------------------------
 * $Id$
 * MPLAB-Cxx  PIC24FJ128GA010 processor header
 *
 * (c) Copyright 1999-2006 Microchip Technology, All rights reserved
 *-------------------------------------------------------------------------*/

#ifndef __24FJ128GA010_H
#define __24FJ128GA010_H

extern volatile unsigned int  WREG0 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG1 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG2 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG3 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG4 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG5 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG6 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG7 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG8 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG9 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG10 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG11 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG12 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG13 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG14 __attribute__((__sfr__,__deprecated__,__unsafe__));
extern volatile unsigned int  WREG15 __attribute__((__sfr__,__deprecated__,__unsafe__));
/* SPLIM: Stack Pointer Limit */
extern volatile unsigned int  SPLIM __attribute__((__sfr__));
extern volatile unsigned int  PCL __attribute__((__sfr__));
extern volatile unsigned char PCH __attribute__((__sfr__));
extern volatile unsigned char TBLPAG __attribute__((__sfr__));
extern volatile unsigned char PSVPAG __attribute__((__sfr__));
extern volatile unsigned int  RCOUNT __attribute__((__sfr__));
extern volatile unsigned int  SR __attribute__((__sfr__));
extern volatile union {
  struct {
    unsigned C:1;
    unsigned Z:1; /* Sticky Zero flag */
    unsigned OV:1;
    unsigned N:1;
    unsigned RA:1;
    unsigned IPL0:1;
    unsigned IPL1:1;
    unsigned IPL2:1;
    unsigned DC:1;
  };
  struct {
    unsigned :5;
    unsigned IP:3;
  };
} SRbits __attribute__((__sfr__));

extern volatile unsigned char CORCON __attribute__((__sfr__));
extern volatile struct {
  unsigned :2;
  unsigned PSV:1;
  unsigned IP3:1;
} CORCONbits __attribute__((__sfr__));

extern volatile unsigned int  DISICNT __attribute__((__sfr__));
extern          unsigned int  CNEN1 __attribute__((__sfr__));
extern          struct {
  unsigned CN0IE:1;
  unsigned CN1IE:1;
  unsigned CN2IE:1;
  unsigned CN3IE:1;
  unsigned CN4IE:1;
  unsigned CN5IE:1;
  unsigned CN6IE:1;
  unsigned CN7IE:1;
  unsigned CN8IE:1;
  unsigned CN9IE:1;
  unsigned CN10IE:1;
  unsigned CN11IE:1;
  unsigned CN12IE:1;
  unsigned CN13IE:1;
  unsigned CN14IE:1;
  unsigned CN15IE:1;
} CNEN1bits __attribute__((__sfr__));

extern          unsigned int  CNEN2 __attribute__((__sfr__));
extern          struct {
  unsigned CN16IE:1;
  unsigned CN17IE:1;
  unsigned CN18IE:1;
  unsigned CN19IE:1;
  unsigned CN20IE:1;
  unsigned CN21IE:1;
} CNEN2bits __attribute__((__sfr__));

extern          unsigned int  CNPU1 __attribute__((__sfr__));
extern          struct {
  unsigned CN0PUE:1;
  unsigned CN1PUE:1;
  unsigned CN2PUE:1;
  unsigned CN3PUE:1;
  unsigned CN4PUE:1;
  unsigned CN5PUE:1;
  unsigned CN6PUE:1;
  unsigned CN7PUE:1;
  unsigned CN8PUE:1;
  unsigned CN9PUE:1;
  unsigned CN10PUE:1;
  unsigned CN11PUE:1;
  unsigned CN12PUE:1;
  unsigned CN13PUE:1;
  unsigned CN14PUE:1;
  unsigned CN15PUE:1;
} CNPU1bits __attribute__((__sfr__));

extern          unsigned int  CNPU2 __attribute__((__sfr__));
extern          struct {
  unsigned CN16PUE:1;
  unsigned CN17PUE:1;
  unsigned CN18PUE:1;
  unsigned CN19PUE:1;
  unsigned CN20PUE:1;
  unsigned CN21PUE:1;
} CNPU2bits __attribute__((__sfr__));

extern          unsigned int  INTCON1 __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned OSCFAIL:1;
  unsigned STKERR:1;
  unsigned ADDRERR:1;
  unsigned MATHERR:1;
  unsigned :10;
  unsigned NSTDIS:1;
} INTCON1bits __attribute__((__sfr__));

extern          unsigned int  INTCON2 __attribute__((__sfr__));
extern          struct {
  unsigned INT0EP:1;
  unsigned INT1EP:1;
  unsigned INT2EP:1;
  unsigned INT3EP:1;
  unsigned INT4EP:1;
  unsigned :9;
  unsigned DISI:1;
  unsigned ALTIVT:1;
} INTCON2bits __attribute__((__sfr__));

extern volatile unsigned int  IFS0 __attribute__((__sfr__));
extern volatile struct {
  unsigned INT0IF:1;
  unsigned IC1IF:1;
  unsigned OC1IF:1;
  unsigned T1IF:1;
  unsigned :1;
  unsigned IC2IF:1;
  unsigned OC2IF:1;
  unsigned T2IF:1;
  unsigned T3IF:1;
  unsigned SPF1IF:1;
  unsigned SPI1IF:1;
  unsigned U1RXIF:1;
  unsigned U1TXIF:1;
  unsigned AD1IF:1;
} IFS0bits __attribute__((__sfr__));

extern volatile unsigned int  IFS1 __attribute__((__sfr__));
extern volatile struct {
  unsigned SI2C1IF:1;
  unsigned MI2C1IF:1;
  unsigned CMIF:1;
  unsigned CNIF:1;
  unsigned INT1IF:1;
  unsigned :4;
  unsigned OC3IF:1;
  unsigned OC4IF:1;
  unsigned T4IF:1;
  unsigned T5IF:1;
  unsigned INT2IF:1;
  unsigned U2RXIF:1;
  unsigned U2TXIF:1;
} IFS1bits __attribute__((__sfr__));

extern volatile unsigned int  IFS2 __attribute__((__sfr__));
extern volatile struct {
  unsigned SPF2IF:1;
  unsigned SPI2IF:1;
  unsigned :3;
  unsigned IC3IF:1;
  unsigned IC4IF:1;
  unsigned IC5IF:1;
  unsigned :1;
  unsigned OC5IF:1;
  unsigned :3;
  unsigned PMPIF:1;
} IFS2bits __attribute__((__sfr__));

extern volatile unsigned int  IFS3 __attribute__((__sfr__));
extern volatile struct {
  unsigned :1;
  unsigned SI2C2IF:1;
  unsigned MI2C2IF:1;
  unsigned :2;
  unsigned INT3IF:1;
  unsigned INT4IF:1;
  unsigned :7;
  unsigned RTCIF:1;
} IFS3bits __attribute__((__sfr__));

extern volatile unsigned int  IFS4 __attribute__((__sfr__));
extern volatile struct {
  unsigned :1;
  unsigned U1ERIF:1;
  unsigned U2ERIF:1;
  unsigned CRCIF:1;
} IFS4bits __attribute__((__sfr__));

extern          unsigned int  IEC0 __attribute__((__sfr__));
extern          struct {
  unsigned INT0IE:1;
  unsigned IC1IE:1;
  unsigned OC1IE:1;
  unsigned T1IE:1;
  unsigned :1;
  unsigned IC2IE:1;
  unsigned OC2IE:1;
  unsigned T2IE:1;
  unsigned T3IE:1;
  unsigned SPF1IE:1;
  unsigned SPI1IE:1;
  unsigned U1RXIE:1;
  unsigned U1TXIE:1;
  unsigned AD1IE:1;
} IEC0bits __attribute__((__sfr__));

extern          unsigned int  IEC1 __attribute__((__sfr__));
extern          struct {
  unsigned SI2C1IE:1;
  unsigned MI2C1IE:1;
  unsigned CMIE:1;
  unsigned CNIE:1;
  unsigned INT1IE:1;
  unsigned :4;
  unsigned OC3IE:1;
  unsigned OC4IE:1;
  unsigned T4IE:1;
  unsigned T5IE:1;
  unsigned INT2IE:1;
  unsigned U2RXIE:1;
  unsigned U2TXIE:1;
} IEC1bits __attribute__((__sfr__));

extern          unsigned int  IEC2 __attribute__((__sfr__));
extern          struct {
  unsigned SPF2IE:1;
  unsigned SPI2IE:1;
  unsigned :3;
  unsigned IC3IE:1;
  unsigned IC4IE:1;
  unsigned IC5IE:1;
  unsigned :1;
  unsigned OC5IE:1;
  unsigned :3;
  unsigned PMPIE:1;
} IEC2bits __attribute__((__sfr__));

extern          unsigned int  IEC3 __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned SI2C2IE:1;
  unsigned MI2C2IE:1;
  unsigned :2;
  unsigned INT3IE:1;
  unsigned INT4IE:1;
  unsigned :7;
  unsigned RTCIE:1;
} IEC3bits __attribute__((__sfr__));

extern          unsigned int  IEC4 __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned U1ERIE:1;
  unsigned U2ERIE:1;
  unsigned CRCIE:1;
} IEC4bits __attribute__((__sfr__));

extern          unsigned int  IPC0 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned INT0IP0:1;
    unsigned INT0IP1:1;
    unsigned INT0IP2:1;
    unsigned :1;
    unsigned IC1IP0:1;
    unsigned IC1IP1:1;
    unsigned IC1IP2:1;
    unsigned :1;
    unsigned OC1IP0:1;
    unsigned OC1IP1:1;
    unsigned OC1IP2:1;
    unsigned :1;
    unsigned T1IP0:1;
    unsigned T1IP1:1;
    unsigned T1IP2:2;
  };
  struct {
    unsigned INT0IP:3;
    unsigned :1;
    unsigned IC1IP:3;
    unsigned :1;
    unsigned OC1IP:3;
    unsigned :1;
    unsigned T1IP:3;
  };
} IPC0bits __attribute__((__sfr__));

extern          unsigned int  IPC1 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned IC2IP0:1;
    unsigned IC2IP1:1;
    unsigned IC2IP2:1;
    unsigned :1;
    unsigned OC2IP0:1;
    unsigned OC2IP1:1;
    unsigned OC2IP2:1;
    unsigned :1;
    unsigned T2IP0:1;
    unsigned T2IP1:1;
    unsigned T2IP2:1;
  };
  struct {
    unsigned :4;
    unsigned IC2IP:3;
    unsigned :1;
    unsigned OC2IP:3;
    unsigned :1;
    unsigned T2IP:3;
  };
} IPC1bits __attribute__((__sfr__));

extern          unsigned int  IPC2 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned T3IP0:1;
    unsigned T3IP1:1;
    unsigned T3IP2:1;
    unsigned :1;
    unsigned SPF1IP0:1;
    unsigned SPF1IP1:1;
    unsigned SPF1IP2:1;
    unsigned :1;
    unsigned SPI1IP0:1;
    unsigned SPI1IP1:1;
    unsigned SPI1IP2:1;
    unsigned :1;
    unsigned U1RXIP0:1;
    unsigned U1RXIP1:1;
    unsigned U1RXIP2:1;
  };
  struct {
    unsigned T3IP:3;
    unsigned :1;
    unsigned SPF1IP:3;
    unsigned :1;
    unsigned SPI1IP:3;
    unsigned :1;
    unsigned U1RXIP:3;
  };
} IPC2bits __attribute__((__sfr__));

extern          unsigned int  IPC3 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned U1TXIP0:1;
    unsigned U1TXIP1:1;
    unsigned U1TXIP2:1;
    unsigned :1;
    unsigned AD1IP0:1;
    unsigned AD1IP1:1;
    unsigned AD1IP2:1;
  };
  struct {
    unsigned U1TXIP:3;
    unsigned :1;
    unsigned AD1IP:3;
  };
} IPC3bits __attribute__((__sfr__));

extern          unsigned int  IPC4 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned SI2C1P0:1;
    unsigned SI2C1P1:1;
    unsigned SI2C1P2:1;
    unsigned :1;
    unsigned MI2C1P0:1;
    unsigned MI2C1P1:1;
    unsigned MI2C1P2:1;
    unsigned :1;
    unsigned CMIP0:1;
    unsigned CMIP1:1;
    unsigned CMIP2:1;
    unsigned :1;
    unsigned CNIP0:1;
    unsigned CNIP1:1;
    unsigned CNIP2:1;
  };
  struct {
    unsigned SI2C1P:3;
    unsigned :1;
    unsigned MI2C1P:3;
    unsigned :1;
    unsigned CMIP:3;
    unsigned :1;
    unsigned CNIP:3;
  };
} IPC4bits __attribute__((__sfr__));

extern          unsigned int  IPC5 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned INT1IP0:1;
    unsigned INT1IP1:1;
    unsigned INT1IP2:1;
  };
  struct {
    unsigned INT1IP:3;
  };
} IPC5bits __attribute__((__sfr__));

extern          unsigned int  IPC6 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned OC3IP0:1;
    unsigned OC3IP1:1;
    unsigned OC3IP2:1;
    unsigned :1;
    unsigned OC4IP0:1;
    unsigned OC4IP1:1;
    unsigned OC4IP2:1;
    unsigned :1;
    unsigned T4IP0:1;
    unsigned T4IP1:1;
    unsigned T4IP2:1;
  };
  struct {
    unsigned :4;
    unsigned OC3IP:3;
    unsigned :1;
    unsigned OC4IP:3;
    unsigned :1;
    unsigned T4IP:3;
  };
} IPC6bits __attribute__((__sfr__));

extern          unsigned int  IPC7 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned T5IP0:1;
    unsigned T5IP1:1;
    unsigned T5IP2:1;
    unsigned :1;
    unsigned INT2IP0:1;
    unsigned INT2IP1:1;
    unsigned INT2IP2:1;
    unsigned :1;
    unsigned U2RXIP0:1;
    unsigned U2RXIP1:1;
    unsigned U2RXIP2:1;
    unsigned :1;
    unsigned U2TXIP0:1;
    unsigned U2TXIP1:1;
    unsigned U2TXIP2:1;
  };
  struct {
    unsigned T5IP:3;
    unsigned :1;
    unsigned INT2IP:3;
    unsigned :1;
    unsigned U2RXIP:3;
    unsigned :1;
    unsigned U2TXIP:3;
  };
} IPC7bits __attribute__((__sfr__));

extern          unsigned int  IPC8 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned SPF2IP0:1;
    unsigned SPF2IP1:1;
    unsigned SPF2IP2:1;
    unsigned :1;
    unsigned SPI2IP0:1;
    unsigned SPI2IP1:1;
    unsigned SPI2IP2:1;
  };
  struct {
    unsigned SPF2IP:3;
    unsigned :1;
    unsigned SPI2IP:3;
  };
} IPC8bits __attribute__((__sfr__));

extern          unsigned int  IPC9 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned IC3IP0:1;
    unsigned IC3IP1:1;
    unsigned IC3IP2:2;
    unsigned :1;
    unsigned IC4IP0:1;
    unsigned IC4IP1:1;
    unsigned IC4IP2:1;
    unsigned :1;
    unsigned IC5IP0:1;
    unsigned IC5IP1:1;
    unsigned IC5IP2:1;
  };
  struct {
    unsigned :4;
    unsigned IC3IP:3;
    unsigned :1;
    unsigned IC4IP:3;
    unsigned :1;
    unsigned IC5IP:3;
  };
} IPC9bits __attribute__((__sfr__));

extern          unsigned int  IPC10 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned OC5IP0:1;
    unsigned OC5IP1:1;
    unsigned OC5IP2:1;
  };
  struct {
    unsigned :4;
    unsigned OC5IP:3;
  };
} IPC10bits __attribute__((__sfr__));

extern          unsigned int  IPC11 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned PMPIP0:1;
    unsigned PMPIP1:1;
    unsigned PMPIP2:1;
  };
  struct {
    unsigned :4;
    unsigned PMPIP:3;
  };
} IPC11bits __attribute__((__sfr__));

extern          unsigned int  IPC12 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned SI2C2P0:1;
    unsigned SI2C2P1:1;
    unsigned SI2C2P2:1;
    unsigned :1;
    unsigned MI2C2P0:1;
    unsigned MI2C2P1:1;
    unsigned MI2C2P2:1;
  };
  struct {
    unsigned :4;
    unsigned SI2C2P:3;
    unsigned :1;
    unsigned MI2C2P:3;
  };
} IPC12bits __attribute__((__sfr__));

extern          unsigned int  IPC13 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned INT3IP0:1;
    unsigned INT3IP1:1;
    unsigned INT3IP2:1;
    unsigned :1;
    unsigned INT4IP0:1;
    unsigned INT4IP1:1;
    unsigned INT4IP2:1;
  };
  struct {
    unsigned :4;
    unsigned INT3IP:3;
    unsigned :1;
    unsigned INT4IP:3;
  };
} IPC13bits __attribute__((__sfr__));

extern          unsigned int  IPC15 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :8;
    unsigned RTCIP0:1;
    unsigned RTCIP1:1;
    unsigned RTCIP2:1;
  };
  struct {
    unsigned :8;
    unsigned RTCIP:3;
  };
} IPC15bits __attribute__((__sfr__));

extern          unsigned int  IPC16 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :4;
    unsigned U1ERIP0:1;
    unsigned U1ERIP1:1;
    unsigned U1ERIP2:1;
    unsigned :1;
    unsigned U2ERIP0:1;
    unsigned U2ERIP1:1;
    unsigned U2ERIP2:1;
    unsigned :1;
    unsigned CRCIP0:1;
    unsigned CRCIP1:1;
    unsigned CRCIP2:1;
  };
  struct {
    unsigned :4;
    unsigned U1ERIP:3;
    unsigned :1;
    unsigned U2ERIP:3;
    unsigned :1;
    unsigned CRCIP:3;
  };
} IPC16bits __attribute__((__sfr__));

extern volatile unsigned int  TMR1 __attribute__((__sfr__));
extern          unsigned int  PR1 __attribute__((__sfr__));
extern          unsigned int  T1CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :1;
    unsigned TCS:1;
    unsigned TSYNC:1;
    unsigned :1;
    unsigned TCKPS0:1;
    unsigned TCKPS1:1;
    unsigned TGATE:1;
    unsigned :6;
    unsigned TSIDL:1;
    unsigned :1;
    unsigned TON:1;
  };
  struct {
    unsigned :4;
    unsigned TCKPS:2;
  };
} T1CONbits __attribute__((__sfr__));

extern volatile unsigned int  TMR2 __attribute__((__sfr__));
extern volatile unsigned int  TMR3HLD __attribute__((__sfr__));
extern volatile unsigned int  TMR3 __attribute__((__sfr__));
extern          unsigned int  PR2 __attribute__((__sfr__));
extern          unsigned int  PR3 __attribute__((__sfr__));
extern          unsigned int  T2CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :1;
    unsigned TCS:1;
    unsigned :1;
    unsigned T32:1;
    unsigned TCKPS0:1;
    unsigned TCKPS1:1;
    unsigned TGATE:1;
    unsigned :6;
    unsigned TSIDL:1;
    unsigned :1;
    unsigned TON:1;
  };
  struct {
    unsigned :4;
    unsigned TCKPS:2;
  };
} T2CONbits __attribute__((__sfr__));

extern          unsigned int  T3CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :1;
    unsigned TCS:1;
    unsigned :2;
    unsigned TCKPS0:1;
    unsigned TCKPS1:1;
    unsigned TGATE:1;
    unsigned :6;
    unsigned TSIDL:1;
    unsigned :1;
    unsigned TON:1;
  };
  struct {
    unsigned :4;
    unsigned TCKPS:2;
  };
} T3CONbits __attribute__((__sfr__));

extern volatile unsigned int  TMR4 __attribute__((__sfr__));
extern volatile unsigned int  TMR5HLD __attribute__((__sfr__));
extern volatile unsigned int  TMR5 __attribute__((__sfr__));
extern          unsigned int  PR4 __attribute__((__sfr__));
extern          unsigned int  PR5 __attribute__((__sfr__));
extern          unsigned int  T4CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :1;
    unsigned TCS:1;
    unsigned :1;
    unsigned T32:1;
    unsigned TCKPS0:1;
    unsigned TCKPS1:1;
    unsigned TGATE:1;
    unsigned :6;
    unsigned TSIDL:1;
    unsigned :1;
    unsigned TON:1;
  };
  struct {
    unsigned :4;
    unsigned TCKPS:2;
  };
} T4CONbits __attribute__((__sfr__));

extern          unsigned int  T5CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :1;
    unsigned TCS:1;
    unsigned :2;
    unsigned TCKPS0:1;
    unsigned TCKPS1:1;
    unsigned TGATE:1;
    unsigned :6;
    unsigned TSIDL:1;
    unsigned :1;
    unsigned TON:1;
  };
  struct {
    unsigned :4;
    unsigned TCKPS:2;
  };
} T5CONbits __attribute__((__sfr__));


/* Generic structure of entire SFR area for each Input Capture module */
typedef struct tagIC {
        unsigned int icxbuf;
        unsigned int icxcon;
} IC, *PIC;

/* SFR blocks for each Input Capture module */
extern volatile IC IC1 __attribute__((__sfr__));
extern volatile IC IC2 __attribute__((__sfr__));
extern volatile IC IC3 __attribute__((__sfr__));
extern volatile IC IC4 __attribute__((__sfr__));
extern volatile IC IC5 __attribute__((__sfr__));

extern volatile unsigned int  IC1BUF __attribute__((__sfr__));
extern          unsigned int  IC1CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ICM0:1;
    unsigned ICM1:1;
    unsigned ICM2:1;
    unsigned ICBNE:1;
    unsigned ICOV:1;
    unsigned ICI0:1;
    unsigned ICI1:1;
    unsigned ICTMR:1;
    unsigned :5;
    unsigned ICSIDL:1;
  };
  struct {
    unsigned ICM:3;
    unsigned :2;
    unsigned ICI:2;
  };
} IC1CONbits __attribute__((__sfr__));

extern volatile unsigned int  IC2BUF __attribute__((__sfr__));
extern          unsigned int  IC2CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ICM0:1;
    unsigned ICM1:1;
    unsigned ICM2:1;
    unsigned ICBNE:1;
    unsigned ICOV:1;
    unsigned ICI0:1;
    unsigned ICI1:1;
    unsigned ICTMR:1;
    unsigned :5;
    unsigned ICSIDL:1;
  };
  struct {
    unsigned ICM:3;
    unsigned :2;
    unsigned ICI:2;
  };
} IC2CONbits __attribute__((__sfr__));

extern volatile unsigned int  IC3BUF __attribute__((__sfr__));
extern          unsigned int  IC3CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ICM0:1;
    unsigned ICM1:1;
    unsigned ICM2:1;
    unsigned ICBNE:1;
    unsigned ICOV:1;
    unsigned ICI0:1;
    unsigned ICI1:1;
    unsigned ICTMR:1;
    unsigned :5;
    unsigned ICSIDL:1;
  };
  struct {
    unsigned ICM:3;
    unsigned :2;
    unsigned ICI:2;
  };
} IC3CONbits __attribute__((__sfr__));

extern volatile unsigned int  IC4BUF __attribute__((__sfr__));
extern          unsigned int  IC4CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ICM0:1;
    unsigned ICM1:1;
    unsigned ICM2:1;
    unsigned ICBNE:1;
    unsigned ICOV:1;
    unsigned ICI0:1;
    unsigned ICI1:1;
    unsigned ICTMR:1;
    unsigned :5;
    unsigned ICSIDL:1;
  };
  struct {
    unsigned ICM:3;
    unsigned :2;
    unsigned ICI:2;
  };
} IC4CONbits __attribute__((__sfr__));

extern volatile unsigned int  IC5BUF __attribute__((__sfr__));
extern          unsigned int  IC5CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ICM0:1;
    unsigned ICM1:1;
    unsigned ICM2:1;
    unsigned ICBNE:1;
    unsigned ICOV:1;
    unsigned ICI0:1;
    unsigned ICI1:1;
    unsigned ICTMR:1;
    unsigned :5;
    unsigned ICSIDL:1;
  };
  struct {
    unsigned ICM:3;
    unsigned :2;
    unsigned ICI:2;
  };
} IC5CONbits __attribute__((__sfr__));


/* Generic structure of entire SFR area for each Output Compare module */
typedef struct tagOC {
        unsigned int ocxrs;
        unsigned int ocxr;
        unsigned int ocxcon;
} OC, *POC;

/* SFR blocks for each Output Compare module */
extern volatile OC OC1 __attribute__((__sfr__));
extern volatile OC OC2 __attribute__((__sfr__));
extern volatile OC OC3 __attribute__((__sfr__));
extern volatile OC OC4 __attribute__((__sfr__));
extern volatile OC OC5 __attribute__((__sfr__));

extern volatile unsigned int  OC1RS __attribute__((__sfr__));
extern volatile unsigned int  OC1R __attribute__((__sfr__));
extern          unsigned int  OC1CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OCM:3;
    unsigned OCTSEL:1;
    unsigned OCFLT:1;
    unsigned :8;
    unsigned OCSIDL:1;
  };
  struct {
    unsigned OCM0:1;
    unsigned OCM1:1;
    unsigned OCM2:2;
  };
} OC1CONbits __attribute__((__sfr__));

extern volatile unsigned int  OC2RS __attribute__((__sfr__));
extern volatile unsigned int  OC2R __attribute__((__sfr__));
extern          unsigned int  OC2CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OCM:3;
    unsigned OCTSEL:1;
    unsigned OCFLT:1;
    unsigned :8;
    unsigned OCSIDL:1;
  };
  struct {
    unsigned OCM0:1;
    unsigned OCM1:1;
    unsigned OCM2:1;
  };
} OC2CONbits __attribute__((__sfr__));

extern volatile unsigned int  OC3RS __attribute__((__sfr__));
extern volatile unsigned int  OC3R __attribute__((__sfr__));
extern          unsigned int  OC3CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OCM:3;
    unsigned OCTSEL:1;
    unsigned OCFLT:1;
    unsigned :8;
    unsigned OCSIDL:1;
  };
  struct {
    unsigned OCM0:1;
    unsigned OCM1:1;
    unsigned OCM2:2;
  };
} OC3CONbits __attribute__((__sfr__));

extern volatile unsigned int  OC4RS __attribute__((__sfr__));
extern volatile unsigned int  OC4R __attribute__((__sfr__));
extern          unsigned int  OC4CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OCM:3;
    unsigned OCTSEL:1;
    unsigned OCFLT:1;
    unsigned :8;
    unsigned OCSIDL:1;
  };
  struct {
    unsigned OCM0:1;
    unsigned OCM1:1;
    unsigned OCM2:1;
  };
} OC4CONbits __attribute__((__sfr__));

extern volatile unsigned int  OC5RS __attribute__((__sfr__));
extern volatile unsigned int  OC5R __attribute__((__sfr__));
extern          unsigned int  OC5CON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OCM:3;
    unsigned OCTSEL:1;
    unsigned OCFLT:1;
    unsigned :8;
    unsigned OCSIDL:1;
  };
  struct {
    unsigned OCM0:1;
    unsigned OCM1:1;
    unsigned OCM2:1;
  };
} OC5CONbits __attribute__((__sfr__));

extern volatile unsigned char I2C1RCV __attribute__((__sfr__));
extern volatile unsigned char I2C1TRN __attribute__((__sfr__));
extern          unsigned int  I2C1BRG __attribute__((__sfr__));
extern          unsigned int  I2C1CON __attribute__((__sfr__));
extern          struct {
  unsigned SEN:1;
  unsigned RSEN:1;
  unsigned PEN:1;
  unsigned RCEN:1;
  unsigned ACKEN:1;
  unsigned ACKDT:1;
  unsigned STREN:1;
  unsigned GCEN:1;
  unsigned SMEN:1;
  unsigned DISSLW:1;
  unsigned A10M:1;
  unsigned IPMIEN:1;
  unsigned SCLREL:1;
  unsigned I2CSIDL:1;
  unsigned :1;
  unsigned I2CEN:1;
} I2C1CONbits __attribute__((__sfr__));

extern          unsigned int  I2C1STAT __attribute__((__sfr__));
extern          struct {
  unsigned TBF:1;
  unsigned RBF:1;
  unsigned R_W:1;
  unsigned S:1;
  unsigned P:1;
  unsigned D_A:1;
  unsigned I2CPOV:1;
  unsigned IWCOL:1;
  unsigned ADD10:1;
  unsigned GCSTAT:1;
  unsigned BCL:1;
  unsigned :3;
  unsigned TRSTAT:1;
  unsigned ACKSTAT:1;
} I2C1STATbits __attribute__((__sfr__));

extern volatile unsigned int  I2C1ADD __attribute__((__sfr__));
extern          unsigned int  I2C1MSK __attribute__((__sfr__));
extern volatile unsigned char I2C2RCV __attribute__((__sfr__));
extern volatile unsigned char I2C2TRN __attribute__((__sfr__));
extern          unsigned int  I2C2BRG __attribute__((__sfr__));
extern          unsigned int  I2C2CON __attribute__((__sfr__));
extern          struct {
  unsigned SEN:1;
  unsigned RSEN:1;
  unsigned PEN:1;
  unsigned RCEN:1;
  unsigned ACKEN:1;
  unsigned ACKDT:1;
  unsigned STREN:1;
  unsigned GCEN:1;
  unsigned SMEN:1;
  unsigned DISSLW:1;
  unsigned A10M:1;
  unsigned IPMIEN:1;
  unsigned SCLREL:1;
  unsigned I2CSIDL:1;
  unsigned :1;
  unsigned I2CEN:1;
} I2C2CONbits __attribute__((__sfr__));

extern          unsigned int  I2C2STAT __attribute__((__sfr__));
extern          struct {
  unsigned TBF:1;
  unsigned RBF:1;
  unsigned R_W:1;
  unsigned S:1;
  unsigned P:1;
  unsigned D_A:1;
  unsigned I2CPOV:1;
  unsigned IWCOL:1;
  unsigned ADD10:1;
  unsigned GCSTAT:1;
  unsigned BCL:1;
  unsigned :3;
  unsigned TRSTAT:1;
  unsigned ACKSTAT:1;
} I2C2STATbits __attribute__((__sfr__));

extern volatile unsigned int  I2C2ADD __attribute__((__sfr__));
extern          unsigned int  I2C2MSK __attribute__((__sfr__));

/* Generic structure of entire SFR area for each UART module */
typedef struct tagUART {
        unsigned int uxmode;
        unsigned int uxsta;
        unsigned int uxtxreg;
        unsigned int uxrxreg;
        unsigned int uxbrg;
} UART, *PUART;

/* SFR blocks for each UART module */
extern volatile UART UART1 __attribute__((__sfr__));
extern volatile UART UART2 __attribute__((__sfr__));

extern          unsigned int  U1MODE __attribute__((__sfr__));
extern          union {
  struct {
    unsigned STSEL:1;
    unsigned PDSEL0:1;
    unsigned PDSEL1:1;
    unsigned BRGH:1;
    unsigned RXINV:1;
    unsigned ABAUD:1;
    unsigned LPBACK:1;
    unsigned WAKE:1;
    unsigned UEN0:1;
    unsigned UEN1:1;
    unsigned :1;
    unsigned RTSMD:1;
    unsigned IREN:1;
    unsigned USIDL:1;
    unsigned :1;
    unsigned UARTEN:1;
  };
  struct {
    unsigned :1;
    unsigned PDSEL:2;
    unsigned :5;
    unsigned UEN:2;
  };
} U1MODEbits __attribute__((__sfr__));

extern          unsigned int  U1STA __attribute__((__sfr__));
extern          union {
  struct {
    unsigned URXDA:1;
    unsigned OERR:1;
    unsigned FERR:1;
    unsigned PERR:1;
    unsigned RIDLE:1;
    unsigned ADDEN:1;
    unsigned URXISEL0:1;
    unsigned URXISEL1:1;
    unsigned TRMT:1;
    unsigned UTXBF:1;
    unsigned UTXEN:1;
    unsigned UTXBRK:1;
    unsigned :1;
    unsigned UTXISEL0:1;
    unsigned UTXINV:1;
    unsigned UTXISEL1:1;
  };
  struct {
    unsigned :6;
    unsigned URXISEL:2;
  };
} U1STAbits __attribute__((__sfr__));

extern volatile unsigned int  U1TXREG __attribute__((__sfr__));
extern volatile unsigned int  U1RXREG __attribute__((__sfr__));
extern          unsigned int  U1BRG __attribute__((__sfr__));
extern          unsigned int  U2MODE __attribute__((__sfr__));
extern          union {
  struct {
    unsigned STSEL:1;
    unsigned PDSEL0:1;
    unsigned PDSEL1:1;
    unsigned BRGH:1;
    unsigned RXINV:1;
    unsigned ABAUD:1;
    unsigned LPBACK:1;
    unsigned WAKE:1;
    unsigned UEN0:1;
    unsigned UEN1:1;
    unsigned :1;
    unsigned RTSMD:1;
    unsigned IREN:1;
    unsigned USIDL:1;
    unsigned :1;
    unsigned UARTEN:1;
  };
  struct {
    unsigned :1;
    unsigned PDSEL:2;
    unsigned :5;
    unsigned UEN:2;
  };
} U2MODEbits __attribute__((__sfr__));

extern          unsigned int  U2STA __attribute__((__sfr__));
extern          union {
  struct {
    unsigned URXDA:1;
    unsigned OERR:1;
    unsigned FERR:1;
    unsigned PERR:1;
    unsigned RIDLE:1;
    unsigned ADDEN:1;
    unsigned URXISEL0:1;
    unsigned URXISEL1:1;
    unsigned TRMT:1;
    unsigned UTXBF:1;
    unsigned UTXEN:1;
    unsigned UTXBRK:1;
    unsigned :1;
    unsigned UTXISEL0:1;
    unsigned UTXINV:1;
    unsigned UTXISEL1:1;
  };
  struct {
    unsigned :6;
    unsigned URXISEL:2;
  };
} U2STAbits __attribute__((__sfr__));

extern volatile unsigned int  U2TXREG __attribute__((__sfr__));
extern volatile unsigned int  U2RXREG __attribute__((__sfr__));
extern          unsigned int  U2BRG __attribute__((__sfr__));

/* Generic structure of entire SFR area for each SPI module */
typedef struct tagSPI {
        unsigned int spixstat;
        unsigned int spixcon;
        unsigned int spixbuf;
} SPI, *PSPI;

/* SFR blocks for each SPI module */
extern volatile SPI SPI1 __attribute__((__sfr__));
extern volatile SPI SPI2 __attribute__((__sfr__));

extern volatile unsigned int  SPI1STAT __attribute__((__sfr__));
extern volatile union {
  struct {
    unsigned SPIRBF:1;
    unsigned SPITBF:1;
    unsigned :4;
    unsigned SPIROV:1;
    unsigned :1;
    unsigned SPIBEC:3;
    unsigned :2;
    unsigned SPISIDL:1;
    unsigned :1;
    unsigned SPIEN:1;
  };
  struct {
    unsigned :8;
    unsigned SPIBEC0:1;
    unsigned SPIBEC1:1;
    unsigned SPIBEC2:1;
  };
} SPI1STATbits __attribute__((__sfr__));

extern          unsigned int  SPI1CON1 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned PPRE0:1;
    unsigned PPRE1:1;
    unsigned SPRE:3;
    unsigned MSTEN:1;
    unsigned CKP:1;
    unsigned SSEN:1;
    unsigned CKE:1;
    unsigned SMP:1;
    unsigned MODE16:1;
    unsigned DISSDO:1;
    unsigned DISSCK:1;
  };
  struct {
    unsigned PPRE:2;
    unsigned SPRE0:1;
    unsigned SPRE1:1;
    unsigned SPRE2:1;
  };
} SPI1CON1bits __attribute__((__sfr__));

extern          unsigned int  SPI1CON2 __attribute__((__sfr__));
extern          struct {
  unsigned SPIBEN:1;
  unsigned SPIFE:1;
  unsigned :11;
  unsigned SPIFPOL:1;
  unsigned SPIFSD:1;
  unsigned FRMEN:1;
} SPI1CON2bits __attribute__((__sfr__));

extern volatile unsigned int  SPI1BUF __attribute__((__sfr__));
extern volatile unsigned int  SPI2STAT __attribute__((__sfr__));
extern volatile union {
  struct {
    unsigned SPIRBF:1;
    unsigned SPITBF:1;
    unsigned :4;
    unsigned SPIROV:1;
    unsigned :1;
    unsigned SPIBEC:3;
    unsigned :2;
    unsigned SPISIDL:1;
    unsigned :1;
    unsigned SPIEN:1;
  };
  struct {
    unsigned :8;
    unsigned SPIBEC0:1;
    unsigned SPIBEC1:1;
    unsigned SPIBEC2:1;
  };
} SPI2STATbits __attribute__((__sfr__));

extern          unsigned int  SPI2CON1 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned PPRE0:1;
    unsigned PPRE1:1;
    unsigned SPRE:3;
    unsigned MSTEN:1;
    unsigned CKP:1;
    unsigned SSEN:1;
    unsigned CKE:1;
    unsigned SMP:1;
    unsigned MODE16:1;
    unsigned DISSDO:1;
    unsigned DISSCK:1;
  };
  struct {
    unsigned PPRE:2;
    unsigned SPRE0:1;
    unsigned SPRE1:1;
    unsigned SPRE2:1;
  };
} SPI2CON1bits __attribute__((__sfr__));

extern          unsigned int  SPI2CON2 __attribute__((__sfr__));
extern          struct {
  unsigned SPIBEN:1;
  unsigned SPIFE:1;
  unsigned :11;
  unsigned SPIFPOL:1;
  unsigned SPIFSD:1;
  unsigned FRMEN:1;
} SPI2CON2bits __attribute__((__sfr__));

extern volatile unsigned int  SPI2BUF __attribute__((__sfr__));
extern          unsigned int  TRISA __attribute__((__sfr__));
extern          struct {
  unsigned TRISA0:1;
  unsigned TRISA1:1;
  unsigned TRISA2:1;
  unsigned TRISA3:1;
  unsigned TRISA4:1;
  unsigned TRISA5:1;
  unsigned TRISA6:1;
  unsigned TRISA7:1;
  unsigned :1;
  unsigned TRISA9:1;
  unsigned TRISA10:1;
  unsigned :3;
  unsigned TRISA14:1;
  unsigned TRISA15:1;
} TRISAbits __attribute__((__sfr__));

extern          unsigned int  PORTA __attribute__((__sfr__));
extern          struct {
  unsigned RA0:1;
  unsigned RA1:1;
  unsigned RA2:1;
  unsigned RA3:1;
  unsigned RA4:1;
  unsigned RA5:1;
  unsigned RA6:1;
  unsigned RA7:1;
  unsigned :1;
  unsigned RA9:1;
  unsigned RA10:1;
  unsigned :3;
  unsigned RA14:1;
  unsigned RA15:1;
} PORTAbits __attribute__((__sfr__));

extern          unsigned int  LATA __attribute__((__sfr__));
extern          struct {
  unsigned LATA0:1;
  unsigned LATA1:1;
  unsigned LATA2:1;
  unsigned LATA3:1;
  unsigned LATA4:1;
  unsigned LATA5:1;
  unsigned LATA6:1;
  unsigned LATA7:1;
  unsigned :1;
  unsigned LATA9:1;
  unsigned LATA10:1;
  unsigned :3;
  unsigned LATA14:1;
  unsigned LATA15:1;
} LATAbits __attribute__((__sfr__));

extern          unsigned int  TRISB __attribute__((__sfr__));
extern          struct {
  unsigned TRISB0:1;
  unsigned TRISB1:1;
  unsigned TRISB2:1;
  unsigned TRISB3:1;
  unsigned TRISB4:1;
  unsigned TRISB5:1;
  unsigned TRISB6:1;
  unsigned TRISB7:1;
  unsigned TRISB8:1;
  unsigned TRISB9:1;
  unsigned TRISB10:1;
  unsigned TRISB11:1;
  unsigned TRISB12:1;
  unsigned TRISB13:1;
  unsigned TRISB14:1;
  unsigned TRISB15:1;
} TRISBbits __attribute__((__sfr__));

extern          unsigned int  PORTB __attribute__((__sfr__));
extern          struct {
  unsigned RB0:1;
  unsigned RB1:1;
  unsigned RB2:1;
  unsigned RB3:1;
  unsigned RB4:1;
  unsigned RB5:1;
  unsigned RB6:1;
  unsigned RB7:1;
  unsigned RB8:1;
  unsigned RB9:1;
  unsigned RB10:1;
  unsigned RB11:1;
  unsigned RB12:1;
  unsigned RB13:1;
  unsigned RB14:1;
  unsigned RB15:1;
} PORTBbits __attribute__((__sfr__));

extern          unsigned int  LATB __attribute__((__sfr__));
extern          struct {
  unsigned LATB0:1;
  unsigned LATB1:1;
  unsigned LATB2:1;
  unsigned LATB3:1;
  unsigned LATB4:1;
  unsigned LATB5:1;
  unsigned LATB6:1;
  unsigned LATB7:1;
  unsigned LATB8:1;
  unsigned LATB9:1;
  unsigned LATB10:1;
  unsigned LATB11:1;
  unsigned LATB12:1;
  unsigned LATB13:1;
  unsigned LATB14:1;
  unsigned LATB15:1;
} LATBbits __attribute__((__sfr__));

extern          unsigned int  TRISC __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned TRISC1:1;
  unsigned TRISC2:1;
  unsigned TRISC3:1;
  unsigned TRISC4:1;
  unsigned :7;
  unsigned TRISC12:1;
  unsigned TRISC13:1;
  unsigned TRISC14:1;
  unsigned TRISC15:1;
} TRISCbits __attribute__((__sfr__));

extern          unsigned int  PORTC __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned RC1:1;
  unsigned RC2:1;
  unsigned RC3:1;
  unsigned RC4:1;
  unsigned :7;
  unsigned RC12:1;
  unsigned RC13:1;
  unsigned RC14:1;
  unsigned RC15:1;
} PORTCbits __attribute__((__sfr__));

extern          unsigned int  LATC __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned LATC1:1;
  unsigned LATC2:1;
  unsigned LATC3:1;
  unsigned LATC4:1;
  unsigned :7;
  unsigned LATC12:1;
  unsigned LATC13:1;
  unsigned LATC14:1;
  unsigned LATC15:1;
} LATCbits __attribute__((__sfr__));

extern          unsigned int  TRISD __attribute__((__sfr__));
extern          struct {
  unsigned TRISD0:1;
  unsigned TRISD1:1;
  unsigned TRISD2:1;
  unsigned TRISD3:1;
  unsigned TRISD4:1;
  unsigned TRISD5:1;
  unsigned TRISD6:1;
  unsigned TRISD7:1;
  unsigned TRISD8:1;
  unsigned TRISD9:1;
  unsigned TRISD10:1;
  unsigned TRISD11:1;
  unsigned TRISD12:1;
  unsigned TRISD13:1;
  unsigned TRISD14:1;
  unsigned TRISD15:1;
} TRISDbits __attribute__((__sfr__));

extern          unsigned int  PORTD __attribute__((__sfr__));
extern          struct {
  unsigned RD0:1;
  unsigned RD1:1;
  unsigned RD2:1;
  unsigned RD3:1;
  unsigned RD4:1;
  unsigned RD5:1;
  unsigned RD6:1;
  unsigned RD7:1;
  unsigned RD8:1;
  unsigned RD9:1;
  unsigned RD10:1;
  unsigned RD11:1;
  unsigned RD12:1;
  unsigned RD13:1;
  unsigned RD14:1;
  unsigned RD15:1;
} PORTDbits __attribute__((__sfr__));

extern          unsigned int  LATD __attribute__((__sfr__));
extern          struct {
  unsigned LATD0:1;
  unsigned LATD1:1;
  unsigned LATD2:1;
  unsigned LATD3:1;
  unsigned LATD4:1;
  unsigned LATD5:1;
  unsigned LATD6:1;
  unsigned LATD7:1;
  unsigned LATD8:1;
  unsigned LATD9:1;
  unsigned LATD10:1;
  unsigned LATD11:1;
  unsigned LATD12:1;
  unsigned LATD13:1;
  unsigned LATD14:1;
  unsigned LATD15:1;
} LATDbits __attribute__((__sfr__));

extern          unsigned int  TRISE __attribute__((__sfr__));
extern          struct {
  unsigned TRISE0:1;
  unsigned TRISE1:1;
  unsigned TRISE2:1;
  unsigned TRISE3:1;
  unsigned TRISE4:1;
  unsigned TRISE5:1;
  unsigned TRISE6:1;
  unsigned TRISE7:1;
  unsigned TRISE8:1;
  unsigned TRISE9:1;
} TRISEbits __attribute__((__sfr__));

extern          unsigned int  PORTE __attribute__((__sfr__));
extern          struct {
  unsigned RE0:1;
  unsigned RE1:1;
  unsigned RE2:1;
  unsigned RE3:1;
  unsigned RE4:1;
  unsigned RE5:1;
  unsigned RE6:1;
  unsigned RE7:1;
  unsigned RE8:1;
  unsigned RE9:1;
} PORTEbits __attribute__((__sfr__));

extern          unsigned int  LATE __attribute__((__sfr__));
extern          struct {
  unsigned LATE0:1;
  unsigned LATE1:1;
  unsigned LATE2:1;
  unsigned LATE3:1;
  unsigned LATE4:1;
  unsigned LATE5:1;
  unsigned LATE6:1;
  unsigned LATE7:1;
  unsigned LATE8:1;
  unsigned LATE9:1;
} LATEbits __attribute__((__sfr__));

extern          unsigned int  TRISF __attribute__((__sfr__));
extern          struct {
  unsigned TRISF0:1;
  unsigned TRISF1:1;
  unsigned TRISF2:1;
  unsigned TRISF3:1;
  unsigned TRISF4:1;
  unsigned TRISF5:1;
  unsigned TRISF6:1;
  unsigned TRISF7:1;
  unsigned TRISF8:1;
  unsigned :3;
  unsigned TRISF12:1;
  unsigned TRISF13:1;
} TRISFbits __attribute__((__sfr__));

extern          unsigned int  PORTF __attribute__((__sfr__));
extern          struct {
  unsigned RF0:1;
  unsigned RF1:1;
  unsigned RF2:1;
  unsigned RF3:1;
  unsigned RF4:1;
  unsigned RF5:1;
  unsigned RF6:1;
  unsigned RF7:1;
  unsigned RF8:1;
  unsigned :3;
  unsigned RF12:1;
  unsigned RF13:1;
} PORTFbits __attribute__((__sfr__));

extern          unsigned int  LATF __attribute__((__sfr__));
extern          struct {
  unsigned LATF0:1;
  unsigned LATF1:1;
  unsigned LATF2:1;
  unsigned LATF3:1;
  unsigned LATF4:1;
  unsigned LATF5:1;
  unsigned LATF6:1;
  unsigned LATF7:1;
  unsigned LATF8:1;
  unsigned :3;
  unsigned LATF12:1;
  unsigned LATF13:1;
} LATFbits __attribute__((__sfr__));

extern          unsigned int  TRISG __attribute__((__sfr__));
extern          struct {
  unsigned TRISG0:1;
  unsigned TRISG1:1;
  unsigned TRISG2:1;
  unsigned TRISG3:1;
  unsigned :2;
  unsigned TRISG6:1;
  unsigned TRISG7:1;
  unsigned TRISG8:1;
  unsigned TRISG9:1;
  unsigned :2;
  unsigned TRISG12:1;
  unsigned TRISG13:1;
  unsigned TRISG14:1;
  unsigned TRISG15:1;
} TRISGbits __attribute__((__sfr__));

extern          unsigned int  PORTG __attribute__((__sfr__));
extern          struct {
  unsigned RG0:1;
  unsigned RG1:1;
  unsigned RG2:1;
  unsigned RG3:1;
  unsigned :2;
  unsigned RG6:1;
  unsigned RG7:1;
  unsigned RG8:1;
  unsigned RG9:1;
  unsigned :2;
  unsigned RG12:1;
  unsigned RG13:1;
  unsigned RG14:1;
  unsigned RG15:1;
} PORTGbits __attribute__((__sfr__));

extern          unsigned int  LATG __attribute__((__sfr__));
extern          struct {
  unsigned LATG0:1;
  unsigned LATG1:1;
  unsigned LATG2:1;
  unsigned LATG3:1;
  unsigned :2;
  unsigned LATG6:1;
  unsigned LATG7:1;
  unsigned LATG8:1;
  unsigned LATG9:1;
  unsigned :2;
  unsigned LATG12:1;
  unsigned LATG13:1;
  unsigned LATG14:1;
  unsigned LATG15:1;
} LATGbits __attribute__((__sfr__));

extern          unsigned int  PADCFG1 __attribute__((__sfr__));
extern          struct {
  unsigned PMPTTL:1;
  unsigned RTSECSEL:1;
} PADCFG1bits __attribute__((__sfr__));

extern volatile unsigned int  ADC1BUF0 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF1 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF2 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF3 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF4 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF5 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF6 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF7 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF8 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUF9 __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFA __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFB __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFC __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFD __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFE __attribute__((__sfr__));
extern volatile unsigned int  ADC1BUFF __attribute__((__sfr__));
extern          unsigned int  AD1CON1 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned DONE:1;
    unsigned SAMP:1;
    unsigned ASAM:1;
    unsigned :2;
    unsigned SSRC:3;
    unsigned FORM0:1;
    unsigned FORM1:1;
    unsigned :3;
    unsigned ADSIDL:1;
    unsigned :1;
    unsigned ADON:1;
  };
  struct {
    unsigned :5;
    unsigned SSRC0:1;
    unsigned SSRC1:1;
    unsigned SSRC2:1;
    unsigned FORM:2;
  };
} AD1CON1bits __attribute__((__sfr__));

extern          unsigned int  AD1CON2 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ALTS:1;
    unsigned BUFM:1;
    unsigned SMPI:4;
    unsigned :1;
    unsigned BUFS:1;
    unsigned :2;
    unsigned CSCNA:1;
    unsigned :2;
    unsigned VCFG:3;
  };
  struct {
    unsigned :2;
    unsigned SMPI0:1;
    unsigned SMPI1:1;
    unsigned SMPI2:1;
    unsigned SMPI3:1;
    unsigned :7;
    unsigned VCFG0:1;
    unsigned VCFG1:1;
    unsigned VCFG2:1;
  };
} AD1CON2bits __attribute__((__sfr__));

extern          unsigned int  AD1CON3 __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ADCS:8;
    unsigned SAMC:5;
    unsigned :2;
    unsigned ADRC:1;
  };
  struct {
    unsigned ADCS0:1;
    unsigned ADCS1:1;
    unsigned ADCS2:1;
    unsigned ADCS3:1;
    unsigned ADCS4:1;
    unsigned ADCS5:1;
    unsigned ADCS6:1;
    unsigned ADCS7:1;
    unsigned SAMC0:1;
    unsigned SAMC1:1;
    unsigned SAMC2:1;
    unsigned SAMC3:1;
    unsigned SAMC4:1;
  };
} AD1CON3bits __attribute__((__sfr__));

extern          unsigned int  AD1CHS __attribute__((__sfr__));
extern          union {
  struct {
    unsigned CH0SA:4;
    unsigned :3;
    unsigned CH0NA:1;
    unsigned CH0SB:4;
    unsigned :3;
    unsigned CH0NB:1;
  };
  struct {
    unsigned CH0SA0:1;
    unsigned CH0SA1:1;
    unsigned CH0SA2:1;
    unsigned CH0SA3:1;
    unsigned :4;
    unsigned CH0SB0:1;
    unsigned CH0SB1:1;
    unsigned CH0SB2:1;
    unsigned CH0SB3:1;
  };
} AD1CHSbits __attribute__((__sfr__));

extern          unsigned int  AD1PCFG __attribute__((__sfr__));
extern          struct {
  unsigned PCFG0:1;
  unsigned PCFG1:1;
  unsigned PCFG2:1;
  unsigned PCFG3:1;
  unsigned PCFG4:1;
  unsigned PCFG5:1;
  unsigned PCFG6:1;
  unsigned PCFG7:1;
  unsigned PCFG8:1;
  unsigned PCFG9:1;
  unsigned PCFG10:1;
  unsigned PCFG11:1;
  unsigned PCFG12:1;
  unsigned PCFG13:1;
  unsigned PCFG14:1;
  unsigned PCFG15:1;
} AD1PCFGbits __attribute__((__sfr__));

extern          unsigned int  AD1CSSL __attribute__((__sfr__));
extern          struct {
  unsigned CSSL0:1;
  unsigned CSSL1:1;
  unsigned CSSL2:1;
  unsigned CSSL3:1;
  unsigned CSSL4:1;
  unsigned CSSL5:1;
  unsigned CSSL6:1;
  unsigned CSSL7:1;
  unsigned CSSL8:1;
  unsigned CSSL9:1;
  unsigned CSSL10:1;
  unsigned CSSL11:1;
  unsigned CSSL12:1;
  unsigned CSSL13:1;
  unsigned CSSL14:1;
  unsigned CSSL15:1;
} AD1CSSLbits __attribute__((__sfr__));

extern          unsigned int  PMCON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned RDSP:1;
    unsigned WRSP:1;
    unsigned BEP:1;
    unsigned CS1P:1;
    unsigned CS2P:1;
    unsigned ALP:1;
    unsigned CSF0:1;
    unsigned CSF1:1;
    unsigned PTRDEN:1;
    unsigned PTWREN:1;
    unsigned PTBEEN:1;
    unsigned ADRMUX0:1;
    unsigned ADRMUX1:1;
    unsigned PSIDL:1;
    unsigned :1;
    unsigned PMPEN:1;
  };
  struct {
    unsigned :6;
    unsigned CSF:2;
    unsigned :3;
    unsigned ADRMUX:2;
  };
} PMCONbits __attribute__((__sfr__));

extern          unsigned int  PMMODE __attribute__((__sfr__));
extern          union {
  struct {
    unsigned WAITE0:1;
    unsigned WAITE1:1;
    unsigned WAITM:4;
    unsigned WAITB0:1;
    unsigned WAITB1:1;
    unsigned MODE0:1;
    unsigned MODE1:1;
    unsigned MODE16:1;
    unsigned INCM0:1;
    unsigned INCM1:1;
    unsigned IRQM0:1;
    unsigned IRQM1:1;
    unsigned BUSY:1;
  };
  struct {
    unsigned WAITE:2;
    unsigned WAITM0:1;
    unsigned WAITM1:1;
    unsigned WAITM2:1;
    unsigned WAITM3:1;
    unsigned WAITB:2;
    unsigned MODE:2;
    unsigned :1;
    unsigned INCM:2;
    unsigned IRQM:2;
  };
} PMMODEbits __attribute__((__sfr__));

extern          unsigned int  PMADDR __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :14;
    unsigned CS1:1;
    unsigned CS2:1;
  };
  struct {
    unsigned :14;
    unsigned CS:2;
  };
} PMADDRbits __attribute__((__sfr__));

extern          unsigned int  PMDOUT1 __attribute__((__sfr__));
extern          unsigned int  PMDOUT2 __attribute__((__sfr__));
extern volatile unsigned int  PMDIN1 __attribute__((__sfr__));
extern volatile unsigned int  PMDIN2 __attribute__((__sfr__));
extern          unsigned int  PMPEN __attribute__((__sfr__));
extern          struct {
  unsigned PTEN0:1;
  unsigned PTEN1:1;
  unsigned PTEN2:1;
  unsigned PTEN3:1;
  unsigned PTEN4:1;
  unsigned PTEN5:1;
  unsigned PTEN6:1;
  unsigned PTEN7:1;
  unsigned PTEN8:1;
  unsigned PTEN9:1;
  unsigned PTEN10:1;
  unsigned PTEN11:1;
  unsigned PTEN12:1;
  unsigned PTEN13:1;
  unsigned PTEN14:1;
  unsigned PTEN15:1;
} PMPENbits __attribute__((__sfr__));

extern          unsigned int  PMSTAT __attribute__((__sfr__));
extern          struct {
  unsigned OB0E:1;
  unsigned OB1E:1;
  unsigned OB2E:1;
  unsigned OB3E:1;
  unsigned :2;
  unsigned OBUF:1;
  unsigned OBE:1;
  unsigned IB0F:1;
  unsigned IB1F:1;
  unsigned IB2F:1;
  unsigned IB3F:1;
  unsigned :2;
  unsigned IBOV:1;
  unsigned IBF:1;
} PMSTATbits __attribute__((__sfr__));

extern          unsigned int  ALRMVAL __attribute__((__sfr__));
extern          unsigned int  ALCFGRPT __attribute__((__sfr__));
extern          union {
  struct {
    unsigned ARPT:8;
    unsigned ALRMPTR0:1;
    unsigned ALRMPTR1:1;
    unsigned AMASK:4;
    unsigned CHIME:1;
    unsigned ALRMEN:1;
  };
  struct {
    unsigned ARPT0:1;
    unsigned ARPT1:1;
    unsigned ARPT2:1;
    unsigned ARPT3:1;
    unsigned ARPT4:1;
    unsigned ARPT5:1;
    unsigned ARPT6:1;
    unsigned ARPT7:1;
    unsigned ALRMPTR:2;
    unsigned AMASK0:1;
    unsigned AMASK1:1;
    unsigned AMASK2:1;
    unsigned AMASK3:1;
  };
} ALCFGRPTbits __attribute__((__sfr__));

extern          unsigned int  RTCVAL __attribute__((__sfr__));
extern          unsigned int  RCFGCAL __attribute__((__sfr__));
extern          union {
  struct {
    unsigned CAL:8;
    unsigned RTCPTR0:1;
    unsigned RTCPTR1:1;
    unsigned RTCOE:1;
    unsigned HALFSEC:1;
    unsigned RTCSYNC:1;
    unsigned RTCWREN:1;
    unsigned :1;
    unsigned RTCEN:1;
  };
  struct {
    unsigned CAL0:1;
    unsigned CAL1:1;
    unsigned CAL2:1;
    unsigned CAL3:1;
    unsigned CAL4:1;
    unsigned CAL5:1;
    unsigned CAL6:1;
    unsigned CAL7:1;
    unsigned RTCPTR:2;
  };
} RCFGCALbits __attribute__((__sfr__));

extern          unsigned int  CMCON __attribute__((__sfr__));
extern          struct {
  unsigned C1POS:1;
  unsigned C1NEG:1;
  unsigned C2POS:1;
  unsigned C2NEG:1;
  unsigned C1INV:1;
  unsigned C2INV:1;
  unsigned C1OUT:1;
  unsigned C2OUT:1;
  unsigned C1OUTEN:1;
  unsigned C2OUTEN:1;
  unsigned C1EN:1;
  unsigned C2EN:1;
  unsigned C1EVT:1;
  unsigned C2EVT:1;
  unsigned :1;
  unsigned CMIDL:1;
} CMCONbits __attribute__((__sfr__));

extern          unsigned int  CVRCON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned CVR:4;
    unsigned CVRSS:1;
    unsigned CVRR:1;
    unsigned CVROE:1;
    unsigned CVREN:1;
  };
  struct {
    unsigned CVR0:1;
    unsigned CVR1:1;
    unsigned CVR2:1;
    unsigned CVR3:1;
  };
} CVRCONbits __attribute__((__sfr__));

extern          unsigned int  CRCCON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned PLEN:4;
    unsigned CRCGO:1;
    unsigned :1;
    unsigned CRCMPT:1;
    unsigned CRCFUL:1;
    unsigned VWORD:5;
    unsigned CSIDL:1;
  };
  struct {
    unsigned PLEN0:1;
    unsigned PLEN1:1;
    unsigned PLEN2:1;
    unsigned PLEN3:1;
    unsigned :4;
    unsigned VWORD0:1;
    unsigned VWORD1:1;
    unsigned VWORD2:1;
    unsigned VWORD3:1;
    unsigned VWORD4:1;
  };
} CRCCONbits __attribute__((__sfr__));

extern          unsigned int  CRCXOR __attribute__((__sfr__));
extern          unsigned int  CRCDAT __attribute__((__sfr__));
extern          unsigned int  CRCWDAT __attribute__((__sfr__));
extern          unsigned int  ODCA __attribute__((__sfr__));
extern          struct {
  unsigned ODA0:1;
  unsigned ODA1:1;
  unsigned ODA2:1;
  unsigned ODA3:1;
  unsigned ODA4:1;
  unsigned ODA5:1;
  unsigned ODA6:1;
  unsigned ODA7:1;
  unsigned :1;
  unsigned ODA9:1;
  unsigned ODA10:1;
  unsigned :3;
  unsigned ODA14:1;
  unsigned ODA15:1;
} ODCAbits __attribute__((__sfr__));

extern          unsigned int  ODCB __attribute__((__sfr__));
extern          struct {
  unsigned ODB0:1;
  unsigned ODB1:1;
  unsigned ODB2:1;
  unsigned ODB3:1;
  unsigned ODB4:1;
  unsigned ODB5:1;
  unsigned ODB6:1;
  unsigned ODB7:1;
  unsigned ODB8:1;
  unsigned ODB9:1;
  unsigned ODB10:1;
  unsigned ODB11:1;
  unsigned ODB12:1;
  unsigned ODB13:1;
  unsigned ODB14:1;
  unsigned ODB15:1;
} ODCBbits __attribute__((__sfr__));

extern          unsigned int  ODCC __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned ODC1:1;
  unsigned ODC2:1;
  unsigned ODC3:1;
  unsigned ODC4:1;
  unsigned :7;
  unsigned ODC12:1;
  unsigned ODC13:1;
  unsigned ODC14:1;
  unsigned ODC15:1;
} ODCCbits __attribute__((__sfr__));

extern          unsigned int  ODCD __attribute__((__sfr__));
extern          struct {
  unsigned ODD0:1;
  unsigned ODD1:1;
  unsigned ODD2:1;
  unsigned ODD3:1;
  unsigned ODD4:1;
  unsigned ODD5:1;
  unsigned ODD6:1;
  unsigned ODD7:1;
  unsigned ODD8:1;
  unsigned ODD9:1;
  unsigned ODD10:1;
  unsigned ODD11:1;
  unsigned ODD12:1;
  unsigned ODD13:1;
  unsigned ODD14:1;
  unsigned ODD15:1;
} ODCDbits __attribute__((__sfr__));

extern          unsigned int  ODCE __attribute__((__sfr__));
extern          struct {
  unsigned ODE0:1;
  unsigned ODE1:1;
  unsigned ODE2:1;
  unsigned ODE3:1;
  unsigned ODE4:1;
  unsigned ODE5:1;
  unsigned ODE6:1;
  unsigned ODE7:1;
  unsigned ODE8:1;
  unsigned ODE9:1;
} ODCEbits __attribute__((__sfr__));

extern          unsigned int  ODCF __attribute__((__sfr__));
extern          struct {
  unsigned ODF0:1;
  unsigned ODF1:1;
  unsigned ODF2:1;
  unsigned ODF3:1;
  unsigned ODF4:1;
  unsigned ODF5:1;
  unsigned ODF6:1;
  unsigned ODF7:1;
  unsigned ODF8:1;
  unsigned :3;
  unsigned ODF12:1;
  unsigned ODF13:1;
} ODCFbits __attribute__((__sfr__));

extern          unsigned int  ODCG __attribute__((__sfr__));
extern          struct {
  unsigned ODG0:1;
  unsigned ODG1:1;
  unsigned ODG2:1;
  unsigned ODG3:1;
  unsigned :2;
  unsigned ODG6:1;
  unsigned ODG7:1;
  unsigned ODG8:1;
  unsigned ODG9:1;
  unsigned :2;
  unsigned ODG12:1;
  unsigned ODG13:1;
  unsigned ODG14:1;
  unsigned ODG15:1;
} ODCGbits __attribute__((__sfr__));

extern          unsigned int  RCON __attribute__((__sfr__));
extern          struct {
  unsigned POR:1;
  unsigned BOR:1;
  unsigned IDLE:1;
  unsigned SLEEP:1;
  unsigned WDTO:1;
  unsigned SWDTEN:1;
  unsigned SWR:1;
  unsigned EXTR:1;
  unsigned VREGS:1;
  unsigned CM:1;
  unsigned :4;
  unsigned IOPUWR:1;
  unsigned TRAPR:1;
} RCONbits __attribute__((__sfr__));

extern          unsigned int  OSCCON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned OSWEN:1;
    unsigned SOSCEN:1;
    unsigned :1;
    unsigned CF:1;
    unsigned :1;
    unsigned LOCK:1;
    unsigned :1;
    unsigned CLKLOCK:1;
    unsigned NOSC:3;
    unsigned :1;
    unsigned COSC:3;
  };
  struct {
    unsigned :1;
    unsigned LPOSCEN:1;
    unsigned :6;
    unsigned NOSC0:1;
    unsigned NOSC1:1;
    unsigned NOSC2:1;
    unsigned :1;
    unsigned COSC0:1;
    unsigned COSC1:1;
    unsigned COSC2:1;
  };
} OSCCONbits __attribute__((__sfr__));

extern          unsigned int  CLKDIV __attribute__((__sfr__));
extern          union {
  struct {
    unsigned :8;
    unsigned RCDIV:3;
    unsigned DOZEN:1;
    unsigned DOZE:3;
    unsigned ROI:1;
  };
  struct {
    unsigned :8;
    unsigned RCDIV0:1;
    unsigned RCDIV1:1;
    unsigned RCDIV2:1;
    unsigned :1;
    unsigned DOZE0:1;
    unsigned DOZE1:1;
    unsigned DOZE2:1;
  };
} CLKDIVbits __attribute__((__sfr__));

extern          unsigned int  OSCTUN __attribute__((__sfr__));
extern          union {
  struct {
    unsigned TUN:6;
  };
  struct {
    unsigned TUN0:1;
    unsigned TUN1:1;
    unsigned TUN2:1;
    unsigned TUN3:1;
    unsigned TUN4:1;
    unsigned TUN5:1;
  };
} OSCTUNbits __attribute__((__sfr__));

extern          unsigned int  NVMCON __attribute__((__sfr__));
extern          union {
  struct {
    unsigned NVMOP:4;
    unsigned :2;
    unsigned ERASE:1;
    unsigned :6;
    unsigned WRERR:1;
    unsigned WREN:1;
    unsigned WR:1;
  };
  struct {
    unsigned NVMOP0:1;
    unsigned NVMOP1:1;
    unsigned NVMOP2:1;
    unsigned NVMOP3:1;
  };
  struct {
    unsigned PROGOP:4;
  };
  struct {
    unsigned PROGOP0:1;
    unsigned PROGOP1:1;
    unsigned PROGOP2:1;
    unsigned PROGOP3:1;
  };
} NVMCONbits __attribute__((__sfr__));

extern          unsigned char NVMKEY __attribute__((__sfr__));
extern          unsigned int  PMD1 __attribute__((__sfr__));
extern          struct {
  unsigned ADCMD:1;
  unsigned :2;
  unsigned SPI1MD:1;
  unsigned SPI2MD:1;
  unsigned U1MD:1;
  unsigned U2MD:1;
  unsigned I2C1MD:1;
  unsigned :3;
  unsigned T1MD:1;
  unsigned T2MD:1;
  unsigned T3MD:1;
  unsigned T4MD:1;
  unsigned T5MD:1;
} PMD1bits __attribute__((__sfr__));

extern          unsigned int  PMD2 __attribute__((__sfr__));
extern          struct {
  unsigned OC1MD:1;
  unsigned OC2MD:1;
  unsigned OC3MD:1;
  unsigned OC4MD:1;
  unsigned OC5MD:1;
  unsigned :3;
  unsigned IC1MD:1;
  unsigned IC2MD:1;
  unsigned IC3MD:1;
  unsigned IC4MD:1;
  unsigned IC5MD:1;
} PMD2bits __attribute__((__sfr__));

extern          unsigned int  PMD3 __attribute__((__sfr__));
extern          struct {
  unsigned :1;
  unsigned I2C2MD:1;
  unsigned :5;
  unsigned CRCPMD:1;
  unsigned PMPMD:1;
  unsigned RTCCMD:1;
  unsigned CMPMD:1;
} PMD3bits __attribute__((__sfr__));



/* ---------------------------------------------------------- */
/* Defines for unique SFR bit names                           */
/* ---------------------------------------------------------- */

/* SR */
#define _C SRbits.C
#define _Z SRbits.Z
#define _OV SRbits.OV
#define _N SRbits.N
#define _RA SRbits.RA
#define _IPL0 SRbits.IPL0
#define _IPL1 SRbits.IPL1
#define _IPL2 SRbits.IPL2
#define _DC SRbits.DC
#define _IP SRbits.IP

/* CORCON */
#define _PSV CORCONbits.PSV
#define _IP3 CORCONbits.IP3

/* CNEN1 */
#define _CN0IE CNEN1bits.CN0IE
#define _CN1IE CNEN1bits.CN1IE
#define _CN2IE CNEN1bits.CN2IE
#define _CN3IE CNEN1bits.CN3IE
#define _CN4IE CNEN1bits.CN4IE
#define _CN5IE CNEN1bits.CN5IE
#define _CN6IE CNEN1bits.CN6IE
#define _CN7IE CNEN1bits.CN7IE
#define _CN8IE CNEN1bits.CN8IE
#define _CN9IE CNEN1bits.CN9IE
#define _CN10IE CNEN1bits.CN10IE
#define _CN11IE CNEN1bits.CN11IE
#define _CN12IE CNEN1bits.CN12IE
#define _CN13IE CNEN1bits.CN13IE
#define _CN14IE CNEN1bits.CN14IE
#define _CN15IE CNEN1bits.CN15IE

/* CNEN2 */
#define _CN16IE CNEN2bits.CN16IE
#define _CN17IE CNEN2bits.CN17IE
#define _CN18IE CNEN2bits.CN18IE
#define _CN19IE CNEN2bits.CN19IE
#define _CN20IE CNEN2bits.CN20IE
#define _CN21IE CNEN2bits.CN21IE

/* CNPU1 */
#define _CN0PUE CNPU1bits.CN0PUE
#define _CN1PUE CNPU1bits.CN1PUE
#define _CN2PUE CNPU1bits.CN2PUE
#define _CN3PUE CNPU1bits.CN3PUE
#define _CN4PUE CNPU1bits.CN4PUE
#define _CN5PUE CNPU1bits.CN5PUE
#define _CN6PUE CNPU1bits.CN6PUE
#define _CN7PUE CNPU1bits.CN7PUE
#define _CN8PUE CNPU1bits.CN8PUE
#define _CN9PUE CNPU1bits.CN9PUE
#define _CN10PUE CNPU1bits.CN10PUE
#define _CN11PUE CNPU1bits.CN11PUE
#define _CN12PUE CNPU1bits.CN12PUE
#define _CN13PUE CNPU1bits.CN13PUE
#define _CN14PUE CNPU1bits.CN14PUE
#define _CN15PUE CNPU1bits.CN15PUE

/* CNPU2 */
#define _CN16PUE CNPU2bits.CN16PUE
#define _CN17PUE CNPU2bits.CN17PUE
#define _CN18PUE CNPU2bits.CN18PUE
#define _CN19PUE CNPU2bits.CN19PUE
#define _CN20PUE CNPU2bits.CN20PUE
#define _CN21PUE CNPU2bits.CN21PUE

/* INTCON1 */
#define _OSCFAIL INTCON1bits.OSCFAIL
#define _STKERR INTCON1bits.STKERR
#define _ADDRERR INTCON1bits.ADDRERR
#define _MATHERR INTCON1bits.MATHERR
#define _NSTDIS INTCON1bits.NSTDIS

/* INTCON2 */
#define _INT0EP INTCON2bits.INT0EP
#define _INT1EP INTCON2bits.INT1EP
#define _INT2EP INTCON2bits.INT2EP
#define _INT3EP INTCON2bits.INT3EP
#define _INT4EP INTCON2bits.INT4EP
#define _DISI INTCON2bits.DISI
#define _ALTIVT INTCON2bits.ALTIVT

/* IFS0 */
#define _INT0IF IFS0bits.INT0IF
#define _IC1IF IFS0bits.IC1IF
#define _OC1IF IFS0bits.OC1IF
#define _T1IF IFS0bits.T1IF
#define _IC2IF IFS0bits.IC2IF
#define _OC2IF IFS0bits.OC2IF
#define _T2IF IFS0bits.T2IF
#define _T3IF IFS0bits.T3IF
#define _SPF1IF IFS0bits.SPF1IF
#define _SPI1IF IFS0bits.SPI1IF
#define _U1RXIF IFS0bits.U1RXIF
#define _U1TXIF IFS0bits.U1TXIF
#define _AD1IF IFS0bits.AD1IF

/* IFS1 */
#define _SI2C1IF IFS1bits.SI2C1IF
#define _MI2C1IF IFS1bits.MI2C1IF
#define _CMIF IFS1bits.CMIF
#define _CNIF IFS1bits.CNIF
#define _INT1IF IFS1bits.INT1IF
#define _OC3IF IFS1bits.OC3IF
#define _OC4IF IFS1bits.OC4IF
#define _T4IF IFS1bits.T4IF
#define _T5IF IFS1bits.T5IF
#define _INT2IF IFS1bits.INT2IF
#define _U2RXIF IFS1bits.U2RXIF
#define _U2TXIF IFS1bits.U2TXIF

/* IFS2 */
#define _SPF2IF IFS2bits.SPF2IF
#define _SPI2IF IFS2bits.SPI2IF
#define _IC3IF IFS2bits.IC3IF
#define _IC4IF IFS2bits.IC4IF
#define _IC5IF IFS2bits.IC5IF
#define _OC5IF IFS2bits.OC5IF
#define _PMPIF IFS2bits.PMPIF

/* IFS3 */
#define _SI2C2IF IFS3bits.SI2C2IF
#define _MI2C2IF IFS3bits.MI2C2IF
#define _INT3IF IFS3bits.INT3IF
#define _INT4IF IFS3bits.INT4IF
#define _RTCIF IFS3bits.RTCIF

/* IFS4 */
#define _U1ERIF IFS4bits.U1ERIF
#define _U2ERIF IFS4bits.U2ERIF
#define _CRCIF IFS4bits.CRCIF

/* IEC0 */
#define _INT0IE IEC0bits.INT0IE
#define _IC1IE IEC0bits.IC1IE
#define _OC1IE IEC0bits.OC1IE
#define _T1IE IEC0bits.T1IE
#define _IC2IE IEC0bits.IC2IE
#define _OC2IE IEC0bits.OC2IE
#define _T2IE IEC0bits.T2IE
#define _T3IE IEC0bits.T3IE
#define _SPF1IE IEC0bits.SPF1IE
#define _SPI1IE IEC0bits.SPI1IE
#define _U1RXIE IEC0bits.U1RXIE
#define _U1TXIE IEC0bits.U1TXIE
#define _AD1IE IEC0bits.AD1IE

/* IEC1 */
#define _SI2C1IE IEC1bits.SI2C1IE
#define _MI2C1IE IEC1bits.MI2C1IE
#define _CMIE IEC1bits.CMIE
#define _CNIE IEC1bits.CNIE
#define _INT1IE IEC1bits.INT1IE
#define _OC3IE IEC1bits.OC3IE
#define _OC4IE IEC1bits.OC4IE
#define _T4IE IEC1bits.T4IE
#define _T5IE IEC1bits.T5IE
#define _INT2IE IEC1bits.INT2IE
#define _U2RXIE IEC1bits.U2RXIE
#define _U2TXIE IEC1bits.U2TXIE

/* IEC2 */
#define _SPF2IE IEC2bits.SPF2IE
#define _SPI2IE IEC2bits.SPI2IE
#define _IC3IE IEC2bits.IC3IE
#define _IC4IE IEC2bits.IC4IE
#define _IC5IE IEC2bits.IC5IE
#define _OC5IE IEC2bits.OC5IE
#define _PMPIE IEC2bits.PMPIE

/* IEC3 */
#define _SI2C2IE IEC3bits.SI2C2IE
#define _MI2C2IE IEC3bits.MI2C2IE
#define _INT3IE IEC3bits.INT3IE
#define _INT4IE IEC3bits.INT4IE
#define _RTCIE IEC3bits.RTCIE

/* IEC4 */
#define _U1ERIE IEC4bits.U1ERIE
#define _U2ERIE IEC4bits.U2ERIE
#define _CRCIE IEC4bits.CRCIE

/* IPC0 */
#define _INT0IP0 IPC0bits.INT0IP0
#define _INT0IP1 IPC0bits.INT0IP1
#define _INT0IP2 IPC0bits.INT0IP2
#define _IC1IP0 IPC0bits.IC1IP0
#define _IC1IP1 IPC0bits.IC1IP1
#define _IC1IP2 IPC0bits.IC1IP2
#define _OC1IP0 IPC0bits.OC1IP0
#define _OC1IP1 IPC0bits.OC1IP1
#define _OC1IP2 IPC0bits.OC1IP2
#define _T1IP0 IPC0bits.T1IP0
#define _T1IP1 IPC0bits.T1IP1
#define _T1IP2 IPC0bits.T1IP2
#define _INT0IP IPC0bits.INT0IP
#define _IC1IP IPC0bits.IC1IP
#define _OC1IP IPC0bits.OC1IP
#define _T1IP IPC0bits.T1IP

/* IPC1 */
#define _IC2IP0 IPC1bits.IC2IP0
#define _IC2IP1 IPC1bits.IC2IP1
#define _IC2IP2 IPC1bits.IC2IP2
#define _OC2IP0 IPC1bits.OC2IP0
#define _OC2IP1 IPC1bits.OC2IP1
#define _OC2IP2 IPC1bits.OC2IP2
#define _T2IP0 IPC1bits.T2IP0
#define _T2IP1 IPC1bits.T2IP1
#define _T2IP2 IPC1bits.T2IP2
#define _IC2IP IPC1bits.IC2IP
#define _OC2IP IPC1bits.OC2IP
#define _T2IP IPC1bits.T2IP

/* IPC2 */
#define _T3IP0 IPC2bits.T3IP0
#define _T3IP1 IPC2bits.T3IP1
#define _T3IP2 IPC2bits.T3IP2
#define _SPF1IP0 IPC2bits.SPF1IP0
#define _SPF1IP1 IPC2bits.SPF1IP1
#define _SPF1IP2 IPC2bits.SPF1IP2
#define _SPI1IP0 IPC2bits.SPI1IP0
#define _SPI1IP1 IPC2bits.SPI1IP1
#define _SPI1IP2 IPC2bits.SPI1IP2
#define _U1RXIP0 IPC2bits.U1RXIP0
#define _U1RXIP1 IPC2bits.U1RXIP1
#define _U1RXIP2 IPC2bits.U1RXIP2
#define _T3IP IPC2bits.T3IP
#define _SPF1IP IPC2bits.SPF1IP
#define _SPI1IP IPC2bits.SPI1IP
#define _U1RXIP IPC2bits.U1RXIP

/* IPC3 */
#define _U1TXIP0 IPC3bits.U1TXIP0
#define _U1TXIP1 IPC3bits.U1TXIP1
#define _U1TXIP2 IPC3bits.U1TXIP2
#define _AD1IP0 IPC3bits.AD1IP0
#define _AD1IP1 IPC3bits.AD1IP1
#define _AD1IP2 IPC3bits.AD1IP2
#define _U1TXIP IPC3bits.U1TXIP
#define _AD1IP IPC3bits.AD1IP

/* IPC4 */
#define _SI2C1P0 IPC4bits.SI2C1P0
#define _SI2C1P1 IPC4bits.SI2C1P1
#define _SI2C1P2 IPC4bits.SI2C1P2
#define _MI2C1P0 IPC4bits.MI2C1P0
#define _MI2C1P1 IPC4bits.MI2C1P1
#define _MI2C1P2 IPC4bits.MI2C1P2
#define _CMIP0 IPC4bits.CMIP0
#define _CMIP1 IPC4bits.CMIP1
#define _CMIP2 IPC4bits.CMIP2
#define _CNIP0 IPC4bits.CNIP0
#define _CNIP1 IPC4bits.CNIP1
#define _CNIP2 IPC4bits.CNIP2
#define _SI2C1P IPC4bits.SI2C1P
#define _MI2C1P IPC4bits.MI2C1P
#define _CMIP IPC4bits.CMIP
#define _CNIP IPC4bits.CNIP

/* IPC5 */
#define _INT1IP0 IPC5bits.INT1IP0
#define _INT1IP1 IPC5bits.INT1IP1
#define _INT1IP2 IPC5bits.INT1IP2
#define _INT1IP IPC5bits.INT1IP

/* IPC6 */
#define _OC3IP0 IPC6bits.OC3IP0
#define _OC3IP1 IPC6bits.OC3IP1
#define _OC3IP2 IPC6bits.OC3IP2
#define _OC4IP0 IPC6bits.OC4IP0
#define _OC4IP1 IPC6bits.OC4IP1
#define _OC4IP2 IPC6bits.OC4IP2
#define _T4IP0 IPC6bits.T4IP0
#define _T4IP1 IPC6bits.T4IP1
#define _T4IP2 IPC6bits.T4IP2
#define _OC3IP IPC6bits.OC3IP
#define _OC4IP IPC6bits.OC4IP
#define _T4IP IPC6bits.T4IP

/* IPC7 */
#define _T5IP0 IPC7bits.T5IP0
#define _T5IP1 IPC7bits.T5IP1
#define _T5IP2 IPC7bits.T5IP2
#define _INT2IP0 IPC7bits.INT2IP0
#define _INT2IP1 IPC7bits.INT2IP1
#define _INT2IP2 IPC7bits.INT2IP2
#define _U2RXIP0 IPC7bits.U2RXIP0
#define _U2RXIP1 IPC7bits.U2RXIP1
#define _U2RXIP2 IPC7bits.U2RXIP2
#define _U2TXIP0 IPC7bits.U2TXIP0
#define _U2TXIP1 IPC7bits.U2TXIP1
#define _U2TXIP2 IPC7bits.U2TXIP2
#define _T5IP IPC7bits.T5IP
#define _INT2IP IPC7bits.INT2IP
#define _U2RXIP IPC7bits.U2RXIP
#define _U2TXIP IPC7bits.U2TXIP

/* IPC8 */
#define _SPF2IP0 IPC8bits.SPF2IP0
#define _SPF2IP1 IPC8bits.SPF2IP1
#define _SPF2IP2 IPC8bits.SPF2IP2
#define _SPI2IP0 IPC8bits.SPI2IP0
#define _SPI2IP1 IPC8bits.SPI2IP1
#define _SPI2IP2 IPC8bits.SPI2IP2
#define _SPF2IP IPC8bits.SPF2IP
#define _SPI2IP IPC8bits.SPI2IP

/* IPC9 */
#define _IC3IP0 IPC9bits.IC3IP0
#define _IC3IP1 IPC9bits.IC3IP1
#define _IC3IP2 IPC9bits.IC3IP2
#define _IC4IP0 IPC9bits.IC4IP0
#define _IC4IP1 IPC9bits.IC4IP1
#define _IC4IP2 IPC9bits.IC4IP2
#define _IC5IP0 IPC9bits.IC5IP0
#define _IC5IP1 IPC9bits.IC5IP1
#define _IC5IP2 IPC9bits.IC5IP2
#define _IC3IP IPC9bits.IC3IP
#define _IC4IP IPC9bits.IC4IP
#define _IC5IP IPC9bits.IC5IP

/* IPC10 */
#define _OC5IP0 IPC10bits.OC5IP0
#define _OC5IP1 IPC10bits.OC5IP1
#define _OC5IP2 IPC10bits.OC5IP2
#define _OC5IP IPC10bits.OC5IP

/* IPC11 */
#define _PMPIP0 IPC11bits.PMPIP0
#define _PMPIP1 IPC11bits.PMPIP1
#define _PMPIP2 IPC11bits.PMPIP2
#define _PMPIP IPC11bits.PMPIP

/* IPC12 */
#define _SI2C2P0 IPC12bits.SI2C2P0
#define _SI2C2P1 IPC12bits.SI2C2P1
#define _SI2C2P2 IPC12bits.SI2C2P2
#define _MI2C2P0 IPC12bits.MI2C2P0
#define _MI2C2P1 IPC12bits.MI2C2P1
#define _MI2C2P2 IPC12bits.MI2C2P2
#define _SI2C2P IPC12bits.SI2C2P
#define _MI2C2P IPC12bits.MI2C2P

/* IPC13 */
#define _INT3IP0 IPC13bits.INT3IP0
#define _INT3IP1 IPC13bits.INT3IP1
#define _INT3IP2 IPC13bits.INT3IP2
#define _INT4IP0 IPC13bits.INT4IP0
#define _INT4IP1 IPC13bits.INT4IP1
#define _INT4IP2 IPC13bits.INT4IP2
#define _INT3IP IPC13bits.INT3IP
#define _INT4IP IPC13bits.INT4IP

/* IPC15 */
#define _RTCIP0 IPC15bits.RTCIP0
#define _RTCIP1 IPC15bits.RTCIP1
#define _RTCIP2 IPC15bits.RTCIP2
#define _RTCIP IPC15bits.RTCIP

/* IPC16 */
#define _U1ERIP0 IPC16bits.U1ERIP0
#define _U1ERIP1 IPC16bits.U1ERIP1
#define _U1ERIP2 IPC16bits.U1ERIP2
#define _U2ERIP0 IPC16bits.U2ERIP0
#define _U2ERIP1 IPC16bits.U2ERIP1
#define _U2ERIP2 IPC16bits.U2ERIP2
#define _CRCIP0 IPC16bits.CRCIP0
#define _CRCIP1 IPC16bits.CRCIP1
#define _CRCIP2 IPC16bits.CRCIP2
#define _U1ERIP IPC16bits.U1ERIP
#define _U2ERIP IPC16bits.U2ERIP
#define _CRCIP IPC16bits.CRCIP

/* T1CON */
#define _TSYNC T1CONbits.TSYNC

/* TRISA */
#define _TRISA0 TRISAbits.TRISA0
#define _TRISA1 TRISAbits.TRISA1
#define _TRISA2 TRISAbits.TRISA2
#define _TRISA3 TRISAbits.TRISA3
#define _TRISA4 TRISAbits.TRISA4
#define _TRISA5 TRISAbits.TRISA5
#define _TRISA6 TRISAbits.TRISA6
#define _TRISA7 TRISAbits.TRISA7
#define _TRISA9 TRISAbits.TRISA9
#define _TRISA10 TRISAbits.TRISA10
#define _TRISA14 TRISAbits.TRISA14
#define _TRISA15 TRISAbits.TRISA15

/* PORTA */
#define _RA0 PORTAbits.RA0
#define _RA1 PORTAbits.RA1
#define _RA2 PORTAbits.RA2
#define _RA3 PORTAbits.RA3
#define _RA4 PORTAbits.RA4
#define _RA5 PORTAbits.RA5
#define _RA6 PORTAbits.RA6
#define _RA7 PORTAbits.RA7
#define _RA9 PORTAbits.RA9
#define _RA10 PORTAbits.RA10
#define _RA14 PORTAbits.RA14
#define _RA15 PORTAbits.RA15

/* LATA */
#define _LATA0 LATAbits.LATA0
#define _LATA1 LATAbits.LATA1
#define _LATA2 LATAbits.LATA2
#define _LATA3 LATAbits.LATA3
#define _LATA4 LATAbits.LATA4
#define _LATA5 LATAbits.LATA5
#define _LATA6 LATAbits.LATA6
#define _LATA7 LATAbits.LATA7
#define _LATA9 LATAbits.LATA9
#define _LATA10 LATAbits.LATA10
#define _LATA14 LATAbits.LATA14
#define _LATA15 LATAbits.LATA15

/* TRISB */
#define _TRISB0 TRISBbits.TRISB0
#define _TRISB1 TRISBbits.TRISB1
#define _TRISB2 TRISBbits.TRISB2
#define _TRISB3 TRISBbits.TRISB3
#define _TRISB4 TRISBbits.TRISB4
#define _TRISB5 TRISBbits.TRISB5
#define _TRISB6 TRISBbits.TRISB6
#define _TRISB7 TRISBbits.TRISB7
#define _TRISB8 TRISBbits.TRISB8
#define _TRISB9 TRISBbits.TRISB9
#define _TRISB10 TRISBbits.TRISB10
#define _TRISB11 TRISBbits.TRISB11
#define _TRISB12 TRISBbits.TRISB12
#define _TRISB13 TRISBbits.TRISB13
#define _TRISB14 TRISBbits.TRISB14
#define _TRISB15 TRISBbits.TRISB15

/* PORTB */
#define _RB0 PORTBbits.RB0
#define _RB1 PORTBbits.RB1
#define _RB2 PORTBbits.RB2
#define _RB3 PORTBbits.RB3
#define _RB4 PORTBbits.RB4
#define _RB5 PORTBbits.RB5
#define _RB6 PORTBbits.RB6
#define _RB7 PORTBbits.RB7
#define _RB8 PORTBbits.RB8
#define _RB9 PORTBbits.RB9
#define _RB10 PORTBbits.RB10
#define _RB11 PORTBbits.RB11
#define _RB12 PORTBbits.RB12
#define _RB13 PORTBbits.RB13
#define _RB14 PORTBbits.RB14
#define _RB15 PORTBbits.RB15

/* LATB */
#define _LATB0 LATBbits.LATB0
#define _LATB1 LATBbits.LATB1
#define _LATB2 LATBbits.LATB2
#define _LATB3 LATBbits.LATB3
#define _LATB4 LATBbits.LATB4
#define _LATB5 LATBbits.LATB5
#define _LATB6 LATBbits.LATB6
#define _LATB7 LATBbits.LATB7
#define _LATB8 LATBbits.LATB8
#define _LATB9 LATBbits.LATB9
#define _LATB10 LATBbits.LATB10
#define _LATB11 LATBbits.LATB11
#define _LATB12 LATBbits.LATB12
#define _LATB13 LATBbits.LATB13
#define _LATB14 LATBbits.LATB14
#define _LATB15 LATBbits.LATB15

/* TRISC */
#define _TRISC1 TRISCbits.TRISC1
#define _TRISC2 TRISCbits.TRISC2
#define _TRISC3 TRISCbits.TRISC3
#define _TRISC4 TRISCbits.TRISC4
#define _TRISC12 TRISCbits.TRISC12
#define _TRISC13 TRISCbits.TRISC13
#define _TRISC14 TRISCbits.TRISC14
#define _TRISC15 TRISCbits.TRISC15

/* PORTC */
#define _RC1 PORTCbits.RC1
#define _RC2 PORTCbits.RC2
#define _RC3 PORTCbits.RC3
#define _RC4 PORTCbits.RC4
#define _RC12 PORTCbits.RC12
#define _RC13 PORTCbits.RC13
#define _RC14 PORTCbits.RC14
#define _RC15 PORTCbits.RC15

/* LATC */
#define _LATC1 LATCbits.LATC1
#define _LATC2 LATCbits.LATC2
#define _LATC3 LATCbits.LATC3
#define _LATC4 LATCbits.LATC4
#define _LATC12 LATCbits.LATC12
#define _LATC13 LATCbits.LATC13
#define _LATC14 LATCbits.LATC14
#define _LATC15 LATCbits.LATC15

/* TRISD */
#define _TRISD0 TRISDbits.TRISD0
#define _TRISD1 TRISDbits.TRISD1
#define _TRISD2 TRISDbits.TRISD2
#define _TRISD3 TRISDbits.TRISD3
#define _TRISD4 TRISDbits.TRISD4
#define _TRISD5 TRISDbits.TRISD5
#define _TRISD6 TRISDbits.TRISD6
#define _TRISD7 TRISDbits.TRISD7
#define _TRISD8 TRISDbits.TRISD8
#define _TRISD9 TRISDbits.TRISD9
#define _TRISD10 TRISDbits.TRISD10
#define _TRISD11 TRISDbits.TRISD11
#define _TRISD12 TRISDbits.TRISD12
#define _TRISD13 TRISDbits.TRISD13
#define _TRISD14 TRISDbits.TRISD14
#define _TRISD15 TRISDbits.TRISD15

/* PORTD */
#define _RD0 PORTDbits.RD0
#define _RD1 PORTDbits.RD1
#define _RD2 PORTDbits.RD2
#define _RD3 PORTDbits.RD3
#define _RD4 PORTDbits.RD4
#define _RD5 PORTDbits.RD5
#define _RD6 PORTDbits.RD6
#define _RD7 PORTDbits.RD7
#define _RD8 PORTDbits.RD8
#define _RD9 PORTDbits.RD9
#define _RD10 PORTDbits.RD10
#define _RD11 PORTDbits.RD11
#define _RD12 PORTDbits.RD12
#define _RD13 PORTDbits.RD13
#define _RD14 PORTDbits.RD14
#define _RD15 PORTDbits.RD15

/* LATD */
#define _LATD0 LATDbits.LATD0
#define _LATD1 LATDbits.LATD1
#define _LATD2 LATDbits.LATD2
#define _LATD3 LATDbits.LATD3
#define _LATD4 LATDbits.LATD4
#define _LATD5 LATDbits.LATD5
#define _LATD6 LATDbits.LATD6
#define _LATD7 LATDbits.LATD7
#define _LATD8 LATDbits.LATD8
#define _LATD9 LATDbits.LATD9
#define _LATD10 LATDbits.LATD10
#define _LATD11 LATDbits.LATD11
#define _LATD12 LATDbits.LATD12
#define _LATD13 LATDbits.LATD13
#define _LATD14 LATDbits.LATD14
#define _LATD15 LATDbits.LATD15

/* TRISE */
#define _TRISE0 TRISEbits.TRISE0
#define _TRISE1 TRISEbits.TRISE1
#define _TRISE2 TRISEbits.TRISE2
#define _TRISE3 TRISEbits.TRISE3
#define _TRISE4 TRISEbits.TRISE4
#define _TRISE5 TRISEbits.TRISE5
#define _TRISE6 TRISEbits.TRISE6
#define _TRISE7 TRISEbits.TRISE7
#define _TRISE8 TRISEbits.TRISE8
#define _TRISE9 TRISEbits.TRISE9

/* PORTE */
#define _RE0 PORTEbits.RE0
#define _RE1 PORTEbits.RE1
#define _RE2 PORTEbits.RE2
#define _RE3 PORTEbits.RE3
#define _RE4 PORTEbits.RE4
#define _RE5 PORTEbits.RE5
#define _RE6 PORTEbits.RE6
#define _RE7 PORTEbits.RE7
#define _RE8 PORTEbits.RE8
#define _RE9 PORTEbits.RE9

/* LATE */
#define _LATE0 LATEbits.LATE0
#define _LATE1 LATEbits.LATE1
#define _LATE2 LATEbits.LATE2
#define _LATE3 LATEbits.LATE3
#define _LATE4 LATEbits.LATE4
#define _LATE5 LATEbits.LATE5
#define _LATE6 LATEbits.LATE6
#define _LATE7 LATEbits.LATE7
#define _LATE8 LATEbits.LATE8
#define _LATE9 LATEbits.LATE9

/* TRISF */
#define _TRISF0 TRISFbits.TRISF0
#define _TRISF1 TRISFbits.TRISF1
#define _TRISF2 TRISFbits.TRISF2
#define _TRISF3 TRISFbits.TRISF3
#define _TRISF4 TRISFbits.TRISF4
#define _TRISF5 TRISFbits.TRISF5
#define _TRISF6 TRISFbits.TRISF6
#define _TRISF7 TRISFbits.TRISF7
#define _TRISF8 TRISFbits.TRISF8
#define _TRISF12 TRISFbits.TRISF12
#define _TRISF13 TRISFbits.TRISF13

/* PORTF */
#define _RF0 PORTFbits.RF0
#define _RF1 PORTFbits.RF1
#define _RF2 PORTFbits.RF2
#define _RF3 PORTFbits.RF3
#define _RF4 PORTFbits.RF4
#define _RF5 PORTFbits.RF5
#define _RF6 PORTFbits.RF6
#define _RF7 PORTFbits.RF7
#define _RF8 PORTFbits.RF8
#define _RF12 PORTFbits.RF12
#define _RF13 PORTFbits.RF13

/* LATF */
#define _LATF0 LATFbits.LATF0
#define _LATF1 LATFbits.LATF1
#define _LATF2 LATFbits.LATF2
#define _LATF3 LATFbits.LATF3
#define _LATF4 LATFbits.LATF4
#define _LATF5 LATFbits.LATF5
#define _LATF6 LATFbits.LATF6
#define _LATF7 LATFbits.LATF7
#define _LATF8 LATFbits.LATF8
#define _LATF12 LATFbits.LATF12
#define _LATF13 LATFbits.LATF13

/* TRISG */
#define _TRISG0 TRISGbits.TRISG0
#define _TRISG1 TRISGbits.TRISG1
#define _TRISG2 TRISGbits.TRISG2
#define _TRISG3 TRISGbits.TRISG3
#define _TRISG6 TRISGbits.TRISG6
#define _TRISG7 TRISGbits.TRISG7
#define _TRISG8 TRISGbits.TRISG8
#define _TRISG9 TRISGbits.TRISG9
#define _TRISG12 TRISGbits.TRISG12
#define _TRISG13 TRISGbits.TRISG13
#define _TRISG14 TRISGbits.TRISG14
#define _TRISG15 TRISGbits.TRISG15

/* PORTG */
#define _RG0 PORTGbits.RG0
#define _RG1 PORTGbits.RG1
#define _RG2 PORTGbits.RG2
#define _RG3 PORTGbits.RG3
#define _RG6 PORTGbits.RG6
#define _RG7 PORTGbits.RG7
#define _RG8 PORTGbits.RG8
#define _RG9 PORTGbits.RG9
#define _RG12 PORTGbits.RG12
#define _RG13 PORTGbits.RG13
#define _RG14 PORTGbits.RG14
#define _RG15 PORTGbits.RG15

/* LATG */
#define _LATG0 LATGbits.LATG0
#define _LATG1 LATGbits.LATG1
#define _LATG2 LATGbits.LATG2
#define _LATG3 LATGbits.LATG3
#define _LATG6 LATGbits.LATG6
#define _LATG7 LATGbits.LATG7
#define _LATG8 LATGbits.LATG8
#define _LATG9 LATGbits.LATG9
#define _LATG12 LATGbits.LATG12
#define _LATG13 LATGbits.LATG13
#define _LATG14 LATGbits.LATG14
#define _LATG15 LATGbits.LATG15

/* PADCFG1 */
#define _PMPTTL PADCFG1bits.PMPTTL
#define _RTSECSEL PADCFG1bits.RTSECSEL

/* AD1CON1 */
#define _DONE AD1CON1bits.DONE
#define _SAMP AD1CON1bits.SAMP
#define _ASAM AD1CON1bits.ASAM
#define _SSRC AD1CON1bits.SSRC
#define _FORM0 AD1CON1bits.FORM0
#define _FORM1 AD1CON1bits.FORM1
#define _ADSIDL AD1CON1bits.ADSIDL
#define _ADON AD1CON1bits.ADON
#define _SSRC0 AD1CON1bits.SSRC0
#define _SSRC1 AD1CON1bits.SSRC1
#define _SSRC2 AD1CON1bits.SSRC2
#define _FORM AD1CON1bits.FORM

/* AD1CON2 */
#define _ALTS AD1CON2bits.ALTS
#define _BUFM AD1CON2bits.BUFM
#define _SMPI AD1CON2bits.SMPI
#define _BUFS AD1CON2bits.BUFS
#define _CSCNA AD1CON2bits.CSCNA
#define _VCFG AD1CON2bits.VCFG
#define _SMPI0 AD1CON2bits.SMPI0
#define _SMPI1 AD1CON2bits.SMPI1
#define _SMPI2 AD1CON2bits.SMPI2
#define _SMPI3 AD1CON2bits.SMPI3
#define _VCFG0 AD1CON2bits.VCFG0
#define _VCFG1 AD1CON2bits.VCFG1
#define _VCFG2 AD1CON2bits.VCFG2

/* AD1CON3 */
#define _ADCS AD1CON3bits.ADCS
#define _SAMC AD1CON3bits.SAMC
#define _ADRC AD1CON3bits.ADRC
#define _ADCS0 AD1CON3bits.ADCS0
#define _ADCS1 AD1CON3bits.ADCS1
#define _ADCS2 AD1CON3bits.ADCS2
#define _ADCS3 AD1CON3bits.ADCS3
#define _ADCS4 AD1CON3bits.ADCS4
#define _ADCS5 AD1CON3bits.ADCS5
#define _ADCS6 AD1CON3bits.ADCS6
#define _ADCS7 AD1CON3bits.ADCS7
#define _SAMC0 AD1CON3bits.SAMC0
#define _SAMC1 AD1CON3bits.SAMC1
#define _SAMC2 AD1CON3bits.SAMC2
#define _SAMC3 AD1CON3bits.SAMC3
#define _SAMC4 AD1CON3bits.SAMC4

/* AD1CHS */
#define _CH0SA AD1CHSbits.CH0SA
#define _CH0NA AD1CHSbits.CH0NA
#define _CH0SB AD1CHSbits.CH0SB
#define _CH0NB AD1CHSbits.CH0NB
#define _CH0SA0 AD1CHSbits.CH0SA0
#define _CH0SA1 AD1CHSbits.CH0SA1
#define _CH0SA2 AD1CHSbits.CH0SA2
#define _CH0SA3 AD1CHSbits.CH0SA3
#define _CH0SB0 AD1CHSbits.CH0SB0
#define _CH0SB1 AD1CHSbits.CH0SB1
#define _CH0SB2 AD1CHSbits.CH0SB2
#define _CH0SB3 AD1CHSbits.CH0SB3

/* AD1PCFG */
#define _PCFG0 AD1PCFGbits.PCFG0
#define _PCFG1 AD1PCFGbits.PCFG1
#define _PCFG2 AD1PCFGbits.PCFG2
#define _PCFG3 AD1PCFGbits.PCFG3
#define _PCFG4 AD1PCFGbits.PCFG4
#define _PCFG5 AD1PCFGbits.PCFG5
#define _PCFG6 AD1PCFGbits.PCFG6
#define _PCFG7 AD1PCFGbits.PCFG7
#define _PCFG8 AD1PCFGbits.PCFG8
#define _PCFG9 AD1PCFGbits.PCFG9
#define _PCFG10 AD1PCFGbits.PCFG10
#define _PCFG11 AD1PCFGbits.PCFG11
#define _PCFG12 AD1PCFGbits.PCFG12
#define _PCFG13 AD1PCFGbits.PCFG13
#define _PCFG14 AD1PCFGbits.PCFG14
#define _PCFG15 AD1PCFGbits.PCFG15

/* AD1CSSL */
#define _CSSL0 AD1CSSLbits.CSSL0
#define _CSSL1 AD1CSSLbits.CSSL1
#define _CSSL2 AD1CSSLbits.CSSL2
#define _CSSL3 AD1CSSLbits.CSSL3
#define _CSSL4 AD1CSSLbits.CSSL4
#define _CSSL5 AD1CSSLbits.CSSL5
#define _CSSL6 AD1CSSLbits.CSSL6
#define _CSSL7 AD1CSSLbits.CSSL7
#define _CSSL8 AD1CSSLbits.CSSL8
#define _CSSL9 AD1CSSLbits.CSSL9
#define _CSSL10 AD1CSSLbits.CSSL10
#define _CSSL11 AD1CSSLbits.CSSL11
#define _CSSL12 AD1CSSLbits.CSSL12
#define _CSSL13 AD1CSSLbits.CSSL13
#define _CSSL14 AD1CSSLbits.CSSL14
#define _CSSL15 AD1CSSLbits.CSSL15

/* PMCON */
#define _RDSP PMCONbits.RDSP
#define _WRSP PMCONbits.WRSP
#define _BEP PMCONbits.BEP
#define _CS1P PMCONbits.CS1P
#define _CS2P PMCONbits.CS2P
#define _ALP PMCONbits.ALP
#define _CSF0 PMCONbits.CSF0
#define _CSF1 PMCONbits.CSF1
#define _PTRDEN PMCONbits.PTRDEN
#define _PTWREN PMCONbits.PTWREN
#define _PTBEEN PMCONbits.PTBEEN
#define _ADRMUX0 PMCONbits.ADRMUX0
#define _ADRMUX1 PMCONbits.ADRMUX1
#define _PSIDL PMCONbits.PSIDL
#define _PMPEN PMCONbits.PMPEN
#define _CSF PMCONbits.CSF
#define _ADRMUX PMCONbits.ADRMUX

/* PMMODE */
#define _WAITE0 PMMODEbits.WAITE0
#define _WAITE1 PMMODEbits.WAITE1
#define _WAITM PMMODEbits.WAITM
#define _WAITB0 PMMODEbits.WAITB0
#define _WAITB1 PMMODEbits.WAITB1
#define _MODE0 PMMODEbits.MODE0
#define _MODE1 PMMODEbits.MODE1
#define _INCM0 PMMODEbits.INCM0
#define _INCM1 PMMODEbits.INCM1
#define _IRQM0 PMMODEbits.IRQM0
#define _IRQM1 PMMODEbits.IRQM1
#define _BUSY PMMODEbits.BUSY
#define _WAITE PMMODEbits.WAITE
#define _WAITM0 PMMODEbits.WAITM0
#define _WAITM1 PMMODEbits.WAITM1
#define _WAITM2 PMMODEbits.WAITM2
#define _WAITM3 PMMODEbits.WAITM3
#define _WAITB PMMODEbits.WAITB
#define _MODE PMMODEbits.MODE
#define _INCM PMMODEbits.INCM
#define _IRQM PMMODEbits.IRQM

/* PMADDR */
#define _CS1 PMADDRbits.CS1
#define _CS2 PMADDRbits.CS2
#define _CS PMADDRbits.CS

/* PMPEN */
#define _PTEN0 PMPENbits.PTEN0
#define _PTEN1 PMPENbits.PTEN1
#define _PTEN2 PMPENbits.PTEN2
#define _PTEN3 PMPENbits.PTEN3
#define _PTEN4 PMPENbits.PTEN4
#define _PTEN5 PMPENbits.PTEN5
#define _PTEN6 PMPENbits.PTEN6
#define _PTEN7 PMPENbits.PTEN7
#define _PTEN8 PMPENbits.PTEN8
#define _PTEN9 PMPENbits.PTEN9
#define _PTEN10 PMPENbits.PTEN10
#define _PTEN11 PMPENbits.PTEN11
#define _PTEN12 PMPENbits.PTEN12
#define _PTEN13 PMPENbits.PTEN13
#define _PTEN14 PMPENbits.PTEN14
#define _PTEN15 PMPENbits.PTEN15

/* PMSTAT */
#define _OB0E PMSTATbits.OB0E
#define _OB1E PMSTATbits.OB1E
#define _OB2E PMSTATbits.OB2E
#define _OB3E PMSTATbits.OB3E
#define _OBUF PMSTATbits.OBUF
#define _OBE PMSTATbits.OBE
#define _IB0F PMSTATbits.IB0F
#define _IB1F PMSTATbits.IB1F
#define _IB2F PMSTATbits.IB2F
#define _IB3F PMSTATbits.IB3F
#define _IBOV PMSTATbits.IBOV
#define _IBF PMSTATbits.IBF

/* ALCFGRPT */
#define _ARPT ALCFGRPTbits.ARPT
#define _ALRMPTR0 ALCFGRPTbits.ALRMPTR0
#define _ALRMPTR1 ALCFGRPTbits.ALRMPTR1
#define _AMASK ALCFGRPTbits.AMASK
#define _CHIME ALCFGRPTbits.CHIME
#define _ALRMEN ALCFGRPTbits.ALRMEN
#define _ARPT0 ALCFGRPTbits.ARPT0
#define _ARPT1 ALCFGRPTbits.ARPT1
#define _ARPT2 ALCFGRPTbits.ARPT2
#define _ARPT3 ALCFGRPTbits.ARPT3
#define _ARPT4 ALCFGRPTbits.ARPT4
#define _ARPT5 ALCFGRPTbits.ARPT5
#define _ARPT6 ALCFGRPTbits.ARPT6
#define _ARPT7 ALCFGRPTbits.ARPT7
#define _ALRMPTR ALCFGRPTbits.ALRMPTR
#define _AMASK0 ALCFGRPTbits.AMASK0
#define _AMASK1 ALCFGRPTbits.AMASK1
#define _AMASK2 ALCFGRPTbits.AMASK2
#define _AMASK3 ALCFGRPTbits.AMASK3

/* RCFGCAL */
#define _CAL RCFGCALbits.CAL
#define _RTCPTR0 RCFGCALbits.RTCPTR0
#define _RTCPTR1 RCFGCALbits.RTCPTR1
#define _RTCOE RCFGCALbits.RTCOE
#define _HALFSEC RCFGCALbits.HALFSEC
#define _RTCSYNC RCFGCALbits.RTCSYNC
#define _RTCWREN RCFGCALbits.RTCWREN
#define _RTCEN RCFGCALbits.RTCEN
#define _CAL0 RCFGCALbits.CAL0
#define _CAL1 RCFGCALbits.CAL1
#define _CAL2 RCFGCALbits.CAL2
#define _CAL3 RCFGCALbits.CAL3
#define _CAL4 RCFGCALbits.CAL4
#define _CAL5 RCFGCALbits.CAL5
#define _CAL6 RCFGCALbits.CAL6
#define _CAL7 RCFGCALbits.CAL7
#define _RTCPTR RCFGCALbits.RTCPTR

/* CMCON */
#define _C1POS CMCONbits.C1POS
#define _C1NEG CMCONbits.C1NEG
#define _C2POS CMCONbits.C2POS
#define _C2NEG CMCONbits.C2NEG
#define _C1INV CMCONbits.C1INV
#define _C2INV CMCONbits.C2INV
#define _C1OUT CMCONbits.C1OUT
#define _C2OUT CMCONbits.C2OUT
#define _C1OUTEN CMCONbits.C1OUTEN
#define _C2OUTEN CMCONbits.C2OUTEN
#define _C1EN CMCONbits.C1EN
#define _C2EN CMCONbits.C2EN
#define _C1EVT CMCONbits.C1EVT
#define _C2EVT CMCONbits.C2EVT
#define _CMIDL CMCONbits.CMIDL

/* CVRCON */
#define _CVR CVRCONbits.CVR
#define _CVRSS CVRCONbits.CVRSS
#define _CVRR CVRCONbits.CVRR
#define _CVROE CVRCONbits.CVROE
#define _CVREN CVRCONbits.CVREN
#define _CVR0 CVRCONbits.CVR0
#define _CVR1 CVRCONbits.CVR1
#define _CVR2 CVRCONbits.CVR2
#define _CVR3 CVRCONbits.CVR3

/* CRCCON */
#define _PLEN CRCCONbits.PLEN
#define _CRCGO CRCCONbits.CRCGO
#define _CRCMPT CRCCONbits.CRCMPT
#define _CRCFUL CRCCONbits.CRCFUL
#define _VWORD CRCCONbits.VWORD
#define _CSIDL CRCCONbits.CSIDL
#define _PLEN0 CRCCONbits.PLEN0
#define _PLEN1 CRCCONbits.PLEN1
#define _PLEN2 CRCCONbits.PLEN2
#define _PLEN3 CRCCONbits.PLEN3
#define _VWORD0 CRCCONbits.VWORD0
#define _VWORD1 CRCCONbits.VWORD1
#define _VWORD2 CRCCONbits.VWORD2
#define _VWORD3 CRCCONbits.VWORD3
#define _VWORD4 CRCCONbits.VWORD4

/* ODCA */
#define _ODA0 ODCAbits.ODA0
#define _ODA1 ODCAbits.ODA1
#define _ODA2 ODCAbits.ODA2
#define _ODA3 ODCAbits.ODA3
#define _ODA4 ODCAbits.ODA4
#define _ODA5 ODCAbits.ODA5
#define _ODA6 ODCAbits.ODA6
#define _ODA7 ODCAbits.ODA7
#define _ODA9 ODCAbits.ODA9
#define _ODA10 ODCAbits.ODA10
#define _ODA14 ODCAbits.ODA14
#define _ODA15 ODCAbits.ODA15

/* ODCB */
#define _ODB0 ODCBbits.ODB0
#define _ODB1 ODCBbits.ODB1
#define _ODB2 ODCBbits.ODB2
#define _ODB3 ODCBbits.ODB3
#define _ODB4 ODCBbits.ODB4
#define _ODB5 ODCBbits.ODB5
#define _ODB6 ODCBbits.ODB6
#define _ODB7 ODCBbits.ODB7
#define _ODB8 ODCBbits.ODB8
#define _ODB9 ODCBbits.ODB9
#define _ODB10 ODCBbits.ODB10
#define _ODB11 ODCBbits.ODB11
#define _ODB12 ODCBbits.ODB12
#define _ODB13 ODCBbits.ODB13
#define _ODB14 ODCBbits.ODB14
#define _ODB15 ODCBbits.ODB15

/* ODCC */
#define _ODC1 ODCCbits.ODC1
#define _ODC2 ODCCbits.ODC2
#define _ODC3 ODCCbits.ODC3
#define _ODC4 ODCCbits.ODC4
#define _ODC12 ODCCbits.ODC12
#define _ODC13 ODCCbits.ODC13
#define _ODC14 ODCCbits.ODC14
#define _ODC15 ODCCbits.ODC15

/* ODCD */
#define _ODD0 ODCDbits.ODD0
#define _ODD1 ODCDbits.ODD1
#define _ODD2 ODCDbits.ODD2
#define _ODD3 ODCDbits.ODD3
#define _ODD4 ODCDbits.ODD4
#define _ODD5 ODCDbits.ODD5
#define _ODD6 ODCDbits.ODD6
#define _ODD7 ODCDbits.ODD7
#define _ODD8 ODCDbits.ODD8
#define _ODD9 ODCDbits.ODD9
#define _ODD10 ODCDbits.ODD10
#define _ODD11 ODCDbits.ODD11
#define _ODD12 ODCDbits.ODD12
#define _ODD13 ODCDbits.ODD13
#define _ODD14 ODCDbits.ODD14
#define _ODD15 ODCDbits.ODD15

/* ODCE */
#define _ODE0 ODCEbits.ODE0
#define _ODE1 ODCEbits.ODE1
#define _ODE2 ODCEbits.ODE2
#define _ODE3 ODCEbits.ODE3
#define _ODE4 ODCEbits.ODE4
#define _ODE5 ODCEbits.ODE5
#define _ODE6 ODCEbits.ODE6
#define _ODE7 ODCEbits.ODE7
#define _ODE8 ODCEbits.ODE8
#define _ODE9 ODCEbits.ODE9

/* ODCF */
#define _ODF0 ODCFbits.ODF0
#define _ODF1 ODCFbits.ODF1
#define _ODF2 ODCFbits.ODF2
#define _ODF3 ODCFbits.ODF3
#define _ODF4 ODCFbits.ODF4
#define _ODF5 ODCFbits.ODF5
#define _ODF6 ODCFbits.ODF6
#define _ODF7 ODCFbits.ODF7
#define _ODF8 ODCFbits.ODF8
#define _ODF12 ODCFbits.ODF12
#define _ODF13 ODCFbits.ODF13

/* ODCG */
#define _ODG0 ODCGbits.ODG0
#define _ODG1 ODCGbits.ODG1
#define _ODG2 ODCGbits.ODG2
#define _ODG3 ODCGbits.ODG3
#define _ODG6 ODCGbits.ODG6
#define _ODG7 ODCGbits.ODG7
#define _ODG8 ODCGbits.ODG8
#define _ODG9 ODCGbits.ODG9
#define _ODG12 ODCGbits.ODG12
#define _ODG13 ODCGbits.ODG13
#define _ODG14 ODCGbits.ODG14
#define _ODG15 ODCGbits.ODG15

/* RCON */
#define _POR RCONbits.POR
#define _BOR RCONbits.BOR
#define _IDLE RCONbits.IDLE
#define _SLEEP RCONbits.SLEEP
#define _WDTO RCONbits.WDTO
#define _SWDTEN RCONbits.SWDTEN
#define _SWR RCONbits.SWR
#define _EXTR RCONbits.EXTR
#define _VREGS RCONbits.VREGS
#define _CM RCONbits.CM
#define _IOPUWR RCONbits.IOPUWR
#define _TRAPR RCONbits.TRAPR

/* OSCCON */
#define _OSWEN OSCCONbits.OSWEN
#define _SOSCEN OSCCONbits.SOSCEN
#define _CF OSCCONbits.CF
#define _LOCK OSCCONbits.LOCK
#define _CLKLOCK OSCCONbits.CLKLOCK
#define _NOSC OSCCONbits.NOSC
#define _COSC OSCCONbits.COSC
#define _LPOSCEN OSCCONbits.LPOSCEN
#define _NOSC0 OSCCONbits.NOSC0
#define _NOSC1 OSCCONbits.NOSC1
#define _NOSC2 OSCCONbits.NOSC2
#define _COSC0 OSCCONbits.COSC0
#define _COSC1 OSCCONbits.COSC1
#define _COSC2 OSCCONbits.COSC2

/* CLKDIV */
#define _RCDIV CLKDIVbits.RCDIV
#define _DOZEN CLKDIVbits.DOZEN
#define _DOZE CLKDIVbits.DOZE
#define _ROI CLKDIVbits.ROI
#define _RCDIV0 CLKDIVbits.RCDIV0
#define _RCDIV1 CLKDIVbits.RCDIV1
#define _RCDIV2 CLKDIVbits.RCDIV2
#define _DOZE0 CLKDIVbits.DOZE0
#define _DOZE1 CLKDIVbits.DOZE1
#define _DOZE2 CLKDIVbits.DOZE2

/* OSCTUN */
#define _TUN OSCTUNbits.TUN
#define _TUN0 OSCTUNbits.TUN0
#define _TUN1 OSCTUNbits.TUN1
#define _TUN2 OSCTUNbits.TUN2
#define _TUN3 OSCTUNbits.TUN3
#define _TUN4 OSCTUNbits.TUN4
#define _TUN5 OSCTUNbits.TUN5

/* NVMCON */
#define _NVMOP NVMCONbits.NVMOP
#define _ERASE NVMCONbits.ERASE
#define _WRERR NVMCONbits.WRERR
#define _WREN NVMCONbits.WREN
#define _WR NVMCONbits.WR
#define _NVMOP0 NVMCONbits.NVMOP0
#define _NVMOP1 NVMCONbits.NVMOP1
#define _NVMOP2 NVMCONbits.NVMOP2
#define _NVMOP3 NVMCONbits.NVMOP3
#define _PROGOP NVMCONbits.PROGOP
#define _PROGOP0 NVMCONbits.PROGOP0
#define _PROGOP1 NVMCONbits.PROGOP1
#define _PROGOP2 NVMCONbits.PROGOP2
#define _PROGOP3 NVMCONbits.PROGOP3

/* PMD1 */
#define _ADCMD PMD1bits.ADCMD
#define _SPI1MD PMD1bits.SPI1MD
#define _SPI2MD PMD1bits.SPI2MD
#define _U1MD PMD1bits.U1MD
#define _U2MD PMD1bits.U2MD
#define _I2C1MD PMD1bits.I2C1MD
#define _T1MD PMD1bits.T1MD
#define _T2MD PMD1bits.T2MD
#define _T3MD PMD1bits.T3MD
#define _T4MD PMD1bits.T4MD
#define _T5MD PMD1bits.T5MD

/* PMD2 */
#define _OC1MD PMD2bits.OC1MD
#define _OC2MD PMD2bits.OC2MD
#define _OC3MD PMD2bits.OC3MD
#define _OC4MD PMD2bits.OC4MD
#define _OC5MD PMD2bits.OC5MD
#define _IC1MD PMD2bits.IC1MD
#define _IC2MD PMD2bits.IC2MD
#define _IC3MD PMD2bits.IC3MD
#define _IC4MD PMD2bits.IC4MD
#define _IC5MD PMD2bits.IC5MD

/* PMD3 */
#define _I2C2MD PMD3bits.I2C2MD
#define _CRCPMD PMD3bits.CRCPMD
#define _PMPMD PMD3bits.PMPMD
#define _RTCCMD PMD3bits.RTCCMD
#define _CMPMD PMD3bits.CMPMD


/* ---------------------------------------------------------- */
/* Some useful macros for inline assembly stuff               */
/* ---------------------------------------------------------- */

#define Nop()    {__asm__ volatile ("nop");}
#define ClrWdt() {__asm__ volatile ("clrwdt");}
#define Sleep()  {__asm__ volatile ("pwrsav #0");}
#define Idle()   {__asm__ volatile ("pwrsav #1");}

/*----------------------------------------------------------- */
/* Some useful macros for allocating data memory              */
/*----------------------------------------------------------- */

/* The following macros require an argument N that specifies  */
/* alignment. N must a power of two, minimum value = 2.       */
/* For example, to declare an uninitialized array that is     */
/* aligned to a 32 byte address:                              */
/*                                                            */
/* int _BSS(32) buf[16];                                      */
/*                                                            */
/* To declare an initialized array without special            */
/* alignment:                                                 */
/*                                                            */
/* int _DATA(2) table1[] = {0, 1, 1, 2, 3, 5, 8, 13, 21};     */
/*                                                            */
#define _BSS(N)    __attribute__((aligned(N)))
#define _DATA(N)   __attribute__((aligned(N)))

/* The following macros do not require an argument. They can  */
/* be used to locate a variable in persistent data memory or  */
/* in near data memory. For example, to declare two variables */
/* that retain their values across a device reset:            */
/*                                                            */
/* int _PERSISTENT var1,var2;                                 */
/*                                                            */
#define _PERSISTENT __attribute__((persistent))
#define _NEAR       __attribute__((near))

/* ---------------------------------------------------------- */
/* Some useful macros for declaring functions                 */
/* ---------------------------------------------------------- */

/* The following macros can be used to declare interrupt      */
/* service routines (ISRs). For example, to declare an ISR    */
/* for the timer1 interrupt:                                  */
/*                                                            */
/* void _ISR _T1Interrupt(void);                              */
/*                                                            */
/* To declare an ISR for the SPI1 interrupt with fast         */
/* context save:                                              */
/*                                                            */
/* void _ISRFAST _SPI1Interrupt(void);                        */
/*                                                            */
/* Note: ISRs will be installed into the interrupt vector     */
/* tables automatically if the reserved names listed in the   */
/* MPLAB C30 Compiler User's Guide (DS51284) are used.        */
/*                                                            */
#define _ISR __attribute__((interrupt))
#define _ISRFAST __attribute__((interrupt, shadow))

/* ---------------------------------------------------------- */
/* Some useful macros for changing the CPU IPL                */
/* ---------------------------------------------------------- */

/* The following macros can be used to modify the current CPU */
/* IPL. The definition of the macro may vary from device to   */
/* device.                                                    */
/*                                                            */
/* To safely set the CPU IPL, use SET_CPU_IPL(ipl); the       */
/* valid range of ipl is 0-7, it may be any expression.       */
/*                                                            */
/* SET_CPU_IPL(7);                                            */
/*                                                            */
/* To preserve the current IPL and save it use                */
/* SET_AND_SAVE_CPU_IPL(save_to, ipl); the valid range of ipl */
/* is 0-7 and may be any expression, save_to should denote    */
/* some temporary storage.                                    */
/*                                                            */
/* int old_ipl;                                               */
/*                                                            */
/* SET_AND_SAVE_CPU_IPL(old_ipl, 7);                          */
/*                                                            */
/* The IPL can be restored with RESTORE_CPU_IPL(saved_to)     */
/*                                                            */
/* RESTORE_CPU_IPL(old_ipl);                                  */

#define SET_CPU_IPL(ipl) {       \
  int DISI_save;                 \
                                 \
  DISI_save = DISICNT;           \
  asm volatile ("disi #0x3FFF"); \
  SRbits.IPL = ipl;              \
  DISICNT = DISI_save; } (void) 0;

#define SET_AND_SAVE_CPU_IPL(save_to, ipl) { \
  save_to = SRbits.IPL; \
  SET_CPU_IPL(ipl); } (void) 0;

#define RESTORE_CPU_IPL(saved_to) SET_CPU_IPL(saved_to)

/* -------------------------------------------------------- */
/* Macros for setting device configuration registers        */
/* -------------------------------------------------------- */

/* Register CONFIG2 (0x157fc)                               */

#define _CONFIG2(x) __attribute__((section("__CONFIG2.sec,code"))) int _CONFIG2 = (x);

/*
** Only one invocation of CONFIG2 should appear in a project,
** at the top of a C source file (outside of any function).
**
** The following constants can be used to set CONFIG2.
** Multiple options may be combined, as shown:
**
** _CONFIG2( OPT1_ON & OPT2_OFF & OPT3_PLL )
**
**   Two Speed Start-up:
**     IESO_OFF             Disabled
**     IESO_ON              Enabled
**
**   Oscillator Selection:
**     FNOSC_FRC            Fast RC oscillator
**     FNOSC_FRCPLL         Fast RC oscillator w/ divide and PLL
**     FNOSC_PRI            Primary oscillator (XT, HS, EC)
**     FNOSC_PRIPLL         Primary oscillator (XT, HS, EC) w/ PLL
**     FNOSC_SOSC           Secondary oscillator
**     FNOSC_LPRC           Low power RC oscillator
**     FNOSC_LPRCDIV        Fast RC oscillator with divide
**
**   Clock switching and clock monitor:
**     FCKSM_CSECME         Both enabled
**     FCKSM_CSECMD         Only clock switching enabled
**     FCKSM_CSDCMD         Both disabled
**
**   OSCO/RC15 function:
**     OSCIOFNC_ON          RC15
**     OSCIOFNC_OFF         OSCO or Fosc/2
**
**   Oscillator Selection:
**     POSCMOD_EC           External clock
**     POSCMOD_XT           XT oscillator
**     POSCMOD_HS           HS oscillator
**     POSCMOD_NONE         Primary disabled
**
*/

#define IESO_OFF             0x7FFF
#define IESO_ON              0xFFFF

#define FNOSC_FRC            0xF8FF
#define FNOSC_FRCPLL         0xF9FF
#define FNOSC_PRI            0xFAFF
#define FNOSC_PRIPLL         0xFBFF
#define FNOSC_SOSC           0xFCFF
#define FNOSC_LPRC           0xFDFF
#define FNOSC_LPRCDIV        0xFFFF

#define FCKSM_CSECME         0xFF3F
#define FCKSM_CSECMD         0xFF7F
#define FCKSM_CSDCMD         0xFFBF

#define OSCIOFNC_ON          0xFFDF
#define OSCIOFNC_OFF         0xFFFF

#define POSCMOD_EC           0xFFFC
#define POSCMOD_XT           0xFFFD
#define POSCMOD_HS           0xFFFE
#define POSCMOD_NONE         0xFFFF

/* Register CONFIG1 (0x157fe)                               */

#define _CONFIG1(x) __attribute__((section("__CONFIG1.sec,code"))) int _CONFIG1 = (x);

/*
** Only one invocation of CONFIG1 should appear in a project,
** at the top of a C source file (outside of any function).
**
** The following constants can be used to set CONFIG1.
** Multiple options may be combined, as shown:
**
** _CONFIG1( OPT1_ON & OPT2_OFF & OPT3_PLL )
**
**   JTAG:
**     JTAGEN_OFF           Disabled
**     JTAGEN_ON            Enabled
**
**   Code Protect:
**     GCP_ON               Enabled
**     GCP_OFF              Disabled
**
**   Write Protect:
**     GWRP_ON              Enabled
**     GWRP_OFF             Disabled
**
**   Background Debugger:
**     BKBUG_ON             Enabled
**     BKBUG_OFF            Disabled
**
**   Clip-on Emulation mode:
**     COE_ON               Enabled
**     COE_OFF              Disabled
**
**   ICD pins select:
**     ICS_PGx1             EMUC/EMUD share PGC1/PGD1
**     ICS_PGx2             EMUC/EMUD share PGC2/PGD2
**
**   Watchdog Timer:
**     FWDTEN_OFF           Disabled
**     FWDTEN_ON            Enabled
**
**   Windowed WDT:
**     WINDIS_ON            Enabled
**     WINDIS_OFF           Disabled
**
**   Watchdog prescaler:
**     FWPSA_PR32           1:32
**     FWPSA_PR128          1:128
**
**   Watchdog postscale:
**     WDTPS_PS1            1:1
**     WDTPS_PS2            1:2
**     WDTPS_PS4            1:4
**     WDTPS_PS8            1:8
**     WDTPS_PS16           1:16
**     WDTPS_PS32           1:32
**     WDTPS_PS64           1:64
**     WDTPS_PS128          1:128
**     WDTPS_PS256          1:256
**     WDTPS_PS512          1:512
**     WDTPS_PS1024         1:1,024
**     WDTPS_PS2048         1:2,048
**     WDTPS_PS4096         1:4,096
**     WDTPS_PS8192         1:8,192
**     WDTPS_PS16384        1:16,384
**     WDTPS_PS32768        1:32,768
**
*/

#define JTAGEN_OFF           0xBFFF
#define JTAGEN_ON            0xFFFF

#define GCP_ON               0xDFFF
#define GCP_OFF              0xFFFF

#define GWRP_ON              0xEFFF
#define GWRP_OFF             0xFFFF

#define BKBUG_ON             0xF7FF
#define BKBUG_OFF            0xFFFF

#define COE_ON               0xFBFF
#define COE_OFF              0xFFFF

#define ICS_PGx1             0xFEFF
#define ICS_PGx2             0xFFFF

#define FWDTEN_OFF           0xFF7F
#define FWDTEN_ON            0xFFFF

#define WINDIS_ON            0xFFBF
#define WINDIS_OFF           0xFFFF

#define FWPSA_PR32           0xFFEF
#define FWPSA_PR128          0xFFFF

#define WDTPS_PS1            0xFFF0
#define WDTPS_PS2            0xFFF1
#define WDTPS_PS4            0xFFF2
#define WDTPS_PS8            0xFFF3
#define WDTPS_PS16           0xFFF4
#define WDTPS_PS32           0xFFF5
#define WDTPS_PS64           0xFFF6
#define WDTPS_PS128          0xFFF7
#define WDTPS_PS256          0xFFF8
#define WDTPS_PS512          0xFFF9
#define WDTPS_PS1024         0xFFFA
#define WDTPS_PS2048         0xFFFB
#define WDTPS_PS4096         0xFFFC
#define WDTPS_PS8192         0xFFFD
#define WDTPS_PS16384        0xFFFE
#define WDTPS_PS32768        0xFFFF


#endif
