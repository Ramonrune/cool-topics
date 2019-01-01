DEVICE  16F628A
DECLARE RSOUT_MODE 0
DECLARE RSOUT_PIN PORTA.0 
DECLARE SERIAL_BAUD 9600    ' Default baud rate = 9600
XTAL = 4 

symbol DQ = PORTB.7         ' One-wire data pin "DQ" on PortC.7
Dim Stat  as bit            ' Busy or not bit

Begin:
    delayms 300             ' Wait .3 seconds
   
    Rsout cls, "DS2405 NETWORK TEST" ' Clear LCD on power-up

Switch_1:
    OWrite DQ, 1, [$55,$05,$C5,$C3,$08,$00,$00,$00,$CD]
    Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
	IF Stat = 0 THEN
        rsout at 2, 1 , "Switch #1 = OFF"
    ELSE
        rsout at 2, 1 , "Switch #1 = ON "
    ENDIF

    delayms 500
    
Switch_2:
    OWrite DQ, 1, [$55,$05,$B3,$BF,$08,$00,$00,$00,$AB]
    Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
    IF Stat = 0 THEN
        rsout at 3, 1 , "Switch #2 = OFF"
    ELSE
        rsout at 3, 1 , "Switch #2 = ON "
    ENDIF

    delayms 500

Switch_3:
    OWrite DQ, 1, [$55,$05,$B4,$BF,$08,$00,$00,$00,$2E]
    Oread DQ, 4, [Stat]     ' Check switch status ON/OFF
    IF Stat = 0 THEN
        rsout at 4, 1 , "Switch #3 = OFF"
    ELSE
        rsout at 4, 1 , "Switch #3 = ON "
    ENDIF

    delayms 500
    
    Goto Switch_1
    END

