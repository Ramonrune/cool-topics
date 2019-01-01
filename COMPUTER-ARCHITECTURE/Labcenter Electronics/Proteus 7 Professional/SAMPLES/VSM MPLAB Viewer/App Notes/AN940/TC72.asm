;----------------------------------------------------------------------
;
;                     Software License Agreement
;
; The software supplied herewith by Microchip Technology Incorporated
; (the "Company") for its PICmicro® Microcontroller is intended and
; supplied to you, the Company’s customer, for use solely and
; exclusively on Microchip PICmicro Microcontroller products.
;
; The software is owned by the Company and/or its supplier, and is
; protected under applicable copyright laws. All rights are reserved.
; Any use in violation of the foregoing restrictions may subject the
; user to criminal sanctions under applicable laws, as well as to
; civil liability for the breach of the terms and conditions of this
; license.
;
; THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;                                                                     
;----------------------------------------------------------------------
;
;   Filename:           TC72 PICtail.asm
;   Date:               January 26, 2004
;   File Version:       0.1
;   Assembled using:    MPLAB IDE v6.50
;
;   Author:             Steven Bible
;   Company:            Microchip Technology Inc.
;
;
;----------------------------------------------------------------------
;
;   Files required:
;                       p16f676.inc
;
;
;----------------------------------------------------------------------
;
;   Program Description 
;
;   This program demonstrates the Microchip TC72 Thermal Sensor with
;   SPI(tm) compatible interface using the PICkit 1 FLASH Starter Kit.
;   The temperature is read from the TC72 and displayed on LEDs 
;   D0 through D7 in Binary Coded Decimal (BCD).
;
;----------------------------------------------------------------------

    list        p=16f676        ; list directive to define processor
    #include    <p16f676.inc>   ; processor specific variable definitions

    errorlevel  -302            ; suppress message 302 from list file

; ---------------------------------------------------------------------
; Configuration Bits (Section 9.1 Configuration Bits)
; ---------------------------------------------------------------------
;
; Data Memory Code Protection bit:
; _CPD = Enabled
; _CPD_OFF = Disabled
;
; Program Memory Code protection:
; _CP = Enabled
; _CP_OFF = : Disabled
;
; Brown-out Detection Enable bit:
; _BODEN = Enabled
; _BODEN_OFF = Disabled
;
; GP3/MCLR pin function select:
; _MCLRE_ON = GP3/MCLR pin function is /MCLR
; _MCLRE_OFF = GP3/MCLR pin function is digital I/O, 
;              /MCLR internally tied to Vdd
;
; Power-up Timer Enable bit:
; _PWRTE_ON = Enabled
; _PWRTE_OFF = Disabled
;
; Watchdog Timer Enable bit:
; _WDT_ON = Enabled
; _WDT_OFF = Disabled
;
; Oscillator Selction bits:
; _EXTRC_OSC_NOCLKOUT = CLKOUT function on GP4 pin, RC on GP5 pin.
; _EXTRC_OSC_CLKOUT = I/O function on GP4 pin, RC on GP5 pin.
; _INTRC_OSC_CLKOUT =  Internal oscillator, CLKOUT function on GP4 pin,
;                      I/O function on GP5 pin.
; _INTRC_OSC_NOCLKOUT = Internal oscillator, I/O function on GP4 and GP5 pins.
; _EC_OSC = I/O function on GP4 pin, CLKIN on GP5 pin.
; _HS_OSC = High speed crystal/resonator on GP4 and GP5 pins.
; _XT_OSC = Crystal/resonator on GP4 and GP5 pins.
; _LP_OSC = Low power crystal on GP4 and GP5 pins.
;
;
; ---------------------------------------------------------------------

    __CONFIG    _CPD_OFF & _CP_OFF & _BODEN & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT

;----------------------------------------------------------------------
; Variables  (Section 2.2 Data Memory Organization)
;----------------------------------------------------------------------

    ; Data Memory Organization (Section 2.2)
    ;
    ; The data memory is partitioned into two banks which contain
    ; the General Purpose Registers and the Special Function Registers.
    ; The Special Function registers are located in the first 32 
    ; locations of each bank. Register locations 0x20 to 0x5F (64 bytes)
    ; are General Purpose registers, implemented as static RAM and are
    ; mapped across both banks. 
    ;
    ;   RP0 (STATUS<5>)
    ;    0  ->  Bank 0
    ;    1  ->  Bank 1
    ;
    ; Refer to Section 2.2 of the data sheet for the organization of 
    ; the General Purpose Registers.

    ; Bank 0 General Purpose Registers

    cblock  0x20    ; File Address 0x20-0x5F (64 bytes)

        W_TEMP                      ; used for context saving 
        STATUS_TEMP                 ; used for context saving
        PCLATH_TEMP                 ; used for context saving
        FSR_TEMP                    ; used for context saving

        TEMP                        ; General Purpose Temporary register

        FLAG                        ; A byte of binary flags (see Defines below)

        TICK                        ; Tick counter

        ; LED Display on PICkit 1 Flash Starter Kit

        LEDREG                      ; LED Array Register
        LEDSTATE                    ; LED Array State Counter
        LEDDISP                     ; LED Array Display bit (which LED is lit)

        ; TC72 Thermal Sensor variables

        BIT_CNTR                    ; Bit counter

        TC72_ADX                    ; TC72 Address
        TC72_MSB                    ; TC72 MSB Temperature
        TC72_LSB                    ; TC72 LSB Temperature
        TC72_CTRL                   ; TC72 Control Register

        TEMP_MSB                    ; Temporary Register Most Significant Byte
        TEMP_LSB                    ; Temporary Register Least Significant Byte

        ; Binary Coded Decimal (BCD) variables

        BCD_H                       ; BCD Hundreds
        BCD_T                       ; BCD Tens
        BCD_O                       ; BCD Ones

    endc


