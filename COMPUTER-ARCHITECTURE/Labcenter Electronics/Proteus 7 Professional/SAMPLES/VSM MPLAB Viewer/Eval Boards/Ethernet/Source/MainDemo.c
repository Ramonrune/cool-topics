/*********************************************************************
 *
 *       Example Web Server Application using Microchip TCP/IP Stack
 *
 *********************************************************************
 * FileName:        MainDemo.c
 * Dependencies:    string.H
 *                  StackTsk.h
 *                  Tick.h
 *                  http.h
 *                  MPFS.h
 *				   	mac.h
 * Processor:       PIC18, PIC24F, PIC24H, dsPIC30F, dsPIC33F
 * Complier:        Microchip C18 v3.02 or higher
 *					Microchip C30 v2.01 or higher
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
 * Author              Date         Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Nilesh Rajbharti		4/19/01		Original (Rev. 1.0)
 * Nilesh Rajbharti		2/09/02		Cleanup
 * Nilesh Rajbharti		5/22/02		Rev 2.0 (See version.log for detail)
 * Nilesh Rajbharti		7/9/02		Rev 2.1 (See version.log for detail)
 * Nilesh Rajbharti		4/7/03		Rev 2.11.01 (See version log for detail)
 * Howard Schlunder		10/1/04		Beta Rev 0.9 (See version log for detail)
 * Howard Schlunder		10/8/04		Beta Rev 0.9.1 Announce support added
 * Howard Schlunder		11/29/04	Beta Rev 0.9.2 (See version log for detail)
 * Howard Schlunder		2/10/05		Rev 2.5.0
 * Howard Schlunder		1/5/06		Rev 3.00
 * Howard Schlunder		1/18/06		Rev 3.01 ENC28J60 fixes to TCP, 
 *									UDP and ENC28J60 files
 * Howard Schlunder		3/01/06		Rev. 3.16 including 16-bit micro support
 * Howard Schlunder		4/12/06		Rev. 3.50 added LCD for Explorer 16
 * Howard Schlunder		6/19/06		Rev. 3.60 finished dsPIC30F support, added PICDEM.net 2 support
 * Howard Schlunder		8/02/06		Rev. 3.75 added beta DNS, NBNS, and HTTP client (GenericTCPClient.c) services
 ********************************************************************/

/*
 * Following define uniquely deines this file as main
 * entry/application In whole project, there should only be one such
 * definition and application file must define AppConfig variable as
 * described below.
 */
#define THIS_IS_STACK_APPLICATION

#define VERSION 		"v3.75"		// TCP/IP stack version
#define BAUD_RATE       (19200)     // bps


// These headers must be included for required defs.
#include <string.h>
#include "..\Include\Compiler.h"
#include "..\Include\StackTsk.h"
#include "..\Include\Tick.h"
#include "..\Include\MAC.h"
#include "..\Include\Helpers.h"
#include "..\Include\Delay.h"
#include "..\Include\UART.h"
#include "..\Include\MPFS.h"
#include "..\Include\LCDBlocking.h"
#include "..\Include\GenericTCPClient.h"

#if defined(STACK_USE_DHCP)
#include "..\Include\DHCP.h"
#endif

#if defined(STACK_USE_HTTP_SERVER)
#include "..\Include\HTTP.h"
#endif

#if defined(STACK_USE_FTP_SERVER) && defined(MPFS_USE_EEPROM)
#include "..\Include\FTP.h"
#endif

#if defined(STACK_USE_ANNOUNCE)
#include "..\Include\Announce.h"
#endif

#if defined(MPFS_USE_EEPROM)
#include "..\Include\XEEPROM.h"
#endif

#if defined(STACK_USE_NBNS)
#include "..\Include\NBNS.h"
#endif

#if defined(STACK_USE_DNS)
#include "..\Include\DNS.h"
#endif

#if defined(STACK_USE_GENERIC_TCP_EXAMPLE)
#include "..\Include\GenericTCPClient.h"
#endif


// The SPBRG_VAL is used for PIC18s only.  See InitializeBoard() for 
// PIC24, dsPIC initialization of the baud rate generator.
#define USART_USE_BRGH_LOW
#if defined(USART_USE_BRGH_LOW)
    #define SPBRG_VAL   ( ((INSTR_FREQ/BAUD_RATE)/16) - 1)
#else
    #define SPBRG_VAL   ( ((INSTR_FREQ/BAUD_RATE)/4) - 1)
#endif

#if (SPBRG_VAL > 255) && !defined(__C30__)
    #error "Calculated SPBRG value is out of range for currnet CLOCK_FREQ."
#endif


// This is used by other stack elements.
// Main application must define this and initialize it with proper values.
APP_CONFIG AppConfig = 
	{
		{MY_DEFAULT_IP_ADDR_BYTE1, MY_DEFAULT_IP_ADDR_BYTE2, MY_DEFAULT_IP_ADDR_BYTE3, MY_DEFAULT_IP_ADDR_BYTE4},
		{MY_DEFAULT_MAC_BYTE1, MY_DEFAULT_MAC_BYTE2, MY_DEFAULT_MAC_BYTE3, MY_DEFAULT_MAC_BYTE4, MY_DEFAULT_MAC_BYTE5, MY_DEFAULT_MAC_BYTE6},
		{MY_DEFAULT_MASK_BYTE1, MY_DEFAULT_MASK_BYTE2, MY_DEFAULT_MASK_BYTE3, MY_DEFAULT_MASK_BYTE4},
		{MY_DEFAULT_GATE_BYTE1, MY_DEFAULT_GATE_BYTE2, MY_DEFAULT_GATE_BYTE3, MY_DEFAULT_GATE_BYTE4},
		{MY_DEFAULT_DNS_BYTE1, MY_DEFAULT_DNS_BYTE2, MY_DEFAULT_DNS_BYTE3, MY_DEFAULT_DNS_BYTE4},
		{0b00000001},	// Flags, enable DHCP
	};

BYTE myDHCPBindCount = 0;
#if defined(STACK_USE_DHCP)
    extern BYTE DHCPBindCount;
#else
	#define DHCPBindCount	(0xFF)
#endif

/*
 * Set configuration fuses
 */
