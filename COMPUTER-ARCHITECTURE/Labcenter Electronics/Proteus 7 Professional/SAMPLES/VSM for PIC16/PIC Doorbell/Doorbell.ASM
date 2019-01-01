              LIST    p=16F84 ; PIC16F844 is the target processor

              #include "P16F84.INC" ; Include header file

              CBLOCK 0x10   ; Temporary storage
              tempo
              tptrl
              tptrh
              note
              length
              pitch
              temp              
              dl1
              dl2              
              ENDC


              ORG   0
entrypoint    goto  initialise

              ORG   4
intvector     goto    toggle

initialise    ; Register set up:
              clrw                    ; Zero.
              movwf   PORTA	      ; Ensure PORTB is zero before we enable it.		
              movwf   PORTB           ; Ensure PORTB is zero before we enable it.
              bsf     STATUS,RP0      ; Select Bank 1
              clrf    TRISB	      ; Port B is outputs              

	      ; Set up timer 0 for tone generation
	      movlw   0x02            ; Prescaler on, internal clocking, divide by 4            
	      movwf   OPTION_REG
              bcf     STATUS,RP0      ; Back to bank 0                              
              
                                
	      ; Poll for a button
wait	      clrf    PORTB
wloop	      btfss   PORTA,0
	      goto    playtune0
	      btfss   PORTA,1
	      goto    playtune1
	      goto    wloop                                   

;Routines to play the tunes
playtune0     movlw   0x13
	      movwf   PORTB
	      movlw   0x50
    	      movwf   tempo
	      movlw   tune0 / 0x100
	      movwf   tptrh
	      movlw   tune0 % 0x100
	      movwf   tptrl
	      goto    playtune

playtune1     movlw   0x23
	      movwf   PORTB
	      movlw   0xA0
    	      movwf   tempo
	      movlw   tune1 / 0x100
	      movwf   tptrh
	      movlw   tune1 % 0x100
	      movwf   tptrl
	      goto    playtune
                  
;Subroutine to play a tune
playtune      call    gettunedata       ; Lookup note from tune table
	      movwf   note              ; Store the note code
	      btfsc   note,7		; Bit 7 set => end of tune
	      goto    wait		; Back to waiting for a button press
 	      incf    tptrl,F           ; Increment the tune pointer
	      call    gettunedata       ; Get the note length
	      movwf   length            ; Store it
                                                                             
; Play the stored note
; The tune table supports two octaves and 8 note lengths.
playnote      btfsc   note,6	 	; Bit 6 set => rest
              goto    playwait          ; Silence ensues...     
	      movf    note,W		; Retrieve the note	      
              andlw   0x3F              ; Mask off the pitch index
	      call    pitchtable        ; and look it up in the pitchtable
 	      movwf   pitch             ; Transfer the value to Timer 0
 	      movwf   TMR0
 	      bcf     INTCON,T0IF       ; Clear Timer Interrupt
	      bsf     INTCON,T0IE       ; Enable interrupts for Timer 0
	      bsf     INTCON,GIE
playwait      movf    length,W          ; Retrieve the note length
	      movwf   dl1               ; and store it in delay counter 1
loop1	      movf    tempo,W  	        ; This value sets the timing resolution
	      movwf   dl2
loop2         nop                       ; Inner delay loop delay
	      nop      
	      decfsz  dl2,F             
              goto    loop2
              decfsz  dl1,F             ; Outer delay loop 
              goto    loop1
              bcf     INTCON,T0IE       ; Timer interrupts off            

;Fetch next note/length pair:
   	      incf    tptrl,F           ; Increment tune ptr   	      
 	      btfsc   STATUS,Z     	; Test for low byte rollover
 	      incf    tptrh,F           ; Inc high byte
              goto    playtune	        ; Loop for next note

; Routine to fetch data from the tune tables
gettunedata   movf    tptrh,W         ; Set up PCLATH for the jump
              movwf   PCLATH                      
	      movf    tptrl,W	      ; Get low address of tptr
	      movwf   PCL	      ; Jump off to the table entry                                   

