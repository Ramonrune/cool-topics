*       title   Inits.Asm
*
*
*/***** initvars() *****/
*
*initvars()
*{
* char *x;
* varbegin=varend=0x7000;
* varmend=0x7FFF;
* for(x=varbegin; x<=varmend; x++) *x=0;
* basbeg=basend=0x4000;
* basmend=0x6FFF;
* for(x=basbeg; x<=basmend; x++) *x=0;
* hiline=0;
* return;
*}
*
*
INITVARS:	EQU    *
	LDX    RAMStart     ; YES. VARIABLES START AT RAMBEG.
	STX    VARBEGIN     ; SET POINTERS TO BOTH START AND END OF VARIABLE
	STX    VAREND       ; STORAGE.
	STX    BASBEG       ; SET POINTERS TO BOTH THE START AND END OF THE
	STX    BASEND       ; BASIC PROGRAM.
	XGDX		; GET THE START OF RAM INTO D
	ADDD   RAMSize	; add the size of the RAM to it.
	SUBD   #SWSTKSize+1	; subtract the size of the software stack, token & input buffers.
	STD    VARMEND      ; SAVE THE POINTER.
	STD    BASMEND      ; MAKE IT THE END OF BASIC PROGRAM MEMORY.
	addd   #1		; Set up a pointer to the input buffer.
	std    INBUFFS	; Save the pointer.
	addd   #IBUFLEN     ; add the length of the input buffer to create a pointer to the token buffer.
	std    TKNBUFS	; save the pointer.
	addd   #TBUFLEN     ; add the length of the token buffer to create a pointer to the end of the operand stack.
	std    EOPSTK       ; save the pointer to the end of the operator stack.
	addd   #OPSLEN	; add the length of the operand stack.
	std    STOPS	; save the pointer to the start of the operator stack.
	std    ENUMSTK	; also make it the end of the operand stack.
	addd   #NUMSLEN     ; add the length of the operand stack.
	std    STNUMS	; save the result as the start of the operand stack.
	std    EFORSTK	; also make it the end of the FOR stack.
	addd   #FORSLEN     ; Add the length of the FOR stack.
	std    STFORSTK     ; save the result as the start of the FOR stack.
	std    EWHSTK	; also make it the end of the while stack.
	addd   #WHSLEN	; add the length of the while stack.
	std    STWHSTK	; save the pointer as the start of the while stack.
	std    EGOSTK	; also make it the end of the GOSUB stack.
	addd   #GOSLEN	; add the length of the GOSUB stack.
	std    STGOSTK	; save it as the start of the GOSUB stack.
	LDX    BASBEG	; point to the start of the basic program buffer.
INIT1:	CLR    0,X          ; CLEAR THE STORAGE TO ZERO.
	INX                 ; POINT TO THE NEXT LOCATION.
	CPX    BASMEND      ; ARE WE DONE?
	BLS    INIT1        ; NO. KEEP CLEARING.
*                             ; YES. POINT TO THE PHYSICAL END OF MEMORY.
	ldx    EEStart
	LDAA   AUTOSTF,X    ; GET THE AUTO START FLAG AGAIN.
	CMPA   #$55         ; IS THE AUTO START MODE SET?
	BNE    INIT5        ; NO. DO A NORMAL INIT.
*
	JSR    AUTOLOAD     ; GO LOAD the program and VARIABLES INTO RAM.
INIT5:	LDD    #0           ; MAKE THE HIGHEST LINE IN THE PROGRAM 0.
	STD    HILINE
	STD    CURLINE      ; MAKE THE CURRENT LINE #0.
	JSR    RUNINIT      ; GO INITALIZE ALL THE SOFTWARE STACKS.
	CLR    TRFLAG       ; TURN THE TRACE MODE OFF.
	LDAA   #1           ; "CONT" COMMAND NOT ALLOWED.
	STAA   CONTFLAG
