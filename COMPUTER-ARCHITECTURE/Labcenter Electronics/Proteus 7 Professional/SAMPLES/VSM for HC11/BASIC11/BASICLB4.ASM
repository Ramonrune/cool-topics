*        title    BASICLB4
*        page
*
*
*/***** xon *****/
*
*xon()
*{
* int num;
* *tbufptr++=ONTOK;      /* put ON token in buffer */
* blanks();              /* skip any blanks */
* xexpres(NUM);          /* get the expression */
* if(errcode) return;    /* if error, return */
* blanks();              /* skip any blanks */
* if(match("GOTO")) xgoto();     /* check for GOTO */
* else if(match("GOSUB")) xgosub();      /* check for GOSUB */
* else errcode=IONSYERR;         /* if neither, flag an error */
* if(errcode) return;            /* if error, return */
* blanks();              /* skip blanks */
*
*
XON:	EQU    *
*        JSR    BLANKS
	LDAA   #NUM
	JSR    XEXPRES
XON1:	JSR    BLANKS
	LDX    #GOTO
	JSR    STREQ
	BCC    XON2
	LDAA   #GOTOTOK
	JSR    PUTTOK
	JSR    BLANKS
	JSR    XGOTO
	BRA    XON5
XON2:	LDX    #GOSUB
	JSR    STREQ
	BCS    XON4
	LDAA   #IONSYERR
	JMP    RPTERR
XON4:	LDAA   #GOSUBTOK
	JSR    PUTTOK
	JSR    BLANKS
	JSR    XGOSUB
XON5:	JSR BLANKS
*
*
* while(*ibufptr==',')   /* do until EOL */
* {
*  *tbufptr++=COMMATOK;  /* put COMMA token in buffer */
*  ++ibufptr;            /* advance the input buffer pointer */
*  blanks();             /* skip blanks */
*  *tbufptr++=LCONTOK;   /* put line number constant token in buffer */
*  num=getlinum();       /* get line number */
*  if(num==0) errcode=LINENERR;   /* if 0, line number error */
*  if(errcode) return;    /* if error, return */
*  putint(num);           /* put line number in buffer */
*  blanks();              /* skip blanks */
* }
* return;
*}
*
	JSR    CHKCOMA
	BCS    XON6
	RTS
XON6:	JSR    BLANKS
	LDAA   #LCONTOK
	JSR    PUTTOK
	JSR    GETLINUM
XON8:	JSR    PUTDTOK
	BRA    XON5
*
*
XONIRQ:	EQU    *            ; "ONIRQ" HAS A FUNCTION CODE & LINE NUMBER.
XONTIME:	EQU    *
	LDAA   #NUM         ; GO GET THE VALUE OF THE TIMER WE SHOULD GO ON.
	JSR    XEXPRES
	JSR    BLANKS       ; SKIP BLANKS.
	JSR    CHKCOMA      ; GO CHECK FOR A COMMA.
	BCS    XONTIME1     ; IF PRESENT, IT'S OK.
XONTIME2:	LDAA   #MCOMAERR    ; IF NOT, REPORT AN ERROR.
	JMP    RPTERR
XONTIME1:	JSR    BLANKS
	LDAA   #LCONTOK     ; GET THE LINE CONSTANT TOKEN.
	JSR    PUTTOK       ; PUT IT IN THE TOKEN BUFFER.
	JSR    GETLINUM     ; GO GET A LINE NUMBER.
	JMP    PUTDTOK      ; PUT THE LINE NUMBER IN THE TOKEN BUFFER.
*
*
XONPACC:	EQU    *
	BSR    GETARG       ; GET AN ARGUMENT AND A COMMA.
	BRA    XONTIME      ; GO USE SOME OTHER CODE.
*
*
GETARG:	LDAA   #NUM         ; GO GET THE "OPERATING MODE" EXPRESSION.
	JSR    XEXPRES
	JSR    BLANKS       ; SKIP BLANKS.
	JSR    CHKCOMA      ; GO CHECK FOR COMMA.
	BCC    XONTIME2     ; NO COMMA. REPORT ERROR.
	JMP    BLANKS       ; SKIP BLANKS AFTER COMMA AND RETURN.