#if defined(__18CXX)
	#if defined(__18F8722)
		// PICDEM HPC Explorer board
		#pragma config OSC=HSPLL, FCMEN=OFF, IESO=OFF, PWRT=OFF, WDT=OFF, LVP=OFF
	#elif defined(__18F87J10) || defined(__18F86J15) || defined(__18F86J10) || defined(__18F85J15) || defined(__18F85J10) || defined(__18F67J10) || defined(__18F66J15) || defined(__18F66J10) || defined(__18F65J15) || defined(__18F65J10)
		// PICDEM HPC Explorer board
		#pragma config XINST=OFF, WDTEN=OFF, FOSC2=ON, FOSC=HSPLL
	#elif defined(__18F97J60) || defined(__18F96J65) || defined(__18F96J60) || defined(__18F87J60) || defined(__18F86J65) || defined(__18F86J60) || defined(__18F67J60) || defined(__18F66J65) || defined(__18F66J60) 
		// PICDEM.net 2 board
		#pragma config XINST=OFF, WDT=OFF, FOSC2=ON, FOSC=HSPLL, ETHLED=ON
	#elif defined(HI_TECH_C)	
		// PICDEM HPC Explorer board
		__CONFIG(1, HSPLL);
		__CONFIG(2, WDTDIS);
		__CONFIG(3, MCLREN);
		__CONFIG(4, XINSTDIS & LVPDIS);
	#elif defined(__18F4620)	
		// PICDEM.net board
//		#pragma config OSC=HS, WDT=OFF, MCLRE=ON, PBADEN=OFF, LVP=OFF, XINST=OFF
	#elif defined(__18F452)	
		// PICDEM.net board
		#pragma config OSC=HS, WDT=OFF, LVP=OFF
	#endif
#elif defined(__PIC24F__)
	// Explorer 16 board
	_CONFIG2(FNOSC_PRIPLL & POSCMOD_XT)		// Primary XT OSC with 4x PLL
	_CONFIG1(JTAGEN_OFF & FWDTEN_OFF)		// JTAG off, watchdog timer off
#elif defined(__dsPIC33F__) || defined(__PIC24H__)
	// Explorer 16 board
	_FOSCSEL(FNOSC_PRIPLL)			// PLL enabled
	_FOSC(OSCIOFNC_OFF & POSCMD_XT)	// XT Osc
	_FWDT(FWDTEN_OFF)				// Disable Watchdog timer
	// JTAG should be disabled as well
#elif defined(__dsPIC30F__)
	// dsPICDEM 1.1 board
	_FOSC(XT_PLL16)					// XT Osc + 16X PLL
	_FWDT(WDT_OFF)					// Disable Watchdog timer
	_FBORPOR(MCLR_EN & PBOR_OFF & PWRT_OFF)
#endif


// Private helper functions.
// These may or may not be present in all applications.
static void InitAppConfig(void);
static void InitializeBoard(void);
static void ProcessIO(void);

BOOL StringToIPAddress(char *str, IP_ADDR *buffer);
static void DisplayIPValue(IP_ADDR *IPVal);
static void SetConfig(void);
static void FormatNetBIOSName(BYTE Name[16]);

#if defined(MPFS_USE_EEPROM)
static BOOL DownloadMPFS(void);
static void SaveAppConfig(void);
#else
	#define SaveAppConfig()
#endif

// NOTE: Several PICs, including the PIC18F4620 revision A3 have a RETFIE FAST/MOVFF bug
// The interruptlow keyword is used to work around the bug when using C18
#if defined(HI_TECH_C)
void interrupt HighISR(void)
#else
#pragma interruptlow HighISR
void HighISR(void)
#endif
{
#ifdef __18CXX
    TickUpdate();
#endif

#if defined(STACK_USE_SLIP)
    MACISR();
#endif
}

#if defined(__18CXX) && !defined(HI_TECH_C)
#pragma code highVector=0x08
void HighVector (void)
{
    _asm goto HighISR _endasm
}
#pragma code // Return to default code section
#endif



ROM char NewIP[] = "New IP Address: ";
ROM char CRLF[] = "\r\n";


// Main application entry point.
#ifdef __C30__ 
int main(void)
#else
void main(void)
#endif
{
    static TICK t = 0;
    
    // Initialize any application specific hardware.
    InitializeBoard();

#ifdef USE_LCD
	// Initialize and display the stack version on the LCD
	LCDInit();
	DelayMs(100);
	strcpypgm2ram(LCDText, "TCPStack " VERSION "  "
					       "                ");
	LCDUpdate();
#endif

    // Initialize all stack related components.
    // Following steps must be performed for all applications using
    // PICmicro TCP/IP Stack.
    TickInit();

    // Following steps must be performed for all applications using
    // PICmicro TCP/IP Stack.
    MPFSInit();

	// Load the default NetBIOS Host Name
	memcpypgm2ram(AppConfig.NetBIOSName, (ROM void*)MY_DEFAULT_HOST_NAME, 16);
	FormatNetBIOSName(AppConfig.NetBIOSName);

    // Initialize Stack and application related NV variables.
    InitAppConfig();

    // Initiates board setup process if button is depressed 
	// on startup
    if(BUTTON0_IO == 0)
    {
        SetConfig();
    }

    StackInit();

#if defined(STACK_USE_HTTP_SERVER)
    HTTPInit();
#endif

#if defined(STACK_USE_FTP_SERVER) && defined(MPFS_USE_EEPROM)
    FTPInit();
#endif


#if defined(STACK_USE_DHCP) || defined(STACK_USE_IP_GLEANING)
    if(!AppConfig.Flags.bIsDHCPEnabled)
    {
        // Force IP address display update.
        myDHCPBindCount = 1;
#if defined(STACK_USE_DHCP)
        DHCPDisable();
#endif
    }
#endif


    // Once all items are initialized, go into infinite loop and let
    // stack items execute their tasks.
    // If application needs to perform its own task, it should be
    // done at the end of while loop.
    // Note that this is a "co-operative mult-tasking" mechanism
    // where every task performs its tasks (whether all in one shot
    // or part of it) and returns so that other tasks can do their
    // job.
    // If a task needs very long time to do its job, it must broken
    // down into smaller pieces so that other tasks can have CPU time.
    while(1)
    {
        // Blink SYSTEM LED every second.
        if ( TickGetDiff(TickGet(), t) >= TICK_SECOND/2 )
        {
            t = TickGet();
            LED0_IO ^= 1;
        }

        // This task performs normal stack task including checking
        // for incoming packet, type of packet and calling
        // appropriate stack entity to process it.
        StackTask();

#if defined(STACK_USE_HTTP_SERVER)
        // This is a TCP application.  It listens to TCP port 80
        // with one or more sockets and responds to remote requests.
        HTTPServer();
#endif

#if defined(STACK_USE_FTP_SERVER) && defined(MPFS_USE_EEPROM)
        FTPServer();
#endif

#if defined(STACK_USE_ANNOUNCE)
		DiscoveryTask();
#endif

#if defined(STACK_USE_NBNS)
		NBNSTask();
#endif

#if defined(STACK_USE_GENERIC_TCP_EXAMPLE)
		GenericTCPClient();
#endif

        // In future, as new TCP/IP applications are written, it
        // will be added here as new tasks.

        // Add your application speicifc tasks here.
        ProcessIO();


        // For DHCP information, display how many times we have renewed the IP
        // configuration since last reset.
        if ( DHCPBindCount != myDHCPBindCount )
        {
            myDHCPBindCount = DHCPBindCount;

			putrsUART(NewIP);
            DisplayIPValue(&AppConfig.MyIPAddr);	// Print to UART
			putrsUART(CRLF);
#if defined(STACK_USE_ANNOUNCE)
			AnnounceIP();
#endif
        }

    }
}


