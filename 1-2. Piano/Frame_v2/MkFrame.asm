.model tiny
.code
org 100h

; Constants ===========================

BASE_NAME_SIZE equ 5
MAX_INP_LEN equ 20
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

vert_side  = 0bah	; vertical side
horiz_side = 0cdh	; horizontal side

lu_corn = 0c9h  ; left-up
ld_corn = 0c8h  ; left-down
ru_corn = 0bbh	; right-up
rd_corn = 0bch  ; right-down

space = 20h	; free space

shadow_30 = 0b0h	; 30 %
shadow_50 = 0b1h        ; 50 %
shadow_70 = 0b2h        ; 70 %

;======================================



Start:	
	mov ax, 4c00h
	int 21h
	
	;========================================
	; Requires: defined x1, x2, y1, y2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	global DrawFrame
	DrawFrame proc
	    	mov bx, videomem
	    	mov es, bx                      ; Jump to videosegment 
		
		call ClearFrame
		call DrawBorders

	ret
	endp

	

        ;========================================
	; Requires: defined x1, x2, y1, y2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	global ClearFrame
	ClearFrame proc                                               
		mov di, lu_coord	; Coordinates of start

		mov ah, 00h		; Black background
		mov al, 20h		; Space symbol

		mov cx, y2 - y1

		clear:
			mov bx, cx
			mov cx, x2 - x1

			clear_line:
		        	stosw     	; mov es:[di], ax / inc di
				loop clear_line

			add di, (80 - (x2 - x1)) * 2

			mov cx, bx
			loop clear

	ret
	endp



        ;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	global DrawBorders
	DrawBorders proc         
		mov ah, 08h	; Grey on Black background

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
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	global DrawHorizontalBorder
	DrawHorizontalBorder proc
	   	mov cx, x2 - x1 - 1
		mov al, horiz_side

		rep stosw

	ret
	endp



        ;========================================
	; Requires: defined x1, x2, y1, y2                                       
	;                                                                        
	; Returns:  ----
	;
	; Damages:  al, cx, di
	;========================================
	global DrawVerticalBorder
	DrawVerticalBorder proc
	   	mov cx, y2 - y1 - 1
		mov al, vert_side

	v_symb: 
		mov es:[di], ax
		add di, 80*2
		loop v_symb

	ret
	endp




    
          
Input:	db MAX_INP_LEN dup (?)

Number:	db MAX_NUM_LEN dup (?)

Base_bin: db 'bin: '

Base_oct: db 'oct: '

Base_hex: db 'hex: '

end Start	 