' Experimental software to reproduce the classic Space Invaders game
' For version 2.1 of the PROTON+ BASIC Compiler
' Written by Les Johnson 2003.
'
' This version uses the LCDWRITE and PLOT commands to produce the graphics
' Which allows smooth movements on a pixel by pixel basis
'
' Use an 8MHz crystal
'
' BUTTON CONNECTIONS
' LEFT Button connects to PORTB.0
' RIGHT Button connects to PORTB.1
' FIRE Button connects to PORTB.2
'
' SOUND CHANNEL CONNECTIONS
' Each channel is output from PORTA.0,1,2
' Channel 1. PORTA.0 is the INVADER noise
' Channel 2. PORTA.1 is the MISSILE noise 
' Channel 3. PORTA.2 is the SAUCER noise  
' Each pin should have a current limiting resistor in order to stop pin to pin shorts.
'             
'                      1uF
'			  220	  +| |-
'  PORTA.0 --/\/\/\----| |--- To SPEAKER
'                    | | |
'             330    |
'  PORTA.1 --/\/\/\--| 
'                    |
'             330    |
'  PORTA.2 --/\/\/\--|
' 
'

		Include "PROTON18_G8.INT"								' Game created on the PROTON board
        
' Set up some Variables
        
' Interrupt driven sound channel variables
        Dim NOTE_STATUS as Byte SYSTEM
        Dim INVADER_SOUND_ENABLE as NOTE_STATUS.0
        Dim MISSILE_SOUND_ENABLE as NOTE_STATUS.1
        Dim SAUCER_SOUND_ENABLE as NOTE_STATUS.2
        Dim INTERNAL_INVADER_SOUND_ENABLE as NOTE_STATUS.4
        
        Dim INTERRUPT_COUNTER1 as Byte SYSTEM
        Dim INVADER_SOUND_COUNTER as Byte SYSTEM                   
		Dim INVADER_FREQ as Byte SYSTEM   
        Dim INVADER_SOUND_DURATION as Byte SYSTEM
        Dim INVADER_SOUND_DURATION_COUNTER as Byte SYSTEM 
                    
        Dim MISSILE_SOUND_COUNTER as Byte SYSTEM                  
		Dim MISSILE_FREQ as Byte SYSTEM
		Dim SAUCER_SOUND_COUNTER as Byte SYSTEM                   
		Dim SAUCER_FREQ as Byte SYSTEM
        
' Space invader variables		
                
        Dim BASE_ENABLED[9] 	as Byte						' Whether or not the section of the BASE is enabled
        Dim BASE_HITS[9] 		as Byte						' Holds the amount of hits each part of the bases has had
        Dim INVADER_XPOS[18] 	as Byte'	at 400				' Array to hold the space invader's X position
        Dim INVADER_YPOS[18] 	as Byte'	at 418				' Array to hold the space invader's Y position
        Dim INVADER_ENABLED[18] as Byte' at 436				' Array to hold the space invader' config. i.e. hit or active
        
        Dim SHIP_XPOS			as	Byte					' X position of BASE ship
        Dim	MISSILE_YPOS		as	Byte					' Y position of Ship's MISSILE
        Dim MISSILE_XPOS		as 	Byte					' X position of Ship's MISSILE
        Dim MISSILE_STATUS		as  Byte SYSTEM
        Dim MISSILE_FIRED		as 	MISSILE_STATUS.0		' TRUE if Ship's MISSILE in the air
        Dim MISSILE_HIT			as  MISSILE_STATUS.1		' Set if Ship's missile has hit something
        Dim TIME_TO_MOVE_INVADERS as MISSILE_STATUS.7		' Indicate time to move the invaders       
        Dim BASE_HIT 			as MISSILE_STATUS.2			' Indicates whether a BASE has been hit by a missile
        Dim TIME_TO_MOVE_SHIP_MISSILE as MISSILE_STATUS.3	' Indicate time to move the ship's missile
        Dim TIME_TO_MOVE_BASE 	as Bit
        Dim SHIP_SPEED			as Byte
        Dim INVADER_TICK 		as Byte						' Constant tick within program
        Dim INVADER_LOOP 		as Byte SYSTEM				' Scans the invader arrays
        Dim INVADER_MISSILE_TICK as Byte
        Dim SHIP_MISSILE_TICK 	as Byte
        Dim TEMP_LOOP 			as Byte
        Dim INVADERS_DIRECTION 	as Bit
        Dim INVADERS_ENABLED 	as Byte						' Count the INVADERS enabled
        Dim INVADER_SPEED 		as Byte						' The speed of the invaders
        Dim BASE_XPOS_TEST		as Byte						' Used for detecting a missile hit on a BASE
        Dim SHIP_HIT 			as Bit						' TRUE if ship hit by missile
        
        Dim	INVADER_MISSILE_YPOS	as	Byte				' Y position of Invader's MISSILE
        Dim INVADER_MISSILE_XPOS	as 	Byte				' X position of Invader's MISSILE
        Dim TIME_TO_MOVE_INV_MISSILE 	as MISSILE_STATUS.4	' Indicate time to move the invader's missile
        Dim INVADER_MISSILE_FIRED	as 	MISSILE_STATUS.5	' TRUE if Invader's MISSILE in the air
        Dim INVADER_MISSILE_HIT		as  MISSILE_STATUS.6	' Set if Invader's missile has hit something
        Dim TIME_TO_MOVE_INVADERS_DOWN as Bit				' Signal that the invaders need to move down
        Dim INVADERS_REACHED_BOTTOM as Bit					' Set if the invaders reach the botton of the screen
        Dim INVADER_MISSILE_SPEED 	as Byte					' The speed of the invader's missile. This slows down as invader near the bottom of the screen
        Dim DEFAULT_INVADER_SPEED 	as Byte					' Saves the initial speed of the invaders
        Dim INVADER_CHARACTER 		as Bit					' Determines the character to use for the invader
        
        Dim INVADER_MISSILE2_TICK 	as Byte
        Dim	INVADER_MISSILE2_YPOS	as	Byte				' Y position of Invader's second MISSILE
        Dim INVADER_MISSILE2_XPOS	as 	Byte				' X position of Invader's second MISSILE
        Dim TIME_TO_MOVE_INV_MISSILE2 	as Bit				' Indicate time to move the invader's second missile
        Dim INVADER_MISSILE2_FIRED	as 	Bit					' TRUE if Invader's second MISSILE in the air
        Dim INVADER_MISSILE2_HIT	as  Bit					' Set if Invader's second missile has hit something
        Dim INVADER_MISSILE2_SPEED 	as Byte					' The speed of the invader's second missile. This slows down as invader near the bottom of the screen

        
        Dim SAUCER_XPOS 			as Byte
        Dim SAUCER_HIT 				as Bit
        Dim TIME_TO_MOVE_SAUCER 	as Bit
        Dim SAUCER_SPEED 			as Byte
        Dim SAUCER_ENABLED 			as Bit
        Dim SCORE 					as Dword				' Holds the games score
 		Dim LEVEL 					as Word					' Game level
        Dim LIVES 					as Byte					' Amount of lives left for the base
        
' Define some constants and alias's       
        Symbol L_BUTTON = PORTB.0
        Symbol R_BUTTON = PORTB.1
		Symbol FIRE_BUTTON = PORTB.2
        Symbol SPEAKER = PORTB.3
        
        Symbol SHIP_WIDTH = 9								' The width of the ship in pixels. This does not include the two blanks
        Symbol INVADER_WIDTH = 10							' The width of the invaders. minus the two outside blanks 
        Symbol INVADER_RIGHT_LIMIT = 127 - INVADER_WIDTH	' The right most limit for the invaders before they need to move down
        Symbol SAUCER_WIDTH = 14
        
        Symbol TRUE = 1
        Symbol FALSE = 0
        Symbol FORWARD = 1
        Symbol BACKWARD = 0
 		
        Symbol T0IF = INTCON.2								' Timer0 Overflow Interrupt Flag
		Symbol GIE = INTCON.7								' Global Interrupt Enable
        
        'ON_INTERRUPT Goto NOTE_INT
        
'----------------------------------------------------------------------------
        Input L_BUTTON
        Input R_BUTTON
		Input FIRE_BUTTON
        Delayms	200											' Wait for the PICmicro to stabilise
        PORTB_PULLUPS = ON
        Cls													' Clear the LCD
        Goto MAIN_PROGRAM_LOOP								' Jump over any subroutines

'----------------------------------------------------------------------------
' Draw or clear the Invader's missile
CLEAR_INVADER_MISSILE:
		UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS
        UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS + 1
        UnPlot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS
        UnPlot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS + 1
        UnPlot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS
        UnPlot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS + 1
        Return
DRAW_INVADER_MISSILE:
		UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS
        UnPlot INVADER_MISSILE_YPOS, INVADER_MISSILE_XPOS + 1
        Plot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS
        Plot INVADER_MISSILE_YPOS + 1, INVADER_MISSILE_XPOS + 1
        Plot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS
        Plot INVADER_MISSILE_YPOS + 2, INVADER_MISSILE_XPOS + 1
        Return 
        
