              LIST    p=16F84 ; PIC16F844 is the target processor

              #include "P16F84.INC" ; Include header file

              CBLOCK 0x10   ; Temporary storage
                 state
                 secs
                 mins
                 hours
                 ticks
                 idc
                 bcd
              ENDC

; Constants for bit allocation. The BIT_x constants are actual bit numbers and
; the MASK_x are bit masks for the same bit.
BIT_HSEL      EQU H'0000'
BIT_TSET      EQU H'0001'
BIT_HSET      EQU H'0002'
BIT_MSET      EQU H'0003'

BIT_H24       EQU H'0000'
BIT_PM        EQU H'0001'
BIT_SET       EQU H'0002'
BIT_HSB       EQU H'0003'

MASK_H24      EQU H'0001'
MASK_PM       EQU H'0002'
MASK_SET      EQU H'0004'
MASK_HSB      EQU H'0008'


; Macro to generate a MOVLW instruction that also causes a model break:
break         MACRO arg
              DW    0x3100 | (arg & H'FF')
              ENDM

              ORG   0
entrypoint    goto  initialise

              ORG   4
intvector     goto    clock

initialise    ; Register set up:
              clrw                    ; Zero.
              movwf   PORTA           ; Ensure PORTA is zero before we enable it.
              movwf   PORTB           ; Ensure PORTB is zero before we enable it.
              bsf     STATUS,RP0      ; Select Bank 1
              movlw   H'1F'           ; Mask for PORTA inputs/outputs.
              movwf   TRISA           ; Set TRISA register.
              movlw   H'01'           ; Mask for PORTA inputs/outputs.
              movwf   TRISB           ; Set TRISB register.
              bcf     STATUS,RP0      ; Reselect Bank 0.

              ; Initialise clock:
              clrf    state
              bsf     state,BIT_HSB
              movlw   D'0'
              movwf   hours
              movlw   D'0'
              movwf   mins
              movlw   D'0'
              movwf   secs

              ; Clear 50Hz tick count:
              clrf    ticks

              ; Clear interrupt disable count (idc) semaphore:
              clrf    idc

              ; Initialise display:
              call    wr_hours
              call    wr_mins
              call    wr_secs
              call    wr_state

              ; Finally initialise interrupts for clock on RB0/INT pin:
              movlw   H'90'
              movwf   INTCON

start         ; When not processing an interrupt we sit and check input pins:
              call    chk_tset        ; Time set select active?
              call    chk_hsel        ; H12/H24 display format select active?
              goto    start


;------------------------------------------------------------------------------
; Interrupt handler. We come here for every tick of the time base.

clock         ; Toggle half-second flag and set state outputs:
              incf    ticks,F         ; Increment clock ticks.
              movf    ticks,W         ; Get ticks value.
              sublw   D'25'           ; Is it 25 (W=25-W)?
              btfss   STATUS,Z        ; Test zero flag.
              goto    endclock        ; Return.

toggle_hs     ; Half second - toggle HS flag, write it and return:
              clrf    ticks           ; Reset timebase,
              movf    state,W         ; Get state.
              xorlw   MASK_HSB        ; Toggle half-second bit.
              movwf   state           ; Save it back to register.
              call    wr_state        ; Display it.
              movf    state,W         ; Get state.
              btfss   state,BIT_HSB   ; Is bit now clear?
              goto    endclock        ; Return.

inc_secs      ; Incrmement seconds...
              incf    secs,F          ; Increment seconds count.
              movf    secs,W          ; Get it into W.
              sublw   D'60'           ; Is it 60 (W=60-W)?
              btfsc   STATUS,Z        ; Test zero flag, skip clear if no set.
              goto    reset_secs      ; Clear seconds, increment minutes.
              call    wr_secs         ; Write seconds it to display.
              goto    endclock        ; Done.

reset_secs    clrf    secs
              call    wr_secs         ; Write seconds to display.

              incf    mins,F          ; Increment minute count.
              movf    mins,W          ; Get it into W.
              sublw   D'60'           ; Is it 60 (W=60-W)?
              btfsc   STATUS,Z        ; Test zero flag, skip clear if no set.
              goto    reset_mins      ; Clear minutes, increment hours.
              call    wr_mins         ; Write minutes it to display.
              goto    endclock        ; Done.

