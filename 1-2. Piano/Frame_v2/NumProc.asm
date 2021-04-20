.model tiny
.code
org 100h

; Constants ===========================

BASE_NAME_SIZE equ 5
MAX_INP_LEN equ 20

;======================================



Start:		
	;==================================================================
	; Requires: Input buffer with constant size MAX_INP_LEN (up to 254)
	;
	; Returns:  Char buffer with beginnig at si + 1, with it's
	;	    length in [si]
	;
	; Damages:  ah, si, dx
	;==================================================================
	global GetString
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
	; Requires: pointer on buffer in si (where si + 1 - beginning of the string 
	;				      and [si]    - length of string)
	;
	; Returns:  number from the buffer in ax
	;
	; Damages:  ax, bx, cx, dx
	;==================================================================
	global ReadNumber
	ReadNumber proc
		
		xor ax, ax
		xor cx, cx
		xor di, di

		mov cl, [si]
		mov dx, cx	; Сохраняем количество цифр
		inc si		; Переходим к буфферу
		cld
		
    store_nums:	sub byte ptr [si], '0'
		lodsb
		push ax		; Пушим каждую цифру в стек
                loop store_nums
                           
		mov cx, dx      ; Возвращаем в cx кол-во цифр
		mov bx, 1	; Множитель для первой цифры		
      
  count_number: pop ax          ; Считываем новую цифру из стека

		mul bx          ; Умножаем цифру на степень 10
                add di, ax	; Прибавляем произведение к сохранённой сумме (будущему числу)

		mov ax, 10	; Умножаем bx на 10
		mul bx
		mov bx, ax
		
		loop count_number
		

	  quit: mov ax, di
                
	ret
	endp



Input:	db MAX_INP_LEN dup (?)
   
end Start