;JKJ : Not present!
;        LDX    DFLOPADR     ; point to the D-Flip flop address.
;        STAA   0,X          ; CONNECT SCI RX PIN TO THE HOST CONNECTOR.
	CLR    DEVNUM       ; MAKE THE DEFAULT DEVICE NUMBER 0 (CONSOLE).
	clr    IMMID        ; clear the immediate mode flag (added 9/17/90).
	LDX    VAREND	; GET THE POINTER TO THE END OF VARIABLE STORAGE.
	INX		; BUMP IT BY 1.
	STX    STRASTG	; POINT TO THE DYNAMIC ARRAY STORAGE.
	RTS                 ; RETURN.
*
*
*
POWERUP:	EQU    *
	LDD    IOBASE	; GET THE BASE ADDRESS OF THE I/O REGISTERS.
	STD    IOBaseV
	LSRA
	LSRA
	LSRA
	LSRA
	STAA   $103D	; remap the I/0 regs to where the user wants them.
	LDX    IOBaseV      ; point to the I/O Register Base.
	LDAA   #$93         ; TURN ON A/D, USE E CLOCK, SET IRQ LEVEL SENSITIVE
	STAA   OPTION,X     ; DELAY AFTER STOP, DISABLE CLOCK MONITOR, SET COP
*                             ; TIMMER PREIOD TO MAX.
	LDAA   #$03         ; SET THE TIMER PRESCALER TO /16.
	STAA   TMSK2,X
*
	LDD    RAMStart	; Get start of RAM.
	ADDD   RAMSize	; Add the size of the RAM to it.
	XGDX		; Put the calculated address into X.
	TXS		; Transfer the address to the stack pointer.
*
	LDX    #RAMVECTS    ; POINT TO THE RAM INTERRUPT VECTOR TABLE.
	LDY    #RETII       ; GET ADDRESS OF RTI INSTRUCTION.
	LDAB   #20          ; PUT THE "JMP" OPCODE INTO ALL VECTOR LOCATIONS.
	LDAA   #JMPOP       ; GET THE JMP OPCODE.
POWERUP1:	STAA   0,X          ; STORE IT.
	INX                 ; POINT TO THE NEXT VECTOR.
	STY    0,X          ; INITALIZE VECTOR TO "RTI".
	INX
	INX
	DECB                ; DONE?
	BNE    POWERUP1     ; NO. INITALIZE ALL VECTORS.
	LDX    #ILLOP       ; POINT TO THE ILLEGAL OP-CODE VECTOR.
	LDD    #POWERUP     ; GET THE ADDRESS OF THE POWER UP VECTOR.
	STD    1,X          ; INITALIZE ILLEGAL OP-CODE VECTOR.
	STD    4,X          ; INITALIZE WATCH DOG FAIL VECTOR.
	STD    7,X          ; INITALIZE CLOCK MONITOR FAIL VECTOR.
*
*
*
	LDX    #INTABLE     ; POINT TO THE START OF THE I/O VECTOR TABLE.
	LDY    #IOVects     ; point to the default table in ROM.
	LDAB   #32          ; GET NUMBER OF BYTES IN THE TABLE.
POWERUP2:	ldaa   0,Y          ; Move a byte of the table from ROM into RAM.
	staa   0,X
	INX                 ; POINT TO THE NEXT BYTE.
	INY
	DECB                ; DECREMENT THE COUNT.
	BNE    POWERUP2     ; GO TILL WE'RE DONE.
