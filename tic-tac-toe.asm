; ###############
; Justin Blechel
; Project: Tic-Tac-Toe
; 12/13/20
; ###############

; Data Section
; ############
section 	.data
	
; ###############################################
; Variable Definitions
; ###############################################
; constants for system calls
SYS_read	equ	0x0
SYS_stdin	equ	0x0
SYS_write	equ	0x1
SYS_stdout	equ	0x1
SYS_exit	equ	0x3c
exit_success	equ	0x0
endl		db	0x0a
space		db	" "

; tic-tac-toe game pieces and board
player1		db	"X"
player2		db	"O"
tttIndex	db 	"# 123"
tttArray	db	"---------"
tttRow		dq	0x3
tttCol		dq	0x3

; start prompt
title		db	"     TIC-TAC-TOE              "
exitPrompt	db	"Enter 0 (zero) to EXIT         "
instructions	db	"22 means row 2, column 2      "

; round prompts
p1Prompt	db	"Player 1's turn! Place an X!"
p2Prompt	db	"Player 2's turn! Place an O!"
promptSize	equ	$-p2Prompt

; input prompt
inputPrompt	db	"Enter row/col number: "
userInput	db	"                      "
inputSize	equ	$-userInput

; error messages
inputError 	db 	"Invalid Input, try again..    "
placeError 	db 	"Invalid Placement, try again.."
errorSize	equ	$-placeError 	

; exit prompts
p1WinPrompt	db	"Player 1 wins!!!"
p2WinPrompt	db	"Player 2 wins!!!"
drawPrompt	db	"Draw!!!         "
endPromptSize	equ	$-drawPrompt

; BSS Section
; ############ 
section		.bss

row resb 1 ; reserve a byte for row input

col resb 1 ; reserve a byte for column input

; ###############################################
; Variable Declarations
; ###############################################

; Code Section
; ############	
section		.text

; 3x3 Grid: tttArray (---------)
; r1c1 = row 1, column 1 		Row Win Conditions:							
;	     |         |     			
;      1*1   |   1*2   |   1*3   	1, 2, 3: XXX------	
;      ==    |   ==    |   ==		row 1: r1c1, r1c2, r1c3    
;     __1____|____2____|____3__		________________________			
;            |	       |     			
;      2*1   |   2*2   |   2*3		4, 5, 6: ---OOO---
;      !=    |   !=    |   ==		row 2: r2c1, r2c2, r2c3   		
;     __4____|____5____|____6__		________________________
;	     |	       |         		
;      3*1   |   3*2   |   3*3	    	7, 8, 9: ------XXX
;      !=    |   !=    |   ==	    	row 3: r3c1, r3c2, r3c3   
;     __7____|____8____|____9__         ________________________
                                             
;   Column Win Conditions:       	Diagonal Win Conditions:
;     					|	
;   | col 1:   |  col 2:  |  col 3:	\  1, 5, 9: X---X---X
;   |  r1c1,   |  r1c2,   |  r1c3,	 \  r1c1, r2c2, r3c3
;   |  r2c1,   |  r2c2,   |  r2c3,	  \	
;   |  r3c1    |  r3c2    |  r3c3	   \  3, 5, 7: --O-O-O--
;   |          |          |                 \  r1c3, r2c2, r3c1
;   | 1, 4, 7  | 2, 5, 8  | 3, 6, 9	     \__________________  
;   X--X--X--  -O--O--O-  --X--X--X 				
;   Total win conditions: 8	
;   9 initial moves, 8 possible responses, 9! or 362,880 possible games


; ###############################################
; ### Begin Program 
; ###############################################	
global _start

_start:
; ###############################################
; ### Macro: output prompt
; ###############################################
%macro print 0x2

mov rax, SYS_write	; call code = 0x1
mov rdi, SYS_stdout	; output location
mov rsi, %1		; address of output
mov rdx, %2		; output size
syscall			; invoke call to system service	

mov rax, SYS_write	; call code = 0x1
mov rdi, SYS_stdout	; output location = 0x1
mov rsi, endl		; endl = 0x0a
mov rdx, SYS_write	; size of output = call code
syscall			; invoke call to system service	

%endmacro



; ###############################################
; ### Macro: print a row
; ###############################################
%macro printRow 0x1

push rcx		; save counter

mov rax, qword[tttRow]  ; size of the row
mov rbx, %1		; move the row number to print into rbx
dec rbx			; decrement to 0 offset
mul rbx			; multiply rax by rbx for the correct point in the array

lea rsi, [tttArray+rax] ; set the address of rsi to the correct point in tttArray
mov rdx, qword[tttRow]	; size of the row

print rsi, rdx		; pass address and size to print
pop rcx			; restore counter

