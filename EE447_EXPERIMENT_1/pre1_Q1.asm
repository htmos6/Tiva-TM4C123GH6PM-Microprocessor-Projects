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
NUM         DCD         245456

;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		MySubroutine, READONLY, CODE
            THUMB
            IMPORT 		CONVRT
			IMPORT 		OutStr
			IMPORT 		InChar
			
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
            EXPORT 		__main
			
			ENTRY
__main 		PROC
get			LDR			R4, =NUM
			LDR			R4, [R4]
			LDR 		R5, =0x20000400
			BL 			InChar
			BL			CONVRT
			B			get
			ENDP
;***************************************************************
; End of the program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
			ALIGN
            END
