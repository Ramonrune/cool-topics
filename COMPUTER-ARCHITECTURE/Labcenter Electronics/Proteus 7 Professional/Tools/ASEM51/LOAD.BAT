@ECHO OFF
REM           Will be invoked by BOOT.BAT.
REM           Do not run LOAD.BAT directly!
REM
IF (%6)==() GOTO USAGE
IF NOT (%7)==() GOTO USAGE
REM initialize serial port %1 to baudrate %2:
MODE %1:%2,N,8,1,P
IF ERRORLEVEL 1 GOTO END
REM reset target system over printer port %4:
RESET %4 %5
IF ERRORLEVEL 1 GOTO END
REM assemble program:
ASEM %6
IF ERRORLEVEL 1 GOTO END
REM upload Intel-HEX file to target system:
ECHO U >%1
ECHO .
ECHO      uploading file %6.HEX ...
ECHO .
COPY %6.HEX %1
REM start program at location %3:
ECHO G %3 >%1
GOTO END
:USAGE
ECHO .
ECHO      usage:         BOOT source
ECHO .
:END
