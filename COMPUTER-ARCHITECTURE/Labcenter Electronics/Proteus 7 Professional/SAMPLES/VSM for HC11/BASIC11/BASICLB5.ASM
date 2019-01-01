*        title    BASICLB5
*        page
*
*/***** getfun() *****/
*
*getfun()
*{
* short type;
* if(match("FDIV")) type=xfdiv();
* else if(match("CHR$")) type=xchrs();
* else if(match("ABS")) type=xabs();
* else if(match("RND")) type=xrnd();
* else if(match("SGN")) type=xsgn();
* else if(match("TAB")) type=xtab();
* else if(match("ADC")) type=xadc();
* else if(match("CALL")) type=xcall();
* else return(0);
* return(type);
*}
*
*
GETFUN:	EQU    *
	LDX    #FUNCTBL
GETFUN1:	JSR    STREQ
	BCS    GETFUN2
GETFUN3:	INX
	LDAA   0,X
	BNE    GETFUN3
	LDAB   #4
	ABX
	TST    0,X
	BNE    GETFUN1
	CLRA
	RTS
GETFUN2:	LDAA   #FUNCTFLG
	JSR    PUTTOK
	LDAA   1,X
	LDX    2,X
	JMP    0,X
*
*
FUNCTBL:	EQU    *
FDIVS:	FCC    "FDIV"
	FCB    0
	FCB    FDIVTOK
	FDB    BNUMFUN
CHRS:	FCC    "CHR$"
	FCB    0
	FCB    CHRTOK
	FDB    UNUMFUN
ABS:	FCC    "ABS"
	FCB    0
	FCB    ABSTOK
	FDB    UNUMFUN
RND:	FCC    "RND"
	FCB    0
	FCB    RNDTOK
	FDB    UNUMFUN
SGN:	FCC    "SGN"
	FCB    0
	FCB    SGNTOK
	FDB    UNUMFUN
TABS:	FCC    "TAB"
	FCB    0
	FCB    TABTOK
	FDB    UNUMFUN
ADCS:	FCC    "ADC"
	FCB    0
	FCB    ADCTOK
	FDB    UNUMFUN
CALL:	FCC    "CALL"
	FCB    0
	FCB    CALLTOK
	FDB    UNUMFUN
PEEK:	FCC    "PEEK"
	FCB    0
	FCB    PEEKTOK
	FDB    UNUMFUN
	FCC    "EEP"
	FCB    0
	FCB    FEEPTOK
	FDB    UNUMFUN
HEX2:	FCC    "HEX2"
	FCB    0
	FCB    HEX2TOK
	FDB    UNUMFUN
HEX:	FCC    "HEX"
	FCB    0
	FCB    HEXTOK
	FDB    UNUMFUN
	FCC    "PORT"
	FCB    0
	FCB    FPRTATOK
	FDB    FINDPORT
	FCC    "TIME"
	FCB    0
	FCB    FTIMETOK
	FDB    XTIMEF
	FCC    "PACC"
	FCB    0
	FCB    FPACCTOK
	FDB    XPACCF
	FCB    0            ; END OF TABLE MARKER.
*
*
XPOKE:	EQU    *
	LDX    TBUFPTR      ; GET TOKEN BUFFER POINTER.
	DEX                 ; DEC. TO COMPENSATE FOR PUTTOK DONE IN XLATE.
	STX    TBUFPTR      ; SAVE NEW POINTER VALUE. FALL THROUGH TO BNUMFUN.
	LDAA   0,X          ; GET TOKEN BACK INTO THE A-REG.
*
*
*/***** xfdiv() *****/
*
*xfdiv()
*{
* short type[2];
* type[0]=type[1]=NUM;            /* both arguments must be type NUM */
* dofunct(FDIVTOK,2,type);
* return(NUM);
*}
*
BNUMFUN:	EQU    *
	PSHY
	LDAB   #NUM
	PSHB
	PSHB
	TSY
	LDAB   #2
	JSR    DOFUNCT
*        LDAA   #NUM
	PULA
	PULA
	PULY
	RTS
