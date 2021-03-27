section .text
global _start
global _MPrintf

extern printf

%macro CheckBuffer 0
		cmp r8, OutSize
		ja %%BufferOverflow
		jmp %%BufferOk

	%%BufferOverflow:
		call ResetBuffer

	%%BufferOk:

%endmacro


_MPrintf:
                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rdi

                call MPrintf

                pop rdi
                pop rsi
                pop rdx
                pop rcx
                pop r8
                pop r9

                ret



;======= MPrintf function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, RSI, RDI, R8, R9
;
;	You can:
;
;		Print something using format string and arguments
;
;	You need:
;
;		Format string with those possible specificators:
;		
;		| %c | single character
;		
;		| %s | character string
;
;		| %d | signed integer
;
;		| %o | converts unsigned integer to the octal number
;
;		| %x | converts unsigned integer to the hexadecimal number
;
;		| %b | converts unsigned integer to the binary number
;		
;		To print '%', you should enter "%%" in format string
;
;====================================================================
MPrintf:
			push rdx

			mov rdx, rsp
			mov rsi, [rdx + 8*2]	; moving pointer to a format string (adresses for ret before it)

			lea rdx, [rdx + 8*3]	; moving pointer on the first argument to rdx
			mov rdi, Output

			xor r8, r8

	.loop:
			CheckBuffer

			lodsb

			test al, al
			jz .loop_end

			cmp al, '%'
			je SpecProc

			stosb
			inc r8

			jmp .loop

	.loop_end:

			pop rdx

			call PrintOutput

			ret




;======= SpecProc function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, RSI, RDI, R8, R9
;
;	You can:
;
;		Processing specificators in format string 
;			- filling Output in correct way
;			- increasing registers, that should be increased
;
;	You need:
;
;		| RAX |	number od symbols in Output
;		| RDX |	offset of current argument in stack
;
;		| RSI | pointer on the current symbol ('%') in format string
;		| RDI |	pointer on the end of Output
;
;=====================================================================
SpecProc:	
			cmp al, '%'
			jne Error.BadFormat

			cld
			lodsb

			cmp al, '%'
			je .PercentOut

			cmp al, 'b'
			jb Error.BadFormat

			cmp al, 'x'
			ja Error.BadFormat

			sub al, 'b'
			jmp qword [JumpTable + rax * 8]




	.BinArgOut:

			mov rax, [rdx]
			lea rdx, [rdx + 8]

			mov rbx, BinBase
			call NumberProc.Convert

			jmp MPrintf.loop


	.CharArgOut:
			mov al, byte [rdx]
			lea rdx, [rdx + 8]

			stosb
			inc r8

			jmp MPrintf.loop


	.DecArgOut:

			mov rax, [rdx]
			lea rdx, [rdx + 8]
			mov rbx, DecBase
			call NumberProc.Convert

			jmp MPrintf.loop


	.OctArgOut:
			
			mov rax, [rdx]
			lea rdx, [rdx + 8]

			mov rbx, OctBase
			call NumberProc.Convert

			jmp MPrintf.loop


	.StringArgOut:
			
			mov r9, [rdx]
			lea rdx, [rdx + 8]

			.StrCopy:
				mov al, byte [r9]
				inc r9

				test al, al
				jz MPrintf.loop

				stosb
				inc r8

				jmp .StrCopy


	.HexArgOut:

			mov rax, [rdx]
			lea rdx, [rdx + 8]

			mov rbx, HexBase
			call NumberProc.Convert

			jmp MPrintf.loop


	.PercentOut:

			stosb
			inc r8

			jmp MPrintf.loop





