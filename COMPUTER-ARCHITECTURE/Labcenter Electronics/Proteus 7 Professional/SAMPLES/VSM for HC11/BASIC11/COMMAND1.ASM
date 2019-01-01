*        title    COMMAND1
*        page
*/***** chckcmds() *****/
*
*chckcmds()
*{
* if(match("LIST")) clist();
* else if(match("RUN")) crun();
* else if(match("NEW")) cnew();
* else if(match("CONT")) ccont();
* else if(match("CLEAR")) cclear();
* else return(0);
* return(1);
*}
*
*
CHCKCMDS:	EQU    *
	JSR    GETCHR        ; GET FIRST CHAR FROM THE INPUT BUFFER.
	CMPA   #EOL          ; IS IT AN EOL?
	BNE    CHKCMDS1      ; NO. GO CHECK FOR COMMANDS.
CHKCMDS5:	LDD    #0            ; YES. JUST RETURN.
	RTS
CHKCMDS1:	LDX    #CMDTBL       ; POINT TO COMMAND TABLE.
CHKCMDS2:	JSR    STREQ         ; GO CHECK FOR A COMMAND.
	BCS    CHKCMDS3      ; IF WE FOUND ONE GO EXECUTE IT.
CHKCMDS4:	INX                  ; ADVANCE POINTER TO NEXT CHAR IN TABLE ENTRY.
	LDAA   0,X           ; GET THE CHAR. ARE WE AT THE END OF THIS ENTRY?
	BNE    CHKCMDS4      ; NO. KEEP GOING TILL WE ARE PAST IT.
	INX                  ; BYPASS END OF COMMAND MARKER & EXECUTION ADDR.
	INX
	INX
	TST    0,X           ; ARE WE AT THE END OF THE TABLE?
	BNE    CHKCMDS2      ; NO. GO CHECK THE NEXT TABLE ENTRY.
	BRA    CHKCMDS5      ; YES. RETURN W/ ENTRY NOT FOUND INDICATION.
CHKCMDS3:	LDX    1,X           ; GET ADDRESS OF COMMAND.
	JSR    0,X           ; GO DO IT.
	LDD    #1            ; SHOW WE EXECUTED A COMMAND.
	RTS                  ; RETURN.
*
*
CMDTBL:	EQU    *
	FCC    "LIST"
	FCB    0
	FDB    CLIST
	FCC    "RUN"
	FCB    0
	FDB    CRUN
	FCC    "NEW"
	FCB    0
	FDB    CNEW
	FCC    "CONT"
	FCB    0
	FDB    CCONT
	FCC    "CLEAR"
	FCB    0
	FDB    CCLEAR
	FCC    "ESAVE"
	FCB    0
	FDB    CESAVE
	FCC    "ELOAD"
	FCB    0
	FDB    CELOAD
	FCC    "LLIST"
	FCB    0
	FDB    CLLIST
	FCC    "AUTOST"
	FCB    0
	FDB    CAUTOST
	FCC    "NOAUTO"
	FCB    0
	FDB    CNOAUTO
	FCC	"FREE"
	FCB	0
	FDB	CFREE
	FCB    0             ;END OF TABLE MARKER.
	
	
