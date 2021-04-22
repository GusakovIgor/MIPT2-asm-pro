	;========================================
	; Requires: defined x1, x2, y1, y2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	DrawKeys proc
		
		push es
	    mov bx, videomem
	    mov es, bx			; Jump to videosegment 
		
		call ClearKeys
		call DrawKeyBorders
		pop es

	ret
	endp



	;========================================
	; Requires: scan code in ax
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	DrawKeyPress proc
		
		push es
	    mov bx, videomem
	    mov es, bx			; Jump to videosegment 
		
		push ax
		cmp ax, 15
		ja @@Down
		cmp ax, 5
		je @@continue
		cmp ax, 9
		je @@continue		
		
		call DrawShadowUp
		jmp @@continue

	@@Down:	
		call DrawShadowDown
	
	@@continue:
		pop ax

		pop es

	ret
	endp
	

	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	DrawShadowUp proc

		sub ax, 3
		cmp ax, 3
		jb @@first
		cmp ax, 7
		jb @@second
		jmp @@third


	@@first:
		mov di, (80 * (ky1 + 1) + kx1 + 1 + key_len) * 2		; Coordinates of start
		mov cx, ax
		jmp @@to_right_key

	@@second:
		mov di, (80 * (ky1 + 1) + kx1 + 1 + 6 * (key_len)) * 2
		sub ax, 3
		mov cx, ax
		jmp @@to_right_key

	@@third:
		mov di, (80 * (ky1 + 1) + kx1 + 1 + 13 * (key_len)) * 2
		sub ax, 7
		mov cx, ax		
	

	@@to_right_key:
		add di, (key_len) * 2 * 2
		loop @@to_right_key

		mov ah, 3Bh
		mov al, shadow_50

		mov cx, key_height - 4

		@@fill:
			mov bx, cx
			mov cx, key_len - 1

			@@fill_line:
		        stosw
				loop @@fill_line

			add di, (80 - (key_len - 1)) * 2

			mov cx, bx
			loop @@fill

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	DrawShadowDown proc

		sub ax, 16
		cmp ax, 3
		jb @@first
		cmp ax, 7
		jb @@second
		jmp @@third


	@@first:
		mov di, (80 * (ky1 + 1) + kx1 + 1) * 2		; Coordinates of start
		mov cx, ax
		jmp @@to_right_key

	@@second:
		mov di, (80 * (ky1 + 1) + kx1 + 1 + 5 * (key_len)) * 2
		sub ax, 3
		mov cx, ax
		jmp @@to_right_key

	@@third:
		mov di, (80 * (ky1 + 1) + kx1 + 1 + 12 * (key_len)) * 2
		sub ax, 7
		mov cx, ax		
	
	
	@@to_right_key:
		add di, key_len * 2 * 2
		loop @@to_right_key
		mov dx, ax

		mov ah, 5Dh
		mov al, shadow_50

		mov cx, key_height - 1

		@@fill:
			mov bx, cx
			mov cx, key_len - 1

			@@fill_line:
		        	stosw
				loop @@fill_line

			add di, (80 - (key_len - 1)) * 2

			mov cx, bx
			loop @@fill
		
	ret
	endp


	
	;========================================
	; Requires: defined kx1, kx2, ky1, ky2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	ClearKeys proc

		mov di, (80 * ky1 + kx1) * 2	; Coordinates of start

		mov ah, 00h						; Black background
		mov al, 20h						; Space symbol

		mov cx, ky2 - ky1

		@@clear:
			mov bx, cx
			mov cx, kx2 - kx1

			@@clear_line:
		        	stosw
				loop @@clear_line

			add di, (80 - (kx2 - kx1)) * 2

			mov cx, bx
			loop @@clear

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	DrawKeyBorders proc

		mov ah, 09h						; Grey on Black background
                
		mov di, (80 * ky1 + kx1) * 2	; Coordinates of start
		call DrawUp

		call DrawSides

		mov di, (80 * ky2 + kx1) * 2               
		call DrawDown

		mov di, (80 * (ky1 + 5) + kx1) * 2
		call DrawMid

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawSides proc

		mov cx, key_height - 1
		call DrawVerticalKey


		mov cx, num_keys - 1
		add di, key_len*2

	    @@next_side:	
			push cx

			mov al, triangle_down
			mov es:[di], ax		

			mov cx, key_height - 4
			call DrawVerticalKey
			add di, key_len*2

			pop cx
			loop @@next_side
     
		mov cx, key_height - 1
		call DrawVerticalKey

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawUp proc

		mov cx, key_len * num_keys
		call DrawHorizontalKey

		mov al, ru_corn
		mov es:[di + key_len * num_keys * 2], ax

		mov al, lu_corn
		mov es:[di], ax

	ret
	endp


	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawMid proc

		add di, (key_len) * 2
		mov cx, num_dies
	
		@@next_side:
			cmp cx, 5
			je skip_side
			cmp cx, 2
			je skip_side
			jmp fill_side

			skip_side:
				add di, (key_len) * 2

			fill_side:
				push cx
				mov al, ld_corn
				mov es:[di], ax
				inc di
				inc di

				mov cx, key_len - 1
				call DrawHorizontalKey

				inc di
				inc di
				mov al, triangle_down
				mov es:[di], ax
				mov cx, key_height - 5
				call DrawVerticalKey
				mov al, triangle_up
				mov es:[di + 80 * (key_height - 5) * 2], ax
				dec di
				dec di

				mov al, rd_corn
				mov es:[di + (key_len - 1) * 2], ax

				add di, ((key_len) * 2 - 1) * 2
				
				pop cx

			loop @@next_side

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, bx, cx, di
	;========================================
	DrawDown proc

		mov cx, key_len * num_keys
		call DrawHorizontalKey

		mov al, triangle_up
		mov es:[di + key_len * 12 * 2], ax

		mov al, triangle_up
		mov es:[di + key_len * 5 * 2], ax
		
		push di
		mov cx, 3
		add di, key_len * 5 * 2 - 80 * 4 * 2
		call DrawVerticalKey

		mov cx, 3
		add di, key_len * 7 * 2
		call DrawVerticalKey
		pop di

		mov al, ld_corn
		mov es:[di], ax

		mov al, rd_corn
		mov es:[di + key_len * num_keys * 2], ax

	ret
	endp
	

	
	;========================================
	; Requires: Number of symbols to print in cx                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawHorizontalKey proc

		mov al, horiz_side
		
		push di
		rep stosw
		pop di

	ret
	endp



	;========================================
	; Requires: Number of symbols to print in cx                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, bx, cx
	;========================================
	DrawVerticalKey proc

		mov al, vert_side
		mov bx, di

		@@v_symb:
			add di, 80*2
			mov es:[di], ax
			loop @@v_symb

		mov di, bx

	ret
	endp