*
*
*
*/***** xif() *****/
*
*xif()
*{
*int num;
* *tbufptr++=IFTOK;              /* put if token in the buffer */
* blanks();                      /* skip any blanks */
* ifwhflag=1;                    /* let xexpres() know we are doing an IF */
* xexpres(NULL);                 /* get relational expression */
* if(errcode) return;            /* if error, return */
* blanks();                      /* if not, skip blanks */
*
*
XIF:	EQU    *
*        JSR    BLANKS
	INC    IFWHFLAG
	LDAA   #NUM
	JSR    XEXPRES
XIF1:	JSR    BLANKS
*
*
* if(match("THEN"))              /* check for "THEN" clause */
* {
*  *tbufptr++=THENTOK;           /* put THEN token in the buffer */
*  blanks();                     /* skip any blanks after "THEN" */
*
*
	LDX    #THENS
	JSR    STREQ
	BCS    XIF2
	LDAA   #MTHENERR
	JMP    RPTERR
*
*
*  if(numeric(*ibufptr))         /* is a line number present after THEN? */
*  {                             /* yes */
*   *tbufptr++=LCONTOK;          /* put line # const. token in buffer */
*   num=getlinum();              /* get the line # */
*   if(num==0) errcode=LINENERR;
*   if(errcode) return;          /* if error, return */
*   putint(num);                 /* put number in buffer */
*  }
*  else                          /* not a line #, check for statement */
*  {
*   xlate();             /* try to make a statement out of what follows */
*   if(errcode) return;          /* if error, return */
*  }
* }
*
*
XIF2:	EQU    *
	LDAA   #THENTOK
	JSR    PUTTOK
	JSR    BLANKS
	JSR    GETCHR
	JSR    NUMERIC
	BCC    XIF9
*
XIF3:	LDAA   #LCONTOK
	JSR    PUTTOK
	JSR    GETLINUM
XIF6:	JSR    PUTDTOK
*
*
* else                   /* if "THEN" not present */
* {
*  errcode=MTHENERR;             /* flag a missing THEN error */
*  return;
* }
*
*
* blanks();                      /* skip any blanks after object of THEN */
* if(match("ELSE"))              /* is "ELSE" clause present? */
* {                              /* yes */
*  *tbufptr++=ELSETOK;           /* put ELSE token in the buffer */
*  blanks();                     /* skip any blanks after ELSE */
*
*
XIF4:	EQU    *
	JSR    BLANKS
	LDX    #ELSES
	JSR    STREQ
	BCS    XIF7
	RTS
XIF7:	LDAA   #ELSETOK
	JSR    PUTTOK
	JSR    BLANKS
*
*
*  if(numeric(*ibufptr))         /* is a line # present after ELSE */
*  {                     /* yes */
*   *tbufptr++=LCONTOK;          /* put line # const. token in buffer */
*   num=getlinum();              /* get the line # */
*   if(num==0) errcode=LINENERR;
*   if(errcode) return;          /* if error, return */
*   putint(num);                 /* put number in buffer */
*  }
*  else          /* line # not present, try to xlate a statement */
*  {
*   xlate();
*  }
* }
*
*
	JSR    GETCHR
	JSR    NUMERIC
	BCS    XIF8
XIF9:	LDAA   #LINENERR
	JMP    RPTERR
XIF8:	LDAA   #LCONTOK
	JSR    PUTTOK
	JSR    GETLINUM
XIF10:	JMP    PUTDTOK
*
* return;                /* in any case, return */
*}
*
*
THENS:	FCC    "THEN"
	FCB    0
ELSES:	FCC    "ELSE"
	FCB   0
