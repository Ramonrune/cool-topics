; Simple PIC 16F877X Program to drive Serial LCDs.
; Assumes 1MHZ CPU clock, 2400 baud rate for the LCD.

           LIST    p=16F874
           #include "P16F874.INC"

	   ; Counter variables for delay
           cblock 0x20
               char,cmd,lc1,lc2;
           endc

           ; Vector for normal start up.
           org     0
           goto    start

           org     4
           goto    inthlr

; Main program starts here:
start      clrw                    ; Clear W.
           movwf   PORTA           ; Ensure PORTA is zero before we enable it.
           movwf   PORTB           ; Ensure PORTB is zero before we enable it.

           ; Set up ports:
           bcf     STATUS,RP0      ; Select Bank 0
           bsf     RCSTA,SPEN      ; Enable USART.
           bsf	   RCSTA,CREN	   ; Enable Receeive
           bsf     STATUS,RP0      ; Select Bank 1
           clrw                    ; Set W to mask for all outputs.
           movwf   TRISA           ; Set TRISA register as outputs.
           movwf   TRISB           ; Set TRISB register as outputs.
           movlw   0x19            ; BRG value for 2400 baud @ 1MHz
           movwf   SPBRG           ; Write it to register.
           movlw   0xA4            ; CSRC/TXEN (Internal clock, 8 bit mode, Async operation, High Speed)
           movwf   TXSTA           ; Write to TX control register.           

	   movlw   80
	   call    delay

           movlw   'M'             ; Value to transmit.
	   call    putc                       
           movlw   'i'             ; Value to transmit.
	   call    putc                       
           movlw   'l'             ; Value to transmit.
	   call    putc                       
           movlw   'f'             ; Value to transmit.
	   call    putc                       
	   movlw  'o'              ; Value to transmit.
	   call    putc                       
           movlw  'r'              ; Value to transmit.
	   call    putc                       
	   movlw  'd'              ; Value to transmit.
	   call    putc                       
	   movlw  ' '              ; Value to transmit.
	   call    putc                       
	   movlw  'L'              ; Value to transmit.
	   call    putc                       
	   movlw  'C'              ; Value to transmit.
	   call    putc                       
	   movlw  'D'              ; Value to transmit.
	   call    putc                       
	   movlw  ' '              ; Value to transmit.
	   call    putc                       
	   movlw  'D'              ; Value to transmit.
	   call    putc                       
	   movlw  'e'              ; Value to transmit.
	   call    putc                       
	   movlw  'm'              ; Value to transmit.
	   call    putc                       
	   movlw  'o'              ; Value to transmit.
	   call    putc                       

	   movlw  0xC0 	           ; Move cursor to row two
	   call   wrcmd

	   movlw  0x0D 		   ; Show the cursor
	   call   wrcmd
	            
loop	   call  getc                                  
           movwf char           
	   sublw 0d
	   btfsc STATUS,Z
	   goto  cls	     
	   movf  char,w
	   sublw 08
	   btfsc STATUS,Z
	   goto  bspace
	   movf  char,W
	   call  putc    	  ; Send the character straight thru
	   goto  loop

cls        movlw  0x01		  ; Send command prefix
           call wrcmd
	   goto loop            

bspace     movlw 0x10		  ; Send command prefix
  	   call wrcmd
	   goto loop
	         
hang	   clrwdt                 ; Clear WDT in case it is enabled.
	   goto hang			

;Subroutine to sent a command
wrcmd	   movwf cmd    	  ; Store the command      
	   movlw 0xFE             ; Write the command prefix
	   call putc
	   movf cmd,W	          ; Write the command code
	   goto putc
	   
;Subroutine to wait and receive a byte
;Returns character in W
;
getc       bcf     STATUS,RP0      ; Select Bank 0.
getc1      btfss   PIR1,RCIF	   ; Skip if RC int flag set  
	   goto    getc1           ; Try again
	   movf	   RCREG,W         ; Read the character
	   bcf     PIR1,RCIF       ; Clear the interrupt flag
	   return

;Subroutine to transmit a byte and wait
;W = Character
;
putc       bcf     STATUS,RP0      ; Select Bank 0.
           movwf   TXREG           ; Write it!
           bsf     STATUS,RP0      ; Select Bank 1
           movf	   TXSTA,W	   ; Peek transmit status
putc1      btfss   TXSTA,1         ; Skip if TXbuffer empty
           goto    putc1           ; Try again     
           bcf     STATUS,RP0      ; Select Bank 0.                 
	   return

;Delay Routine   
;W = delay time
;
delay      movwf   lc2
_sw2       movlw   0xFF
           movwf   lc1
_sw3       nop
           decfsz  lc1,f
           goto    _sw3
           decfsz  lc2,f
           goto    _sw2
           return



inthlr	   retfie	   	           

	   END