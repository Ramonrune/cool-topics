	ORG    ROMBEG
*        title    BASICLB1
******************************************************************************
*                                                                            *
*                      MC68HC11 BASIC INTERPRETER                            *
*                                                                            *
*                             WRITTEN BY:                                    *
*                                                                            *
*                           GORDON DOUGHMAN                                  *
*                                                                            *
*                        COPYRIGHT 1985-1990 BY                              *
*                                                                            *
*                           GORDON DOUGHMAN                                  *
*                                                                            *
******************************************************************************
*
*
*/
*       include "1.DEFINES.C"
*
*main()
*{
* initvars();            /* initalize all variables & pointers */
* outheader();           /* send startup message to console */
* outrdy();              /* output ready message */
*
	JMP    POWERUP
MAIN:	EQU    *
MAINC:	JSR    INITVARS     ; INITALIZE ALL INTERNAL VARIABLES.
	LDX    EEStart
	LDAA   AUTOSTF,X    ; get the auto start flag.
	CMPA   #$55
	BNE    MAIN9
	CLI		; ALLOW ALL INTERRUPTS TO BE SERVICED.
	JSR    CRUN
MAIN9:	JSR    OUTHEADR     ; PRINT HEADER.
MAINW:	EQU    *
MAIN2:	LDD    RAMStart     ; RESET STACK VALUE.
	ADDD   RAMSize
	XGDX
	TXS
	CLI                 ; (J.I.C.)
	CLRA                ; CLEAR D.
	CLRB
	STD    TIMECMP      ; DON'T ALLOW "ONTIME" INTERRUPTS TO OCCUR.
	STD    ONIRQLIN     ; DON'T ALLOW "ONIRQ" INTERRUPTS TO OCCUR.
	STD    ONPACLIN     ; DON'T ALLOW "PACC" INTERRUPTS TO OCCUR.
	JSR    OUTRDY       ; PRINT READY MESSAGE.
*
* while(1)               /* do forever */
* {
*  outprmpt();           /* output prompt */
*  getline();            /* getline from console */
*  skipspcs();           /* ignore leading spaces in input buffer */
*  if(chckcmds()) continue;           /* check for commands */
*  parse();              /* translate/execute line */
*  if(errcode) rpterr(); /* if an error occured somewhere, report it. */
*  errcode=0;            /* clear error status */
* }
*}
*
MAIN1:	EQU    *
	CLR    IMMID        ; CLEAR THE IMMIDIATE MODE FLAG.
	CLR    ERRCODE      ; CLEAR THE ERROR CODE BYTE.
	CLR    RUNFLAG      ; CLEAR THE RUN MODE FLAG.
	JSR    OUTPRMPT     ; SEND PROMPT TO CONSOLE.
	JSR    GETLINE      ; GO GET LINE FROM OPERATOR.
	JSR    SKIPSPCS     ; SKIP ANY LEADING SPACES.
	JSR    CHCKCMDS     ; GO CHECK FOR ANY COMMANDS.
	CPD    #0           ; WERE THERE ANY?
	BNE    MAIN2        ; YES. CONTINUE.
	LDX    VAREND       ; SAVE CURRENT END OF VARIABLE AREA IN CASE LINE
	STX    FENCE        ; HAS AN ERROR IN IT. (SO NO SPURIOUS VARIABLES
*                             ; ARE ALLOCATED)
	JSR    PARSE
	TST    IMMID        ; DID WE EXECUTE IN IMMIDATE MODE?
	BNE    MAIN2        ; YES. PRINT READY MESSAGE.
	BRA    MAIN1        ; NO. JUST PRINT PROMPT.
*
*
MAIN3:	LDX    FENCE        ; GET THE VAREND FENCE.
	CLR    0,X          ; MARK "OLD" END OF VARIABLE AREA IN CASE ANY
*                             ; VARIABLES WERE ALLOCATED.
	STX    VAREND       ; RESTORE THE POINTER.
	BRA    MAIN2        ; CONTINUE AFTER ERROR.
*
*        /***** skipspcs() *****/
	
