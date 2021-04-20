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

;======================================



Start:	
	;mov ax, 123                     ; Number to convert
	;mov bx, 2			; Base of system number to convert
        ;mov di, (80*15 + 25) * 2	; Offest of message in VideoMemory
	;call NumberProcessing

	;mov ax, 123                     ; Number to convert
	;mov bx, 8			; Base of system number to convert
        ;mov di, (80*16 + 25) * 2		; Offest of message in VideoMemory
	;call NumberProcessing

	;mov ax, 123                     ; Number to convert
	;mov bx, 16			; Base of system number to convert
        ;mov di, (80*17 + 25) * 2	; Offest of message in VideoMemory
	;call NumberProcessing

	;mov ax, 4c00h
	;int 21h



	;==================================================================
	; Requires: decimal number (up to 65535) to convert in three number systems
	;	    and print on screen in ax
	;
	; Returns:  pointer in si on the length of number and beginning of number in si + 1
	;
	; Notes:    
	;
	; Damages:  ----
	;==================================================================
	global NumberProcessing	
	NumberProcessing proc

		push di                 ; There is offset in di
		call WriteSystem
	        call Convert        	; Adding to output number in another number system
		pop di
		
		mov ah, 1ah		; Colour of text to print
		call PushToVideo	; Pushing string in VideoMemory
	ret
	endp


	
	;====================================================================
	; Requires: decimal number (up to 65535) to convert in ax, pointer on 
	;	    output message in si and base of new number system in bx
	;
	;
	; Returns:  pointer in si on output message, that contains
	;
	; Notes:    
	;
	; Damages:  ax, bx, cx, dx, si
	;====================================================================
	global Convert
	Convert proc
	
		xor cx, cx
		xor dx, dx	; For division error, when (dx, ax) / bx is too big for ax		                                                

    digit_proc:	
		div bx
		
		call NumInChar
		push dx
		xor dx, dx

		inc cx		
		or ax, ax
		jnz digit_proc
		
		add [si - 1], cl

    digit_push:	
		pop dx
		mov [di], dl
                inc di
		loop digit_push
		
   	ret
	endp


        ;==================================================================
	; Requires: decimal number (up to 15) to convert in dx
	;
	; Returns:  symbol (it's code) in dx, that displays that number
	;
	; Notes:    That is more universal, then using "add dx, '0'" in 
	;	    Bin and Octal converting, but it's longer by 5 operations
	;
	; Damages:  ----
	;==================================================================
	global NumInChar	
	NumInChar proc
		cmp dx, 10
		jb  easy
		jmp hard

	easy:	add dx, '0'
	        jmp return

	hard:	sub dx, 10
	        add dx, 'A'

	return:

	ret
	endp



	;==================================================================
	; Requires: decimal number, base of number system in bx (2, 8 or 16)
	;
	; Returns:  ----
	;
	; Notes:    Writes number system name in bytes with adress in si
	;
	; Damages:  si, di
	;==================================================================
	global WriteSystem
	WriteSystem proc
		
		mov di, offset Output
		mov byte ptr [di], BASE_NAME_LEN
		inc di


		cmp bx, 2
		je bin
		cmp bx, 8
		je oct
		cmp bx, 16
		je hex

	   bin: mov si, offset Base_bin
                jmp write_base

	   oct:	mov si, offset Base_oct
		jmp write_base

	   hex:	mov si, offset Base_hex
		jmp write_base


    write_base: mov cl, byte ptr [di - 1]
		xor ch, ch
		
		push di
		rep movsb
		pop si

	ret
	endp



	;==================================================================
	; Requires: buffer in si, buffer length in cx, colour in ah
	;
	; Returns:  string in VideoMemory
	;
	; Notes:
	;
	; Damages:  ax, cx, es, si, di
	;==================================================================
       	global PushToVideo
	PushToVideo proc
		
		push es
		
		mov dx, videomem
		mov es, dx
		
		mov cl, [si - 1]		
		xor ch, ch
		cld

 out_symb_forw: lodsb
		stosw
		loop out_symb_forw

		pop es
	ret
	endp


Input:	db MAX_INP_LEN dup (?)

Output:	db MAX_OUT_LEN dup (?)

Base_bin: db 'bin: '

Base_oct: db 'oct: '

Base_hex: db 'hex: '

end Start