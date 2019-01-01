*        title    LEDITOR.TXT
*        page
*/***** storlin() *****/
*
*storlin()
*{
* int *numptr,*linum;
* numptr=tknbuf;                 /* get int pointer into token buffer */
* if(*numptr>hiline)             /* line # larger than current hi line*/
* {
*  apendlin();                   /* append it to the end of the buffer */
*  hiline=*numptr;               /* make it the current hi line number */
*  return;
* }
*
*
STORLIN:	EQU    *
	LDAA   #1		;set the continue flag.
	STAA   CONTFLAG	; we don't allow continues if the program has been altered.
	LDX	TKNBUFS	; point to the start of the token buffer
	LDD    0,X	; get the first 2 bytes of the token buffer (the line number).
	CPD    HILINE	; was the entered lines number higher than the highest so far?
	BLS    STORLIN1	; no. go do an insert or replace operation.
	JSR    APENDLIN	; yes. just append the line to the end of the program buffer.
	LDX    TKNBUFS	; point to the start of the token buffer
	LDD    0,X	; get the first 2 bytes of the token buffer (the line number).
	STD    HILINE
	RTS		; return.
*
*
* linum=findline(*numptr);       /* look for line # in the program buffer */
* if(*linum==*numptr)            /* is it the same line #? */
* {
*  repline(linum);               /* yes. replace it with the new line */
*  return;
* }
* insrtlin(linum);               /* no. insert the new line in the buffer */
* return;
*}
*
*
STORLIN1:	EQU    *
	BSR    FINDLINE
	LDD    0,X
	PSHX
	LDX    TKNBUFS
	CPD    0,X
	PULX
	BNE    INSRTLIN
	JMP    REPLINE
*
*
* /***** delline() *****/
*
*delline(num)            /* delete line from basic buffer */
*int num;
*{
* int *linum;
* char *ptr;
* if(num > hiline) return;       /* line number can't be there, return */
* linum=findline(num);           /* look for the requested line # */
*
*
DELLINE:	EQU    *
*        PSHD		; SAVE THE LINE NUMBER TO DELETE.
	PSHB
	PSHA
	TSY		; POINT TO THE LINE NUMBER WE SAVED.
	CPD    HILINE	; IS IT HIGHER THAN THE HIGHEST LINE ENTERED SO FAR?
	BLS    DELLINE1	; NO. GO SEE IF THE LINE EXISTS.
DELLINE2:	LDAA   #1		; YES. THE LINE CANNOT EXIST.
	STAA   CONTFLAG
*        PULD		; PULL THE LINE NUMBER OFF THE STACK.
	PULA
	PULB
	RTS		; RETURN.
DELLINE1:	BSR    FINDLINE	; GO SEE IF THE LINE EXISTS.
			; RETURN A POINTER TO A LINE NUMBER IN THE BASIC PROGRAM BUFFER.
*
*
* if(*linum!=num) return;        /* if the line # doesn't exist, return */
* ptr=linum;                     /* make the int pointer a char pointer */
* closespc(ptr[2],ptr);          /* go delete the line */
* if(num==hiline) hiline=findhiln();
* return;
*}
*
*
	LDD    0,X	; GET THE LINE NUMBER THAT WAS FOUND.
	CPD    0,Y	; WAS THE LINE NUMBER FOUND THE ONE THAT WAS REQUESTED TO BE DELETED.
	BNE    DELLINE2	; NO. THE LINE DOESN'T EXIST. JUST RETURN.
	LDAB   2,X	; YES. GET THE LENGTH OF THE LINE.
	BSR    CLOSESPC	; GO CLOSE THE SPACE IN THE PROGRAM BUFFER.
	LDD    HILINE	; GET THE HIGHEST LINE NUMBER ENTERED.
	CPD    0,Y	; DID WE DELETE THE HIGHEST LINE NUMBER?
	BNE    DELLINE2	; NO. JUST RETURN.
	BSR    FINDHILN	; YES. GO FIND THE HIGHEST LINE NUMBER.
	STD    HILINE	; SAVE IT.
	BRA    DELLINE2	; RETURN.