;----------------------------------------------------------------------
; Defines
;----------------------------------------------------------------------

    ;--------------------
    ; PORTA (Section 3.1)
    ;--------------------
    ; PORTA is an 6-bit wide, bi-directional port. The corresponding data
    ; direction register is TRISA. Setting a TRISA bit (= 1) will make
    ; the corresponding PORTA pin and input. Clearing a TRISA bit (= 0)
    ; will make the corresponding PORTA pin an output. The exception is
    ; RA3, which is input only and its TRIS bit will always read as a '1'.
    ;
    ; Function of PORTA pins depend on:
    ;   Configuration Bits (CONFIG) (Section 9.1)
    ;   Weak Pull-up Register (WPU) (Section 3.2.1)
    ;   Interrupt-on-change Register (IOCB) (Section 3.2.2)
    ;   Option Register (OPTION_REG) (Register 4-1)
    ;   TIMER1 Control Register (T1CON) (Register 5-1)
    ;   Comparator Control Register (CMCON) (Section 6.0)
    ;   A/D Control Register (ADCON0) (Section 7.0) (PIC16F676 Only)

#define POT     PORTA, 0            ; (Analog Input) Potentiometer RP1
#define RA1     PORTA, 1            ; (Digital Input/Output) LEDs D6, D7
#define RA2     PORTA, 2            ; (Digital Input/Output) LEDs D2, D3, D4, D5, D6, D7
#define SW1     PORTA, 3            ; (Digital Input Only) Push Button SW1
#define RA4     PORTA, 4            ; (Digital Input/Output) LEDs D0, D1, D2, D3
#define RA5     PORTA, 5            ; (Digital Input/Output) LEDs D0, D1, D4, D5

    ; Define for TRISA Register (Section 3.1)

    ;   PORTA Pins = xx543210
#define PORTATRIS  b'00111111'

    ;--------------------
    ; PORTC (Section 3.3)
    ; --------------------
    ; PORTC is a general purpose I/O port consisting of 6 bi-directional
    ; pins. The pins can be configured for either digital I/O or analog
    ; input to A/D converter. For specific information about individual
    ; functions such as the comparator or the A/D.

#define SCK     PORTC, 0            ; (Digital Output) Serial Clock (Output)
#define SDI     PORTC, 1            ; (Digital Input) Serial Data In (w.r.t. PICmicro)
#define SDO     PORTC, 2            ; (Digital Output) Serial Data Out (w.r.t. PICmicro)
#define TC72_CE PORTC, 3            ; (Digital Output) TC72 Chip Enable (active high)
#define TX      PORTC, 4            ; USART
#define RX      PORTC, 5            ; USART

    ; Define for TRISC Register (Section 3.3)

    ;   PORTC Pins = xx543210
#define PORTCTRIS  b'00110010'

    ;--------------------
    ; Program Defines
    ;--------------------

    ; Flags

#define TRIP     0              ; Tick counter trip flag
#define SIGN_BIT 1              ; temperature sign bit
#define C_F_DISP 2              ; Display in C or F

    ; LEDs

    ;    PORTA Pins = xx543210
#define LED0TRIS    b'00001111'
#define LED1TRIS    b'00001111'
#define LED2TRIS    b'00101011'
#define LED3TRIS    b'00101011'
#define LED4TRIS    b'00011011'
#define LED5TRIS    b'00011011'
#define LED6TRIS    b'00111001'
#define LED7TRIS    b'00111001'
#define LEDOFFTRIS  b'00111111'

    ;    PORTA Pins = xx543210
#define LED0ON      b'00010000'
#define LED1ON      b'00100000'
#define LED2ON      b'00010000'
#define LED3ON      b'00000100'
#define LED4ON      b'00100000'
#define LED5ON      b'00000100'
#define LED6ON      b'00000100'
#define LED7ON      b'00000010'


