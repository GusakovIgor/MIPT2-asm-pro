	;==================================================================
	; Requires: decimal number (up to 65535) to convert in three number systems
	;	    and print on screen in ax
	;
	; Returns:  ----
	;
	; Notes:    
	;
	; Damages:  all
	;==================================================================
	ShowNumber proc

		push bx cx dx si di ds es ax
		mov ax, cs
		mov ds, ax
		mov es, ax
		pop ax

		push ax
		mov bx, 10					; Base of system number to convert
        mov di, lu_coord + 160 + 2	; Offest of message in VideoMemory
		call NumberProcessing
		pop ax

		push ax
		mov bx, 2
        mov di, ru_coord + 80 * 2 - 22 * 2
		call NumberProcessing
		pop ax

		push ax
		mov bx, 8
        mov di, ru_coord + 160 * 2 - 22 * 2
		call NumberProcessing
		pop ax

		push ax
		mov bx, 16
        mov di, ru_coord  + 240 * 2 - 22 * 2
		call NumberProcessing
		pop ax

		pop es ds di si dx cx bx

	ret
	endp


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
	NumberProcessing proc

		push di             ; There is offset in di
		call WriteSystem
	    call Convert        ; Adding to output number in another number system
		pop di
		
		mov ah, 0Dh			; Colour of text to print
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
	WriteSystem proc
		
		mov di, offset Output
		mov byte ptr [di], BASE_NAME_LEN
		inc di

		cmp bx, 10
		je dec

		cmp bx, 2
		je bin
		cmp bx, 8
		je oct
		cmp bx, 16
		je hex

		dec:	mov si, offset Base_dec
				jmp write_base

		bin: 	mov si, offset Base_bin
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
	; Damages:  ax, cx, dx, es, si, di
	;==================================================================
	PushToVideo proc
		
		push es
		
		mov dx, videomem
		mov es, dx
		
		mov cl, [si - 1]		
		xor ch, ch
		mov dx, MAX_INP_LEN
		sub dx, cx
		cld

	 	out_symb_forw: 
	 		lodsb
			stosw
			loop out_symb_forw
			
			mov cx, dx
			mov ah, 00h

		clean:  
			lodsb
			stosw
			loop clean

			pop es

	ret
	endp


Base_dec: db 'inp: '

Base_bin: db 'bin: '

Base_oct: db 'oct: '

Base_hex: db 'hex: '