*
*
*/***** closespc() *****/        /* close up space in the BASIC buffer */
*
*closespc(bytes,ptr)
*char bytes,*ptr;
*{
* char *to,*from;                /* define the from/to pointers */
* to=ptr;                        /* set up destination pointer */
* from=ptr+bytes;                /* setup source pointer */
* while(from<basend)             /* while we're not at the end of the buff */
* { *to++=*from++; }             /* move source to destination */
* basend=to;                     /* set new basend pointer */
* return;
*}
*
*
CLOSESPC:	EQU    *		; ENTERED WITH
	PSHY		; SAVE THE CURRENT VALUE OF Y.
	PSHX		; TRANSFER X TO Y BY... PUSHING X AND THEN
	PULY		; PULLING Y.
	ABY		; ADD THE LENGTH TO Y.
CLOSESP1:	CPY    BASEND	; HAVE WE MOVED ALL THE BYTES?
	BHS    CLOSESP2	; YES. RETURN.
	LDAA   0,Y	; NO. GET A BYTE.
	STAA   0,X	; MOVE IT.
	INX		; ADVANCE THE DESTINATION POINTER.
	INY		; ADVANCE THE SOURCE POINTER.
	BRA    CLOSESP1	; GO CHECK TO SEE IF WE'RE DONE.
CLOSESP2:	STX    BASEND	; SAVE THE NEW 'END OF BASIC PROGRAM' POINTER.
	JSR    MOVEVARSDN	; MOVE ALL THE VARIABLES DOWN.
	PULY		; RESTORE Y.
	RTS		; RETURN.
*
*
*/***** findline() *****/        /* return pointer to line number or next
*                                   highest line number */
*findline(linenum)
*int linenum;
*{
* char *linelen;
* int *basbufp;
* basbufp=basbeg;                /* set pointer to start of basic buffer */
* while(*basbufp<linenum)        /* do until we find line # or one higher */
* {
*  linelen=basbufp;              /* convert int pointer to char pointer */
*  basbufp=linelen+linelen[2];   /* convert char ptr back to int pointer */
* }
* return(basbufp);               /* return the pointer */
*}
*
*
FINDLINE:	EQU    *
	LDX    BASBEG
FINDLIN1:	CPD    0,X
	BLS    FINDLIN2
	PSHB
	LDAB   2,X
	ABX
	PULB
	BRA    FINDLIN1
FINDLIN2:	RTS
*
*
*/***** findhiln() *****/
*
*findhiln()                      /* find highest line number in basic buffer **/*{
* int *iptr,lnum;
* char *cptr;
* lnum=0;                        /* set line # to 0 */
* iptr=basbeg;                   /* set int pointer to basbeg */
* while(iptr!=basend)            /* we're not to the end of the basic buff */
* {
*  lnum=*iptr;                   /* get current line # */
*  cptr=iptr;                    /* convert int pointer to char pointer */
*  iptr=cptr+cptr[2];            /* add line length, point to next line */
* }
* return(lnum);                  /* return highest line number */
*}
*
*
FINDHILN:	EQU    *
	LDX    BASBEG
FINDHIL1:	CPX    BASEND
	BEQ    FINDHIL2
	LDD    0,X
	PSHB
	LDAB   2,X
	ABX
	PULB
	BRA    FINDHIL1
FINDHIL2:	RTS
*
*
*/***** insrtlin() *****/
*
*insrtlin(ptr)
*char *ptr;
*{
* openspc(tknbuf[2],ptr);        /* go open space in the program bufer */
* if(errcode) return;            /* return if out of memory */
* putline(ptr);                  /* put line into buffer */
* return;
*}
*
*
INSRTLIN:	EQU    *
	PSHX
	LDX	TKNBUFS
	LDAB   2,X
	PULX
	PSHX
	BSR    OPENSPC
	PULX
	BRA    PUTLINE
