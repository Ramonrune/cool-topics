*         title  Config/Reset/Interrupt Vectors
*         page

         $if     * > $ffa0
         #fatal   "BASIC Is Too Large"
         $endif
*
*
*
	org	$ffa0
IOVects fdb     SCIIN
        fdb     0
	fdb	0
	fdb	0
	fdb	0
	fdb	0
	fdb	0
	fdb	0

        fdb     SCIOUT
        fdb     0
	fdb	0
	fdb	0
	fdb	0
	fdb	0
	fdb	0
	fdb	0
*
*
	org	$ffc0
RAMStart:       fdb     $8000           ; starting address of system RAM.
RAMSize:	fdb	$2000		; size of BASIC11 RAM Buffer.
EEStart:	fdb	$6000		; starting address of program storage EEPROM 
EESize:         fdb     $2000           ; size of the program storage EEPROM
IOBase:         fdb     $1000           ; Base Address of the I/O Registers
TimeVal:	fdb	62500		; value used for generating 'Time' Interrupt
UserInit:       fdb     IODevInit       ; Used to initialize console/other hardware.
DFLOPADR:	fdb	$4000		; Address of flip-flop used to connect the HC11 SCI
                                        ; to the host port connector.
;
;

          ORG    ROMBEG+ROMSIZE-42  ; START OF VECTOR TABLE.
          FDB    SCISS		; SCI SERIAL SYSTEM
          FDB    SPITC		; SPI TRANSFER COMPLETE
          FDB    PACCIE		; PULSE ACCUMULATOR INPUT EDGE
          FDB    PACCOVF		; PULSE ACCUMULATOR OVERFLOW
          FDB    TIMEROVF		; TIMER OVERFLOW
          FDB    TOC5		; TIMER OUTPUT COMPARE 5
          FDB    TOC4		; TIMER OUTPUT COMPARE 4
          FDB    TOC3		; TIMER OUTPUT COMPARE 3
          FDB    TOC2		; TIMER OUTPUT COMPARE 2
          FDB    TOC1		; TIMER OUTPUT COMPARE 1
          FDB    TIC3		; TIMER INPUT CAPTURE 3
          FDB    TIC2		; TIMER INPUT CAPTURE 2
          FDB    TIC1		; TIMER INPUT CAPTURE 1
          FDB    REALTIMI		; REAL TIME INTERRUPT
          FDB    IRQI		; IRQ INTERRUPT
          FDB    XIRQ		; XIRQ INTERRUPT
          FDB    SWII		; SOFTWARE INTERRUPT
          FDB    ILLOP		; ILLEGAL OPCODE TRAP
          FDB    COP		; WATCH DOG FAIL
          FDB    CMF		; CLOCK MONITOR FAIL
          FDB    POWERUP		; RESET
*
*
*
