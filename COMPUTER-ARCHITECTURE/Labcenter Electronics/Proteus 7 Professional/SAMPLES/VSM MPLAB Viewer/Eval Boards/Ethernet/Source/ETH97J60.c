/*********************************************************************
 *
 *     MAC Module (Microchip PIC18F97J60 family) for Microchip TCP/IP Stack
 *
 *********************************************************************
 * FileName:        ETH97J60.c
 * Dependencies:    ETH97J60.h
 *					MAC.h
 *					string.h
 *                  StackTsk.h
 *                  Helpers.h
 *					Delay.h
 * Processor:       PIC18F97J60 family device
 * Complier:        MCC18 v3.02 or higher
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
 * Author               Date   	 Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Rawin Rojvanit       07/26/05 Stuff
 * Howard Schlunder     11/17/05 Ported to PIC18F97J60
 * Howard Schlunder		06/16/06 Synchronized with ENC28J60 code
********************************************************************/
#define THIS_IS_MAC_LAYER

#include <string.h>
#include "..\Include\StackTsk.h"
#include "..\Include\Helpers.h"
#include "..\Include\Delay.h"
#include "..\Include\MAC.h"

#if !defined(__18F97J60) && !defined(__18F96J65) && !defined(__18F96J60) && !defined(__18F87J60) && !defined(__18F86J65) && !defined(__18F86J60) && !defined(__18F67J60) && !defined(__18F66J65) && !defined(__18F66J60) && !defined(HI_TECH_C)
	#error "ETH97J60.c MAC layer for PIC18F97J60 family Ethernet modules is included, but a PIC18F97J60 family mirocontroller is not selected.  Did you mean to include the ENC28J60.c MAC layer instead?  Is your target processor selected correctly?"
#endif

#if defined(STACK_USE_SLIP)
#error Unexpected module is detected.
#error This file must be linked when SLIP module is not in use.
#endif


/** D E F I N I T I O N S ****************************************************/
// Since the Ethernet PHY doesn't support auto-negotiation, full-duplex mode is 
// not compatible with most switches/routers.  If a dedicated network is used 
// where the duplex of the remote node can be manually configured, you may 
// change this configuration.  Otherwise, half duplex should always be used.
#define HALF_DUPLEX
//#define FULL_DUPLEX

// Pseudo Functions
#define LOW(a) 					(a & 0xFF)
#define HIGH(a) 				((a>>8) & 0xFF)

// NIC RAM definitions
#define RAMSIZE	8192ul		
#define TXSTART (RAMSIZE-(MAC_TX_BUFFER_COUNT * (MAC_TX_BUFFER_SIZE + 8ul)))
#define RXSTART	(0ul)						// Should be an even memory address
#define	RXSTOP	((TXSTART-2ul) | 0x0001ul)	// Odd for errata workaround
#define RXSIZE	(RXSTOP-RXSTART+1ul)

#define ETHER_IP	(0x00u)
#define ETHER_ARP	(0x06u)

#define MAXFRAMEC	(1500u+sizeof(ETHER_HEADER)+4u)

// A generic structure representing the Ethernet header starting all Ethernet 
// frames
typedef struct _ETHER_HEADER
{
    MAC_ADDR        DestMACAddr;
    MAC_ADDR        SourceMACAddr;
    WORD_VAL        Type;
} ETHER_HEADER;

// A header appended at the start of all RX frames by the hardware
typedef struct _ENC_PREAMBLE
{
    WORD			NextPacketPointer;
    RXSTATUS		StatusVector;

    MAC_ADDR        DestMACAddr;
    MAC_ADDR        SourceMACAddr;
    WORD_VAL        Type;
} ENC_PREAMBLE;

typedef struct _DATA_BUFFER
{
	WORD_VAL StartAddress;
	WORD_VAL EndAddress;
	struct 
	{
		unsigned char bFree : 1;
		unsigned char bTransmitted : 1;
	} Flags;
} DATA_BUFFER;



// Internal and externally used MAC level variables.
#if MAC_TX_BUFFER_COUNT > 1
static DATA_BUFFER TxBuffers[MAC_TX_BUFFER_COUNT];
#endif
BUFFER CurrentTxBuffer;
BUFFER LastTXedBuffer;

// Internal MAC level variables and flags.
WORD_VAL NextPacketLocation;
WORD_VAL CurrentPacketLocation;
BOOL WasDiscarded;

// Temp fix for bank f issue where registers are not located properly on PIC18F97J60 silicon revision A1 (A1 is beta silicon only)
// This can can be deleted for all production silicon chips (Rev. B0)
#pragma udata eth_sfr0=0xEFC
union
{
	volatile far unsigned char EIRx;
	volatile far struct {
	  unsigned RXERIF:1;
	  unsigned TXERIF:1;
	  unsigned WOLIF:1;
	  unsigned TXIF:1;
	  unsigned LINKIF:1;
	  unsigned DMAIF:1;
	  unsigned PKTIF:1;
	} EIRxbits;
} EIRUnion;
#pragma udata eth_sfr1=0xEFA
volatile far unsigned char EDATAx;
#pragma udata eth_sfr3=0xEE0
union {
	volatile far unsigned int ERDPTx;
	volatile far struct {
		unsigned char ERDPTLx;
		unsigned char ERDPTHx;
	} ERDPTxbytes;
} ERDPTUnion;
#pragma udata eth_sfr4=0xEDF
union {
	volatile far unsigned char       ECON1x;
	volatile far struct {
	  unsigned :2;
	  unsigned RXEN:1;
	  unsigned TXRTS:1;
	  unsigned CSUMEN:1;
	  unsigned DMAST:1;
	  unsigned RXRST:1;
	  unsigned TXRST:1;
	} ECON1xbits;
}ECON1Union;
//#pragma udata eth_sfr5=0xEFD
//volatile far unsigned char ESTATx;
#pragma udata