*
*
*/***** xchrs *****/
*
*xchrs()
*{
* return(unumfun(CHRTOK));
*}
*
*/***** xabs() *****/
*
*xabs()
*{
* return(unumfun(ABSTOK));
*}
*
*/***** xrnd() *****/
*
*xrnd()
*{
* return(unumfun(RNDTOK));
*}
*
*/***** xsgn() *****/
*
*xsgn()
*{
* return(unumfun(SGNTOK));
*}
*
*/***** xtab() *****/
*
*xtab()
*{
* return(unumfun(TABTOK));
*}
*
*/***** xadc() *****/
*
*xadc()
*{
* return(unumfun(ADCTOK));
*}
*
*/***** xcall() *****/
*
*xcall()
*{
* return(unumfun(CALLTOK));
*}
*
*/***** unumfun() *****/
*
*unumfun(token)  /* common code for a uinary numerical function */
*short token;
*{
* short type[1];         /* setup argument 'type' array */
* type[0]=NUM;           /* set the 1st (only) argument type to NUM */
* dofunct(token,1,type); /* go do the function */
* return(NUM);           /* return the function type */
*}
*
XEEP:	EQU    *            ; PROGRAM A WORD OF EEPROM.
	LDX    TBUFPTR      ; COMPENSATE FOR TOKEN PLACEMENT BU UNUMFUN
	DEX                 ; ROUTINE.
	STX    TBUFPTR      ; SAVE POINTER.
	LDAA   0,X          ; GET TOKEN FROM BUFFER.
	BSR    UNUMFUN      ; GO TREAT AS A UNIARY NUMERIC FUNCTION.
	JMP    ASIGNMT1     ; GO USE ASSIGNMENT CODE FOR REST OF FUNCTION.
*
*
*
UNUMFUN:	EQU    *
	PSHY
	LDAB   #NUM
	PSHB
	LDAB   #1
	TSY
	BSR    DOFUNCT
*        LDAA   #NUM
	PULA
	PULY
	RTS
*
*
*/***** dofunct() *****/
*
*dofunct(functok,nargs,type)
*short functok,nargs,*type;
*{
* *tbufptr++=functok;            /* put function token in buffer */
* if(*ibufptr!='(') { errcode=ILFSYERR; return; }
* *tbufptr++=OPARNTOK;           /* put open paren in token buffer */
* ++ibufptr;
*
DOFUNCT:	EQU    *
	JSR    PUTTOK
	JSR    GETCHR
	CMPA   #'('
	BEQ    DOFUNCT1
DOFUNCT5:	LDAA   #MPARNERR
	JMP    RPTERR
DOFUNCT1:	JSR    INCIBP
	LDAA   #OPARNTOK
	JSR    PUTTOK
*
*
* while(1)
* {
*  xexpres(*type++);             /* get the argument/expression */
*  if(errcode) return;           /* return if error */
*  if(--nargs==0) break;         /* if we have all the arguments, quit */
*  if(*ibufptr!=',')             /* if delimiter not present, return */
*   { errcode=ILFSYERR; return; }
*  *tbufptr++=COMMATOK;          /* if it is, put it in the token buffer */
*  ++ibufptr;                    /* point to the next character */
* }
*
DOFUNCT4:	LDAA   0,Y
	INY
	PSHB
	JSR    XEXPRES
	PULB
	DECB
	BEQ    DOFUNCT3
	JSR    CHKCOMA
	BCC    DOFUNCT5
	BRA    DOFUNCT4
*
*
* if(*ibufptr!=')')              /* must see closing paren */
* {
*  errcode=ILFSYERR;             /* if not, error */
*  return;
* }
* else                           /* saw closing paren */
* {
*  *tbufptr++=CPARNTOK;          /* put it in the token buffer */
*  ++ibufptr;                    /* advance input buffer pointer */
* }
* return;
*}
*
DOFUNCT3:	EQU    *
	JSR    GETCHR
	CMPA   #')'
	BNE    DOFUNCT5
	JSR    INCIBP
	LDAA   #CPARNTOK
	JMP    PUTTOK       ; PUT TOKEN IN BUFFER & RETURN.
*
*
*
FINDPORT:	EQU    *
	JSR    GETNXCHR     ; GO GET PORT "NUMBER".
	JSR    ToUpper	; Translate the character to upper case.
	CMPA   #'A'         ; IS IT AN A OR HIGHER?
	BHS    FINDPRT1     ; YES. GO CHECK UPPER LIMIT.
FINDPRT2:	LDAA   #ILPRTERR    ; NO. ILLEGAL PORT "NUMBER".
	JMP    RPTERR       ; REPORT ERROR.
FINDPRT1:	CMPA   #'E'         ; IS IT HIGHER THAN AN "E"?
	BHI    FINDPRT2     ; YES. ILLEGAL PORT.
	SUBA   #'A'         ; SUBTRACT "BASE" PORT OF A
	ADDA   #FPRTATOK    ; ADD IN "BASE" TOKEN.
*
*                            ; STEAL SOME CODE.
XPACCF:	EQU    *
XTIMEF:	JSR    PUTTOK       ; PUT TOKEN IN BUFFER.
	LDAA   #NUM         ; RETURN TYPE "NUM".
	RTS                 ; RETURN.
*
*