%endmacro



; ###############################################
; ### Macro: print the tic-tac-toe board
; ###############################################
%macro printBoard 0x0

print tttIndex, 0x5	; print column index above the board

mov rcx, 0x1		; start counter 1
%%printRowStart:
push rcx		; save counter

; print row index
mov rax, SYS_write		; call code
mov rdi, SYS_stdout		; output location
lea rsi, byte [tttIndex+rcx+1]	; address of output
mov rdx, SYS_write		; size of output = call code	
syscall				; invoke call to system service

; print a space
mov rax, SYS_write	; call code
mov rdi, SYS_stdout	; output location
mov rsi, space		; address of output
mov rdx, SYS_write	; size of output = call code
syscall			; invoke call to system service		

; print a row
pop rcx			; restore counter
printRow rcx		; pass counter to the 'printRow' macro
inc rcx			; increment the counter after printing a row
cmp rcx, [tttRow]	; compare the counter to row size
jbe %%printRowStart	; continue the loop if counter is below or equal to 3

; print an endline
mov rax, SYS_write	; call code
mov rdi, SYS_stdout	; output location
mov rsi, endl		; address of output
mov rdx, SYS_write	; size of output = call code
syscall			; invoke call to system service

%endmacro



; ###############################################
; ### Macro: check if placement is valid
; ###############################################
%macro checkPlacement 0x0

mov bl, byte [tttArray + rax]	; store placement position
cmp bl, [player1]		; if "X" is already in this placement position
je invalidPlacement		; then selected placement is invalid
				; else continue
cmp bl, [player2]		; if "O" is already in this placement position
je invalidPlacement		; then selected placement is invalid
jmp validPlacement		; else valid placement

%endmacro



; ###############################################
; ### Game start
; ###############################################
mov rax, SYS_write	; call code = 0x1
mov rdi, SYS_stdout	; output location = 0x1
mov rsi, endl		; endl = 0x0a
mov rdx, SYS_write	; size of output = call code
syscall			; invoke call to system service

; start prompts
print title, promptSize		; "TIC-TAC-TOE"
print exitPrompt, promptSize	; "Enter 0 (zero) to EXIT"
print instructions, promptSize	; "22 means row 2, column 2"

mov rax, SYS_write	; call code = 0x1
mov rdi, SYS_stdout	; output location = 0x1
mov rsi, endl		; endl = 0x0a
mov rdx, SYS_write	; size of output = call code
syscall			; invoke call to system service	

printBoard		; print default board	

; ### Round start
; ###############################################
xor rcx, rcx			; round counter

roundStart:
inc rcx				; increment round counter
push rcx			; save round counter

; player 1 (X) is odd
; player 2 (O) is even
test rcx, 0x1			; test round counter
jz p2Turn			; jump to "p2Turn" if even/lowest bit clear

; else lowest bit set; odd
mov r8b, [player1]		; r8b holds "X"
print p1Prompt, promptSize 	; output: "Player 1's turn! Place an X!"
jmp continue			; continue to input	

p2Turn:
mov r8b, [player2]		; r8b holds "O"
print p2Prompt, promptSize 	; output: "Player 2's turn! Place an O!"
jmp continue			; continue to input

invalidPlacement: 		; jumped from the checkPlacement macro			
 print placeError, errorSize 	; output: "Invalid Placement, try again.."

continue:		

; ### Input start
; ###############################################
inputStart:

; output 'inputPrompt' to console
mov rax, SYS_write	; call code = 0x1
mov rdi, SYS_stdout	; output location
mov rsi , inputPrompt	; address of output
mov rdx, inputSize	; output size
syscall			; invoke call to system service	

; get input from console
mov rax, SYS_read	; call code = 0x0
mov rdi, SYS_stdin	; input location
mov rsi, userInput	; address to store input
mov rdx, inputSize	; size of input
syscall			; invoke call to system service	

; the first byte in rsi or "userInput" is the row input
mov al, byte [rsi]	; store row input in the accumulator register
sub al, 0x30		; subtract 48 to convert ASCII to decimal
jz exit			; if row input is zero; exit program
cmp al, 0x3		; if row input is greater than 3
jg invalidInput		; jump to "invalidInput"
; else row input is valid, continue check for column input

; the second byte in rsi or "userInput" is the column input
mov bl, byte [rsi+1]	; store column input in the base register	
sub bl, 0x30		; subtract 48 to convert ASCII to decimal
jz exit			; if column input is zero; exit program
cmp bl, 0x3		; if column input is greater than 3		
jg invalidInput		; jump to "invalidInput"
cmp bl, 0x0a		; if the second byte is an endl
je invalidInput		; jump to "invalidInput"
; else column input is valid, continue check for endl			