static void DisplayIPValue(IP_ADDR *IPVal)
{
//	printf("%u.%u.%u.%u", IPVal->v[0], IPVal->v[1], IPVal->v[2], IPVal->v[3]);
    BYTE IPDigit[5];
#ifdef USE_LCD
	BYTE i;
	BYTE LCDPos=16;
#endif

    itoa(IPVal->v[0], IPDigit);
	putsUART(IPDigit);
#ifdef USE_LCD
	for(i=0; i < strlen(IPDigit); i++)
	{
		LCDText[LCDPos++] = IPDigit[i];
	}
	LCDText[LCDPos++] = '.';
#endif
	while(BusyUART());
	WriteUART('.');

    itoa(IPVal->v[1], IPDigit);
	putsUART(IPDigit);
#ifdef USE_LCD
	for(i=0; i < strlen(IPDigit); i++)
	{
		LCDText[LCDPos++] = IPDigit[i];
	}
	LCDText[LCDPos++] = '.';
#endif
	while(BusyUART());
	WriteUART('.');

    itoa(IPVal->v[2], IPDigit);
	putsUART(IPDigit);
#ifdef USE_LCD
	for(i=0; i < strlen(IPDigit); i++)
	{
		LCDText[LCDPos++] = IPDigit[i];
	}
	LCDText[LCDPos++] = '.';
#endif
	while(BusyUART());
	WriteUART('.');

    itoa(IPVal->v[3], IPDigit);
	putsUART(IPDigit);
#ifdef USE_LCD
	for(i=0; i < strlen(IPDigit); i++)
	{
		LCDText[LCDPos++] = IPDigit[i];
	}

	while(LCDPos < 32)
	{
		LCDText[LCDPos++] = ' ';
	}
	LCDUpdate();
#endif
	while(BusyUART());
}


static char AN0String[8];
//static char AN1String[8] = "";

static void ProcessIO(void)
{
#ifdef __C30__
//  Note: floats and sprintf uses a lot of program memory/CPU cycles, so it's commented out
//	float Temperature;
//
//    // Convert temperature result into ASCII string
//	Temperature = ((float)(ADC1BUF0)*(3.3/1024.)-0.500)*100.;
//	sprintf(AN1String, "%3.1f°C", Temperature);

    // Convert potentiometer result into ASCII string
    itoa((unsigned)ADC1BUF0, AN0String);
#else
    // AN0 should already be set up as an analog input
    ADCON0bits.GO = 1;

    // Wait until A/D conversion is done
    while(ADCON0bits.GO);

	// AD converter errata work around (ex: PIC18F87J10 A2)
	#if !defined(__18F452)
	PRODL = ADCON2;
	ADCON2bits.ADCS0 = 1;
	ADCON2bits.ADCS1 = 1;
	ADCON2 = PRODL;
	#endif

    // Convert 10-bit value into ASCII string
    itoa(*((WORD*)(&ADRESL)), AN0String);
#endif
}

// CGI Command Codes
#define CGI_CMD_DIGOUT      (0)
#define CGI_CMD_LCDOUT      (1)
#define CGI_CMD_RECONFIG	(2)

// CGI Variable codes. - There could be 00h-FFh variables.
// NOTE: When specifying variables in your dynamic pages (.cgi),
//       use the hexadecimal numbering scheme and always zero pad it
//       to be exactly two characters.  Eg: "%04", "%2C"; not "%4" or "%02C"
#define VAR_LED0			(0x00)
#define VAR_LED1			(0x01)
#define VAR_LED2			(0x10)
#define VAR_LED3			(0x11)
#define VAR_LED4			(0x12)
#define VAR_LED5			(0x13)
#define VAR_LED6			(0x14)
#define VAR_LED7			(0x15)
#define VAR_ANAIN_AN0       (0x02)
#define VAR_ANAIN_AN1       (0x03)
#define VAR_DIGIN0       	(0x04)	// Button0 on Explorer16
#define VAR_DIGIN1       	(0x0D)	// Button1 on Explorer16
#define VAR_DIGIN2       	(0x0E)	// Button2 on Explorer16
#define VAR_DIGIN3       	(0x0F)	// Button3 on Explorer16
#define VAR_STACK_VERSION	(0x16)
#define VAR_STACK_DATE		(0x17)
#define VAR_STROUT_LCD      (0x05)
#define VAR_MAC_ADDRESS     (0x06)
#define VAR_SERIAL_NUMBER   (0x07)
#define VAR_IP_ADDRESS      (0x08)
#define VAR_SUBNET_MASK     (0x09)
#define VAR_GATEWAY_ADDRESS (0x0A)
#define VAR_DHCP	        (0x0B)	// Use this variable when the web page is updating us
#define VAR_DHCP_TRUE       (0x0B)	// Use this variable when we are generating the web page
#define VAR_DHCP_FALSE      (0x0C)	// Use this variable when we are generating the web page


// CGI Command codes (CGI_CMD_DIGOUT).
// Should be a one digit numerical value
#define CMD_LED1			(0x0)
#define CMD_LED2			(0x1)


/*********************************************************************
 * Function:        void HTTPExecCmd(BYTE** argv, BYTE argc)
 *
 * PreCondition:    None
 *
 * Input:           argv        - List of arguments
 *                  argc        - Argument count.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        This function is a "callback" from HTTPServer
 *                  task.  Whenever a remote node performs
 *                  interactive task on page that was served,
 *                  HTTPServer calls this functions with action
 *                  arguments info.
 *                  Main application should interpret this argument
 *                  and act accordingly.
 *
 *                  Following is the format of argv:
 *                  If HTTP action was : thank.htm?name=Joe&age=25
 *                      argv[0] => thank.htm
 *                      argv[1] => name
 *                      argv[2] => Joe
 *                      argv[3] => age
 *                      argv[4] => 25
 *
 *                  Use argv[0] as a command identifier and rests
 *                  of the items as command arguments.
 *
 * Note:            THIS IS AN EXAMPLE CALLBACK.
 ********************************************************************/
#if defined(STACK_USE_HTTP_SERVER)

ROM char COMMANDS_OK_PAGE[] = "INDEX.CGI";
ROM char CONFIG_UPDATE_PAGE[] = "CONFIG.CGI";
ROM char CMD_UNKNOWN_PAGE[] = "INDEX.CGI";

// Copy string with NULL termination.
#define COMMANDS_OK_PAGE_LEN  	(sizeof(COMMANDS_OK_PAGE))
#define CONFIG_UPDATE_PAGE_LEN  (sizeof(CONFIG_UPDATE_PAGE))
#define CMD_UNKNOWN_PAGE_LEN    (sizeof(CMD_UNKNOWN_PAGE))

