.model tiny
.code
org 100h

MAX_INP_LEN equ 10

Start:		mov si, offset Input
		mov bx, si
		mov cx, MAX_INP_LEN
		mov ah, 01h

	mark:	int 21h
		cmp al, 0dh
		je print
		mov [si], al
		inc si
		loop mark

	print:	mov byte ptr [si], '$'
		mov dx, bx 
     
		mov ah, 09h
		int 21h
		jmp terminate

	terminate:	mov ax, 4c00h
			int 21h

.data
Input:	db MAX_INP_LEN DUP (?)

end Start