*
*
*/***** xfor() *****/
*
*xfor()
*{
* short type;
* *tbufptr++=FORTOK;             /* put for token in buffer */
* blanks();              /* skip blanks between FOR & assignment statement */
* type=getvar();         /* get variable */
* if((type!=NUM)|(*ibufptr++!='='))      /* is it a numerical variable? */
* { errcode=IVEXPERR; return; }  /* no. flag error & return */
*
*
XFOR:	EQU    *
*        JSR    BLANKS
	JSR    GETVAR
	CMPA   #NUM
	BEQ    XFOR1
XFOR2:	LDAA   #IVEXPERR
	JMP    RPTERR
XFOR1:	JSR    GETNXCHR
	CMPA   #'='
	BNE    XFOR2
*
*
* *tbufptr++=EQUALTOK;   /* put equals token in buffer */
* xexpres(NUM);          /* go get a numerical expression */
* if(errcode) return;    /* if error, return */
* blanks();              /* skip blanks */
*
*
	LDAA   #EQUALTOK
	JSR    PUTTOK
	LDAA   #NUM
	JSR    XEXPRES
	JSR    BLANKS
*
*
* if(match("TO"))        /* is TO present? */
* {                      /* yes */
*  *tbufptr++=TOTOK;     /* put TO token in buffer */
*  blanks();             /* skip blanks */
*  xexpres(NUM);         /* get the "TO" expression */
*  if(errcode) return;   /* return if error */
* }
* else                   /* "TO" not present */
* {
*  errcode=MTOERR;       /* set error flag & return */
*  return;
* }
*
*
	LDX    #TO
	JSR    STREQ
	BCS    XFOR4
	LDAA   #MTOERR
	JMP    RPTERR
XFOR4:	LDAA   #TOTOK
	JSR    PUTTOK
	JSR    BLANKS
	LDAA   #NUM
	JSR    XEXPRES
*
*
* blanks();              /* skip blanks */
* if(match("STEP"))      /* is optional "STEP" clause present? */
* {                      /* yes */
*  *tbufptr++=STEPTOK;   /* put STEP token in buffer */
*  blanks();             /* skip blanks */
*  xexpres(NUM);         /* get expression */
* }
* return;
*}
*
*
	JSR    BLANKS
	LDX    #STEP
	JSR    STREQ
	BCS    XFOR3
	RTS
XFOR3:	LDAA   #STEPTOK
	JSR    PUTTOK
	JSR    BLANKS
	LDAA   #NUM
	JMP    XEXPRES
*
*
TO:	FCC    "TO"
	FCB    0
STEP:	FCC    "STEP"
	FCB    0
*
*
*/***** xnext() *****/
*
*xnext()
*{
* *tbufptr++=NEXTTOK;    /* put NEXT token in buffer */
* blanks();              /* skip blanks */
* if(getvar()!=NUM) errcode=SYTXERR;     /* get variable, must be numeric */
* return;
*}
*
*
XNEXT:	EQU    *
*        JSR    BLANKS
	JSR    GETVAR
	CMPA   #NUM
	BEQ    XNEXT1
	LDAA   #SYTXERR
	JMP    RPTERR
XNEXT1:	RTS
*
*
*/***** xprint() *****/
*
*xprint()
*{
* *tbufptr++=PRINTTOK;   /* put PRINT token in buffer */
* blanks();             /* skip blanks */
*
*
XPRINT:	EQU    *
*        JSR    BLANKS
	JSR    GETCHR
	CMPA   #'#'       ; HAS AN ALTERNATE PORT BEEN SPECIFIED?
	BNE    XPRINT9    ; NO. GO PROCESS THE REST OF THE PRINT STATEMENT.
	LDAA   #PNUMTOK   ; YES. PUT THE TOKEN INTO THE BUFFER.
	JSR    PUTTOK     ; DO IT.
	JSR    INCIBP     ; POINT PAST THE "#".
	JSR    BLANKS     ; SKIP SPACES BETWEEN '#' AND EXPRESION.
	BRA    XPRINT7    ; GO GET EXPRESSION & CONTINUE.
*
*
	
* while((*ibufptr!=EOL)|(*ibufptr!=MIDEOL))    /* do until end of line */
* {
*  xexpres(NULL);        /* get expression */
*  if(errcode) return;   /* if error, return */
*  blanks();             /* skip blanks */
*  if(*ibufptr==COMMA) *tbufptr=COMMATOK;        /* check for comma */
*  else if(*ibufptr==SEMI) *tbufptr=SEMITOK;     /* check for semicolin */
*  else return;          /* if neither, return */
*  ++ibufptr;            /* advance input buffer pointer */
*  ++tbufptr;            /* advance token buffer pointer */
*  blanks();             /* skip blanks after delimeter */
* }
* return;
*}
XPRINT9:	JSR    BLANKS
	JSR    GETCHR
	CMPA   #EOL
	BEQ    XPRINT2
	CMPA   #MIDEOL
	BNE    XPRINT3
XPRINT2:	RTS
XPRINT3:	JSR    GETCHR       ; GET THE NEXT CHARACTER IN THE BUFFER.
	CMPA   #'"'         ; IS IT A STRING CONSTANT?
	BNE    XPRINT7
	JSR    GETSCON      ; YES. GO GET A STRING CONSTANT.
	BRA    XPRINT8      ; CONTINUE.
