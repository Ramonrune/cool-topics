/*********************************************************************
 *
 *               Microchip File System Implementaion on PIC18
 *
 *********************************************************************
 * FileName:        MPFS.c
 * Dependencies:    StackTsk.h
 *                  MPFS.h
 * Processor:       PIC18
 * Complier:        MCC18 v1.00.50 or higher
 *                  HITECH PICC-18 V8.10PL1 or higher
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
 * Nilesh Rajbharti     8/14/01     Original (Rev. 1.0)
 * Nilesh Rajbharti     2/9/02      Cleanup
 * Nilesh Rajbharti     5/22/02     Rev 2.0 (See version.log for detail)
 * Howard Schlunder     3/31/05		Changed MPFS_ENTRY and mpfs_Flags for C30
********************************************************************/
#define THIS_IS_MPFS

#include <p24fj128ga010.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "MPFS.h"

char *strupr(unsigned char *string);

// This file system supports short file names i.e. 8 + 3.
#define MAX_FILE_NAME_LEN   (12u)

#define MPFS_DATA          (0x00u)
#define MPFS_DELETED       (0x01u)
#define MPFS_DLE           (0x03u)
#define MPFS_ETX           (0x04u)

/*
 * MPFS Structure:
 *
 * MPFS_Start:
 *      <MPFS_DATA><Address1><FileName1>
 *      <MPFS_DATA><Address2><FileName2>
 *      ...
 *      <MPFS_ETX><Addressn><FileNamen>
 * Address1:
 *      <Data1>[<Data2>...<Datan>]<MPFS_ETX><MPFS_INVALID>
 *      ...
 *
 * Note: If File data contains either MPFS_DLE or MPFS_ETX
 *       extra MPFS_DLE is stuffed before that byte.
 */
typedef struct  _MPFS_ENTRY
{
    BYTE Flag;
    MPFS Address;
    BYTE Name[MAX_FILE_NAME_LEN];
	unsigned char page;
} MPFS_ENTRY;

static union
{
    struct
    {
        unsigned char bNotAvailable : 1;
    } bits;
    BYTE Val;
} mpfsFlags;

BYTE mpfsOpenCount;


	// An address where MPFS data starts in program memory.
    extern MPFS_ENTRY MPFS_Start[];


MPFS _currentHandle;
MPFS _currentFile;
BYTE _currentCount;

extern const unsigned char MPFS_0000[] __attribute__((space(psv)));
extern const unsigned char MPFS_0001[] __attribute__((space(psv)));
extern const unsigned char MPFS_0002[] __attribute__((space(psv)));
extern const unsigned char MPFS_0003[] __attribute__((space(psv)));
extern const unsigned char MPFS_0004[] __attribute__((space(psv)));
extern const unsigned char MPFS_0005[] __attribute__((space(psv)));
extern const unsigned char MPFS_0006[] __attribute__((space(psv)));
extern const unsigned char MPFS_0007[] __attribute__((space(psv)));
extern const unsigned char MPFS_0008[] __attribute__((space(psv)));
extern const unsigned char MPFS_0009[] __attribute__((space(psv)));
extern const unsigned char MPFS_0010[] __attribute__((space(psv)));
extern const unsigned char MPFS_0011[] __attribute__((space(psv)));
extern const unsigned char MPFS_0012[] __attribute__((space(psv)));
extern const unsigned char MPFS_0013[] __attribute__((space(psv)));
extern const unsigned char MPFS_0014[] __attribute__((space(psv)));
extern const unsigned char MPFS_0015[] __attribute__((space(psv)));
extern const unsigned char MPFS_0016[] __attribute__((space(psv)));
extern const unsigned char MPFS_0017[] __attribute__((space(psv)));
extern const unsigned char MPFS_0018[] __attribute__((space(psv)));
extern const unsigned char MPFS_0019[] __attribute__((space(psv)));
extern const unsigned char MPFS_0020[] __attribute__((space(psv)));
extern const unsigned char MPFS_0021[] __attribute__((space(psv)));
extern const unsigned char MPFS_0022[] __attribute__((space(psv)));
extern const unsigned char MPFS_0023[] __attribute__((space(psv)));
extern const unsigned char MPFS_0024[] __attribute__((space(psv)));
extern const unsigned char MPFS_0025[] __attribute__((space(psv)));
extern const unsigned char MPFS_0026[] __attribute__((space(psv)));
extern const unsigned char MPFS_0027[] __attribute__((space(psv)));
extern const unsigned char MPFS_0028[] __attribute__((space(psv)));
extern const unsigned char MPFS_0029[] __attribute__((space(psv)));
extern const unsigned char MPFS_0030[] __attribute__((space(psv)));

