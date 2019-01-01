'-----------------------------------------------------------------------------
' 
' Sample program clock and temperature guage
'
'
'
'
'
'
'
'
'		(C)2002, Advanced Digital Technologies
'                                                                                                                                                                                                      
'=============================================================================
'
'
SYMBOL	ticks	= B0
SYMBOL	count	= B1
SYMBOL	hours	= B2
SYMBOL	minutes	= B3
SYMBOL	seconds	= B4
SYMBOL	temp	= B5
SYMBOL	prnPos	= B6
SYMBOL	data	= B7
SYMBOL	clocks	= B8
SYMBOL	last	= B9
SYMBOL	I		= 254
SYMBOL	L2		= 192
SYMBOL	clr		= 1
SYMBOL	LCD		= 7
SYMBOL	CLK		= 2
SYMBOL	setRun	= PIN0
SYMBOL	incMin	= PIN1
SYMBOL	incHrs	= PIN2
SYMBOL	clkIn	= PIN3
SYMBOL	set		= 0
SYMBOL	hold 	= 1
SYMBOL	run		= 1
SYMBOL	timePos	= 135


'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================
Begin:
	LET			DIRS = $F0
	PAUSE		200
	
	SEROUT		LCD,N2400,(I,clr)
	SEROUT		LCD,N2400,("Time:")


'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================	
doTiming:	
	IF setRun = set THEN setClock
	IF clkIn = BIT0 THEN doTiming
'	LET			last = clkIn
	LET			ticks = ticks + 1 & %11
	IF ticks <> 3 THEN doTiming
	GOSUB		incTime
	GOSUB		showTime
	GOTO		doTiming
	
	
'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================	
setClock:
	IF setRun = run THEN doTiming
	LET			seconds = 0
	IF incMin = hold THEN ckHours
	GOSUB		incMinutes
	GOTO		setDone

ckHours:
	IF incHrs = hold THEN setClock
	GOSUB		incHours
	
setDone:
	GOSUB		showTime
	PAUSE		200
	GOTO		setClock
	
					
'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================	
showTime:
	SEROUT		LCD,N2400,(I,timepos)
	LET			count = hours
	GOSUB		showDigs
	SEROUT		LCD,N2400,(":")
	LET			count = minutes
	GOSUB		showDigs
	SEROUT		LCD,N2400,(":")
	LET			count = seconds
	GOSUB		showDigs
	RETURN
	
		
'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================	
showDigs:
	LET			temp = count / 10
	SEROUT		LCD,N2400,(#temp)
	LET			temp = count // 10
	SEROUT		LCD,N2400,(#temp)
	RETURN
	
	
'-----------------------------------------------------------------------------
' 
'                                                                                                                                                                                                      
'=============================================================================	
incTime:
	LET			seconds = seconds + 1
	IF seconds < 60 THEN done
	LET			seconds = 0
incMinutes:
	LET			minutes = minutes + 1
	IF minutes < 60 THEN done
	LET			minutes = 0
incHours:
	LET			hours = hours + 1
	IF hours < 13 THEN done
	LET			hours = 1
done:
	RETURN
				


			