#define	EDATA		EDATAx
#define EIR			EIRUnion.EIRx
#define EIRbits		EIRUnion.EIRxbits
#define ERDPT		ERDPTUnion.ERDPTx
#define ERDPTH		ERDPTUnion.ERDPTxbytes.ERDPTHx
#define ERDPTL		ERDPTUnion.ERDPTxbytes.ERDPTLx
#define ECON1		ECON1Union.ECON1x
#define ECON1bits	ECON1Union.ECON1xbits
#define ESTAT		ESTATx


/******************************************************************************
 * Function:        void MACInit(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACInit enables the Ethernet module, waits for the 
 *                  to become ready, and programs all registers for future 
 *                  TX/RX operations.
 *
 * Note:            This function blocks for at least 1ms, waiting for the 
 *                  hardware to stabilize.
 *****************************************************************************/
void MACInit(void)
{
	BYTE i;
	
	
    LATAbits.LATA0 = 0;
    LATAbits.LATA1 = 0;
    TRISAbits.TRISA0 = 0;   // Set LED0 as output
    TRISAbits.TRISA1 = 0;   // Set LED1 as output
    ECON2bits.ETHEN = 1;    // Enable Ethernet!

	// Wait for PHYRDY to become set.
    while(!ESTATbits.PHYRDY);

    // Wait at least 1ms for everything to stabilize
    DelayMs(1);

#if MAC_TX_BUFFER_COUNT > 1
    // On Init, all transmit buffers are free.
    for (i = 0; i < MAC_TX_BUFFER_COUNT; i++ )
    {
        TxBuffers[i].StartAddress.Val = TXSTART + ((WORD)i * (MAC_TX_BUFFER_SIZE+8));
        TxBuffers[i].Flags.bFree = TRUE;
    }
#endif
    CurrentTxBuffer = 0;
	
	// Configure the receive buffer boundary pointers 
	// and the buffer write protect pointer (receive buffer read pointer)
	WasDiscarded = TRUE;
	NextPacketLocation.Val = RXSTART;

	ERXST = RXSTART;
	ERXRDPTL = LOW(RXSTOP);	// Write low byte first
	ERXRDPTH = HIGH(RXSTOP);// Write high byte last
#if RXSTOP != 0x1FFF	// The RESET default ERXND is 0x1FFF
	ERXND = RXSTOP;
#endif
#if TXSTART != 0		// The RESET default ETXST is 0
	ETXST = TXSTART;
#endif

	// Configure Receive Filters 
	// (No need to reconfigure - Unicast OR Broadcast with CRC checking is 
	// acceptable)
	//ERXFCON = ERXFCON_CRCEN;     // Promiscious mode


	// Configure the MAC
	// Enable the receive portion of the MAC
    MACON1 = MACON1_TXPAUS | MACON1_RXPAUS | MACON1_MARXEN; Nop();

	// Pad packets to 60 bytes, add CRC, and check Type/Length field.
    MACON3 = MACON3_PADCFG0 | MACON3_TXCRCEN | MACON3_FRMLNEN; Nop();

    // Allow infinite deferals if the medium is continuously busy 
    // (do not time out a transmission if the half duplex medium is 
    // completely saturated with other people's data)
    MACON4 = MACON4_DEFER; Nop();

	// Late collisions occur beyond 63 bytes (default for 802.3 spec)
    MACLCON2 = 63; Nop();
	
	// Set non-back-to-back inter-packet gap to 9.6us.  The back-to-back 
	// inter-packet gap (MABBIPG) is set by MACSetDuplex() which is called 
	// later.
    MAIPGL = 0x12; Nop();
    MAIPGH = 0x0C; Nop();

	// Set the maximum packet size which the controller will accept
    MAMXFLL = LOW(MAXFRAMEC); Nop();
    MAMXFLH = HIGH(MAXFRAMEC); Nop();
	

    // Initialize physical MAC address registers
    MAADR1 = AppConfig.MyMACAddr.v[0]; Nop();
    MAADR2 = AppConfig.MyMACAddr.v[1]; Nop();
    MAADR3 = AppConfig.MyMACAddr.v[2]; Nop();
    MAADR4 = AppConfig.MyMACAddr.v[3]; Nop();
    MAADR5 = AppConfig.MyMACAddr.v[4]; Nop();
    MAADR6 = AppConfig.MyMACAddr.v[5]; Nop();

	// Disable half duplex loopback in PHY.  
	WritePHYReg(PHCON2, PHCON2_HDLDIS);

	// Configure LEDA to display LINK status, LEDB to display TX/RX activity
	SetLEDConfig(0x0472);
	
	// Use the external LEDB polarity to determine weather full or half duplex 
	// communication mode should be set.  
#if defined(FULL_DUPLEX)
	MACSetDuplex(FULL);		// Function exits with Bank 2 selected
#else
	MACSetDuplex(HALF);		// Function exits with Bank 2 selected
#endif

	// Enable packet reception
    ECON1bits.RXEN = 1;
}//end MACInit


/******************************************************************************
 * Function:        BOOL MACIsLinked(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          TRUE: If the PHY reports that a link partner is present 
 *						  and the link has been up continuously since the last 
 *						  call to MACIsLinked()
 *					FALSE: If the PHY reports no link partner, or the link went 
 *						   down momentarily since the last call to MACIsLinked()
 *
 * Side Effects:    None
 *
 * Overview:        Returns the PHSTAT1.LLSTAT bit.
 *
 * Note:            None
 *****************************************************************************/
BOOL MACIsLinked(void)
{
	// LLSTAT is a latching low link status bit.  Therefore, if the link 
	// goes down and comes back up before a higher level stack program calls
	// MACIsLinked(), MACIsLinked() will still return FALSE.  The next 
	// call to MACIsLinked() will return TRUE (unless the link goes down 
	// again).
	return ReadPHYReg(PHSTAT1).PHSTAT1bits.LLSTAT;
}


