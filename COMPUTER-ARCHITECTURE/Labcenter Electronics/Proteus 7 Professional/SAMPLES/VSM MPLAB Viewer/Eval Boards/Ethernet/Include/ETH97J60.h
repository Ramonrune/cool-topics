/*********************************************************************
 *
 *            Ethernet registers/bits for PIC18F97J60
 *
 *********************************************************************
 * FileName:        ETH97J60.h
 * Description: 	Include file for Ethernet related data structures 
 * 					constants.
 * Company:         Microchip Technology, Inc.
 *
 * Software License Agreement
 *
 * This software is owned by Microchip Technology Inc. ("Microchip") 
 * and is supplied to you for use exclusively as described in the 
 * associated software agreement.  This software is protected by 
 * software and other intellectual property laws.  Any use in 
 * violation of the software license may subject the user to criminal 
 * sanctions as well as civil liability.  Copyright 2006 Microchip
 * Technology Inc.  All rights reserved.
 *
 * This software is provided "AS IS."  MICROCHIP DISCLAIMS ALL 
 * WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE, NOT LIMITED 
 * TO MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND 
 * INFRINGEMENT.  Microchip shall in no event be liable for special, 
 * incidental, or consequential damages.
 *
 *
 * Author               Date        Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Howard Schlunder		06/12/05	Modified for 97J60 (from ENC28J60)
 * Howard Schlunder		03/23/06	Updated for Advance Data Sheet
 * Howard Schlunder		06/29/06	Changed MACON3_PHDRLEN to MACON3_PHDREN
********************************************************************/

#ifndef __ETH97J60_H
#define __ETH97J60_H

typedef union {
	BYTE v[7];
	struct {
		WORD	 ByteCount;
		unsigned CollisionCount:4;
		unsigned CRCError:1;
		unsigned LengthCheckError:1;
		unsigned LengthOutOfRange:1;
		unsigned Done:1;
		unsigned Multicast:1;
		unsigned Broadcast:1;
		unsigned PacketDefer:1;
		unsigned ExcessiveDefer:1;
		unsigned MaximumCollisions:1;
		unsigned LateCollision:1;
		unsigned Giant:1;
		unsigned Underrun:1;
		WORD 	 BytesTransmittedOnWire;
		unsigned ControlFrame:1;
		unsigned PAUSEControlFrame:1;
		unsigned BackpressureApplied:1;
		unsigned VLANTaggedFrame:1;
		unsigned Zeros:4;
	} bits;
} TXSTATUS;

typedef union {
	BYTE v[4];
	struct {
		WORD	 ByteCount;
		unsigned PreviouslyIgnored:1;
		unsigned RXDCPreviouslySeen:1;
		unsigned CarrierPreviouslySeen:1;
		unsigned CodeViolation:1;
		unsigned CRCError:1;
		unsigned LengthCheckError:1;
		unsigned LengthOutOfRange:1;
		unsigned ReceiveOk:1;
		unsigned Multicast:1;
		unsigned Broadcast:1;
		unsigned DribbleNibble:1;
		unsigned ControlFrame:1;
		unsigned PauseControlFrame:1;
		unsigned UnsupportedOpcode:1;
		unsigned VLANType:1;
		unsigned Zero:1;
	} bits;
} RXSTATUS;



/******************************************************************************
* PH Register Locations
******************************************************************************/
#define PHCON1	0x00
#define PHSTAT1	0x01
#define PHID1	0x02
#define PHID2	0x03
#define PHCON2	0x10
#define PHSTAT2	0x11
#define PHIE	0x12
#define PHIR	0x13
#define PHLCON	0x14


