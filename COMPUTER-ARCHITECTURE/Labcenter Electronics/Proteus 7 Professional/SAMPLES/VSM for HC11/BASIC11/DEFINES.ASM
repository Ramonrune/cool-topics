*        title    DEFINES

        $IFDEF     HC11

*/***** HC11EVB defines *****/

ROMBEG:	EQU    $E000
ROMSIZE:	EQU    $2000
ACIAST:	EQU    $9800
ACIADT:	EQU    ACIAST+1
DFLOP:	EQU    $4000
SWPRE:	EQU    02           ; SOFTWARE PRESCALER VALUE.
*
*
*
SBASBEG:	equ    0
SBASEND:	equ    2
SVARBEG:	equ    4
SVAREND:	equ    6
SHILINE:	equ    8
AUTOSTF:	equ    10
SSTART:	equ    11

        $ELSE

*/***** 6809/FLEX development defines *****/

ROMBEG:	EQU    $8000
ROMSIZE:	EQU    $2000
RAMBEG:	EQU    $4000
RAMSIZE:	EQU    $2000
STACKP:	EQU    RAMBEG+RAMSIZE-1
SWSTACK:	EQU    RAMBEG+RAMSIZE-512
ACIAST:	EQU    $E010
ACIADT:	EQU    ACIAST+1
*
         ORG    $6000
*
SEEPROM:	EQU    *
SBASBEG:	RMB    2
SBASEND:	RMB    2
SVARBEG:	RMB    2
SVAREND:	RMB    2
AUTOSTF:	RMB    1
SHILINE:	RMB    2
SSTART:	EQU    *


        $ENDIF

*/***** hc11 (device dependant) defines *****/
 
EEPBASAD:	EQU    $B600   ; /* EEPROM base address */
MAXEESUB:	EQU    255     ; /* maximum EEP subscript */
*
*	I/O Register Offsets From The Base Address
*
PPROG:	EQU    $3B  ; /* EEPROM programing control register */
ADCTL:	EQU    $30  ; /* A-TO-D control/status register */
ADR1:	EQU    $31  ; /* A/D result register 1 */
ADR2:	EQU    $32  	 ; /* A/D result register 2 */
ADR3:	EQU    $33  	 ; /* A/D result register 3 */
ADR4:	EQU    $34  	 ; /* A/D result register 4 */
PORTAIO:	EQU    $00  	 ; /* PORTA I/O register */
PORTBIO:	EQU    $04  	 ; /* PORTB I/O register */
PORTCIO:	EQU    $03  	 ; /* PORTC I/O register */
DDRC:           EQU    $07       ; Portc direction register
PORTDIO:        EQU    $08       ; /* PORTD I/O register */
PORTEIO:	EQU    $0A  	 ; /* PORTE I/O register */
TCNT:	EQU    $0E  	 ; /* TIMER/COUNTER register */
TOC1REG:	EQU    $16  	 ; /* TIMER Output Compare 1 register */
TFLAG1:	EQU    $23  	 ; /* TIMER Flag #1 register */
TMSK1:	EQU    $22 	 ; /* TIMER Mask #1 register */
TMSK2:	EQU    $24 	 ; /* TIMER Mask #2 register */
OPTION:	EQU    $39 	 ; /* OPTION select register */
BAUD:	EQU    $2B 	 ; /* SCI baud rate select register */
SCCR1:	EQU    $2C 	 ; /* SCI control register #1 */
SCCR2:	EQU    $2D 	 ; /* SCI control register #2 */
SCSR:	EQU    $2E 	 ; /* SCI status register */
SCDR:	EQU    $2F 	 ; /* SCI transmit/recieve data register */
PACNT:	EQU    $27  	 ; /* PACC count register */
PACTL:	EQU    $26 	 ; /* PACC control register */
TFLG2:	EQU    $25 	 ; /* TIMER Flag #2 register */
INIT:	EQU    $3D    	 ; /* INIT (Base address of RAM & I/O Regs) Register */

