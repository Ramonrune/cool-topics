'****************************************************************
'*  Notes   : 1-Wire Identifier                                 *
'*          ; Identifies & Displays 1-Wire Device Information   *
'****************************************************************
DECLARE RSOUT_MODE 0        ' 
DECLARE RSOUT_PIN PORTA.0   ' Defines display serial port output pin
DECLARE SERIAL_BAUD 9600    ' Default baud rate = 9600
XTAL = 4                    ' Clock is set to 4MHz

symbol DQ = PORTB.7         ' One-wire data pin "DQ" on PortC.7
dim SN[8] as byte       

Begin:
    delayms 500             ' Wait for 500 ms to initialize display
    Rsout cls 
    
Do_again:
    OWrite DQ, 1, [$33]     ' Issue a READ ROM command [33H]

' Retrieves the ROM code of the device
'
    ORead DQ, 0, [STR SN\8] ' Read 64-bit device data into the 8-byte array "SN"
    Rsout at 1, 1, "Family Code = ",HEX2 SN[0],"h"
    Rsout at 2, 1, "Ser# = ",HEX2 SN[1],HEX2 SN[2],HEX2 SN[3],HEX2 SN[4],HEX2 SN[5],HEX2 SN[6],"h"
    Rsout at 3, 1, "CRC Value = ",HEX2 SN[7],"h"

'Identifies the device
'
    IF SN[0] = $5 Then
       Rsout at 4, 1, "Device = Switch     "
    EndIF

    IF SN[0] = $28 OR SN[0] = $22 Then
       Rsout at 4, 1, "Device = Temp Sensor"
    EndIF

    IF SN[0] = $01 Then
       Rsout at 4, 1, "Device = Serial #   "
    EndIF
    delayms 10000          ' wait for 10-second
    GoTo Do_again 
    End
