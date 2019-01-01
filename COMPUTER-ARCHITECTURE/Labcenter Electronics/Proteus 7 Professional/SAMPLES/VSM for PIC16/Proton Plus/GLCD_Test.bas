' Display text and graphics on a graphic LCD

		Include "PROTON_G4.INT" 
        
' Set up some Variables
        
        Dim Xpos		as	Byte
        Dim	Ypos		as	Byte

        Cls
        Print at 0 , 2 , "Graphic LCD Test"
        
Again:        
        For Xpos = 0 to 63
        	Ypos = SIN Xpos
        	Plot Xpos , Ypos
        	Delayms 10
        Next
        For Xpos = 0 to 63
        	Ypos = SIN Xpos
        	UnPlot Xpos , Ypos
        	Delayms 10
        Next                
		Goto Again
        
		Include "FONT.INC"