'----------------------------------------------------------------------------
' Draw or clear the second Invader's missile
CLEAR_INVADER_MISSILE2:
		UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS
        UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS + 1
        UnPlot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS
        UnPlot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS + 1
        UnPlot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS
        UnPlot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS + 1
        Return
DRAW_INVADER_MISSILE2:
		UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS
        UnPlot INVADER_MISSILE2_YPOS, INVADER_MISSILE2_XPOS + 1
        Plot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS
        Plot INVADER_MISSILE2_YPOS + 1, INVADER_MISSILE2_XPOS + 1
        Plot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS
        Plot INVADER_MISSILE2_YPOS + 2, INVADER_MISSILE2_XPOS + 1
        Return 
'----------------------------------------------------------------------------
' Re-Draw the bases
UPDATE_BASES:
		Print at 6,2,2 + BASE_HITS#0,8 + BASE_HITS#1,14 + BASE_HITS#2,_
              at 6,9,2 + BASE_HITS#3,8 + BASE_HITS#4,14 + BASE_HITS#5,_
              at 6,15,2 + BASE_HITS#6,8 + BASE_HITS#7,14 + BASE_HITS#8
		Return
'----------------------------------------------------------------------------
' Check if BASE hit by a missile
' Each base is built from three elements (characters)
' Returns with BASE_HIT set if a hit was detected
CHECK_BASE_HIT:
		BASE_HIT = FALSE										' Default to no hit detected
        Select BASE_XPOS_TEST
        	Case 12 to 17										' Has the missile XPOS hit BASE 1, ELEMENT 0
            	If BASE_HITS#0 < 5 AND BASE_ENABLED#0 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                	Inc BASE_HITS#0								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                   	BASE_ENABLED#0 = FALSE						' Disable the base element
                Endif            
           	Case 18 to 23										' Has the missile XPOS hit BASE 1, ELEMENT 1
            	If BASE_HITS#1 < 5 AND BASE_ENABLED#1 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ? 
                    Inc BASE_HITS#1								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                    BASE_ENABLED#1 = FALSE						' Disable the base element
                Endif
            Case 24 to 29										' Has the missile XPOS hit BASE 1, ELEMENT 2
            	If BASE_HITS#2 < 5 AND BASE_ENABLED#2 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#2								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
       			Else
                    BASE_ENABLED#2 = FALSE						' Disable the base element
                Endif                  
            Case 54 to 59										' Has the missile XPOS hit BASE 2, ELEMENT 3
                If BASE_HITS#3 < 5 AND BASE_ENABLED#3 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#3								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                    BASE_ENABLED#3 = FALSE						' Disable the base element
                Endif            
            Case 60 to 65										' Has the missile XPOS hit BASE 2, ELEMENT 4
            	If BASE_HITS#4 < 5 AND BASE_ENABLED#4 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#4								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                    BASE_ENABLED#4 = FALSE						' Disable the base element
                Endif
            Case 66 to 71										' Has the missile XPOS hit BASE 2, ELEMENT 5
            	If BASE_HITS#5 < 5 AND BASE_ENABLED#5 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#5								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
       			Else
                    BASE_ENABLED#5 = FALSE						' Disable the base element
                Endif                 
            Case 90 to 95										' Has the missile XPOS hit BASE 3, ELEMENT 6
                If BASE_HITS#6 < 5 AND BASE_ENABLED#6 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#6								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                    BASE_ENABLED#6 = FALSE						' Disable the base element
                Endif            
            Case 96 to 101										' Has the missile XPOS hit BASE 3, ELEMENT 7
            	If BASE_HITS#7 < 5 AND BASE_ENABLED#7 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#7								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
            	Else
                    BASE_ENABLED#7 = FALSE						' Disable the base element
                Endif
            Case 102 to 107										' Has the missile XPOS hit BASE 3, ELEMENT 8
            	If BASE_HITS#8 < 5 AND BASE_ENABLED#8 = TRUE Then ' Is the base element enabled, and has had less than 5 hits ?
                    Inc BASE_HITS#8								' Increment the amount of hits the base element has sustained
                    BASE_HIT = TRUE								' Indicate a missile has hit a target
       			Else
                    BASE_ENABLED#8 = FALSE						' Disable the base element
                Endif             
            End Select
            If BASE_HIT = TRUE Then Gosub UPDATE_BASES			' Update the base shapes if a hit was detected
            Return
'----------------------------------------------------------------------------
' Move the invader's missile
' The missile can only be fired if the flag INVADER_MISSILE_FIRED is false, 
' otherwise there is already a missile in the air

MOVE_INVADER_MISSILE:
        If INVADER_MISSILE_FIRED = TRUE Then  								' Don't enter the routine if the invader's missile is already flying       	                       
            If TIME_TO_MOVE_INV_MISSILE = TRUE Then							' Is it time to move the invader's missile ?
            	Gosub DRAW_INVADER_MISSILE
            	Inc INVADER_MISSILE_YPOS
            Endif	     		       	     
        	If INVADER_MISSILE_YPOS >= 63 OR INVADER_MISSILE_HIT = TRUE Then ' Has the invader's missile reached the bottom of the display or hit something ?
                INVADER_MISSILE_FIRED = FALSE								' Yes. So signal the invader's missile is finished
        		Gosub CLEAR_INVADER_MISSILE									' Clear the invader's missile
            	INVADER_MISSILE_HIT = FALSE
            Endif
        Endif
        Return
'----------------------------------------------------------------------------
' Move the invader's second missile
' The missile can only be fired if the flag INVADER_MISSILE2_FIRED is false, 
' otherwise there is already a missile in the air

MOVE_INVADER_MISSILE2:
		If INVADER_MISSILE2_FIRED = TRUE Then  								' Don't enter the routine if the invader's missile is already flying       	                       
            If TIME_TO_MOVE_INV_MISSILE2 = TRUE Then							' Is it time to move the invader's missile ?
            	Gosub DRAW_INVADER_MISSILE2
            	Inc INVADER_MISSILE2_YPOS
            Endif	     		       	     
        	If INVADER_MISSILE2_YPOS >= 63 OR INVADER_MISSILE2_HIT = TRUE Then ' Has the invader's missile reached the bottom of the display or hit something ?
                INVADER_MISSILE2_FIRED = FALSE								' Yes. So signal the invader's missile is finished
        		Gosub CLEAR_INVADER_MISSILE2									' Clear the invader's missile
            	INVADER_MISSILE2_HIT = FALSE
            Endif
        Endif
        Return
'---------------------------------------------------------------------------- 
' Fire an invader missile if possible 
' The logic is: -
' Make sure a missile is not already in flight.
' Scan all the invaders...
' If the invader is enabled, then check if it is over the ship.
' If it is then enable a missile to be fired.      
FIRE_INVADER_MISSILE:
		If INVADER_MISSILE_FIRED = FALSE Then										' Is it OK to fire an invader missile ?
        	INVADER_LOOP = 0
            Repeat        															' Create a loop for all the invaders
            	If INVADER_ENABLED[INVADER_LOOP] = TRUE Then 						' Is this invader enabled ?
            		Select INVADER_XPOS[INVADER_LOOP] + 5					
                    	Case SHIP_XPOS to SHIP_XPOS + 8								' Is the invader over the ship ?
                    		INVADER_MISSILE_FIRED = TRUE							' Signal that an invader's  missile is in the air
            				INVADER_MISSILE_XPOS = INVADER_XPOS[INVADER_LOOP] + 5	' Move missile XPOS to the middle of the invader
                			INVADER_MISSILE_YPOS = (INVADER_YPOS[INVADER_LOOP] * 8) + 8	' Move missile YPOS to below the invader
                    End Select                   
            	Endif           
            	Inc INVADER_LOOP
            Until INVADER_LOOP > 17													' Close the loop when all invaders have been scanned
		Endif 
        Return
'---------------------------------------------------------------------------- 
' Fire an invader second missile if possible 
' The logic is: -
' Make sure a missile is not already in flight.
' Scan all the invaders...
' If the invader is enabled, then check if it is over the ship.
' If it is then enable a missile to be fired.      
Dim RANDOM_VALUE as Byte
FIRE_INVADER_MISSILE2:
		If INVADER_MISSILE2_FIRED = FALSE Then	' Is it OK to fire an invader second missile ?
        	'If INVADER_MISSILE_XPOS < SHIP_XPOS Then
            Select SHIP_XPOS
            	Case > INVADER_MISSILE_XPOS + RANDOM_VALUE , < INVADER_MISSILE_XPOS - RANDOM_VALUE
            INVADER_LOOP = 0
            Repeat        															' Create a loop for all the invaders
            	If INVADER_ENABLED[INVADER_LOOP] = TRUE Then 						' Is this invader enabled ?
            		Select INVADER_XPOS[INVADER_LOOP] + 5					
                    	Case SHIP_XPOS to SHIP_XPOS + 8								' Is the invader over the ship ?
                    		INVADER_MISSILE2_FIRED = TRUE							' Signal that an invader's  missile is in the air
            				INVADER_MISSILE2_XPOS = INVADER_XPOS[INVADER_LOOP] + 5	' Move missile XPOS to the middle of the invader
                			INVADER_MISSILE2_YPOS = (INVADER_YPOS[INVADER_LOOP] * 8) + 8	' Move missile YPOS to below the invader
                    End Select                   
            	Endif           
            	Inc INVADER_LOOP
            Until INVADER_LOOP > 17													' Close the loop when all invaders have been scanned
			EndSelect
            
        Endif 
        Return 