;----------------------------------------------------------------------
; Program Memory
;----------------------------------------------------------------------

    ; Program Memory Organization (Section 2.1)

        ORG     0x0000              ; RESET Vector

        nop                         ; for ICD use
        goto    MAIN                ; goto MAIN Program


        ORG     0x0004              ; Interrupt Vector
        goto    int_vector

int_vector
        ORG     0x0005
        movwf   W_TEMP              ; save W register
        swapf   STATUS, W           ; swap status to be saved into W
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movwf   STATUS_TEMP         ; save STATUS register
        movfw   PCLATH
        movwf   PCLATH_TEMP         ; save PCLATH_TEMP register
        movfw   FSR
        movwf   FSR_TEMP            ; save FSR_TEMP register

;----------------------------------------
; Interrupt Service Routine (ISR) (Section 9.4)
;
; Description: 
;
;----------------------------------------

        bcf     INTCON, T0IF        ; clear TMR0 Interrupt Flag

        call    DISPLAY             ; Update LED Array (light LEDs)

        decf    TICK, F             ; decrement tick counter
        btfsc   STATUS, Z
         bsf    FLAG, TRIP

;----------------------------------------

        movfw   PCLATH_TEMP         ; restore PCLATH_TEMP register
        movwf   PCLATH
        movfw   FSR_TEMP            ; restore FSR_TEMP register
        movwf   FSR
        swapf   STATUS_TEMP, W      ; swap status_temp into W, sets bank to original state
        movwf   STATUS              ; restore STATUS register
        swapf   W_TEMP, F
        swapf   W_TEMP, W           ; restore W register

        retfie


;----------------------------------------------------------------------
; Initialize PICmicro (PIC16F630/676)
;----------------------------------------------------------------------

INITIALIZE

; Disable global interrupts during initialization

        bcf     INTCON, GIE         ; disable global interrupts


;----------------------------------------
; Calibrating the Internal Oscillator (Section 9.2.5.1)
; Oscillator Calibration Register (OSCCAL) (Section 2.2.2.7)
;
; A calibration instruction is programmed into the last location of
; program memory. This instruction is a RETLW XX, where the literal is
; the calibration value. The literal is placed in the OSCCAL register
; to set the calibration of the internal oscillator.

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        ;call    0x3FF               ; retrieve factory calibration value
        ;movwf   OSCCAL              ; update register with factory cal value

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; PORTS A AND C (Section 3.0)
;
; Store PORTATRIS and PORTCTRIS values defined above into the
; TRISA and TRISC direction registers

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        movlw   PORTATRIS
        movwf   TRISA               ; Write to TRISA register

        movlw   PORTCTRIS
        movwf   TRISC               ; Write to TRISC register

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; Comparator Module (Section 6.0)
;
; The PIC16F630/676 devices have one analog comparator. The inputs to
; the comparator are multiplexed with the RA0 and RA1 pins. There is
; an on-chip Comparator Voltage Reference that can also be applied to
; an input of the comparator. In addition, RA2 can be configured as
; the comparator output. The Comparator Control Register (CMCON)
; contains bits to control the comparator. The Voltage Reference
; Control Register (VRCON) controls the voltage reference module.

        ; Comparator Configuration (Figure 6-2)
;        bcf     CMCON, CINV         ; Comparator Output Inversion: not inverted
;        bcf     CMCON, COUT         ; Comparator Output bit: Vin+ < Vin-
;        bcf     CMCON, CIS          ; Comparator Input Switch: Vin- connects to Cin-

        ; CM2:CM0 = 111 - Comparator Off (lowest power)
        bsf     CMCON, CM2          ; Comparator Mode bit 2
        bsf     CMCON, CM1          ; Comparator Mode bit 1
        bsf     CMCON, CM0          ; Comparator Mode bit 0

        ; VRCON (Register 6-2)
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        bcf     VRCON, VREN         ; CVref circuit: powered down, no Idd drain

;        bcf     VRCON, VRR          ; CVref Range Selection: High Range