*/***** misc. defines *****/
 
EOL:	EQU    13      ; /* end of line marker */
CR:	EQU    13      ; /* same as EOL */
LF:	EQU    10      ; /* linefeed character */
BS:	EQU    8       ; /* backspace character */
SPC:	EQU    32      ; /* space character */
MIDEOL:	EQU    ':'     ; /* mid EOL character */
COMMA:	EQU    ','     ; /* comma */
SEMI:	EQU    ';'     ; /* semicolin */
NUM:	EQU    1       ; /* getvar return flag */
STRING:	EQU    2       ; /* getvar return flag */
NULL:	EQU    0       ; /* null value */
CNTRLC:	EQU    3       ; /* control-c (break character) */
*
*
IBUFLEN:	EQU    80      ; /* input buffer max length */
TBUFLEN:	EQU    128     ; /* token buffer max length */
SWSTKSize:	EQU	592
*
OPSLEN:		 EQU	30	; /* operator stack length */
NUMSLEN:		 EQU	60	; /* operand stack length */
FORSLEN:	EQU	80	; /* FOR..NEXT stack length */
WHSLEN:		 EQU	16	; /* WHILE..ENDWH stack length */
GOSLEN:		 EQU	16	; /* GOSUB stack length */
*
*/***** define error codes *****/
 
LINRANG:	EQU    1       ; /* line number range error */
SYTXERR:	EQU    2       ; /* syntax error */
IVEXPERR:	EQU    3       ; /* invalid expression error */
UPARNERR:	EQU    4       ; /* unbalanced parentheses error */
DTMISERR:	EQU    5       ; /* data type mismatch error */
OPRTRERR:	EQU    6       ; /* illegal operator error */
ILVARERR:	EQU    7       ; /* illegal variable error */
ILTOKERR:	EQU    8       ; /* illegal token error */
OMEMERR:	EQU    9       ; /* out of memory error */
INTOVERR:	EQU    10      ; /* integer overflow error */
IVHEXERR:	EQU    11      ; /* invalid hex digit error */
HEXOVERR:	EQU    12      ; /* hex number overflow */
MISQUERR:	EQU    13      ; /* missing quote error */
MPARNERR:	EQU    14      ; /* missing open or closing parenthisis */
IONSYERR:	EQU    15      ; /* "ON" syntax error */
MTHENERR:	EQU    16      ; /* missing "THEN" in "IF" statement */
MTOERR:	EQU    17      ; /* missing "TO" in "FOR" statement */
LINENERR:	EQU    18      ; /* line number error */
IDTYERR:	EQU    19      ; /* illegal data type error */
EXPCXERR:	EQU    20      ; /* expression too complex (xlator token buff ovf.) */
MCOMAERR:	EQU    21      ; /* missing comma */
MCMSMERR:	EQU    22      ; /* missing comma or semicolin */
MSTKOERR:	EQU    23      ; /* math stack overflow error */
UNDIMERR:	EQU    24      ; /* undimentioned array error */
SUBORERR:	EQU    25      ; /* subscript out of range error */
ZDIVERR:	EQU    26      ; /* divide by zero error */
LNFERR:	EQU    27      ; /* line not found error */
GOSOVERR:	EQU    28      ; /* too many nested GOSUB's */
RWOGERR:	EQU    29      ; /* RETURN w/o GOSUB error */
WHSOVERR:	EQU    30      ; /* too many active WHILE's */
ENDWHERR:	EQU    31      ; /* ENDWH statement w/o WHILE */
ONARGERR:	EQU    32      ; /* ON argument is negative, zero, or too large */
NOSUBERR:	EQU    33      ; /* non-subscriptable variable found in DIM statem. */
REDIMERR:	EQU    34      ; /* variable has already been DIMensioned */
FORNXERR:	EQU    35      ; /* too many active FOR -- NEXT loops active */
MFRNXERR:	EQU    36      ; /* mismatched FOR -- NEXT statements. */
CNTCNERR:	EQU    37      ; /* can't continue */
ODRDERR:	EQU    38      ; /* out of data in read or restore statement */
NEGSUBER:	EQU    39      ; /* negative subscripts not allowed */
EESUBERR:	EQU    40      ; /* EEP() subscript negative or > 200 */
PRFUNERR:	EQU    41      ; /* function only allowed in print statement */
TABARGER:	EQU    42      ; /* argument <0 or >255 in TAB() function */
CHRARGER:	EQU    43      ; /* argument <0 or >255 in CHR$() function */
OVDV0ERR:	EQU    44      ; /* overflow or /0 error in FDIV() function */
INVCHERR:	EQU    45      ; /* invalid channel number in ADC() function */
PRTASERR:	EQU    46      ; /* tried to assign a value <0 or >255 to PORT(X) */
ILPRTERR:	EQU    47      ; /* illegal port error */
ILLIOERR:	EQU    48      ; /* illegal I/O vector number <0 or >7 */
UNINIERR:	EQU    49      ; /* uninitalized I/O vector */
HEX2AERR:	EQU    50      ; /* argument <0 or >255 in HEX2 function */
NOTALERR:	EQU    51      ; /* statement not allowed in direct mode */
NOTINTER:	EQU    52      ; /* an RETI statement executed when not in interrupt */
PACCARGE:	EQU    53      ; /* tried to assign a value of <0 or >255 to PACC */
INTMODER:	EQU    54      ; /* interrupt or count mode error in ONPACC */
EETOSMAL:	EQU    55      ; /* program storage EEPROM is Too Small */