'----------------------------------------------------------------------------
' Check if the invader's missile has hit something
' Returns with INVADER_MISSILE_HIT set if the invader's missile has hit something
CHECK_FOR_INVADER_MISSILE_HIT:
		INVADER_MISSILE_HIT = FALSE												' Default to not hit 
        If INVADER_MISSILE_FIRED = TRUE Then   									' First make sure that a missile is actually launched
			' Check if the invader's missile has hit a BASE
        	If INVADER_MISSILE_YPOS >= 45 Then
        		BASE_XPOS_TEST = INVADER_MISSILE_XPOS							' Transfer the invader's missile XPOS for testing
            	Gosub CHECK_BASE_HIT											' Check if a base was hit
            	If BASE_HIT = TRUE Then
            		INVADER_MISSILE_HIT = TRUE									' Transfer the hit detector into the invader's missile detector
        			Return														' Return from the subroutine prematurely
            	Endif
        	Endif 
             
			' Check if the invader's missile has hit the ship
			If INVADER_MISSILE_YPOS >= 56 Then
        		Select INVADER_MISSILE_XPOS
            		Case SHIP_XPOS - 1 To SHIP_XPOS + SHIP_WIDTH
       					Gosub DRAW_SHIP
                    	INVADER_MISSILE_HIT = TRUE								' Indicate the invader's missile has hit something
       					SHIP_HIT = TRUE											' Indicate that it is the ship that has been hit
                End Select
       		Endif
		Endif
        Return 
'----------------------------------------------------------------------------
' Check if the invader's second missile has hit something
' Returns with INVADER_MISSILE2_HIT set if the invader's missile has hit something
CHECK_FOR_INVADER_MISSILE2_HIT: 
		INVADER_MISSILE2_HIT = FALSE											' Default to not hit
        If INVADER_MISSILE2_FIRED = TRUE Then   								' First make sure that a second missile is actually launched
			' Check if the invader's second missile has hit a BASE
        	If INVADER_MISSILE2_YPOS >= 45 Then
        		BASE_XPOS_TEST = INVADER_MISSILE2_XPOS							' Transfer the invader's second missile XPOS for testing
            	Gosub CHECK_BASE_HIT											' Check if a base was hit
            	If BASE_HIT = TRUE Then
            		INVADER_MISSILE2_HIT = TRUE									' Transfer the hit detector into the invader's second missile detector
        			Return														' Return from the subroutine prematurely
            	Endif
        	Endif 
             
			' Check if the invader's missile has hit the ship
			If INVADER_MISSILE2_YPOS >= 56 Then
        		Select INVADER_MISSILE2_XPOS
            		Case SHIP_XPOS - 1 To SHIP_XPOS + SHIP_WIDTH
       					Gosub DRAW_SHIP
                    	INVADER_MISSILE2_HIT = TRUE								' Indicate the invader's second missile has hit something
       					SHIP_HIT = TRUE											' Indicate that it is the ship that has been hit
                End Select
       		Endif
		Endif
        Return         
'----------------------------------------------------------------------------
' Draw or clear the Ship's missile
CLEAR_MISSILE:
		UnPlot MISSILE_YPOS, MISSILE_XPOS
        UnPlot MISSILE_YPOS, MISSILE_XPOS + 1
        UnPlot MISSILE_YPOS + 1, MISSILE_XPOS
        UnPlot MISSILE_YPOS + 1, MISSILE_XPOS + 1
        UnPlot MISSILE_YPOS + 2, MISSILE_XPOS
        UnPlot MISSILE_YPOS + 2, MISSILE_XPOS + 1
        Return
DRAW_MISSILE:
        Plot MISSILE_YPOS, MISSILE_XPOS
        Plot MISSILE_YPOS, MISSILE_XPOS + 1
        Plot MISSILE_YPOS + 1, MISSILE_XPOS
        Plot MISSILE_YPOS + 1, MISSILE_XPOS + 1
        UnPlot MISSILE_YPOS + 2, MISSILE_XPOS
        UnPlot MISSILE_YPOS + 2, MISSILE_XPOS + 1
        Return
'----------------------------------------------------------------------------
' Draw the ship
DRAW_SHIP:
		LCDWRITE 7,SHIP_XPOS,[$00,$E0,$F0,$F0,$F8,$FC,$F8,$F0,$F0,$E0,$00]
        Return
'----------------------------------------------------------------------------
' Check if the ship's missile has hit something
' Returns with MISSILE_HIT set if the ship's missile has hit something
CHECK_FOR_MISSILE_HIT:
		MISSILE_HIT = FALSE												' Default to not hit    
		SAUCER_HIT = FALSE												' Default to saucer not hit
		If MISSILE_FIRED = TRUE Then									' First make sure a missile is actually launched
' Check if the ship's missile has hit a BASE
        	If MISSILE_YPOS  = 53 Then
        		BASE_XPOS_TEST = MISSILE_XPOS							' Transfer the ship's missile XPOS for testing
            	Gosub CHECK_BASE_HIT									' Check if a base was hit
            	If BASE_HIT = TRUE Then
            		MISSILE_SOUND_ENABLE = 0							' Disable the missile's sound
                    MISSILE_HIT = TRUE									' Transfer the hit detector into the missile detector
        			Return												' And return from the subroutine prematurely
        		Endif
        	Endif 

' Check if the ship's missile has hit an invader's missile
			If MISSILE_XPOS = INVADER_MISSILE_XPOS Then If MISSILE_YPOS = INVADER_MISSILE_YPOS Then
        		MISSILE_SOUND_ENABLE = 0							' Disable the missile's sound
                MISSILE_HIT = TRUE										' Indicate the ship's missile has hit a target
        		INVADER_MISSILE_HIT = TRUE								' Indicate the invader's missile has also been hit
            	Inc SCORE												' Increment the score by one
                Return													' And return from the subroutine prematurely
        	Endif 
 
' Check if the ship's missile has hit the saucer
			If SAUCER_ENABLED = TRUE Then
        		If MISSILE_YPOS < 7 Then
            		Select MISSILE_XPOS
            			Case SAUCER_XPOS To SAUCER_XPOS  + SAUCER_WIDTH
                			MISSILE_HIT = TRUE							' Indicate the ship's missile has hit a target	
            				SAUCER_HIT = TRUE
            				SAUCER_SOUND_ENABLE = TRUE
                            SAUCER_FREQ = 30
                            LCDWRITE 0,SAUCER_XPOS,[$8C,$C5,$6B,$36,$0C,$20,$68,$CC,$96,$33,$69,$CC,$86,$02]
                        	Delayms 10
                        	LCDWRITE 0,SAUCER_XPOS,[$7F,$08,$08,$08,$7F,$00,$00,$41,$7F,$41,$00,$00,$01,$01,$7F,$01,$01] ' Display text HIT
                        	SAUCER_FREQ = 20
                            Delayms 5
                        	SAUCER_FREQ = 10
                            Delayms 10
                        	SCORE = SCORE + (100 + SAUCER_XPOS)				' Add 100 + xpos to the score for hitting the saucer
                        	SAUCER_SOUND_ENABLE = FALSE
                            Return
            		EndSelect
        		Endif
        	Endif
                          
' Check if the ship's missile has hit an INVADER
        	INVADER_LOOP = 0
        	Repeat
        		If INVADER_ENABLED[INVADER_LOOP] = TRUE Then 				' Only check if the invader is enabled
            		If INVADER_YPOS[INVADER_LOOP] = MISSILE_YPOS / 8 Then
                    	Select MISSILE_XPOS
                    		Case INVADER_XPOS[INVADER_LOOP] to INVADER_XPOS[INVADER_LOOP] + INVADER_WIDTH
                    			INVADER_ENABLED[INVADER_LOOP] = FALSE
                    			MISSILE_HIT = TRUE							' Indicate the ship's missile has hit a target
                            	MISSILE_SOUND_ENABLE = 1
                                MISSILE_FREQ = 30
                            	Select INVADER_LOOP							' Decide on the score depending on which invader is hit
                            		Case 0 to 5								' Top layer of invaders score 20
                                		LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$42,$61,$51,$49,$46,$00,$3E,$51,$49,$45,$3E,$00]
                                		SCORE = SCORE + 20
                                	Case 6 to 11							' Middle layer of invaders score 10
                                		LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$42,$7F,$40,$00,$00,$3E,$51,$49,$45,$3E,$00]
                            			SCORE = SCORE + 10
                            		Case 12 to 17							' Bottom layer of invaders score 5
                            			LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$3E,$51,$49,$45,$3E,$00, $27,$45,$45,$45,$39,$00]
                                    	SCORE = SCORE + 5
                            	EndSelect
                                Delayms 10
                            	MISSILE_FREQ = 20
                                Delayms 10
                                MISSILE_FREQ = 10                              
                                Delayms 20
                            	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00] ' Erase the INVADER that was hit
                    			
                                
                                Dec INVADERS_ENABLED						' Decrement the hits counter
                    		
                            	If INVADERS_ENABLED = 1 Then				' Increase the speed substantially if only one invader left
                                	INVADER_SPEED = 5
                                Else if INVADERS_ENABLED = 2 Then
                                    INVADER_SPEED = 10						' Increase the speed to fast if there are only two invaders left
                                Else
                                
                                	If INVADER_SPEED >= 3 Then 					' Is the inveders speed greater than 3 ?
                						If INVADERS_ENABLED <= 4 Then			' Are there 4 or less invaders left ?
                							INVADER_SPEED = INVADER_SPEED - 3	' Yes.. So increase their speed by a factor of three
                						Else
                							Dec INVADER_SPEED					' Otherwise.. Increase the speed of the remaining invaders
                						Endif
                					Endif
                            	Endif
                                MISSILE_SOUND_ENABLE = 0					' Disable the missile's sound
                                Return										' And return from the subroutine prematurely
                    	Endselect
                	Endif
            	Endif
            	Inc INVADER_LOOP
        	Until INVADER_LOOP > 17
        Endif
        Return
