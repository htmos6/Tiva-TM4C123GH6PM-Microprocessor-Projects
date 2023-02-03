#include "TM4C123GH6PM.h"
int dir;   //clockwise = 0, counterclockwise = 1
int led_number;
int index;

extern void SysTick_Handler(void);
extern void GPIOB_Handler (void);

void init_func(void);
void init_SysTick(unsigned time);

int main ( ) {
	init_func(); // Configure ports as input/output/den/amsel/afsel/pctl registers etc.
	init_SysTick(32000000); // start systick_timer with 3s value
	dir = 1;
	led_number = 1;
	
	GPIOB -> DATA &= 0xF0;   // Reset pins 0-3 so that you will start with no led is turned on
	GPIOB -> DATA |= 0x08;   //1000, initial value. Turn on led 1
	
	
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
	GPIOB -> DIR |= 0x0F;    //PortB pins 0 to 3 set output
	GPIOB -> DIR &= 0x0F;    //PortB pins 4 to 7 set input
	GPIOB -> DEN |= 0xFF;
	GPIOB -> AFSEL &= 0x00;   //no alternate function
	GPIOB -> PCTL &= 0x00;
	GPIOB -> AMSEL &= 0x00;
	
	//INTERUPT CONFIGURATIONS FOR PUSH BUTTONS
	
}

void init_SysTick(unsigned time){	
	SysTick -> CTRL = 0x0;		//Disable systick
	SysTick -> LOAD = time-1; // 2s delay
	
	SysTick -> CTRL = 7;
	SysTick -> VAL = 0;	
}

void GPIOB_Handler (void){
		
}

