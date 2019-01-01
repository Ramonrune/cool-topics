;*********************************************************************
;**    PIC17Cxx MPASM Initialized Data Startup File, Version 0.01   **
;**    (c) Copyright 1997 Microchip Technology                      **
;*********************************************************************

;------------------------ Equates --------------------------;
;Register addresses
INDF           equ    0x00
PCL            equ    0x02
STATUS         equ    0x03
FSR            equ    0x04
PCLATH         equ    0x0A

;Bits within registers
Z              equ    0x02
C              equ    0x00

;----------------External variables and labels--------------;
   EXTERN  _cinit     ;Start of const. data table

;***********************************************************;
VARIABLES   UDATA_OVR
;-----------------------------------------------------------;
; Data used for copying const. data into RAM
;
; NOTE:  ALL THE LOCATIONS IN THIS SECTION CAN BE REUSED
;        BY USER PROGRAMS. THIS CAN BE DONE BY DECLARING
;        A SECTION WITH THE SAME NAME AND ATTRIBUTE,
;        i.e.
;             VARIABLES  UDATA_OVER          (in MPASM)
;        or
;            #pragma udata overlay VARIABLES (in MPLAB-C)
;-----------------------------------------------------------;
num_init             RES   2  ;Number of entries in init table
init_entry_from_addr RES   2  ;ROM address to copy const. data from
init_entry_to_addr   RES   2  ;RAM address to copy const. data to
init_entry_size      RES   2  ;Number of bytes in each init.section
save_tblptrl         RES   1  ;These two variables preserve
save_tblptrh         RES   1  ;the position of TBLTRL within the entry table
;-----------------------------------------------------------;

; ****************************************************************
_copy_idata_sec    CODE    PROGMEM_START

; ****************************************************************
; * Copy initialized data from ROM to RAM                        *
; ****************************************************************
;   The values to be stored in initialized data are stored in
; program memory sections. The actual initialized variables are
; stored in data memory in a section defined by the IDATA directive
; in MPASM or automatically defined by MPLAB-C. There are 'num_init'
; such sections in a program. The table below has an entry for each
; section. Each entry contains the starting address in program memory
; where the data is to be copied from, the starting address in data
; memory where the data is to be copied, and the number of bytes to copy.
;   The startup code below walks the table, reading those starting
; addresses and counts, and copies the data from program to data memory.
;
;
;             +============================+
;  _cinit     | num_init (low)             |
;             +----------------------------+
;             | num_init (high)            |
;             +============================+
;             | init_entry_from_addr (low) |       IDATA (0)
;             +----------------------------+
;             | init_entry_from_addr (high)|
;             +----------------------------+
;             | init_entry_to_addr (low)   |
;             +----------------------------+
;             | init_entry_to_addr (high)  |
;             +----------------------------+
;             | init_entry_size   (low)    |
;             +----------------------------+
;             | init_entry_size   (high)   |
;             +============================+
;             |            .               |           .
;                          .                           .
;             |                            |
;             +============================+
;             | init_entry_from_addr (low) |       IDATA (num_init - 1)
;             +----------------------------+
;             | init_entry_from_addr (high)|
;             +----------------------------+
;             | init_entry_to_addr (low)   |
;             +----------------------------+
;             | init_entry_to_addr (high)  |
;             +----------------------------+
;             | init_entry_size   (low)    |
;             +----------------------------+
;             | init_entry_size   (high)   |
;             +============================+

;   Start of code that copies initialization
; data from program to data memory
copy_init_data

;   First read the count of entries (_cinit)
        movlw   HIGH _cinit
        movwf   PCLATH
        CALL    _cinit & 0x3FF
        BANKSEL num_init
        movwf   num_init
        CALL    (_cinit & 0x3FF) + 1
        movwf   num_init+1

;   For (num_init) do copy data for each initialization
; entry. Decrement 'num_init' every time and when it
; reaches 0 we are done copying initialization data
;
_loop_num_init
        BANKSEL num_init
        movf    num_init, W
        iorwf   num_init+1, 0
        btfss   STATUS, Z             ;   If num_init is not down to 0,
        goto    _copy_init_sec        ; then we have more sections to copy,
        goto    _end_copy_init_data   ; otherwise, we're done copying data.

;   For a single initialization section, read the
; starting addresses in both program and data memory,
; as well as the number of bytes to copy.
;
_copy_init_sec
;  Read 'from' address in program memory
        BANKSEL init_entry_from_addr
        tablrd  0, 1, init_entry_from_addr
        tlrd    0, init_entry_from_addr
        tlrd    1, init_entry_from_addr+1

;  Read 'to' address in data memory
        BANKSEL init_entry_to_addr
        tablrd  0, 1, init_entry_to_addr
        tlrd    0, init_entry_to_addr
        tlrd    1, init_entry_to_addr+1