'----------------------------------------------------------------------------
' Move the ship's missile
' The missile can only be fired if the flag MISSILE_FIRED is false, 
' otherwise there is already a missile in the air
'
MOVE_MISSILE:       
        If MISSILE_FIRED = TRUE Then  								' Don't enter the routine if the ship's missile is already flying       	                       
            If TIME_TO_MOVE_SHIP_MISSILE = TRUE Then				' Is it time to move the ship's missile ?
            	Gosub DRAW_MISSILE
            	Dec MISSILE_YPOS
                MISSILE_FREQ = 63 - MISSILE_YPOS
            Endif	     		       	     
        	If MISSILE_YPOS = 0 OR MISSILE_HIT = TRUE Then 			' Has the missile reached the top of the display or hit something ?
                MISSILE_SOUND_ENABLE = 0
                MISSILE_FIRED = FALSE								' Yes. So signal the missile is finished
        		Gosub CLEAR_MISSILE									' Clear the missile		
        		MISSILE_YPOS = 63 - 9       						' Reset the missile to the bottom of the display
            Endif
        Endif
        Return
'----------------------------------------------------------------------------
' Move the ship right
SHIP_RIGHT:
        If SHIP_XPOS > 117 Then Return
		Gosub DRAW_SHIP
		Inc SHIP_XPOS
		Return
'----------------------------------------------------------------------------
' Move the ship left
SHIP_LEFT:
        If SHIP_XPOS = 0 Then Return
		Gosub DRAW_SHIP
		Dec SHIP_XPOS
		Return 
'----------------------------------------------------------------------------
' Move the INVADERS down a line
' And check whether they have reached the bottom of the screen
' Flag INVADERS_REACHED_BOTTOM will be set if they have
MOVE_INVADERS_DOWN:
		INVADERS_REACHED_BOTTOM = FALSE									' Default to the invaders not at bottom of the screen
        TEMP_LOOP = 18
        Repeat      	
            Dec TEMP_LOOP
            If INVADER_ENABLED[TEMP_LOOP] = TRUE Then
            	LCDWRITE INVADER_YPOS[TEMP_LOOP],INVADER_XPOS[TEMP_LOOP],[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00]
            	INVADER_YPOS[TEMP_LOOP] = INVADER_YPOS[TEMP_LOOP] + 1
                If INVADER_YPOS[TEMP_LOOP] = 6 Then 					' Have the invaders hit the bases ?
                	Str BASE_ENABLED = 0,0,0,0,0,0,0,0,0 				' Yes.. So disable them all
                    Str BASE_HITS = 5,5,5,5,5,5,5,5,5					' And move their hit counters to past their thresholds
                Endif
                If INVADER_YPOS[TEMP_LOOP] >= 7 Then INVADERS_REACHED_BOTTOM = TRUE ' Set a flag if the invaders have reached the bottom
                LCDWRITE INVADER_YPOS[TEMP_LOOP],INVADER_XPOS[TEMP_LOOP],[$00,$06,$0C,$9C,$EA,$36,$36,$EA,$9C,$0C,$06,$00]                             
            Endif
        Until TEMP_LOOP = 0 
        Inc INVADER_MISSILE_SPEED										' Slow down the invader's missile speed as they approach the bottom of the screen
        If INVADER_SPEED >= 3 Then Dec INVADER_SPEED					' Increase the speed of the invaders
        Return      
'----------------------------------------------------------------------------
' Reset the invaders positions
' Each element of the arrays hold coordinates for the invaders
' INVADER_XPOS holds the X position of the invader
' INVADER_YPOS holds the Y position of the invader
RESET_INVADERS:
        INVADER_LOOP = 0
        Repeat
        	INVADER_ENABLED[INVADER_LOOP] = TRUE						' Set all invaders to active and image 1
        	Select INVADER_LOOP
            	Case 0 to 5
                	INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP + 1) * 16
            		INVADER_YPOS[INVADER_LOOP] = 1
                Case 6 to 11
                	INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP - 5) * 16
            		INVADER_YPOS[INVADER_LOOP] = 2
                Case 12 to 17
                	INVADER_XPOS[INVADER_LOOP] = (INVADER_LOOP - 11) * 16
            		INVADER_YPOS[INVADER_LOOP] = 3
            End Select
        	Inc INVADER_LOOP
        Until INVADER_LOOP > 17
        Return
'----------------------------------------------------------------------------
' Move the INVADERS
MOVE_INVADERS:

		'If TIME_TO_MOVE_INVADERS = TRUE Then
         	TIME_TO_MOVE_INVADERS_DOWN = FALSE
            If INVADERS_DIRECTION = FORWARD Then 						' Are the invaders to move forward (right) ?         
                INVADER_LOOP = 0										' Yes.. So reset the invader loop
                Repeat													' Create a loop for all the invaders
                	If INVADER_ENABLED[INVADER_LOOP] = TRUE Then    	' Is this invader enabled ?          	
            			INVADER_XPOS[INVADER_LOOP] = INVADER_XPOS[INVADER_LOOP] + 1 ' Yes.. So increment its XPOS
            			If INVADER_XPOS[INVADER_LOOP] >= INVADER_RIGHT_LIMIT Then 	' Have we hit the right side of the screen ?
                            INVADERS_DIRECTION = BACKWARD				' Yes.. So indicate that we need to go backwards
                            SAUCER_ENABLED = TRUE
                            TIME_TO_MOVE_INVADERS_DOWN = TRUE			' and signal that we need to move the invaders down
         				Endif
         			Endif
         			Inc INVADER_LOOP
        		Until INVADER_LOOP > 17									' Close the loop after all the invader elements have been scanned
         	Else														' Otherwise we go backwards (left)
                INVADER_LOOP = 0										' Reset the invader loop
                Repeat													' Create a loop for all the invaders
         			If INVADER_ENABLED[INVADER_LOOP] = TRUE Then       	' Is this invader enabled ?        		
                		INVADER_XPOS[INVADER_LOOP] = INVADER_XPOS[INVADER_LOOP] - 1 ' Yes.. So decrement its XPOS
                        If INVADER_XPOS[INVADER_LOOP] <= 1 Then    		' Have we hit the left side of the screen ?                   
                            INVADERS_DIRECTION = FORWARD				' Yes.. So indicate that we need to go forwards
                            TIME_TO_MOVE_INVADERS_DOWN = TRUE			' and signal that we need to move the invaders down
                		Endif
        			Endif
        			Inc INVADER_LOOP
        		Until INVADER_LOOP > 17									' Close the loop after all the invader elements have been scanned
        	Endif
        If TIME_TO_MOVE_INVADERS_DOWN = TRUE Then Gosub MOVE_INVADERS_DOWN ' Do we need to move the invaders down ?
        'Endif
        ' Fall through to DRAW_THE_INVADERS
'----------------------------------------------------------------------------
' Draw the invaders
' Draws one of two invader shapes depending on the contents of BIT variable INVADER_CHARACTER
' Each row of invaders is a different character
'INVADER TOP ROW character 1 $00,$18,$4C,$2E,$5B,$2F,$2F,$5B,$2E,$4C,$18,$00
'INVADER TOP ROW character 2 $00,$08,$2C,$5E,$0B,$1F,$1F,$0B,$5E,$2C,$08,$00
                    
'INVADER MIDDLE ROW character 1 $00,$38,$0D,$3E,$5A,$1E,$1E,$5A,$3E,$0D,$38,$00
'INVADER MIDDLE ROW character 2 $00,$06,$48,$7F,$1A,$1E,$1E,$1A,$7F,$48,$06,$00
                    
