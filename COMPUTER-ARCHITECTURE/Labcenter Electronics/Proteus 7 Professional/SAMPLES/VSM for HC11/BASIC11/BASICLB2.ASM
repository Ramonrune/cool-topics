*        title    BASICLB2
*        page
*
*
*<><><><><><> NOTE: FUNCTION PERFORMED IN "XLATE" <><><><><><>
*
*/***** xmideol() *****/
*
*xmideol()
*{
* *tbufptr++=MEOLTOK;
* ++ibufptr;
* return;
*}
*
*
*
*/****** common code for GOSUB and GOTO *****/
*
*xgo(gotok)
*char gotok;
*{
* int num;
* *tbufptr++=gotok;      /* put GOTO or GOSUB token in buffer */
* blanks();              /* skip blanks before line number */
* *tbufptr++=LCONTOK;    /* put line number constant token in buffer */
* num=getlinum();        /* get line number */
* if(num==0) errcode=LINENERR;   /* if 0, line number error */
* if(errcode) return;    /* if error, return */
* putint(num);           /* put line number in buffer */
* return;
*}
*
XGOSUB:	EQU    *
XGOTO:	EQU    *
*        JSR    BLANKS
	LDAA   #LCONTOK
	BSR    PUTTOK
	JSR    GETLINUM
XGOTO2:	BRA    PUTDTOK
*
*
*<><><><><><> ROUTINE NOT NEEDED <><><><><><>
*
*/***** GOSUB *****/
*
*xgosub()
*{
* xgo(GOSUBTOK);
* return;
*}
*
*
*<><><><><><> ROUTINE NOT NEEDED <><><><><><>
*
*/***** GOTO *****/
*
*xgoto()
*{
* xgo(GOTOTOK);
* return;
*}
	
*/***** RETURN *****/
*
*xreturn()
*{
* *tbufptr++=RETNTOK;    /* put RETURN token in buffer */
* return;
*}
*
*/***** STOP *****/
*
*xstop()
*{
* *tbufptr++=STOPTOK;    /* put STOP token in buffer */
* return;
*}
*
*/***** END *****/
*
*xend()
*{
* *tbufptr++=ENDTOK;     /* put end token in buffer */
* return;
*}
*
*/***** TRON *****/
*
*xtron()
*{
* *tbufptr++=TRONTOK;    /* put TRON token in buffer */
* return;
*}
*
*/***** TROFF *****/
*
*xtroff()
*{
* *tbufptr++=TROFFTOK;   /* put TROFF token in buffer */
* return;
*}
*
XRETURN:	EQU    *
XSTOP:	EQU    *
XEND:	EQU    *
XTRON:	EQU    *
XTROFF:	EQU    *
XRESTORE:	EQU    *
XENDWH:	EQU    *
XRETI:	EQU    *
XSLEEP:	EQU    *
XRTIME:	EQU    *
	RTS                ; NULL FUNCTIONS BECAUSE TOKEN PLACEMENT IS DONE IN
*                            ; XLATE FUNCTION.
*
	
*/***** REM *****/
*
*xrem()
*{
* char c;
* *tbufptr++=REMTOK;     /* put rem token in buffer */
* while(1)
* {
*  if((c=*ibufptr)==EOL) break;
*  *tbufptr++=c;
*  ++ibufptr;
* }
* return;
*}
*
*
*/***** xdata() *****/
*
*xdata()
*{
* char c;
* *tbufptr++=DATATOK;            /* put DATA token in buffer */
* while((c=*ibufptr)!=EOL)
* {
*  if(c==',') *tbufptr++=COMMATOK;
*  else *tbufptr++=c;
*  ++ibufptr;
* }
* return;
*}
*
XDATA:	EQU    *
XREM:	EQU    *
	LDX    TBUFPTR      ; GET POINTER TO TOKEN BUFFER.
	PSHX                ; SAVE IT. (POINTER TO LENGTH OF REM OR DATA)
	LDAA   #0           ; SAVE A BYTE FOR THE LENGTH.
	BSR    PUTTOK
	LDAB   #2           ; INITALIZE LENGTH  TO 2 (INCLUDES LENGTH & EOL.