*skipspcs()
*{
* while(*ibufptr==SPC) ++ibufptr;
* return;
*}
*
SKIPSPCS:	EQU    *
SKIPSPC1:	JSR    GETCHR
	CMPA   #SPC
	BNE    SKIPSPC2
	JSR    INCIBP
	BRA    SKIPSPC1
SKIPSPC2:	RTS
*
	
*        /***** outheader *****/
	
*outheader()
*{
* pl("BASIC11 v1.1");
* nl();
* nl();
* pl("Written by Gordon Doughman");
* nl();
*}
*
OUTHEADR:	EQU    *
	LDX    #HEADER
	JMP    PL
*
HEADER:	EQU    *
	FCB    $0D,$0A,$0D,$0A
	FCC    "BASIC11 v1.55"
	FCB    $0D,$0A
	FCC    "Copyright 1985-1990 by"
	FCB    $0D,$0A
	FCC    "Gordon Doughman"
	FCB    $0D,$0A,0
*
*
*        /***** outrdy() *****/
	
*outrdy()
*{
* nl();
* pl("READY");
* return;
*}
*
OUTRDY:	EQU    *
	LDX    #READY
	JMP    PL
*
READY:	EQU    *
	FCB    $0D,$0A
	FCC    "READY"
	FCB    $0D,$0A,0
*
*
*        /***** getline() *****/
	
*getline()
*{
* short chrcnt;
* char c;
* chrcnt=IBUFLEN;
* ibufptr=inbuff;
*
GETLINE:	EQU    *
	LDAB   #IBUFLEN-1
	LDX    INBUFFS
*
* while((c=inbyte())!=EOL && (chrcnt>0))
* {
*
GETLINE3:	JSR    INBYTE
	CMPA   #EOL
	BEQ    GETLINE1
	TSTB
	BEQ    GETLINE1
*
*  if(c==BS)
*  {
*   if(ibufptr!=inbuff)
*   {
*    ibufptr-=1;         /* point to previous buffer location */
*    outbyte(SPC);        /* erase character on screen */
*    outbyte(BS);        /* back cursor up */
*    chrcnt+=1;
*   }
*   else
*    continue;
*   }
*
*
	CMPA   #BS
	BNE    GETLINE2
	CMPB   #IBUFLEN-1
	BEQ    GETLINE1
	DEX
	LDAA   #SPC
	JSR    OUTBYTE
	LDAA   #BS
	JSR    OUTBYTE
	INCB
*
*  if(c < SPC) continue;  /* ignore all other control characters */
*
GETLINE2:	EQU    *
	CMPA   #CNTRLC      ; IS IT A "BREAK"?
	BNE    GETLINE4     ; NO. GO PROCESS THE CHARACTER.
	INC    CONTFLAG     ; DONT ALLOW A "CONT".
	JMP    CHCKBRK2     ; GO DO A BREAK.
GETLINE4:	CMPA   #SPC
	BLO    GETLINE3
*
*  *ibufptr=c;            /* save character in input buffer */
*  ibufptr+=1;           /* point to next location */
*  chrcnt-=1;
* }
	STAA   0,X
	INX
	DECB
	BNE    GETLINE3
*
* *ibufptr=EOL;          /* put EOL in input buffer */
* ibufptr=inbuff;        /* initalize the input buffer pointer */
* return;
*}
*
GETLINE1:	EQU    *
	LDAA   #EOL
	STAA   0,X
	LDX    INBUFFS
	STX    IBUFPTR
	RTS
*
ToUpper:		 EQU	*
	 cmpa	#'a'		; is the character less than a lower case 'a'?
	 blo	ToUpper1
	 cmpa	#'z'
	 bhi	ToUpper1
	 anda	#$df
ToUpper1:	rts
	
*        /***** outprmpt() *****/
	
*outprmpt()
*{
* nl();          /* go to new line */
* outbyte('#');  /* send prompt to console */
* return;
*}
*
OUTPRMPT:	EQU    *
	LDX    #PRMPTSTR
	BRA    PL
*
PRMPTSTR:	EQU    *
	FCB    $0D,$0A
        FCC    ">"
	FCB    0
*
*        /***** nl() *****/
	