'INVADER BOTTOM ROW character 1 $00,$4C,$6E,$3A,$1B,$2F,$2F,$1B,$3A,$6E,$4C,$00
'INVADER BOTTOM ROW character 2 $00,$0C,$0E,$3A,$4B,$1F,$1F,$4B,$3A,$0E,$0C,$00
DRAW_INVADERS:
		INVADER_LOOP = 0
        Repeat          
            If INVADER_ENABLED[INVADER_LOOP] = TRUE Then   	         
                If INVADER_CHARACTER = 0 Then
                	INVADER_SOUND_ENABLE = 0
                    INVADER_FREQ = 90             	                                    
                    Select INVADER_LOOP							' Decide on the score depending on which invader is hit
                    	Case 0 to 5								
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$18,$4C,$2E,$5B,$2F,$2F,$5B,$2E,$4C,$18,$00]
                    	Case 6 to 11							
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$38,$0D,$3E,$5A,$1E,$1E,$5A,$3E,$0D,$38,$00]
                    	Case 12 to 17							
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$4C,$6E,$3A,$1B,$2F,$2F,$1B,$3A,$6E,$4C,$00]
             		EndSelect
                              	
                	INVADER_SOUND_ENABLE = 1
                Else
                    INVADER_SOUND_ENABLE = 0
                    INVADER_FREQ = 105
            		Select INVADER_LOOP							' Decide on the score depending on which invader is hit
                    	Case 0 to 5								
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$08,$2C,$5E,$0B,$1F,$1F,$0B,$5E,$2C,$08,$00]
                    	Case 6 to 11							
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$06,$48,$7F,$1A,$1E,$1E,$1A,$7F,$48,$06,$00]
                    	Case 12 to 17							
                        	LCDWRITE INVADER_YPOS[INVADER_LOOP],INVADER_XPOS[INVADER_LOOP],[$00,$0C,$0E,$3A,$4B,$1F,$1F,$4B,$3A,$0E,$0C,$00]
             		EndSelect
                    INVADER_SOUND_ENABLE = 1
                Endif
            Endif 
        	Inc INVADER_LOOP
        Until INVADER_LOOP > 17
        Return  
'----------------------------------------------------------------------------
' Clear the saucer located at the top of the screen
CLEAR_SAUCER:
		Lcdwrite 0,SAUCER_XPOS,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        Return
'----------------------------------------------------------------------------
' Draw the saucer located at the top of the screen
DRAW_SAUCER:	
        Lcdwrite 0,SAUCER_XPOS,[$00,$04,$0E,$3A,$1B,$0F,$1B,$1B,$0F,$1B,$3A,$0E,$04,$00]
        Return
'----------------------------------------------------------------------------
' Move the saucer if it is not already flying
MOVE_SAUCER:
	
		If SAUCER_ENABLED = TRUE Then  								' Don't enter the routine if the saucer is already flying       	
            SAUCER_SOUND_ENABLE = 1									' Enable the saucer's sound channel
            If TIME_TO_MOVE_SAUCER = TRUE Then						' Is it time to move the saucer ?
                Dec SAUCER_XPOS										' Move the saucer accross the screen
                if SAUCER_XPOS // 2 = 0 Then
                	SAUCER_FREQ = 10
                Else
                	SAUCER_FREQ = 12
                Endif
                Gosub DRAW_SAUCER									' Display the saucer
            Endif	     		
        	If SAUCER_XPOS = 0 OR SAUCER_HIT = TRUE Then 			' Has the saucer reached the left of the display or been hit ?      		
                SAUCER_ENABLED = FALSE								' Yes. So signal the sacucer is finished
        		Gosub CLEAR_SAUCER									' Clear the saucer		
        		SAUCER_XPOS = 127 - SAUCER_WIDTH       				' Reset the saucer to the right of the display
        		Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES	' And display the score because it was erased by the saucer
            Endif     
        Else
        	SAUCER_SOUND_ENABLE = 0								' Disable the saucer's sound channel
        Endif
        Return
'----------------------------------------------------------------------------
' Determine whether a missile, ship, saucer or base should move 
' governed by their individual speed controls
GOVERN_SPEEDS:
		' Advance the saucers's tick (governs its speed)
        Dec SAUCER_SPEED
        TIME_TO_MOVE_SAUCER = FALSE
        If SAUCER_SPEED = 0 Then 	
        TIME_TO_MOVE_SAUCER = TRUE
        SAUCER_SPEED = 3
        Endif
            
        ' Advance the ship's tick (governs its speed)
        Dec SHIP_SPEED
        TIME_TO_MOVE_BASE = FALSE
        If SHIP_SPEED = 0 Then 	
        	TIME_TO_MOVE_BASE = TRUE
            SHIP_SPEED = 3
        Endif
            
        ' Advance the invader's missile tick (governs its speed)
        Inc INVADER_MISSILE_TICK
        TIME_TO_MOVE_INV_MISSILE = FALSE
        If INVADER_MISSILE_TICK >= INVADER_MISSILE_SPEED Then 			' Set the speed for the invader's missile
        	TIME_TO_MOVE_INV_MISSILE = TRUE
            INVADER_MISSILE_TICK = 0
        Endif
        ' Advance the invader's second missile tick (governs its speed)
        Inc INVADER_MISSILE2_TICK
        TIME_TO_MOVE_INV_MISSILE2 = FALSE
        If INVADER_MISSILE2_TICK >= INVADER_MISSILE2_SPEED Then 		' Set the speed for the invader's second missile
        	TIME_TO_MOVE_INV_MISSILE2 = TRUE
            INVADER_MISSILE2_TICK = 0
        Endif
                 
        ' Advance the ship's missile tick (governs its speed)
        Dec SHIP_MISSILE_TICK
        TIME_TO_MOVE_SHIP_MISSILE = FALSE
        If SHIP_MISSILE_TICK = 0 Then 									' Set the speed for the ship's missile
        	TIME_TO_MOVE_SHIP_MISSILE = TRUE
            SHIP_MISSILE_TICK = 2
        Endif
		Return
'----------------------------------------------------------------------------
' Display the spash screen
' The subroutine re-uses some of the variables
' TEMP_LOOP, LEVEL, and INVADER_LOOP
DISPLAY_SPASH_SCREEN:
		Cls
        SCORE = 0
        TEMP_LOOP = 0
        Repeat
        	INVADER_LOOP = 0
            Repeat
            	LEVEL = CREAD INVADER_SPLASH_SCREEN + SCORE
            	LcdWrite TEMP_LOOP,INVADER_LOOP,[LEVEL]
        		Inc SCORE
                Inc INVADER_LOOP
            Until INVADER_LOOP > 127    
            Inc TEMP_LOOP
        Until TEMP_LOOP > 7
        Return
'----------------------------------------------------------------------------
MAIN_PROGRAM_LOOP:
        
        Gosub DISPLAY_SPASH_SCREEN
        Delayms 1000       
        Print at 4,1,"PRESS FIRE TO START"       
        While FIRE_BUTTON = 1 : Wend
        While FIRE_BUTTON = 0 : Wend
        Delayms 50
        
        Cls
        Print at 0,7,"Scoring"
        Lcdwrite 2,0,[$00,$04,$0E,$3A,$1B,$0F,$1B,$1B,$0F,$1B,$3A,$0E,$04,$00] 
        Print at 2,2," = 100+ Points"
        
        LCDWRITE 3,0,[$00,$18,$4C,$2E,$5B,$2F,$2F,$5B,$2E,$4C,$18,$00]						
        Print at 3,2," = 20 Points"
        LCDWRITE 4,0,[$00,$38,$0D,$3E,$5A,$1E,$1E,$5A,$3E,$0D,$38,$00]							
        Print at 4,2," = 10 Points"
        LCDWRITE 5,0,[$00,$4C,$6E,$3A,$1B,$2F,$2F,$1B,$3A,$6E,$4C,$00]
        Print at 5,2," = 5 Points"
        Print at 7,1,"PRESS FIRE TO START"
        While FIRE_BUTTON = 1 : Wend
        While FIRE_BUTTON = 0 : Wend
        Delayms 50
        
        LEVEL = 0										' Start at level 0								
        LIVES = "3"										' Set the initial lives counter to 3
        SHIP_SPEED = 3
        SCORE = 0
        SHIP_XPOS = 64
        SAUCER_SPEED = 7								' Speed of the saucer
        INVADER_SPEED = 70								' The initial speed of the invaders
        DEFAULT_INVADER_SPEED = INVADER_SPEED	
        
        TEMP_LOOP = 0
        Repeat
        	BASE_ENABLED[TEMP_LOOP] = TRUE
        	BASE_HITS[TEMP_LOOP] = 0 
        	Inc TEMP_LOOP
        Until TEMP_LOOP > 8
        
               
		INTERRUPT_COUNTER1 = 0
        NOTE_STATUS = 0
        INVADER_SOUND_COUNTER = 0
		MISSILE_SOUND_COUNTER = 0
        SAUCER_SOUND_COUNTER = 0
        INVADER_SOUND_DURATION_COUNTER = 0
        
        INVADER_SOUND_ENABLE = 1						' Enable the Invaders sound channel
		INVADER_SOUND_DURATION = 20						' Set the note duration to 20
        
      
        										
' Main program loop starts here
	           