reset_mins    clrf    mins            ; Reset minute count to zero.
              call    wr_mins         ; Write minutes to display.

              call    inc_hours       ; Increment hours, display it with PM flag.
              
endclock      movlw   H'90'
              movwf   INTCON
              retfie                  ; Return

;------------------------------------------------------------------------------
; Subroutine. Check the state of the HSEL input and set h12/h24 format as
; required.

chk_hsel      btfsc   PORTA,BIT_HSEL  ; Test 12/24 select.
              goto    set_h12         ; H12 set so switch to 12 hour format.
              ; fall through          ; H12 not set so switch to 24 hour format.

set_h24       btfsc   state,BIT_H24   ; Are we on 12 hour format?
              retlw   0               ; No, so no need to do anything...

              bcf     INTCON,GIE      ; Disable interrupts.
              incf    idc,F           ; Increment count of number of disables.
              bsf     state,BIT_H24   ; Clear h12 flag.

              movf    hours,W         ; Get hours value.
              sublw   D'12'           ; Is it 12:xx?
              btfsc   STATUS,Z        ; Test zero flag.
              clrf    hours           ; Reset to zero.
              movf    hours,W         ; Get hours value.
              btfsc   state,BIT_PM    ; Is the PM indicator set?
              addlw   D'12'           ; Add 12 to get 24 hour value.
              movwf   hours           ; Save result (does nothing for AM).
              bcf     state,BIT_PM    ; Clear PM flag.
              call    wr_hours        ; Write hours.
              call    wr_state        ; Write H12 state and PM state.
              goto    chk_hsel_iec    ; Done.

set_h12       btfss   state,BIT_H24   ; Are we on 12 hour format?
              retlw   0               ; Yes, so no need to do anything...

              bcf     INTCON,GIE      ; Disable interrupts.
              incf    idc,F           ; Increment count of number of disables.
              bcf     state,BIT_H24   ; Set h12 flag.

              movf    hours,W         ; Get hour value.
              sublw   D'11'           ; W=11-W. C is clear for a borrow (W>=12).
              btfss   STATUS,C        ; Test carry flag.
              goto    set_h12_pm      ; Set PM.

set_h12_am    bcf     state,BIT_PM    ; Clear PM bit.
              movf    hours,W         ; Get hours.
              btfsc   STATUS,Z        ; Is it zero?
              addlw   D'12'           ; Yes, add 12 to get 00:xx to 12:xx.
              movwf   hours           ; Save any result.
              call    wr_hours        ; Display hours.
              call    wr_state        ; Display H12 and PM states.
              goto    chk_hsel_iec    ; Done.

set_h12_pm    bsf     state,BIT_PM    ; Set PM bit.
              movlw   D'12'           ; Constant.
              subwf   hours,F         ; hours=hours-12 (23..12 -> 11..0).
              btfsc   STATUS,Z        ; Zero set?
              movwf   hours           ; Yes, so reset to '12'.
              call    wr_hours        ; No, so leave hours alone and display it.
              call    wr_state        ; Display H12 and PM states.
              goto    chk_hsel_iec    ; Done.

chk_hsel_iec  decfsz  idc,F           ; Decrement idc. If zero we can reenable interrupts.
              retlw   1               ; Return without enabling interrupts.

chk_hsel_done movlw   H'90'           ; Constant for GIE and T0IE.
              movwf   INTCON          ; Set interrupt register.
              retlw   1               ; Return.

;------------------------------------------------------------------------------
chk_tset      btfsc   PORTA,BIT_TSET  ; Set mode?
              retlw   0

              bcf     INTCON,GIE      ; Disable interrupts.
              incf    idc,F           ; Increment count of number of disables.
              bsf     state,BIT_SET   ; Set the 'set mode' bit.
              clrf    secs            ; Setting time resets seconds count.
              call    wr_secs         ; Display it.
              bcf     state,BIT_HSB   ; Clear seconds toggle.
              call    wr_state        ; Update the state output latch.

