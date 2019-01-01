                 LIST    p=16F877
                 #include "P16F877.INC"

SDO              EQU 7
CLK              EQU 6

                 ORG   0
entrypoint       goto  start

                 ORG   4
intvector        goto    intvector

                 CBLOCK 0x30
                    address, value, byte, bit, ack
                    lc1, lc2, lc3
                 ENDC


set_sdo_high     bcf    STATUS,RP0
                 bcf    PORTC,SDO
                 bsf    STATUS,RP0
                 bsf    TRISC,SDO
                 bcf    STATUS,RP0
                 return

set_sdo_low      bcf    STATUS,RP0
                 bcf    PORTC,SDO
                 bsf    STATUS,RP0
                 bcf    TRISC,SDO
                 bcf    STATUS,RP0
                 return

;-----------------------------------------------------------
set_clk_high     bcf    STATUS,RP0
                 bsf    PORTC,CLK
                 bsf    STATUS,RP0
                 bcf    TRISC,CLK
                 bcf    STATUS,RP0
                 return

;-----------------------------------------------------------
set_clk_low      bcf    STATUS,RP0
                 bcf    PORTC,CLK
                 bsf    STATUS,RP0
                 bcf    TRISC,CLK
                 bcf    STATUS,RP0
                 return

;-----------------------------------------------------------
wait_quarter_bit movlw  0x06
                 movwf  lc1
wqb0:            decfsz lc1,F
                 goto   wqb0
                 return

;-----------------------------------------------------------
wait_half_bit    movlw  0x10
                 movwf  lc1
whb0:            decfsz lc1,F
                 goto   wqb0
                 return

;-----------------------------------------------------------
init             movlw 0xFF
                 movwf PORTC
                 movlw 0x00
                 bsf   STATUS,RP0
                 movwf TRISC
                 bcf   STATUS,RP0
                 return

;-----------------------------------------------------------
wr_start         call  set_clk_high
                 call  wait_half_bit
                 call  set_sdo_low
                 call  wait_half_bit
                 call  set_clk_low
                 call  wait_half_bit
                 call  wait_half_bit
                 call  wait_half_bit
                 return
;-----------------------------------------------------------
wr_stop          call  wait_half_bit
                 call  set_clk_low
                 call  wait_half_bit
                 call  set_sdo_low
                 call  wait_half_bit
                 call  set_clk_high
                 call  wait_half_bit
                 call  set_sdo_high
                 call  wait_half_bit
                 return

;-----------------------------------------------------------
wr_restart       call   set_clk_low
                 call   wait_half_bit
                 call   set_sdo_high
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_sdo_low
                 call   wait_half_bit
                 call   set_clk_low
                 call   wait_half_bit
                 return

;-----------------------------------------------------------
wr_ack           call   set_clk_low
                 call   wait_half_bit
                 call   set_sdo_low
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low
                 call   wait_half_bit
                 call   set_sdo_high
                 call   wait_half_bit
                 return

;-----------------------------------------------------------
wr_no_ack        call   set_clk_low
                 call   wait_half_bit
                 call   set_sdo_high
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low
                 call   wait_half_bit
                 call   wait_half_bit
                 return

;-----------------------------------------------------------
; Generate a reset by generating a stop followed by at least
; eight clock pulses.
wr_reset         call   wait_half_bit
                 call   set_clk_low
                 call   wait_half_bit
                 call   set_sdo_low
                 call   wait_half_bit
                 call   set_clk_high

                 movlw  0x40
                 movwf  lc1
wrr0:            decfsz lc1,F
                 goto   wrr0

                 call   set_sdo_high

                 movlw  0x40
                 movwf  lc1
wrr1:            decfsz lc1,F
                 goto   wrr1

                 call   set_clk_low             ; clk 0
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 1
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 2
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 3
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 4
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 5
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 6
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 7
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit
                 call   set_clk_low             ; clk 8
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_half_bit

                 return


;-----------------------------------------------------------
wr_bit           bcf   STATUS,RP0
                 call  wait_quarter_bit
                 movf  bit,w
                 andwf byte,w
                 btfsc STATUS,Z
                 goto  bit_is_0

bit_is_1         call  set_sdo_high
                 goto  wbit0

bit_is_0         call  set_sdo_low
                 goto  wbit0


wbit0            bcf   STATUS,RP0
                 call  wait_quarter_bit
                 call  set_clk_high
                 call  wait_half_bit
                 call  set_clk_low
                 return

;-----------------------------------------------------------
wr_byte          movwf byte
                 movlw 0x80
                 movwf bit

wbyte0           call  wr_bit
                 bcf   STATUS,C
                 rrf   bit,F
                 movf  bit,F
                 btfss STATUS,Z
                 goto  wbyte0

                 call  wait_quarter_bit
                 call  set_sdo_high
                 call  wait_quarter_bit
                 call  set_clk_high
                 call  wait_quarter_bit
                 movf  PORTC,W
                 andlw (1<<SDO)
                 xorlw (1<<SDO)
                 movwf ack
                 call  wait_quarter_bit
                 call  set_clk_low
                 call  wait_quarter_bit
                 return

;-----------------------------------------------------------
wr_halfbyte      movwf byte
                 movlw 0x08
                 movwf bit

whbyte0          call  wr_bit
                 bcf   STATUS,C
                 rrf   bit,F
                 movf  bit,F
                 btfss STATUS,Z
                 goto  whbyte0

                 call  wait_quarter_bit
                 call  set_sdo_high
                 call  wait_quarter_bit
                 call  set_clk_high
                 call  wait_quarter_bit
                 movf  PORTC,W
                 andlw (1<<SDO)
                 xorlw (1<<SDO)
                 movwf ack
                 call  wait_quarter_bit
                 call  set_clk_low
                 call  wait_quarter_bit
                 return

