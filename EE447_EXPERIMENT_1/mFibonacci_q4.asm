; EQU Directives
;***************************************************************
;LABEL 	DIRECTIVE 	VALUE 		COMMENT
;
;***************************************************************
; Data Area
;***************************************************************
;LABEL 	DIRECTIVE 	VALUE 		COMMENT
			AREA 		mdata , DATA, READONLY
			THUMBÜ
;***************************************************************
; Program section
;***************************************************************
;LABEL 		DIRECTIVE 	VALUE 		COMMENT
			AREA		mcode, CODE, READONLY
			THUMB
			ALIGN
			IMPORT 		InChar
			IMPORT 		OutStr
			IMPORT 		CONVRT
			EXPORT 		__main
			ENTRY
__main		PROC
			BL			InChar
			SUB			R1, R0, #48    		; first digit of N
			BL			InChar
			SUB			R2, R0, #48    		; second digit of N
			MOV			R6, #10
			MUL			R1, R1, R6
			ADD			R1, R1, R2			; N, used as counter
			MOV			R7, R1				; also N, used as counter
			LDR 		R5, =0x20000000  	; SET RANDOM ADDRESS FOR R5
			MOV 		R2, #1				; Fn-1
			MOV 		R3, #1				; Fn-2
			BL			mFibonacci
done		B			done
			ENDP
					
mFibonacci 	PROC
			PUSH		{LR}
			CMP			R1, #2				
			BLO			less				; if less than 2, store the value
			STR			R3, [R5], #4 		; store values in the memory starting from 0x20000000
			SUB			R1, #1				; decrease counter
			ADD			R6, R2, R3, LSL #1
			MOV			R3, R2				; new Fn-2 = old Fn-1
			MOV			R2, R6				; calculated new Fn-1 
			B 			mFibonacci				
			
exit		LDR			R4, [R6], #4		; load values to R4
			BL			CONVRT				; print decimal recursively starting from address 0x20000000	
			SUBS		R7, #1				; decrease counter
			BEQ			last
			B			exit
last		POP			{LR}				; return to main program
			BX			LR
			
less		STR			R3, [R5]			; store last item
			LDR 		R6, =0x20000000		; refresh the address
			LDR 		R5, =0x20000900		; not to affect written items, convrt address is defined
			B			exit
			ENDP
			ALIGN
			END