*/* mathematical operator tokens */
 
OPARNTOK:	EQU    $10     ; /* '(' */
CPARNTOK:	EQU    $11     ; /* ')' */
ANDTOK:	EQU    $20     ; /* 'AND' */
ORTOK:	EQU    $21     ; /* 'OR' */
EORTOK:	EQU    $22     ; /* 'EOR' */
LTTOK:	EQU    $30     ; /* '<' */
GTTOK:	EQU    $31     ; /* '> */
LTEQTOK:	EQU    $32     ; /* '<=' */
GTEQTOK:	EQU    $33     ; /* '>=' */
EQTOK:	EQU    $34     ; /* '=' */
NOTEQTOK:	EQU    $35     ; /* '<>' */
PLUSTOK:	EQU    $40     ; /* '+' */
MINUSTOK:	EQU    $41     ; /* '-' */
SPLUSTOK:	EQU    $42     ; /* '+' */
MULTTOK:	EQU    $50     ; /* '*' */
DIVTOK:	EQU    $51     ; /* '/' */
MODTOK:	EQU    $52     ; /* '%' */
PWRTOK:	EQU    $60     ; /* '^' */
INDIRTOK:	EQU    $70     ; /* '@' */
NOTTOK:	EQU    $71     ; /* 'NOT' */
NEGTOK:	EQU    $72     ; /* '-' (uniary minus) */
 
*/* keyword tokens */
 
