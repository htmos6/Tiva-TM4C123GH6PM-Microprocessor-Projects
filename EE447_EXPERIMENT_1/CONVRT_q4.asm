;***************************************************************
; Program PracticeLab.s
; Clear memory locations 0x2000.0400 - 0x2000.041F,
; then load these locations with consecutive numbers starting
; with 00.
; 'CONST' is the number of locations operated on.
; 'FIRST' is the address of first memory address.
;***************************************************************

;***************************************************************
; EQU Directives
; These directives do not allocate memory
;***************************************************************
;SYMBOL		DIRECTIVE	VALUE			COMMENT

;***************************************************************
; Program section
;***************************************************************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        sdata, DATA, READONLY
            THUMB


;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		MySubroutine, READONLY, CODE
            THUMB
            EXPORT 		CONVRT
			IMPORT 		OutStr

			
			; CONVRT FUNCTION BEGINS
CONVRT 		PROC
			PUSH		{R0,R1,R2,R3,R5,R6,LR}
			;R0 --> COUNTER
			;
			MOV 		R0, #0  ; Reset counter at every time subroutine is called.
			MOV			R6, #10 ; 10 will be used for division. It will give remainder and quotient.
			MOV 		R1, R4  ; Store value of R4 at R1.
			
loop1		CMP			R1, #10 ; If value R1 is less than 10, it is a directly remainder. 
			ADD			R0, #1  ; INCREASE COUNTER.
			BCC			less_if
			UDIV		R2, R1, R6
			MLS			R3, R2, R6, R1 ; R3 = R1 - R2*10 TO FIND REMAINDER
			MOV 		R1, R2
			PUSH		{R3} ; Store remainder at each loop	
			B 			loop1
			
less_if		PUSH 		{R1}
disc_stack 	POP			{R1}
			ADD			R1, #48 ; CONVERT READED NUMBER TO ASCI
			STRB		R1, [R5], #1 
			SUBS 		R0, #1
			BNE 		disc_stack
			LDR			R1, =0x04
			STRB		R1, [R5]
			POP			{R0,R1,R2,R3,R5,R6}
			MOV 		R0, R5
			BL			OutStr
			POP 		{LR}
			BX 			LR
end_loop	ENDP
			; CONVRT FUNCTION ENDS
			
			END