' Jump to this location to implement a new sheet of invaders
NEW_SHEET:
        Inc LEVEL
        Cls
        Gosub UPDATE_BASES											' Draw the bases (or what's left of them)
        SHIP_HIT = FALSE											' Default to no hit on the ship by a missile
        SAUCER_ENABLED = FALSE										' Disable the saucer
        SAUCER_XPOS = 127 - SAUCER_WIDTH							' Position saucer at top tight of the screen
        MISSILE_XPOS = 0
        MISSILE_YPOS = 63 - 9
        INVADER_MISSILE_XPOS = 0
        INVADER_MISSILE_YPOS = 0
        MISSILE_STATUS = 0
        INVADER_MISSILE2_YPOS = 0									' Y position of Invader's second MISSILE
        INVADER_MISSILE2_XPOS = 0									' X position of Invader's second MISSILE
        TIME_TO_MOVE_INV_MISSILE2 = FALSE							' Indicate time to move the invader's second missile
        INVADER_MISSILE2_FIRED = FALSE								' TRUE if Invader's second MISSILE in the air
        INVADER_MISSILE2_HIT = FALSE								' Default to not hit anything
        TIME_TO_MOVE_BASE = FALSE
        
        Gosub CLEAR_INVADER_MISSILE
        Gosub CLEAR_MISSILE
        Gosub DRAW_SHIP												' Draw the initial ship
            
       	Dec DEFAULT_INVADER_SPEED									' Speed up the invaders every new sheet
        INVADER_SPEED = DEFAULT_INVADER_SPEED						' Transfer the speed into the actual speed altering variable
        Clear INVADER_TICK
        Clear INVADER_MISSILE_TICK
        Clear INVADER_MISSILE2_TICK
        SHIP_MISSILE_TICK = 2
        INVADERS_REACHED_BOTTOM = FALSE								' Default to the invaders not at the bottom of the screen
        INVADER_CHARACTER = 0
        INVADER_MISSILE_SPEED = 5									' Default speed of the invader's missile
        INVADER_MISSILE2_SPEED = 4
        INVADERS_DIRECTION = FORWARD								' Default to the invaders moving right
        INVADERS_ENABLED = 18										' All 18 invaders are enabled
        Gosub RESET_INVADERS 										' Reset all the invaders positions   
        Gosub DRAW_INVADERS											' Place all the invaders on the screen 
        
        Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
        
        While 1 = 1
        	RANDOM_VALUE = RANDOM
            RANDOM_VALUE = RANDOM_VALUE & %00111000
            Inc INVADER_TICK
            TIME_TO_MOVE_INVADERS = FALSE
            If INVADER_TICK > INVADER_SPEED Then 
            	INVADER_TICK = 0
           	 	'TIME_TO_MOVE_INVADERS = TRUE
            	'If TIME_TO_MOVE_INVADERS = TRUE Then
            	Gosub MOVE_INVADERS
                Gosub MOVE_INVADERS
                INVADER_CHARACTER = ~INVADER_CHARACTER				' Use a new invader character
                If INVADERS_REACHED_BOTTOM  = TRUE Then GAME_OVER    	
            Endif
            Gosub MOVE_SAUCER										' Move the flying saucer (if required)
            
            Gosub GOVERN_SPEEDS										' Check whether a piece should be moving
            
            If L_BUTTON = 0 Then Gosub SHIP_LEFT  					' Move ship left if LEFT button pressed
            If R_BUTTON = 0 Then Gosub SHIP_RIGHT					' Move ship right if RIGHT button pressed

        	           
        	If FIRE_BUTTON = 0 Then If MISSILE_FIRED = FALSE Then 	' Has the FIRE button been pressed and the ship's missile not already flying ?
        		SEED INVADER_SOUND_COUNTER
                MISSILE_FIRED = TRUE								' Yes.. So signal we need the ship's missile FIRED
            	MISSILE_XPOS = SHIP_XPOS + 4						' Place the ship's missile's xpos at the middle of the ship's shape
        		MISSILE_SOUND_ENABLE = 1							' Enable the missile's sound
            Endif
        	
                    
            Gosub MOVE_MISSILE										' Move the ship's missile if OK to do so
			Gosub CHECK_FOR_MISSILE_HIT								' Check if the ship's missile has hit anything
            
            If MISSILE_HIT = TRUE OR SAUCER_HIT = TRUE Then
            	If BASE_HIT = FALSE Then
                	'Print at 0,19,Dec2 INVADERS_ENABLED," "		' Display the INVADER hits count             
            		Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
                Endif
            Endif
            
           	If INVADER_CHARACTER = 1 Then
            	Gosub FIRE_INVADER_MISSILE							' Fire an invader missile is possible
 			Endif
            Gosub MOVE_INVADER_MISSILE								' Move the invader's missile (if fired)
            Gosub CHECK_FOR_INVADER_MISSILE_HIT						' Check if the invader's missile has hit anything
            
            If INVADERS_ENABLED = 0 Then 							' Have all the invaders been destroyed ?
            	INVADERS_ENABLED = 18								' Yes.. So enable them all again
                If INVADER_SPEED >= 3 Then Dec INVADER_SPEED		' Increase the speed of the invaders
                Goto NEW_SHEET										' and start a new sheet
            Endif              
        	
            If LEVEL > 10 Then										' Add a second invader missile after level 10
            	If INVADER_CHARACTER = 0 then
            		Gosub FIRE_INVADER_MISSILE2						' Fire an invader missile is possible
 				Endif
            	Gosub MOVE_INVADER_MISSILE2							' Move the invader's missile (if fired)
            	Gosub CHECK_FOR_INVADER_MISSILE2_HIT				' Check if the invader's missile has hit anything
        	Endif
            
            If SHIP_HIT = TRUE Then									' Has the ship been hit ?
            	SHIP_HIT = FALSE
                
                SAUCER_SOUND_ENABLE = 1								' Yes. So enable SAUCER sound channel
        		MISSILE_SOUND_ENABLE = 1       						' Enable MISSILE sound channel
        		MISSILE_FREQ = 70									' Set MISSILE channel frequency to 70 
        		SAUCER_FREQ = 90     								' Set SAUCER channel frequency to 90 
                LCDWRITE 7,SHIP_XPOS,[$10,$24,$AC,$F8,$F0,$E0,$F0,$F8,$AC,$24,$10] ' Draw first part of ship exploding
				Delayms 40											' Leave the graphic on the screen for 40ms
                SAUCER_FREQ = 100									' Increase the SAUCER channel's frequency
        		MISSILE_FREQ = 120									' Increase the MISSILE channel's frequency
                LCDWRITE 7,SHIP_XPOS,[$00,$20,$28,$F0,$A8,$C0,$E0,$F0,$28,$04,$00]	' Draw second part of ship exploding
        		Delayms 40											' Leave the graphic on the screen for 40ms
                SAUCER_FREQ = 150									' Increase the SAUCER channel's frequency
        		MISSILE_FREQ = 135									' Increase the MISSILE channel's frequency
                LCDWRITE 7,SHIP_XPOS,[$00,$00,$30,$60,$80,$C0,$60,$30,$00,$00,$00]	' Draw third part of ship exploding
                Delayms 100
                LCDWRITE 7,SHIP_XPOS,[$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00]	' Clear the ship graphic
                Delayms 100											' Leave the graphic on the screen for 100ms
                LIVES = LIVES - 1									' Decrement the lives counter
                MISSILE_SOUND_ENABLE = 0							' Disable the MISSILE sound channel
				SAUCER_SOUND_ENABLE = 0								' Disable the SAUCER sound channel
                If LIVES > "0" Then									' Do we have any lives left ?
                	LCDWRITE 7,SHIP_XPOS,[$00,$E0,$F0,$F0,$F8,$FC,$F8,$F0,$F0,$E0,$00]	' Yes. So Re-draw the ship and carry on
                	Print at 0,20,LIVES								' Update the Display for the amount of lives
                Else												' Otherwise, we don't have any lives left
                	Goto GAME_OVER									' So game over					
                Endif
            Endif
            Delayms 6												' Main game speed setting
        Wend
'--------------------------------------------------------------------
' Explode the ship when the game is over
GAME_OVER:
		Print at 0,0,Dec LEVEL, " ",Dec SCORE,at 0,20,LIVES
        SAUCER_SOUND_ENABLE = TRUE										' Enable SAUCER sound channel
        MISSILE_SOUND_ENABLE = TRUE       								' Enable MISSILE sound channel
        MISSILE_FREQ = 70											' Set MISSILE channel frequency to 70 
        SAUCER_FREQ = 90     										' Set SAUCER channel frequency to 90 
        TEMP_LOOP = 1
        Repeat
        	MISSILE_FREQ = MISSILE_FREQ - TEMP_LOOP
            SAUCER_FREQ = SAUCER_FREQ - TEMP_LOOP
            Delayms 10 + TEMP_LOOP
            Circle 1,SHIP_XPOS + 5,63,TEMP_LOOP          
            If TEMP_LOOP > 10 Then
            	Circle 0,SHIP_XPOS + 5,63,TEMP_LOOP - 10
            Endif
        	TEMP_LOOP = TEMP_LOOP + 2
        Until TEMP_LOOP > 24
        SAUCER_SOUND_ENABLE = FALSE										' Disable SAUCER sound channel
        MISSILE_SOUND_ENABLE = FALSE       								' Disable MISSILE sound channel
        TEMP_LOOP = 1
        Repeat
            Circle 0,SHIP_XPOS + 5,63,TEMP_LOOP    
        	TEMP_LOOP = TEMP_LOOP + 2
        Until TEMP_LOOP > 24
        'Cls
        Print at 3,6,INVERSE 1,"GAME OVER", INVERSE 0
        Delayms 500
        Print at 4,1,"PRESS FIRE TO START"
        While FIRE_BUTTON = 1 : Wend
        Delayms 50
        While FIRE_BUTTON = 0 : Wend
        Delayms 50
        Goto MAIN_PROGRAM_LOOP
