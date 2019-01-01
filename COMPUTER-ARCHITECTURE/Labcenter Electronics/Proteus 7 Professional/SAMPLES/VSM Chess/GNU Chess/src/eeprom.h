/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****               PROTEUS VSM GNU CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                   I2C EEPROM I/O Header                  *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/


// Portability types:
#ifndef VOID
#define VOID void
typedef int INT;
typedef unsigned UINT;
typedef int BOOL;
typedef unsigned char BYTE;
typedef unsigned short WORD;
#endif

// Booleans
#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

VOID eeprom_init();
BYTE eeprom_read (INT addr);
VOID eeprom_write (INT addr, BYTE data);

BOOL i2c_start (INT addr);
BOOL i2c_stop ();
INT i2c_write (BYTE data);
INT i2c_read (BOOL ack);