/******************************************************************************
 * Function:        BOOL MACIsTxReady(BOOL HighPriority)
 *
 * PreCondition:    None
 *
 * Input:           HighPriority: TRUE: Check the hardware ECON1.TXRTS bit
 *								  FALSE: Check if a TX buffer is free
 *
 * Output:          TRUE: If no Ethernet transmission is in progress
 *					FALSE: If a previous transmission was started, and it has 
 *						   not completed yet.  While FALSE, the data in the 
 *						   transmit buffer and the TXST/TXND pointers must not
 *						   be changed.
 *
 * Side Effects:    None
 *
 * Overview:        Returns the ECON1.TXRTS bit
 *
 * Note:            None
 *****************************************************************************/
BOOL MACIsTxReady(BOOL HighPriority)
{
#if MAC_TX_BUFFER_COUNT > 1
	BUFFER i;

	if(HighPriority)
#endif
	{
	    return !ECON1bits.TXRTS;
	}

#if MAC_TX_BUFFER_COUNT > 1

	// Check if the current buffer can be modified.  It cannot be modified if 
	// the TX hardware is currently transmitting it.
	if(CurrentTxBuffer == LastTXedBuffer)
	{
	    return !ECON1bits.TXRTS;
	}

	// Check if a buffer is available for a new packet
	for(i = 1; i < MAC_TX_BUFFER_COUNT; i++)
	{
		if(TxBuffers[i].Flags.bFree)
		{
			return TRUE;
		}
	}

	return FALSE;
#endif
}


BUFFER MACGetTxBuffer(BOOL HighPriority)
{
#if MAC_TX_BUFFER_COUNT > 1
	BUFFER i;

	if(HighPriority)
#endif
	{
		return !ECON1bits.TXRTS ? 0 : INVALID_BUFFER;
	}
	
#if MAC_TX_BUFFER_COUNT > 1
	// Find a free buffer
	for(i = 1; i < MAC_TX_BUFFER_COUNT; i++)
	{
		// If this buffer is free, then mark it as used and return with it
		if(TxBuffers[i].Flags.bFree)
		{
			TxBuffers[i].Flags.bFree = FALSE;
			TxBuffers[i].Flags.bTransmitted = FALSE;
			return i;
		}
	}

	return INVALID_BUFFER;
#endif
}


void MACDiscardTx(BUFFER buffer)
{
#if MAC_TX_BUFFER_COUNT > 1
	if(buffer <= MAC_TX_BUFFER_COUNT)
	{
	    TxBuffers[buffer].Flags.bFree = TRUE;
	    CurrentTxBuffer = buffer;
	}
#endif
}


/******************************************************************************
 * Function:        void MACDiscardRx(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        Marks the last received packet (obtained using 
 *					MACGetHeader())as being processed and frees the buffer 
 *					memory associated with it
 *
 * Note:            None
 *****************************************************************************/
void MACDiscardRx(void)
{
	WORD_VAL NewRXRDLocation;

	// Make sure the current packet was not already discarded
	if( WasDiscarded )
		return;
	WasDiscarded = TRUE;
	
	// Decrement the next packet pointer before writing it into 
	// the ERXRDPT registers.  This is a silicon errata workaround.
	// RX buffer wrapping must be taken into account if the 
	// NextPacketLocation is precisely RXSTART.
	NewRXRDLocation.Val = NextPacketLocation.Val - 1;
#if RXSTART == 0
	if(NewRXRDLocation.Val > RXSTOP)
#else
	if(NewRXRDLocation.Val < RXSTART || NewRXRDLocation.Val > RXSTOP)
#endif
	{
		NewRXRDLocation.Val = RXSTOP;
	}

	// Decrement the RX packet counter register, EPKTCNT
    ECON2bits.PKTDEC = 1;

	// Move the receive read pointer to unwrite-protect the memory used by the 
	// last packet.  The writing order is important: set the low byte first, 
	// high byte last.
    ERXRDPTL = NewRXRDLocation.v[0];
	ERXRDPTH = NewRXRDLocation.v[1];
	
	// Clearing the PKTIF flag should automatically be done by hardware, but 
	// the current silicon version requires that you manually clear it.
	// Clear the packet pending interrupt bit (if we can: EPKTCNT must be 0).  This 
	// must not occur immediately after setting ECON2bits.PKTDEC (at least one NOP 
	// or other instruction must execute first).
	EIRbits.PKTIF = 0;
}


/******************************************************************************
 * Function:        WORD MACGetFreeRxSize(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          A WORD estimate of how much RX buffer space is free at 
 *					the present time.
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 *****************************************************************************/
WORD MACGetFreeRxSize(void)
{
	WORD_VAL ReadPT, WritePT;

	// Read the Ethernet hardware buffer write pointer.  Because packets can be 
	// received at any time, it can change between reading the low and high 
	// bytes.  A loop is necessary to make certain a proper low/high byte pair
	// is read.
	do {
		// Save EPKTCNT in a temporary location
		ReadPT.v[0] = EPKTCNT;
	
		WritePT.Val = ERXWRPT;	
	} while(EPKTCNT != ReadPT.v[0]);
	
	// Determine where the write protection pointer is
	ReadPT.Val = ERXRDPT;

	
	// Calculate the difference between the pointers, taking care to account 
	// for buffer wrapping conditions
	if ( WritePT.Val > ReadPT.Val )
	{
		return (RXSTOP - RXSTART) - (WritePT.Val - ReadPT.Val);
	}
	else if ( WritePT.Val == ReadPT.Val )
	{
		return RXSIZE - 1;
	}
	else
    {
		return ReadPT.Val - WritePT.Val - 1;
	}
}

