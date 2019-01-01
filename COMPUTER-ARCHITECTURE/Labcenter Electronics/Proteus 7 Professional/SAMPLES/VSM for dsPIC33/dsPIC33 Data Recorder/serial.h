/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                       UART1 module                      *****/
/*****        Header for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/
void Init_Serial (void);
void Close_Serial (void);
void Serial_PutChar(char Ch);
void Serial_SendString (char *str);
char Serial_GetChar(void);
void Serial_PutDec(unsigned int Dec);
void Serial_Hexbyte (unsigned char value);
void Serial_Hexword (unsigned int value);