*
*
	LDX    #TIMEINT     ; GET THE ADDRESS OF THE OUTPUT COMPARE 1 ROUTINE.
	STX    TOC1+1       ; PUT IT IN THE INTERRUPT VECTOR.
	LDAA   #SWPRE+1     ; ADD 1 TO NORMAL PRE SCALER.
	STAA   TIMEPRE      ; SET UP THE SOFTWARE PRESCALER.
	clra
	clrb
	std    TIMEREG      ; ZERO THE TIME REGISTER.
	std    TIMECMP      ; zero the time compare register.
	LDX    IOBaseV
	BSR    TIMINTS      ; GO SETUP THE TIMER FOR THE FIRST INTERRUPT.
	LDAA   #$80         ; ENABLE INTERRUPTS FROM OC1.
	STAA   TMSK1,X
	 
	LDX    #IRQINT     ; GET THE ADDRESS OF THE IRQ SERVICE ROUTINE.
	STX    IRQI+1      ; PUT IT IN THE IRQ VECTOR.
	LDX    #PACCINT    ; GET THE ADDRESS OF THE PACC INT ROUTINE.
	STX    PACCIE+1    ; SET ADDRESS IN INPUT EDGE INTERRUPT VECTOR.
	STX    PACCOVF+1   ; SET ADDRESS IN PACC OVERFLOW INTERRUPT VECTOR.
	CLRA
	CLRB
	STD    ONTIMLIN    ; INITALIZE THE LINE POINTERS.
	STD    ONIRQLIN
	STD    ONPACLIN
*
*
*
	LDX    UserInit
	JSR    0,X	; INITALIZE THE ACIA & SCI.
	JMP    MAIN         ; GO TO BASIC.
*
*
*
TIMEINT:	BSR    TIMINTS
RETII:	RTI                 ; RETURN FROM ALL INTERRUPT SOURCES.
*
*
TIMINTS:	LDX    IOBaseV	; Point to the I/O Base Address.
	LDD    TOC1REG,X    ; GET THE VALUE OF THE TIMER/COUNTER.
TIMINTS3:	ADDD   TimeVal      ; ADD IN 62500 FOR NEXT COMPARE ( 2 HZ INT.).
	STD    TOC1REG,X    ; PUT IT IN THE OUTPUT COMPARE REGISTER.
	LDAA   #$80         ; SETUP TO CLEAR THE OC1 FLAG.
	STAA   TFLAG1,X
	DEC    TIMEPRE      ; HAVE TWO OUTPUT COMPARES OCCURED?
	BNE    TIMINTS1     ; NO. JUST RETURN.
	LDAA   #SWPRE       ; YES. RELOAD THE REGISTER.
	STAA   TIMEPRE
	LDD    TIMEREG      ; GET THE CURRENT VALUE OF "TIME".
	ADDD   #1           ; ADD 1 SECOND TO THE COUNT.
	STD    TIMEREG      ; UPDATE THE TIME REGISTER.
	LDD    TIMECMP      ; GET THE VALUE TO COMPARE TO FOR "ONTIME".
	BEQ    TIMINTS1     ; IF IT'S 0, THE "ONTIME" FUNCTION IS OFF.
	CPD    TIMEREG      ; DOES THE COMPARE VALUE MATCH THE TIME REGISTER?
	BNE    TIMINTS1     ; NO. JUST RETURN.
	LDY    ONTIMLIN     ; MAKE THE POINTER TO THE LINE NUMBER THE NEW IP.
	INS                 ; GET RID OF THE RETURN ADDRESS.
	INS
TIMINTS2:	INC    IMMID        ; FAKE THE GOTO ROUTINE OUT.
	LDD    CURLINE      ; SAVE THE CURRENT LINE NUMBER IN MAIN PROGRAM.
	STD    SCURLINE
	LDD    ADRNXLIN     ; SAVE THE ADDRESS OF THE NEXT LINE IN MAIN PROG.
	STD    SADRNXLN
	JMP    RGOTO3       ; GOTO THE SERVICE ROUTINE.
TIMINTS1:	RTS                 ; RETURN.
*
*
*
IRQINT:	EQU    *
	LDY    ONIRQLIN     ; GET POINTER TO LINE NUMBER OF THE IRQ SERVICE.
	BNE    TIMINTS2     ; GO DO IT.
	RTI                 ; IF IT'S 0, "ONIRQ" HAS NOT BEEN EXECUTED.
*
*
PACCINT:	EQU    *
	LDX    IOBaseV
	LDAA   #$30         ; RESET BOTH THE TIMER OVERFLOW & INPUT FLAG.
	STAA   TFLG2,X
	LDY    ONPACLIN     ; GET POINTER TO LINE NUMBER OF THE SERVICE ROUT.
	BNE    TIMINTS2
	RTI
*
*