set_loop      call    chk_hsel        ; Check for H12/H24 display change.
              btfss   PORTA,BIT_MSET  ; If pin is high then switch is open.
              goto    set_mins        ; Bit not set, switch closed, set minutes.
              btfss   PORTA,BIT_HSET  ; If pin is high then switch is open.
              goto    set_hours       ; Bit not set, switch closed, set hours.
              btfss   PORTA,BIT_TSET  ; If pin is high then switch is open.
              goto    set_loop        ; Bit not set, switch closed, loop.

              bcf     state,BIT_SET   ; Clear the 'set mode' bit.
              call    wr_state        ; Update the state output latch.

chk_tset_idc  decfsz  idc,F           ; Decrement idc. If zero we can reenable interrupts.
              retlw   1               ; Return without enabling interrupts.
chk_tset_done movlw   H'90'           ; Constant for GIE and T0IE.
              movwf   INTCON          ; Set interrupt register.
              retlw   1               ; Return.

set_mins      incf    mins,F          ; Increment minute count.
              movf    mins,W          ; Get it into W.
              sublw   D'60'           ; Is it 60 (W=60-W)?
              btfsc   STATUS,Z        ; Test zero flag, skip clear if no set.
              clrf    mins            ; Clear minutes.
              call    wr_mins         ; Write minutes.

debounce_mset btfss   PORTA,BIT_MSET  ; Wait for MSET button to be released.
              goto    debounce_mset   ; Loop.
              goto    set_loop        ; Released so recheck buttons.

set_hours     call    inc_hours       ; Increment hours and display.
debounce_hset btfss   PORTA,BIT_HSET  ; Wait for HSET button to be released.
              goto    debounce_hset   ; Loop.
              goto    set_loop        ; Released so recheck buttons.

;------------------------------------------------------------------------------
; Increment hours, set PM indicator bit as necessary.

inc_hours     btfsc   state,BIT_H24   ; 12h display?
              goto    reset_on24      ; No,  so we reset when we get to 24.

reset_on12    movf    hours,W         ; Get hours
              sublw   D'12'           ; Is it 12 (W=12-W)?
              btfsc   STATUS,Z        ; Test zero flag, skip clear if no set.
              clrf    hours           ; Clear hours.
              incf    hours,F         ; Increment hours.
              call    wr_hours        ; Write it.
              movf    hours,W         ; Get hours
              sublw   D'12'           ; Is it 12 (W=12-W)?
              btfss   STATUS,Z        ; Test zero flag.
              return                  ; Zero not set, so not 12, so return.
              movlw   MASK_PM         ; Get PM state bit mask.
              xorwf   state,F         ; Toggle PM state bit in state.
              call    wr_state        ; Update state outputs.
              return                  ; Return.

reset_on24    incf    hours,F         ; Incrment hours.
              movf    hours,W         ; Get it in W.
              sublw   D'24'           ; Is it 24 (W=24-W)?
              btfsc   STATUS,Z        ; Test zero flag, skip clear if no set.
              clrf    hours           ; Clear hours 24->0.
              call    wr_hours        ; Write hours to display.
              return

;------------------------------------------------------------------------------
; Get seconds value, split to get BCD pair and write to port.
wr_secs       movf    secs,W          ; Get seconds.
              call    bin2bcd         ; Convert to BCD.
              movwf   bcd             ; Save result.
              andlw   0xF0            ; Mask BCD pair to leave upper digit in W upper nibble.
              iorlw   0x0A            ; Select strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe (by selecting Q0).
              movwf   PORTB           ; Write to PORTB.
              swapf   bcd,W           ; Get lower BCD digit in to W upper nibble.
              andlw   0xF0            ; Mask of strobe selection bits.
              iorlw   0x0C            ; Set WR strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe.
              movwf   PORTB           ; Write to PORTB.
              return                  ; Return.

