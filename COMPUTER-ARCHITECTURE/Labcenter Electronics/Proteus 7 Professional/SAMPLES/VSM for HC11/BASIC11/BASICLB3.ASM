*        title    BASICLB3
*        page
*
*
*/***** getvar *****/
*
*/* tries to make a variable out of what is currently being pointed to by */
*/* 'ibufptr' and places it into the variable symbol table if it is not   */
*/* already there */
*
*getvar()
*{
* short vartype,cnt;
* char varname[3];
* int offset;
* for(cnt=0; cnt<=2; cnt++) { varname[cnt]=0; } /* clr out var name */
* if(alpha(*ibufptr)) { varname[0]=*ibufptr++; } /* is 1st char an alpha? */
*  else { errcode=ILVARERR; return(0); } /* no. error */
*
GETVAR:	EQU    *
	PSHY
	CLRA
	PSHA
	PSHA
	PSHA
	PSHA
	TSY
	JSR    GETCHR
	JSR    ALPHA
	BCS    GETVAR1
	LDAA   #ILVARERR
	JMP    RPTERR
GETVAR1:	jsr    ToUpper
	STAA   0,Y
	JSR    INCIBP
*
*
* if(alphanum(*ibufptr)) { varname[1]=*ibufptr++; }
* if((vartype=chcktyp())==0) { vartype=FVARTOK; }
*  else { ++ibufptr; }
*
	JSR    GETCHR
	JSR    ALPHANUM
	BCC    GETVAR2
	jsr    ToUpper
	STAA   1,Y
	JSR    INCIBP
GETVAR2:	JSR    CHCKTYP
	STAA   3,Y
*
*
* if((offset=findvar(vartype,varname))==-1) /* is var already in table? */
* {
*  if(errcode) return;
*  if((offset=putvar(vartype,varname))==-1) return;  /* no. put it there */
* }
* if(errcode) return;
*
	JSR    FINDVAR
	CPD    #-1
	BNE    GETVAR5
GETVAR4:	LDAA   3,Y
	JSR    PUTVAR
*
*
* *tbufptr++=vartype;    /* put variable type byte in token buffer */
* putint(offset);        /* put offset after it */
* if((vartype==IVARTOK) | (vartype==FVARTOK)) return(NUM);
* return(STRING);
*}
*
GETVAR5:	EQU    *
*        PSHD
	PSHB
	PSHA
	LDAA   3,Y
	JSR    PUTTOK
