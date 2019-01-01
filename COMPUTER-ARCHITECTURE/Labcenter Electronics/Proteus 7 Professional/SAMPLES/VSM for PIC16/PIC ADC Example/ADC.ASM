           LIST    p=16F877
           #include "P16F877.INC"

; Macro to generate a MOVLW instruction that also causes a model break:
break      MACRO arg
           DW    0x3100 | (arg & H'FF')
           ENDM

           cblock 0x20
              count, lc1, lc2;
           endc

           ; Vector for normal start up.
           org     0
           goto    start

           org     4
           goto    inthlr

; Main program starts here:
start      clrw                    ; Clear W.
           movwf   PORTB           ; Ensure PORTB is zero before we enable it.
           movwf   PORTD           ; Ensure PORTD is zero before we enable it.
           movwf   count           ; Reset count value.
           movwf   CCPR1H          ; Clear.
           movwf   CCPR1L          ; Clear.

           ; Set up ports:
           bsf     STATUS,RP0      ; Select Bank 1
           movlw   0xFF		   ; Set W to mask for all inputs.
           movwf   TRISA	   ; set TRISA register as inputs.
           movlw   0x00		   ; Set W to mask for all inputs.
           movwf   TRISA	   ; set TRISA register as inputs.

           bcf     STATUS,RP0      ; Select Bank 1
	   bsf     PORTA,0
	   bcf     PORTA,0
	   bsf     PORTA,0
	   bcf     PORTA,0
           bsf     STATUS,RP0      ; Select Bank 0

           movlw   0xFF		   ; Set W to mask for all inputs.
           movwf   TRISA	   ; set TRISA register as inputs.
           clrf    TRISB           ; Set TRISB register as outputs.
           clrf    TRISD           ; Set TRISD register as outputs.

	   movlw   0x81            ; ADFM=1, all inputs analogue, +VREF enabled.
           movwf   ADCON1          ; Save it.
           bcf     STATUS,RP0      ; Select Bank 0.
           movlw   0xC1		   ; Clock/Channel select and enable.
           movwf   ADCON0          ; Save it.
	   movlw   0x01		   ; Number of loops of 255 clocks.
           call    swait           ; Wait for acquire time.

do_conv    bsf     ADCON0,GO
wait_eoc   btfsc   ADCON0,GO	   ; Is bit still set?
           goto    wait_eoc        ; Yes, so loop and wait for end of conversion.

	   bcf     STATUS,RP0      ; Ensure we have bank 0.
           bsf     PORTD,0         ; Show ISR in progress.
           incf    count,F         ; Increment count.
           call    disp_adc        ; Display captured value.
           bcf     PORTD,0         ; Remove progress bit.

	   movlw   0x40            ; Count	
           movwf   count           ; Save it.
loop1      nop                     ; Dilly...
	   nop                     ; Dally...
	   nop                     ; Dilly...
	   decfsz count            ; Decrement loop counter
	   goto loop1              ; Loop if no zero.

	   goto    do_conv	   ; Do another conversion.

disp_adc   bsf     STATUS,RP0      ; Bank 1.
	   movf    ADRESL,W        ; Get ADRESL into W.
           bcf     STATUS,RP0      ; Bank 0.
           movwf   PORTB           ; Write it to port
           bsf     PORTD,6         ; Toggle latch enable
           nop                     ; Wait
           nop                     ; Wait
           bcf     PORTD,6         ; Toggle latch enable
	   movf    ADRESH,W        ; Get ADRESH into W.
	   movwf   PORTB           ; Write it to port
           bsf     PORTD,7         ; Toggle latch enable
           nop                     ; Wait
           nop                     ; Wait
           bcf     PORTD,7         ; Toggle latch enable
           return

inthlr     retfie

; -------------------------------------------------------------------------------
; Wait function
; -------------
swait      movwf   lc2
_sw2       movlw   0xFF
           movwf   lc1
_sw3       nop
           decfsz  lc1,f
           goto    _sw3
           decfsz  lc2,f
           goto    _sw2
           return

           END
