#include "Pulse_init.h"
#include <stdio.h>
#include <string.h>
extern void OutStr ( char * ) ;

int main()
{
	pulse_init();
	
	// initialize PB4 as input
	SYSCTL->RCGCGPIO |= 0x2; // turn on bus clock for GPIOB
	GPIOB->DIR			&= ~(0x10u); //set PB4 as input
  GPIOB->AFSEL		|= (0x10);  // port function
	GPIOB->PCTL			&= 0xFFF0FFFF;  // alternate function
	GPIOB->PCTL			|= 0x70000;  // alternate function
	GPIOB->AMSEL		=0; //Disable analog
	GPIOB->DEN			|=0x10; // Enable port digital
	

	//TIMER1 Configurations
	SYSCTL->RCGCTIMER	|=0x02; // Start timer1
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	TIMER1->CTL			&=0xFFFFFFFE; //Disable timer during setup
	TIMER1->CFG			=0x04;  //Set 16 bit mode
	TIMER1->TAPR		=15; // Divide the clock by 16 to get 1us
	TIMER1->TAMR		=0x17; // set to capture, count up, edge time.
	TIMER1->TAILR		=0xFFFF; //Set interval load TO MAX NUMBER
	TIMER1->IMR			=0x0; //disable timeout intrrupt	
	TIMER1->ICR     =0x4; //Clear interrupt register event
	TIMER1->ICR     =0x1; //Clear interrupt register timeout
	
	TIMER1->CTL     =0x1; // ENABLE TIMERA, RISING EDGE EVENT MODE.
	//TIMER1->CTL     =0xD; // ENABLE TIMERA, BOTH EDGE EVENT MODE.
	

	unsigned int time1=0, time2=0, time3=0;
	unsigned int highTime = 0, lowTime = 0;
	unsigned int period = 0, duty_cycle = 0, pulse_width = 0;
	char str[150];

	while(1)
	{
		TIMER1 ->CTL &= ~(0xCu);			//rising edge
		
		while ((TIMER1->RIS & 0x4u) == 0x0)		
		{// Wait until edge is captured
		}
					
		/*
		
		if (!(GPIOB->DATA & 0x10u))		//if my data is 0, falling edge happened
		{
			TIMER1 ->ICR &= 0x4;
			while (TIMER1->RIS & 0x4 == 0x0)		
			{// Wait until rising edge is captured. 
			}			
		}
		*/
		
		// TIME 1 PART
		//now signal is high 
		time1 = TIMER1 -> TAR; // STORE START TIME OF THE RISING EDGE
		
		
		TIMER1 ->CTL &= ~(0xCu);
		TIMER1->CTL   |= 0x4;			// FALLING EDGE EVENT MODE.
		TIMER1 ->ICR |= 0x4;   // CLEAR INTERRUPT REGISTER
		
		/*
		sprintf(str, "Timer1: %u\n%c ", time1 ,0x04);
		OutStr(str);
		*/
		
		// TIME 2 PART
		while ((TIMER1->RIS & 0x4U) == 0x0)		
		{// Wait until falling edge is captured. If edge is captured, Raw interrupt register's flag is settled. 
		}			
		
		//now signal is LOW
		time2 = TIMER1->TAR;		// Store time when falling edge is occcured. 
		
		TIMER1 ->CTL &= ~(0xCu);		//rising edge
		TIMER1 -> ICR |= 0x4;   // CLEAR INTERRUPT REGISTER
		
		
		//highTime = time2 - time1;
		
		
		
	  if(TIMER1 -> RIS & 0x1 == 1) { // Time out flag is settled.
			highTime = 0xFFFF - time1 + time2;	
			
		}
		else {
			highTime = time2 - time1;
		}
		TIMER1 -> ICR = 0x1;
		
		
		
		//TIMER1 ->CTL &= ~(0xCu);
		
		// TIME 3 PART
		while ((TIMER1->RIS & 0x4) == 0x0)		
		{// Wait until falling edge is captured. If edge is captured, Raw interrupt register's flag is settled. 
		}			
		
		//now signal is LOW
		time3 = TIMER1->TAR;		// Store time when falling edge is occcured. 
		TIMER1 -> ICR |= 0x4;   // CLEAR INTERRUPT REGISTER
		
		//lowTime = time3 - time2;
		
		
		
		if(TIMER1 -> RIS & 0x1 == 1) { // Time out flag is settled.
			lowTime = 0xFFFF - time2 + time3;	
		}
		else {
			lowTime = time3 - time2;
		}
		TIMER1 -> ICR = 0x1;
		
		
		//highTime and lowTime are in terms of cycles
		//calculate duty cycle, pulse width and period
		
		duty_cycle = ((highTime*100)/(highTime + lowTime));			//in percentage
		period = (highTime + lowTime) ;			//in us
		pulse_width = highTime ;						//in us
		
		
		
		sprintf(str, "Period: %u Duty Cycle: %u Pulse Width: %u \n %c", period, duty_cycle, pulse_width ,0x04);
		OutStr(str);
		
	}
}