void HTTPExecCmd(BYTE** argv, BYTE argc)
{
    BYTE command;
    BYTE var;
#ifdef ENABLE_REMOTE_CONFIG
    BYTE CurrentArg;
    WORD_VAL TmpWord;
#endif
    /*
     * Design your pages such that they contain command code
     * as a one character numerical value.
     * Being a one character numerical value greatly simplifies
     * the job.
     */
    command = argv[0][0] - '0';

    /*
     * Find out the cgi file name and interpret parameters
     * accordingly
     */
    switch(command)
    {
    case CGI_CMD_DIGOUT:	// ACTION=0
        /*
         * Identify the parameters.
         * Compare it in upper case format.
         */
        var = argv[1][0] - '0';

        switch(var)
        {
        case CMD_LED1:	// NAME=0
            // Toggle LED.
            LED1_IO ^= 1;
            break;

        case CMD_LED2:	// NAME=1
            // Toggle LED.
            LED2_IO ^= 1;
            break;
         }

         memcpypgm2ram((void*)argv[0], (ROM void*)COMMANDS_OK_PAGE, COMMANDS_OK_PAGE_LEN);
         break;
#if defined(USE_LCD)
    case CGI_CMD_LCDOUT:	// ACTION=1
		if(argc > 2)	// Text provided in argv[2]
		{
			// Write 32 received characters or less to LCDText
			if(strlen(argv[2]) < 32)
			{
				memset(LCDText, ' ', 32);
				strcpy(LCDText, argv[2]);
			}
			else
			{
				memcpy(LCDText, (void*)argv[2], 32);
			}

			// Write LCDText to the LCD
			LCDUpdate();
		}
		else			// No text provided
		{
			LCDErase();
		}
		memcpypgm2ram((void*)argv[0], (ROM void*)COMMANDS_OK_PAGE, COMMANDS_OK_PAGE_LEN);
        break;
#endif
#if ENABLE_REMOTE_CONFIG
// Possibly useful code for remotely reconfiguring the board through 
// HTTP
	case CGI_CMD_RECONFIG:	// ACTION=2
		// Loop through all variables that we've been given
		CurrentArg = 1;
		while(argc > CurrentArg)
		{
			// Get the variable identifier (HTML "name"), and 
			// increment to the variable's value
			TmpWord.byte.MSB = argv[CurrentArg][0];
			TmpWord.byte.LSB = argv[CurrentArg++][1];
	        var = hexatob(TmpWord);
	        
	        // Make sure the variable's value exists
	        if(CurrentArg >= argc)
	        	break;
	        
	        // Take action with this variable/value
	        switch(var)
	        {
	        case VAR_SERIAL_NUMBER:
	        	AppConfig.SerialNumber.Val = atoi(argv[CurrentArg]);
	        	AppConfig.MyMACAddr.v[4] = AppConfig.SerialNumber.byte.MSB;
	        	AppConfig.MyMACAddr.v[5] = AppConfig.SerialNumber.byte.LSB;
	            break;
	
	        case VAR_IP_ADDRESS:
	        case VAR_SUBNET_MASK:
	        case VAR_GATEWAY_ADDRESS:
	        	{
		        	DWORD TmpAddr;
		        	
		        	// Convert the returned value to the 4 octect 
		        	// binary representation
			        if(!StringToIPAddress(argv[CurrentArg], (IP_ADDR*)&TmpAddr))
			        	break;

					// Reconfigure the App to use the new values
			        if(var == VAR_IP_ADDRESS)
			        {
				        // Cause the IP address to be rebroadcast
				        // through Announce.c or the RS232 port since
				        // we now have a new IP address
				        if(TmpAddr != *(DWORD*)&AppConfig.MyIPAddr)
					        DHCPBindCount++;
					    
					    // Set the new address
			        	memcpy((void*)&AppConfig.MyIPAddr, (void*)&TmpAddr, sizeof(AppConfig.MyIPAddr));
			        }
			        else if(var == VAR_SUBNET_MASK)
			        	memcpy((void*)&AppConfig.MyMask, (void*)&TmpAddr, sizeof(AppConfig.MyMask));
			        else if(var == VAR_SUBNET_MASK)
			        	memcpy((void*)&AppConfig.MyGateway, (void*)&TmpAddr, sizeof(AppConfig.MyGateway));
		        }
	            break;
	
	        case VAR_DHCP:
	        	if(AppConfig.Flags.bIsDHCPEnabled)
	        	{
		        	if(!(argv[CurrentArg][0]-'0'))
		        	{
		        		AppConfig.Flags.bIsDHCPEnabled = FALSE;
		        	}
		        }
		        else
	        	{
		        	if(argv[CurrentArg][0]-'0')
		        	{
						AppConfig.MyIPAddr.Val = 0x00000000ul;
		        		AppConfig.Flags.bIsDHCPEnabled = TRUE;
				        AppConfig.Flags.bInConfigMode = TRUE;
			        	DHCPReset();
		        	}
		        }
	            break;
	    	}

			// Advance to the next variable (if present)
			CurrentArg++;	
        }
		
		// Save any changes to non-volatile memory
      	SaveAppConfig();


		// Return the same CONFIG.CGI file as a result.
        memcpypgm2ram((void*)argv[0],
             (ROM void*)CONFIG_UPDATE_PAGE, CONFIG_UPDATE_PAGE_LEN);
		break;
#endif

    default:
		memcpypgm2ram((void*)argv[0], (ROM void*)COMMANDS_OK_PAGE, COMMANDS_OK_PAGE_LEN);
        break;
    }

}
#endif


/*********************************************************************
 * Function:        WORD HTTPGetVar(BYTE var, WORD ref, BYTE* val)
 *
 * PreCondition:    None
 *
 * Input:           var         - Variable Identifier
 *                  ref         - Current callback reference with
 *                                respect to 'var' variable.
 *                  val         - Buffer for value storage.
 *
 * Output:          Variable reference as required by application.
 *
 * Side Effects:    None
 *
 * Overview:        This is a callback function from HTTPServer() to
 *                  main application.
 *                  Whenever a variable substitution is required
 *                  on any html pages, HTTPServer calls this function
 *                  8-bit variable identifier, variable reference,
 *                  which indicates whether this is a first call or
 *                  not.  Application should return one character
 *                  at a time as a variable value.
 *
 * Note:            Since this function only allows one character
 *                  to be returned at a time as part of variable
 *                  value, HTTPServer() calls this function
 *                  multiple times until main application indicates
 *                  that there is no more value left for this
 *                  variable.
 *                  On begining, HTTPGetVar() is called with
 *                  ref = HTTP_START_OF_VAR to indicate that
 *                  this is a first call.  Application should
 *                  use this reference to start the variable value
 *                  extraction and return updated reference.  If
 *                  there is no more values left for this variable
 *                  application should send HTTP_END_OF_VAR.  If
 *                  there are any bytes to send, application should
 *                  return other than HTTP_START_OF_VAR and
 *                  HTTP_END_OF_VAR reference.
 *
 *                  THIS IS AN EXAMPLE CALLBACK.
 *                  MODIFY THIS AS PER YOUR REQUIREMENTS.
 ********************************************************************/
