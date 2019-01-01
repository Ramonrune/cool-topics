;*******************Constant definitions**************************
SCIO            equ     2               ; Define SCIO as PORTB bit 2
USERCODE        equ     .3              ; Define interleaved user code as 3 insts.

STARTHDR        equ     0x55            ; Define STARTHDR as 0x55
DEVICEADDR      equ     0xA0            ; Define DEVICEADDR as 0xA0
SAK             equ     1               ; Define SAK as 1
NOSAK           equ     0               ; Define NoSAK as 0
MAK             equ     1               ; Define MAK as 1
NOMAK           equ     0               ; Define NoMAK as 0
;*******************Delay loop constant definitions***************
; These constants are used in calculating the correct number of
; loops for different delays. These delays ensure that all
; subroutines have the same overhead which keeps all bit period
; timings the same.
PRE             equ     .13             ; Pre-command overhead value
POST            equ     .11             ; Post-command overhead value
;*******************Bit flag definitions**************************
SEND_MAK        equ     0               ; Send MAK flag
CHECK_SAK       equ     1               ; Check SAK flag
FIRST_HALF      equ     2               ; First half of bit period flag
;*******************Command definitions***************************
READ_CMD        equ     03h             ; Read command
CRRD_CMD        equ     06h             ; Current Address Read command
WRITE_CMD       equ     6Ch             ; Write command
WREN_CMD        equ     96h             ; Write Enable command
WRDI_CMD        equ     91h             ; Write Disable command
RDSR_CMD        equ     05h             ; Read Status Register command
WRSR_CMD        equ     6Eh             ; Write Status Register command
ERAL_CMD        equ     6Dh             ; Erase All command
SETAL_CMD       equ     67h             ; Set All comand