; if input is valid, the third byte will be 0x0a (endl)
cmp byte [rsi+2], 0x0a	; if the 3rd byte is not an endl
jne invalidInput	; jump to "invalidInput"		
			; else valid input
mov byte [row], al	; set row
mov byte [col], bl	; set column
jmp validInput		; jump to "validInput"

invalidInput:
 print inputError, errorSize 	; output: "Invalid input, try again.."
jmp inputStart			; restart input, jump to "inputStart"

validInput:	; input is valid, placement can start			

; ### Placement start
; ###############################################

mul bl			; row*col gives the correct placement for row 1 or column 3
cmp byte [row], 0x1	; if row = 1
je r1ORc3		;    or
cmp byte [col], 0x3	; if col = 3 
je r1ORc3		; jump to placement for row 1 or column 3 
			; else
cmp al, 0x4		; if row*col = 4; row 2, column 2
je r2c2			; else continue	
cmp al, 0x3		; if row*col = 3; row 3, column 1
je r3c1			; else continue

; row 2, column 1 or row 3, column 2 

inc rax			; increment the product for the correct placement in tttArray
 checkPlacement 	

r2c2: 			; row 2, column 2
 checkPlacement 	; product = placement

r3c1: 			; row 3, column 1
add rax, 0x3		; add 3 to the product for the correct placement in tttArray
 checkPlacement 

r1ORc3:			; row 1 OR column 3
dec rax			; decrement the product for the correct placement in tttArray	
 checkPlacement

validPlacement:
mov byte [tttArray + rax], r8b 	; set valid placement

; ### Print new board
; ###############################################

printBoard	; print new board

pop rcx		; restore counter		
cmp rcx, 0x5	; if counter is less than 5 it's impossible to win
jl nextRound	; a few operations to skip hundreds
push rcx	; save counter

; ### Check win conditions
; ###############################################

; starting at the tail of the current row
mov al, byte [row]		; accumulator = row
mov bl, 0x3			; base = 3
mul bl				; accumulator*base = row tail + 1
mov rcx, 0x3			; set counter to 3
checkRows:			; tttArray+rax-1 = row tail	
cmp r8b, byte [tttArray+rax-1]  ; if current placement != row position
jne exitRows			; exit row win check				  								
dec rcx				; else decrement counter
jz win				; if counter = 0; win condition found, exit loop
dec al				; decrement to traverse row tail to head
jmp checkRows			; restart: check next row position
exitRows:		

; starting at the head of the column from the current placement
mov al, byte [col]		; accumulator = column
mov rcx, 0x3			; set counter to 3
checkColumns:
cmp r8b, byte [tttArray+rax-1]  ; if current placement != column position
jne exitColumns			; exit column win check
dec rcx				; else decrement counter
jz win				; if counter = 0; win condition found, exit loop			
add al, 0x3			; add 3 to traverse from column head to tail
jmp checkColumns		; restart: check next column position
exitColumns:			

; Diagonal 1: [0, 4, 8] 
mov rcx, 0xC			; counter = 12
checkDiag1:
cmp rcx, 0x0			; if counter = 0
je win				; win condition found, exit loop
sub rcx, 0x4			; subtract 4 to traverse from tail to head 
cmp r8b, byte [tttArray+rcx]	; if current placement = diagonal position
je checkDiag1			; restart: check next diagonal position

; Diagonal 2: [2, 4, 6]
mov rcx, 0x8			; counter = 8
checkDiag2:
cmp rcx, 0x2			; if counter = 2
je win				; win condition found, exit loop
sub rcx, 0x2			; subtract 2 to traverse from tail to head
cmp r8b, byte [tttArray+rcx]	; if current placement = diagonal position
je checkDiag2			; restart: check next diagonal positon

; else no win conditions found

; ### Round end
; ###############################################

pop rcx		; restore round counter
cmp rcx, 0x9	; if round counter = 9, the board is full
je draw		; exit; the current game is a draw
nextRound:	; else
jmp roundStart	; start next round

; ### Output win or draw
; ###############################################
win:	

pop rcx		; restore round counter
test rcx, 0x1	; test round counter
jz p2win	; if even, player 2 wins
		; else player 1 wins
		
 print p1WinPrompt, endPromptSize	; output: "Player 1 wins!!!"
jmp exit
	
p2win:
 print p2WinPrompt, endPromptSize	; output: "Player 2 wins!!!"
jmp exit

draw:
 print drawPrompt, endPromptSize	; output: "Draw!!!"

exit:
; ###############################################
; ### Game exit with exit code 0x0
; ###############################################
	mov rax, SYS_exit	; call code = 0x3c
	mov rdi, exit_success	; output location = 0x0
	syscall