; Pitch lookup function		                             
pitchtable    clrf    PCLATH           ; Clear PCLATH for zero page
	      addwf PCL,F
	      retlw 0x11               ;C5  // Midi Code 60
	      retlw 0x1F               ;C#
	      retlw 0x2B               ;D
	      retlw 0x37               ;D#
	      retlw 0x42               ;E
	      retlw 0x4D               ;F
	      retlw 0x57               ;F#
	      retlw 0x61               ;G
	      retlw 0x6A	       ;G#
	      retlw 0x72               ;A (440)
	      retlw 0x7A               ;Bb
	      retlw 0x81               ;B
	      retlw 0x89               ;C6 // Midi Code 72
	      retlw 0x8F               ;Db
	      retlw 0x96               ;D
	      retlw 0x9C               ;Eb
	      retlw 0xA1               ;E
	      retlw 0xA7               ;F
	      retlw 0xAC               ;F#
	      retlw 0xB0               ;G
	      retlw 0xB5               ;Ab
	      retlw 0xB9               ;A (880)
	      retlw 0xBD               ;Bb
	      retlw 0xC1               ;B
	      retlw 0xC4               ;C7 // Midi Code 84
	      retlw 0xC8               ;Db
	      retlw 0xCB               ;D
	      retlw 0xCE               ;Eb
	      retlw 0xD1               ;E
	      retlw 0xD3               ;F
	      retlw 0xD6               ;F#
	      retlw 0xD8               ;G
	      retlw 0xDA               ;Ab
	      retlw 0xDC               ;A (1760)
      	      retlw 0xDE	       ;Bb
	      retlw 0xE0               ;
	      retlw 0xE2               ;C8 // Midi Code 96

                                                                    
              

;Interrupt service - toggle the drive polarity to the sounder
;Note that this does not preserve the status bits - be careful,
;and that there is an assumption we are addressing bank 0.
toggle        movwf   temp
              movf    pitch,W
              movwf   TMR0
	      movf    PORTB,W
              xorlw   0x0F
              movwf   PORTB
	      bcf     INTCON,T0IF
	      movf    temp,w
	      retfie

;Tune Tables             
;Must be on even byte boundary                        
                        
	      org 0x0080

; Tune 0 Data
; Bach 'Badinerie' from Suite No 2
tune0	retlw 0x17	;B
	retlw 0x78	;240
	retlw 0x1A	;D
	retlw 0x3C	;120
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0xF0	;480
	retlw 0x06	;F#
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0x3C	;120
	retlw 0x0D	;C#
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0x3C	;120
	retlw 0x0D	;C#
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0x3C	;120
	retlw 0x0A	;A#
	retlw 0x3C	;120
	retlw 0x0D	;C#
	retlw 0x3C	;120
	retlw 0x10	;E
	retlw 0x3C	;120
	retlw 0x0D	;C#
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x0B	;B
	retlw 0x78	;240
	retlw 0x17	;B
	retlw 0x78	;240
	retlw 0x1A	;D
	retlw 0x3C	;120
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x0E	;D
	retlw 0x3C	;120
	retlw 0x0B	;B
	retlw 0xF0	;480
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x0E	;D
	retlw 0x78	;240
	retlw 0x17	;B
	retlw 0x78	;240
	retlw 0x0E	;D
	retlw 0x78	;240
 	retlw 0x10	;E
	retlw 0x3C	;60
	retlw 0x0E	;D
	retlw 0x3C	;30
	retlw 0x0D	;C#
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x78	;240
	retlw 0x1A	;D
	retlw 0x78	;240
	retlw 0x12	;F#
	retlw 0x78	;220
	retlw 0x12	;F#
	retlw 0x3C	;30
	retlw 0x14	;G#
	retlw 0x3C	;65
	retlw 0x11	;F
	retlw 0x78	;270
	retlw 0x0D	;C#
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x15	;A
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x11	;F
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x15	;A
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x15	;A
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x15	;A
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x11	;F
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x11	;F
	retlw 0x39	;115
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x19	;C#
	retlw 0x3E	;125
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x11	;F
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x39	;115
	retlw 0x1A	;D
	retlw 0x3E	;125
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x11	;F
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;120
	retlw 0x1A	;D
	retlw 0x3C	;120
	retlw 0x19	;C#
	retlw 0x3C	;120
	retlw 0x17	;B
	retlw 0x3C	;120
	retlw 0x19	;C#
	retlw 0x3C	;120
	retlw 0x15	;A
	retlw 0x3C	;120
	retlw 0x14	;G#
	retlw 0x3C	;120
	retlw 0x12	;F#
	retlw 0x3C	;130
	retlw 0x15	;A
	retlw 0x78	;210
	retlw 0x14	;G#
	retlw 0x3C
	retlw 0x12	;F#
	retlw 0x3C	;
	retlw 0x12	;F#
	retlw 0xE0	;480
	retlw 0xFF	
	retlw 0