/******************************************************************************
 * Function:        BOOL MACGetHeader(MAC_ADDR *remote, BYTE* type)
 *
 * PreCondition:    None
 *
 * Input:           *remote: Location to store the Source MAC address of the 
 *							 received frame.
 *					*type: Location of a BYTE to store the constant 
 *						   MAC_UNKNOWN, ETHER_IP, or ETHER_ARP, representing 
 *						   the contents of the Ethernet type field.
 *
 * Output:          TRUE: If a packet was waiting in the RX buffer.  The 
 *						  remote, and type values are updated.
 *					FALSE: If a packet was not pending.  remote and type are 
 *						   not changed.
 *
 * Side Effects:    Last packet is discarded if MACDiscardRx() hasn't already
 *					been called.
 *
 * Overview:        None
 *
 * Note:            None
 *****************************************************************************/
BOOL MACGetHeader(MAC_ADDR *remote, BYTE* type)
{
    ENC_PREAMBLE header;

	// Test if at least one packet has been received and is waiting
    if(EPKTCNT == 0)
    {
        return FALSE;
    }

	// Make absolutely certain that any previous packet was discarded
	if(WasDiscarded == FALSE)
	{
		MACDiscardRx();
		return FALSE;
	}
	// Save the location of this packet
	CurrentPacketLocation.Val = NextPacketLocation.Val;

	// Set the read pointer to the beginning of the next unprocessed packet
    ERDPT = NextPacketLocation.Val;

	// Obtain the MAC header from the Ethernet buffer
	MACGetArray((BYTE*)&header, sizeof(header));

	// The EtherType field, like most items transmitted on the Ethernet medium
	// are in big endian.
    header.Type.Val = swaps(header.Type.Val);

	if(header.NextPacketPointer > RXSTOP || ((BYTE_VAL*)(&header.NextPacketPointer))->bits.b0 ||
	   header.StatusVector.bits.Zero ||
	   header.StatusVector.bits.CRCError ||
	   header.StatusVector.bits.ByteCount > 1518 ||
	   !header.StatusVector.bits.ReceiveOk)
	{
		Reset();
	}

	// Save the location where the hardware will write the next packet to
	NextPacketLocation.Val = header.NextPacketPointer;

	// Return the Ethernet frame's Source MAC address field to the caller
	// This parameter is useful for replying to requests without requiring an 
	// ARP cycle.
    memcpy((void*)remote->v, (void*)header.SourceMACAddr.v, sizeof(*remote));

	// Return a simplified version of the EtherType field to the caller
    *type = MAC_UNKNOWN;
    if( (header.Type.v[1] == 0x08u) && 
    	((header.Type.v[0] == ETHER_IP) || (header.Type.v[0] == ETHER_ARP)) )
    {
    	*type = header.Type.v[0];
    }

    // Mark this packet as discardable
    WasDiscarded = FALSE;	
	return TRUE;
}


/******************************************************************************
 * Function:        void    MACPutHeader(MAC_ADDR *remote,
 *					                     BYTE type,
 *                   					 WORD dataLen)
 *
 * PreCondition:    MACIsTxReady() must return TRUE.
 *
 * Input:           *remote: Pointer to memory which contains the destination
 * 							 MAC address (6 bytes)
 *					type: The constant ETHER_ARP or ETHER_IP, defining which 
 *						  value to write into the Ethernet header's type field.
 *					dataLen: Length of the Ethernet data payload
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            Because of the dataLen parameter, it is probably 
 *					advantagous to call this function immediately before 
 *					transmitting a packet rather than initially when the 
 *					packet is first created.  The order in which the packet
 *					is constructed (header first or data first) is not 
 *					important.
 *****************************************************************************/
void    MACPutHeader(MAC_ADDR *remote,
                     BYTE type,
                     WORD dataLen)
{
#if MAC_TX_BUFFER_COUNT > 1
	// Set the write pointer to the beginning of the transmit buffer
	EWRPT = TxBuffers[CurrentTxBuffer].StartAddress.Val;

	// Calculate where to put the TXND pointer
    dataLen += (WORD)sizeof(ETHER_HEADER) + TxBuffers[CurrentTxBuffer].StartAddress.Val;
	TxBuffers[CurrentTxBuffer].EndAddress.Val = dataLen;
#else
	// Set the write pointer to the beginning of the transmit buffer
	EWRPT = TXSTART;

	// Calculate where to put the TXND pointer
    dataLen += (WORD)sizeof(ETHER_HEADER) + TXSTART;

	// Write the TXND pointer into the registers, given the dataLen given
	ETXND = dataLen;
#endif


	// Set the per-packet control byte and write the Ethernet destination 
	// address
	MACPut(0x00);	// Use default control configuration
    MACPutArray((BYTE*)remote, sizeof(*remote));

	// Write our MAC address in the Ethernet source field
	MACPutArray((BYTE*)&AppConfig.MyMACAddr, sizeof(AppConfig.MyMACAddr));

	// Write the appropriate Ethernet Type WORD for the protocol being used
    MACPut(0x08);
    MACPut((type == MAC_IP) ? ETHER_IP : ETHER_ARP);
}

/******************************************************************************
 * Function:        void MACFlush(void)
 *
 * PreCondition:    A packet has been created by calling MACPut() and 
 *					MACPutHeader().
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACFlush causes the current TX packet to be sent out on 
 *					the Ethernet medium.  The hardware MAC will take control
 *					and handle CRC generation, collision retransmission and 
 *					other details.
 *
 * Note:			After transmission completes (MACIsTxReady() returns TRUE), 
 *					the packet can be modified and transmitted again by calling 
 *					MACFlush() again.  Until MACPutHeader() or MACPut() is 
 *					called (in the TX data area), the data in the TX buffer 
 *					will not be corrupted.
 *****************************************************************************/