* nl()                    /* send CR/LF to console */
*{
* outbyte(CR);
* outbyte(LF);
* return;
*}
*
*
NL2:	BSR    NL
NL:	EQU    *
	LDX    #CRLFSTR
	BSR    PL
	CLR    PRINTPOS     ; SET THE CURRENT PRINT POSITION TO 0.
	RTS
*
CRLFSTR:	FCB    $0A,$0D,$00
*
*        /***** pl() *****/
	
*pl(ptr)                 /* send line to console */
*char *ptr;
*{
* int k; char c;
* k=0;
* while(c=ptr[k++]) outbyte(c);
* return;
*}
*
PL:	EQU    *
PL1:	LDAA   0,X
	BEQ    PL2
	JSR    OUTBYTE
	INX
	BRA    PL1
PL2:	RTS
*
	
*        /***** parse() *****/
	
*parse()
*{
* int num;
* tbufptr=tknbuf;                /* initalize the token buffer pointer */
*
PARSE:	EQU    *
	LDX    TKNBUFS		; Get the start of the token buffer
	STX    TBUFPTR
*
* if(num=getlinum())             /* get line number if present */
* {
*  if(*ibufptr==EOL)             /* was line # followed by CR? */
*  {                             /* yes. */
*   delline(num);                /* go delete the line from the prog buffer */
*   return;
*  }
*  immid=0;                      /* flag as not immidiate */
*  putlinum(num);                /* put line number in buffer */
* }
*  else immid=1;                  /* if no line # flag as immidiate*/
*
	BSR    GETLINUM
	BCC    PARSE2
	PSHA
	JSR    GETCHR
	CMPA   #EOL
	PULA
	BNE    PARSE1
	JSR    DELLINE
	LDX    VAREND
	INX
	STX    STRASTG
PARSE7:	RTS
PARSE1:	CLR    IMMID
PARSE8:	BSR    PUTLINUM
	BRA    PARSE3
PARSE2:	JSR    GETCHR
	CMPA   #EOL
	BEQ    PARSE7
	LDAA   #1
	STAA   IMMID
	LDD    #0
	BRA    PARSE8
*
* if(errcode) return;             /* if line number error, return */
* xlate();                        /* if translation error, return */
* if(errcode) return;
* if(immid) runline();            /* if immidiate mode run 1 line */
*  else storlin();                /* if not store pgm line */
* return;                         /* go get next line */
*}
*
PARSE3:	JSR    XLATE
	TST    IMMID
	BEQ    PARSE5
	JMP    RUNLINE      ; GO RUN THE LINE & RETURN.
PARSE5:	JSR    STORLIN      ; GO STORE LINE & RETURN.
	LDX    VAREND
	INX
	STX    STRASTG
	RTS
*
	
*        /***** getlinum *****/
	
*getlinum()
*{
* int num;
* num=0;
*
GETLINUM:	EQU    *
*
*
	PSHY
	CLRA
	PSHA
	PSHA
	TSY
*
* if(numeric(*ibufptr)==0) return(0);    /* if 1st char not numeric, rtn 0 */
*
	LDX    IBUFPTR
	LDAA   0,X
	BSR    NUMERIC
	BCC    GTLNUM4
*
* while(numeric(*ibufptr))       /* while *ibufptr is numeric */
* {
*  num=num*10+(*ibufptr-'0');    /* get a digit */
*  ibufptr++;                    /* advance input buffer pointer */
*  if(num<=0) { errcode=LINRANG; return(0); }
* }
* return(num);
*}
*
GTLNUM2:	LDAA   0,X
	BSR    NUMERIC
	BCS    GTLNUM3
	SEC
GTLNUM1:	LDD    0,Y
	BNE    GTLNUM4
	LDAA   #LINENERR
	BRA    GTLNUM5
GTLNUM4:	INS
	INS
	PULY
	STX    IBUFPTR
	RTS
GTLNUM3:	BSR    ADDDIG
	BPL    GTLNUM2
	LDAA   #LINRANG
GTLNUM5:	JMP    RPTERR
*
*
ADDDIG:	EQU    *
	LDD    0,Y
	ASLD
	ASLD
	ADDD   0,Y
	ASLD
	STD    0,Y
	LDAB   0,X
	INX
	SUBB   #'0'
	CLRA
	ADDD   0,Y
	STD    0,Y
	RTS