LETTOK:	EQU    $01     ; /* LET */
IMLETTOK:	EQU    $02     ; /* implied LET */
PRINTTOK:	EQU    $03     ; /* PRINT */
FORTOK:	EQU    $04     ; /* FOR */
NEXTTOK:	EQU    $05     ; /* NEXT */
TRONTOK:	EQU    $06     ; /* TRON */
TROFFTOK:	EQU    $07     ; /* TROFF */
POKETOK:	EQU    $08     ; /* POKE */
DIMTOK:	EQU    $09     ; /* DIM */
REMTOK:	EQU    $0A     ; /* REM */
PACCTOK:	EQU    $0B     ; /* PACC */
DATATOK:	EQU    $0C     ; /* DATA */
READTOK:	EQU    $0D     ; /* READ */
RESTRTOK:	EQU    $0E     ; /* RESTORE */
GOSUBTOK:	EQU    $0F     ; /* GOSUB */
GOTOTOK:	EQU    $12     ; /* GOTO */
ONTOK:	EQU    $13     ; /* ON */
RETNTOK:	EQU    $14     ; /* RETURN */
IFTOK:	EQU    $15     ; /* IF */
INPUTTOK:	EQU    $16     ; /* INPUT */
STOPTOK:	EQU    $17     ; /* STOP */
ENDTOK:	EQU    $18     ; /* END */
WHILETOK:	EQU    $19     ; /* WHILE */
ENDWHTOK:	EQU    $1A     ; /* ENDWH */
EEPTOK:	EQU    $1B     ; /* EEP */
PORTATOK:	EQU    $1C     ; /* PORTA */
PORTBTOK:	EQU    $1D     ; /* PORTB */
PORTCTOK:	EQU    $1E     ; /* PORTC */
PORTDTOK:	EQU    $1F     ; /* PORTD */
INBYTTOK:	EQU    $23     ; /* INBYTE */
TIMETOK:	EQU    $24     ; /* TIME */
ONTIMTOK:	EQU    $25     ; /* ONTIME */
ONIRQTOK:	EQU    $26     ; /* ONIRQ */
RETITOK:	EQU    $27     ; /* RETI */
ONPACTOK:	EQU    $28     ; /* ONPACC */
SLEEPTOK:	EQU    $29     ; /* SLEEP */
RTIMETOK:	EQU    $2A     ; /* RTIME */
FUNCTFLG:	EQU    $36     ; /* function flag byte */
TOTOK:	EQU    $37     ; /* TO */
THENTOK:	EQU    $38     ; /* THEN */
ELSETOK:	EQU    $39     ; /* ELSE */
STEPTOK:	EQU    $3A     ; /* STEP */
 
*/* function tokens */
 
FDIVTOK:	EQU    $01     ; /* FDIV */
CHRTOK:	EQU    $02     ; /* CHR$ */
ADCTOK:	EQU    $03     ; /* ADC */
ABSTOK:	EQU    $04     ; /* ABS */
RNDTOK:	EQU    $05     ; /* RND */
SGNTOK:	EQU    $06     ; /* SGN */
TABTOK:	EQU    $07     ; /* TAB */
CALLTOK:	EQU    $08     ; /* CALL */
PEEKTOK:	EQU    $09     ; /* PEEK */
FEEPTOK:	EQU    $0A     ; /* EEP */
HEXTOK:	EQU    $0B     ; /* HEX */
FPRTATOK:	EQU    $0C     ; /* PORTA */
FPRTBTOK:	EQU    $0D     ; /* PORTB */
FPRTCTOK:	EQU    $0E     ; /* PORTC */
FPRTDTOK:	EQU    $0F     ; /* PORTD */
FPRTETOK:	EQU    $10     ; /* PORTE */
FTIMETOK:	EQU    $11     ; /* TIME */
HEX2TOK:	EQU    $12     ; /* HEX2 */
FPACCTOK:	EQU    $13     ; /* PACC */

*/* numerical/variable tokens */
 
FVARTOK:	EQU    $81     ; /* floating point variable address */
SVARTOK:	EQU    $82     ; /* string variable address */
IVARTOK:	EQU    $84     ; /* integer variable address */
 
FAVARTOK:	EQU    $91     ; /* floating point array */
SAVARTOK:	EQU    $92     ; /* string array */
IAVARTOK:	EQU    $94     ; /* integer array */
 
FCONTOK:	EQU    $A1     ; /* floating point constant */
SCONTOK:	EQU    $A2     ; /* string constant */
LCONTOK:	EQU    $A8     ; /* line # constant */
ICONTOK:	EQU    $A4     ; /* integer constant */
 
ISIZ:	EQU    2       ; /* number of bytes in integer variable */
SSIZ:	EQU    3       ; /* number of bytes in string variable */
FSIZ:	EQU    5       ; /* number of bytes in f.p. variable */
ASIZ:	EQU    2       ; /* number of bytes for array variable in dictionary */
*/* misc. tokens */
 