;  Read 'size' of data to be copied in BYTES
        BANKSEL init_entry_size
        tablrd  0, 1, init_entry_size
        tlrd    0, init_entry_size
        tlrd    1, init_entry_size+1

;  We must save the position of TBLPTR since TBLPTR
;is used in copying the data as well.
        movfp   TBLPTRL, WREG
        BANKSEL save_tblptrl
        movwf   save_tblptrl
        movfp   TBLPTRH, WREG
        BANKSEL save_tblptrh
        movwf   save_tblptrh

; Setup TBLPTRH:TBLPTRL to point to the ROM section
;where the initialization values of the data are stored.
        BANKSEL init_entry_from_addr
        movfp   init_entry_from_addr, WREG
        movwf   TBLPTRL
        movfp   init_entry_from_addr+1, WREG
        movwf   TBLPTRH

;  We must determine whether the data section is in
;the general purpose area of RAM or in the special
;function register (SFR) area. We do this by comparing
;the address with the register memory map. We then
;determine ;whether to alter the upper or lower nibble
;of the BSR register in preparation for copying the data.
;
        BANKSEL init_entry_to_addr
        movfp   init_entry_to_addr, FSR0

; First we see if destination is GPR (>0x20)
        movlw   0x1f
        cpfslt  init_entry_to_addr    ;   If it is < 0x1F continue testing,
        goto    _init_sec_gpr         ;otherwise it's 0x20 or higher (GPR)

; It's not GPR, let's see if it's SFR or unbanked between 0x18 and 0x1F
        movlw   0x18
        cpfslt  init_entry_to_addr    ;is it <=17 ?
        goto    _start_copying_data   ;No, it's between 0x18 and 0x1F

;It's <=17, let's see if it is 0x00-0x0F or 0x10-0x17
        movlw   0x0F
        cpfsgt  init_entry_to_addr
        goto    _start_copying_data    ; It's between 0x00 and 0x0F, COPY!

;if we fall through it's an SFR from 0x10-0x17

;OK, it's an SFR that needs MOVLB-type of bank switching!
;First mask off low nibble of BSR
        movlw   0xF0
        andwf   BSR,1                       ;clear the low nibble
        movfp   init_entry_to_addr+1, WREG  ;Load high portion of address
        iorwf   BSR,1                       ;and paste high portion into BSR
        goto    _start_copying_data

;Well, it's a banked GPR needing MOVLR-type of bank switching!
_init_sec_gpr
;First mask off high nibble of BSR
        movlw   0x0F
        andwf   BSR,1
        BANKSEL init_entry_to_addr+1
        swapf   (init_entry_to_addr+1), WREG  ;Bank addr.in hi nibble of WREG
        iorwf   BSR,1
        goto    _start_copying_data

;Loop for # of bytes to be copied

;   Since on 17Cxx we store two bytes per word we must be careful
;if the number of bytes to be copied is odd. We cannot copy word by
;word or we may end up overwriting a byte in RAM that doesn't belong
;to the initialized data section. We therefore must decrement and
;check the size for every low and high byte read from program memory.
;
_start_copying_data
        tablrd  0, 1, WREG

;***  Test ****
        movfp   init_entry_size, WREG
        iorwf   init_entry_size+1,0
        btfsc   ALUSTA, Z
        goto    _dec_num_init

;***** Copy low byte ****
        tlrd    0, WREG       ;
        movfp   WREG, INDF0   ;Low byte stored in RAM location

;*** Decrement ***
        decf    init_entry_size,1
        btfss   ALUSTA, C
        decf    init_entry_size+1,1

;*** Test again ***
        movfp   init_entry_size, WREG
        iorwf   init_entry_size+1,0
        btfsc   ALUSTA, Z
        goto    _dec_num_init

;**** Copy high byte ****
        tlrd    1, WREG
        movfp   WREG, INDF0

;*** Decrement ***
        decf    init_entry_size,1
        btfss   ALUSTA, C
        decf    init_entry_size+1,1

        goto _start_copying_data

; Decrement the counter for the outermost loop (no. of init.secs.)
;
_dec_num_init
        decf    num_init,1
        btfss   ALUSTA,C
        decf    num_init+1, 1

;Now restore TBLPTRH:TBLPTRL to point to table
        movfp  save_tblptrl, WREG
        movwf  TBLPTRL
        movfp  save_tblptrh, WREG
        movwf  TBLPTRH

;Then go back to the top to do the next section, if any
        goto  _loop_num_init

;We're done copying initialized data
_end_copy_init_data

        return

;Must declare it as GLOBAL to be able to call it from other assembly modules

        GLOBAL   copy_init_data

   END

