/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****                     I2C Master module                   *****/
/*****        Header for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

void I2C_EEPROM_Init (unsigned long baudrate); 
void I2C_Off (void);
void I2C_Write (unsigned char data, unsigned int address);
unsigned char I2C_Read (unsigned int address);
void I2C_Erase (void);