'--------------------------------------------------------------------                
' Font CDATA table for space invaders game

FONT:-	CData $00,$00,$00,$00,$00,$00		'Graphic Character 0
		CData $FF,$FF,$FF,$FF,$FF,$FF		'Graphic Character 1
        CData $E0,$F0,$F8,$FC,$FC,$FE		' Left side of base complete (Character 2)
        CData $C0,$B0,$B0,$70,$EC,$F8		' Left side of base after hit 1 (Character 3)
        CData $C0,$A0,$B0,$70,$AC,$28		' Left side of base after hit 2 (Character 4)
        CData $40,$A0,$B0,$70,$A0,$20		' Left side of base after hit 3 (Character 5)
        CData $40,$80,$80,$40,$A0,$20		' Left side of base after hit 4 (Character 6)
        CData $00,$00,$00,$00,$00,$00		' Left side of base after hit 5 (Character 7)
        
        CData $FE,$FE,$FE,$FE,$FE,$FE		' Middle of base complete (Character 8)
        CData $FE,$DE,$EC,$F0,$F8,$FE		' Middle of base after hit 1 (Character 9)
        CData $F8,$DE,$E4,$F0,$D8,$9E		' Middle of base after hit 2 (Character 10)
        CData $B8,$DE,$A4,$B0,$48,$B4		' Middle of base after hit 3 (Character 11)
        CData $34,$58,$A4,$B8,$48,$34		' Middle of base after hit 4 (Character 12)
        CData $00,$00,$00,$00,$00,$00		' Middle of base after hit 5 (Character 13)
        
        CData $FE,$FC,$FC,$F8,$F0,$E0		' Right side of base complete (Character 14)
        CData $C0,$B0,$B0,$70,$EC,$F8		' Right side of base after hit 1 (Character 15)
        CData $C0,$A0,$B0,$70,$AC,$28		' Right side of base after hit 2 (Character 16)
        CData $40,$A0,$B0,$70,$A0,$20		' Right side of base after hit 3 (Character 17)
        CData $40,$80,$80,$40,$A0,$20		' Right side of base after hit 4 (Character 18)
        CData $00,$00,$00,$00,$00,$00		' Right side of base after hit 5 (Character 19)
        
        CData $FF,$00,$00,$00,$00,$00		'Graphic character 20
        CData $00,$00,$00,$00,$00,$FF		'Graphic character 21
        CData $FF,$01,$01,$01,$01,$01		'Graphic character 22
        CData $01,$01,$01,$01,$01,$FF		'Graphic character 23
        CData $FF,$80,$80,$80,$80,$80		'Graphic character 24
        CData $80,$80,$80,$80,$80,$FF		'Graphic character 25
        CData $00,$00,$00,$00,$F0,$F0		'User defined character 26
        CData $00,$00,$00,$00,$0F,$0F		'User defined character 27
        CData $00,$00,$00,$00,$00,$00		'User defined character 28
        CData $00,$00,$00,$00,$00,$00		'User defined character 29
        CData $00,$00,$00,$00,$00,$00		'User defined character 30
        CData $00,$00,$00,$00,$00,$00		'User defined character 31
        CData $00,$00,$00,$00,$00,$00		'32 -   - 20        
		CData $00,$00,$4F,$00,$00,$00		'33 - ! - 21
		CData $00,$07,$00,$07,$00,$00		'34 - " - 22
		CData $14,$7F,$14,$7F,$14,$00		'35 - # - 23
		CData $24,$2A,$7F,$2A,$12,$00		'36 - $ - 24
		CData $23,$13,$08,$64,$62,$00		'37 - % - 25
		CData $36,$49,$55,$22,$50,$00		'38 - & - 26
		CData $00,$05,$03,$00,$00,$00		'39 - ' - 27
		CData $1C,$22,$41,$00,$00,$00		'40 - ( - 28
		CData $00,$00,$41,$22,$1C,$00		'41 - ) - 29
		CData $14,$08,$3E,$08,$14,$00		'42 - * - 2A
		CData $08,$08,$3E,$08,$08,$00		'43 - + - 2B
		CData $00,$50,$30,$00,$00,$00		'44 - , - 2C
		CData $08,$08,$08,$08,$08,$00		'45 - - - 2D
		CData $00,$60,$60,$00,$00,$00		'46 - . - 2E
		CData $20,$10,$08,$04,$02,$00		'47 - / - 2F
		CData $3E,$51,$49,$45,$3E,$00		'48 - 0 - 30
		CData $00,$42,$7F,$40,$00,$00		'49 - 1 - 31
		CData $42,$61,$51,$49,$46,$00		'50 - 2 - 32
		CData $21,$41,$45,$4B,$31,$00		'51 - 3 - 33
		CData $18,$14,$12,$7F,$10,$00		'52 - 4 - 34
		CData $27,$45,$45,$45,$39,$00		'53 - 5 - 35
		CData $3C,$4A,$49,$49,$30,$00		'54 - 6 - 36
		CData $01,$71,$09,$05,$03,$00		'55 - 7 - 37
		CData $36,$49,$49,$49,$36,$00		'56 - 8 - 38
		CData $06,$49,$49,$49,$3E,$00		'57 - 9 - 39
		CData $00,$36,$36,$00,$00,$00		'58 - : - 3A
		CData $00,$56,$36,$00,$00,$00		'59 - ; - 3B
		CData $08,$14,$22,$41,$00,$00		'60 - < - 3C
		CData $14,$14,$14,$14,$14,$00		'61 - = - 3D
		CData $00,$41,$22,$14,$08,$00		'62 - > - 3E
		CData $02,$01,$51,$09,$06,$00		'63 - ? - 3F
		CData $32,$49,$79,$41,$3E,$00		'64 - @ - 40
		CData $7E,$11,$11,$11,$7E,$00		'65 - A - 41
		CData $7F,$49,$49,$49,$36,$00		'66 - B - 42
		CData $3E,$41,$41,$41,$22,$00		'67 - C - 43
		CData $7F,$41,$41,$22,$1C,$00		'68 - D - 44
		CData $7F,$49,$49,$49,$41,$00		'69 - E - 45
		CData $7F,$09,$09,$09,$01,$00		'70 - F - 46
		CData $3E,$41,$49,$49,$7A,$00		'71 - G - 47
		CData $7F,$08,$08,$08,$7F,$00		'72 - H - 48
		CData $00,$41,$7F,$41,$00,$00		'73 - I - 49
		CData $20,$40,$41,$3F,$01,$00		'74 - J - 4A
		CData $7F,$08,$14,$22,$41,$00		'75 - K - 4B
		CData $7F,$40,$40,$40,$40,$00		'76 - L - 4C
		CData $7F,$02,$0C,$02,$7F,$00		'77 - M - 4D
		CData $7F,$04,$08,$10,$7F,$00		'78 - N - 4E
		CData $3E,$41,$41,$41,$3E,$00		'79 - O - 4F
		CData $7F,$09,$09,$09,$06,$00		'80 - P - 50
		CData $3E,$41,$51,$21,$5E,$00		'81 - Q - 51
		CData $7F,$09,$19,$29,$46,$00		'82 - R - 52
		CData $46,$49,$49,$49,$31,$00		'83 - S - 53
		CData $01,$01,$7F,$01,$01,$00		'84 - T - 54
		CData $3F,$40,$40,$40,$3F,$00		'85 - U - 55
		CData $1F,$20,$40,$20,$1F,$00		'86 - V - 56
		CData $3F,$40,$38,$40,$3F,$00		'87 - W - 57
		CData $63,$14,$08,$14,$63,$00		'88 - X - 58
		CData $07,$08,$70,$08,$07,$00		'89 - Y - 59
		CData $61,$51,$49,$45,$43,$00		'90 - Z - 5A
		CData $7F,$41,$41,$00,$00,$00		'91 - [ - 5B
		CData $02,$04,$08,$10,$20,$00		'92 - \ - 5C
		CData $00,$00,$41,$41,$7F,$00		'93 - ] - 5D
		CData $04,$02,$01,$02,$04,$00		'94 - ^ - 5E
		CData $40,$40,$40,$40,$40,$00		'95 - _ - 5F
		CData $00,$01,$02,$04,$00,$00		'96 - ` - 60
		CData $20,$54,$54,$54,$78,$00		'97 - a - 61
		CData $7F,$48,$44,$44,$38,$00		'98 - b - 62
		CData $38,$44,$44,$44,$20,$00		'99 - c - 63
		CData $38,$44,$44,$48,$7F,$00		'100  d - 64
		CData $38,$54,$54,$54,$18,$00		'101  e - 65
		CData $08,$7E,$09,$01,$02,$00		'102  f - 66
		CData $0C,$52,$52,$52,$3E,$00		'103  g - 67
		CData $7F,$08,$04,$04,$78,$00		'104  h - 68
		CData $00,$44,$7D,$40,$00,$00		'105  i - 69
		CData $00,$20,$40,$44,$3D,$00		'106  j - 6A
		CData $7F,$10,$28,$44,$00,$00		'107  k - 6B
		CData $00,$41,$7F,$40,$00,$00		'108  l - 6C
		CData $7C,$04,$18,$04,$78,$00		'109  m - 6D
		CData $7C,$08,$04,$04,$78,$00		'110  n - 6E
		CData $38,$44,$44,$44,$38,$00		'111  o - 6F
		CData $7C,$14,$14,$14,$08,$00		'112  p - 70
		CData $08,$14,$14,$18,$7C,$00		'113  q - 71
		CData $7C,$08,$04,$04,$08,$00		'114  r - 72
		CData $48,$54,$54,$54,$20,$00		'115  s - 73
		CData $04,$3F,$44,$40,$20,$00		'116  t - 74
		CData $3C,$40,$40,$20,$7C,$00		'117  u - 75
		CData $1C,$20,$40,$20,$1C,$00		'118  v - 76
		CData $3C,$40,$30,$40,$3C,$00		'119  w - 77
		CData $44,$28,$10,$28,$44,$00		'120  x - 78
		CData $0C,$50,$50,$50,$3C,$00		'121  y - 79
		CData $44,$64,$54,$4C,$44,$00		'122  z - 7A
		CData $08,$36,$41,$00,$00,$00		'123  { - 7B
		CData $00,$00,$7F,$00,$00,$00		'124  | - 7C
		CData $00,$00,$41,$36,$08,$00		'125  } - 7D
		CData $00,$08,$04,$08,$04,$00 		'126  ~ - 7E     
        
        