;-----------------------------------------------------------
rd_bit           bcf    STATUS,RP0
                 call   set_sdo_high
                 call   set_clk_low
                 call   wait_half_bit
                 call   set_clk_high
                 call   wait_quarter_bit
                 movf   PORTC,W
                 andlw  (1<<SDO)
                 btfsc  STATUS,Z
                 goto   rd_bit_clear
                 movf   bit,W
                 iorwf  byte,F
rd_bit_clear     call   wait_quarter_bit
                 call   set_clk_low
                 return

;-----------------------------------------------------------
rd_byte          movlw  0x00
                 movwf  byte
                 movlw  0x80
                 movwf  bit

rbyte0           call   rd_bit
                 bcf    STATUS,C
                 rrf    bit,F
                 movf   bit,F
                 btfss  STATUS,Z
                 goto   rbyte0
                 movf   byte,W
                 return

;-----------------------------------------------------------
; Write W register to PORTD and hang.
wr_error         bcf   STATUS,RP0
                 movwf PORTD
                 bsf   STATUS,RP0
                 clrf  TRISD
                 bcf   STATUS,RP0

wre_flash        bsf    PORTA,0
                 movlw  0xFF
                 call   longwait
                 movlw  0xFF
                 call   longwait
                 bcf    PORTA,0
                 movlw  0xFF
                 call   longwait
                 movlw  0xFF
                 call   longwait
                 goto   wre_flash
                 return

;-----------------------------------------------------------
; Write W register to PORTD and hang.
wr_result        bcf   STATUS,RP0
                 movwf PORTD
                 bsf   STATUS,RP0
                 clrf  TRISD
                 bcf   STATUS,RP0

wrr_flash        bsf    PORTA,0
                 movlw  0x30
                 call   vlongwait
                 bcf    PORTA,0
                 movlw  0x03
                 call   vlongwait
                 goto   wrr_flash
                 return

;-----------------------------------------------------------
vlongwait        movwf  lc1
vlw1             movlw  0xFF
                 movwf  lc2
vlw2             movlw  0xFF
                 movwf  lc3
vlw3             decfsz lc3,F
                 goto   vlw3
                 decfsz lc2,F
                 goto   vlw2
                 decfsz lc1,F
                 goto   vlw1
                 return

;-----------------------------------------------------------
longwait         movwf  lc1
lw1              movlw  0xFF
                 movwf  lc2
lw2              decfsz lc2,F
                 goto   lw2
                 decfsz lc1,F
                 goto   lw1
                 return

;-----------------------------------------------------------
hang             goto  hang


;===========================================================
start            call  init
                 call  wr_reset


                 bcf   STATUS,RP0
                 clrf  PORTA
                 clrf  PORTD

                 bsf   STATUS,RP0
                 movlw 0x06
                 movwf ADCON1
                 movlw 0x20
                 movwf TRISA
                 clrf  TRISD

                 bcf   STATUS,RP0
                 clrf  PORTA
                 clrf  address
                 clrf  value

                 ; Test RA5 to see if we do writes:
                 btfss PORTA,5
                 goto  reset_addr

                 ; Do start condition:
main_wr_loop:    call   wr_start

                 ; Send write command:
                 movlw  0xA6
                 call   wr_byte
                 movlw  0x01
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 ; Send address:
                 movf   address,W
                 call   wr_byte
                 movlw  0x02
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 ; Send value:
                 movf   value,W
                 call   wr_byte
                 movlw  0x03
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 ; Do stop. This starts the write cycle.
                 call   wr_stop

                 ; Now poll for acknowledge:
poll_for_ack     call   wr_start
                 movlw  0xA6
                 call   wr_byte
                 movlw  0x04
                 movf   ack,F
                 btfsc  STATUS,Z
                 goto   poll_for_ack

                 ; Increment address/data and loop round:
                 incf   address
                 incf   value
                 btfss  address,4
                 goto   main_wr_loop

                 ; Cancel sucessful poll command:
                 call   wr_stop

wait             movlw  0x10
                 call   longwait

reset_addr       ; Generate start condition...
                 call   wr_start

                 ; Write command:
                 movlw  0xA6
                 call   wr_byte
                 movlw  0x05
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 ; Send address:
                 clrf   address
                 movf   address,W
                 call   wr_byte
                 movlw  0x06
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 ; Send stop:
                 call   wr_stop

read_bytes       call  wr_start
                 movlw  0xA7
                 call   wr_byte
                 movlw  0x07
                 movf   ack,F
                 btfsc  STATUS,Z
                 call   wr_error

                 bsf    PORTA,1
                 nop
                 nop
                 nop
                 bcf    PORTA,1

                 ; Do read:
main_rd_loop     call   rd_byte

                 ; Is this the value we expected?
                 movf   address,W
                 subwf  byte,W
                 movlw  0x08
                 btfss  STATUS,Z
                 call   wr_error

                 ; Increment address/data and loop round:
                 incf   address
                 btfsc  address,4
                 goto   done

                 ; Not done yet so acknowledge byte and read next one:
                 call   wr_ack
                 goto   main_rd_loop


                 ; Stop condition marks end of sequential read:
done             call   wr_no_ack
                 call   wr_stop

                 ; End of test:
                 call hang

                 END