*
*
*        /***** putlinum *****/
	
*putlinum(lnum)
*int lnum;
*{
* putint(lnum);          /* put line # in token buffer */
* *tbufptr++=0;          /* hold place for length of line */
* return;
*}
*
PUTLINUM:	EQU    *
	JSR    PUTDTOK
	CLRA
	JMP    PUTTOK
*
*        /***** numeric() *****/
	
*numeric(c)
*char c;
*{
* c=c&127;
* return((c>='0')&(c<='9'));
*}
*
NUMERIC:	EQU    *
	CMPA   #'0'
	BLO    NUMERIC1
	CMPA   #'9'
	BHI    NUMERIC1
	SEC
	RTS
NUMERIC1:	CLC
	RTS
	
*        /***** alpha() *****/
	
*alpha(c)
*char c;
*{
* c=c&127;
* return((c>='A')&(c<='Z'));
*}
*
ALPHA:	EQU    *
	CMPA   #'A'
	BLO    ALPHA1
	CMPA   #'Z'
	BLS    ALPHA2
	CMPA   #'a'
	BLO    ALPHA1
	CMPA   #'z'
	BHI    ALPHA1
ALPHA2:	SEC
	RTS
ALPHA1:	CLC
	RTS
	
*        /***** alphanum *****/
	
*alphanum(c)
*char c;
*{ return ((alpha(c)) | (numeric(c))); }
*
ALPHANUM:	EQU    *
	BSR    ALPHA
	BCC    ALPHANU1
	RTS
ALPHANU1:	BRA    NUMERIC
*
*/*****************************************
*              xlate()
* translate the input buffer into tokenized
* form placing the results into tknbuf
******************************************/
*
*xlate()
*{
* while(*ibufptr!=EOL)
* {
*  ifwhflag=0;              /* set IF flag to zero */
*  blanks();              /* skip all blanks */
*  if(match("DATA")) xdata();
*  else if(match("LET")) xlet();
*  else if(match("READ")) xread();
*  else if(match("RESTORE")) xrestore();
*  else if(match("GOSUB")) xgosub();
*  else if(match("GOTO")) xgoto();
*  else if(match("ON")) xon();
*  else if(match("RETURN")) xreturn();
*  else if(match("IF")) xif();
*  else if(match("INPUT")) xinput();
*  else if(match("PRINT")) xprint();
*  else if(match("FOR")) xfor();
*  else if(match("NEXT")) xnext();
*  else if(match("STOP")) xstop();
*  else if(match("ENDWH")) xendwh();
*  else if(match("END")) xend();
*  else if(match("REM")) xrem();
*/*else if(match("SWAP")) xswap();*/
*  else if(match("TRON")) xtron();
*  else if(match("TROFF")) xtroff();
*  else if(match("WHILE")) xwhile();
*/*else if(match("ONIRQ")) xonirq();*/
*  else ximplet();                 /* if no keyword, assume implied LET */
*  if(errcode) return;
*  blanks();
*  if(*ibufptr==MIDEOL) { xmideol(); continue; }
*  if(*ibufptr!=EOL) { errcode=SYTXERR; return; }
*  }
* *tbufptr=EOLTOK;               /* put token eol in token buffer */
* tknbuf[2]=tbufptr-tknbuf+1;    /* put line length into tokenized line */
* return;
*}
*
XLATE:	EQU    *
	JSR    GETCHR      ; GET NEXT CHAR.
	CMPA   #EOL        ; AT THE END OF THE LINE?
	BEQ    XLATE1      ; YES.
	CLR    IFWHFLAG    ; NOT XLATING "IF" OR "WHILE"
	JSR    BLANKS      ; SKIP BLANKS.
	LDX    #KEYWORDS   ; POINT TO KEYWORD TABLE.
XLATE4:	JSR    STREQ       ; IS KEYWORD IS IN THE INPUT BUFFER?
	BCS    XLATE2      ; YES GO PROCESS IT.