typedef union {
	WORD Val;
	WORD_VAL VAL;

	// PHCON1 bits ----------
	struct {
		unsigned :8;
		unsigned PDPXMD:1;
		unsigned :2;
		unsigned PPWRSV:1;
		unsigned :2;
		unsigned PLOOPBK:1;
		unsigned PRST:1;
	} PHCON1bits;

	// PHSTAT1 bits --------
	struct {
		unsigned :1;
		unsigned JBSTAT:1;
		unsigned LLSTAT:1;
		unsigned :5;
		unsigned :3;
		unsigned PHDPX:1;
		unsigned PFDPX:1;
		unsigned :3;
	} PHSTAT1bits;

	// PHID2 bits ----------
	struct {
		unsigned PREV0:1;
		unsigned PREV1:1;
		unsigned PREV2:1;
		unsigned PREV3:1;
		unsigned PPN0:1;
		unsigned PPN1:1;
		unsigned PPN2:1;
		unsigned PPN3:1;
		unsigned PPN4:1;
		unsigned PPN5:1;
		unsigned PID19:1;
		unsigned PID20:1;
		unsigned PID21:1;
		unsigned PID22:1;
		unsigned PID23:1;
		unsigned PID24:1;
	} PHID2bits;
	struct {
		unsigned PREV:4;
		unsigned PPNL:4;
		unsigned PPNH:2;
		unsigned PID:6;
	} PHID2bits2;

	// PHCON2 bits ----------
	struct {
		unsigned :8;
		unsigned HDLDIS:1;
		unsigned :1;
		unsigned JABBER:1;
		unsigned :2;
		unsigned TXDIS:1;
		unsigned FRCLNK:1;
		unsigned :1;
	} PHCON2bits;

	// PHSTAT2 bits --------
	struct {
		unsigned :5;
		unsigned PLRITY:1;
		unsigned :2;
		unsigned :1;
		unsigned DPXSTAT:1;
		unsigned LSTAT:1;
		unsigned COLSTAT:1;
		unsigned RXSTAT:1;
		unsigned TXSTAT:1;
		unsigned :2;
	} PHSTAT2bits;

	// PHIE bits -----------
	struct {
		unsigned :1;
		unsigned PGEIE:1;
		unsigned :2;
		unsigned PLNKIE:1;
		unsigned :3;
		unsigned :8;
	} PHIEbits;

	// PHIR bits -----------
	struct {
		unsigned :2;
		unsigned PGIF:1;
		unsigned :1;
		unsigned PLNKIF:1;
		unsigned :3;
		unsigned :8;
	} PHIRbits;

	// PHLCON bits -------
	struct {
		unsigned :1;
		unsigned STRCH:1;
		unsigned LFRQ0:1;
		unsigned LFRQ1:1;
		unsigned LBCFG0:1;
		unsigned LBCFG1:1;
		unsigned LBCFG2:1;
		unsigned LBCFG3:1;
		unsigned LACFG0:1;
		unsigned LACFG1:1;
		unsigned LACFG2:1;
		unsigned LACFG3:1;
		unsigned :4;
	} PHLCONbits;
	struct {
		unsigned :1;
		unsigned STRCH:1;
		unsigned LFRQ:2;
		unsigned LBCFG:4;
		unsigned LACFG:4;
		unsigned :4;
	} PHLCONbits2;
} PHYREG;


/******************************************************************************
* Individual Register Bits
******************************************************************************/
// ETH/MAC/MII bits

// EIE bits ----------
#define	EIE_PKTIE		(1<<6)
#define	EIE_DMAIE		(1<<5)
#define	EIE_LINKIE		(1<<4)
#define	EIE_TXIE		(1<<3)
#define	EIE_TXERIE		(1<<1)
#define	EIE_RXERIE		(1)

// EIR bits ----------
#define	EIR_PKTIF		(1<<6)
#define	EIR_DMAIF		(1<<5)
#define	EIR_LINKIF		(1<<4)
#define	EIR_TXIF		(1<<3)
#define	EIR_TXERIF		(1<<1)
#define	EIR_RXERIF		(1)
	
// ESTAT bits ---------
#define	ESTAT_BUFER		(1<<6)
#define	ESTAT_RXBUSY	(1<<2)
#define	ESTAT_TXABRT	(1<<1)
#define	ESTAT_PHYRDY	(1)
	
// ECON2 bits --------
#define	ECON2_AUTOINC	(1<<7)
#define	ECON2_PKTDEC	(1<<6)
#define	ECON2_ETHEN		(1<<5)
	
// ECON1 bits --------
#define	ECON1_TXRST		(1<<7)
#define	ECON1_RXRST		(1<<6)
#define	ECON1_DMAST		(1<<5)
#define	ECON1_CSUMEN	(1<<4)
#define	ECON1_TXRTS		(1<<3)
#define	ECON1_RXEN		(1<<2)
	
// ERXFCON bits ------
#define	ERXFCON_UCEN	(1<<7)
#define	ERXFCON_ANDOR	(1<<6)
#define	ERXFCON_CRCEN	(1<<5)
#define	ERXFCON_PMEN	(1<<4)
#define	ERXFCON_MPEN	(1<<3)
#define	ERXFCON_HTEN	(1<<2)
#define	ERXFCON_MCEN	(1<<1)
#define	ERXFCON_BCEN	(1)
	
