global main
extern printf

section .text

main:
			mov rdi, FormatTest
			mov rsi, String

			xor rax, rax
			call printf 

			mov rax, 0x3C
			xor rdi, rdi
			syscall





section .data

FormatTest:		db "Your number is %s", 0x0a, 0x00