XREM1:	BSR    GETCHR
	CMPA   #EOL
	BEQ    XREM2
	BSR    PUTTOK
	BSR    INCIBP
	INCB                ; UP THE BYTE COUNT.
	BRA    XREM1
XREM2:	BSR    PUTTOK
	PULX                ; GET POINTER TO LENGTH BYTE.
	STAB   0,X          ; PUT IT IN THE TOKEN BUFFER.
	RTS
*
*
XPORTA:	EQU    *
XPORTB:	EQU    *
XPORTC:	EQU    *
XPORTD:	EQU    *
	LDAB   #NUM         ; WE'RE XLATING A NUMERICAL STATEMENT.
	BRA    ASIGNMT1     ; GO DO IT LIKE AN ASIGNMENT STATEMENT.
*
*
*
*
	
*/***** LET *****/
*
*xlet()
*{
* letcom(LETTOK);                /* pass LET token to common code */
* return;
*}
*
*/***** implied LET *****/
*
*ximplet()
*{
* letcom(IMLETTOK);
* return;
*}
*
*/***** common code for explicit & implicit LET *****/
*
*letcom(letok)
*short letok;
*{
* *tbufptr++=letok;              /* put LET token in buffer */
* blanks();              /* skip blanks before assignment statement */
* if(ibufptr=='@') { *tbufptr++=INDIRTOK; ++ibufptr; }
* asignmt();                     /* evaluate expression */
* return;
*}
*
XLET:	EQU    *
XIMPLET:	EQU    *
*        JSR    BLANKS
*XLET1    JMP    ASIGNMT
*
*
	
*/***** asignmt() *****/
*
*asignmt()
*{
*short type;
* if((type=getvar())==0) return; /* get variable & return type */
* if(errcode) return;
* if(*ibufptr++!='=') { errcode=IVEXPERR; return; } /* invalid expression */
* *tbufptr++=EQUALTOK;           /* put equals token in buffer */
* xexpres(type);                 /* build expression in token buffer */
* return;
*}
*
ASIGNMT:	EQU    *
	JSR    GETVAR
	TAB
ASIGNMT1:	BSR    GETNXCHR
	CMPA   #'='
	BEQ    ASIGNMT2
	LDAA   #IVEXPERR
	JMP    RPTERR
ASIGNMT2:	LDAA   #EQUALTOK
	BSR    PUTTOK
	TBA
*                               FALL THROUGH TO XEXPRES.
*
*
	