XPRINT7:	LDAA   #NUM
	JSR    XEXPRES
XPRINT8:	JSR    BLANKS
	JSR    GETCHR
	CMPA   #EOL
	BEQ    XPRINT2
	CMPA   #MIDEOL
	BEQ    XPRINT2
	BSR    CHKCOMA
	BCS    XPRINT9
XPRINT4:	CMPA   #SEMI
	BEQ    XPRINT6
	LDAA   #MCMSMERR
	JMP    RPTERR
XPRINT6:	LDAA   #SEMITOK
	BSR    CHKCOMA2
	BRA    XPRINT9
*
*
CHKCOMA:	JSR    GETCHR          ; GET CHARACTER FROM INPUT BUFFER.
	CMPA   #COMMA          ; IS IT A COMMA?
	BEQ    CHKCOMA1        ; YES. PUT IT IN THE TOKEN BUFFER.
	CLC                    ; NO. FLAG NO COMMA FOUND.
	RTS                    ; RETURN.
CHKCOMA1:	LDAA   #COMMATOK       ; GET THE COMMA TOKEN.
CHKCOMA2:	JSR    PUTTOK          ; PUT THE TOKEN IN THE BUFFER.
	JSR    INCIBP          ; BUMP THE INPUT BUFFER POINTER.
	SEC
	RTS                    ; RETURN.
*
*
*/***** xinput() *****/
*
*xinput()
*{
* *tbufptr++=INPUTTOK;           /* put INPUT token in buffer */
* blanks();                      /* skip blanks */
*
*
XINPUT:	EQU    *
*        JSR    BLANKS
	BSR    XCHKDEV         ; GO CHECK FOR AN ALTERNATE DEVICE NUMBER.
*
*
* if(*ibufptr=='"')              /* is a prompt included? */
* {                      /* yes */
*  getscon();            /* get the string constant */
*  if(errcode) return;   /* if error, return */
*  if(*ibufptr!=COMMA) { errcode=SYTXERR; return; }
*  *tbufptr++=COMMATOK;
*  ++ibufptr;
* }
* inreadcm();            /* get the input variable list */
* return;
*}
*
*
XINPUT2:	JSR    BLANKS
	JSR    GETCHR
	CMPA   #'"'
	BNE    INREADCM
	JSR    GETSCON
	BSR    CHKCOMA         ; IF COMMA PRESENT, PUT IN TOKEN BUFFER.
	BCS    INREADCM
XINPUT3:	LDAA   #MCOMAERR
	JMP    RPTERR
*
*
*/***** inreadcm() *****/
*
*inreadcm()
*{
* while(1)               /* do forever */
* {
*  blanks();             /* skip blanks */
*  getvar();             /* get a variable */
*  if(errcode) return;   /* if error, return */
*  blanks();             /* skip blanks */
*  if(*ibufptr==COMMA) 
*  {
*   *tbufptr++=COMMATOK;      /* put delimiter in buffer */
*   ++ibufptr;                /* and point to the next char in the buffer */
*  }
*  else return;          /* if no delimiter return */
* }
*}
*
XDIM:	EQU    *
INREADCM:	EQU    *
XREAD:	EQU    *
*        JSR    BLANKS
	JSR    GETVAR
XREAD1:	JSR    BLANKS
	BSR    CHKCOMA
	BCS    XREAD
	RTS
*
*
*
XCHKDEV:	EQU    *
	JSR    GETCHR
	CMPA   #'#'       ; HAS AN ALTERNATE PORT BEEN SPECIFIED?
	BEQ    XCHKDEV1   ; NO. GO PROCESS THE REST OF THE PRINT STATEMENT.
	RTS               ; RETURN.
XCHKDEV1:	LDAA   #PNUMTOK   ; YES. PUT THE TOKEN INTO THE BUFFER.
	JSR    PUTTOK     ; DO IT.
	JSR    INCIBP     ; POINT PAST THE "#".
	JSR    BLANKS     ; SKIP SPACES BETWEEN '#' AND EXPRESION.
	LDAA   #NUM       ; EXPRESSION MUST BE NUMERIC.
	JSR    XEXPRES    ; GO GET THE EXPRESSION.
	JSR    BLANKS     ; SKIP SPACES.
	BSR    CHKCOMA    ; GO GET COMMA THAT MUST FOLLOW THE EXPRESSION.
	BCC    XINPUT3    ; MISSING COMMA. GO REPORT THE ERROR.
	RTS               ; IT WAS THERE. GO PROCESS THE REST OF THE STATEMENT.
