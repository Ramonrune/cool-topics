/**********************************************************************
mcp23016.c - Driver file MCP23016 I/O Expander

-Controls I2C interfacing
**********************************************************************/

#use standard_io(C)

//Utilizing a 20MHz clock
#use delay(clock=20000000) 

//Intialize I2C interface
#use i2c(master,sda=PIN_C4,scl=PIN_C3)

// COMMAND BYTE TO REGISTER RELATIONSHIP : Table: 1-3 of Microchip MCP23016 - DS20090A
#define GP0 0x00
#define GP1 0x01
#define OLAT0 0x02
#define OLAT1 0x03
#define IPOL0 0x04		// INPUT POLARITY PORT REGISTER 0
#define IPOL1 0x05		// INPUT POLARITY PORT REGISTER 1
#define IODIR0 0x06		// I/O DIRECTION REGISTER 0
#define IODIR1 0x07		// I/O DIRECTION REGISTER 1
#define INTCAP0 0x08	// INTERRUPT CAPTURE REGISTER 0
#define INTCAP1 0x09	// INTERRUPT CAPTURE REGISTER 1
#define IOCON0 0x0A		// I/O EXPANDER CONTROL REGISTER 0
#define IOCON1 0x0B		// I/O EXPANDER CONTROL REGISTER 1

// BLOCK VARIABLE REGISTER
unsigned char MCP23016_Device_Address; // MCP23016 Assigned Device Address.
int GPIO_port; // MCP23016 Data Port Register.

// MCP23016 - I2C constants for selecting type of data transfer.
#define I2C_MCP23016_GP0_READ 0x9F		// 1001 1111
#define I2C_MCP23016_GP0_WRITE 0x9E		// 1001 1110
#define I2C_MCP23016_GP1_READ 0x9F		// 1001 1111
#define I2C_MCP23016_GP1_WRITE 0x9E		// 1001 1110

void write2Expander(unsigned char WriteAddress, unsigned char cmdByte, unsigned char lsbData, unsigned char msbData)
{
	short int status;
	
	i2c_start(); // start condition
	delay_us(20);
	i2c_write(WriteAddress); // Send slave address and clear (R/W_)
	delay_us(20);
	i2c_write(cmdByte); // Command byte and register to be written.
	delay_us(20);
	i2c_write(lsbData); // First data byte pair as per command byte(cmd)
	delay_us(20);
	i2c_write(msbData); // Second data byte pair as per command byte(cmd)
	delay_us(20);
	i2c_stop(); // stop condition
	delay_us(50); // delay to allow write (12us)min.

}

unsigned char readExpander(unsigned char WriteAddress, unsigned char ReadAddress, unsigned char cmdByte)
{
	unsigned char Data,	lsbData, msbData;
	short int status,count;

	startRead:
	count=0; //	Initialize read	attempts counter.

	i2c_start(); //	start condition
	i2c_write(WriteAddress); //	Send slave address and clear (R/W_)
	i2c_write(cmdByte);	// Command byte	and	register to	be written.
	i2c_start(); //	restart	condition
	i2c_write(ReadAddress);	// Send	slave address and clear	(R_/W)
	lsbData	= i2c_read(1); // Data from	LSB	or MSB of register
	msbData	= i2c_read(0); // Data from	MSB	or LSB of register
	i2c_stop();	// stop	condition
	delay_us(50); // delay to allow	read (12us)min.

	// There is	no limitation on the no. of	data bytes in one read transmission, so	wait until all is read.
	i2c_start(); //	restart	condition
	status=i2c_read(1);
	while(status==1)
	{
		i2c_start(); // restart condition
		status=i2c_read(1); // force reading

		// Otherwise start reading process all over again after 100 read attempts
		if (status==1 && count==100 )
		goto startRead; // timeout restart
		count+=1;
	}

	// Combine two 8-bit data lengths into one 16-bit word length as a return value.
	combiner:
	data=lsbData;
	data=data*9;
	if((msbData&0x80)!=0)
	data=data+4;

	data=(data/5)+32;
	msbData=data;

	return(msbData); // return read value
}

void init_mcp23016(unsigned char MCP23016_Device_Address)
{
	// Wait for MCP23016 Expander Device to power-up.
	delay_ms(250);
	delay_ms(250);
	delay_ms(250);

	// Set-up selected I/O expander unit
	//write2Expander(MCP23016_Device_Address, IPOL0, 0xFF, 0xFF); // Invert all input polarities if active low.
	//write2Expander(MCP23016_Device_Address, IPOL1, 0xFF, 0xFF); // Invert all input polarities if active low.
	write2Expander(MCP23016_Device_Address, IPOL0, 0x00, 0x00); // NonInvert all input polarities if active low.
	write2Expander(MCP23016_Device_Address, IPOL1, 0x00, 0x00); // NonInvert all input polarities if active low.

	write2Expander(MCP23016_Device_Address, IOCON0, 0x01, 0x01); // IARES(1) to max. activity detection time.
	write2Expander(MCP23016_Device_Address, IOCON0, 0x01, 0x01); // IARES(1) to max. activity detection time.

	write2Expander(MCP23016_Device_Address, IODIR0, 0x00, 0x00); // Direction of all data is output.
	write2Expander(MCP23016_Device_Address, IODIR1, 0x00, 0x00); // Direction of all data is output.

	write2Expander(MCP23016_Device_Address, OLAT0, 0xFF, 0xFF); // Update o/p latch that controls the output.
	write2Expander(MCP23016_Device_Address, OLAT1, 0xFF, 0xFF); // Update o/p latch that controls the output.
} 