XLATE3:	INX                ; NO. POINT TO NEXT CHAR.
	LDAA   0,X         ; AT THE END OF THIS KEYWORD?
	BNE    XLATE3      ; NO.
	LDAB   #4          ; NUMBER OF BYTES TO SKIP.
	ABX
	TST    0,X         ; AT THE END OF THE TABLE?
	BNE    XLATE4      ; NO. CHCK FOR NEXT KEYWORD.
	LDAA   #IMLETTOK   ; ASSUME AN IMPLIED LET.
*        JSR    PUTTOK       ; PUT TOKEN IN BUFFER.
	LDX    #XIMPLET    ; GET ADDR OF XLATION ROUTINE.
*        JSR    0,X          ; GO DO IT.
*        BRA    XLATE6       ; GO FINISH UP.
	BRA    XLATE9
XLATE2:	LDAA   1,X         ; GET KEYWORD TOKEN.
	LDX    2,X         ; GET ADDR OF XLATION ROUTINE.
XLATE9:	JSR    PUTTOK      ; PUT TOKEN IN BUFFER.
	CMPA   #DATATOK    ; SPECIAL CASE, DONT SKIP BLANKS AFTER KEYWORD.
	BEQ    XLATE5
	CMPA   #REMTOK     ; SAME SPECIAL CASE AS FOR DATA.
	BEQ    XLATE5
	JSR    BLANKS      ; SKIP BLANKS BETWEEN KEYWORD & NEXT OBJECT.
XLATE5:	JSR    0,X         ; GO DO IT.
XLATE6:	JSR    BLANKS      ; SKIP BLANKS.
	JSR    GETNXCHR    ; GET NEXT CHAR.
	CMPA   #MIDEOL     ; IS IT A MID EOL?
	BNE    XLATE7      ; NO. CHCK FOR EOL.
	LDAA   #MEOLTOK    ; GET MID EOL TOKEN.
	JSR    PUTTOK      ; PUT IT IN BUFFER.
	BRA    XLATE       ; CONTINUE.
XLATE7:	CMPA   #EOL        ; EOL?
	BEQ    XLATE1      ; YES. FINISH UP.
	LDAA   #SYTXERR    ; NO. SYNTAX ERROR.
	JMP    RPTERR      ; REPORT XLATION ERROR.
XLATE1:	LDAA   #EOLTOK     ; GET EOL TOKEN.
	JSR    PUTTOK      ; PUT IT IN BUFFER.
	LDD    TBUFPTR     ; GET TOKEN BUFFER POINTER.
	SUBD   TKNBUFS     ; Compute the TOKEN BUFFER LENGTH.
	LDX    TKNBUFS     ; POINT TO BUFFER.
	STAB   2,X         ; STORE LENGTH.
	RTS                ; RETURN.
*
*
*        KEYWORD LOOK UP TABLE
*
*
KEYWORDS:	EQU    *
DATA:	FCC    "DATA"
	FCB    0
	FCB    DATATOK
	FDB    XDATA
LET:	FCC    "LET"
	FCB    0
	FCB    LETTOK
	FDB    XLET
READ:	FCC    "READ"
	FCB    0
	FCB    READTOK
	FDB    XREAD
RESTORE:	FCC    "RESTORE"
	FCB    0
	FCB    RESTRTOK
	FDB    XRESTORE
GOSUB:	FCC    "GOSUB"
	FCB    0
	FCB    GOSUBTOK
	FDB    XGOSUB
GOTO:	FCC    "GOTO"
	FCB    0
	FCB    GOTOTOK
	FDB    XGOTO
ONTIME:	FCC    "ONTIME"
	FCB    0
	FCB    ONTIMTOK
	FDB    XONTIME
ONIRQ:	FCC    "ONIRQ"
	FCB    0
	FCB    ONIRQTOK
	FDB    XONIRQ
ONPACC:	FCC    "ONPACC"
	FCB    0
	FCB    ONPACTOK
	FDB    XONPACC
ON:	FCC    "ON"
	FCB    0
	FCB    ONTOK
	FDB    XON
RETURN:	FCC    "RETURN"
	FCB    0
	FCB    RETNTOK
	FDB    XRETURN
IIF:	FCC    "IF"
	FCB    0
	FCB    IFTOK
	FDB    XIF