*
*
*/***** openspc() *****/         /* open space in program buffer */
*
*openspc(bytes,ptr)
*char bytes,*ptr;
*{
* char *to,*from;                /* declare to/from pointers */
* from=basend;                   /* set source at end of buffer */
* to=basend+bytes;               /* set destination "bytes" beyond source */
* if(to>basmend)                 /* if out of memory, return an error */
* { errcode=OMEMERR; return; }
* basend=to;                     /* set new end of buffer */
* while(from>=ptr)
* { *to--=*from--; }             /* open up area in buffer */
* return;
*}
*
OPENSPC:	EQU    *
	PSHY
	PSHX
	LDX    VAREND
	ABX
	CPX    BASMEND
	BHI    OPENSPC4
	JSR    MOVEVARSUP
	LDX    BASEND
	PSHX
	ABX
	PSHX
	TSY
	LDD    0,Y
OPENSPC1:	STD    BASEND
OPENSPC3:	LDD    2,Y
	CPD    4,Y
	BLO    OPENSPC2
	LDX    2,Y
	LDAA   0,X
	DEX
	STX    2,Y
	LDX    0,Y
	STAA   0,X
	DEX
	STX    0,Y
	BRA    OPENSPC3
OPENSPC4:	LDAA   #OMEMERR
	JMP    RPTERR
OPENSPC2:	PULX
	PULX
	PULX
	PULY
	RTS
*
*
*/***** putline() *****/         /* move line from token buffer to program
*                                   buffer */
*putline(cptr)
*char *cptr;
*{
* short count;
* count=tknbuf[2];               /* get length of line in token buffer */
* tbufptr=tknbuf;                /* point to start of token buffer */
* while(count)
* {
*  *cptr++=*tbufptr++;           /* move a byte */
*  --count;                      /* decrement the byte count */
* }
* return;
*}
*
*
PUTLINE:	EQU    *
	PSHX
	LDX    TKNBUFS
	LDAB   2,X
	PULX
	LDY    TKNBUFS
PUTLINE1:	LDAA   0,Y
	INY
	STAA   0,X
	INX
	DECB
	BNE    PUTLINE1
	RTS
*
*
*/***** apendlin() *****/        /* appent line to end of program buffer */
*
*apendlin()
*{
* if((basend+tknbuf[2])<=basmend)  /* do we have enough memory left? */
* {
*  putline(basend);              /* move the line */
*  basend+=tknbuf[2];            /* set the new end of basic pointer */
* }
* else errcode=OMEMERR;          /* not enough memory, error */
* return;
*}
*
*
APENDLIN:	EQU    *
	LDX    TKNBUFS
	LDAB   2,X
	LDX    VAREND
	ABX
	CPX    BASMEND
	BHI    APENDLN1
*	LDAB   TKNBUF+2
	JSR    MOVEVARSUP
	LDX    BASEND
	ABX
	XGDX
	LDX    BASEND
	STD    BASEND
	BRA    PUTLINE
APENDLN1:	LDAA   #OMEMERR
	JMP    RPTERR
*
*
*/***** repline() *****/         /* replace line in buffer */
*
*repline(ptr)
*char *ptr;
*{
* short lendif,temp1,temp2;
* temp1=*(ptr+2);                /* convert type from char to int */
* temp2=(tknbuf[2]);
* lendif=temp1-temp2;            /* get the difference in line length */
*      if(lendif==0)             /* if the same, just write over the old */
*      {
*       putline(ptr);
*      }
*
*
REPLINE:	EQU    *
	LDAB   2,X
	PSHX
	LDX   TKNBUFS
	SUBB   2,X
	PULX
	BNE    REPLINE1
	BRA    PUTLINE
*
*
* else if(lendif<0)              /* if line in tknbuf is larger */
*      {
*       lendif=-lendif;          /* make it a positive number */
*       openspc(lendif,ptr);     /* tru to open up a space */
*       if(errcode) return;      /* if not enough memory, return */
*       putline(ptr);            /* if ok, copy line to program buffer */
*      }
*
*
REPLINE1:	EQU    *
	BPL    REPLINE2
	NEGB
	PSHX
	JSR    OPENSPC
	PULX
	BRA    PUTLINE
*
*
* else                           /* if line in tknbuf is smaller */
*      {
*       closespc(lendif,ptr);    /* close up excess space */
*       putline(ptr);            /* put new line in program buffer */
*      }
* return;
*}
*
*
REPLINE2:	EQU    *
	PSHX
	JSR    CLOSESPC
	PULX
	BRA    PUTLINE