;        bcf     VRCON, VR3          ; CVref value selection bit 3
;        bcf     VRCON, VR2          ; CVref value selection bit 2
;        bcf     VRCON, VR1          ; CVref value selection bit 1
;        bcf     VRCON, VR0          ; CVref value selection bit 0

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; Analog-to-Digital Converter (A/D) Module (Section 7.0) (PIC16F676 Only)
;
; The analog-to-digital converter (A/D) allows conversion of an analog
; input signal to a 10-bit binary representation of that signal. The
; PIC16F676 has eight analog inputs multiplexed into one sample and hold
; circuit. There are two registers to control the functions of the A/D
; module:
;   A/D Control Register 0 (ADCON0)
;   A/D Control Register 1 (ADCON1)
;   Analog Select Register (ANSEL)
;
; Note: When using PORTA or PORTC pins as analog inputs, ensure the 
;       TRISA or TRISC register bits are set (= 1) for input.

        bcf     ADCON0, ADFM        ; A/D Result Formed: left justified
        bcf     ADCON0, VCFG        ; Voltage Reference: Vdd

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        ; select A/D Conversion Clock Source: Fosc/8
        bcf     ADCON1, ADCS2       ; A/D Conversion Clock Select bit 2
        bcf     ADCON1, ADCS1       ; A/D Conversion Clock Select bit 1
        bsf     ADCON1, ADCS0       ; A/D Conversion Clock Select bit 0

        ; select GPIO pins that will be analog inputs: RA0/AN0
        bcf     ANSEL, ANS7         ; Analog Select RC3/AN7: digital I/O
        bcf     ANSEL, ANS6         ; Analog Select RC2/AN6: digital I/O
        bcf     ANSEL, ANS5         ; Analog Select RC1/AN5: digital I/O
        bcf     ANSEL, ANS4         ; Analog Select RC0/AN4: digital I/O
        bcf     ANSEL, ANS3         ; Analog Select RA3/AN3: digital I/O
        bcf     ANSEL, ANS2         ; Analog Select RA2/AN2: digital I/O
        bcf     ANSEL, ANS1         ; Analog Select RA1/AN1/Vref: digital I/O
        bsf     ANSEL, ANS0         ; Analog Select RA0/AN0: analog input

        bcf     STATUS, RP0         ;---- Select Bank 0 -----

        bcf     ADCON0, ADON        ; ADC is shut-off and consumes no operating current


;----------------------------------------
; TIMER1 Module with Gate Control (Section 5.0)
;
; The TIMER1 Control Register (T1CON) is used to enable/disable TIMER1
; and select various features of the TIMER1 module.

        bcf     T1CON, TMR1ON       ; TIMER1: stopped

        bcf     T1CON, TMR1CS       ; TIMER1 Clock Source Select: Internal Clock (Fosc/4)

        bcf     T1CON, NOT_T1SYNC   ; TIMER1 External Clock Input Sync Control: Syncronize external clock input

        ; T1OSCEN only if INTOSC without CLKOUT oscillator is active, else ignored
        bcf     T1CON, T1OSCEN      ; LP Oscillator Enable Control: LP oscillator off

        ; TIMER1 Input Prescale Select: 1:1
        bcf     T1CON, T1CKPS1      ; TIMER1 Input Clock Prescale Select bit 1
        bcf     T1CON, T1CKPS0      ; TIMER1 Input Clock Prescale Select bit 0

        ; TMR1GE only if TMR1ON = 1, else ignored
        bcf     T1CON, TMR1GE       ; TIMER1 Gate Enable: on


;----------------------------------------
; PORTA Weak Pull-up Register (WPUA) (Section 3.2.1)
;
; Each of the PORTA pins, except RA3, has an individually configurable
; weak internal pull-up. Control bits WPUAx enable or disable each 
; pull-up. Refer to Register 3-1. Each weak pull-up is automatically
; turned off when the port pin is configured as an output. The pull-ups
; are disabled on a Power-on Reset by the /RAPU bit (see OPTION Register
; below).

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

;    PORTA Pins = xx54x210
        movlw   B'00000000'         ; no pull-ups enabled
        movwf   WPUA

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; OPTION Register (OPTION_REG) (Section 2.2.2.2)
; TIMER0 Module (Section 4.0)
;
; The OPTION_REG contains control bits to configure:
;   Weak pull-ups on GPIO (see also WPU Register above)
;   External RA2/INT interrupt
;   TMR0
;   TMR0/WDT prescaler

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        bsf     OPTION_REG, NOT_GPPU ; PORTA pull-ups: disabled

        bsf     OPTION_REG, INTEDG  ; Interrupt Edge: on rising edge of RA2/INT pin

        bcf     OPTION_REG, T0CS    ; TMR0 Clock Source: internal instruction cycle (CLKOUT)
        bcf     OPTION_REG, T0SE    ; TMR0 Source Edge: increment low-to-high transition on GP2/T0CKI pin

        bcf     OPTION_REG, PSA     ; Prescaler Assignment: assigned to TIMER0

        ; TMR0 Prescaler Rate: 1:8
        bcf     OPTION_REG, PS2     ; Prescaler Rate Select bit 2
        bsf     OPTION_REG, PS1     ; Prescaler Rate Select bit 1
        bcf     OPTION_REG, PS0     ; Prescaler Rate Select bit 0

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; PORTA Interrupt-on-Change Register (IOCA) (Section 3.2.2)
;
; Each of the PORTA pins is individually configurable as an interrupt-
; on-change pin. Control bits IOCAx enable or disable the interrupt 
; function for each pin. Refer to Register 3-4. The interrupt-on-change
; is disabled on a Power-on Reset.
;
; Note: Global interrupt enables (GIE and GPIE) must be enabled for
;       individual interrupts to be recognized.

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