#if defined(STACK_USE_HTTP_SERVER)
WORD HTTPGetVar(BYTE var, WORD ref, BYTE* val)
{
	// Temporary variables designated for storage of a whole return 
	// result to simplify logic needed since one byte must be returned
	// at a time.
	static BYTE VarString[20];
#if ENABLE_REMOTE_CONFIG
	static BYTE VarStringLen;
	BYTE *VarStringPtr;

	BYTE i;
	BYTE *DataSource;
#endif
	
	// Identify variable
    switch(var)
    {
    case VAR_LED0:
        *val = LED0_IO ? '1':'0';
        break;
    case VAR_LED1:
        *val = LED1_IO ? '1':'0';
        break;
    case VAR_LED2:
        *val = LED2_IO ? '1':'0';
        break;
    case VAR_LED3:
        *val = LED3_IO ? '1':'0';
        break;
    case VAR_LED4:
        *val = LED4_IO ? '1':'0';
        break;
    case VAR_LED5:
        *val = LED5_IO ? '1':'0';
        break;
    case VAR_LED6:
        *val = LED6_IO ? '1':'0';
        break;
    case VAR_LED7:
        *val = LED7_IO ? '1':'0';
        break;

    case VAR_ANAIN_AN0:
        *val = AN0String[(BYTE)ref];
        if(AN0String[(BYTE)ref] == '\0')
            return HTTP_END_OF_VAR;
		else if(AN0String[(BYTE)++ref] == '\0' )
            return HTTP_END_OF_VAR;
        return ref;
//    case VAR_ANAIN_AN1:
//        *val = AN1String[(BYTE)ref];
//        if(AN1String[(BYTE)ref] == '\0')
//            return HTTP_END_OF_VAR;
//		else if(AN1String[(BYTE)++ref] == '\0' )
//            return HTTP_END_OF_VAR;
//        return ref;

    case VAR_DIGIN0:
        *val = BUTTON0_IO ? '1':'0';
        break;
    case VAR_DIGIN1:
        *val = BUTTON1_IO ? '1':'0';
        break;
    case VAR_DIGIN2:
        *val = BUTTON2_IO ? '1':'0';
        break;
    case VAR_DIGIN3:
        *val = BUTTON3_IO ? '1':'0';
        break;

	case VAR_STACK_VERSION:
        if(ref == HTTP_START_OF_VAR)
		{
			strcpypgm2ram(VarString, VERSION);
		}
        *val = VarString[(BYTE)ref];
        if(VarString[(BYTE)ref] == '\0')
            return HTTP_END_OF_VAR;
		else if(VarString[(BYTE)++ref] == '\0' )
            return HTTP_END_OF_VAR;
        return ref;
	case VAR_STACK_DATE:
        if(ref == HTTP_START_OF_VAR)
		{
			strcpypgm2ram(VarString, __DATE__ " " __TIME__);
		}
        *val = VarString[(BYTE)ref];
        if(VarString[(BYTE)ref] == '\0')
            return HTTP_END_OF_VAR;
		else if(VarString[(BYTE)++ref] == '\0' )
            return HTTP_END_OF_VAR;
        return ref;

#if ENABLE_REMOTE_CONFIG
    case VAR_MAC_ADDRESS:
        if ( ref == HTTP_START_OF_VAR )
        {
            VarStringLen = 2*6+5;	// 17 bytes: 2 for each of the 6 address bytes + 5 octet spacers

	        // Format the entire string
            i = 0;
            VarStringPtr = VarString;
            while(1)
            {
	            *VarStringPtr++ = btohexa_high(AppConfig.MyMACAddr.v[i]);
	            *VarStringPtr++ = btohexa_low(AppConfig.MyMACAddr.v[i]);
	            if(++i == 6)
	            	break;
	            *VarStringPtr++ = '-';
	        }
        }

		// Send one byte back to the calling function (the HTTP Server)
		*val = VarString[(BYTE)ref];
		
        if ( (BYTE)++ref == VarStringLen )
            return HTTP_END_OF_VAR;

        return ref;
    	
    case VAR_SERIAL_NUMBER:
        if ( ref == HTTP_START_OF_VAR )
        {
	        // Obtain the serial number.  For this demo, we will call 
	        // the two low bytes of our MAC address (required to be 
	        // organization assigned) our board's serial number
	        itoa(AppConfig.SerialNumber.Val, VarString);
            VarStringLen = strlen(VarString);
        }

		// Send one byte back to the calling function (the HTTP Server)
		*val = VarString[(BYTE)ref];
		
		// If this is the last byte to be returned, return 
		// HTTP_END_OF_VAR so the HTTP server won't keep calling this 
		// application callback function
        if ( (BYTE)++ref == VarStringLen )
            return HTTP_END_OF_VAR;

        return ref;
    	
    case VAR_IP_ADDRESS:
    case VAR_SUBNET_MASK:
    case VAR_GATEWAY_ADDRESS:
    	// Check if ref == 0 meaning that the first character of this 
    	// variable needs to be returned
        if ( ref == HTTP_START_OF_VAR )
        {
	        // Decide which 4 variable bytes to send back
	        if(var == VAR_IP_ADDRESS)
		    	DataSource = (BYTE*)&AppConfig.MyIPAddr;
		    else if(var == VAR_SUBNET_MASK)
		    	DataSource = (BYTE*)&AppConfig.MyMask;
		    else if(var == VAR_GATEWAY_ADDRESS)
		    	DataSource = (BYTE*)&AppConfig.MyGateway;
	        
	        // Format the entire string
	        VarStringPtr = VarString;
	        i = 0;
	        while(1)
	        {
		        itoa((WORD)*DataSource++, VarStringPtr);
		        VarStringPtr += strlen(VarStringPtr);
		        if(++i == 4)
		        	break;
		        *VarStringPtr++ = '.';
		    }
		    VarStringLen = strlen(VarString);
        }

		// Send one byte back to the calling function (the HTTP Server)
		*val = VarString[(BYTE)ref];
		
		// If this is the last byte to be returned, return 
		// HTTP_END_OF_VAR so the HTTP server won't keep calling this 
		// application callback function
        if ( (BYTE)++ref == VarStringLen )
            return HTTP_END_OF_VAR;

        return ref;
    	
    case VAR_DHCP_TRUE:
    case VAR_DHCP_FALSE:
    	// Check if ref == 0 meaning that the first character of this 
    	// variable needs to be returned
        if ( ref == HTTP_START_OF_VAR )
        {
	        if((var == VAR_DHCP_TRUE) ^ AppConfig.Flags.bIsDHCPEnabled)
	        	return HTTP_END_OF_VAR;

            VarStringLen = 7;
			memcpypgm2ram(VarString, (rom void *)"checked", 7);
        }

		*val = VarString[(BYTE)ref];
		
        if ( (BYTE)++ref == VarStringLen )
            return HTTP_END_OF_VAR;

        return ref;
#endif
    }

    return HTTP_END_OF_VAR;
}
#endif


