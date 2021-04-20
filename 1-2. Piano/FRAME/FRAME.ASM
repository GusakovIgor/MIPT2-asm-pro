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


Start:		call GetString		; Reading a number

		mov cx, 2
		call NewLines		; Printing 2 new lines
		
		call ReadNumber		; Converts string into number

		push ax
		call DrawFrame          ; Drawing a frame
		pop ax
		
		call NumberProcessing	; Converts number in other number systems, and print them in screen
                

     terminate:	mov ax, 4c00h
		int 21h




	;==================================================================
	; Requires: Input buffer with constant size MAX_INP_LEN (up to 254)
	;
	; Returns:  Char buffer with beginnig at si + 1, with it's
	;	    length in [si]
	;
	; Damages:  ah, si, dx
	;==================================================================
	GetString proc

		mov ah, 0ah
		mov dx, offset Input
		mov si, dx
		mov byte ptr [si], MAX_INP_LEN
		
		int 21h
		inc si
	ret
	endp



	;==================================================================
	; Requires: number of lines to print in cx
	;
	; Returns:  ----
	;
	; Damages: ah, dl, cx
	;==================================================================
	NewLines proc

	mark:	mov ah, 02h
		
		mov dl, 0dh
		int 21h
		mov dl, 0ah
		int 21h

		loop mark
	ret
	endp	
	
	
	
	;==================================================================
	; Requires: number of lines to print in cx
	;
	; Returns:  ----
	;
	; Damages: ah, dl, cx
	;==================================================================
	StrLen proc
		mov cx, BASE_NAME_SIZE
	ret
	endp



        ;==================================================================
	; Requires: pointer on buffer in si (where si + 1 - beginning of the string 
	;				      and [si]    - length of string)
	;
	; Returns:  number from the buffer in ax
	;
	; Damages:  ax, bx, cx, dx
	;==================================================================
	ReadNumber proc
		
		xor ax, ax
		xor cx, cx
		mov cl, byte ptr [si]
		mov dx, cx	; Сохраняем количество цифр
		inc si		; Переходим к буфферу
		
    store_nums:	sub byte ptr [si], '0'
		lodsb
		push ax		; Пушим каждую цифру в стек
                loop store_nums
                           
		mov cx, dx      ; Возвращаем в cx кол-во цифр
		mov bx, 10	; Перескакиваем умножение на 1 первой цифры
		dec cx
		pop dx
		
		or cx, cx       ; Если цифра была одна - выходим
		jz quit		
      
  count_number: pop ax          ; Считываем новую цифру из стека

		mov di, dx
		mul bx          ; Умножаем цифру на степень 10
		mov dx, di
                add dx, ax	; Прибавляем произведение к сохранённой сумме (будущему числу)

		mov di, dx      ; Умножаем bx на 10
		mov ax, 10
		mul bx
		mov dx, di
		mov bx, ax
		
		loop count_number
		

	  quit: mov ax, dx
                
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

		mov bx, 2		; Base of system number to convert
		push ax
		mov ah, 1ah		; Colour of printed text
		mov di, lu_coord        ; Offset to left corner of frame
		add di, 80*2 + 1*2	; Additional offset into frame
		call WriteSystem
		pop ax

		push ax
		mov ah, 1ah
		call Convert            ; Converting number in string in other number system
		add di, dx
		push 0
		call PushToVideo	; Pushing converted string in videomemory
               	pop ax

	;	mov bx, 8
	;	push ax
	;	call Convert
	;	mov ah, 1ah
	;	mov di, lu_coord
	;	add di, 80*2*2 + 1*2
	;	call WriteSystem
	;	add di, dx
	;	push 0
	;	call PushToVideo
        ;	pop ax
        ;
         ;       mov bx, 16
	;	call Convert
	;	mov ah, 1ah
	;	mov di, lu_coord
	;	add di, 80*3*2 + 1*2
	;	call WriteSystem
	;	add di, dx
	;	push 0
	;	call PushToVideo
	ret
	endp


	
		
	;==================================================================
	; Requires: decimal number (up to 65535) to convert in ax, 
	;	    and base of new number system in bx
	;
	; Returns:  pointer in si on number in number system, which base was in bx
	;	    and its length in cx
	;
	; Notes:   з 
	;
	; Damages:  ax, bx, cx, dx, si
	;==================================================================
	Convert proc
	
		xor cx, cx
		xor dx, dx
		
		mov si, offset Number

    digit_proc:	div bx
		
		call NumInChar
		
		mov [si], dl
                inc si
		inc cx
		xor dx, dx
		
		or ax, ax
		jnz digit_proc
		
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

    write_base: call StrLen
		push 1
		call PushToVideo
	ret
	endp



	;==================================================================
	; Requires: buffer in si, and buffer length in bx, 1/0 in stack (forward or backward reading)
	;
	; Returns:  ----
	;
	; Notes:
	;
	; Damages:  ax, cx, es, si, di
	;==================================================================
       	PushToVideo proc
		
		mov dx, videomem
		mov es, dx

		pop dx
		or dx, dx
		jz out_symb_back
		
		cld

 out_symb_forw: lodsb
		stosw
		loop out_symb_forw

		jmp stop_pushing

 out_symb_back:	std
		lodsb
		cld
		stosw
		loop out_symb_back
  stop_pushing:

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
	
	
	
        ;========================================
	; Requires: defined x1, x2, y1, y2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, es, di
	;========================================
	ClearFrame proc                                               
		mov di, lu_coord	; Coordinates of start

		mov ah, 10h		; Black background
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
	DrawBorders proc         
		mov ah, 18h	; Grey on Black background

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