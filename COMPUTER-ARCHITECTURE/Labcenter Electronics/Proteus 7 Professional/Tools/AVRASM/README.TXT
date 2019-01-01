AVR Development Tools version 1.30

Welcome to the AVR Development Tools
version 1.30.

Note that the AVRSIM simulator is not longer
included in this package. In order to simulate
the output of the Assembler, use AVR Studio
which is available from www.atmel.com.


The changes in the Assembler are as follows:

Version 1.30:
1) Device support for several new devices has
   been added. The Assembler now support the
   following devices: AT90S1200, AT90S2313,
   AT90S2323, AT90S2333, AT90S2343, AT90S4414,
   AT90S4433, AT90S4434, AT90S8515, AT90S8534,
   AT90S8535, ATtiny11, ATtiny12, ATtiny22,
   ATMEGA603 and ATmega103. Definition files
   for all these devices are supplied in the
   appnotes directory.

2) The help file for the assembler now only
   contains a link to the new HTML based
   help file. This file is named avrasm.html
   and is located in the doc/ subdirectory.
   All the documentation and help files are
   now available as HTML files.

3) The new instructions in the AVR instruction
   set are supported. These instructions are
   MULS, MULSU, FMUL, FMULS, FMULSU, MOVW,
   LPM Rx,Z, LPM Rx,Z+, ELPM Rx,Z, ELPM Rx,Z+,
   SPM and ESPM. These instructions will be
   available on some new devices. See the
   individual data books for each part to see
   which instruction it supports.

4) New application notes have been added. The
   distribution now contains the code of 21
   application notes.

5) Bug fixes.
   The following bugs have been fixed:

   - The DB directive now operates correctly
     when strings are preceded by constants.
   - The DB Directive now correctly updates
     the address counter in the ESEG
   - The problem reported in some Windows95
     installations with GPF when opening WAVRASM
     has been further reduced.
   - The problem with addressing in Intel-hex
     files for devices with more than 64K Byte
     code has been removed.
   - Error messages are given when reserved words
     are used as symbols.
   - The problem of Erroneous operands giving erroneous
     opcodes has been removed.
   - The border case (+/- 2K) of RJMP/RCALL has been
     corrected.
   - The border case (+/- 64) of Branches has been'
     removed.
   - Illegal mnemonics in Macros now results in error
     message.
   - A problem related to file inclusion in Macros has
     been fixed.
   - The problem of some syntax errors not giving error
     messages is solved.
   - Multiple Device statements can no longer be defined.
   - Duplicate Macro definitions does now give a message
   

Version 1.21:

1) There has been some problems with the Windows
   version of the AVR Assembler and some Windows
   95 versions. The program generates a General
   Protection Fault when restarting the Assembler
   if all windows were not closed before exit on
   the previous execution. Users who experience
   this problem should enable the option "Close
   all windows before exit" to avoid the problem.

2) There was a problem with the bitwise not
   operator. The error message "Overflow in
   arithmetic operation" was often incorrectly
   generated when this operator was used. This
   problem has been fixed.

3) The problem with erronous intel-hex files caused
   by the device directive has been fixed. 

4) Labels can now correctly be used in .db
   directives.

Version 1.20:

1)  Macros which were referred before they were
    defined resulted in incorrect code. This
    situation will now generate an error message.

2)  In the Data Segment (dseg) the location
    counter started at 0x20. This has been
    changed to 0x60

3)  The Windows version of the assembler does
    not support files larger than 30K. If this
    situation occurs, the situation will now be
    flagged.
    Workarounds: use the include directive or use
    an external editor and the command line version
    of the Assembler.

4)  The Windows Assembler will not enter Insert
    mode when Shift+Ins or Ctrl+Ins are pressed.
    
5)  The Windows Assembler has had problems with
    special versions of Windows 95 during startup.
    Version 1.20 avoids this problem.
    
6)  The warning message when using LDS/STS
    instruction together with a .device at90s2313
    is removed.

7)  New devices are added: AT90S2323, AT90S2343
    and ATMEGA103

8)  .db and .dw directives can be used within
    a macro

9)  ASCII literals are supported: ldi  r16,'A'

10) ASCII strings are supported: .db "String"
    ASCII strings will not be zero terminated.

11) The .dw directive had a problem when used in
    the EEPROM segment (eseg). This has been
    corrected.

12) Calling macros from within another macro is
    not supported. Version 1.20 will issue an
    error message when this is done.