#if defined(STACK_USE_FTP_SERVER) && defined(MPFS_USE_EEPROM)
ROM char FTP_USER_NAME[]    = "ftp";
ROM char FTP_USER_PASS[]    = "microchip";
#undef FTP_USER_NAME_LEN
#define FTP_USER_NAME_LEN   (sizeof(FTP_USER_NAME)-1)
#define FTP_USER_PASS_LEN   (sizeof(FTP_USER_PASS)-1)

BOOL FTPVerify(char *login, char *password)
{
    if ( !memcmppgm2ram(login, (ROM void*)FTP_USER_NAME, FTP_USER_NAME_LEN) )
    {
        if ( !memcmppgm2ram(password, (ROM void*)FTP_USER_PASS, FTP_USER_PASS_LEN) )
            return TRUE;
    }
    return FALSE;
}
#endif




/*********************************************************************
 * Function:        void InitializeBoard(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        Initialize board specific hardware.
 *
 * Note:            None
 ********************************************************************/
static void InitializeBoard(void)
{
	// LEDs
	LED0_TRIS = 0;
	LED1_TRIS = 0;
	LED2_TRIS = 0;
	LED3_TRIS = 0;
	LED4_TRIS = 0;
	LED5_TRIS = 0;
	LED6_TRIS = 0;
#if !defined(EXPLORER_16) && !defined(EXPLORER16_RTL)	// Pin multiplexed with a button on EXPLORER_16 
	LED7_TRIS = 0;
#endif
	LED0_IO = 0;
	LED1_IO = 0;
	LED2_IO = 0;
	LED3_IO = 0;
	LED4_IO = 0;
	LED5_IO = 0;
	LED6_IO = 0;
	LED7_IO = 0;


#ifdef __C30__
	#if defined(__dsPIC33F__) || defined(__PIC24H__)
	// Crank up the core frequency
	PLLFBD = 39;				// Multiply by 40 for 160MHz VCO output (8MHz XT oscillator)
	CLKDIV = 0x0000;			// FRC: divide by 2, PLLPOST: divide by 2, PLLPRE: divide by 2

	// Port I/O
	AD1PCFGHbits.PCFG23 = 1;	// Make RA7 (BUTTON1) a digital input
	#endif

	// ADC
	AD1CON1 = 0x84E4;			// Turn on, auto sample start, auto-convert, 12 bit mode (on parts with a 12bit A/D)
	AD1CON2 = 0x0404;			// AVdd, AVss, int every 2 conversions, MUXA only, scan
	AD1CON3 = 0x1003;			// 16 Tad auto-sample, Tad = 3*Tcy
    AD1CHS = 0;					// Input to AN0 (potentiometer)
	AD1PCFGbits.PCFG5 = 0;		// Disable digital input on AN5 (potentiometer)
	AD1PCFGbits.PCFG4 = 0;		// Disable digital input on AN4 (TC1047A temp sensor)
	AD1CSSL = 1<<5;				// Scan pot

//	// Enable ADC interrupt
//	IFS0bits.AD1IF = 0;
//	IEC0bits.AD1IE = 1;


	// UART
	UARTTX_TRIS = 0;
	UARTRX_TRIS = 1;
	U2BRG = (INSTR_FREQ+8ul*BAUD_RATE)/16/BAUD_RATE-1;
	U2MODE = 0x8000;		// UARTEN set
	U2STA = 0x0400;			// UTXEN set
#else
	// Enable 4x PLL on PIC18F87J10, PIC18F97J60, etc.
    OSCTUNE = 0x40;

	// Set up analog features of PORTA

	// PICDEM.net 2 board has POT on AN2, Temp Sensor on AN3
	#if defined(PICDEMNET2) || defined(PIC18F97J60_TEST_BOARD)
		ADCON0 = 0b10001001;	// ADON, Channel 2, Calibrate next conversion
		ADCON1 = 0b00001011;	// Vdd/Vss is +/-REF, AN0, AN1, AN2, AN3 are analog
	    TRISA = 0x2F;
	#elif defined(__18F452)
		ADCON0 = 0b10000001;	// ADON, Channel 0, Fosc/32
		ADCON1 = 0b10001110;	// Right justified, Fosc/32, AN0 only anlog, VREF+/VREF- are VDD/VSS
	    TRISA = 0x23;
	#else
		ADCON0 = 0b00000001;	// ADON, Channel 0
		ADCON1 = 0b00001110;	// Vdd/Vss is +/-REF, AN0 is analog
	    TRISA = 0x23;
	#endif
	ADCON2 = 0b10111110;	// Right justify, 20TAD ACQ time, Fosc/64 (~21.0kHz)


    // Enable internal PORTB pull-ups
    INTCON2bits.RBPU = 0;

	// Configure USART
    TXSTA = 0b00100000;     // Low BRG speed
//#if defined(FS_USB)
//    RCSTA = 0b10000000;		// PICDEM FS USB demo board has UART RX pin multipled with SPI, we must not enable the UART RX functionality
//#else
    RCSTA = 0b10010000;
//#endif
    SPBRG = SPBRG_VAL;

	// Enable Interrupts
    T0CON = 0;
    INTCONbits.GIEH = 1;
    INTCONbits.GIEL = 1;

    // Do a calibration A/D conversion
	#if defined(__18F87J10) || defined(__18F86J15) || defined(__18F86J10) || defined(__18F85J15) || defined(__18F85J10) || defined(__18F67J10) || defined(__18F66J15) || defined(__18F66J10) || defined(__18F65J15) || defined(__18F65J10) || defined(__18F97J60) || defined(__18F96J65) || defined(__18F96J60) || defined(__18F87J60) || defined(__18F86J65) || defined(__18F86J60) || defined(__18F67J60) || defined(__18F66J65) || defined(__18F66J60) 
		ADCON0bits.ADCAL = 1;
	    ADCON0bits.GO = 1;
		while(ADCON0bits.GO);
		ADCON0bits.ADCAL = 0;
	#endif

//	// Enable ADC interrupt
//	PIR1bits.ADIF = 0;
//	PIE1bits.ADIE = 1;

#endif

#if defined(DSPICDEM11)
	// Deselect the LCD controller (PIC18F252 onboard) to ensure there is no SPI2 contention
	LCDCTRL_CS_TRIS = 0;
	LCDCTRL_CS_IO = 1;

	// Hold the codec in reset to ensure there is no SPI2 contention
	CODEC_RST_TRIS = 0;
	CODEC_RST_IO = 0;
#endif

}