MSCNTOK:	EQU    $7F     ; /* multiple space count token */
SSCNTOK:	EQU    $7E     ; /* single space token */
EOLTOK:	EQU    $7D     ; /* end of line token */
COMMATOK:	EQU    $7C     ; /* , */
SEMITOK:	EQU    $7B     ; /* ; */
MEOLTOK:	EQU    $7A     ; /* : */
EQUALTOK:	EQU    $79     ; /* '=' */
PNUMTOK:	EQU    $78     ; /* '#' */
*
*
JMPOP:	EQU    $7E     ; OP-CODE FOR "JMP" (USED TO INITALIZE INTERRUPT TABLE)
 
*         /*********** define variables ***********/
 
         ORG    $0000
*
*               char
*
IBUFPTR:	RMB    2        ; /* input buffer pointer */
TBUFPTR:	RMB    2        ; /* token buffer pointer */
*
*	the next 5 variables must remain grouped togeather
*
BASBEG:	RMB    2        ; /* start of basic program area */
BASEND:	RMB    2        ; /* end of basic program */
VARBEGIN:	RMB    2        ; /* start of variable storage area */
VAREND:	RMB    2        ; /* end of variable storage area */
HILINE:	RMB    2        ; /* highest line number in program buffer */
*
*
*
BASMEND:	RMB    2        ; /* physical end of basic program memory */
VARMEND:	RMB    2        ; /* physical end of variable memory */
*
*               int
*
FIRSTLIN:	RMB    2        ; /* first line to list */
LASTLIN:	RMB    2        ; /* last line to list */
INTPTR:	RMB    2        ; /* integer pointer */
*
*               short
*
ERRCODE:	RMB    1        ; /* error code status byte */
IMMID:	RMB    1        ; /* immidiate mode flag */
BREAKCNT:	EQU    *        ; /* also use for break check count */
COUNT:	EQU    *        ; /* count used in ESAVE & ELOAD routines */
IFWHFLAG:	RMB    1        ; /* translating IF flag */
TRFLAG:	RMB    1        ; /* trace mode flag */
CONTFLAG:	RMB    1        ; /* continue flag */
RUNFLAG:	RMB    1        ; /* indicates we are in the run mode */
PRINTPOS:	RMB    1        ; /* current print position */
NUMSTACK:	RMB    2        ; /* numeric operand stack pointer */
OPSTACK:	RMB    2        ; /* operator stack pointer */
FORSTACK:	RMB    2        ; /* FOR stack pointer */
WHSTACK:	RMB    2        ; /* WHILE stack pointer */
GOSTACK:	RMB    2        ; /* GOSUB stack pointer */
CURLINE:	RMB    2        ; /* line # that we are currently interpreting */
ADRNXLIN:	RMB    2        ; /* address of the next line */
STRASTG:	RMB    2        ; /* dynamic string/array pool pointer */
FENCE:	RMB    2        ; /* varend fence in case of an error in xlation */
IPSAVE:	RMB    2        ; /* interpretive pointer save for "BREAK" */
DATAPTR:	RMB    2        ; /* pointer to data for read statement */
RANDOM:	RMB    2        ; /* random number/seed */
DEVNUM:	RMB    1        ; /* I/O device number */
TIMEREG:	RMB    2        ; /* TIME register */
TIMECMP:	RMB    2        ; /* TIME compare register */
TIMEPRE:	RMB    1        ; /* software prescaler for TIME */
ONTIMLIN:	RMB    2        ; /* ONTIME line number to goto */
ONIRQLIN:	RMB    2        ; /* ONIRQ line number to goto */
ONPACLIN:	RMB    2        ; /* ONPACC line number to goto */
XONCH:	RMB    1        ; /* XON character for printer */
XOFFCH:	RMB    1        ; /* XOFF character for printer */
SCURLINE:	RMB    2        ; /* used to save CURLINE during int. processing */
SADRNXLN:	RMB    2        ; /* used to save ADRNXLIN during int. processing */
INBUFFS:	rmb    2        ; /* pointer to the start of the input buffer */
TKNBUFS:	rmb    2        ; /* pointer to the start of the token buffer */
*
EOPSTK:	RMB    2        ; /* end of operator stack */
STOPS:	RMB    2        ; /* start of operator stack */
ENUMSTK:	RMB    2        ; /* end of operand stack */
STNUMS:	RMB    2        ; /* start of operand stack */
EFORSTK:	RMB    2        ; /* end of FOR - NEXT stack */
STFORSTK:	RMB    2        ; /* start of FOR - NEXT stack */
EWHSTK:	RMB    2        ; /* end of WHILE stack */
STWHSTK:	RMB    2        ; /* start of WHILE stack */
EGOSTK:	RMB    2        ; /* end of GOSUB stack */
STGOSTK:	RMB    2        ; /* start of GOSUB stack */
IOBaseV:	RMB    2        ; /* Address vector for I/O Registers */
DNAME:	RMB    3        ; /* Place to put the variable name when doing a dump command */
SUBMAX:   RMB    2        ; /*  */
SUBCNT:	RMB    2        ; /*  */
TOKPTR:	rmb    2        ; /* token pointer (used for list command) */
VarSize:	rmb    2        ; /* used by the line editor. size of the variable table */
*
*
         $if     * > $9E
         #fatal   "Ran out of Page 0 RAM"
         $endif
