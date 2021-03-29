section .text
global _start
global _MPrintf

extern printf

%macro CheckBuffer 0
		cmp r8, OutSize - 10
		ja %%BufferOverflow
		jmp %%BufferOk

	%%BufferOverflow:
		call ResetBuffer

	%%BufferOk:

%endmacro


_MPrintf:
				pop r12		; taking out return adress (r11 damages with call)

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

                push r12	; pushing return adress back

                ret



;======= MPrintf function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, RSI, RDI, R8, R9, R10
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
			push rbp

			mov rbp, rsp
			mov rsi, [rbp + 8*2]	; moving pointer to a format string (adresses for ret and rbp before it)

			lea rbp, [rbp + 8*3]	; moving to rbp pointer on the first argument
			mov rdi, Output

			xor r8, r8

	.loop:
			CheckBuffer

			lodsb

			test al, al
			jz .loop_end

			cmp al, '%'
			jne .NotSpec

			call SpecProc
			jmp .loop

	.NotSpec:
			call PrintSymbol

			jmp .loop

	.loop_end:

			pop rbp

			call PrintOutput

			ret




;======= SpecProc function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RBP, RSI, RDI, R8, R9, R10
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
;		| rbp |	offset of current argument in stack
;
;		| RSI | pointer on the current symbol ('%') in format string
;		| RDI |	pointer on the end of Output
;
;=====================================================================
SpecProc:	
			cld
			lodsb

			cmp al, '%'
			je .Percent

			cmp al, 'b'
			jb .Error

			cmp al, 'x'
			ja .Error

			sub al, 'b'
			call qword [JumpTable + rax * 8]

	.SpecProcEnd:
			ret
	

	.Percent:
			call PrintSymbol

			jmp .SpecProcEnd

	
	.Error:
			sub al, 'b'

			call BadFormat
	
			jmp .SpecProcEnd




PrintSymbol:

		stosb
		inc r8

		ret


BinArgOut:

		mov rax, [rbp]
		lea rbp, [rbp + 8]

		mov rbx, BinBase
		call Convert

		ret


CharArgOut:
		mov al, [rbp]
		lea rbp, [rbp + 8]

		call PrintSymbol

		ret


DecArgOut:

		mov rax, [rbp]
		lea rbp, [rbp + 8]
		mov rbx, DecBase
		call Convert

		ret


OctArgOut:
		
		mov rax, [rbp]
		lea rbp, [rbp + 8]

		mov rbx, OctBase
		call Convert

		ret


StringArgOut:
		
		mov r9, [rbp]
		lea rbp, [rbp + 8]

		.StrCopy:

			CheckBuffer

			mov al, byte [r9]
			inc r9

			test al, al
			jz .return

			stosb
			inc r8

			jmp .StrCopy

		.return:
			ret


HexArgOut:

		mov rax, [rbp]
		lea rbp, [rbp + 8]

		mov rbx, HexBase
		call Convert

		ret





;======= Convert function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, R10, R11
;
;	You can:
;
;		Converting number in other number system in string representation
;
;	You need:
;
;		| RAX |	number for converting
;		| RBX | base of number system for converting
;
;		| RDI |	pointer on the end of Output
;
;=======================================================================
Convert:

	xor rcx, rcx
	xor rdx, rdx	; To avoid division error, when (rdx, rax) / rbx is too big for rax		                                                
	cmp rbx, 10
	je .decimal_proc

	
	dec rbx
	call FindPower
	xor r10, r10
	call Powers2Proc

	jmp .digit_write

	.decimal_proc:
		call DecimalProc

    .digit_write:	
		pop rax
		call PrintSymbol
		
		loop .digit_write

	ret


;======= FindPower function ===========================================
;
;	It damages:
;		
;		RCX
;
;	You can:
;
;		If we imagine equation 2^n = rbx, you can find n in rcx
;
;	You need:
;
;		| RBX | base of number system for converting
;
;=======================================================================
FindPower:
	
	push rbx
	xor rcx, rcx
	
	.loop:
		shr rbx, 1
		inc rcx
		test rbx, rbx
		jnz .loop

	pop rbx
	ret


;======= Powers2Proc function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, R10, R11
;
;	You can:
;
;		Pushing in stack all digits of rax in num. system with base 2, 8 or 16
;		And moves to rcx number of digits in converted rax
;
;	You need:
;
;		| RAX |	number for converting
;		| RBX | base of number system for converting - 1
;
;=======================================================================
Powers2Proc:
	pop r11
	
	.loop

		mov rdx, rbx
		and rdx, rax
		shr rax, cl

		mov dl, byte [BaseChars + rdx]

		push rdx
		xor rdx, rdx

		inc r10
		test rax, rax
		jnz .loop
	
	mov rcx, r10

	push r11
	ret


;======= Powers2Proc function ===========================================
;
;	It damages:
;		
;		RAX, RBX, RCX, RDX, R11
;
;	You can:
;
;		Pushing in stack all digits of rax in  decimal num. system
;		And moves to rcx number of digits in converted rax
;
;	You need:
;
;		| RAX |	number for converting
;		| RBX | base of number system for converting
;
;=======================================================================
DecimalProc:
	pop r11

	.loop:

		div rbx

		mov dl, byte [BaseChars + rdx]

		push rdx
		xor rdx, rdx

		inc rcx		
		test rax, rax
		jnz .loop

	push r11
	ret



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
BadFormat:
		mov byte [rdi], '%'
		inc rdi
		inc r8

		add al, 'b'
		stosb
		inc r8

		ret



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
;
;=======================================================================
ResetBuffer:
		push rsi

		call PrintOutput

		xor r8, r8
		mov rdi, Output
		pop rsi

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

Check 		db "bac", 0x0a, 0x00


;====================================================================



;======= Output & Other Consts ======================================

OutSize		equ		1000

Output 		times OutSize	db	0x00

BinBase		equ 	2

OctBase		equ 	8

DecBase		equ 	10

HexBase		equ 	16

BaseChars	db 		"0123456789abcdef"

;====================================================================



;======= Errors =====================================================

BadFormatMsg	db "You've got bad specificators in format string", 0x0a
ErrMsgLen_1		equ		$-BadFormatMsg

FormatTest:		db "Your number is %d", 0x00

;====================================================================



JumpTable					dq	BinArgOut		; for %b
							dq	CharArgOut		; for %c
							dq	DecArgOut		; for %d
	times	'o' - 'd' - 1	dq 	BadFormat 		; for bad %(e-n)
							dq	OctArgOut		; for %o
	times	's' - 'o' - 1	dq 	BadFormat 		; for bad %(p-r)
							dq	StringArgOut	; for %s
	times	'x' - 's' - 1	dq 	BadFormat 		; for bad %(t-w)
							dq	HexArgOut		; for %xsection .text