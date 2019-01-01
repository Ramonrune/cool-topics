/*******************************************************************/
/*******************************************************************/
/*****                                                         *****/
/*****       L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                         *****/
/*****      LABCENTER INTEGRATED SIMULATION ARCHITECTURE       *****/
/*****              SHTxx digital sensors drivers              *****/
/*****             NOTE: not standard I2C protocol             *****/
/*****                                                         *****/
/*****        Header for SOLID STATE Recorder using dsPIC33    *****/
/*****                                                         *****/
/*******************************************************************/
/*******************************************************************/

unsigned int get_measure (void);
unsigned char get_byte (char ack);
void send_command (unsigned char command);

// List of shtxx commands:
#define MEAS_TEMP       0b00000011
#define MEAS_RH         0b00000101
#define READ_STATUS     0b00000111
#define WRITE_STATUS    0b00000110
#define SOFT_RESET      0b00011110

// Pins involved in the stuff:
#define SCL             _RB9
#define SDA             _RB1
#define SCLDIR          _TRISB9
#define SDADIR          _TRISB1

// Definitions: 
#define  out            0
#define  in             1
#define  delay          Nop() 

#define  scl_low        SCLDIR = out; SCL = 0
#define  scl_hi         SCLDIR = out; SCL = 1          
#define  sda_low        SDA = 0; SDADIR = out
#define  sda_hi         SDADIR = in; delay                           
#define  scl_toggle     scl_low; scl_hi 
#define  scl_tick       scl_hi; scl_low

// Macros:
// Connection reset sequence. Nine or more SCK toggles while leaving DATA high.
#define reset()      sda_hi; scl_toggle; scl_toggle; scl_toggle; scl_toggle; scl_toggle; scl_toggle; \
                             scl_toggle; scl_toggle; scl_toggle; scl_toggle; scl_toggle; scl_low; scl_low  

// Transmission start sequence
#define start()      sda_hi; scl_hi; sda_low; scl_low; scl_hi; sda_hi; scl_low        