*
*
*
XINBYTE:	EQU    *
	BSR    XCHKDEV    ; GO CHECK FOR ALTERNATE DEVICE.
	JSR    BLANKS     ; SKIP BLANKS AFTER COMMA.
	JMP    GETVAR     ; GO TRY TO GET A VARIABLE.
*
*
*
*
*/***** xread *****/
*
*xread()
*{
* *tbufptr++=READTOK;    /* put read token in buffer */
* inreadcm();            /* get the variable list */
* return;
*}
*
*/***** xrestore() *****/
*
*xrestore()
*{
* *tbufptr++=RESTRTOK;   /* put RESTORE token in buffer */
* return;
*}
*
*/***** xwhile() *****/
*
*xwhile()
*{
* *tbufptr++=WHILETOK;   /* put WHILE token in buffer */
* blanks();              /* skip blanks */
* ifwhflag=1;            /* indicate we are going to get a WHILE expression */
* xexpres(NULL);         /* get expression */
* return;
*}
*
*
XWHILE:	EQU    *
*        JSR    BLANKS
	INC    IFWHFLAG
	LDAA   #NULL
	JMP    XEXPRES
*
*
*/***** xendwh() *****/
*
*xendwh()
*{
* *tbufptr++=ENDWHTOK;   /* put ENDWH token in buffer */
* return;
*}
*
*
XPACC:	EQU    *
XTIME:	EQU    *
	LDAB   #NUM         ; SETUP TO USE CODE IN "ASIGNMT".
	JMP    ASIGNMT1     ; GO DO ASSIGNMENT STATEMENT.
*
*
*
*/***** rpterr() *****/
*
*rpterr()
*{
*char *ptr,c;
* ptr=inbuff;    /* point to start of input buffer */
* nl();
* nl();
* while((c=*ptr++)!=EOL) outbyte(c);     /* print the input buffer */
*
*
RPTERR:	EQU    *
	STAA   ERRCODE
	JSR    NL2
	LDX    INBUFFS
RPTERR1:	LDAA   0,X
	CMPA   #EOL
	BEQ    RPTERR2
	JSR    OUTBYTE
	INX
	BRA    RPTERR1
*
*
* nl();          /* go to next line */
* ptr=inbuff;    /* point to begining of input buffer */
* while(ptr++ < ibufptr-2) outbyte('*');    /* output '*' to point of error */
* pl("^^^");  /* point to error */
* nl();
*
*
RPTERR2:	EQU    *
	JSR    NL
	LDX    IBUFPTR
	DEX
	DEX
	CPX    INBUFFS
	BLS    RPTERR4
	STX    IBUFPTR
	LDX    INBUFFS
	LDAA   #'*'
RPTERR3:	JSR    OUTBYTE
	INX
	CPX    IBUFPTR
	BNE    RPTERR3
RPTERR4:	LDX    #ARROWS
	JSR    PL
	JSR    NL
	BSR    RPTERR5
RPTERR6:	LDAA   #1
	STAA   CONTFLAG
	JMP    MAIN3
*
*
* pl("ERROR # ");
* outdeci(errcode);
* return;
*}
*
*
RPTERR5:	LDX    #ERRORS
	JSR    PL
	LDAB   ERRCODE
	CLRA
	JMP    OUTDECI
*
*
ARROWS:	FCC    "^^^"
	FCB    0
ERRORS:	FCC    "ERROR # "
	FCB    0
*
*
RPTRERR:	EQU    *             ; REPORT A RUN TIME ERROR.
	STAA   ERRCODE
	JSR    RPTERR5
RPTRERR1:	LDX    #INLINE
	JSR    PL
	LDD    CURLINE
	JSR    OUTDECI
	JSR    NL
	LDAA   #1
	STAA   CONTFLAG
	JMP    MAINW
*
*
BREAKS:	FCC    "BREAK"
INLINE:	FCC    " IN LINE # "
	FCB    0
        $IF     HC11 = 0