*        PULD
	PULA
	PULB
	JSR    PUTDTOK
	LDAA   3,Y           ; GET VARIABLE TYPE AGAIN.
	BITA   #$10          ; IS IT AN ARRAY VARIABLE?
	BEQ    GETVAR7       ; NO. CONTINUE.
	JSR    INCIBP        ; MOVE THE INPUT BUFFER POINTER PAST THE OPEN (.
	LDAA   #OPARNTOK
	JSR    PUTTOK
	LDAA   #NUM          ; YES. SUBSCRIPT EXPRESSION MUST BE NUMERIC.
	JSR    XEXPRES       ; GO GET THE SUBSCRIPT.
	JSR    GETNXCHR      ; GET THE TERMINATING CHARACTER.
	CMPA   #')'          ; IS IT A CLOSING PAREN?
	BEQ    GETVAR8       ; YES. GO FINISH UP.
	LDAA   #MPARNERR     ; NO. ERROR.
	JMP    RPTERR
GETVAR8:	LDAA   #CPARNTOK     ; GET CLOSING PAREN TOKEN.
	JSR    PUTTOK        ; PUT TOKEN IN BUFFER.
GETVAR7:	LDAA   #NUM          ; NO. RETURN PROPER TYPE.
	LDAB   3,Y
	BITB   #2
	BEQ    GETVAR6
	LDAA   #STRING
GETVAR6:	INS
	INS
	INS
	INS
	PULY
	RTS
*
*
*
*/***** chcktype *****/
*
*chcktyp()
*{
* if(*ibufptr=='%') return(IVARTOK);
*  else if(*ibufptr=='$') return(SVARTOK);
*  else return(0);
*}
*
CHCKTYP:	EQU    *
	LDAA   #IVARTOK        ; IN V1.0 ONLY INTEGER VARIABLES ARE SUPPORTED.
	PSHA                   ; IN V2.0 FLOATING POINT VARIABLES WILL BE
	JSR    GETCHR          ; SUPPORTED.
	CMPA   #'('            ; IS A SUBSCRIPT FOLLOWING THE NAME?
	PULA                   ; RESTORE THE TOKEN TYPE.
	BNE    CHCKTYP4        ; NO. RETURN.
	ADDA   #$10            ; YES. MAKE IT AN ARRAY VARIABLE.
CHCKTYP4:	RTS                    ; RETURN.
*
*/***** findvar *****/
*
*findvar(vartype,varname)
*short vartype;
*char *varname;
*{
* char *varptr;
* varptr=varbegin;               /* point to the start of the var table */
* while(*varptr)                 /* we're not to the end of the table */
*
FINDVAR:	EQU    *
	LDX    VARBEGIN
FINDVAR1:	TST    0,X
	BEQ    FINDVAR2
*
* {
*  if(*varptr==vartype)          /* is the current var the same type? */
*  {                             /* yes. */
*   if(streq(varptr+1,varname))  /* is the name the same? */
*   {                            /* yes. */
*    return(varptr-varbegin);    /* return the offset from the table start */
*   }
*  }
*
	CMPA   0,X
	BNE    FINDVAR3
	LDAB   1,X
	CMPB   0,Y
	BNE    FINDVAR3
	LDAB   2,X
	CMPB   1,Y
	BNE    FINDVAR3
	XGDX
	SUBD   VARBEGIN
	RTS
*
*  /* if not, advance to the next variable in the table */
*  if(*varptr==IVARTOK) varptr=varptr+ISIZ+3;
*  else if(*varptr==SVARTOK) varptr=varptr+SSIZ+3;
*  else if(*varptr==FVARTOK) varptr=varptr+FSIZ+3;
*  else { errcode=ILTOKERR; return(-1); }
* }
*
FINDVAR3:	EQU    *
	LDAB   0,X
	BITB   #$10          ; IS IT AN ARRAY VARIABLE?
	BEQ    FINDVAR8      ; NO CONTINUE.
	LDAB   #ASIZ+3       ; YES. GET ARRAY SIZE +3.
	BRA    FINDVAR7
FINDVAR8:	CMPB   #IVARTOK
	BNE    FINDVAR6
	LDAB   #ISIZ+3
FINDVAR7:	ABX
	BRA    FINDVAR1
FINDVAR6:	LDAA   #ILTOKERR
	JMP    RPTERR
FINDVAR2:	LDD    #-1
	RTS
*
* return(-1);
*}
*
*
*
*/***** putvar *****/
*
*putvar(vartype,varname)
*short vartype;
*char *varname;
*{
*short count,n;
*char *varadd;
* varadd=varend;         /* save begining addr of var we are storing */
* *varend++=vartype;     /* put token/type in variable symbol table */
* *varend++=*varname++;  /* put variable name in */
* *varend++=*varname++;
*
PUTVAR:	EQU    *
	LDX    VAREND
	PSHX
	STAA   0,X
	INX
	LDAB   0,Y
	STAB   0,X
	INX
	LDAB   1,Y
	STAB   0,X
	INX
*
* if(vartype==IVARTOK) count=ISIZ+1;     /* determine # of bytes for this */
* else if(vartype==SVARTOK) count=SSIZ+1;/* variable */
* else if(vartype==FVARTOK) count=FSIZ+1;
* else { errcode=ILTOKERR; return(-1); }
* for(n=1;n<=count;n++) *varend++=0;      /* zero the storage */
* --varend;
* if(varend > varmend) { errcode=OMEMERR; return(-1); } /* memory overflow? */
* vmemavil-=count;       /* decrement the amt of avail memory */
* return(varadd-varbegin);       /* return offset */
*}
*
	BSR    CLRVAR
	CLR    0,X          ; CLEAR 1 BYTE BEYOND THE END OF THE VAR AREA.
	STX    VAREND
	CPX    VARMEND
	BLS    PUTVAR5
	LDAA   #OMEMERR
	BRA    CLRVAR6
PUTVAR5:	EQU    *
*        PULD
	PULA
	PULB
	SUBD   VARBEGIN
*        PSHD                ; SAVE THE OFFSET TO THIS VARIABLE.
	PSHB
	PSHA
	JSR    CCLEAR3      ; CLEAR ALL VARIABLES SINCE WE MAY HAVE TRASHED
*                            ANY ARRAYS THAT HAD BEEN ALLOCATED.
*        PULD                RESTORE THE "NEW" VARIABLE OFFSET.
	PULA
	PULB
	RTS
*
*
CLRVAR:	EQU    *
	BITA   #$10          ; IS IT AN ARRAY VARIABLE?
	BEQ    CLRVAR8       ; NO. CONTINUE.
	LDAB   #ASIZ         ; YES. GET THE DICTIONARY SIZE+1.
	BRA    CLRVAR1       ; PUT THE VARIABLE IN THE DICTIONARY.
CLRVAR8:	CMPA   #IVARTOK
	BNE    CLRVAR4
	LDAB   #ISIZ
CLRVAR1:	EQU    *
	CLR    0,X
	INX
	DECB
	BNE    CLRVAR1
	RTS
CLRVAR4:	LDAA   #ILTOKERR
CLRVAR6:	JMP    RPTERR
*
*
*/***** getcon() *****/
*
*getcon()
*{
* int const;
* char *litp;
* short count;
* litp=ibufptr;          /* save a pointer to start of constant */
* if(*ibufptr=='"') { getscon(); return(STRING); } /* if " get strng */
*
GETCON:	EQU    *
	JSR    GETCHR
*
*
*  else if(*ibufptr=='$') { ++ibufptr; const=gethex(); } /* if '$' get hex */
*  else const=getdeci();         /* else assume its a decimal constant */
* if(errcode) return(0);         /* if error abort */
*
GETCON2:	EQU    *
	LDX    IBUFPTR
	PSHX
	CMPA   #'$'
	BNE    GETCON3
	JSR    INCIBP
	JSR    GETHEX
	BRA    GETCON4
GETCON3:	JSR    GETDECI
*
*
* *tbufptr++=ICONTOK;            /* put integer constant token in buffer */
* putint(const);                 /* follow it with the constant */
* count=ibufptr-litp;    /* get number of bytes in source form of const. */
* *tbufptr++=count;       /* put it in the token buffer */
* while(litp < ibufptr) *tbufptr++=*litp++; /* copy source form into buffer */
* return(NUM);           /* return the constant type */
* }
*
GETCON4:	EQU    *
	PSHA
	LDAA   #ICONTOK
	JSR    PUTTOK
	PULA
	JSR    PUTDTOK
	LDD    IBUFPTR
	TSX
	SUBD   0,X
	TBA
	JSR    PUTTOK
	PULX
GETCON5:	LDAA   0,X
	JSR    PUTTOK
	INX
	DECB
	BNE    GETCON5
	LDAA   #NUM
	RTS
*
*
*/***** getdeci() *****/
*
*getdeci()
*{
* char c;
* int num;
* num=0;
* if(numeric(*ibufptr)==0)       /* is 1st char numeric? */
*  { errcode=SYTXERR; return; }  /* no. flag error & return */
* while(numeric(c=*ibufptr))     /* yes. while *ibufptr is numeric */
* {
*  num=num*10+(c-'0');           /* build number */
*  if(num < 0) { errcode=INTOVERR; return; }     /* if <0 flag error & ret */
*  ++ibufptr;
* }
* return(num);           /* return the value */
*}
*
GETDECI:	EQU    *
	PSHY
	CLRA
	PSHA
	PSHA
	TSY
	LDX    IBUFPTR
	LDAA   0,X
	JSR    NUMERIC
	BCS    GETDECI1
	LDAA   #SYTXERR
	BRA    CHCKERR
GETDECI1:	LDAA   0,X
	JSR    NUMERIC
	BCC    GETDECI3
	JSR    ADDDIG
	BPL    GETDECI1
	LDAA   #INTOVERR
	BRA    CHCKERR
GETDECI3:	STX    IBUFPTR
	LDD    0,Y
	INS
	INS
	PULY
	RTS
*
*
*/***** gethex() *****/
*
*gethex()
*{
* char c;
* short count;
* int num;
* num=count=0;
* if(hexdig(*ibufptr)==0)        /* is the char a hex digit? */
*  { errcode=IVHEXERR; return; } /* no. flag error & return */
*
GETHEX:	EQU    *
	PSHY
	CLRA
	PSHA
	PSHA
	TSY
	LDX    IBUFPTR
	LDAA   0,X
	JSR    HEXDIG
	BCS    GETHEX1
	LDAA   #IVHEXERR
CHCKERR:	TST    RUNFLAG
	BEQ    GETHEX5
	JMP    RPTRERR
GETHEX5:	JMP    RPTERR
*
*
* while(hexdig(c=*ibufptr))      /* while a hex digit is in the buffer */
* {
*  if(numeric(c)) num=num*16+(c-'0');  /* build the number */
*   else num=num*16+(c-55);
*  if(count++ > 4) 
*   { errcode=HEXOVERR; return; }  /* if over 4 digits flag overflow & ret */
*  ++ibufptr;
* }
* return(num);   /* return constant value */
*}
*
GETHEX1:	EQU    *
	LDAA   0,X
	JSR    HEXDIG
	BCC    GETDECI3
	LDD    0,Y
	LSLD
	BCS    GETHEX3
	LSLD
	BCS    GETHEX3
	LSLD
	BCS    GETHEX3
	LSLD
	BCS    GETHEX3
	STD    0,Y
	LDAA   0,X
	 JSR	ToUpper
	 TAB
	INX
	SUBB   #'0'
	CMPB   #9
	BLS    GETHEX4
	SUBB   #7
GETHEX4:	CLRA
	ADDD   0,Y
	STD    0,Y
	BRA    GETHEX1
GETHEX3:	LDAA   #HEXOVERR
	BRA    CHCKERR
*
*
*/***** hexdig() *****/
*
*hexdig(c)
*char c;
*{
* return(numeric(c) | (c>='A' & c<='F')); /* return true if c is hex */
*}
*
HEXDIG:	EQU    *
	JSR    NUMERIC
	BCC    HEXDIG1
	RTS
HEXDIG1:	JSR    ToUpper
	CMPA   #'A'
	BLO    HEXDIG2
	CMPA   #'F'
	BHI    HEXDIG2
	SEC
	RTS
HEXDIG2:	CLC
	RTS
*
*
*/***** getscon *****/
*
*getscon()
*{
* short count;
* char *bufptr,c;
* count=2;       /* initalize byte count to 2 */
* *tbufptr++=SCONTOK;   /* put string constant token in buffer */
* bufptr=tbufptr++;   /* save value of tbufptr, advance to next byte, */
*                     /* and reserve a byte for string length */
* *tbufptr++=*ibufptr++;   /* put 1st quote in token buffer */
*
GETSCON:	EQU    *
	LDAB   #2
	LDAA   #SCONTOK
	JSR    PUTTOK
	LDX    TBUFPTR
	PSHX
	CLRA
	JSR    PUTTOK
	JSR    GETNXCHR     ; PUT FIRST QUOTE IN TOKEN BUFFER.
	JSR    PUTTOK
*
*
* while(((c=*ibufptr) != '"'))
* {
*  if(c==EOL)             /* if we hit EOL */
*   { errcode=MISQUERR; return; } /* flag error & return */
*  *tbufptr++=c;         /* if not, put next char in buffer */
*  ++ibufptr;            /* advance input buffer pointer */
*  ++count;              /* up byte count */
* }
*
GETSCON1:	EQU    *
	JSR    GETNXCHR
	CMPA   #'"'
	BEQ    GETSCON2
	CMPA   #EOL
	BNE    GETSCON3
	LDAA   #MISQUERR
	JMP    RPTERR
GETSCON3:	JSR    PUTTOK
	INCB
	BRA    GETSCON1
*
* *tbufptr++=c;          /* put closing quote in token buffer */
* ++ibufptr;             /* advance input buffer pointer */
* *bufptr=count;         /* put string byte count in token buffer */
* return;
*}
*
GETSCON2:	EQU    *
	JSR    PUTTOK
GETSCON4:	PULX
	STAB   0,X
	RTS
*
*
