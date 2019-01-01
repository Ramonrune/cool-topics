; Test program for external memory.
; Write data to memory, then read it back.
; The program loops forever.

                org 0


loop1:		mov DPTR,#1234h
		mov A,#0AAh
		movx @DPTR,A		
		movx A,@DPTR

		jmp loop1
                
                END

