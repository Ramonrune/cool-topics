/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****       LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                                                          *****/
/*****             Header File for 4-Bit LCD Sample             *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/      
                                                                                            
typedef void VOID;                                                                          
typedef int  INT;                                                                           
typedef signed char INT8;
typedef signed int  INT16;
typedef signed long INT32;
typedef unsigned short WORD;                                                                
typedef char CHAR;                                                                          
typedef unsigned char BYTE;                                                                 
typedef float FLOAT;                                                                        
typedef double DOUBLE;                                                                      
typedef long LONG;                                                                          
typedef INT8 BOOL;
                                                                                            
//Display Config.
#define MAX_DISPLAY_CHAR 15    

//LCD Registers addresses (PORT B)
#define LCD_CMD_WR	   0x00
#define LCD_DATA_WR	   0x01
#define LCD_BUSY_RD	   0x02
#define LCD_DATA_RD	   0x03
                     
//LCD Commands        
#define LCD_CLS		   0x01
#define LCD_HOME	   0x02
#define LCD_SETMODE	   0x04
#define LCD_SETVISIBLE	   0x08
#define LCD_SHIFT	   0x10
#define LCD_SETFUNCTION	   0x20
#define LCD_SETCGADDR	   0x40
#define LCD_SETDDADDR	   0x80

#define E_PIN_MASK         0x04
#define NOP                asm("NOP")

#define FALSE 0
#define TRUE  1                                                       
                                                                                            
//Error handling status.                                                                    
enum ERROR     { OK = 0, SLEEP = 1, ERROR = 2};                                                 
                                                                                               
/************************************************************************                   
***** FUNCTION PROTOTYPES *****                                                             
******************************/                                                             
VOID lcd_init();
VOID lcd_wait();
VOID clearscreen();
VOID wrcmd (CHAR data);
VOID wrdata(CHAR data);
VOID wrcgchr(BYTE *arrayptr, INT offset);
VOID pause(INT num);
VOID eat();