*
*
MoveVarsUp:
	PSHY		; SAVE THE Y REGISTER.
	PSHB		; SAVE THE BYTE COUNT.
	LDX	VAREND	; POINT TO THE END OF THE VARIABLE MEMORY SPACE.
	LDY	VAREND	; POINT TO THE END OF VARIABLE MEMORY SPACE.
	ABX		; ADD THE NUMBER OF BYTES TO MOVE TO THE POINTER.
	LDD	VAREND	; GET THE CURRENT VARIABLE TABLE ENDING ADDRESS.
	STX	VAREND	; SAVE THE NEW END OF VARIABLE TABLE POINTER.
	SUBD	VARBEGIN	; CALCULATE THE NUMBER OF BYTES TO MOVE.
	BEQ	MOVEUP2	; JUST RETURN IF THERE IS NOTHING TO MOVE.
	std	VarSize	; save the size of the variable table (9/12/89).
MOVEUP1:	LDAA	0,Y	; GET A BYTE.
	STAA	0,X	; MOVE IT.
	DEX
	DEY
	bsr	DecCount	; DECREMENT THE BYTE COUNT. ARE WE DONE? (9/12/89).
	BPL	MOVEUP1	; GO TILL WE'RE DONE.
	INX		; ADJUST THE POINTER
MOVEUP2:	STX	VARBEGIN  ; SAVE THE NEW START OF VARIABLE TABLE POINTER.
	PULB		; RESTORE THE BYTE COUNT.
	PULY		; RESTORE Y.
	RTS		; RETURN.
*
*
MoveVarsDn:
	PSHY		; SAVE Y.
	PSHB		; SAVE THE BYTE COUNT.
	LDY	VARBEGIN	; POINT TO THE CURRENT START OF THE VARIABLE TABLE.
	LDAA	#$FF	; MAKE THE BYTE COUNT NEGATIVE SO WE CAN JUST ADD.
	NEGB			
	ADDD	VARBEGIN	; CALCULATE THE NEW START OF THE VARIABLE TABLE.
	XGDX		; PUT THE NEW STARTING ADDRESS OF THE VARIABLE TABLE INTO X.
	LDD	VAREND	; GET THE OLD TABLE ENDING ADDRESS.
	SUBD	VARBEGIN	; SUBTRACT THE OLD TABLE STARTING ADDRESS TO GET THE SIZE OF THE TABLE.
	STX	VARBEGIN	; SAVE THE POINTER TO THE NEW START OF THE VARIABLE TABLE.
	std	VarSize	; save the size of the variable table (9/12/89).
	BEQ	MOVEDN2	; IF THE SIZE IS 0 (NO VARIABLES ALLOCATED) EXIT.
MOVEDN1:	LDAA	0,Y	; GET A BYTE.
	STAA	0,X	; MOVE IT.
	INX		; MOVE THE DESTINATION POINTER.
	INY		; MOVE THE SOURCE POINTER.
	bsr	DecCount	; DECREMENT THE BYTE COUNT. ARE WE DONE? (9/12/89).
	BPL	MOVEDN1	; NO. KEEP MOVIN' THEM BYTES.
	DEX
MOVEDN2:	STX	VAREND	; SAVE THE NEW POINTER TO THE END OF THE VARIABLE TABLE.
	PULB		; RESTORE THE BYTE COUNT.
	PULY		; RESTORE Y.
	RTS		; RETURN.
*
*
DecCount:
	ldd	VarSize	; get the size of the variable table.
	subd	#1	; decrement it.
	std	VarSize	; save the new value.
	rts		; return.
