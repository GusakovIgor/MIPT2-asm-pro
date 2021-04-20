.model tiny
.code
org 100h

MAX_INP_LEN equ 10

Start:		mov ah, 0ah
		mov dx, offset Input
		mov si, dx
		mov [si], MAX_INP_LEN
		int 21h
		
		mov ah, 02h
		mov dl, 0ah
		int 21h
		mov dl, [si + 1]
		add dl, '0'
		int 21h

	term:	mov ax, 4c00h
		int 21h

Input:	db MAX_INP_LEN dup (?)

end Start