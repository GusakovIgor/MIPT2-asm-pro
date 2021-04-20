	;==================================================================
	; Requires: numer (up to 65535) to print in ax
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, dx
	;==================================================================
	PrintNumber proc

		cmp ax, 10
		jb easy_out	; Если число < 10, его нужно просто вывести, добавив '0'
		or ah, ah
		jz norm_out     ; Если  9 < число < 256, то его нужно разбить на цифры
		jmp hard_out    ; А если число >= 256, то это немного другое разбиение


      easy_out:	mov dl, al
		add dl, '0'
		mov ah, 02h
		int 21h
		ret

      norm_out:	mov bh, 10
		xor dx, dx
		xor cx, cx	; Обнуляем счётчик
		
		digitn:	div bh

			add ah, '0'     ; Вычисление новой цифры числа
			mov dl, ah
			push dx         ; И запоминание её в стеке
			inc cx		; Увеличение счётчика

			xor ah, ah	; Восстановление ax

		        or al, al       ; Считываем новую цифру, если она есть
			jnz digitn
		
		jmp output
		
	
      hard_out:	mov bx, 10
		xor dx, dx
		xor cx, cx
		
		digith:	div bx

			add dx, '0'
			push dx
			inc cx

			xor dx, dx

			or ax, ax
			jnz digith

		jmp output
			

	output: mov ah, 02h
		pop dx
		int 21h
		loop output

	ret
	endp