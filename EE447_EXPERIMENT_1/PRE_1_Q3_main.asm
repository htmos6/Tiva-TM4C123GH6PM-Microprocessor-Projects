;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
NUM         EQU         0x20000800

;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		MySubroutine, READONLY, CODE
            THUMB
			IMPORT 		OutStr
			IMPORT 		InChar
			IMPORT 		UPBND
			IMPORT 		CONVRT

;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
            EXPORT 		__main
			
			ENTRY
__main 		PROC
get			LDR			R4, =NUM		; R4 KEEPS ADDRESS/ AFTER THAT IT WILL MODIFIED SO THAT IT KEEPS THE VALUE THAT WE WANT TO PRINT TO THE SCREEN
			LDR 		R5, =0x20000400 ; SET RANDOM ADDRESS FOR R5
			LDR			R3, =0xFFFFFFFF ; according to input "n", we will clear required amounts of bits.
			; Input Part //// GET NUMBER "n" ////
			MOV			R2, #10			; IN ORDER TO MULTIPLY FIRST CHAR BY 10
			BL 			InChar			; TAKE INPUT
			SUB 		R1, R0, #48 	; CONVERT INPUT VARIABLE FROM ASCII --> FIRST GIVEN CHAR
			BL 			InChar			; TAKE INPUT
			SUB 		R0, R0, #48 	; CONVERT INPUT VARIABLE FROM ASCII --> SECOND GIVEN CHAR
			; Determine "n"
			MUL 		R1, R1, R2		; R1 = R1 * 10
			ADD 		R1, R1, R0      ; WE FOUND SIZE OF OUR NUMBER "n" VALUE
			RSB			R1, R1, #32
			; NOW WE NOW NUMBER OF BITS "n"
			
			MOV 		R2, #1 			; MODIFY R2 TO KEEP MIN
			
bit_clear 	LSR 		R3, #1			; KEEPS "n" BITS MAX NUMBER
			SUB			R1, #1			; R1 KEEPS NUMBER OF ZERO BITS
			CMP 		R1, #0
			BNE 		bit_clear
			
			MOV 		R1, #0
			ADD			R1, R2, R3
			LSR			R1, #1 			; FIND MID VALUE
			MOV			R4, R1
			
quess		BL			CONVRT			; PRINT MID VALUE
			BL			InChar	   		; IN ORDER TO TAKE AN INPUT WHETHER PROVIDED VALUE IS UPPER/CORRECT/LOWER
			; IF RESULT IS CORRECT, FINISH PROGRAM
			CMP			R0, #0x43   	; compare with C. IF RESULT IS CORRECT, END PROGRAM
			BEQ 		finish	   		; END
			BL			UPBND
			B			quess
			
finish		B			finish
			ENDP

;LABEL		DIRECTIVE	VALUE			COMMENT
			ALIGN
            END
