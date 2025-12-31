; KART NO: 34A
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

.text
	bic.b   #01111110b, &P1SEL		; make P1.0 (Success Indicator), P1.1, P1.2, P1.4, P1.5 (Input Buttons), P1.3 (Start Button) and P1.6 (Lose Indicator)
 	bic.b   #01111110b, &P1SEL2    	; make P1.0 (Success Indicator), P1.1, P1.2, P1.4, P1.5 (Input Buttons), P1.3 (Start Button) and P1.6 (Lose Indicator)
	bis.b   #01000001b, &P1DIR    	; make P1.0 and P1.6 output
 	bic.b   #00111110b, &P1DIR	 	; make P1.1, P1.2, P1.3, P1.4, P1.5 input
	bis.b   #00111110b, &P1REN	 	; enable pull-up resistor for P1.1, P1.2, P1.3, P1.4, P1.5
 	bis.b   #00111110b, &P1OUT	 	; enable pull-up resistor for P1.1, P1.2, P1.3, P1.4, P1.5
	bis.w 	#GIE, SR 				; enable interrupts
	bis.b 	#00110110b, &P1IES 		; P1.1, P1.2, P1.4, P1.5 interrupts from H to L
	bis.b 	#00110110b, &P1IE 		; enable P1.1, P1.2, P1.4, P1.5 interrupt
	bic.b   #11010101b, &P2SEL		; make P2.0, P2.2, P2.4, P2.6 (Output LED) and P2.7 (Win LED)
 	bic.b   #11010101b, &P2SEL2     ; make P2.0, P2.2, P2.4, P2.6 (Output LED) and P2.7 (Win LED)
 	bis.b   #11010101b, &P2DIR	 	; make P2.0, P2.2, P2.4, P2.6, P2.7 output
	bic.b   #01000001b, &P1OUT    	; reset P1OUT outputs
	bic.b   #11010101b, &P2OUT    	; reset P2OUT outputs
	mov.w #0, R4 					; Timer counter
	mov.w #0, R5					; Timer flag
	mov.w #0, R6					; Start condition
	mov.w #0, R7					; Level Index
	mov.b #0, R8					; Pattern Index
	mov.b #0, R9					; Input Index

.data
first_level: 	.byte #BIT1, #BIT2, #BIT1, #BIT4, #BIT2 
second_level: 	.byte #BIT2, #BIT2, #BIT1, #BIT4, #BIT3, #BIT4
third_level: 	.byte #BIT1, #BIT2, #BIT3, #BIT4, #BIT1, #BIT3, #BIT2, #BIT4

Idle_State:
	bit.b   #00001000b, &P1IN       ; read switch at P1.3
    jeq		Start_State				; if P1.3 open branch to Off
    bis.b   #01000000b, &P2OUT    	; set P2.6 (LED 4 off)
	bis.b   #00000001b, &P2OUT    	; set P2.0 (LED 1 on)
	call 	#blink
	bic.b	#00000001b, &P2OUT    	; set P2.0 (LED 1 off)
	bis.b   #00000100b, &P2OUT    	; set P2.2 (LED 2 on)
	call 	#blink
	bic.b	#00000100b, &P2OUT    	; set P2.2 (LED 2 off)
	bis.b   #00010000b, &P2OUT    	; set P2.4 (LED 3 on)
	call 	#blink
	bic.b	#00010000b, &P2OUT    	; set P2.4 (LED 3 off)
	bis.b   #01000000b, &P2OUT    	; set P2.6 (LED 4 on)
	call 	#blink
    jmp 	Idle_State

Start_State:
	inc.w 	R6
	cmp.w 	#11111111b,R6
	jge 	Game_State				; if start button is pressed enough
	jmp 	Idle_State

Game_State:
	call 	#Reset_State
	mov.w 	#1, R7					; set current level to "initiliazed"
	jmp 	Show_Pattern

Show_Pattern:
	mov.b	#0, R8					; reset patter index for upcoming level
	cmp.b	#1, R7
	jeq 	First_Level
	cmp.b	#2, R7
	jeq 	Second_Level
	cmp.b	#3, R7
	jeq 	Third_Level
	jmp		Idle_State

First_Level:
	bis.b	first_level(R8), &P2OUT	; set corresponding led on
	call	#blink
	call	#blink
	call	#blink
	bic.b	first_level(R8), &P2OUT	; set corresponding led off
	call	#blink
	call	#blink
	call	#blink
	inc.b	R8
	cmp.b	#5, R8
	jl		First_Level
	mov.b	#0, R8
	jmp 	Wait_State

