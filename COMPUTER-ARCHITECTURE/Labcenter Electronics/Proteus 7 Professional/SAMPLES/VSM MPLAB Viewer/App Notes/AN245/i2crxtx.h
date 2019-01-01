/******************************************************************************************/
// Hardware I2C single master routines for PIC16F877
// for HI-TEC PIC C COMPILER.
//
// i2c_init  - initialize I2C functions
// i2c_start - issue Start condition
// i2c_repStart- issue Repeated Start condition
// i2c_stop  - issue Stop condition
// i2c_read(x) - receive unsigned char - x=0, don't acknowledge - x=1, acknowledge
// i2c_write - write unsigned char - returns ACK
//
// modified from CCS i2c_877 demo
//
//
/******************************************************************************************/

void i2c_init();

void i2c_waitForIdle();

void i2c_start();

void i2c_repStart();

void i2c_stop();

int i2c_read( unsigned char ack );

unsigned char i2c_write( unsigned char i2cWriteData );


/******************************************************************************************/