;     GPIO Pins = xx54x210
        movlw   B'00000000'
        movwf   IOCA                ; Interrupt-on-change disabled

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; Peripheral Interrupt Enable Register (PIE1) (Section 2.2.2.4)
;
; The PIE1 register contains peripheral interrupt enable bits.
;
; Note: The PEIE bit (INTCON<6>) must be set to enable any 
;       peripheral interrupt.

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        bcf     PIE1, EEIE          ; EE Write Complete Interrupt: disabled
        bcf     PIE1, ADIE          ; A/D Converter Interrupt (PIC12F675 Only): disabled
        bcf     PIE1, CMIE          ; Comparator Interrupt: disabled
        bcf     PIE1, TMR1IE        ; TMR1 Overflow Interrupt: disabled

        bcf     STATUS, RP0         ;---- Select Bank 0 -----


;----------------------------------------
; Interrupt Control Register (INTCON) (Section 2.2.2.3)
;
; The INTCON register contains enable and disable flag bits for TMR0
; register overflow, GPIO port change and external GP2/INT pin 
; interrupts.

        bsf     INTCON, T0IE        ; TMR0 Overflow Interrupt: ENABLED
        bcf     INTCON, INTE        ; RA2/INT External Interrupt: disabled
        bcf     INTCON, RAIE        ; Port Change Interrupt: disabled

        bcf     INTCON, PEIE        ; Peripheral Interrupts: disabled
                                    ; (EEI, ADI, CMI, TMR1I)

        bcf     INTCON, GIE         ; Global Interrupts: disabled

        return                      ; return from INITIALIZE

; end INITIALIZE

;----------------------------------------------------------------------
; Subroutine: DATA_EEPROM_READ
;
; Description: To read an EEPROM data memory location, the address is
;   written to the EEADR register and set control bit RD (EECON1<0>) to
;   initiate a read. Data is available in the EEDATA register the next
;   clock cycle.
;
; Constants: none
;   
; Global Variables: none
;   
; Initialization: W contains EEPROM address (EEADR) to be read
;   
; Output: W contains EEPROM data (EEDATA)
;
;----------------------------------------------------------------------

DATA_EEPROM_READ

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        movwf   EEADR               ; move EEPROM address in W to EEADR
        bsf     EECON1, RD          ; initiate EEPROM read
        movf    EEDATA, W           ; move data to W

        bcf     STATUS, RP0         ; ---- Select Bank 0 -----

        return


;----------------------------------------------------------------------
; Subroutine: DATA_EEPROM_WRITE
;
; Description: To write an EEPROM data memory location, the address is
;   written to the EEADR register, data to the EEDATA register, then
;   execute a required sequence of instructions.
;   
; CAUTION: Interrupts are disable and then re-enabled during this 
;          subroutine
;
; Constants: none
;   
; Global Variables: none
;   
; Initialization: Address = EEADR, Data = EEDATA
;   
; Output: none
;
;----------------------------------------------------------------------

DATA_EEPROM_WRITE

        bsf     STATUS, RP0         ; ---- Select Bank 1 -----

        bsf     EECON1, WREN        ; EEPROM Write Enable: allow write cycles
;        bcf     INTCON, GIE         ; disable global interrupts
                                    ; *** required sequence, do not alter ***
        movlw   0x55
        movwf   EECON2
        movlw   0xAA
        movwf   EECON2
        bsf     EECON1, WR          ; initiate EEPROM write
                                    ; *** end required sequence ***

        btfsc   EECON1, WR          ; has write completed?
        goto    $-1

;        bsf     INTCON, GIE         ; enable global interrupts
        bcf     EECON1, WREN        ; EEPROM Write Enable: inhibit write cycles

        bcf     STATUS, RP0         ; ---- Select Bank 0 -----

        return


;----------------------------------------------------------------------
; Subroutine: READ_ANALOG_AN0
;
; Description: Read analog channel 0 (AN0).
;   
; Constants: none
;   
; Global Variables: none
;   
; Initialization: none
;   
; Output: ADRESH and ADRESL contain 10-bit A/D result justified 
;   according to ADCON0, ADFM bit.
;
;----------------------------------------------------------------------

READ_ANALOG_AN0

        bsf     ADCON0, ADON        ; Turn on ADC module

        bcf     ADCON0, CHS1        ; select analog channel AN0
        bcf     ADCON0, CHS0

        ; After selecting a new channel, allow for sufficent sample time.
        ; The amount of sample time depends on the charging time of the
        ; internal charge holding capacitor (Section 7.2).

        movlw   D'6'                ; At 4 MHz, a 22 us delay
        movwf   TEMP                ; (22us = 2us + 6 * 3us + 1us)
        decfsz  TEMP, F
        goto    $-1

        bsf     ADCON0, GO          ; start A/D conversion

        btfsc   ADCON0, GO          ; has A/D conversion completed?
        goto    $-1

        bcf     ADCON0, ADON        ; Turn off ADC module (consumes no operating current)

        return