void MACFlush(void)
{
#if MAC_TX_BUFFER_COUNT > 1
	// Set the packet start and end address pointers
	ETXST = TxBuffers[CurrentTxBuffer].StartAddress.Val;
	ETXND = TxBuffers[CurrentTxBuffer].EndAddress.Val;
	LastTXedBuffer = CurrentTxBuffer;
	TxBuffers[CurrentTxBuffer].Flags.bTransmitted = TRUE;
#endif

	// Reset transmit logic if a TX Error has previously occured
	// This may be unnecessary.
	if(EIRbits.TXERIF)
	{
		EIRbits.TXERIF = 0;
		ECON1bits.TXRST = 1;
		ECON1bits.TXRST = 0;
	}

	// Start the transmission
	// After transmission completes (MACIsTxReady() returns TRUE), the packet 
	// can be modified and transmitted again by calling MACFlush() again.
	// Until MACPutHeader() is called, the data in the TX buffer will not be 
	// corrupted.
    ECON1bits.TXRTS = 1;
}


/******************************************************************************
 * Function:        void MACSetRxBuffer(WORD offset)
 *
 * PreCondition:    A packet has been obtained by calling MACGetHeader() and 
 *					getting a TRUE result.
 *
 * Input:           offset: WORD specifying how many bytes beyond the Ethernet 
 *							header's type field to relocate the SPI read and 
 *							write pointers.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        SPI read and write pointers are updated.  All calls to 
 *					MACGet(), MACPut(), MACGetArray(), and MACPutArray(), 
 *					and various other functions will use these new values.
 *
 * Note:			RXSTOP must be statically defined as being > RXSTART for 
 *					this function to work correctly.  In other words, do not 
 *					define an RX buffer which spans the 0x1FFF->0x0000 memory
 *					boundary.
 *****************************************************************************/
void MACSetRxBuffer(WORD offset)
{
	WORD_VAL ReadPT;

	// Determine the address of the beginning of the entire packet
	// and adjust the address to the desired location
	ReadPT.Val = CurrentPacketLocation.Val + sizeof(ENC_PREAMBLE) + offset;
	
	// Since the receive buffer is circular, adjust if a wraparound is needed
	if ( ReadPT.Val > RXSTOP )
	{
		ReadPT.Val -= RXSIZE;
	}
	
	// Set the RAM read and write pointers to the new calculated value
	ERDPT = ReadPT.Val;
	EWRPT = ReadPT.Val;
}


/******************************************************************************
 * Function:        void MACSetTxBuffer(BUFFER buffer, WORD offset)
 *
 * PreCondition:    None
 *
 * Input:           buffer: BYTE specifying which transmit buffer to seek 
 *							within.  If MAC_TX_BUFFER_COUNT <= 1, this 
 *							parameter is not used.
 *					offset: WORD specifying how many bytes beyond the Ethernet 
 *							header's type field to relocate the SPI read and 
 *							write pointers.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        SPI read and write pointers are updated.  All calls to 
 *					MACGet(), MACPut(), MACGetArray(), and MACPutArray(), 
 *					and various other functions will use these new values.
 *
 * Note:			None
 *****************************************************************************/
void MACSetTxBuffer(BUFFER buffer, WORD offset)
{
    CurrentTxBuffer = buffer;

	// Calculate the proper address.  Since the TX memory area is not circular,
	// no wrapparound checks are necessary. +1 adjustment is needed because of 
	// the per packet control byte which preceeds the packet in the TX memory 
	// area.
#if MAC_TX_BUFFER_COUNT > 1
	offset += TxBuffers[buffer].StartAddress.Val + 1 + sizeof(ETHER_HEADER);
#else
	offset += TXSTART + 1 + sizeof(ETHER_HEADER);
#endif

	// Set the RAM read and write pointers to the new calculated value
    ERDPT = offset;
	EWRPT = offset;
}


// MACCalcRxChecksum() and MACCalcTxChecksum() use the DMA module to calculate
// checksums.  These two functions have been tested.
/******************************************************************************
 * Function:        WORD MACCalcRxChecksum(WORD offset, WORD len)
 *
 * PreCondition:    None
 *
 * Input:           offset	- Number of bytes beyond the beginning of the 
 *							Ethernet data (first byte after the type field) 
 *							where the checksum should begin
 *					len		- Total number of bytes to include in the checksum
 *
 * Output:          16-bit checksum as defined by rfc 793.
 *
 * Side Effects:    None
 *
 * Overview:        This function performs a checksum calculation in the MAC
 *                  buffer itself using the hardware DMA module
 *
 * Note:            None
 *****************************************************************************/
WORD MACCalcRxChecksum(WORD offset, WORD len)
{
	WORD_VAL temp;

	// Add the offset requested by firmware plus the Ethernet header
	temp.Val = CurrentPacketLocation.Val + sizeof(ENC_PREAMBLE) + offset;
	if ( temp.Val > RXSTOP )		// Adjust value if a wrap is needed
	{
		temp.Val -= RXSIZE;
	}
	// Program the start address of the DMA

    EDMAST = temp.Val;

    // Set the DMA end address
	temp.Val += len-1;
	if ( temp.Val > RXSTOP )		// Adjust value if a wrap is needed
	{
		temp.Val -= RXSIZE;
	}

    EDMAND = temp.Val;
	
	// Calculate the checksum using the DMA device
    ECON1bits.CSUMEN = 1;
    ECON1bits.DMAST = 1;
    while(ECON1bits.DMAST);

	// Swap endianness and return
    temp.v[1] = EDMACSL;
    temp.v[0] = EDMACSH;

	return temp.Val;
}


/******************************************************************************
 * Function:        WORD MACCalcTxChecksum(WORD offset, WORD len)
 *
 * PreCondition:    None
 *
 * Input:           offset	- Number of bytes beyond the beginning of the 
 *							Ethernet data (first byte after the type field) 
 *							where the checksum should begin
 *					len		- Total number of bytes to include in the checksum
 *
 * Output:          16-bit checksum as defined by rfc 793.
 *
 * Side Effects:    None
 *
 * Overview:        This function performs a checksum calculation in the MAC
 *                  buffer itself using the hardware DMA module
 *
 * Note:            None
 *****************************************************************************/
