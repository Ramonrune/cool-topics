/**********************************************************************
* © 2005 Microchip Technology Inc.
*
* FileName:        PFC Project.c
* Dependencies:    Header (.h) files if applicable, see below
* Processor:       dsPIC30Fxxxx
* Compiler:        MPLAB® C30 v3.00 or higher
*
* SOFTWARE LICENSE AGREEMENT:
* Microchip Technology Incorporated ("Microchip") retains all ownership and
* intellectual property rights in the code accompanying this message and in all
* derivatives hereto.  You may use this code, and any derivatives created by
* any person or entity by or on your behalf, exclusively with Microchip,s
* proprietary products.  Your acceptance and/or use of this code constitutes
* agreement to the terms and conditions of this notice.
*
* CODE ACCOMPANYING THIS MESSAGE IS SUPPLIED BY MICROCHIP "AS IS".  NO
* WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
* TO, IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
* PARTICULAR PURPOSE APPLY TO THIS CODE, ITS INTERACTION WITH MICROCHIP,S
* PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.
*
* YOU ACKNOWLEDGE AND AGREE THAT, IN NO EVENT, SHALL MICROCHIP BE LIABLE, WHETHER
* IN CONTRACT, WARRANTY, TORT (INCLUDING NEGLIGENCE OR BREACH OF STATUTORY DUTY),
* STRICT LIABILITY, INDEMNITY, CONTRIBUTION, OR OTHERWISE, FOR ANY INDIRECT, SPECIAL,
* PUNITIVE, EXEMPLARY, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, FOR COST OR EXPENSE OF
* ANY KIND WHATSOEVER RELATED TO THE CODE, HOWSOEVER CAUSED, EVEN IF MICROCHIP HAS BEEN
* ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.  TO THE FULLEST EXTENT
* ALLOWABLE BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO
* THIS CODE, SHALL NOT EXCEED THE PRICE YOU PAID DIRECTLY TO MICROCHIP SPECIFICALLY TO
* HAVE THIS CODE DEVELOPED.
*
* You agree that you are solely responsible for testing the code and
* determining its suitability.  Microchip has no obligation to modify, test,
* certify, or support the code.
*
* REVISION HISTORY:
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Author            Date      Comments on this revision
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Vinaya Skanda     12/12/07  First release of source file
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* ADDITIONAL NOTES:
* This code is tested on Explorer 16 Development Board with Motor Control Interface PicTail Plus Daughter
* board connected to the High Voltage Power Module. The dsPIC33F device is used as the controller for this application */

//***************************************************************************************************************************//

// Header files //

#include "General.h"


//***************************************************************************************************************************//

// Configuration Fuse Settings

_FPOR( PWMPIN_ON & HPOL_ON & LPOL_ON  & ALTI2C_OFF & FPWRT_PWR128)
_FWDT( FWDTEN_OFF & WINDIS_OFF)
_FOSC( FCKSM_CSECMD & IOL1WAY_OFF & POSCMD_NONE )
_FOSCSEL( FNOSC_FRCPLL )
_FGS( GSS_OFF & GCP_OFF & GWRP_OFF )
_FBS( BWRP_WRPROTECT_OFF )
//_FICD( JTAGEN_OFF & ICS_PGD3 )

//***************************************************************************************************************************//

// Global Variable Declaration

volatile unsigned int PowerOnDelay = 100;		// 125ms delay for charging caps at 40kHz sampling
volatile unsigned int SumVacLow,SumVacHigh = 0x009E;						
volatile int SumVacHighMinimum = 0x0024, SampleCountMin = 300;				// Initialize minimum values for SumVacHigh and SampleCount
volatile unsigned int AverageVac;
volatile unsigned int VpiCount=0,IrefCount=0;								// Initialize counts for running Vpi and Iref loops
volatile unsigned int SampleCount = SamplingFrequency/(2*NominalFrequency);	// Initialize sample count


//***************************************************************************************************************************//

