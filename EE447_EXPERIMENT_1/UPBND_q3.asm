;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		upbnd, READONLY, CODE
            THUMB
			IMPORT		InChar
			IMPORT		CONVRT
            EXPORT 		UPBND	
			
UPBND 		PROC		
			PUSH 		{LR}
			; MID R1
			; MIN R2
			; MAX R3
			CMP			R0, #0x55   ; compare with U
			ADDEQ 		R2, R1, #1  ; MIN = MID + 1
			BEQ 		cont
			CMP			R0, #0x44   ; compare with D
			SUBEQ 		R3, R1, #1  ; MAX = MID - 1
			BEQ 		cont

cont		ADD			R1, R2, R3
			LSR			R1, #1 			; FIND MID VALUE
			MOV			R4, R1
			POP 		{LR}
			BX			LR
			ENDP
			END