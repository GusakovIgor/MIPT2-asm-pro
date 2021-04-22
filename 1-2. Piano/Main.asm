.model tiny
.code

org 100h

LOCALS

; Constants ===========================

BASE_NAME_LEN equ 5
MAX_INP_LEN equ 20
MAX_OUT_LEN equ 20
MAX_NUM_LEN equ 19	; Maximum is needed for binary number. 16 is for number, 1 is for length
			;							 1 for 'b' or 'o' or 'h'
                        ;							 1 for '$'

x1 = 2
x2 = 76

y1 = 2
y2 = 22

lu_coord = (80 * y1 + x1) * 2
ld_coord = (80 * y2 + x1) * 2
ru_coord = (80 * y1 + x2) * 2
rd_coord = (80 * y2 + x2) * 2


kx1 = 4
kx2 = 74

ky1 = 12
ky2 = 20

key_len = 4
key_height = 8
num_keys = 17
num_dies = 7


videomem = 0b800h

vert_side  = 0bah	; vertical side
horiz_side = 0cdh	; horizontal side

triangle_up   = 0cah
triangle_down = 0cbh
 
lu_corn = 0c9h  ; left-up
ld_corn = 0c8h  ; left-down
ru_corn = 0bbh	; right-up
rd_corn = 0bch  ; right-down

space = 20h	; free space

shadow_30 = 0b0h	; 30 %
shadow_50 = 0b1h        ; 50 %
shadow_70 = 0b2h        ; 70 %


Gate2   equ  42h
CmdReg  equ  43h
PortB	equ  61h

WaitLow  equ 0F9CBh	; In microseconds (10^-6)
WaitHigh equ 0008h	; In microseconds (10^-6)

MainFreq equ 1193100

; Notes:

	;C2	equ MainFreq / 65
	;C2_sh	equ MainFreq / 69
	;D2	equ MainFreq / 73
	;E2_fl	equ MainFreq / 78
	;E2	equ MainFreq / 82
	;F2	equ MainFreq / 87
	;F2_sh	equ MainFreq / 92
	;G2	equ MainFreq / 98
	;G2_sh	equ MainFreq / 104
	;A2	equ MainFreq / 110
	;B2_fl	equ MainFreq / 117
	;B2	equ MainFreq / 124

	C3	equ MainFreq / 131
	C3_sh	equ MainFreq / 139
	D3	equ MainFreq / 147
	E3_fl	equ MainFreq / 156
	E3	equ MainFreq / 165
	F3	equ MainFreq / 175
	F3_sh	equ MainFreq / 185
	G3	equ MainFreq / 196
	G3_sh	equ MainFreq / 208
	A3	equ MainFreq / 220
	B3_fl	equ MainFreq / 233
	B3	equ MainFreq / 247

	C4	equ MainFreq / 262
	C4_sh	equ MainFreq / 277
	D4	equ MainFreq / 294
	E4_fl	equ MainFreq / 311
	E4	equ MainFreq / 330
	F4	equ MainFreq / 349
	F4_sh	equ MainFreq / 370
	G4	equ MainFreq / 392
	G4_sh	equ MainFreq / 415
	A4	equ MainFreq / 440
	B4_fl	equ MainFreq / 466
	B4	equ MainFreq / 494

	P	equ 10

;======================================




Start:	
	call DrawFrame
	call DrawKeys

	xor bx, bx	; bx = 0
	mov es, bx	; Moving to standart BIOS segment (es = 0)
	mov bx, 9*4	; Set offset to the part of segment which contains what to do with keyboard interrupt 

	call ChangeIntFunc
    call LoadProg
	
	mov ax, 4c00h
	int 21h

	include resident.asm
    include numout.asm
	include mksound.asm
	include mkkeys.asm

Input:	db MAX_INP_LEN dup (?)

Output:	db MAX_OUT_LEN dup (?)

End_of_Prog:

	include mkframe.asm

end	Start