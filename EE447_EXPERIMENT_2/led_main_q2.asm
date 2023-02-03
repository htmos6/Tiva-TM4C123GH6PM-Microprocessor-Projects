GPIO_PORTB_DATA 	EQU 		0x400053FC 		; data a d d r e s s t o a l l pi n s
PB_INP 				EQU 		0x4000503C		; MPU OUTPUT, KEYPAD INPUT, LEDs B[3:0]
PB_OUT 				EQU 		0x400053C0		; MPU INPUT, KEYPAD OUTPUT, status of the push buttons B[7:4] --> input for the MCU 
												; Pulled up by resistors
 
; Register B default data address is 0x40005000 
; If you want to read just 0-3 bits read 0x400053C0	that adress

;***************************************************************
; Program section
;***************************************************************
;LABEL 		DIRECTIVE 	VALUE 		COMMENT
			AREA 		main , READONLY, CODE
			THUMB
			IMPORT 		PortBE_init
			IMPORT		DELAY
			EXPORT 		__main
		
__main 		PROC
			BL			PortBE_init
loop		
			LDR 		R1, =PB_OUT		; if no key is pressed, input f0

loop_c 		LDR 		R0, [R1] 		; pressed button is 0, other buttons 1
										; Normally pressed button is 0 and others 1. 
										; But in our case, pressed buttons are 1. 
										; Take reverse of the readed data. 
			MVN			R0, R0			; only the pressed button is 1, others 0
			
			AND 		R2,R0,#0xF0 	; check if any switch is pressed
			LSR			R2, R2, #4		; Shift right register2 since it will be sent as an output of the microcontroller. 
										; It will be loaded to the 0x4000503C address.  B[3:0]
										; Method is simple. Check changed bits and they are denoted as 1. 
										; Send them to LEDS. However do we need to change again back to 0 position to light on LEDs. 
										; LEDs lights on when low signal is applied. 
			
			MVN 		R2, R2	
										
			; Bitwise complement of the R2 ? 
display 	LDR			R1, =PB_INP	
			STR			R2, [R1]
			B			loop_d
			
			
			
			
		
loop_d		BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY
			BL			DELAY			;3s delay   20*150ms
			B			loop

			ENDP
			ALIGN
			END
				