// MACON1 bits --------
#define	MACON1_LOOPBK	(1<<4)
#define	MACON1_TXPAUS	(1<<3)
#define	MACON1_RXPAUS	(1<<2)
#define	MACON1_PASSALL	(1<<1)
#define	MACON1_MARXEN	(1)
	
// MACON3 bits --------
#define	MACON3_PADCFG2	(1<<7)
#define	MACON3_PADCFG1	(1<<6)
#define	MACON3_PADCFG0	(1<<5)
#define	MACON3_TXCRCEN	(1<<4)
#define	MACON3_PHDREN	(1<<3)
#define	MACON3_HFRMEN	(1<<2)
#define	MACON3_FRMLNEN	(1<<1)
#define	MACON3_FULDPX	(1)
	
// MACON4 bits --------
#define	MACON4_DEFER	(1<<6)
#define	MACON4_BPEN		(1<<5)
#define	MACON4_NOBKOFF	(1<<4)
	
// MICMD bits ---------
#define	MICMD_MIISCAN	(1<<1)
#define	MICMD_MIIRD		(1)

// MISTAT bits --------
#define	MISTAT_NVALID	(1<<2)
#define	MISTAT_SCAN		(1<<1)
#define	MISTAT_BUSY		(1)
	
// EFLOCON bits -----
#define	EFLOCON_FULDPXS	(1<<2)
#define	EFLOCON_FCEN1	(1<<1)
#define	EFLOCON_FCEN0	(1)



// PHY bits

// PHCON1 bits ----------
#define	PHCON1_PRST		(1ul<<15)
#define	PHCON1_PLOOPBK	(1ul<<14)
#define	PHCON1_PPWRSV	(1ul<<11)
#define	PHCON1_PDPXMD	(1ul<<8)

// PHSTAT1 bits --------
#define	PHSTAT1_PFDPX	(1ul<<12)
#define	PHSTAT1_PHDPX	(1ul<<11)
#define	PHSTAT1_LLSTAT	(1ul<<2)
#define	PHSTAT1_JBSTAT	(1ul<<1)

// PHID2 bits --------
#define	PHID2_PID24		(1ul<<15)
#define	PHID2_PID23		(1ul<<14)
#define	PHID2_PID22		(1ul<<13)
#define	PHID2_PID21		(1ul<<12)
#define	PHID2_PID20		(1ul<<11)
#define	PHID2_PID19		(1ul<<10)
#define	PHID2_PPN5		(1ul<<9)
#define	PHID2_PPN4		(1ul<<8)
#define	PHID2_PPN3		(1ul<<7)
#define	PHID2_PPN2		(1ul<<6)
#define	PHID2_PPN1		(1ul<<5)
#define	PHID2_PPN0		(1ul<<4)
#define	PHID2_PREV3		(1ul<<3)
#define	PHID2_PREV2		(1ul<<2)
#define	PHID2_PREV1		(1ul<<1)
#define	PHID2_PREV0		(1ul)

// PHCON2 bits ----------
#define	PHCON2_FRCLNK	(1ul<<14)
#define	PHCON2_TXDIS	(1ul<<13)
#define	PHCON2_JABBER	(1ul<<10)
#define	PHCON2_HDLDIS	(1ul<<8)

// PHSTAT2 bits --------
#define	PHSTAT2_TXSTAT	(1ul<<13)
#define	PHSTAT2_RXSTAT	(1ul<<12)
#define	PHSTAT2_COLSTAT	(1ul<<11)
#define	PHSTAT2_LSTAT	(1ul<<10)
#define	PHSTAT2_DPXSTAT	(1ul<<9)
#define	PHSTAT2_PLRITY	(1ul<<5)

// PHIE bits -----------
#define	PHIE_PLNKIE		(1ul<<4)
#define	PHIE_PGEIE		(1ul<<1)

// PHIR bits -----------
#define	PHIR_PLNKIF		(1ul<<4)
#define	PHIR_PGIF		(1ul<<2)

// PHLCON bits -------
#define	PHLCON_LACFG3	(1ul<<11)
#define	PHLCON_LACFG2	(1ul<<10)
#define	PHLCON_LACFG1	(1ul<<9)
#define	PHLCON_LACFG0	(1ul<<8)
#define	PHLCON_LBCFG3	(1ul<<7)
#define	PHLCON_LBCFG2	(1ul<<6)
#define	PHLCON_LBCFG1	(1ul<<5)
#define	PHLCON_LBCFG0	(1ul<<4)
#define	PHLCON_LFRQ1	(1ul<<3)
#define	PHLCON_LFRQ0	(1ul<<2)
#define	PHLCON_STRCH	(1ul<<1)

#endif