*/***** clist() *****/
*
*clist()
*{
* int *intptr;
* char token;
* if(basbeg==basend) return;             /* if basic buffer empty, return */
* skipspcs();                    /* skip any spaces after "LIST" */
*
*
CLIST:	EQU    *
	JSR    NL2
	LDD    BASBEG
	CPD    BASEND
	BNE    CLIST1
	RTS
CLIST1:	JSR    SKIPSPCS
*
*
* if(numeric(getchr()))
* {
*  firstlin=getlinum();
*  if(getchr()=='-')
*  {
*   incibp();
*   lastlin=getlinum;
*  }
* }
* else
* {
*  intptr=basbeg;
*  lastlin=hiline;
*  firstlin=*intptr;
* }
* if(firstlin<lastlin) return;
* tokptr=intptr=findline(firstlin);
*
*
	JSR    GETCHR
	JSR    NUMERIC
	BCC    CLIST2
	JSR    GETLINUM
	STD    FIRSTLIN
	JSR    GETCHR
	CMPA   #'-'
	BEQ    CLIST3
	LDD    FIRSTLIN
	STD    LASTLIN
	CPD    HILINE
	BLS    CLIST4
	RTS
CLIST3:	JSR    INCIBP
	JSR    GETLINUM
	CPD    HILINE
	BLS    CLIST13
	LDD    HILINE
CLIST13:	STD    LASTLIN
	BRA    CLIST4
CLIST2:	CMPA   #EOL
	BEQ    CLIST14
	RTS
CLIST14:	LDX    BASBEG
	LDD    0,X
	STD    FIRSTLIN
	LDD    HILINE
	STD    LASTLIN
CLIST4:	LDD    FIRSTLIN
	CPD    LASTLIN
	BLS    CLIST5
	RTS
CLIST5:	LDD    FIRSTLIN
	JSR    FINDLINE
	STX    TOKPTR
	LDD    LASTLIN
	JSR    FINDLINE
	LDD    0,X
	CPD    LASTLIN
	BNE    CLIST12
	LDAB   2,X
	ABX
CLIST12:	STX    LASTLIN
*
*
*
* while(*intptr<lastlin)
* {
*  intptr=tokptr;
*  outdeci(*intptr);
*  tokptr+=3;
*  while(*tokptr!=EOLTOK)
*  {
*   token=gettok;
*   if(token>=0x80)
*   {
*    lvarcon();
*   }
*   else
*   {
*    lkeyword();
*   }
*  }
*  nl();
*  ++tokptr;
* }
* return;
*}
*
*
CLIST6:	LDD    TOKPTR
	CPD    LASTLIN
	BNE    CLIST7
	RTS
CLIST7:	LDX    TOKPTR
	LDD    0,X
	INX
	INX
	INX
	STX    TOKPTR
	JSR    OUTDECI
CLIST8:	LDX    TOKPTR
	LDAA   0,X
	CMPA   #EOLTOK
	BEQ    CLIST9
	TSTA
	BMI    CLIST10
	JSR    LKEYWORD
	BRA    CLIST8
CLIST10:	JSR    LVARCON
	BRA    CLIST8 
CLIST9:	JSR    NL
	LDX    TOKPTR
	INX
	STX    TOKPTR
	BRA    CLIST6
*
*
*/***** lvarcon() *****/
*
*lvarcon()
*{
* char tok;
* tok=gettok;
* if(tok<=0x88)
* {
*  if(tok==FVARTOK) lfvar();
*  else if(tok==SVARTOK) lsvar();
*  else if(tok==IVARTOK) livar();
*  else { errcode=ILTOKERR; return; }
* }
*
*
* else if(tok<=0xA8)
* {
*  if(tok==FCONTOK) lfcon();
*  else if(tok==SCONTOK) lscon();
*  else if(tok==LCONTOK) llcon();
*  else if(tok==ICONTOK) licon();
*  else { errcode=ILTOKERR; return; }
* }
* else { errcode=ILTOKERR; return; }
*}
*
LVARCON:	EQU    *
	LDX    TOKPTR
	LDAA   0,X
	ANDA   #$EF          ; MASK OFF ARRAY INDICATOR IF PRESENT.
	LDX    #VCTOKTBL
LVARCON1:	CMPA   0,X
	BEQ    LVARCON2
	INX
	INX
	INX
	TST    0,X
	BNE    LVARCON1
	LDAA   #ILTOKERR
	JMP    RPTERR
LVARCON2:	LDX    1,X
	JSR    0,X
	RTS
*
*
VCTOKTBL:	EQU    *
	FCB    IVARTOK
	FDB    LIVAR
	FCB    SCONTOK
	FDB    LSCON
	FCB    LCONTOK
	FDB    LLCON
	FCB    ICONTOK
	FDB    LICON
	FCB    0                     ; END OF TABLE MARKER.