'--------------------------------------------------------------------
INVADER_SPLASH_SCREEN:
  CDATA	 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$70,$78,_
		 $7C,$7C,$7C,$7C,$7C,$FC,$F8,$F0,$E0,$C0,$C0,$7C,$7C,$7C,$7C,$7C,_
		 $7C,$7C,$7C,$7C,$7C,$7C,$F8,$F0,$E0,$C0,$00,$00,$80,$7C,$7C,$7C,_
		 $7C,$7C,$7C,$7C,$7C,$70,$80,$00,$00,$00,$80,$C0,$F0,$F8,$3E,$3E,_
		 $3E,$3E,$3E,$3E,$3E,$3E,$3E,$7C,$F8,$E0,$C0,$FE,$FE,$3E,$3E,$3E,_
		 $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$20,$A0,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$60,$F0,$0C,$06,$06,$06,$06,$86,_
		 $86,$86,$06,$06,$06,$0C,$19,$F3,$C7,$3F,$FF,$02,$02,$02,$02,$02,_
		 $82,$82,$82,$82,$02,$06,$0C,$19,$33,$E7,$F8,$00,$FF,$02,$02,$02,_
		 $02,$02,$02,$02,$02,$06,$FF,$00,$00,$FE,$FF,$F3,$71,$08,$0C,$06,_
		 $02,$02,$82,$82,$82,$02,$02,$02,$07,$0F,$FF,$3F,$C0,$FC,$1E,$02,_
		 $02,$02,$03,$C3,$C3,$C3,$C3,$C3,$C3,$43,$73,$1F,$03,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$3C,$E0,$80,$00,$00,$03,_
		 $1E,$61,$5E,$58,$58,$58,$58,$99,$BF,$40,$03,$FF,$C0,$00,$00,$00,_
		 $01,$FF,$83,$FF,$00,$00,$00,$00,$00,$FF,$07,$FE,$0F,$00,$00,$00,_
		 $F8,$7F,$E0,$00,$00,$00,$0F,$FC,$00,$FF,$01,$FF,$00,$00,$00,$00,_
		 $00,$FE,$1F,$0C,$0F,$08,$08,$08,$F8,$7E,$07,$FC,$1F,$03,$00,$00,_
		 $00,$00,$0F,$0F,$0D,$E8,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$63,$E6,$2C,_
		 $28,$28,$68,$E8,$98,$F0,$00,$01,$01,$07,$FE,$83,$7F,$F0,$00,$00,_
		 $00,$01,$E1,$21,$60,$30,$30,$0C,$06,$01,$00,$FF,$00,$00,$00,$00,_
		 $8F,$8C,$8F,$00,$00,$00,$00,$3F,$F8,$3F,$FE,$07,$00,$00,$00,$80,_
		 $FF,$C1,$FE,$0E,$02,$02,$82,$FB,$1F,$E0,$FF,$03,$00,$00,$00,$F0,_
		 $BE,$83,$83,$E3,$82,$83,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$C0,$40,$40,$5C,$7C,$7C,$FC,$FC,$F0,$40,$4C,_
		 $7C,$7C,$7C,$FC,$FC,$F8,$20,$00,$0C,$3C,$3C,$7C,$FC,$FC,$F3,$06,_
		 $0C,$18,$30,$71,$F1,$F1,$F1,$D0,$18,$0C,$3F,$3D,$3C,$FF,$FC,$F8,_
		 $18,$18,$DF,$1E,$3C,$3C,$3C,$3C,$3C,$3C,$3F,$F8,$08,$08,$08,$0E,_
		 $0F,$3C,$3F,$3F,$38,$38,$38,$38,$3F,$3E,$7D,$F3,$EC,$08,$F8,$F8,_
		 $78,$38,$38,$38,$3C,$3F,$3F,$3E,$3E,$3F,$38,$38,$38,$E8,$88,$F8,_
		 $78,$38,$38,$3C,$3F,$3E,$3E,$38,$30,$20,$40,$80,$C0,$F0,$F8,$FC,_
		 $FE,$7E,$3E,$1E,$1E,$1E,$1E,$1E,$1C,$10,$00,$40,$80,$00,$00,$00,_
		 $00,$06,$0E,$36,$C6,$82,$02,$06,$1C,$30,$C6,$8F,$3B,$E3,$82,$02,_
		 $06,$0C,$30,$6E,$FB,$C3,$03,$02,$02,$02,$1E,$73,$9F,$73,$C3,$83,_
		 $03,$07,$1C,$70,$C1,$07,$7F,$C3,$03,$03,$03,$03,$7F,$C0,$FF,$FF,_
		 $FF,$FF,$03,$03,$03,$03,$03,$03,$03,$07,$3E,$C3,$7F,$E0,$00,$00,_
		 $FF,$03,$03,$01,$E1,$E1,$21,$E1,$01,$01,$03,$06,$8F,$F8,$FF,$3F,_
		 $FC,$07,$01,$01,$01,$01,$E1,$E1,$A1,$A1,$A1,$21,$E1,$F1,$3F,$E3,_
		 $3C,$07,$01,$01,$01,$C1,$61,$E1,$61,$01,$01,$01,$01,$C7,$7F,$99,_
		 $70,$3C,$06,$02,$03,$C1,$31,$B1,$71,$31,$01,$01,$81,$C1,$76,$18,_
		 $00,$00,$00,$00,$00,$01,$06,$0C,$30,$40,$80,$01,$06,$0C,$31,$C6,_
		 $9C,$70,$C0,$00,$00,$01,$07,$00,$80,$00,$00,$00,$07,$1E,$F0,$83,_
		 $0E,$38,$E0,$80,$00,$07,$0C,$7F,$80,$00,$00,$00,$00,$FF,$07,$FF,_
		 $FF,$FF,$00,$00,$00,$00,$FF,$E0,$00,$00,$00,$07,$F8,$8F,$FC,$80,_
		 $FF,$00,$00,$00,$FF,$07,$00,$FF,$00,$00,$00,$80,$FF,$FF,$8F,$7E,_
		 $03,$00,$00,$00,$00,$E4,$A7,$A6,$A6,$26,$FE,$7E,$CF,$F9,$0F,$01,_
		 $00,$00,$C0,$C8,$CE,$09,$07,$01,$30,$F0,$68,$2C,$27,$39,$3E,$C3,_
		 $40,$40,$C8,$4E,$0B,$08,$0A,$9B,$F2,$03,$03,$03,$01,$00,$00,$00,_
		 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$0C,$30,$60,$C0,_
		 $C1,$C6,$5D,$F7,$CC,$30,$E0,$C0,$C0,$47,$5E,$6C,$30,$60,$40,$43,_
		 $5E,$74,$04,$05,$06,$18,$70,$40,$40,$40,$40,$40,$40,$47,$7E,$07,_
		 $01,$7F,$40,$40,$40,$40,$79,$09,$09,$70,$40,$40,$40,$4F,$74,$01,_
		 $7F,$40,$40,$40,$47,$44,$46,$41,$40,$20,$10,$0F,$01,$43,$7F,$40,_
		 $40,$40,$40,$40,$4F,$48,$48,$48,$78,$08,$70,$5E,$43,$40,$40,$60,_
		 $38,$47,$7B,$47,$41,$40,$70,$1C,$07,$03,$3E,$61,$41,$61,$69,$6F,_
		 $6D,$66,$61,$30,$10,$1C,$06,$03,$00,$00,$00,$00,$00,$00,$00,$00


            