;----------------------------------------------------------------------
; Subroutine: DISPLAY
;   
; Description: Displays Value Stored In LEDREG On LED Array
;   1 LED is displayed during each call
;   D7..D4 LED'S show most significant nibble
;   D3..D0  LED'S show least significant nibble
;
; Constants: 
;   
; Global Variables: LEDREG, LEDDISP, LEDSTATE
;   
; Initialization: 
;   
; Output: 
;   
;----------------------------------------------------------------------

DISPLAY
        clrf    PORTA               ; turn off all LED's

        bcf     STATUS, C           ; clear the carry bit
        rlf     LEDDISP, F          ; rotate left the LED displayed bit
        btfsc   STATUS, C           ; was the bit rotated into carry?
         rlf    LEDDISP, F          ;  yes, put it back into bit 0

        incf    LEDSTATE, F         ;  no, increment LED State

        movfw   LEDREG              ; get LED Register, should the LED be lit?
        andwf   LEDDISP, W
        btfsc   STATUS, Z
         return                     ; bit was a zero, do not light and return

        movfw   LEDSTATE            ; Mask bits (should be only 8 states)
        andlw   B'00000111'

        addwf   PCL, F

        goto    LITELED0
        goto    LITELED1
        goto    LITELED2
        goto    LITELED3
        goto    LITELED4
        goto    LITELED5
        goto    LITELED6
        goto    LITELED7
	
LITELED0
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED0TRIS
        movwf   TRISA
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED0ON
        movwf   PORTA
        return
	
LITELED1
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED1TRIS
        movwf   TRISA
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED1ON
        movwf   PORTA
        return

LITELED2
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED2TRIS
        movwf   TRISA
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED2ON
        movwf   PORTA
        return
	
LITELED3
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED3TRIS
        movwf   TRISA	
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED3ON
        movwf   PORTA
        return
	
LITELED4
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED4TRIS
        movwf   TRISA				
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED4ON
        movwf   PORTA
        return

LITELED5
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED5TRIS
        movwf   TRISA			
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED5ON
        movwf   PORTA
        return

LITELED6
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED6TRIS
        movwf   TRISA		
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED6ON
        movwf   PORTA
        return

LITELED7
        bsf     STATUS, RP0         ; ---- Select Bank 1 -----
        movlw   LED7TRIS
        movwf   TRISA
        bcf     STATUS, RP0         ; ---- Select Bank 0 -----
        movlw   LED7ON
        movwf   PORTA
        return


;----------------------------------------------------------------------
; Subroutine: CMD_TC72_CTC 
;   
; Description: Command the TC72 into Continuous Temperature Conversion (CTC)
;   mode. 
;   
; Constants: 
;   None
;   
; Global Variables: 
;   BIT_CNTR = Bit counter
;   TC72_ADX = TC72 Address
;   TC72_CTRL = TC72 Control Register
;   
; Initialization: 
;   None
;   
; Output: 
;   None
;   
;----------------------------------------------------------------------

CMD_TC72_CTC

        movlw   D'16'               ; set bit counter to 16
        movwf   BIT_CNTR

        bcf     SCK                 ; set SCK low
        bsf     TC72_CE             ; enable TC72 --> chip select high

        ; Send address byte 0x80 to TC72 (write) followed by
        ; continuous temperature conversion command.

        movlw   0x80                ; address byte 0x80 (write)
        movwf   TC72_ADX

        movlw   b'00000100'         ; load continuous temp. conv. command
        movwf   TC72_CTRL

        bcf     STATUS, C           ; clear Carry bit prior to rotate left

CMD_TC72_CTC_LOOP

        rlf     TC72_CTRL, F        ; rotate left into Carry bit
        rlf     TC72_ADX, F

        btfsc   STATUS, C           ; if Carry bit is set
         bsf     SDO                ;  SDO --> high
        btfss   STATUS, C           ; if Carry bit is clear
         bcf     SDO                ;  SDO --> low

        bsf     SCK                 ; SCK rising edge (shift edge)
        bcf     SCK                 ; SCK falling edge (clock edge)

        decfsz  BIT_CNTR, F         ; all 16 bits sent?
         goto   CMD_TC72_CTC_LOOP

        bcf     TC72_CE             ; disable TC77 --> chip select low

        return