*
*
*
         ORG    $009E
*
CONSTAT:	RMB    3        ; GET CONSOLE STATUS FOR BREAK ROUTINE.
INCONNE:	RMB    3        ; GET BYTE DIRECTLY FROM CONSOLE FOR BREAK ROUTINE.
*
         ORG    $00A4
*
INTABLE:	RMB    16       ; RESERVE SPACE FOR 8 DIFFERENT INPUT ROUTINES.
OUTABLE:	RMB    16       ; RESERVE SPACE FOR 8 DIFFERENT OUTPUT ROUTINES.
*
*
*
*
         ORG    $00C4    ; START OF RAM INTERRUPT VECTORS.
*
RAMVECTS:	EQU    *
SCISS:	RMB    3        ; SCI SERIAL SYSTEM.
SPITC:	RMB    3        ; SPI TRANSFER COMPLETE.
PACCIE:	RMB    3        ; PULSE ACCUMULATOR INPUT EDGE.
PACCOVF:	RMB    3        ; PULSE ACCUMULATOR OVERFLOW.
TIMEROVF:	RMB    3        ; TIMER OVERFLOW.
TOC5:	RMB    3        ; TIMER OUTPUT COMPARE 5.
TOC4:	RMB    3        ; TIMER OUTPUT COMPARE 4.
TOC3:	RMB    3        ; TIMER OUTPUT COMPARE 3.
TOC2:	RMB    3        ; TIMER OUTPUT COMPARE 2.
TOC1:	RMB    3        ; TIMER OUTPUT COMPARE 1.
TIC3:	RMB    3        ; TIMER INPUT CAPTURE 3.
TIC2:	RMB    3        ; TIMER INPUT CAPTURE 2.
TIC1:	RMB    3        ; TIMER INPUT CAPTURE 1.
REALTIMI:	RMB    3        ; REAL TIME INTERRUPT.
IRQI:	RMB    3        ; IRQ INTERRUPT.
XIRQ:	RMB    3        ; XIRQ INTERRUPT.
SWII:	RMB    3        ; SOFTWARE INTERRUPT.
ILLOP:	RMB    3        ; ILLEGAL OPCODE TRAP.
COP:	RMB    3        ; WATCH DOG TIMER FAIL.
CMF:	RMB    3        ; CLOCK MONITOR FAIL.
*
*
