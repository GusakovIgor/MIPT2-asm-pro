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