*
*
*
*
*/***** livar() *****/
*
*livar()
*{
* lfvar();
* outbyte('%');
* return;
*}
*
*
LIVAR:	EQU    *
	LDX    TOKPTR
	INX
	LDD    0,X
	ADDD   VARBEGIN
	INX
	INX
	STX    TOKPTR
	XGDX
LIVAR2:	LDAA   1,X
	JSR    OUTBYTE
	LDAA   2,X
	BEQ    LIVAR1
	JSR    OUTBYTE
LIVAR1:	RTS
*
*
LFCON:	EQU    *
	LDD    TOKPTR
	ADDD   #FSIZ+1
LFCON2:	XGDX
	LDAB   0,X
	INX
LFCON1:	LDAA   0,X
	JSR    OUTBYTE
	INX
	DECB
	BNE    LFCON1
	STX    TOKPTR
	RTS
*
*
*/***** licon() *****/
*
*licon()
*{
* int count;
* tokptr=tokptr+ISIZ+1;
* count=*tokptr++;
* while(count--)
* {
*  outbyte(*tokptr++);
* }
* return;
*}
*
*
LICON:	EQU    *
	LDD    TOKPTR
	ADDD   #ISIZ+1
	BRA    LFCON2
*
*
*/***** lscon() *****/
*
*lscon()
*{
* int count;
* ++tokptr;
* count=*tokptr++;
* while(count--)
* {
*  outbyte(*tokptr++);
* }
* return;
*}
*
*
LSCON:	EQU    *
	LDD    TOKPTR
	ADDD   #1
	BRA    LFCON2
*
*
*/***** llcon *****/
*
*llcon()
*{
* int *intptr;
* intptr=++tokptr;
* tokptr+=2;
* outdeci(*intptr);
* return;
*}
*
*
LLCON:	EQU    *
	LDX    TOKPTR
	INX
	LDD    0,X
	INX
	INX
	STX    TOKPTR
	JSR    OUTDECI
	RTS