;----------------------------------------------------------------------
; Subroutine: READ_TC72_TEMP
;   
; Description: Read temperature and control register from the TC72
;   
; Constants: 
;   None
;   
; Global Variables: 
;   BIT_CNTR = Bit counter
;   TC72_ADX = TC72 Address
;   TC72_MSB = TC72 MSB Temperature
;   TC72_LSB = TC72 LSB Temperature
;   TC72_CTRL = TC72 Control Register
;   
; Initialization: 
;   None
;   
; Output: 
;   TC72_MSB and TC72_LSB contain the 10-bit Temperature value
;   
;----------------------------------------------------------------------

READ_TC72_TEMP

        movlw   D'8'                ; set bit counter to 8
        movwf   BIT_CNTR

        bcf     SCK                 ; set SCK low
        bsf     TC72_CE             ; enable TC72 --> chip select high

        ; send address byte 0x02 to TC72 (MSB Temp)

        movlw   0x02                ; address byte 0x02 (MSB Temperature)
        movwf   TC72_ADX

READ_TC72_TEMP_LOOP_1

        rlf     TC72_ADX, F         ; rotate left into Carry bit

        btfsc   STATUS, C           ; if Carry bit is set
         bsf     SDO                ;  SDO --> high
        btfss   STATUS, C           ; if Carry bit is clear
         bcf     SDO                ;  SDO --> low

        bsf     SCK                 ; SCK rising edge (shift edge)
        bcf     SCK                 ; SCK falling edge (clock edge)

        decfsz  BIT_CNTR, F         ; all 8 bits sent?
         goto   READ_TC72_TEMP_LOOP_1

        ; read 24 bits from TC72 (MSB Temperature, LSB Temperature, Control Register)

        movlw   D'24'               ; set bit counter to 24
        movwf   BIT_CNTR

READ_TC72_TEMP_LOOP

        bsf     SCK                 ; SCK rising edge

        btfsc   SDI                 ; read bit, if bit is set
         bsf     STATUS, C          ;  set carry bit
        btfss   SDI                 ; if bit is clear
         bcf     STATUS, C          ;  clear carry bit

        bcf     SCK                 ; set SCK low

        rlf     TC72_CTRL, F        ; rotate carry bit left
        rlf     TC72_LSB, F
        rlf     TC72_MSB, F

        decfsz  BIT_CNTR, F         ; is reading the Temperature Register complete?
         goto   READ_TC72_TEMP_LOOP

        bcf     TC72_CE             ; disable TC77 --> chip select low

        return


;----------------------------------------------------------------------
;----------------------------------------------------------------------
; Main Program
;----------------------------------------------------------------------
;----------------------------------------------------------------------

MAIN

;----------------------------------------
; Initialize PICmicro
;----------------------------------------

        call    INITIALIZE

;----------------------------------------
; Initialize Variables
;----------------------------------------

        bcf     FLAG, TRIP          ; clear tick counter trip flag.

        bcf     TC72_CE             ; disable TC72 --> chip select low

        clrf    LEDREG              ; initialize the LED display routine
        clrf    LEDSTATE
        movlw   D'1'
        movwf   LEDDISP


        call    CMD_TC72_CTC        ; command the TC72 into Continuous
                                    ; Temperature Conversion mode

        bsf     INTCON, GIE         ; enable global interrupts

MAINLOOP

; tick counter expired?

        btfss   FLAG, TRIP
         goto   MAINLOOP            ; no, loop
        bcf     FLAG, TRIP          ; clear tick counter trip flag.

; read temperature from TC72

        bcf     INTCON, GIE         ; disable global interrupts
        call    READ_TC72_TEMP
        bsf     INTCON, GIE         ; enable global interrupts

; right adjust 10-bit 2's complement temperature value into TC72_MSB:TC72_LSB

        ; rotate right 6 bits

        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F
        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F
        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F
        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F
        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F
        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F

; if temperature is negative, save the sign bit and complement

        btfsc   TC72_MSB, 1
         bsf     FLAG, SIGN_BIT
        btfss   TC72_MSB, 1
         bcf     FLAG, SIGN_BIT

        btfss   FLAG, SIGN_BIT
         goto   ML00                ; temperature is positive, jump ahead

        bsf     TC72_MSB, 7          ; sign extend bits 15:13 in TEMP_HI
        bsf     TC72_MSB, 6
        bsf     TC72_MSB, 5
        bsf     TC72_MSB, 4
        bsf     TC72_MSB, 3
        bsf     TC72_MSB, 2

        comf    TC72_MSB, F         ; 2's complement
        comf    TC72_LSB, F
        incf    TC72_LSB, F
        btfsc   STATUS, C
        incf    TC72_MSB, F

; display temperature in F (no push button press) or C (push button pressed)
ML00
        btfss   SW1                 ; is push button SW1 pressed?
         goto   ML20                ;  no, jump ahead

