Release Notes for MPASM Version 2.30
20 May 99
  
------------------------------------------------------------
Full Device Support List:
------------------------------------------------------------

12C508   12C508A  12C509   12C509A  12CR509A*  
12CE518  12CE519  12C671   12C672   12CE673  12CE674

14000

16C52    16C54    16CR54   16C54A   16CR54A  16C54B   16CR54B
16C54C*  16CR54C  16C505   16C55    16C55A   16C554      
16C558   16C56    16C56A   16CR56A  16C57    16CR57A  16CR57B  
16C57C*  16C58A   16CR58A  16C58B   16CR58B  16HV540*
16C5X    

16C61    16C62    16CR62   16C62A   16C620   16C620A  16CR620A*
16C621   16C621A  16C622   16C622A  16CE623  16CE624  16CE625  16C63    
16C63A   16CR63   16C64    16CR64   16C64A   16C642   16C65    
16CR65   16C65A   16C65B   16C66    16C662   16F627*  16F628*
16C67    16C71    
16C710   16C711   16C712*  16C715   16C716*  16C72    16C72A   
16CR72   16C73    
16C73A   16C73B   16C74    16C74A   16C74B   16C76    16C77 
16C773*  16C774*   
16CR83   16C84    16CR84   16F83    16F84    16F84A*
16F873*  16F874*  16F876*  16F877*
16C923   16C924   
16CXX    

17C42    17CR42   17C42A   17C43    17CR43   17C44    17C752  
17C756   17C756A  17C762   17C766   
17CXX  

EEPROM8 EEPROM16
	
	*-new product support

THESE PARTS MAY NOT ALL BE COMMERCIALLY AVAILABLE.

These can be chosen through the introductory screen, on the
command line, or in source file.  Three selections, 16C5X, 
16CXX, and 17CXX are supported as generic family indicators.  

The selections EEPROM8 and EEPROM16 are provided for generic 
memory product support.  Read below for a description of how
to use MPASM to generate files for programming Microchip Serial 
EEPROM devices.

The standard header files have been updated to reflect these
devices.  One header file, MEMORY.INC, is provided for generic 
memory product support.

------------------------------------------------------------
SERIAL EEPROM SUPPORT:
------------------------------------------------------------

Two "processor" selections are provided to generate byte data - 
EEPROM8 and EEPROM16.  Both generate data in terms of bytes, 
but EEPROM8 considers a "word" to be 8 bits wide, while 
EEPROM16 considers a "word" to be 16 bits wide.  The "program
counter" is always incremented in terms of bytes.

The default size for memory products is 128 bytes.  This can
be overridden by using the LIST M=<max address> directive.  
Note that <max address> is always evaluated as a decimal number.
The header file MEMORY.INC is provided to define the maximum
address for available memory devices.  The format of the 
defined symbols is _<device>; for example, to set the maximum
memory size for a 24LCS21, use the directive LIST M=_24LCS21.

The following data generation directives are supported for 
memory products:

	DW	   FILL	ORG

The behavior of other data generation directives is not 
guaranteed.  All other directives are unchanged.

An example of generating a file for programming a memory device
is as follows:

;*************************************************
; Generate data for a 8-bit wide memory device.

        LIST    P=EEPROM8, R=DECIMAL
        INCLUDE "MEMORY.INC"
        LIST    M=_24LCS21

#DEFINE MAX_VALUE       255

        ORG     0

;-------------------------------------------------
; Create a packed-byte, null terminated string.

        DW      "Hello World", 0

;-------------------------------------------------
; Create data representing a line.  The X position
; is implied from the position of the data in the
; device.  The Y values are stored in the device.

; First, define an equation for the line.

#DEFINE Line( X )       Slope * X + Y_Intercept

; Now define the values needed for the equation.

Slope                   EQU     10
Y_Intercept             EQU     5

; Declare and initialize the X and Y values.

        VARIABLE        X = 0, Y = Line( X )

; Generate values until the maximum Y value is 
; reached or the device is filled up.

        WHILE (Y <= MAX_VALUE) && ($ <= _24LCS21)
           DW   Y
X = X + 1
Y = Line( X )
        ENDW

;-------------------------------------------------
; Perform some checking based on the line data 
; generated above.

; If the device filled up before the end of the
; line was reached, generate an error.  Otherwise,
; if the device is almost out of room, generate a
; message.

        IF (Y < MAX_VALUE)
           ERROR        "Device is full."
        ELSE
           IF (($+10) > _24LCS21)
              MESSG     "Device is nearly full."
           ENDIF
        ENDIF

;-------------------------------------------------
; Fill the rest of the device with zeroes.

        FILL    0, _24LCS21 - $ + 1

        END

CLRW COMMAND:

The CLRW encoding was changed on all 14-bit core devices 
from 0x0100 to 0x0103 (v1.40 and later).  This will not affect
the expected operation of the instruction, but it will change
the value for the instruction in the hex file and therefore
the checksum.


WARNING MESSAGE:

The text for Message #302 was modified to explain more
clearly that bank indication bits are stripped when assembling
instructions that access file registers.  The appropriate
bank must be selected by the appropriate bank selection bits.  
For example, 14-bit core devices contain the lower seven bits 
of the file register address in the opcode, with two bank 
selection bits in the STATUS register.  The message was 
changed from:
        Argument out of range.  Least significant bits used.
to:
        Register in operand not in bank 0.  Ensure that bank 
        bits are correct.


END DIRECTIVE:

Take care to not use the END directive in a macro.  If the END 
directive is encountered in a macro, it can cause the assembler
to loop indefinitely.  Macros should be terminated with the
ENDM directive.  

------------------------------------------------------------    
Instructions on Using MPASM    
------------------------------------------------------------    
    
Create your source code with any text editor.  The file 
should contain ASCII text only.  Assemble your code with the 
command line:
	
	MPASM <file>[.asm]    
    
Correct any syntax problems, referring to the MPASM User's 
Guide for syntax help.  MPASM assembles with INHX8M as the 
default hex output, and generates a listing file, error file,
and .COD file.
    
MPASM currently runs in DOS real mode.  If you have "out of 
memory" problems, try using the DOS protected mode (DPMI) 
version.  To use this assembler, you must have the files 
RTM.EXE and DPMI16BI.OVL (distributed with this release) 
available in your path or in the current directory.  You must 
also have EMM386 or another memory manager running or run the 
assembler from a Windows DOS box.  To invoke this assembler, 
use the command:

	MPASM_DP <file>[.asm]    

A version of MPASM is also available for Windows.  To invoke 
this assembler, execute:

	MPASMWIN.EXE

from within Windows.  You will then be given a Windows
interface window.  Help on using the interface is provided
on-line.  MPASMWIN can also be invoked with parameters or 
through drag-and-drop.  In these cases, the interface 
screen is not displayed and assembly begins immediately.

------------------------------------------------------------    
Fixed SSRs
------------------------------------------------------------  
v2.30
MPASM doesn't appropriately handle 2 different overlay
sections in the same file.
Default radix setting does not affect macros

  
v2.20 
Add DA directive for 2 7-bit ASCII character packing
in 14-bit program memory

v2.15 
16C505 was not generating the proper processor type number
in MPLAB.INI

v2.10
3534 Don't wait for user input in /q (quiet) mode.
     
3543 Don't output object file if error encountered.

v2.01
3217 MPASMWIN has difficulty with Asian and some European
     date and time formats

3245 The expression GOTO $-9w does not return an error if 
     w is a defined constant

v2.00
2089 FILL $,4 at location 0 should produce 0, 1, 2, 3; not
     0, 0, 0, 0.

2883 ADDLW -'=' does not assemble

2884 Message 302 generated for MOVLW out of range instead of
     Warning 202

3035 MPASM window hangs too long when invoked from MPLAB

3110 Macro parameters should be substituted into #define 
     statements

3117 FILL doesn't properly handle instructions with commas

3152 Allow an optional "=" when using a command line option 
     to specify a file name

-----------------------------------------------------------------
How To Contact Microchip
-----------------------------------------------------------------

On-Line Support
---------------
Microchip provides on-line support on the Microchip World
Wide Web (WWW) site.  The web site is used by Microchip as a
means to make files and information easily available to
customers. To view the site, the user must have access to
the Internet and a web browser, such as Netscape or
Microsoft Explorer. Files are also available for FTP
download from our FTP site.

Connecting to the Microchip Internet Web Site      
---------------------------------------------
The Microchip web site is available by using your favorite
Internet browser to attach to:
 
	www.microchip.com

The file transfer site is available by using an FTP service
to connect to: 

	ftp://ftp.microchip.com

The web site and file transfer site provide a variety of
services. Users may download files for the latest
Development Tools, Data Sheets, Application Notes, User's
Guides, Articles and Sample Programs. A variety of Microchip
specific business information is also available, including
listings of Microchip sales offices, distributors and
factory representatives. Other data available for
consideration is:

	* Latest Microchip Press Releases

	* Technical Support Section with Frequently Asked
          Questions 

	* Design Tips

	* Device Errata

	* Job Postings

	* Microchip Consultant Program Member Listing

	* Links to other useful web sites related to
	  Microchip Products

 	* Conferences for products, Development Systems,
	  technical information and more

	* Listing of seminars and events

Systems Information and Upgrade Hot Line 
----------------------------------------
The Systems Information and Upgrade Line provides system
users a listing of the latest versions of all of Microchip's
development systems software products. Plus, this line
provides information on how customers can receive any
currently available upgrade kits.The Hot Line Numbers are: 

	1-800-755-2345 for U.S. and most of Canada, and 

	1-480-786-7302 for the rest of the world.

-----------------------------------------------------------------
Development Systems Customer Notification Service
-----------------------------------------------------------------

Microchip started the customer notification service to help our 
customers keep current on Microchip products with the least amount 
of effort. Once you subscribe to one of our list servers, you will 
receive email notification whenever we change, update, revise or 
have errata related to that product family or development tool. 
See the Microchip WWW web page for other Microchip list servers.

The Development Systems list names are 
Compilers
Emulators
Programmers
MPLAB
Otools

Once you have determined the names of the lists that you are 
interested in, you can subscribe by sending a message to
        listserv@mail.microchip.com 
with the following as the body: 
        subscribe <listname> yourname

Here is an example: 
        subscribe compilers John Doe 


To UNSUBSCRIBE from these lists, send a message to: 
        listserv@mail.microchip.com 
with the following as the body: 
        unsubscribe <listname> yourname

Here is an example: 
        unsubscribe compilers John Doe


Here is a description of the Development Systems list for
MPASM:

COMPILERS - The latest information on Microchip C compilers, 
Linkers and Assemblers.  These include MPLAB-C17, MPLAB-C18, 
MPLINK, MPASM as well as the Librarian, MPLIB for MPLINK.  To 
SUBSCRIBE to this list, send a message to: 
        listserv@mail.microchip.com 
with the following as the body: 
        subscribe compilers yourname