WORD MACCalcTxChecksum(WORD offset, WORD len)
{
	WORD_VAL temp;

	// Program the start address of the DMA, after adjusting for the Ethernet 
	// header
#if MAC_TX_BUFFER_COUNT > 1
	temp.Val = TxBuffers[CurrentTxBuffer].StartAddress.Val + sizeof(ETHER_HEADER)
				+ offset + 1;	// +1 needed to account for per packet control byte
#else
	temp.Val = TXSTART + sizeof(ETHER_HEADER)
				+ offset + 1;	// +1 needed to account for per packet control byte
#endif

    EDMAST = temp.Val;
	
	// Program the end address of the DMA.
	temp.Val += len-1;
    EDMAND = temp.Val;
	
    // Calcualte the checksum using the DMA device
    ECON1bits.CSUMEN = 1;
    ECON1bits.DMAST = 1;
    while(ECON1bits.DMAST);

	// Swap endianness and return
    temp.v[1] = EDMACSL;
    temp.v[0] = EDMACSH;

	return temp.Val;
}


/******************************************************************************
 * Function:        WORD CalcIPBufferChecksum(WORD len)
 *
 * PreCondition:    Read buffer pointer set to starting of checksum data
 *
 * Input:           len: Total number of bytes to calculate the checksum over. 
 *						 The first byte included in the checksum is the byte 
 *						 pointed to by ERDPT, which is updated by calls to 
 *						 MACGet(), MACSetRxBuffer(), MACSetTxBuffer(), etc.
 *
 * Output:          16-bit checksum as defined by rfc 793.
 *
 * Side Effects:    None
 *
 * Overview:        This function performs a checksum calculation in the MAC
 *                  buffer itself.  The MAC has a hardware DMA module 
 *					which can calculate the checksum faster than software, so 
 *					this function replaces the CaclIPBufferChecksum() function 
 *					defined in the helpers.c file.  Through the use of 
 *					preprocessor defines, this replacement is automatic.
 *
 * Note:            This function works either in the RX buffer area or the TX
 *					buffer area.  No validation is done on the len parameter.
 *****************************************************************************/
WORD CalcIPBufferChecksum(WORD len)
{
	WORD_VAL temp;

	// Take care of special cases which the DMA cannot be used for
	if(len == 0u)
	{
		return 0xFFFF;
	}
	else if(len == 1u)
	{
		return ~(((WORD)MACGet())<<8);
	}
		

	// Set the DMA starting address to the RAM read pointer value
    temp.Val = ERDPT;
    EDMAST = temp.Val;
	
	// See if we are calculating a checksum within the RX buffer (where 
	// wrapping rules apply) or TX/unused area (where wrapping rules are 
	// not applied)
#if RXSTART == 0
	if(temp.Val <= RXSTOP)
#else
	if(temp.Val >= RXSTART && temp.Val <= RXSTOP)
#endif
	{
		// Calculate the DMA ending address given the starting address and len 
		// parameter.  The DMA will follow the receive buffer wrapping boundary.
		temp.Val += len-1;
		if(temp.Val > RXSTOP)
		{
			temp.Val -= RXSIZE;
		}
	}
	else
	{
		temp.Val += len-1;
	}	

	// Write the DMA end address
    EDMAND = temp.Val;
	
	// Begin the DMA checksum calculation and wait until it is finished
    ECON1bits.CSUMEN = 1;
    ECON1bits.DMAST = 1;
    while(ECON1bits.DMAST);

	// Return the resulting good stuff
	return EDMACS;
}



/******************************************************************************
 * Function:        void MACCopyRxToTx(WORD RxOffset, WORD TxOffset, WORD len)
 *
 * PreCondition:    None
 *
 * Input:           RxOffset: Offset in the RX buffer (0=first byte of 
 * 							  destination MAC address) to copy from.
 *					TxOffset: Offset in the TX buffer (0=first byte of
 *							  destination MAC address) to copy to.
 *					len:	  Number of bytes to copy
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        If the TX logic is transmitting a packet (ECON1.TXRTS is 
 *					set), the hardware will wait until it is finished.  Then, 
 *					the DMA module will copy the data from the receive buffer 
 *					to the transmit buffer.
 *
 * Note:            None
 *****************************************************************************/
// Remove this line if your application needs to use this 
// function.  This code has NOT been tested.
#if 0 
void MACCopyRxToTx(WORD RxOffset, WORD TxOffset, WORD len)
{
	WORD_VAL temp;

	temp.Val = CurrentPacketLocation.Val + RxOffset + sizeof(ENC_PREAMBLE);
	if ( temp.Val > RXSTOP )		// Adjust value if a wrap is needed
		temp.Val -= RXSIZE;

	EDMAST = temp.Val;

	temp.Val += len-1;
	if ( temp.Val > RXSTOP )		// Adjust value if a wrap is needed
		temp.Val -= RXSIZE;

	EDMAND = temp.Val;
	
	TxOffset += TXSTART+1;
	EDMADST = TxOffset;
	
	// Do the DMA Copy.  The DMA module will wait for TXRTS to become clear 
	// before starting the copy.
	ECON1bits.CSUMEN = 0;
	ECON1bits.DMAST = 1;
	while(ECON1bits.DMAST);
}
#endif


