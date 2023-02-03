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
			EXTERN 		OutChar
		
__main 		PROC
			BL			PortBE_init

; R5 IS A ADDRESS OF INPUT OF THE KEYPAD
; R1 IS A ADDRESS OF INPUT OF THE ARM	

loop		LDR 		R1, =PB_OUT		; PB[7:4] TAKE INPUT FROM THAT PORTS TO CHECK WHETHER L1,L2,L3,L4 ANY OF ONE BECOMES ZERO 0
No_pressed 	LDR			R5, =PB_INP
			MOV			R6, #0x00		; INITIALLY MAKE ALL ROWS ZERO TO CHECK ANY BUTTON IS PRESSED
			STR			R6, [R5]
			
			LDR 		R0, [R1]		; IF NO BUTTON IS PRESSED, THEN VALUE INSIDE R0 WILL BE 0xF0. Otherwise it will be less than 0xF0.
			AND			R0, #0xF0		; REMOVE LSB OF R0. EQUALIZE THEM TO 0 TO MAKE COMPARISON MORE EASY.
			CMP 		R0, #0xF0
			MOV			R3, R0          ; Copy your readed data inside another register. 
			BEQ			No_pressed
			
			BL			DELAY
			
			LDR 		R0, [R1]		; IF NO BUTTON IS PRESSED, THEN VALUE INSIDE R0 WILL BE 0xF0. Otherwise it will be less than 0xF0.
			AND			R0, #0xF0		; REMOVE LSB OF R0. EQUALIZE THEM TO 0 TO MAKE COMPARISON MORE EASY.
			CMP 		R0, #0xF0
			MOV			R9, R0          ; Copy your readed data inside another register. 
			BEQ			No_pressed
			
			CMP 		R3, R9          ; CHECK VALUES THAT ARE TAKEN AT DIFFERENT TIMES FROM DATA REGISTER
			BEQ 		pass            ; IF THEY ARE SAME, DEBOUNCING IS PREVENTED. 
			BNE			No_pressed
			
pass		MOV 		R4, #0xEF       ; 0x11101111 WILL BE SHIFTED TO RIGHT BY ONE TO FIND ROW
			
shift		LSR			R4, #1          ; SHIFT BY 1
			STR			R4, [R5]
			
			NOP
			NOP
			NOP
			
			LDR 		R0, [R1]
			AND			R0, #0xF0
			CMP 		R0, #0xF0
			MOV			R3, R0          ; Copy your readed data inside another register. 
			BEQ			shift           ; IF IT IS STILL 11110000 NO BUTTON PRESSED
			B			cont
			
cont		LSR 		R0, #4    		; SHIFT R0 BY 4 TO MAKE CALCULATIONS EASY
			MVN			R0, R0			; GIVES US THE COLUMN NUMBER
			AND			R0, #0x0F
			MVN			R4, R4          ; GIVES US THE ROW NUMBER
			AND 		R4, #0x0F		; IN ORDER TO RESET [7:4] BITS OF R4

; Check Corresponding Row Number
			MOV 		R7, #0			; R7 WILL BE COUNTER FOR ROW NUMBER
row_num     LSR			R0, #1
			CMP			R0, #0x0
			BEQ			move_r8
			ADD			R7, #1			; Row number
			BNE			row_num

; Check Corresponding Column Number
move_r8		MOV 		R8, #0			; R8 WILL BE COUNTER FOR COLUMN NUMBER
column_num	LSR			R4, #1			;SHIFT BY 1 FIRST
			CMP			R4, #0x0
			BEQ			result
			ADD			R8, #1			; Column number
			BNE			column_num
			
result		MOV			R9, #4			; TO MULTIPLY ROW BY 4 --> BUTTON ID = ROW*4 + COLUMN
			MUL			R7, R7, R9
			ADD			R9, R8, R7  	; Store value of the pressed button at R8
			CMP			R9, #0x9
			ADDLS 		R0, R9, #0x30
			ADDHI		R0, R9, #0x37
			BL			OutChar			
	
; Check whether button is released or not
release		LDR			R5, =PB_INP
			MOV			R6, #0x00
			STR			R6, [R5]
			
			BL			DELAY		
			
first_check LDR 		R1, =PB_OUT	
			LDR 		R0, [R1]
			AND			R0, #0xF0
			CMP 		R0, #0xF0
			BNE			release
			BL			DELAY
			BEQ			sec_check
			
			
sec_check   LDR 		R1, =PB_OUT	
			LDR 		R0, [R1]
			AND			R0, #0xF0
			CMP 		R0, #0xF0
			BNE			first_check
			BL			DELAY
			BEQ			loop
; END OF BUTTON RELEASE CHECK			

			ENDP
			ALIGN
			END
				