/*********************************************************************
 * Function:        void InitAppConfig(void)
 *
 * PreCondition:    MPFSInit() is already called.
 *
 * Input:           None
 *
 * Output:          Write/Read non-volatile config variables.
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
static void InitAppConfig(void)
{
#if defined(MPFS_USE_EEPROM)
    BYTE c;
    BYTE *p;
#endif

#if defined(STACK_USE_DHCP) || defined(STACK_USE_IP_GLEANING)
    AppConfig.Flags.bIsDHCPEnabled = TRUE;
#else
    AppConfig.Flags.bIsDHCPEnabled = FALSE;
#endif

#if defined(MPFS_USE_EEPROM)
    p = (BYTE*)&AppConfig;


    XEEBeginRead(EEPROM_CONTROL, 0x00);
    c = XEERead();
    XEEEndRead();

    /*
     * When a record is saved, first byte is written as 0x55 to indicate
     * that a valid record was saved.
     */
    if(c == 0x55)
    {
        XEEBeginRead(EEPROM_CONTROL, 0x01);
        for ( c = 0; c < sizeof(AppConfig); c++ )
            *p++ = XEERead();
        XEEEndRead();
    }
    else
        SaveAppConfig();
#endif
}

#if defined(MPFS_USE_EEPROM)
static void SaveAppConfig(void)
{
    BYTE c;
    BYTE *p;

    p = (BYTE*)&AppConfig;
    XEEBeginWrite(EEPROM_CONTROL, 0x00);
    XEEWrite(0x55);
    for ( c = 0; c < sizeof(AppConfig); c++ )
    {
        XEEWrite(*p++);
    }

    XEEEndWrite();
}
#endif

ROM char menu[] =
    "\r\n\r\n\rMicrochip TCP/IP Config Application ("VERSION", " __DATE__ ")\r\n\r\n"
    "\t1: Change Board serial number.\r\n"
	"\t2: Change Board Host Name.\r\n"
    "\t3: Change default IP address.\r\n"
    "\t4: Change default gateway address.\r\n"
    "\t5: Change default subnet mask.\r\n"
	"\t6: Change default DNS server address.\r\n"
    "\t7: Enable DHCP & IP Gleaning.\r\n"
    "\t8: Disable DHCP & IP Gleaning.\r\n"
    "\t9: Download MPFS image.\r\n"
    "\t0: Save & Quit.\r\n"
    "\r\n"
    "Enter a menu choice (1-0): ";

typedef enum _MENU_CMD
{
    MENU_CMD_SERIAL_NUMBER          = '1',
	MENU_CMD_HOST_NAME,
    MENU_CMD_IP_ADDRESS,
    MENU_CMD_GATEWAY_ADDRESS,
    MENU_CMD_SUBNET_MASK,
	MENU_CMD_DNS_ADDRESS,
    MENU_CMD_ENABLE_AUTO_CONFIG,
    MENU_CMD_DISABLE_AUTO_CONFIG,
    MENU_CMD_DOWNLOAD_MPFS,
    MENU_CMD_QUIT					= '0',
    MENU_CMD_INVALID				= MENU_CMD_DOWNLOAD_MPFS + 1
} MENU_CMD;

ROM char * const menuCommandPrompt[] =
{
    "\r\nNow running application...\r\n",
    "\r\nSerial Number (",
    "\r\nHost Name (",
    "\r\nDefault IP Address (",
    "\r\nDefault Gateway Address (",
    "\r\nDefault Subnet Mask (",
    "\r\nDefault DNS Server Address (",
    "\r\nDHCP & IP Gleaning enabled.\r\n",
    "\r\nDHCP & IP Gleaning disabled.\r\n",
    "\r\nReady to download MPFS image - Use Xmodem protocol.\r\n",
};

ROM char InvalidInputMsg[] = "\r\nInvalid input received - Input ignored.\r\n"
                             "Press any key to continue...\r\n";


BOOL StringToIPAddress(char *str, IP_ADDR *buffer)
{
    BYTE v;
    char *temp;
    BYTE byteIndex;

    temp = str;
    byteIndex = 0;

    while( v = *str )
    {
        if ( v == '.' )
        {
            *str++ = '\0';
            buffer->v[byteIndex++] = atoi(temp);
            temp = str;
        }
        else if ( v < '0' || v > '9' )
            return FALSE;

        str++;
    }

    buffer->v[byteIndex] = atoi(temp);

    return (byteIndex == 3);
}



MENU_CMD GetMenuChoice(void)
{
    BYTE c;

    while(!DataRdyUART())
	{
		// Invalidate the EEPROM contents if BUTTON0 is held down for more than 4 seconds
		#if defined(MPFS_USE_EEPROM)
		if(BUTTON0_IO == 0)
		{
			TICK StartTime = TickGet();

			while(BUTTON0_IO == 0)
			{
				if(TickGet() - StartTime > 4*TICK_SECOND)
				{
				    XEEBeginWrite(EEPROM_CONTROL, 0x00);
				    XEEWrite(0x00);
				    XEEEndWrite();
					putrsUART("\r\n\r\nBUTTON0 held for more than 4 seconds.  EEPROM contents erased.\r\n\r\n");
					break;
				}
			}
		}
		#endif
	}

    c = ReadUART();

    if ( c >= '0' && c < MENU_CMD_INVALID )
        return c;
    else
        return MENU_CMD_INVALID;
}