#if defined(MAC_FILTER_BROADCASTS)
// NOTE: This code has NOT been tested.  See StackTsk.h's explanation
// of MAC_FILTER_BROADCASTS.
/******************************************************************************
 * Function:        void MACSetPMFilter(BYTE *Pattern, 
 *										BYTE *PatternMask, 
 *										WORD PatternOffset)
 *
 * PreCondition:    None
 *
 * Input:           *Pattern: Pointer to an intial pattern to compare against
 *					*PatternMask: Pointer to an 8 byte pattern mask which 
 *								  defines which bytes of the pattern are 
 *								  important.  At least one bit must be set.
 *					PatternOffset: Offset from the beginning of the Ethernet 
 *								   frame (1st byte of destination address), to
 *								   begin comparing with the given pattern.
 *
 * Output:          None
 *
 * Side Effects:    Contents of the TX buffer space are overwritten
 *
 * Overview:        MACSetPMFilter sets the hardware receive filters for: 
 *					CRC AND (Unicast OR Pattern Match).  As a result, only a 
 *					subset of the broadcast packets which are normally 
 *					received will be received.
 *
 * Note:            None
 *****************************************************************************/
void MACSetPMFilter(BYTE *Pattern, 
					BYTE *PatternMask, 
					WORD PatternOffset)
{
	WORD_VAL i;
	BYTE *MaskPtr;
	BYTE *PMRegister;
	BYTE UnmaskedPatternLen;
	
	// Set the RAM write pointer and DMA startting address to the beginning of 
	// the transmit buffer
	EWRPT = TXSTART;
	EDMAST = TXSTART;

	// Fill the transmit buffer with the pattern to match against.  Only the 
	// bytes which have a mask bit of 1 are written into the buffer and will
	// subsequently be used for checksum computation.  
	MaskPtr = PatternMask;
	for(i.Val = 0x0100; i.v[0] < 64; i.v[0]++)
	{
		if( *MaskPtr & i.v[1] )
		{
			MACPut(*Pattern);
			UnmaskedPatternLen++;
		}
		Pattern++;
		
		i.v[1] <<= 1;
		if( i.v[1] == 0u )
		{
			i.v[1] = 0x01;
			MaskPtr++;
		}
	}

	// Calculate and set the DMA end address
	i.Val = TXSTART + (WORD)UnmaskedPatternLen - 1;
	EDMAND = i.Val;

	// Calculate the checksum on the given pattern using the DMA module
	ECON1bits.CSUMEN = 1;
	ECON1bits.DMAST = 1;
	while(ECON1bits.DMAST);

	// Make certain that the PM filter isn't enabled while it is 
	// being reconfigured.
	ERXFCON = ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_BCEN;

	// Get the calculated DMA checksum and store it in the PM 
	// checksum registers
	EPMCS = EDMACS;

	// Set the Pattern Match offset and 8 byte mask
	EPMO = PatternOffset;
	for(i.Val = 0, PMRegister = &EPMM0; i.Val < 8; i.Val++)
	{
		*PMRegister++ = *PatternMask++;
	}

	// Begin using the new Pattern Match filter instead of the 
	// broadcast filter
	ERXFCON = ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_PMEN;
}//end MACSetPMFilter


/******************************************************************************
 * Function:        void MACDisablePMFilter(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACDisablePMFilter disables the Pattern Match receive 
 *					filter (if enabled) and returns to the default filter 
 *					configuration of: CRC AND (Unicast OR Broadcast).
 *
 * Note:            None
 *****************************************************************************/
void MACDisablePMFilter(void)
{
	ERXFCON = ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_BCEN;
	return;
}//end MACDisablePMFilter
#endif // end of MAC_FILTER_BROADCASTS specific code

/******************************************************************************
 * Function:        BYTE MACGet()
 *
 * PreCondition:    ERDPT must point to the place to read from.
 *
 * Input:           None
 *
 * Output:          Byte read from the Ethernet's buffer RAM
 *
 * Side Effects:    None
 *
 * Overview:        MACGet returns the byte pointed to by ERDPT and 
 *					increments ERDPT so MACGet() can be called again.  The 
 *					increment will follow the receive buffer wrapping boundary.
 *
 * Note:            For better performance, implement this function as a macro:
 *					#define MACGet()	(EDATA)
 *****************************************************************************/
BYTE MACGet()
{
    return EDATA;
}//end MACGet


/******************************************************************************
 * Function:        WORD MACGetArray(BYTE *val, WORD len)
 *
 * PreCondition:    ERDPT must point to the place to read from.
 *
 * Input:           *val: Pointer to storage location
 *					len:  Number of bytes to read from the data buffer.
 *
 * Output:          Byte(s) of data read from the data buffer.
 *
 * Side Effects:    None
 *
 * Overview:        Reads several sequential bytes from the data buffer 
 *					and places them into local memory.  ERDPT is incremented 
 *					after each byte, following the same rules as MACGet().
 *
 * Note:            None
 *****************************************************************************/
WORD MACGetArray(BYTE *val, WORD len)
{
    WORD i = len;
    
    while(i--)
    {
        *val++ = EDATA;
    };

	return len;
}//end MACGetArray


/******************************************************************************
 * Function:        void MACPut(BYTE val)
 *
 * PreCondition:    EWRPT must point to the location to begin writing.
 *
 * Input:           Byte to write into the Ethernet buffer memory
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        Writes to the EDATA register, which will indirectly 
*					increment EWRPTH:EWRPTL.
 *
 * Note:            For better performance, implement this function as a macro:
 *					#define MACPut(a)	EDATA = a
 *****************************************************************************/
void MACPut(BYTE val)
{
    EDATA = val;
}//end MACPut


/******************************************************************************
 * Function:        void MACPutArray(BYTE *val, WORD len)
 *
 * PreCondition:    EWRPT must point to the location to begin writing.
 *
 * Input:           *val: Pointer to source of bytes to copy.
 *					len:  Number of bytes to write to the data buffer.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACPutArray writes several sequential bytes to the 
 *					Ethernet buffer RAM.  It performs faster than multiple MACPut()
 *					calls.  EWRPT is incremented by len.
 *
 * Note:            None
 *****************************************************************************/
void MACPutArray(BYTE *val, WORD len)
{
    while(len--)
        EDATA = *val++;
}//end MACPutArray