*
*
*/***** outdeci() *****/
*
*outdeci(num)
*short num;
*{
* int k,zs;
* char c;
* zs=0;
* k=10000;
* if(num<0)
* {
*  num=(-num);
*  outbyte('-');
* }
*
*
OUTDECI:	EQU    *
	CPD    #0
	BNE    OUTDECI7
	LDAA   #'0'
	JMP    OUTBYTE
OUTDECI7:	PSHY
*        PSHD
	PSHB
	PSHA
	CLRB
	PSHB
	PSHB
	TSY
	LDD    2,Y
	BPL    OUTDECI1
	COMA
	COMB
	ADDD   #1
	STD    2,Y
	LDAA   #'-'
	JSR    OUTBYTE
*
*
* while(k>=1)
* {
*  c=num/k+'0';
*  if((c!='0') | (k==1) | (zs)) { zs=1; outbyte(c); }
*  num=num%k;
*  k=k/10;
* }
* return;
*}
*
*
OUTDECI1:	EQU    *
	LDX    #PWRTEN
OUTDECI2:	LDD    2,Y
	CLR    1,Y
OUTDECI3:	SUBD   0,X
	BMI    OUTDECI5
	INC    1,Y
	BRA    OUTDECI3
OUTDECI5:	ADDD   0,X
	STD    2,Y
	LDAA   1,Y
	BNE    OUTDECI6
	TST    0,Y
	BEQ    OUTDECI4
OUTDECI6:	ADDA   #$30
	LDAB   #1
	STAB   0,Y
	JSR    OUTBYTE
OUTDECI4:	INX
	INX
	TST    1,X
	BNE    OUTDECI2
	INS
	INS
	INS
	INS
	PULY
	RTS
	
*
*
PWRTEN:	FDB    10000
	FDB    1000
	FDB    100
	FDB    10
	FDB    1
	FDB    0
*
        $ELSE
*
OUTDECI:	EQU    *
	CPD    #0
	BNE    OUTDECI1
	LDAA   #'0'
	JMP    OUTBYTE
OUTDECI1:	EQU    *
	PSHY
*        PSHD                ; SAVE THE NUMBER TO PRINT.
	PSHB
	PSHA
	LDD    #10000       ; NUMBER TO START DIVIDING BY.
*        PSHD
	PSHB
	PSHA
	CLRB                ; SET INITAL VALUE OF LEADING ZERO SUPRESS FLAG.
	PSHB
	TSY
	LDD    3,Y          ; IS THE NUMBER NEGATIVE?
	BPL    OUTDECI2     ; NO. GO PRINT THE NUMBER.
	COMA                ; YES. MAKE THE NUMBER POSITIVE.
	COMB                ; (TWO'S COMPLEMENT)
	ADDD   #1
	STD    3,Y          ; SAVE THE RESULT.
	LDAA   #'-'         ; PRINT A MINUS SIGN TO SHOW IT'S NEGATIVE.
	JSR    OUTBYTE
OUTDECI2:	LDD    3,Y          ; GET THE DIVIDEND.
	LDX    1,Y          ; GET THE DIVISOR.
	IDIV                ; DO THE DIVIDE.
	STD    3,Y          ; SAVE THE REMAINDER.
	XGDX                ; PUT QUOTIENT IN D.
	CPD    #0           ; IS THE QUOTIENT 0?
	BNE    OUTDECI3     ; NO. GO OUTPUT THE NUMBER.
	TST    0,Y          ; YES. ARE WE STILL SUPRESSING LEADING ZEROS?
	BEQ    OUTDECI4     ; YES. DON'T PRINT THE NUMBER.
OUTDECI3:	TBA                 ; PUT THE NUMBER IN THE A-REG.
	ADDA   #$30         ; MAKE THE NUMBER ASCII.
	LDAB   #1           ; MAKE THE ZERO SUPRESS FLAG NON-ZERO.
	STAB   0,Y
	JSR    OUTBYTE      ; OUTPUT THE NUMBER.
OUTDECI4:	LDD    1,Y          ; GET CURRENT DIVISOR.
	LDX    #10          ; DIVIDE IT BY 10.
	IDIV
	STX    1,Y          ; SAVE RESULT. ARE WE DONE?
	BNE    OUTDECI2     ; NO KEEP GOING.
	LDAB   #5           ; DEALLOCATE LOCALS.
	ABY
	TYS
	PULY                ; RESTORE Y.
	RTS                 ; RETURN.
*
*
        $ENDIF
*
*