#define MAX_USER_RESPONSE_LEN   (20)
void ExecuteMenuChoice(MENU_CMD choice)
{
    char response[MAX_USER_RESPONSE_LEN];
    IP_ADDR tempIPValue;
    IP_ADDR *destIPValue;

	putrsUART(CRLF);
    putrsUART(menuCommandPrompt[choice-'0']);

    switch(choice)
    {
    case MENU_CMD_SERIAL_NUMBER:
		itoa(AppConfig.SerialNumber.Val, response);
		putsUART(response);
		putrsUART("): ");

		if(ReadStringUART(response, sizeof(response)))
		{
	        AppConfig.SerialNumber.Val = atoi(response);
	        AppConfig.MyMACAddr.v[4] = AppConfig.SerialNumber.v[1];
    	    AppConfig.MyMACAddr.v[5] = AppConfig.SerialNumber.v[0];
		}
        break;

	case MENU_CMD_HOST_NAME:
		putsUART(AppConfig.NetBIOSName);
		putrsUART("): ");

        ReadStringUART(response, sizeof(response) > sizeof(AppConfig.NetBIOSName) ? sizeof(AppConfig.NetBIOSName) : sizeof(response));
		if(response[0] != '\0')
		{
			memcpy(AppConfig.NetBIOSName, (void*)response, sizeof(AppConfig.NetBIOSName));
	        FormatNetBIOSName(AppConfig.NetBIOSName);
		}
		break;

    case MENU_CMD_IP_ADDRESS:
        destIPValue = &AppConfig.MyIPAddr;
        goto ReadIPConfig;

    case MENU_CMD_GATEWAY_ADDRESS:
        destIPValue = &AppConfig.MyGateway;
        goto ReadIPConfig;

    case MENU_CMD_SUBNET_MASK:
        destIPValue = &AppConfig.MyMask;
        goto ReadIPConfig;

    case MENU_CMD_DNS_ADDRESS:
        destIPValue = &AppConfig.PrimaryDNSServer;

    ReadIPConfig:
        DisplayIPValue(destIPValue);
		putrsUART("): ");

        ReadStringUART(response, sizeof(response));

        if ( !StringToIPAddress(response, &tempIPValue) )
        {
            putrsUART(InvalidInputMsg);
            while(!DataRdyUART());
            ReadUART();
        }
        else
        {
            destIPValue->Val = tempIPValue.Val;
        }
        break;


    case MENU_CMD_ENABLE_AUTO_CONFIG:
        AppConfig.Flags.bIsDHCPEnabled = TRUE;
        break;

    case MENU_CMD_DISABLE_AUTO_CONFIG:
        AppConfig.Flags.bIsDHCPEnabled = FALSE;
        break;

    case MENU_CMD_DOWNLOAD_MPFS:
#if defined(MPFS_USE_EEPROM)
        DownloadMPFS();
#endif
        break;

    case MENU_CMD_QUIT:
#if defined(MPFS_USE_EEPROM)
        SaveAppConfig();
#endif
        break;
    }
}




static void SetConfig(void)
{
    MENU_CMD choice;

    do
    {
        putrsUART(menu);
        choice = GetMenuChoice();
        if ( choice != MENU_CMD_INVALID )
            ExecuteMenuChoice(choice);
    } while(choice != MENU_CMD_QUIT);

}


#if defined(MPFS_USE_EEPROM)
/*********************************************************************
 * Function:        BOOL DownloadMPFS(void)
 *
 * PreCondition:    MPFSInit() is already called.
 *
 * Input:           None
 *
 * Output:          TRUE if successful
 *                  FALSE otherwise
 *
 * Side Effects:    This function uses 128 bytes of Bank 4 using
 *                  indirect pointer.  This requires that no part of
 *                  code is using this block during or before calling
 *                  this function.  Once this function is done,
 *                  that block of memory is available for general use.
 *
 * Overview:        This function implements XMODEM protocol to
 *                  be able to receive a binary file from PC
 *                  applications such as HyperTerminal.
 *
 * Note:            In current version, this function does not
 *                  implement user interface to set IP address and
 *                  other informations.  User should create their
 *                  own interface to allow user to modify IP
 *                  information.
 *                  Also, this version implements simple user
 *                  action to start file transfer.  User may
 *                  evaulate its own requirement and implement
 *                  appropriate start action.
 *
 ********************************************************************/
#define XMODEM_SOH      0x01
#define XMODEM_EOT      0x04
#define XMODEM_ACK      0x06
#define XMODEM_NAK      0x15
#define XMODEM_CAN      0x18
#define XMODEM_BLOCK_LEN 128

static BOOL DownloadMPFS(void)
{
    enum SM_MPFS
    {
        SM_MPFS_SOH,
        SM_MPFS_BLOCK,
        SM_MPFS_BLOCK_CMP,
        SM_MPFS_DATA,
    } state;

    BYTE c;
    MPFS handle;
    BOOL lbDone;
    BYTE blockLen;
    BYTE lResult;
    BYTE tempData[XMODEM_BLOCK_LEN];
    TICK lastTick;
    TICK currentTick;

    state = SM_MPFS_SOH;
    lbDone = FALSE;

    handle = MPFSFormat();

    // Notify the host that we are ready to receive...
    lastTick = TickGet();
    do
    {
        currentTick = TickGet();
        if ( TickGetDiff(currentTick, lastTick) >= (TICK_SECOND/2) )
        {
            lastTick = TickGet();
			while(BusyUART());
            WriteUART(XMODEM_NAK);

            /*
             * Blink LED to indicate that we are waiting for
             * host to send the file.
             */
            LED6_IO ^= 1;
        }

    } while(!DataRdyUART());


    while(!lbDone)
    {
        if(DataRdyUART())
        {
            // Toggle LED as we receive the data from host.
            LED6_IO ^= 1;
            c = ReadUART();
        }
        else
        {
            // Real application should put some timeout to make sure
            // that we do not wait forever.
            continue;
        }

        switch(state)
        {
        default:
            if ( c == XMODEM_SOH )
            {
                state = SM_MPFS_BLOCK;
            }
            else if ( c == XMODEM_EOT )
            {
                // Turn off LED when we are done.
                LED6_IO = 1;

                MPFSClose();
				while(BusyUART());
                WriteUART(XMODEM_ACK);
                lbDone = TRUE;
            }
            else
			{
				while(BusyUART());
				WriteUART(XMODEM_NAK);
			}

            break;

        case SM_MPFS_BLOCK:

            // We do not use block information.
            lResult = XMODEM_ACK;
            blockLen = 0;
            state = SM_MPFS_BLOCK_CMP;
            break;

        case SM_MPFS_BLOCK_CMP:

            // We do not use 1's comp. block value.
            state = SM_MPFS_DATA;
            break;

        case SM_MPFS_DATA:

            // Buffer block data until it is over.
            tempData[blockLen++] = c;
            if ( blockLen > XMODEM_BLOCK_LEN )
            {

                // We have one block data. Write it to EEPROM.
                MPFSPutBegin(handle);

                lResult = XMODEM_ACK;
                for ( c = 0; c < XMODEM_BLOCK_LEN; c++ )
                    MPFSPut(tempData[c]);

                handle = MPFSPutEnd();

				while(BusyUART());
                WriteUART(lResult);
                state = SM_MPFS_SOH;
            }
            break;

        }

    }

// This small wait is required if SLIP is in use.
// If this is not used, PC might misinterpret SLIP
// module communication and never close file transfer
// dialog box.
#if defined(STACK_USE_SLIP)
    {
        BYTE i = 255;
        while(i--);
    }
#endif
    return TRUE;
}
#endif

static void FormatNetBIOSName(BYTE Name[16])
{
	BYTE i;

	Name[15] = '\0';
	strupr(Name);
	i = 0;
	while(i < 15)
	{
		if(Name[i] == '\0')
		{
			while(i < 15)
			{
				Name[i++] = ' ';
			}
			break;
		}
		i++;
	}
}
