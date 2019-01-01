;************************************************************************
;*	Microchip Technology Inc. 2007										*
;*	Assembler version: x.x											*
;*	Filename: 															*
;*		lcd.asm (main routine)   										*
;*	Dependents:															*
;*		Main.asm														*
;*		Math.asm														*
;*	October 5 ,2007														*
;* PICDEM HPC Explorer DEMO code. The following functions are included 	*
;*	with this code:														*
;*		1. Voltmeter													*
;*			The center tap of R3 is connected to RA0, the				*
;*			A/D converter converts this analog voltage and				*
;*			the result is displayed on the LCD in a range				*
;*			from 0.00V - 5.00V.											*
;*		2. Temperature													*
;*			The MCP9701A Analog  Thermal Sensor is used to    			*
;*			measure ambient temperature. 								*								*
;*		3. Clock														*
;*			This function is a real-time clock. When the				*
;*			mode is entered, time begins at 00:00:00. The 				*
;*			user can set the time if desired.							*
;************************************************************************
#ifdef __18F8722
	list p=18F8722
	#include p18F8722.inc
#endif
#ifdef __18F87J11
	list p=18F87J11
	#include p18F87J11.inc
#endif


#define	LCD_E			temp_reg, 6	; LCD E clock
#define	LCD_RS			temp_reg, 7	; LCD register select line

#define	LCD_CS			LATA,2	    ; LCD chip select
#define	LCD_CS_TRIS		TRISA,2	    ; LCD chip select
#define	LCD_RST			LATF,6	    ; LCD chip select
#define	LCD_RST_TRIS	TRISF,6	    ; LCD chip select

D_LCD_DATA	UDATA_ACS
delay		res	1
temp_wr		res	1
temp_rd		res	1
Dreg1 		res 1
Dreg2 		res 1
temp_reg 	res 1
                                                
	GLOBAL	temp_wr
PROG1	CODE
;---------------------------------------------------------------
;LCD Initialization routine
;---------------------------------------------------------------
	global LCDInit
LCDInit	
	bcf 	LCD_CS_TRIS
	bsf		LCD_CS
	clrf	temp_reg
	call	Delay
	call	Delay
	call	Delay

	bcf		LCD_RST_TRIS
	bcf		LCD_RST
	call	Delay
	bsf		LCD_RST

	call	InitSPI
	call 	InitPortA_SPI
	call	InitPortB_SPI


	bcf		LCD_E			
	bcf		LCD_RS	
	call	WritePortA

;	call	Delay
;	movlw	b'00110000'
;	movwf	temp_wr
;	call	InitWrite
;
;	call	Delay
;	movlw	b'00110000'
;	movwf	temp_wr
;	call	InitWrite
;
;	call	Delay
;	movlw	b'00110000'
;	movwf	temp_wr
;	call	InitWrite

;Function Set
	call	Delay
	movlw	b'00111100' ;0011NFxx
	movwf	temp_wr
	call	InitWrite


	call	Delay
	movlw	b'00001100' ;Display off
	movwf	temp_wr
	call	InitWrite


	call	Delay
	movlw	b'00000001' ;Display Clear
	movwf	temp_wr
	call	InitWrite


	call	Delay
	movlw	b'00000110' ;Entry mode
	movwf	temp_wr
	call	InitWrite

	return
;-------------------------------------------------------------
;Function to write to the PORT 
;-------------------------------------------------------------
InitWrite
	bcf		LCD_E		
	bcf		LCD_RS	
	call	WritePortA
	call	WritePortB
	nop
	nop
	nop

	bsf		LCD_E
	call	WritePortA	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		LCD_E
	call	WritePortA
	return





;---------------------------------------------------
;LCD busy delay
;---------------------------------------------------
	global LCDBusy
LCDBusy
	call	SDelay
	call	SDelay
	return

	global ClearLCD
ClearLCD
	movlw	0x01
	movwf	temp_wr
	rcall	i_write
	return


;---------------------------------------------------
;Write to Line1
;---------------------------------------------------
	global	LCDLine_1	
LCDLine_1
	movlw	0x80
	movwf	temp_wr
	rcall	i_write
	return
;---------------------------------------------------
;Write to Line2
;---------------------------------------------------
	global LCDLine_2
LCDLine_2
	movlw	0xC0
	movwf	temp_wr
	rcall	i_write
	return
;---------------------------------------------------
;Write data
;---------------------------------------------------
	global d_write
d_write
	rcall	LCDBusy
	bcf		LCD_E				
	bsf		LCD_RS
	call	WritePortA
	call	WritePortB
	nop
	nop
	nop
	nop
	bsf		LCD_E
	call	WritePortA	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		LCD_E		
	call	WritePortA      ;      
	bcf		LCD_RS
	call	WritePortA

	movf	temp_wr,w
	movwf	TXREG			;carriage return
	btfss	TXSTA,TRMT		;wait for data TX
	bra	$-2
	return
;---------------------------------------------------
;Write instrution
;---------------------------------------------------
	global i_write
i_write
	bcf		LCD_E				
	bcf		LCD_RS
	call	WritePortA	

	rcall	LCDBusy
	call	WritePortB
	nop
	nop
	nop
	nop
	bsf		LCD_E
	call	WritePortA	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		LCD_E
	bcf		LCD_RS
	call	WritePortA
	return



;---------------------------------------------------
;Initialize MCP923S17 Port
;---------------------------------------------------
InitPortA_SPI

	bcf		LCD_CS
	movlw	0x40
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	call	Check
	bsf		LCD_CS
	return
;---------------------------------------------------
;Initialize MCP923S17 Port
;---------------------------------------------------
InitPortB_SPI
	bcf		LCD_CS
	movlw	0x40
	movwf	SSPBUF
	call	Check
	movlw	0x01
	movwf	SSPBUF
	call	Check
	movlw	0x00
	movwf	SSPBUF
	call	Check
	bsf		LCD_CS
	return

;---------------------------------------------------
;Initialize SPI 
;---------------------------------------------------
    global InitSPI
InitSPI
	bcf		TRISC,5
	bcf		TRISC,3
	movlw	0x22
	movwf	SSP1CON1
	bsf		SSP1STAT,CKE
	bcf		PIR1,SSPIF
	return

    global Check
Check
	btfss	PIR1,SSPIF
	goto	$-2	
	bcf		PIR1,SSPIF
	movf	SSPBUF,w
	return

;---------------------------------------------------
;Write to  MCP923S17 Port
;---------------------------------------------------
WritePortB
	bcf		LCD_CS
	movlw	0x40
	movwf	SSPBUF
	call	Check
	movlw	0x13
	movwf	SSPBUF
	call	Check



	movf	temp_wr,w	
;	movlw	0xFF
	movwf	SSPBUF
	call	Check		

	bsf		LCD_CS

	return

;---------------------------------------------------
;Write to  MCP923S17 Port
;---------------------------------------------------
WritePortA
	bcf		LCD_CS
	movlw	0x40
	movwf	SSPBUF
	call	Check
	movlw	0x12
	movwf	SSPBUF
	call	Check
;	movlw	0x80
;	movlw	0x40
;	movlw	0xc0
	movf	temp_reg,w
	movwf	SSPBUF
	call	Check		

	bsf		LCD_CS
	return




	GLOBAL Delay
Delay
	nop
	nop
	nop
	nop
	decfsz	Dreg1
	goto Delay
	decfsz	Dreg2
	goto Delay
	return

SDelay
	decfsz	Dreg1
	goto SDelay
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2
	decfsz	Dreg1
	goto	$-2

	return

		goto	$



	END