// Main Function //

int main ( void )
{


// Configure Oscillator to operate the device at 40Mhz
// Fosc= Fin*M/(N1*N2), Fcy=Fosc/2
// Fosc= 7.375M*33/(2*2)=60Mhz for 8M input clock
// Fcy = 30MHz



	PLLFBD=2;//43;				// M=33
	CLKDIVbits.PLLPOST=0;	// N1=2
	CLKDIVbits.PLLPRE=0;		// N2=2
	//OSCTUN=0;					// Tune FRC oscillator, if FRC is used
	
    SetupPorts();                               // Initialize all the GPIO ports
	SetupBoard();								// Setup the board by clearing all faults

    configPWM2();                       		// Configure the PWM2 Module
    configADC();                                // Configure the ADC Module

    IFS0bits.AD1IF = 0;                         // Clear ADC Interrupt Flag
    IEC0bits.AD1IE = 1;                         // Enable ADC Interrupts


    P2TCONbits.PTEN = 1;                     	// Start generating the PWM outputs

    while(1);                                   // Loop Infinitely

}


//***************************************************************************************************************************//


void SetupBoard( void )
{

    unsigned char b;
    pinFaultReset = 1;              // Reset all fault states to default
    for(b=0;b<10;b++)
        Nop();
    pinPFCFire = 0;                 // Disable PFC MOSFET gate pulses
    pinFaultReset = 0;              // Activate all faults

}

//***************************************************************************************************************************//


// Delay Function for power-ON delay //
// 125ms delay is provided for capacitors to charge to the DC Bus Voltage //

void Delay(void)
{
    PowerOnDelay--;                 // Decrement PowerOnDelay counter
    calcVsumAndFreq();              // Calculation of Vsum and Frequency of input AC Voltage
}

//***************************************************************************************************************************//

// ADC Interrupt Service Routine //


void __attribute__((interrupt , auto_psv)) _ADC1Interrupt(void)

{

    IFS0bits.AD1IF = 0;            				 // Clear ADC Interrupt Flag

	
    if(PowerOnDelay != 0)    					 // Check for PowerOnDelay Flag condition
    {
        Delay();             					 // Call Power-ON Delay Subroutine
    }

    else
    {
		LATBbits.LATB13 = 1;						 // Monitor the control loop frequency and execution time


        //  if(VpiCount == 0)
        //  {
        //      VpiCount = 4;					// To run the Voltage PI controller at lower frequency
        	
				VoltagePIControl();             // Voltage Error Compensator

        //  }

        //  if(IrefCount == 0)
        //  {
        //      IrefCount = 2;					// To run the Current Reference Calculation at lower frequency
        	
				calcIacRef();                   // Calculation of Current Reference
        //  }


        CurrentPIControl();             		// Current Error Compensator
        calcVsumAndFreq();             			// Calculation of Vsum and Frequency of input AC Voltage

        //  VpiCount--;							// Decrement the Vpi calculation counter
        //  IrefCount--;						// Decrement the Iref calculation counter

		LATBbits.LATB13 = 0;						 // Monitor the control loop frequency and execution time

    }
}

//***************************************************************************************************************************//

// Configure the A to D Converter

void configADC(void)