*/***** xexpres() *****/
*
*xexpres(type)
*short type;
*{
* char c;
* while(1)
* {
*  if(match("-")) *tbufptr++=NEGTOK;
*  else if(match("@")) *tbufptr++=INDIRTOK;
*  else if(match("NOT")) *tbufptr++=NOTTOK;
XEXPRES:	EQU    *
	PSHY
	PSHA
	TSY
XEXPRS29:	LDX    #UINARYOP
	JSR    TBLSRCH
	BCC    XEXPRS30
	BSR    PUTTOK
*
*  if(*ibufptr=='(')     /* open paren? */
*  {
*   *tbufptr++=OPARNTOK; /* put in token buffer */
*   ++ibufptr;           /* point to next char in input buffer */
*   xexpres(type);       /* go get sub expression */
*   if(errcode) return;
*   if(*ibufptr!=')') { errcode=UPARNERR; return; }
*   *tbufptr++=CPARNTOK; /* put it in the token buffer */
*   ++ibufptr;           /* point to the next char in the input buffer */
*   goto chkoprtr;
*  }
*
XEXPRS30:	JSR    GETCHR
	CMPA   #'('
	BNE    XEXPRS1
	JSR    INCIBP
	LDAA   #OPARNTOK
	JSR    PUTTOK
	LDAA   0,Y
	JSR    XEXPRES
XEXPRS2:	JSR    GETNXCHR
	CMPA   #')'
	BEQ    XEXPRS3
	LDAA   #UPARNERR
	JMP    RPTERR
XEXPRS3:	LDAA   #CPARNTOK
	JSR    PUTTOK
	JMP    CHKOPRTR
*
*  if((numeric(*ibufptr)) | (*ibufptr=='$') | (*ibufptr=='"'))
*  {
*   c=getcon();
*   if(errcode) return;
*  }
*  else if(c=getfun()) ;
*  else (c=getvar()) ;
*  if(errcode) return;
*  if(type==NULL) type=c;
*  if(c!=type) { errcode=DTMISERR; return; }
*
XEXPRS1:	EQU    *
	JSR    NUMERIC
	BCS    XEXPRS4
	CMPA   #'$'
	BEQ    XEXPRS4
	CMPA   #'"'
	BNE    XEXPRS5
XEXPRS4:	JSR    GETCON
	BRA    XEXPRS7
XEXPRS5:	JSR    GETFUN
	TSTA
	BNE    XEXPRS7
	JSR    GETVAR
XEXPRS7:	LDAB   0,Y
	CMPB   #NULL
	BNE    XEXPRS8
	STAA   0,Y
XEXPRS8:	CMPA   0,Y
	BEQ    XEXPRS9
	LDAA   #DTMISERR
	JMP    RPTERR
XEXPRS9:	EQU    *
*
*
*/* now look for operator or end of expression */
*
*  chkoprtr:
*  c=*ibufptr;
*  if(c==EOL | c==MIDEOL | c==SPC | c==COMMA | c==SEMI | c==')')
*  {
*   return(c);
*  }
*
CHKOPRTR:	EQU    *
	JSR    GETCHR
	CMPA   #EOL
	BEQ    XEXPRS24
	CMPA   #MIDEOL
	BEQ    XEXPRS24
	CMPA   #SPC
	BEQ    XEXPRS24
	CMPA   #COMMA
	BEQ    XEXPRS24
	CMPA   #SEMI
	BEQ    XEXPRS24
	CMPA   #')'
	BEQ    XEXPRS24
*
*
*  if(type==NUM)
*  {
*   if(c=cknumop()) ;
*   else if(c=ckbolop()) ;
*   else if(ifwhflag) c=cklogop();
*   else c=NULL;
*  }
XEXPRS15:	EQU    *
	LDAA   0,Y
	CMPA   #NUM
	BNE    XEXPRS21
	JSR    CKNUMOP
	BCS    XEXPRS17
	JSR    CKBOLOP
	BCS    XEXPRS17
	TST    IFWHFLAG
	BEQ    XEXPRS18
	JSR    CKLOGOP
	BRA    XEXPRS17
XEXPRS18:	LDAA   #NULL
	BRA    XEXPRS17
*
*
*  else { errcode=IDTYERR; return; }
*
XEXPRS21:	EQU    *
	LDAA   #IDTYERR
	JMP    RPTERR
*
*
*  if(c==NULL) { errcode=OPRTRERR; return; }
*  *tbufptr++=c;
* }
* return;
*}
*
XEXPRS17:	EQU    *
	TSTA
	BNE    XEXPRS23
	LDAA   #OPRTRERR
	JMP    RPTERR
XEXPRS24:	INS
	PULY
	RTS
XEXPRS23:	JSR    PUTTOK
	JMP    XEXPRS29
*
*
*/***** cknumop() *****/
*
*cknumop()
*{
* if(match("+")) return(PLUSTOK);
* else if(match("-")) return(MINUSTOK);  
* else if(match("*")) return(MULTTOK);
* else if(match("/")) return(DIVTOK);
* else if(match("\\")) return(MODTOK);
* else if(match("^")) return(PWRTOK);
* else return(NULL);
*}
*
CKNUMOP:	EQU    *
	LDX    #NUMOPTBL
