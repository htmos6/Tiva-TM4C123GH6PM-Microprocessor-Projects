;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		upbnd, READONLY, CODE
            THUMB
			IMPORT		InChar
			IMPORT 		OutStr
			EXPORT		CONVRT
				
			
			; CONVRT FUNCTION BEGINS
CONVRT 		PROC
			PUSH		{R0,R1,R2,R3,R5,R6,LR}
			;R0 --> COUNTER
			;R1 --> COPY R4 VALUE TO MODIFY IT WITHOUT CHANGING ORIGINAL
			;R2 --> STORE QUOTIENT (TAM BOLUM)
			;R3 --> STORE REMAINDER --> 123 --> 3,2,1 STORES SUCCESSIVELY
			;R6 --> SET TO 10 FOR DIVISION
			MOV 		R0, #0  ; Reset counter at every time subroutine is called.
			MOV			R6, #10 ; 10 will be used for division. It will give remainder and quotient.
			MOV 		R1, R4  ; Store value of R4 at R1.
			
loop1		CMP			R1, #10 ; If value R1 is less than 10, it is a directly remainder. 
			ADD			R0, #1  ; INCREASE COUNTER.
			BCC			less_if
			UDIV		R2, R1, R6 ; R2 = R1/10
			MLS			R3, R2, R6, R1 ; R3 = R1 - R2*10 TO FIND REMAINDER
			MOV 		R1, R2
			PUSH		{R3} ; Store remainder at each loop	
			B 			loop1		
less_if		PUSH 		{R1}
			
			;R0 --> DEMONSTRATES NUMBER OF DIGIT AT GIVEN INPUT --> USE AS A COUNTER
			;R1 --> UNSTACK REMAINDERS FROM STACK SUCCESSIVELY --> PUT INTO R1
			;       INCREASE R1 BY 48 TO EXPRESS IT CORRECTLY AT ASCII AND STORE 		
disc_stack 	POP			{R1}
			ADD			R1, #48 	; CONVERT READED NUMBER TO ASCI
			STRB		R1, [R5], #1 
			SUBS 		R0, #1 		; DECREASE COUNTER BY 1
			BNE 		disc_stack	; IF COUNTER IS NOT ZERO, CONTINUE STORING REMAINDERS AT R5
			LDR			R1, =0x04	; FINISH END OF REMAINDER STORING WITH 0x04
			STRB		R1, [R5]	
			POP			{R0,R1,R2,R3,R5,R6}
			
			MOV 		R0, R5
			BL			OutStr      ; PRINT VALUE THAT KEPT AT R0
			
			POP 		{LR}
			BX 			LR
end_loop	ENDP
			END