/******************************************************************************
 * Function:        ReadPHYReg
 *
 * PreCondition:    Ethernet module must be enabled (ECON1.ETHEN = 1).
 *
 * Input:           Address of the PHY register to read from.
 *
 * Output:          16 bits of data read from the PHY register.
 *
 * Side Effects:    None
 *
 * Overview:        ReadPHYReg performs an MII read operation.  While in 
 *					progress, it simply polls the MII BUSY bit wasting time 
 *					(10.24us).
 *
 * Note:            None
 *****************************************************************************/
PHYREG ReadPHYReg(BYTE Register)
{
	PHYREG Result;

	// Set the right address and start the register read operation
    MIREGADR = Register; Nop();
    MICMD = MICMD_MIIRD; Nop();

	// Loop to wait until the PHY register has been read through the MII
	// This requires 10.24us
    while(MISTATbits.BUSY);

	// Stop reading
    MICMD = 0x00; Nop();
	
	// Obtain results and return
    Result.VAL.v[0] = MIRDL;
    Nop();
    Result.VAL.v[1] = MIRDH;

	return Result;
}//end ReadPHYReg


/******************************************************************************
 * Function:        WritePHYReg
 *
 * PreCondition:    Ethernet module must be enabled (ECON1.ETHEN = 1).
 *
 * Input:           Address of the PHY register to write to.
 *					16 bits of data to write to PHY register.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        WritePHYReg performs an MII write operation.  While in 
 *					progress, it simply polls the MII BUSY bit wasting time 
 *					(10.24us).
 *
 * Note:            None
 *****************************************************************************/
void WritePHYReg(BYTE Register, WORD Data)
{
	// Write the register address
	MIREGADR = Register; Nop();

	// Write the data
	// Order is important: write low byte first, high byte last
    MIWRL = ((WORD_VAL*)&Data)->v[0]; Nop();
    MIWRH = ((WORD_VAL*)&Data)->v[1]; Nop();

	// Wait until the PHY register has been written
	// This operation requires 10.24us
    while(MISTATbits.BUSY);
}//end WritePHYReg


/******************************************************************************
 * Function:        void MACSetDuplex(DUPLEX DuplexState) 
 *
 * PreCondition:    None
 *
 * Input:           Member of DUPLEX enum:
 *						FULL: Set full duplex mode
 *						HALF: Set half duplex mode
 *
 * Output:          None
 *
 * Side Effects:    RX logic is enabled (RX_EN set), even if it wasn't set 
 *                  prior to calling this function.
 *
 * Overview:        Disables RX, TX logic, sets MAC up for full duplex 
 *					operation, sets PHY up for full duplex operation, and 
 *					reenables RX logic.  The back-to-back inter-packet gap 
 *					register (MACBBIPG) is updated to maintain a 9.6us gap.
 *
 * Note:            If a packet is being transmitted or received while this 
 *					function is called, it will be aborted.
 *****************************************************************************/
void MACSetDuplex(DUPLEX DuplexState)
{
	PHYREG PhyReg;
	BYTE Temp;
	
	// Disable receive logic and abort any packets currently being transmitted
    ECON1bits.RXEN = 0;
    ECON1bits.TXRTS = 0;
	
	// Set the PHY to the proper duplex mode
	PhyReg = ReadPHYReg(PHCON1);
	PhyReg.PHCON1bits.PDPXMD = DuplexState;
	WritePHYReg(PHCON1, PhyReg.Val);

	// Set the MAC to the proper duplex mode (without using a read-modify-write 
	// type of instruction)
    Temp = MACON3;
    Temp &= ~MACON3_FULDPX;
    if(DuplexState)
    {
        Temp |= (MACON3_FULDPX);
    }
    MACON3 = Temp;
    Nop();
        
        

	// Set the back-to-back inter-packet gap time to IEEE specified 
	// requirements.  The meaning of the MABBIPG value changes with the duplex
	// state, so it must be updated in this function.
	// In full duplex, 0x15 represents 9.6us; 0x12 is 9.6us in half duplex
	MABBIPG = DuplexState ? 0x15 : 0x12;
	
	// Reenable receive logic
    ECON1bits.RXEN = 1;

}//end MACSetDuplex


/******************************************************************************
 * Function:        void MACPowerDown(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACPowerDown disables the Ethernet module.
 *					All MAC and PHY registers should not be accessed.
 *
 * Note:            Normally, this function would be called before putting the 
 *					PIC to sleep.  If a packet is being transmitted while this 
 *					function is called, this function will block until it is 
 *					it complete. If anything is being received, it will be 
 *					completed.
 *					
 *					The Ethernet module will continue to draw significant 
 *					power in sleep mode if this function is not called first.
 *****************************************************************************/
void MACPowerDown(void)
{
	// Disable packet reception
	ECON1bits.RXEN = 0;

	// Make sure any last packet which was in-progress when RXEN was cleared 
	// is completed
	while(ESTATbits.RXBUSY);

	// If a packet is being transmitted, wait for it to finish
	while(ECON1bits.TXRTS);
	
	// Disable the Ethernet module
	ECON2bits.ETHEN = 0;
}//end MACPowerDown

/******************************************************************************
 * Function:        void MACPowerUp(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        MACPowerUp returns the Ethernet module back to normal operation
 *					after a previous call to MACPowerDown().  Calling this 
 *					function when already powered up will have no effect.
 *
 * Note:            If a link partner is present, it will take 10s of 
 *					milliseconds before a new link will be established after
 *					waking up.  While not linked, packets which are 
 *					transmitted will most likely be lost.  MACIsLinked() can 
 *					be called to determine if a link is established.
 *****************************************************************************/
void MACPowerUp(void)
{	
	// Power up the Ethernet module
	ECON2bits.ETHEN = 1;

    // Wait at least 1ms for the PHY to stabilize
    Delay10us(100);
	
	// Enable packet reception
	ECON1bits.RXEN = 1;
}//end MACPowerUp
