GPIO_PORTB_DATA 		EQU 		0x400053FC ; data a d d r e s s t o a l l pi n s
GPIO_PORTB_DIR 			EQU 		0x40005400
GPIO_PORTB_AFSEL 		EQU 		0x40005420
GPIO_PORTB_DEN 			EQU 		0x4000551C
IOB 					EQU 		0x0F
GPIO_PORTE_DATA 		EQU 		0x400243FC ; data a d d r e s s t o a l l pi n s
GPIO_PORTE_DIR 			EQU 		0x40024400
GPIO_PORTE_AFSEL 		EQU 		0x40024420
GPIO_PORTE_DEN 			EQU 		0x4002451C
IOE 					EQU 		0x00
SYSCTL_RCGCGPIO 		EQU 		0x400FE608
; CONFIGURATION FILE FOR QUESTION 2
;PUR O f f s e t 0 x 5 1 0
GPIO_PORTB_PUR 			EQU 		0x40005510 ;PUR a c t u al a d d r e s s
PUB 					EQU 		0xF0 ; o r #2 1 1 1 1 0 0 0 0
	
						AREA 		text , READONLY, CODE, ALIGN=2
						THUMB
						EXPORT 		PortBE_init
							
PortBE_init 			PROC
						PUSH		{R1, R0, LR}
						LDR 		R1 , =SYSCTL_RCGCGPIO
						LDR 		R0 , [ R1 ]
						ORR 		R0 , R0 , #0x12   ; clock of port B and E
						STR 		R0 , [ R1 ]
						NOP
						NOP
						NOP ; l e t GPIO cl o c k s t a b i l i z e

						LDR 		R1 , =GPIO_PORTB_DIR 			; c o n f i g . o f p o r t B s t a r t s
						LDR 		R0 , [ R1 ]
						BIC 		R0 , #0xFF
						ORR 		R0 , #IOB						; (B3 to B0) for outputs, and (B7 to B4) for inputs.
						STR 		R0 , [ R1 ]			
						
						LDR 		R1 , =GPIO_PORTB_AFSEL
						LDR 		R0 , [ R1 ]
						BIC 		R0 , #0xFF
						STR 		R0 , [ R1 ]
						
						LDR 		R1 , =GPIO_PORTB_DEN
						LDR 		R0 , [ R1 ]
						ORR 		R0 , #0xFF
						STR 		R0 , [ R1 ] ; c o n f i g . o f p o r t B ends	

						LDR 		R1 , =GPIO_PORTE_DIR ; c o n f i g . o f p o r t E s t a r t s
						LDR 		R0 , [ R1 ]
						ORR 		R0 , #IOE
						STR 		R0 , [ R1 ]
						
						LDR 		R1 , =GPIO_PORTE_AFSEL
						LDR 		R0 , [ R1 ]
						BIC 		R0 , #0xFF
						STR 		R0 , [ R1 ]
						
						LDR 		R1 , =GPIO_PORTE_DEN
						LDR 		R0 , [ R1 ]
						ORR 		R0 , #0xFF
						STR 		R0 , [ R1 ] ; c o n f i g . o f p o r t E ends


; assume c o n f i g s . ’ ve done
						LDR 		R0 , =GPIO_PORTB_PUR
						MOV 		R1 , #PUB             ; B7-B4 will be input. So, upload pull up resistor address. Set corresponding bits to 1. 
						STR 		R1 , [ R0 ]
						
						POP			{R1, R0, LR}
						BX 			LR
						
						ENDP
						END