;======= NumberProc function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, R9
;
;	You can:
;
;		Converting number in other number system in string representation
;
;	You need:
;
;		| RAX |	number for converting
;		| RBX | base of number system for converting
;		| RDX |	offset of current argument in stack
;
;		| RSI | pointer on the current symbol in format string
;		| RDI |	pointer on the end of Output
;
;=======================================================================
NumberProc:

	.Convert:
		push rdx

		xor rcx, rcx
		xor rdx, rdx	; To avoid division error, when (rdx, rax) / rbx is too big for rax		                                                

	    .digit_proc:	
			div rbx
			
			jmp .NumInChar
			.NumInCharOut:

			push rdx
			xor rdx, rdx

			inc rcx		
			test rax, rax
			jnz .digit_proc

	    .digit_write:	
			pop rax
			stosb
	        inc r8
			
			loop .digit_write

		pop rdx

		ret



	.NumInChar:
		cmp rdx, 10
		jb  .easy
		jmp .hard

		.easy:	
			add rdx, '0'
		    jmp .return

		.hard:
			sub rdx, 10
		    add rdx, 'A'

		.return:

		jmp .NumInCharOut

		



;======= Error function ==========================================
;
;	It damages:
;		
;		RAX, RDX, RSI, RDI
;
;	You can:
;
;		Print on the screen error message (that depends on error)
;		And ending a program with 1 exit code
;
;	You need:
;
;		Nothing, just jmp on it
;
;=======================================================================
Error:		

	.BadFormat:
			mov rdx, ErrMsgLen_1
			mov rax, 0x01
			mov rsi, BadFormatMsg
			mov rdi, 1
			syscall

			jmp .ErrorEnd



	.ErrorEnd:
			mov rax, 0x3C
			xor rdi, rdi
			inc rdi
			syscall



;======= ResetBuffer function ==========================================
;
;	It damages:
;		
;		RAX, RDX, RSI, RDI, R8
;
;	You can:
;
;		Print on the screen string, that Output buffer contains
;		And moves the poiner on Output to the beginning of the buffer
;		And of course making r8 zero
;
;	You need:
;
;		| R8 | number of filled bytes in Output buffer
;rax, rcx, r11
;=======================================================================
ResetBuffer:
		push rdx
		push rsi
		call PrintOutput

		xor r8, r8
		xor rdi, rdi
		pop rsi
		pop rdx

		ret



;======= PrintOutput function ==========================================
;
;	It damages:
;		
;		RAX, RDX, RSI, RDI
;
;	You can:
;
;		Print on the screen string, that Output buffer contains
;
;	You need:
;
;		| R8 | number of filled bytes in Output buffer
;
;=======================================================================
PrintOutput:
		mov rdx, r8 	; Number of charecters printed
		mov rax, 0x01	; String output  function
		mov rsi, Output ; Output buffer
		mov rdi, 1		; stdout
		syscall

		ret





section .data

;======= Tests ======================================================

Test_1		db "Good %s is written here - %b%%%c", 0x0a, 0x00
Word_1		db "words", 0x00

Test_2		db "I %s %x on %d%%%c", 0x0a, 0x00
Word_2		db "love", 0x00
Numb_2_1	equ 3802
Numb_2_2	equ 100
Char_2		equ '!'


Test_3		db "That was %s to meet you%c", "And really intresting what will be %d in other systems:", 0x0a, "bin: %b", 0x0a, "oct: %o", 0x0a, "hex: %x", 0x0a, 0x00
Word_3		db "really nice", 0x00
Char_3		equ '!'
Numb_3		equ 65535


;====================================================================



;======= Output & Other Consts ======================================

OutSize		equ		1000

Output 		times OutSize	db	0x00

BinBase		equ 	2

OctBase		equ 	8

DecBase		equ 	10

HexBase		equ 	16

;====================================================================



;======= Errors =====================================================

BadFormatMsg	db "You've got bad specificators in format string"
ErrMsgLen_1		equ		$-BadFormatMsg

FormatTest:		db "Your number is %d", 0x00

;====================================================================



JumpTable					dq	SpecProc.BinArgOut		; for %b
							dq	SpecProc.CharArgOut		; for %c
							dq	SpecProc.DecArgOut		; for %d
	times	'o' - 'd' - 1	dq 	Error.BadFormat 		; for bad %(e-n)
							dq	SpecProc.OctArgOut		; for %o
	times	's' - 'o' - 1	dq 	Error.BadFormat 		; for bad %(p-r)
							dq	SpecProc.StringArgOut	; for %s
	times	'x' - 's' - 1	dq 	Error.BadFormat 		; for bad %(t-w)
							dq	SpecProc.HexArgOut		; for %x