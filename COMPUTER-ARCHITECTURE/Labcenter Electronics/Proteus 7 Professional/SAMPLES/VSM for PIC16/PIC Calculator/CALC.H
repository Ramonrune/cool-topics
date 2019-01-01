/******************************************************************************            
************             LABCENTER ELECTRONICS                      ***********            
************	       Proteus VSM Sample Design Code               ***********		 	     
************	           IAR 'C' Calculator                 	    ***********            
******************************************************************************/           
                                                                                            
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
#define MAX_DISPLAY_CHAR 10    

// Keypad Config.
#define KEYP_NUM_ROWS 4
#define KEYP_NUM_COLS 4

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
enum ERROR { OK = 0, SLEEP = 1, ERROR = 2};                                                 
                                                                                               
/************************************************************************                   
***** FUNCTION PROTOTYPES *****                                                             
******************************/                                                             
VOID calc_evaluate();                                                                       
CHAR calc_getkey (VOID);                                                                    
VOID calc_format (FLOAT f);
VOID calc_display (CHAR *buf);                                             
                                                                                            
//Operator Indirect function.                                                               
VOID calc_opfunctions (CHAR token);                                                         
                                                                                            
//Utility functions.                                                                        
BOOL  calc_testkey  (CHAR ch);                                                              
VOID  calc_output   (INT status);                                                           

// Keypad Functions.
CHAR keypadread(); 
CHAR scankeypad();

VOID lcd_init();
VOID lcd_wait();
VOID wrcmd (CHAR data);
VOID wrdata(CHAR data);
VOID clearscreen();
                                                                                            