INPUT:	FCC    "INPUT"
	FCB    0
	FCB    INPUTTOK
	FDB    XINPUT
PRINT:	FCC    "PRINT"
	FCB    0
	FCB    PRINTTOK
	FDB    XPRINT
	FCC    "?"
	FCB    0
	FCB    PRINTTOK
	FDB    XPRINT
FOR:	FCC    "FOR"
	FCB    0
	FCB    FORTOK
	FDB    XFOR
NEXT:	FCC    "NEXT"
	FCB    0
	FCB    NEXTTOK
	FDB    XNEXT
STOPSS:	FCC    "STOP"
	FCB    0
	FCB    STOPTOK
	FDB    XSTOP
ENDWH:	FCC    "ENDWH"
	FCB    0
	FCB    ENDWHTOK
	FDB    XENDWH
ENDS:	FCC    "END"
	FCB    0
	FCB    ENDTOK
	FDB    XEND
REM:	FCC    "REM"
	FCB    0
	FCB    REMTOK
	FDB    XREM
TRON:	FCC    "TRON"
	FCB    0
	FCB    TRONTOK
	FDB    XTRON
TROFF:	FCC    "TROFF"
	FCB    0
	FCB    TROFFTOK
	FDB    XTROFF
WHILE:	FCC    "WHILE"
	FCB    0
	FCB    WHILETOK
	FDB    XWHILE
POKE:	FCC    "POKE"
	FCB    0
	FCB    POKETOK
	FDB    XPOKE
DIM:	FCC    "DIM"
	FCB    0
	FCB    DIMTOK
	FDB    XDIM
EEP:	FCC    "EEP"
	FCB    0
	FCB    EEPTOK
	FDB    XEEP
PORTA:	FCC    "PORTA"
	FCB    0
	FCB    PORTATOK
	FDB    XPORTA
PORTB:	FCC    "PORTB"
	FCB    0
	FCB    PORTBTOK
	FDB    XPORTB
PORTC:	FCC    "PORTC"
	FCB    0
	FCB    PORTCTOK
	FDB    XPORTC
PORTD:	FCC    "PORTD"
	FCB    0
	FCB    PORTDTOK
	FDB    XPORTD
INBYTES:	FCC    "INBYTE"
	FCB    0
	FCB    INBYTTOK
	FDB    XINBYTE
TIME:	FCC    "TIME"
	FCB    0
	FCB    TIMETOK
	FDB    XTIME
RETI:	FCC    "RETI"
	FCB    0
	FCB    RETITOK
	FDB    XRETI
PACC:	FCC    "PACC"
	FCB    0
	FCB    PACCTOK
	FDB    XPACC
SLEEP:	FCC    "SLEEP"
	FCB    0
	FCB    SLEEPTOK
	FDB    XSLEEP
RTIMES:	FCC    "RTIME"
	FCB    0
	FCB    RTIMETOK
	FDB    XRTIME
	FCB    0           ; END OF TABLE MARKER.

*blanks()
*{
* short spcnt;
* spcnt=0;
* while(*ibufptr==SPC) { ibufptr++; spcnt++; }
*
BLANKS:	EQU    *
	PSHX
	LDX    IBUFPTR
	CLRB
BLANKS1:	LDAA   0,X
	CMPA   #SPC
	BNE    BLANKS2
	INCB
	INX
	BRA    BLANKS1
*
* if(spcnt==0) return;
*
BLANKS2:	TSTB
	BNE    BLANKS3
	PULX
	RTS
*
* if(spcnt>1)
*  {
*   *tbufptr++=MSCNTOK;
*   *tbufptr++=spcnt;
*  }
*
BLANKS3:	STX    IBUFPTR
	LDX    TBUFPTR
	CMPB   #1
	BEQ    BLANKS4
	LDAA   #MSCNTOK
	STAA   0,X
	INX
BLANKS5:	STAB   0,X
	INX
	STX    TBUFPTR
	PULX
	RTS
*
* else
*  {
*   *tbufptr++=SSCNTOK;
*  }
* return;
*}
*
BLANKS4:	LDAB   #SSCNTOK
	BRA    BLANKS5