; Tune 1 
; Mozart Eine Klein Nachtmusik

	
tune1	      	

	retlw 0x13	;G
	retlw 0x43	;538
	retlw 0x40	;REST
	retlw 0x4D	;617
	retlw 0x0E	;D
	retlw 0x18	;193
	retlw 0x40	;REST
	retlw 0x1D	;232
	retlw 0x13	;G
	retlw 0x3E	;498
	retlw 0x40	;REST
	retlw 0x48	;582
	retlw 0x0E	;D
	retlw 0x1B	;218
	retlw 0x40	;REST
	retlw 0x18	;192
	retlw 0x13	;G
	retlw 0x15	;168
	retlw 0x40	;REST
	retlw 0x19	;207
	retlw 0x0E	;D
	retlw 0x15	;168
	retlw 0x40	;REST
	retlw 0x15	;172
	retlw 0x13	;G
	retlw 0x17	;188
	retlw 0x40	;REST
	retlw 0x18	;197
	retlw 0x17	;B
	retlw 0x17	;188
	retlw 0x40	;REST
	retlw 0x1B	;222
	retlw 0x1A	;D
	retlw 0x3B	;478
	retlw 0x40	;REST
	retlw 0x83	;1052
	retlw 0x18	;C
	retlw 0x47	;568
	retlw 0x40	;REST
	retlw 0x4A	;597
	retlw 0x15	;A
	retlw 0x15	;168
	retlw 0x40	;REST
	retlw 0x1D	;237
	retlw 0x18	;C
	retlw 0x3C	;483
	retlw 0x40	;REST
	retlw 0x52	;657
	retlw 0x15	;A
	retlw 0x16	;183
	retlw 0x40	;REST
	retlw 0x16	;177
	retlw 0x18	;C
	retlw 0x1C	;228
	retlw 0x40	;REST
	retlw 0x12	;147
	retlw 0x15	;A
	retlw 0x16	;183
	retlw 0x40	;REST
	retlw 0x18	;197
	retlw 0x12	;F#
	retlw 0x18	;198
	retlw 0x40	;REST
	retlw 0x14	;167
	retlw 0x15	;A
	retlw 0x1D	;238
	retlw 0x40	;REST
	retlw 0x18	;192
	retlw 0x0E	;D
	retlw 0x39	;458
	retlw 0x40	;REST
	retlw 0x82	;1042
	retlw 0x13	;G
	retlw 0x27	;313
	retlw 0x40	;REST
	retlw 0x3E	;497
	retlw 0x13	;G
	retlw 0x6B	;858
	retlw 0x40	;REST
	retlw 0x1E	;242
	retlw 0x17	;B
	retlw 0x31	;395
	retlw 0x15	;A
	retlw 0x21	;268
	retlw 0x40	;REST
	retlw 0x07	;57
	retlw 0x13	;G
	retlw 0x16	;183
	retlw 0x40	;REST
	retlw 0x18	;197
	retlw 0x13	;G
	retlw 0x16	;180
	retlw 0x15	;A
	retlw 0x13	;155
	retlw 0x13	;G
	retlw 0x12	;145
	retlw 0x12	;F#
	retlw 0x10	;133
	retlw 0x40	;REST
	retlw 0x22	;272
	retlw 0x12	;F#
	retlw 0x68	;833
	retlw 0x40	;REST
	retlw 0x1F	;252
	retlw 0x15	;A
	retlw 0x2C	;355
	retlw 0x18	;C
	retlw 0x1B	;218
	retlw 0x40	;REST
	retlw 0x14	;162
	retlw 0x12	;F#
	retlw 0x13	;158
	retlw 0x40	;REST
	retlw 0x19	;202
	retlw 0x15	;A
	retlw 0x2F	;380
	retlw 0x13	;G
	retlw 0x13	;158
	retlw 0x40	;REST
	retlw 0x22	;272
	retlw 0x13	;G
	retlw 0x78	;963
	retlw 0x40	;REST
	retlw 0x1D	;237
	retlw 0x17	;B
	retlw 0x2A	;343
	retlw 0x40	;REST
	retlw 0x03	;27
	retlw 0x15	;A
	retlw 0x22	;278
	retlw 0x40	;REST
	retlw 0x0C	;102
	retlw 0x13	;G
	retlw 0x16	;183
	retlw 0x40	;REST
	retlw 0x1A	;212
	retlw 0x13	;G
	retlw 0x19	;205
	retlw 0x15	;A
	retlw 0x12	;150
	retlw 0x13	;G
	retlw 0x11	;140
	retlw 0x12	;F#
	retlw 0x12	;148
	retlw 0x40	;REST
	retlw 0x1F	;252
	retlw 0x12	;F#
	retlw 0x5B	;728
	retlw 0x40	;REST
	retlw 0x27	;317
	retlw 0x15	;A
	retlw 0x2D	;365
	retlw 0x18	;C
	retlw 0x1A	;208
	retlw 0x40	;REST
	retlw 0x13	;152
	retlw 0x12	;F#
	retlw 0x14	;163
	retlw 0x40	;REST
	retlw 0x19	;207
	retlw 0x13	;G
	retlw 0x14	;163
	retlw 0x40	;REST
	retlw 0x19	;207
	retlw 0x13	;G
	retlw 0x13	;153
	retlw 0x40	;REST
	retlw 0x1A	;212
	retlw 0x13	;G
	retlw 0x1C	;225
	retlw 0x12	;F#
	retlw 0x15	;175
	retlw 0x10	;E
	retlw 0x1E	;240
	retlw 0x12	;F#
	retlw 0x12	;150
	retlw 0x13	;G
	retlw 0x18	;198
	retlw 0x40	;REST
	retlw 0x16	;177
	retlw 0x13	;G
	retlw 0x10	;128
	retlw 0x40	;REST
	retlw 0x23	;287
	retlw 0x17	;B
	retlw 0x17	;190
	retlw 0x15	;A
	retlw 0x0D	;105
	retlw 0x13	;G
	retlw 0x1F	;255
	retlw 0x15	;A
	retlw 0x0F	;125
	retlw 0x17	;B
	retlw 0x18	;193
	retlw 0x40	;REST
	retlw 0x1A	;212
	retlw 0x17	;B
	retlw 0x10	;128
	retlw 0x40	;REST
	retlw 0x20	;257
	retlw 0x1A	;D
	retlw 0x19	;200
	retlw 0x18	;C
	retlw 0x0F	;125
	retlw 0x17	;B
	retlw 0x1F	;250
	retlw 0x18	;C
	retlw 0x10	;135
	retlw 0x1A	;D
	retlw 0x59	;713
	retlw 0x40	;REST
	retlw 0x7B	;987
	retlw 0x0E	;D
	retlw 0xBA	;1495
	retlw 0x10	;E
	retlw 0x7C	;998
	retlw 0x40	;REST
	retlw 0x48	;577
	retlw 0x0E	;D
	retlw 0x19	;205
	retlw 0x0C	;C
	retlw 0x16	;183
	retlw 0x40	;REST
	retlw 0x31	;397
	retlw 0x0C	;C
	retlw 0x14	;163
	retlw 0x40	;REST
	retlw 0x4C	;612
	retlw 0x0C	;C
	retlw 0x17	;190
	retlw 0x0B	;B
	retlw 0x12	;148
	retlw 0x40	;REST
	retlw 0x39	;457
	retlw 0x0B	;B
	retlw 0x13	;153
	retlw 0x40	;REST
	retlw 0x43	;537
	retlw 0x0B	;B
	retlw 0x17	;190
	retlw 0x09	;A
	retlw 0x13	;153
	retlw 0x40	;REST
	retlw 0x37	;447
	retlw 0x09	;A
	retlw 0x16	;178
	retlw 0x40	;REST
	retlw 0x41	;522
	retlw 0x07	;G
	retlw 0x2E	;375
	retlw 0x06	;F#
	retlw 0x33	;410
	retlw 0x04	;E
	retlw 0x2D	;363
	retlw 0x40	;REST
	retlw 0x01	;12
	retlw 0x06	;F#
	retlw 0x35	;428
	retlw 0x40	;REST
	retlw 0x02	;22
	retlw 0x07	;G
	retlw 0x16	;178
	retlw 0x40	;REST
	retlw 0x50	;642
	retlw 0x09	;A
	retlw 0x10	;133
	retlw 0x40	;REST
	retlw 0x4C	;612
	retlw 0x0B	;B
	retlw 0x0E	;113
	retlw 0x40	;REST
	retlw 0xB4	;1442
	retlw 0x0E	;D
	retlw 0xBA	;1495
	retlw 0x10	;E
	retlw 0x82	;1043
	retlw 0x40	;REST
	retlw 0x39	;462
	retlw 0x0E	;D
	retlw 0x2D	;360
	retlw 0x0C	;C
	retlw 0x16	;178
	retlw 0x40	;REST
	retlw 0x1E	;242
	retlw 0x0C	;C
	retlw 0x10	;128
	retlw 0x40	;REST
	retlw 0x1F	;252
	retlw 0x0C	;C
	retlw 0x10	;133
	retlw 0x40	;REST
	retlw 0x1C	;227
	retlw 0x0C	;C
	retlw 0x2C	;355
	retlw 0x0B	;B
	retlw 0x13	;153
	retlw 0x40	;REST
	retlw 0x1E	;247
	retlw 0x0B	;B
	retlw 0x0D	;108
	retlw 0x40	;REST
	retlw 0x23	;282
	retlw 0x0B	;B
	retlw 0x10	;133
	retlw 0x40	;REST
	retlw 0x1E	;247
	retlw 0x0B	;B
	retlw 0x2F	;380
	retlw 0x09	;A
	retlw 0x13	;158
	retlw 0x40	;REST
	retlw 0x1B	;222
	retlw 0x09	;A
	retlw 0x13	;153
	retlw 0x40	;REST
	retlw 0x1E	;242
	retlw 0x09	;A
	retlw 0x10	;128
	retlw 0x40	;REST
	retlw 0x23	;282
	retlw 0x07	;G
	retlw 0x2B	;350
	retlw 0x06	;F#
	retlw 0x2F	;380
	retlw 0x04	;E
	retlw 0x31	;395
	retlw 0x06	;F#
	retlw 0x35	;428
	retlw 0x40	;REST
	retlw 0x05	;47
	retlw 0x07	;G
	retlw 0xB4	;468
	retlw 0xFF
	

              END