;------------------------------------------------------------------------------
; Get minutes value, split to get BCD pair and write to port.
wr_mins       movf    mins,W          ; Get minutes value.
              call    bin2bcd         ; Convert to BCD.
              movwf   bcd             ; Save result.
              andlw   0xF0            ; Mask BCD pair to leave upper digit in W upper nibble.
              iorlw   0x06            ; Select strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe (by selecting Q0).
              movwf   PORTB           ; Write to PORTB.
              swapf   bcd,W           ; Get lower BCD digit in to W upper nibble.
              andlw   0xF0            ; Mask of strobe selection bits.
              iorlw   0x08            ; Set WR strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe.
              movwf   PORTB           ; Write to PORTB.
              return                  ; Return.

;------------------------------------------------------------------------------
; Get hours value, split to get BCD pair and write to port.
wr_hours      movf    hours,W         ; Get hours value/
              call    bin2bcd         ; Convert to BCD.
              movwf   bcd             ; Save result.
              andlw   0xF0            ; Mask BCD pair to leave upper digit in W upper nibble.
              iorlw   0x02            ; Select strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe (by selecting Q0).
              movwf   PORTB           ; Write to PORTB.
              swapf   bcd,W           ; Get lower BCD digit in to W upper nibble.
              andlw   0xF0            ; Mask of strobe selection bits.
              iorlw   0x04            ; Set WR strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe.
              movwf   PORTB           ; Write to PORTB.
              return                  ; Return.

;------------------------------------------------------------------------------
; Write state bits to state latch.
wr_state      swapf   state,W         ; Get state bits in to W<4:1>.
              iorlw   0x0E            ; Set WR strobe.
              movwf   PORTB           ; Write to PORTB.
              andlw   0xF0            ; Clear strobe by selecting Q0.
              movwf   PORTB           ; Write to PORTB.
              return

;------------------------------------------------------------------------------
; Routine to convert a binary value  (0..63) in to a BCD pair. The result is
; returned in W. The lookup is done as a 'calculated goto' by modifying PCL
; (the lower eight bits of the program counter). PCL is only eight bits wide
; with the top five bits coming from the PCLATH register. We use an ORG
; statement to ensure that addition of the offset (0..63) to the table address
; doesn't overflow the PCL register (any overflow would be lost and would result
; in a jump to some other part of the code).

              ORG     0x0100

bin2bcd       clrf    PCLATH          ; Clear PCLATH.
              bsf     PCLATH,0        ; Set bit zero so that goto yields an
                                      ; address 0x01xx.
              andlw   H'3F'           ; Ensure we limit lookup.
              addwf   PCL,F           ; Add offset in W to PCL to calc. goto.

              retlw   0x00
              retlw   0x01
              retlw   0x02
              retlw   0x03
              retlw   0x04
              retlw   0x05
              retlw   0x06
              retlw   0x07
              retlw   0x08
              retlw   0x09
              retlw   0x10
              retlw   0x11
              retlw   0x12
              retlw   0x13
              retlw   0x14
              retlw   0x15
              retlw   0x16
              retlw   0x17
              retlw   0x18
              retlw   0x19
              retlw   0x20
              retlw   0x21
              retlw   0x22
              retlw   0x23
              retlw   0x24
              retlw   0x25
              retlw   0x26
              retlw   0x27
              retlw   0x28
              retlw   0x29
              retlw   0x30
              retlw   0x31
              retlw   0x32
              retlw   0x33
              retlw   0x34
              retlw   0x35
              retlw   0x36
              retlw   0x37
              retlw   0x38
              retlw   0x39
              retlw   0x40
              retlw   0x41
              retlw   0x42
              retlw   0x43
              retlw   0x44
              retlw   0x45
              retlw   0x46
              retlw   0x47
              retlw   0x48
              retlw   0x49
              retlw   0x50
              retlw   0x51
              retlw   0x52
              retlw   0x53
              retlw   0x54
              retlw   0x55
              retlw   0x56
              retlw   0x57
              retlw   0x58
              retlw   0x59
              retlw   0x60
              retlw   0x61
              retlw   0x62
              retlw   0x63

              END
