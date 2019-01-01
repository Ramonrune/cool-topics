           LIST    p=16F84 ; PIC16F844 is the target processor

           #include "P16F84.INC" ; Include header file

           CBLOCK 0x10   ; Temporary storage
              state
              l1,l2
           ENDC

           org     0               ; Start up vector.
           goto    setports        ; Go to start up code.

	   org     4               ; Interrupt vector.
halt       goto    halt            ; Sit in endless loop and do nothing.

setports   clrw                    ; Zero in to W.
           movwf   PORTA           ; Ensure PORTA is zero before we enable it.
           movwf   PORTB           ; Ensure PORTB is zero before we enable it.
           bsf     STATUS,RP0      ; Select Bank 1
           clrw                    ; Mask for all bits as outputs.
           movwf   TRISB           ; Set TRISB register.
           bcf     STATUS,RP0      ; Reselect Bank 0.

initialise clrw                    ; Initial state.
           movwf   state           ; Set it.

loop       call    getmask         ; Convert state to bitmask.
           movwf   PORTB           ; Write it to port.
           incf    state,W         ; Increment state in to W.
           andlw   0x03            ; Wrap it around.
           movwf   state           ; Put it back in to memory.
           call    wait            ; Wait :-)
           goto    loop            ; And loop :-)

           ; Function to return bitmask for output port for current state.
           ; The top nibble contains the bits for one set of lights and the
           ; lower nibble the bits for the other set. Bit 1 is red, 2 is amber
           ; and bit three is green. Bit four is not used.
getmask    movf    state,W         ; Get state in to W.
           addwf   PCL,F           ; Add offset in W to PCL to calc. goto.
           retlw   0x41            ; state==0 is Green and Red.
           retlw   0x23            ; state==1 is Amber and Red/Amber
           retlw   0x14            ; state==3 is Red   and Green
           retlw   0x32            ; state==4 is Red/Amber and Amber.

           ; Function using two loops to achieve a delay.
wait       movlw   5
           movwf   l1

w1         call    wait2
           decfsz  l1
           goto    w1

           return


wait2      clrf    l2
w2         decfsz  l2
           goto    w2
           return
           END
