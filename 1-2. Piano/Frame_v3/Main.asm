.model tiny
.code

org 100h


; Constants ===========================

BASE_NAME_LEN equ 5
MAX_INP_LEN equ 20
MAX_OUT_LEN equ 20
MAX_NUM_LEN equ 19	; Maximum is needed for binary number. 16 is for number, 1 is for length
			;							 1 for 'b' or 'o' or 'h'
                        ;							 1 for '$'

x1 = 10
x2 = 70

y1 = 10
y2 = 20

lu_coord = (80 * y1 + x1) * 2
ld_coord = (80 * y2 + x1) * 2
ru_coord = (80 * y1 + x2) * 2
rd_coord = (80 * y2 + x2) * 2


videomem = 0b800h

vert_side  = 0bah	; vertical side
horiz_side = 0cdh	; horizontal side

lu_corn = 0c9h  ; left-up
ld_corn = 0c8h  ; left-down
ru_corn = 0bbh	; right-up
rd_corn = 0bch  ; right-down

space = 20h	; free space

shadow_30 = 0b0h	; 30 %
shadow_50 = 0b1h        ; 50 %
shadow_70 = 0b2h        ; 70 %

;======================================


; Global Funcs ========================

;extrn DrawFrame	:proc
;extrn GetString	:proc
;extrn ReadNumber	:proc
;extrn NumberProcessing	:proc

;======================================

Start:	call DrawFrame          ; Drawing a frame
	call GetString
	call ReadNumber		; input in ax

	push ax
	mov bx, 10			; Base of system number to convert
        mov di, lu_coord + 160 + 2	; Offest of message in VideoMemory
	call NumberProcessing
	pop ax

	push ax
	mov bx, 2			; Base of system number to convert
        mov di, (lu_coord + ld_coord + ru_coord + rd_coord) / 4 - 160 -	10	; Offest of message in VideoMemory
	call NumberProcessing
	pop ax

	push ax
	mov bx, 8			; Base of system number to convert
        mov di, (lu_coord + ld_coord + ru_coord + rd_coord) / 4	- 10		; Offest of message in VideoMemory
	call NumberProcessing
	pop ax

	push ax
	mov bx, 16			; Base of system number to convert
        mov di, (lu_coord + ld_coord + ru_coord + rd_coord) / 4 + 160 - 10	; Offest of message in VideoMemory
	call NumberProcessing
                
     	mov ax, 4c00h
	int 21h	

	include mkframe.asm
	include numproc.asm
        include numout.asm



Input:	db MAX_INP_LEN dup (?)

Output:	db MAX_OUT_LEN dup (?)

Base_dec: db 'inp: '

Base_bin: db 'bin: '

Base_oct: db 'oct: '

Base_hex: db 'hex: '

end	Start