Second_Level:
	bis.b	second_level(R8), &P2OUT	; set corresponding led on
	call	#blink
	call	#blink
	bic.b	second_level(R8), &P2OUT	; set corresponding led off
	call	#blink
	call	#blink
	inc.b	R8
	cmp.b	#6,	R8
	jl		Second_Level
	mov.b	#0, R8
	mov.b
	jmp 	Wait_State

Third_Level:
	bis.b	third_level(R8), &P2OUT	; set corresponding led on
	call	#blink
	bic.b	third_level(R8), &P2OUT	; set corresponding led off
	call	#blink
	inc.b	R8
	cmp.b	#8,	R8
	jl		Third_Level
	mov.b	#0, R8
	jmp 	Wait_State

Wait_State:
	bis.b 	#00110110b, &P1IE 		; enable P1.1, P1.2, P1.4, P1.5 interrupt
	call	#delay
	call	#delay
	bic.b 	#00110110b, &P1IE 		; disable P1.1, P1.2, P1.4, P1.5 interrupt
	jmp		Show_Pattern

Lose_State:
	call 	#Reset_State
	bis.b   #01000000b, &P1OUT    	; set P1.6 (Lose Indicator on)
	call	#delay
	bic.b   #01000000b, &P1OUT    	; set P1.6 (Lose Indicator off)
	jmp		Idle_State

Success_State:
	call 	#Reset_State
	bis.b   #00000001b, &P1OUT    	; set P1.0 (Success Indicator on)
	call	#blink
	bis.b   #01010101b, &P2OUT    	; set P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 on)
	bic.b   #01010101b, &P2OUT    	; clear P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 off)
	call	#blink
	bis.b   #01010101b, &P2OUT    	; set P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 on)
	bic.b   #01010101b, &P2OUT    	; clear P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 off)
	call	#blink
	bis.b   #01010101b, &P2OUT    	; set P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 on)
	bic.b   #01010101b, &P2OUT    	; clear P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 off)
	call	#blink
	bis.b   #01010101b, &P2OUT    	; set P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 on)
	bic.b   #01010101b, &P2OUT    	; clear P2.0, P2.2, P2.4, P2.6 (LED 1, 2, 3, 4 off)
	bic.b   #00000001b, &P1OUT    	; set P1.0 (Success Indicator off)
	jmp		Game_State

Win_State:
	call 	#Reset_State
	call 	#blink
	bis.b   #10000000b, &P2OUT    	; set P2.7 (Win LED on)
	call	#delay
	jmp		Idle_State

Reset_State:
	bic.b   #01000001b, &P1OUT    	; reset P1OUT outputs
	bic.b   #11010101b, &P2OUT    	; reset P2OUT outputs
	mov.w 	#0, R6					; reset start condition
	ret

delay: ; 2 seconds delay	
	inc.w R4
	cmp.w #11111111b, R4
	jl delay
	mov.w #0, R4
	inc.w R5
	cmp.w #1750, R5
	jl delay
	mov.w #0, R5
	ret

blink: ; blink 0.5 seconds
	inc.w R4
	cmp.w #00111111b, R4
	jl blink
	mov.w #0, R4
	inc.w R5
	cmp.w #1750, R5
	jl blink
	mov.w #0, R5
	ret

Input_State:
	cmp.b	#1, R7
	jeq 	Check_FL
	cmp.b	#2, R7
	jeq 	Check_SL
	cmp.b	#3, R7
	jeq 	Check_TL
	reti

Check_FL:
	cmp.b	#5, R9
	jge		Win_State
	cmp.b	first_level(R9), &P1IFG ; check input
	jeq		Progress
	bic.b	#00110110b, &P1IFG	; clear Interrupt Flag
	jmp		Lose_State

Check_SL:
	cmp.b	#6, R9
	jge		Win_State
	cmp.b	second_level(R9), &P1IFG ; check input
	jeq		Progress
	bic.b	#00110110b, &P1IFG	; clear Interrupt Flag
	jmp		Lose_State

Check_TL:
	cmp.b	#8, R9
	jge		Win_State
	cmp.b	third_level(R9), &P1IFG ; check input
	jeq		Progress
	bic.b	#00110110b, &P1IFG	; clear Interrupt Flag
	jmp		Lose_State

Progress:
	inc.b	#R9
	bic.b	#00110110b, &P1IFG	; clear Interrupt Flag
	cmp.b	#1, R7
	jeq 	Check_FL
	cmp.b	#2, R7
	jeq 	Check_SL
	cmp.b	#3, R7
	jeq 	Check_TL
	reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect ".int02" 					; Port 1 interrupt vector
			.short Input_State
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
