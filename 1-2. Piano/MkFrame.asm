	;==================================================
	; Requires: defined x1, x2, y1, y2, corners coords 
	;		    and frame symbols codes
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;==================================================
	DrawFrame proc
		
		push es
	    mov bx, videomem
	    mov es, bx			; Jump to videosegment 
		
		call ClearFrame
		call DrawBorders
		pop es

	ret
	endp

	

    ;========================================
	; Requires: defined x1, x2, y1, y2, corners coords 
	;		    and frame symbols codes
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	ClearFrame proc 

		mov di, lu_coord	; Coordinates of start

		mov ah, 00h			; Black background
		mov al, 20h			; Space symbol

		mov cx, y2 - y1

		clear:
			mov bx, cx
			mov cx, x2 - x1

			clear_line:
		        	stosw
					loop clear_line

			add di, (80 - (x2 - x1)) * 2

			mov cx, bx
			loop clear

	ret
	endp



	;========================================
	; Requires: defined x1, x2, y1, y2, corners coords 
	;		    and frame symbols codes                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  ax, cx, es, di
	;========================================
	DrawBorders proc

		mov ah, 09h		; Grey on Black background

		mov di, lu_coord
		mov al, lu_corn
		stosw
		call DrawHorizontalBorder

		mov di, lu_coord
		add di, 80*2
		call DrawVerticalBorder

		mov di, ld_coord
		mov al, ld_corn
		stosw
	    call DrawHorizontalBorder

		mov di, ru_coord
		add di, 80*2
        call DrawVerticalBorder

		mov di, ru_coord
		mov al, ru_corn
		stosw

		mov di, rd_coord
		mov al, rd_corn
		stosw

	ret
	endp


	
	;========================================
	; Requires: defined x1, x2, y1, y2, corners coords 
	;		    and frame symbols codes                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawHorizontalBorder proc

	   	mov cx, x2 - x1 - 1
		mov al, horiz_side

		rep stosw

	ret
	endp



    ;========================================
	; Requires: defined x1, x2, y1, y2, corners coords 
	;		    and frame symbols codes                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	DrawVerticalBorder proc

	   	mov cx, y2 - y1 - 1
		mov al, vert_side

		v_symb: 
			mov es:[di], ax
			add di, 80*2
			loop v_symb

	ret
	endp	 