*
CKOP:	JSR    TBLSRCH
	BCS    CKOP1   
	LDAA   #NULL
CKOP1:	RTS
*
*
	
*/***** ckbolop() *****/
*
*ckbolop()
*{
* if(match("AND")) return(ANDTOK);
* else if(match("OR")) return(ORTOK);
* else if(match("EOR")) return(EORTOK);
* else return(NULL);
*}
*
CKBOLOP:	EQU    *
	LDX    #BOLOPTBL
	BRA    CKOP
*
*
	
*/***** cklogop() *****/
*
*cklogop()
*{
* if(match("<=")) return(LTEQTOK);
* else if(match(">=")) return(GTEQTOK);
* else if(match("<>")) return(NOTEQTOK);
* else if(match("<")) return(LTTOK);
* else if(match(">")) return(GTTOK);
* else if(match("=")) return(EQTOK);
* else return(NULL);
*}
*
CKLOGOP:	EQU    *
	LDX    #LOGOPTBL
	BRA    CKOP
*
*
*
*
*<><><><><> NOTE: THIS ROUTINE HAS NO 'C' COUNTER PART <><><><><><>
*
TBLSRCH:	EQU    *
	JSR    STREQ        ; SEARCH FOR STRING.
	BCS    TBLSRCH1     ; IF FOUND GO GET TOKEN & RETURN.
TBLSRCH2:	INX                 ; BUMP POINTER TO NEXT CHAR.
	LDAA   0,X          ; GET IT.
	BNE    TBLSRCH2     ; KEEP LOOKING FOR END OF ENTRY.
	INX                 ; FOUND IT. BUMP POINTER TO NEXT ENTRY.
	INX
	LDAA   0,X          ; AT THE END OF THE TABLE?
	BNE    TBLSRCH      ; NO. GO CHECK THE NEXT ENTRY.
	CLC                 ; YES. FLAG AS NOT FOUND.
	RTS                 ; RETURN.
TBLSRCH1:	LDAA   1,X          ; GET TOKEN.
	SEC                 ; FLAG AS FOUND.
	RTS                 ; RETURN.
*
*
NUMOPTBL:	EQU    *
PLUS:	FCC    "+"
	FCB    0
	FCB    PLUSTOK
MINUS:	FCC    "-"
	FCB    0
	FCB    MINUSTOK
MULT:	FCC    "*"
	FCB    0
	FCB    MULTTOK
DIV:	FCC    "/"
	FCB    0
	FCB    DIVTOK
MODS:	FCB    $5C,$00
	FCB    MODTOK
	FCB    0            ; END OF TABLE FLAG.
*
BOLOPTBL:	EQU    *
ANDS:	FCC    ".AND."
	FCB    0
	FCB    ANDTOK
ORS:	FCC    ".OR."
	FCB    0
	FCB    ORTOK
EORS:	FCC    ".EOR."
	FCB    0
	FCB    EORTOK
	FCB    0            ; END OF TABLE FLAG.
*
LOGOPTBL:	EQU    *
LTEQ:	FCC    "<="
	FCB    0
	FCB    LTEQTOK
GTEQ:	FCC    ">="
	FCB    0
	FCB    GTEQTOK
NOTEQ:	FCC    "<>"
	FCB    0
	FCB    NOTEQTOK
LT:	FCC    "<"
	FCB    0
	FCB    LTTOK
GT:	FCC    ">"
	FCB    0
	FCB    GTTOK
EQ:	FCC    "="
	FCB    0
	FCB    EQTOK
	FCB    0            ; END OF TABLE FLAG.
*
*
UINARYOP:	EQU    *
NEGS:	FCC    "-"
	FCB    0
	FCB    NEGTOK
NOTS:	FCC    "NOT"
	FCB    0
	FCB    NOTTOK
	FCB    0            ; END OF TABLE MARKER.
*
