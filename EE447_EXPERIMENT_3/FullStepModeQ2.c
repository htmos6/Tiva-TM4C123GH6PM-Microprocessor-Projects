#include "TM4C123GH6PM.h"
int dir;   //clockwise = 0, counterclockwise = 1
int led_number; 
int index;
int pressed_temp;

extern void SysTick_Handler(void);
extern void GPIOB_Handler (void);

void init_func(void);
void init_SysTick(unsigned time);

int main ( ) {
	init_func();
	init_SysTick(32000000);
	dir = 1;
	led_number = 1;
	
	GPIOB ->DATA &= 0xF0;   // Clear values that are sent to Step Motor. 
	GPIOB ->DATA |= 0x08;   //1000, initial value that are sent to step motor. 
	
	while (1) 
	{}
}

void SysTick_Handler(void)
{
	
	if(dir == 0)
	{ //clockwise
		if(led_number != 4)
		{
			led_number += 1;
		}
		else 
		{
			led_number = 1;
		}	
	}
	else
	{//counterclockwise
		if(led_number != 1)
		{
			led_number -= 1;
		}
		else 
		{
			led_number = 4;
		}	
	}
	
	index = 4 - led_number ;			//find the corresponding index in the data register
	GPIOB -> DATA &= 0xF0; // Reset corresponding output pins of the data register
	GPIOB -> DATA |= (1 << index); // Set corresponding 1 of the pin as 1 successively
	
}

void init_func(void){
	SYSCTL -> RCGCGPIO |= 0x02;  // PortB
	//NOP
	GPIOB -> DIR &= 0x00;    //PortB pins 4 to 7 input
	GPIOB -> DIR |= 0x0F;    //PortB pins 0 to 3 output
	
	GPIOB -> DEN |= 0xFF;
	GPIOB -> AFSEL &= 0x00;   //no alternate function
	GPIOB -> PCTL &= 0x00;
	GPIOB -> AMSEL &= 0x00;
	GPIOB -> PUR |= 0xF0; // Set outputs as PULL UP REGISTER
	
	
	//INTERUPT CONFIGURATIONS FOR PUSH BUTTONS
	GPIOB -> IS = 0;
	GPIOB -> IBE = 0xF0;
	GPIOB -> IM = 0xF0;
	
	NVIC->IP[1] = 3 << 5; // Set priority as 3
  NVIC->ISER[0] |= (1<<1); 

	GPIOB -> ICR = 0xF0; // Clear interrupt register. 
	
}

void init_SysTick(unsigned time){	
	SysTick -> CTRL = 0x0;		//Disable systick
	SysTick -> LOAD = time-1;		// 2s delay
	
	SysTick ->CTRL = 7; // Enable Systick
	SysTick -> VAL = 0;	
}

void GPIOB_Handler (void){ // When interrupt comes from push buttons, handle with it. 
	int data = GPIOB -> DATA;
	int data2;
	data &= 0xF0;	//clear step motor's input bits. Bits [7:4] will provides us a pressed button value. 
	data = (data >> 4); 
	
	if(data != 0xF)
	{	
		data2 = GPIOB -> DATA; // Read data register again. Compare it with previous value to prevent debouncing. 
		data2 &= 0xF0;				 //clear the step motor output bits
		data2 = (data2 >> 4);
		
		if(data == data2) //no bouncing
		{
			switch(data) 
			{
				case 14: //1110 PINB4 //clockwise 0
					pressed_temp = 0;	// Store pressed button inside temp. value. Equalize & change direction when button is released. 			
					break;
				case 13: //1101 PINB5 //counterclockwise 1
					pressed_temp = 1; // Store pressed button inside temp. value. Equalize & change direction when button is released. 
					break;
			}			
		}
	}
	else{
		data2 = GPIOB -> DATA;
		data2 &= 0xF0;			//clear the step motor output bits
		data2 = (data2 >> 4);
		
		if(data == data2)
		{
				dir = pressed_temp;		
		}
	}
	
	GPIOB -> ICR = 0xF0; // clear interrupt so that next interrupt can be differentiated easily. 
}
