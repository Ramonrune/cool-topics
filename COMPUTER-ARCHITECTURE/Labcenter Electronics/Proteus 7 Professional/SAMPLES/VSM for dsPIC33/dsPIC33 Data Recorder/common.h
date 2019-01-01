unsigned int get_pressure(unsigned char navr);
unsigned int get_temperature (void);
unsigned int get_humidity (void);
unsigned char get_header (unsigned int address);
void header_Initialize (void);
void ee_write (void);

// macros
#define AN_SW_ON           _TRISB4 = 0; _LATB4 = 0 
#define AN_SW_OFF          _TRISB4 = 1; _LATB4 = 1 

// Size for 1364 records (each record for 3 channels) 
#define MAX_SIZE           0x1FFC 
