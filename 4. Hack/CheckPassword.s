global main
extern getchar
extern printf

section .text

main:

	xor rax, rax
	lea rdi, [string]
	
	.read:
		
		push rbp
		call getchar
		pop rbp

		push rax
		lea rdi, [FmtHex]
		mov rsi, rax
		xor rax, rax
		call printf
		pop rax

		cmp rax, 0x0a
		jne .read


	call NewLine

	;lea rdi, [FmtString]
	;lea rsi, [string]

	;xor rax, rax
	;call printf

	;call NewLine
	;call NewLine


	mov rax, 0x3C
	xor rdi, rdi
	syscall


NewLine:
		mov rdi, FmtChar
		mov rsi, newline

		xor rax, rax
		call printf

		ret



section .data

Password: 	db "LoveKoala", 0x00

FmtChar:	db "%c", 0x00

FmtString:	db "%s", 0x00

FmtHex		db "| %x |", 0x00


section .bss

string:	resb 100

symbol:	resb 1

newline		equ 0x0a