/*********************************************************************
 * Function:        BOOL MPFSInit(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          TRUE, if MPFS Storage access is initialized and
 *                          MPFS is ready to be used.
 *                  FALSE otherwise
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
BOOL MPFSInit(void)
{
    mpfsOpenCount = 0;
    mpfsFlags.Val = 0;

	MPFS_Start[0].page = __builtin_psvpage(MPFS_0000);
	MPFS_Start[1].page = __builtin_psvpage(MPFS_0001);
	MPFS_Start[2].page = __builtin_psvpage(MPFS_0002);
	MPFS_Start[3].page = __builtin_psvpage(MPFS_0003);
	MPFS_Start[4].page = __builtin_psvpage(MPFS_0004);
	MPFS_Start[5].page = __builtin_psvpage(MPFS_0005);
	MPFS_Start[6].page = __builtin_psvpage(MPFS_0006);
	MPFS_Start[7].page = __builtin_psvpage(MPFS_0007);
	MPFS_Start[8].page = __builtin_psvpage(MPFS_0008);
	MPFS_Start[9].page = __builtin_psvpage(MPFS_0009);
	MPFS_Start[10].page = __builtin_psvpage(MPFS_0010);
	MPFS_Start[11].page = __builtin_psvpage(MPFS_0011);
	MPFS_Start[12].page = __builtin_psvpage(MPFS_0012);
	MPFS_Start[13].page = __builtin_psvpage(MPFS_0013);
	MPFS_Start[14].page = __builtin_psvpage(MPFS_0014);
	MPFS_Start[15].page = __builtin_psvpage(MPFS_0015);
	MPFS_Start[16].page = __builtin_psvpage(MPFS_0016);
	MPFS_Start[17].page = __builtin_psvpage(MPFS_0017);
	MPFS_Start[18].page = __builtin_psvpage(MPFS_0018);
	MPFS_Start[19].page = __builtin_psvpage(MPFS_0019);
	MPFS_Start[20].page = __builtin_psvpage(MPFS_0020);
	MPFS_Start[21].page = __builtin_psvpage(MPFS_0021);
	MPFS_Start[22].page = __builtin_psvpage(MPFS_0022);
	MPFS_Start[23].page = __builtin_psvpage(MPFS_0023);
	MPFS_Start[24].page = __builtin_psvpage(MPFS_0024);
	MPFS_Start[25].page = __builtin_psvpage(MPFS_0025);
	MPFS_Start[26].page = __builtin_psvpage(MPFS_0026);
	MPFS_Start[27].page = __builtin_psvpage(MPFS_0027);
	MPFS_Start[28].page = __builtin_psvpage(MPFS_0028);
	MPFS_Start[29].page = __builtin_psvpage(MPFS_0029);
	MPFS_Start[30].page = __builtin_psvpage(MPFS_0030);

    return TRUE;
}


/*********************************************************************
 * Function:        MPFS MPFSOpen(BYTE* file)
 *
 * PreCondition:    None
 *
 * Input:           file        - NULL terminated file name.
 *
 * Output:          A handle if file is found
 *                  MPFS_INVALID if file is not found.
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
MPFS MPFSOpen(BYTE* file)
{
    MPFS_ENTRY entry;
    MPFS FAT;
    BYTE fileNameLen;

    if( mpfsFlags.bits.bNotAvailable )
        return MPFS_NOT_AVAILABLE;

    FAT = (MPFS)&MPFS_Start;

    // If string is empty, do not attempt to find it in FAT.
    if ( *file == '\0' )
        return MPFS_INVALID;

    file = (BYTE*)strupr((char*)file);

    while(1)
    {
        // Bring current FAT entry into RAM.
//        memcpypgm2ram(&entry, (const void*)FAT, sizeof(entry));
		memcpy(&entry,(const void*)FAT,sizeof(entry));

        // Make sure that it is a valid entry.
        if (entry.Flag == MPFS_DATA)
        {
            // Does the file name match ?
            fileNameLen = strlen((char*)file);
            if ( fileNameLen > MAX_FILE_NAME_LEN )
                fileNameLen = MAX_FILE_NAME_LEN;

            if( memcmp((void*)file, (void*)entry.Name, fileNameLen) == 0 )
            {
                _currentFile = (MPFS)entry.Address;
				PSVPAG = entry.page;
                mpfsOpenCount++;
                return entry.Address;
            }

            // File does not match.  Try next entry...
            FAT += sizeof(entry);
        }
        else if ( entry.Flag == MPFS_ETX )
        {
            if ( entry.Address != (MPFS)MPFS_INVALID )
                FAT = (MPFS)entry.Address;
            else
                break;
        }
	    else
	        return (MPFS)MPFS_INVALID;
    }
    return (MPFS)MPFS_INVALID;
}


/*********************************************************************
 * Function:        void MPFSClose(void)
 *
 * PreCondition:    None
 *
 * Input:           handle      - File handle to be closed
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
void MPFSClose(void)
{
    _currentCount = 0;
    mpfsFlags.bits.bNotAvailable = FALSE;
    if ( mpfsOpenCount )
        mpfsOpenCount--;
}


/*********************************************************************
 * Function:        BYTE MPFSGet(void)
 *
 * PreCondition:    MPFSOpen() != MPFS_INVALID &&
 *                  MPFSGetBegin() == TRUE
 *
 * Input:           None
 *
 * Output:          Data byte from current address.
 *
 * Side Effects:    None
 *
 * Overview:        Reads a byte from current address.
 *
 * Note:            Caller must call MPFSIsEOF() to check for end of
 *                  file condition
 ********************************************************************/
BYTE MPFSGet(void)
{
    BYTE t;
    
    t = (BYTE)*_currentHandle;
    _currentHandle++;

    if ( t == MPFS_DLE )
    {
        t = (BYTE)*_currentHandle;
        _currentHandle++;
    }
    else if ( t == MPFS_ETX )
    {
        _currentHandle = MPFS_INVALID;
    }

    return t;

}


char *strupr(unsigned char *string)
{
	unsigned char *p=string;

	while ((*p = toupper(*p) ) != '\0') {
		++p;
	}
	return(string);
}