; to convert C to F:
; multiply temperature by 9

        movfw   TC72_MSB            ; move TC72_MSB:TC72_LSB to TEMP_MSB:TEMP_LSB
        movwf   TEMP_MSB            ; (save original temperature in TC72_MSB:TC72_LSB)
        movfw   TC72_LSB
        movwf   TEMP_LSB

        ; left shift 3 (multiply by 8)

        bcf     STATUS, C           ; clear carry bit
        rlf     TEMP_LSB, F         ; rotate left TEMP_MSB:TEMP_LSB 3 bits
        rlf     TEMP_MSB, F
        bcf     STATUS, C           ; clear carry bit
        rlf     TEMP_LSB, F
        rlf     TEMP_MSB, F
        bcf     STATUS, C           ; clear carry bit
        rlf     TEMP_LSB, F
        rlf     TEMP_MSB, F

        ; add TC72_MSB:TC72_LSB (multiply by 9)

        movfw   TC72_LSB
        addwf   TEMP_LSB, F

        btfsc   STATUS, C
         incf   TEMP_MSB, F

        movfw   TC72_MSB
        addwf   TEMP_MSB, F         ; result is in TEMP_MSB:TEMP_LSB

; divide results by 5

        clrf    TC72_MSB
        clrf    TC72_LSB
ML05
        movlw   D'5'                ; subtract 5 from TEMP_LSB
        subwf   TEMP_LSB, F

        btfsc   STATUS, C           ; was there a borrow?
         goto   ML10                ;  no, jump ahead
        movlw   D'1'
        subwf   TEMP_MSB, F         ;  yes, borrow from TEMP_MSB
        btfss   STATUS, C           ; was there a borrow from TEMP_MSB?
         goto   ML15                ;  yes, we are done, jump ahead
ML10
        movlw   D'1'
        addwf   TC72_LSB, F         ;  no, increment TC72_MSB:TC72_LSB
        btfsc   STATUS, C
         incf   TC72_MSB, F

        goto    ML05                ; do it again

; add 32

ML15
        movlw   0x80
        addwf   TC72_LSB, F         ; result is in TC72_MSB:TC72_LSB
        btfsc   STATUS, C
         incf   TC72_MSB, F

; end C to F conversion

; round result to integer value

ML20

        ; rotate right 1

        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F         ; rotate right TC77_HI:TC77_LO 3 bits
        rrf     TC72_LSB, F

        ; round

        movlw   D'1'
        addwf   TC72_LSB, F
        btfsc   STATUS, C
         incf   TC72_MSB, F

        ; rotate right 1

        bcf     STATUS, C           ; clear carry bit
        rrf     TC72_MSB, F
        rrf     TC72_LSB, F

;----------------------------------------

; convert into Binary Coded Decimal (BCD) format

        clrf    BCD_H               ; clear the BCD registers
        clrf    BCD_T
        clrf    BCD_O

        ; hundreds digit
ML25
        movlw   D'100'
        subwf   TC72_LSB, W         ; subtract 100 (result goes into W)

        btfss   STATUS, C           ; was result negative?
         goto   ML30

        incf    BCD_H, F            ; no, increment BCD_H register
        movwf   TC72_LSB            ; save result
        goto    ML25                ; do it again
ML30
        movlw   D'10'               ; subtract 10 (result goes into W)
        subwf   TC72_LSB, W

        btfss   STATUS, C           ; was result negative?
         goto   ML35

        incf    BCD_T, F            ; no, increment BCD_T register
        movwf   TC72_LSB            ; save result
        goto    ML30                ; do it again
ML35
        movfw   TC72_LSB
        movwf   BCD_O               ; save result as BCD_O

; display on PICkit 1 FLASH Starter Kit LED's D7:D0

        movfw   BCD_O               ; move BCD Ones to TEMP
        movwf   TEMP

        swapf   BCD_T, W            ; swap BCD Tens nibbles
        iorwf   TEMP, W             ; inclusive or and store in TEMP

        movwf   LEDREG

        goto    MAINLOOP


;----------------------------------------------------------------------
; Data EEPROM Memory (Section 8.0)
;
; PIC12F630/676 devices have 128 bytes of data EEPROM with address
; range 0x00 to 0x7F.

        ; Initialize Data EEPROM Memory locations

;        ORG     0x2100
;        DE      0x00, 0x01, 0x02, 0x03


;----------------------------------------------------------------------
; Calibrating the Internal Oscillator (Section 9.2.5.1)
; Oscillator Calibration Register (OSCCAL) (Section 2.2.2.7)
;
; The below statements are placed here so that the program can be
; simulated with MPLAB SIM or emulated with the ICD2 or ICE-2000.  
;
; The programmer (PICkit or PROMATE II) will save the actual OSCCAL 
; value in the device and restore it. The value below WILL NOT be
; programmed into the device.

        org     0x3ff
        retlw   0x80                ; Center Frequency


;----------------------------------------------------------------------
        end                         ; end of program directive
;----------------------------------------------------------------------