{

    AD1CON1 = 0;
    AD1CON1bits.FORM = 3;            // Signed Fractional Results
	 AD1CON1bits.AD12B = 0;			    // Configured for 10 bit operation
    AD1CON1bits.SSRC = 5;            // MC PWM2 module to trigger ADC
    AD1CON1bits.SIMSAM = 1;          // Simultaneous Sampling enabled
    AD1CON1bits.ASAM = 1;            // Auto Sampling enabled

    AD1CON2 = 0;
    AD1CON2bits.CHPS = 3;            // Convert CH0, CH1, CH2 and CH3
    AD1CON2bits.SMPI = 1;            // Interrupt on second sample/convert sequence
    AD1CON2bits.CSCNA = 1;           // Channel Scanning Enabled

    AD1CON3bits.SAMC = 8;			    // Auto-Sample time = 8*Tad
    AD1CON3bits.ADCS = 4;            // AD Conversion time = 8*Tcy

	 AD1CHS0bits.CH0NA = 0;           // Channel CH0 negative reference is Vref-

    AD1CHS123bits.CH123NA = 0;       // Channels CH1, CH2 and CH3 negative reference is Vref-
    AD1CHS123bits.CH123SA = 1;       // Convert AN3, AN4 and AN5 on CH1, CH2 and CH3 positive reference respectively

    AD1PCFGL = 0xFFFF;
    AD1PCFGLbits.PCFG2 = 0;          // AN2 pin in analog mode used for Vdc (ADCBUF0)
    AD1PCFGLbits.PCFG3 = 0;          // AN3 pin in analog mode used for Iac (ADCBUF1/5)
    AD1PCFGLbits.PCFG4 = 0;          // AN4 pin in analog mode used for Vac (ADCBUF4)
	 AD1PCFGLbits.PCFG5 = 0;          // AN4 pin in analog mode used for Vac (Don't Care)


    AD1CSSL = 0;
	 AD1CSSLbits.CSS2 = 1;
 	 AD1CSSLbits.CSS4 = 1;
   
	 AD1CON1bits.ADON = 1;            // Turn-ON the ADC Module

}

//***************************************************************************************************************************//

// Configure the PWM2 Module
	/* 
	
	; PWM2 Module Configuration
	; PWM Period = (P2TPER + 1)* Tcy * (P2TMR Prescaler)
	; P2DC1 Updates PWM Duty Cycle
	; P2TPER gives PWM period
	
	; For a PWM frequency of 80KHz, set P2TPER = d#499		*/


void configPWM2(void)
{

	P2TCON = 0x0000;				// Clear the registers for reset values
	P2TMR = 0x0000;

	P2TPER = PWM_PERIOD;					//	The period value corresponds to a frequency of 80kHz

	P2SECMPbits.SEVTCMP = PWM_PERIOD;		//	Special Event Trigger for ADC is at PWM Timer reset
	PWM2CON1bits.PMOD1 = 1;			//	Independent Mode of PWM operation is selected
	PWM2CON1bits.PEN1H = 1;			//	PWM output pin is enabled for PWM output
	
	PWM2CON2 = 0x0000;
	PWM2CON2bits.SEVOPS = 0;		//  Trigger ADC on every PWM cycle
	PWM2CON2bits.IUE = 1;			//	Immediate updates of duty cycle is enabled
	
	P2OVDCONbits.POVD1H = 1;		//	PWM Output pin is controlled by PWM Generator 
	P2DC1 = 0;

	IFS4bits.PWM2IF = 0;			// Clear the PWM2 interrupt flag
	IEC4bits.PWM2IE = 0;			// Enable/Disable PWM2 interrupts

}



//***************************************************************************************************************************//

// PWM2 Interrupt Service Routine //

void __attribute__((__interrupt__ , auto_psv)) _MPWM2Interrupt(void)
{

IFS4bits.PWM2IF = 0;					// Clear PWM2 interrupt flag

}


//***************************************************************************************************************************//

//  Math Error Trap ISR

void __attribute__((__interrupt__ , auto_psv)) _MathError(void)
{
    //  INTCON1bits.MATHERR = 0;
    while(1);
}

//***************************************************************************************************************************//

//  Address Error Trap ISR

void __attribute__((__interrupt__ , auto_psv)) _AddressError(void)

{
    //  INTCON1bits.ADDRERR = 0;
    while(1);
}

//***************************************************************************************************************************//

//  Stack Error Trap ISR

void __attribute__((__interrupt__ , auto_psv)) _StackError(void)

{
    //  INTCON1bits.STKERR = 0;
    while(1);
}

//***************************************************************************************************************************//