*
*
*<><><><><><><> NOTE: THIS FUNCTION NOT NEEDED <><><><><><><>
*
*/**************************************
*             match()
* try to find match between *lit and
* *ibufptr. if match found, ibufptr is
* advanced to point beyond *lit. the
* string pointed to by lit must be null
* terminated.
***************************************/
*
*match(lit)
*char *lit;
*{
* int k;
* if(k=streq(ibufptr,lit))
* {
*  ibufptr+=k;
*  return(1);
* }
* return(0);
*}
	
*/****************************************
*               streq()
* compare srt1 to str2. str2 must be null
* terminated.
*****************************************/
*
*streq(str1,str2)
*char *str1,*str2;
*{
* int k;
* k=0;
* while(str2[k])         /* we're not at the end of string2 */
* {
*  if((str1[k])!=(str2[k])) return(0);
*  k++;
* }
* return(k);
*}
*
STREQ:	EQU    *
	LDD    IBUFPTR     ; SAVE VALUE OF POINTER.
*        PSHD
	PSHB
	PSHA
STREQU4:	LDAA   0,X
	BEQ    STREQU2
STREQU1:	BSR    GETNXCHR
	jsr    ToUpper	; Make the character upper case.
	CMPA   0,X
	BEQ    STREQU3
*        PULD
	PULA
	PULB
	STD    IBUFPTR
	CLC
	RTS
STREQU3:	INX
	BRA    STREQU4
STREQU2:	PULA
	PULB
	SEC
	RTS
*
*
*        THIS ROUTINE GETS THE NEXT CHARACTER FROM THE INPUT BUFFER.
*
*
GETCHR:	PSHX               ; SAVE THE X REGISTER.
	LDX    IBUFPTR     ; GET POINTER.
	LDAA   0,X         ; GET A CHARACTER.
	PULX               ; RESTORE X.
	RTS                ; RETURN.
*
*
*        THIS ROUTINE GETS THE NEXT CHARACTER FROM THE INPUT BUFFER
*        AND ADVANCES THE POINTER TO POINT TO THE NEXT CHARACTER.
*
*
GETNXCHR:	BSR    GETCHR
*                       FALL THROUGH TO INCIBP.
*
*
*        THIS ROUTINE JUST INCREMENTS THE INPUT BUFFER POINTER.
*
*
INCIBP:	PSHX               ; SAVE X.
	LDX    IBUFPTR     ; GET POINTER.
INCIBP1:	INX                ; ADVANCE POINTER.
	STX    IBUFPTR     ; UPDATE POINTER.
INCIBP2:	PULX               ; RESTORE X
	RTS                ; RETURN.
*
*
*        THIS ROUTINE PUTS THE WORD IN THE D-REG. INTO THE TOKEN BUFFER
*        AND ADVANCES THE TOKEN BUFFER POINTER.
*
*
PUTDTOK:	BSR    PUTTOK      ; PUT THE FIRST BYTE INTO THE TOKEN BUFFER.
	TBA                ; PUT THE 2ND BYTE INTO A.
*                            ; FALL THROUGH TO PUTTOK.
*
*
*        THIS ROUTINE PUTS THE CHARACTER IN THE A-REG. INTO THE TOKEN
*        BUFFER AND ADVANCES THE TOKEN BUFFER POINTER.
*
*
PUTTOK:	PSHX               ; SAVE X.
	pshb
	psha					; (9/12/89).
	LDX    TBUFPTR     ; GET POINTER.
	STAA   0,X         ; PUT CHARACTER.
PUTTOK1:	INX                ; ADVANCE POINTER.
	STX    TBUFPTR     ; SAVE POINTER.
	 
	LDD    TKNBUFS     ; get the starting address of the token buffer.
	ADDD   #TBUFLEN    ; add the length of the buffer to it.
	CPD    TBUFPTR     ; IS THE TOKEN BUFFER FULL?
	pula					; (9/12/89).
	pulb               ; restore the b reg.
	BHI    INCIBP2     ; NO. RESTORE X AND RETURN.
	LDAA   #EXPCXERR   ; YES. FLAG THE ERROR.
	JMP    RPTERR      ; GO REPORT IT.