*
*
*/***** lkeyword *****/
*
*lkeyword()
*{
* char *charptr,token;
* token=*tokptr++
*
*
LKEYWORD:	EQU    *
	LDX    TOKPTR
	LDAA   0,X
	INX
	STX    TOKPTR
	CMPA   #MSCNTOK
	BNE    LKEYWRD3
	JMP    LMSPCS
LKEYWRD3:	CMPA   #REMTOK
	BNE    LKEYWRD4
	JMP    LREMLINE
LKEYWRD4:	CMPA   #DATATOK
	BNE    LKEYWRD5
	JMP    LDATALIN
LKEYWRD5:	CMPA   #FUNCTFLG
	BNE    LKEYWRD6
	LDX    TOKPTR
	LDAA   0,X
	INX
	STX    TOKPTR
	LDX    #LFUNCTBL
	BRA    LKEYWRD1
LKEYWRD6:	LDX    #TOKTBL
LKEYWRD1:	CMPA   0,X
	BEQ    LKEYWRD2
	INX
	INX
	INX
	TST    0,X
	BNE    LKEYWRD1
	LDAA   #ILTOKERR
	JMP    RPTERR
LKEYWRD2:	LDX    1,X
	JMP    PL
*
*
LMSPCS:	EQU    *
	LDX    TOKPTR
	LDAB   0,X
	INX
	STX    TOKPTR
	LDAA   #$20
LMSPCS1:	JSR    OUTBYTE
	DECB
	BNE    LMSPCS1
	RTS
*
*
LDATALIN:	EQU    *
	LDX    #DATA
	JSR    PL
	BRA    LREM3
*
*
LREMLINE:	EQU    *
	LDX    #REM
	JSR    PL
LREM3:	LDX    TOKPTR
	INX                 ; PUT POINTER PAST LENGTH BYTE.
LREM1:	LDAA   0,X
	CMPA   #EOL   
	BNE    LREM2
	INX
	STX    TOKPTR
	RTS
LREM2:	JSR    OUTBYTE
	INX
	BRA    LREM1
*
*
TOKTBL:	EQU     *
	FCB     LETTOK
	FDB     LET
	FCB     READTOK
	FDB     READ
	FCB     RESTRTOK
	FDB     RESTORE
	FCB     GOSUBTOK
	FDB     GOSUB
	FCB     GOTOTOK
	FDB     GOTO
	FCB     ONTOK
	FDB     ON
	FCB     RETNTOK
	FDB     RETURN
	FCB     IFTOK
	FDB     IIF
	FCB     THENTOK
	FDB     THENS
	FCB     ELSETOK
	FDB     ELSES
	FCB     INPUTTOK
	FDB     INPUT
	FCB     PRINTTOK
	FDB     PRINT
	FCB     FORTOK
	FDB     FOR
	FCB     NEXTTOK
	FDB     NEXT
	FCB     STOPTOK
	FDB     STOPSS
	FCB     ENDTOK
	FDB     ENDS
	FCB     TRONTOK
	FDB     TRON
	FCB     TROFFTOK
	FDB     TROFF
	FCB     WHILETOK
	FDB     WHILE
	FCB     ENDWHTOK
	FDB     ENDWH
	FCB     STEPTOK
	FDB     STEP
	FCB     TOTOK
	FDB     TO
	FCB     COMMATOK
	FDB     COMMAC
	FCB     SEMITOK
	FDB     SEMIC
	FCB     MEOLTOK
	FDB     COLLINC
	FCB     IMLETTOK
	FDB     IMLET
	FCB     POKETOK
	FDB     POKE
	FCB     EQUALTOK
	FDB     EQ
	FCB     OPARNTOK
	FDB     OPARN
	FCB     CPARNTOK
	FDB     CPARN
	FCB     ANDTOK
	FDB     ANDS
	FCB     ORTOK
	FDB     ORS
	FCB     EORTOK
	FDB     EORS
	FCB     LTTOK
	FDB     LT
	FCB     GTTOK
	FDB     GT
	FCB     LTEQTOK
	FDB     LTEQ
	FCB     GTEQTOK
	FDB     GTEQ
	FCB     EQTOK
	FDB     EQ
	FCB     NOTEQTOK
	FDB     NOTEQ
	FCB     PLUSTOK
	FDB     PLUS
	FCB     MINUSTOK
	FDB     MINUS
	FCB     MULTTOK
	FDB     MULT
	FCB     DIVTOK
	FDB     DIV
	FCB     MODTOK
	FDB     MODS
	FCB     NOTTOK
	FDB     NOTS
	FCB     RTIMETOK
	FDB     RTIMES
	FCB     NEGTOK
	FDB     NEGS
	FCB     SSCNTOK
	FDB     SPACE
	FCB     DIMTOK
	FDB     DIM
	FCB     EEPTOK
	FDB     EEP
	FCB     PORTATOK
	FDB     PORTA
	FCB     PORTBTOK
	FDB     PORTB
	FCB     PORTCTOK
	FDB     PORTC
	FCB     PORTDTOK
	FDB     PORTD
	FCB     PNUMTOK
	FDB     POUNDSGN
	FCB     INBYTTOK
	FDB     INBYTES
	FCB     TIMETOK
	FDB     TIME
	FCB     ONTIMTOK
	FDB     ONTIME
	FCB     ONIRQTOK
	FDB     ONIRQ
	FCB     RETITOK
	FDB     RETI
	FCB     PACCTOK
	FDB     PACC
	FCB     ONPACTOK
	FDB     ONPACC
	FCB     SLEEPTOK
	FDB     SLEEP
	FCB     0            ; END OF TABLE MARKER.
*
*
LFUNCTBL:	EQU    *
	FCB    FDIVTOK
	FDB    FDIVS
	FCB    CHRTOK
	FDB    CHRS
	FCB    ADCTOK
	FDB    ADCS
	FCB    ABSTOK
	FDB    ABS
	FCB    RNDTOK
	FDB    RND
	FCB    SGNTOK
	FDB    SGN
	FCB    TABTOK
	FDB    TABS
	FCB    CALLTOK
	FDB    CALL
	FCB    PEEKTOK
	FDB    PEEK
	FCB    FEEPTOK
	FDB    EEP
	FCB    HEXTOK
	FDB    HEX
	FCB    FPRTATOK
	FDB    PORTA
	FCB    FPRTBTOK
	FDB    PORTB
	FCB    FPRTCTOK
	FDB    PORTC
	FCB    FPRTDTOK
	FDB    PORTD
	FCB    FPRTETOK
	FDB    PORTE
	FCB    FTIMETOK
	FDB    TIME
	FCB    HEX2TOK
	FDB    HEX2
	FCB    FPACCTOK
	FDB    PACC
IMLET:	FCB    0            ;  NO KETWORD TO PRINT FOR AN IMPLIED LET.
COLLINC:	FCC    ":"
	FCB    0
SEMIC:	FCC    ";"
	FCB    0
COMMAC:	FCC    ","
	FCB    0
OPARN:	FCC    "("
	FCB    0
CPARN:	FCC    ")"
	FCB    0
SPACE:	FCC    " "
	FCB    0
PORTE:	FCC    "PORTE"
	FCB    0
POUNDSGN:	FCC    "#"
	FCB    0
*
*
CRUN:	EQU    *
	JSR    NL2          ; DO 2 CR/LF SEQUENCES.
	JSR    RUNINIT      ; INITALIZE RUNTIME VARIABLES.
	LDAA   #1           ; SET THE RUN MODE FLAG.
	STAA   RUNFLAG
*
*        END OF POINTER INITIALIZATIONS
*
	LDY    BASBEG       ; POINT TO THE START OF THE PROGRAM.
	CPY    BASEND       ; IS THERE A PROGRAM IN MEMORY?
	BNE    CRUN5        ; YES. GO RUN IT.
	RTS                 ; NO. RETURN.
*
CRUN5:	LDD    0,Y          ; GET NUMBER OF FIRST/NEXT LINE OF BASIC PROGRAM.
	STD    CURLINE      ; MAKE IT THE CURRENT LINE.
	TST    TRFLAG       ; IS THE TRACE MODE TURNED ON?
	BEQ    CRUN6        ; NO. CONTINUE.
	LDAA   #'['         ; YES. PRINT THE CURRENT LINE.
	JSR    OUTBYTE
	LDD    CURLINE
	JSR    OUTDECI
	LDAA   #']'
	JSR    OUTBYTE
	JSR    NL
CRUN6:	PSHY                ; SAVE POINTER TO START OF NEW LINE.
	LDAB   2,Y          ; GET LENGTH OF LINE.
	ABY                 ; POINT TO START OF NEXT LINE.
	STY    ADRNXLIN     ; SAVE THE ADDRESS OF THE NEXT LINE.
	PULY
	LDAB   #3           ; BYTE COUNT OF LINE NUMBER & LENGTH.
	ABY                 ; POINT TO THE FIRST TOKEN.
CRUN4:	BSR    RSKIPSPC     ; SKIP SPACES IF PRESENT.
	LDAB   0,Y          ; GET KEYWORD TOKEN.
	INY                 ; POINT PAST THE KEYWORD.
	BSR    RSKIPSPC     ; SKIP SPACES AFTER KEYWORD.
	DECB                ; SUBTRACT ONE FOR INDEXING.
	LSLB                ; MULTIPLY BY THE # OF BYTES PER ADDRESS.
	LDX    #RKEYWORD    ; POINT TO RUN TIME ADDRESS TABLE.
	ABX                 ; POINT TO ADDRESS
	LDX    0,X          ; POINT TO RUNTIME ROUTINE.
	JSR    0,X          ; GO DO IT.
*
*
CRUN2:	DEC    BREAKCNT     ; SHOULD WE CHECK FOR A BREAK YET?
	BNE    CRUN7        ; NO. CONTINUE.
	JSR    CHCKBRK      ; CHECK FOR BREAK FROM CONSOLE.
*
CRUN7:	BSR    RSKIPSPC     ; SKIP ANY SPACES.
	LDAA   0,Y          ; GET THE NEXT TOKEN IN THE LINE.
	CMPA   #EOLTOK      ; ARE WE AT THE END OF THE LINE?
	BNE    CRUN3
	INY                 ; YES. POINT TO START OF THE NEXT LINE.
CRUN1:	CPY    BASEND       ; HAVE WE REACHED THE END OF THE BASIC PROGRAM?
	BNE    CRUN5        ; NO. GO EXECUTE THE NEXT LINE.
	JMP    REND         ; GO DO  AN "END".
CRUN3:	INY                 ; MUST BE A MID EOL.
	BRA    CRUN4        ; GO DO NEXT KEYWORD.
*
*
*
RSKIPSPC:	LDAA   0,Y          ; GET A CHARACTER.
	BMI    RSKIP2
	CMPA   #SSCNTOK     ; IS IT A SINGLE SPACE?
	BEQ    RSKIP1       ; YES. BUMP IP BY 1.
	BLO    RSKIP2
	INY                 ; BUMP IP BY 2 FOR MULTIPLE SPACES.
RSKIP1:	INY                 ; BUMP IP.
RSKIP2:	RTS                 ; RETURN.
*
*
RKEYWORD:	EQU    *
	FDB    RLET
	FDB    RLET
	FDB    RPRINT
	FDB    RFOR
	FDB    RNEXT
	FDB    RTRON
	FDB    RTROFF
	FDB    RPOKE
	FDB    RDIM
	FDB    RREM
	FDB    RPACC
	FDB    RDATA
	FDB    RREAD
	FDB    RRESTOR
	FDB    RGOSUB
	FDB    0
	FDB    0
	FDB    RGOTO
	FDB    RON
	FDB    RRETURN
	FDB    RIF
	FDB    RINPUT
	FDB    RSTOP
	FDB    REND
	FDB    RWHILE
	FDB    RENDWH
	FDB    REEP
	FDB    RPORTA
	FDB    RPORTB
	FDB    RPORTC
	FDB    RPORTD
	FDB    0
	FDB    0
	FDB    0
	FDB    RINBYTE
	FDB    RTIME
	FDB    RONTIME
	FDB    RONIRQ
	FDB    RRETI
	FDB    RONPACC
	FDB    RSLEEP
	FDB    RRTIME
*
*
RUNLINE:	JSR    NL2
	LDY    TKNBUFS      ; POINT TO THE TOKEN BUFFER.
	LDD    0,Y          ; GET CURRENT LINE NUMBER.
	STD    CURLINE      ; MAKE "0" THE CURRENT LINE #.
	LDAB   #3           ; POINT PAST THE LINE NUMBER & LENGTH.
	ABY
RUNLINE2:	BSR    RSKIPSPC     ; SKIP SPACES.
	LDAB   0,Y          ; GET KEYWORD.
	INY                 ; POINT PAST KEYWORD.
	BSR    RSKIPSPC     ; SKIP SPACES.
	DECB                ; SUBTRACT ONE FOR INDEXING.
	LSLB                ; MULT BY THE # OF BYTES/ADDRESS.
	LDX    #RKEYWORD    ; POINT TO ADDRESS TABLE.
	ABX                 ; POINT TO ADDRESS OF RUN TIME ROUTINE.
	LDX    0,X          ; GET ADDRESS.
	JSR    0,X          ; GO DO IT.
	JSR    RSKIPSPC     ; SKIP SPACES.
	LDAA   0,Y
	CMPA   #EOLTOK      ; ARE WE AT THE END OF THE LINE?
	BNE    RUNLINE1
	RTS
RUNLINE1:	INY                 ; MUST BE A MID EOL.
	BRA    RUNLINE2
*
*
CHCKBRK:	EQU    *
	LDAA   #10          ; RELOAD THE BREAK CHECK COUNT.
	STAA   BREAKCNT
	JSR    CONSTAT      ; GET CONSOLE STATUS. CHARACTER TYPED?
	BNE    CHCKBRK1     ; YES. GO CHECK IT OUT.
	RTS                 ; NO. RETURN.
CHCKBRK1:	JSR    INCONNE      ; GET BYTE FROM CONSOLE BUT DON'T ECHO.
	CMPA   #$03         ; WAS IT A CONTROL-C?
	BEQ    CHCKBRK2     ; YES. GO DO A BREAK.
	RTS                 ; NO. RETURN.
CHCKBRK2:	STY    IPSAVE       ; SAVE THE IP POINTER IN CASE OF A CONTINUE.
	JSR    NL
	LDX    #BREAKS      ; POINT TO BREAK STRING.
	JSR    PL
	LDD    CURLINE
	JSR    OUTDECI
	JSR    NL
	JMP    MAINW
*
*
*
*
RUNINIT:	EQU    *
	JSR    CCLEAR       ; GO CLEAR ALL VARIABLE STORAGE.
RUNINIT1:	LDX    STNUMS      ; GET START OF NUMERIC OPERAND STACK.
	STX    NUMSTACK     ; INITALIZE THE OPERAND STACK POINTER.
	LDX    STOPS       ; GET THE START OF THE OPERATOR STACK.
	STX    OPSTACK      ; INITALIZE THE OPREATOR STACK POINTER.
	LDX    STFORSTK    ; GET THE START OF THE FOR-NEXT STACK.
	STX    FORSTACK     ; INITALIZE THE FOR NEXT STACK POINTER.
	LDX    STWHSTK     ; GET THE START OF THE WHILE STACK.
	STX    WHSTACK      ; INITALIZE THE WHILE STACK POINTER.
	LDX    STGOSTK     ; GET THE START OF THE GOSUB STACK.
	STX    GOSTACK      ; SET THE START OF THE GOSUB STACK.
	LDX    VAREND       ; GET THE VARIABLE END POINTER.
	INX                 ; POINT TO THE NEXT AVAILABLE BYTE.
	STX    STRASTG      ; INITALIZE THE STRING/ARRAY STORAGE POINTER.
	CLR    PRINTPOS     ; SET THE CURRENT PRINT POSITION TO 0.
	LDAA   #10          ; SET COUNT FOR BREAK CHECK.
	STAA   BREAKCNT
	CLR    CONTFLAG     ; CLEAR THE CONTINUE FLAG.
	LDX    #0           ; CLEAR THE DATA POINTER.
	STX    DATAPTR
	RTS
*
*
CCONT:	EQU    *
	JSR    NL2
	TST    CONTFLAG
	BNE    CCONT1
	LDY    IPSAVE
	JMP    CRUN7
CCONT1:	LDAA   #CNTCNERR
	STAA   ERRCODE
	JMP    RPTERR5
*
*
CNEW:	EQU    *
	ldx    EEStart
	LDAA   AUTOSTF,X   ;  GET THE AUTO START FLAG.
	CMPA   #$55         ; IS IT SET?
	BNE    CNEW1        ; NO. GO INITIALIZE EVERYTHING.
	LDAA   #$FF         ; YES. RESET (ERASE) IT.
	STAA   AUTOSTF,X
	JSR    DLY10MS
CNEW1:	JSR    INITVARS     ; INITIALIZE EVERYTHING.
	RTS                 ; RETURN.
*
*
CCLEAR:	EQU    *
	JSR    RUNINIT1     ; GO INITALIZE ALL STACKS ETC.
CCLEAR3:	LDX    VARBEGIN
CCLEAR1:	LDAA   0,X
	BEQ    CCLEAR2
	INX
	INX
	INX
	JSR    CLRVAR
	BRA    CCLEAR1
CCLEAR2:	LDX    VAREND
	INX
	STX    STRASTG
	RTS
*
*
