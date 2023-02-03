#include "TM4C1231H6PM.h"
uint32_t result;
uint32_t resultADCread;
int resultForQ2;

// Pre declerations of the functions
uint32_t readADC(void);
void initializationOfADC0(void);

volatile int* myVal = (volatile int*) 0x20000700; // Keep input value inside pre-declared address to check it from memory location directly.
volatile int* myVal2_signed_Q2 = (volatile int*) 0x20000720; 

// Initialize ADC0 SS3 && PORTE->3
void initializationOfADC0(void)
{
  // Configurations of the PE3 as analog input
	SYSCTL->RCGCGPIO |= 0x10;     // Enable clock for Port E
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	GPIOE->DIR &= ~0x08u;
	GPIOE->AMSEL |= 0x08u;   			// Enable analog on PE3
	GPIOE->AFSEL |= 0x08u;   			// Enable alternate function on PE3
  GPIOE->DEN &= ~0x08u;    			// Disable digital on PE3
	
	// Configure ADC0
	SYSCTL->RCGCADC |= 0x0001;		// Enable clock to ADC0
	while(SYSCTL->PRADC == 0);
  ADC0->ACTSS &= ~0x0008u;      // Disable SS3 for configuration
  ADC0->EMUX &= ~0xF000u;       // Processor trigger adjustment
  ADC0->SSMUX3 &= ~0x000Fu;     //clear bits 3:0 to select AIN0
  ADC0->SSCTL3 |= 0x0006u;      //set bits 2:1 (IE0, END0) IE0 is set since we want RIS to be set
  ADC0->IM |= 0x0008u;          // Enable SS3 interrupt
	ADC0->PC = 0x1u; 						  // Set bits 0:3 to 0x1 for 125k sps
  ADC0->ACTSS |= 0x0008u;       // Enable ADC0 SS3
}


// Read 12-bit value from ADC0
uint32_t readADC(void)
{
  ADC0->PSSI |= 0x0008;            // Initiate SS3
  while((ADC0->RIS & 0x08) == 0)   // Wait for conversion to complete
	{} 
		
  resultADCread = ADC0->SSFIFO3 & 0xFFF; // Read 12-bit result
  ADC0->ISC |= 0x0008;            // Clear interrupt
	*myVal = (int) resultADCread;
	return resultADCread;
}


int main(void)
{
  // Call initialize function for ADC initialization
	initializationOfADC0();

	while (1) // Read ADC input at always
	{
		result = readADC();    // Read 12-bit input value and store it inside result variable at location  
													 //	volatile int* myVal = (volatile int*) 0x20000700;
		resultForQ2 = (int)	result - 2048; // analog number that corresponds to a offset = 1.65 --> 
		*myVal2_signed_Q2 = resultForQ2; // myVal2_signed_Q2 value changes from -2048 to 2048
	}

	return 0;
}