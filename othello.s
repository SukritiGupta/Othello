.equ SWI_Exit, 0x11
.equ SWI_Open, 0x66
.equ SWI_PrStr, 0x69
.equ SWI_PrInt, 0x6b
.equ SWI_Close, 0x68
.equ SWI_PCD, 0x207
.equ SWI_SEG, 0x200
.equ SWI_CheckBlue, 0x203
.equ seg_A, 0x80
.equ seg_B, 0x40
.equ seg_C, 0x20
.equ seg_D, 0x08
.equ seg_E, 0x04
.equ seg_F, 0x02
.equ seg_G, 0x01
.equ seg_P, 0x10
.text

@		display complete board, 

@	initialised with possible moves

@	take input1

@	change_board(assuming valid input) 

@	display complete board

@	change_player on display



@	call is valmov 64 times
@	if 64 and not valid 
@	then change player,symbol on display. show message no moves
@	call isvalmov 64 times
@	if 64 and not valid 
@	calc win

@	display board, wait for input
@	change board


@	one:
@	Display current board
@	Display player - X, 0
@	Compute_valid_moves: @r3 'X' or '0'
@		if pass then compute valid moves of the other player
@		if exist change player
@		else go to calc win


@	wait for input
@	if not valid do not change wait for new input

@	change board according to input
@	go back to one
@	calc win

	

	mov r7, #1
	ldr r1, =Digits
	ldr r0, [r1,#4]
	swi SWI_SEG


Display:
	
	mov r3, #0
	mov r13, #0 
OL1:	mov r4,#0
IL1:	bl disptile
	add r4, r4, #1
	cmp r4, #8
	blt IL1
	add r3, r3, #1
	cmp r3, #8
	blt OL1
	
	mov r3, #3
	mov r4, #4

	bl Input1
	
	swi 0x206

	

	mov r0, #32
	mov r1, #0
	mov r2, r3
	swi 0x205

	mov r0, #34
	mov r1, #0
	mov r2, r4
	swi 0x205

	bl changeboard

	cmp r11, #0 @please enter valid input
	beq ii
	bne postii
	

ii:	mov r0, #16
	mov r1, #0
	ldr r2, =invinp
	swi 0x204

	b AllValMov

postii:

	mov r3, #0
	mov r13, #0 
OL:	mov r4,#0
IL:	bl disptile
	add r4, r4, #1
	cmp r4, #8
	blt IL
	add r3, r3, #1
	cmp r3, #8
	blt OL

	cmp r7, #1
	beq changeto2
	b changeto1

here:	b AllValMov


changeto2:	mov r7, #2
		ldr r1, =Digits
		ldr r0, [r1,#8]
		swi SWI_SEG
		b here


changeto1:	mov r7, #1
		ldr r1, =Digits
		ldr r0, [r1,#4]
		swi SWI_SEG
		b here



Input1:	swi SWI_CheckBlue
	cmp r0, #0 
	beq Input1 
	cmp r0, #0x80
	moveq r3, #7
	cmp r0, #0x40
	moveq r3, #6 
	cmp r0, #0x20
	moveq r3, #5
	cmp r0, #0x10
	moveq r3, #4

	cmp r0, #0x08
	moveq r3, #3
	cmp r0, #0x04
	moveq r3, #2 
	cmp r0, #0x02
	moveq r3, #1
	cmp r0, #0x01
	moveq r3, #0

Input2:	swi SWI_CheckBlue
	cmp r0, #0 
	beq Input2 
	
	mov r0,r0, LSR #8


	cmp r0, #0x80
	moveq r4, #7
	cmp r0, #0x40
	moveq r4, #6 
	cmp r0, #0x20
	moveq r4, #5
	cmp r0, #0x10
	moveq r4, #4

	cmp r0, #0x08
	moveq r4, #3
	cmp r0, #0x04
	moveq r4, #2 
	cmp r0, #0x02
	moveq r4, #1
	cmp r0, #0x01
	moveq r4, #0

	mov pc, lr

AllValMov:
	mov r3, #0
	mov r13, #0 
OL2:	mov r4,#0
IL2:	bl isVal @*************************************************************
	add r4, r4, #1
	cmp r4, #8
	blt IL2
	add r3, r3, #1
	cmp r3, #8
	blt OL2

	cmp r13, #0
	beq pospas
	bne Display


pospas:	@change player,symbol, display

	cmp r7, #1
	b changeto21
	b changeto11


changeto21:	mov r7, #2
		ldr r1, =Digits
		ldr r0, [r1,#8]
		swi SWI_SEG
		b heres


changeto11:	mov r7, #1
		ldr r1, =Digits
		ldr r0, [r1,#4]
		swi SWI_SEG
		b heres

heres:		

	mov r3, #0
	mov r13, #0 
OL3:	mov r4,#0
IL3:	bl isVal @******************************************
	add r4, r4, #1
	cmp r4, #8
	blt IL3
	add r3, r3, #1
	cmp r3, #8
	blt OL3

	cmp r13, #0
	beq calcwin
	bne Display


@r1 number  of 1
@r2 number of 2
@r3 board
@r4 max 64, offset


calcwin:	mov r1, #0
		mov r2, #0
		mov r4, #0
		ldr r3, =board

Looping:	ldr r5, [r3, r4]
		cmp r5, #1
		addeq r1, r1, #1
		cmp r5, #2
		addeq r2, r2, #1
		add r4, r4, #4
		cmp r4, #256
		blt Looping


		cmp r1, r2
		@swi 0x208
		beq print_draw
		blt print_2win
		bgt print_1win



print_draw:	swi 0x206
		mov r0, #0
		mov r1, #0
		ldr r2, =M1draw
		swi 0x204
		swi SWI_Exit


print_2win:	
		swi 0x206		
		mov r0, #0
		mov r1, #0
		ldr r2, =M2WIN
		swi 0x204
		swi SWI_Exit

print_1win:	swi 0x206
		mov r0, #0
		mov r1, #0
		ldr r2, =M1WIN
		swi 0x204
		swi SWI_Exit


disptile:	@takes x and y in r3,r4 
		@r0 x of display = r4+1
		@r1 y of display = r3+1
		@ r7 stores symbol
		@ 0 - empty    , 1,2-players,    8-valid 
		
		mov r5,#8
		mul r11,r3,r5		@r11 = 8x
		add r11,r11,r4		@r11 = 8x + y
		mov r5,#4
		mul r6,r11,r5		@r6 = byte offset 
		
		ldr r5,=board
		ldr r5,[r5,r6]		@r1 has cell's symbol

		mov r0, r4
		add r0, r0, r0
		mov r1, r3
		add r1, r1, r1
				
		cmp r5, #1
		moveq r2, #'X

		cmp r5, #2
		moveq r2, #'O

		cmp r5, #0
		moveq r2, #'-

		cmp r5, #8
		moveq r2, #'*

		swi SWI_PCD
		mov pc, lr


	@mov r7,#1
	@mov r3,#2
	@mov r4,#4

isVal: 	@r3,r4 store x and y values of cell in consideration (start cell)
	@r5,r6 are increments in x and y that is gradient
	@r7 stores my symbol
	@r8 will store link register

	mov r8,lr
	mov r2,#0	@ count of cells to be flipped
	mov r9,r3
	mov r10,r4
	bl onboard
	cmp r11,#0
	beq endisVal
	bl tile
	cmp r11,#0
	bne endisVal
	mov r12,#-4	@ grad ka pointer

cvms:	@r9,r10 are temp x,y

	add r12,r12,#4
	cmp r12,#64
	beq endisVal

	ldr r11,=grad
	ldr r5,[r11,r12]
	add r12,r12,#4
	ldr r6,[r11,r12]
	
	add r9,r3,r5
	add r10,r4,r6
	bl onboard
	cmp r11,#0
	beq cvms	@not a valid direction of motion

	bl tile
	cmp r11,#2	
	blt cvms	@not valid direction if same tile or empty
	

	@atleast one other tile is there
	
	L: 	add r9,r9,r5
		add r10,r10,r6
		bl onboard
		cmp r11,#0
		beq cvms
		
		bl tile
		cmp r11,#2	@other tile, so continue incrementing
		beq L
		cmp r11,#0	
		beq cvms
		@if reaches this point, the (x,y) is the tile, and hence is a valid move. now backtrack
	
	M:	sub r9,r9,r5
		sub r10,r10,r6
		add r2,r2,#1	@r2 stores the number of tiles to be flipped
		cmp r9,r3
		bne M
		cmp r10,r4
		bne M
		@ we have reached the starting cell
		b cvms

	
endisVal:	@r2 stores the number of tiles to be flipped
		cmp r2,#0
		bgt valid
		mov r11,#0
		b ret

	valid:	@write 8 on corresponding board position and move 1 in r11
		mov r1,#8
		mul r11,r3,r1
		add r11,r11,r4
		mov r1,#4
		mul r0,r11,r1

		mov r11,#8
		ldr r1,=board
		str r11,[r1,r0]		@write 8
		mov r11,#1
		add r13,r13,#1		@no of valid moves with the current user
		
	ret:	mov pc,r8
		@swi SWI_Exit
		

onboard: 	@takes x and y in r9,r10 and returns true(1)/false(0) in r11
		mov r11,#1
		cmp r9,#0
		blt ans
		cmp r10,#0
		blt ans
		cmp r9,#7
		bgt ans
		cmp r10,#7
		bgt ans
		b return
		
	ans:	mov r11,#0
	return: mov pc,lr


tile:		@takes x and y in r9,r10 and returs 1 if cell has tile, 2 if other tile and 0 if empty, in r11.
		@ r7 stores symbol
		@ 0 - empty    , 1,2-players,    8-valid 
		mov r1,#8
		mul r11,r9,r1		@r11 = 8x
		add r11,r11,r10		@r11 = 8x + y
		mov r1,#4
		mul r0,r11,r1		@r0 = byte offset 
		
		ldr r1,=board
		ldr r1,[r1,r0]		@r1 has cell's symbol
		cmp r1,r7		@same if equal
		moveq r11,#1
		beq rtrn

		cmp r1,#0		@empty
		moveq r11,#0
		beq rtrn
		
		
		cmp r1,#8
		moveq r11,#0
		beq rtrn

		mov r11,#2		@other tile (or 8 which in this case is equivalent to being empty)

	rtrn:	mov pc,lr		
		
















changeboard:
 	@r3,r4 store x and y values of cell in consideration (start cell)
	@r5,r6 are increments in x and y that is gradient
	@r7 stores my symbol
	@r8 will store link register
	mov r8,lr

	


	@remove all 8s
	mov r5,#0		@ r5 and r6 are counters for row and column
outer:	mov r6,#0

inner:	@cell r5,r6
	
	mov r1,#8
	mul r11,r5,r1
	add r11,r11,r6
	mov r1,#4
	mul r0,r11,r1

	mov r11,#8
	ldr r1,=board
	ldr r11,[r1,r0]		@load character in cell
	cmp r11,#8
	bne continue

	mov r11,#0
	str r11,[r1,r0]		@ store 0 in the cell that previously had 0
	
continue:
	add r6,r6,#1		@increment j
	cmp r6,#8
	bne inner
	add r5,r5,#1
	cmp r5,#8
	blt outer
	@all cells traversed
	@and board conditions restored (ie all 8s removed)


	

	
	mov r2,#0	@ count of cells to be flipped
	mov r9,r3		@r9,r10 are temp x,y
	mov r10,r4
	bl onboard
	cmp r11,#0
	beq endisVal2
	bl tile
	cmp r11,#0
	bne endisVal2
	mov r12,#-4	@ grad ka pointer

cvms2:	@r9,r10 are temp x,y

	add r12,r12,#4
	cmp r12,#64
	beq endisVal2

	ldr r11,=grad
	ldr r5,[r11,r12]
	add r12,r12,#4
	ldr r6,[r11,r12]
	
	add r9,r3,r5
	add r10,r4,r6
	bl onboard
	cmp r11,#0
	beq cvms2	@not a valid direction of motion

	bl tile
	cmp r11,#2	
	blt cvms2	@not valid direction if same tile or empty
	

	@atleast one other tile is there
	
	L2: 	add r9,r9,r5
		add r10,r10,r6
		bl onboard
		cmp r11,#0
		beq cvms2
		
		bl tile
		cmp r11,#2	@other tile, so continue incrementing
		beq L2
		cmp r11,#0	
		beq cvms2
		@if reaches this point, the (x,y) is the tile, and hence is a valid move. now backtrack
	
	M2:	sub r9,r9,r5
		sub r10,r10,r6
		add r2,r2,#1	@r2 stores the number of tiles to be flipped 
		@keep flipping the tiles (other tile changed to my tile)
		mov r1,#8
		mul r11,r9,r1
		add r11,r11,r10
		mov r1,#4
		mul r0,r11,r1

		ldr r1,=board
		str r7,[r1,r0]		@write my symbol thart is stored in r7

		
		
		cmp r9,r3
		bne M2
		cmp r10,r4
		bne M2
		@ we have reached the starting cell that already has my symbol
		b cvms2

	
endisVal2:	@r2 stores the number of tiles to be flipped
		cmp r2,#0
		bgt valid2
		mov r11,#0	 @ print INVALID
		b ret2

	valid2:	@write my symbol on corresponding board position and move 1 in r11
		
		mov r1,#8
		mul r11,r3,r1
		add r11,r11,r4
		mov r1,#4
		mul r0,r11,r1

		
		ldr r1,=board
		str r7,[r1,r0]		@write my symbol
		mov r11,#1
		add r13,r13,#1		@no of valid moves with the current user
		
	ret2:	mov pc,r8
		@swi SWI_Exit
		




end:

.data

board: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
grad:	.word 1,1,1,0,0,1,-1,-1,1,-1,-1,1,0,-1,-1,0


M1draw: .asciz "IT WAS A DRAW\n"
M1WIN: .asciz "PLAYER 1 WON\n"
M2WIN: .asciz "PLAYER 2 WON\n"
invinp: .asciz "Please enter valid input\n"

Digits:
.word seg_A | seg_B | seg_C | seg_D | seg_E|seg_G @0
.word seg_B | seg_C @1
.word seg_A | seg_B | seg_F | seg_E | seg_D @2
.word seg_A | seg_B | seg_F | seg_C | seg_D @3
.word seg_G | seg_F | seg_B | seg_C @4
.word seg_A | seg_G | seg_F | seg_C | seg_D @5
.word seg_A | seg_G | seg_F | seg_E | seg_D | seg_C @6
.word seg_A | seg_B | seg_C @7
.word seg_A|seg_B|seg_C|seg_D|seg_E|seg_F|seg_G @8
.word seg_A | seg_B | seg_F | seg_G | seg_C @9
.word 0 @Blank display 

.end
