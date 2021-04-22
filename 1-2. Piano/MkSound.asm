	;========================================
	; Requires: scancode of input symbal in ax
	;
	; Returns:  ----
	;
	; Damages:  ax, si
	;========================================
	SetNote proc

		push ds es ax
		mov ax, cs
		mov ds, ax
		mov es, ax
		pop ax

		push ax
		cmp ax, 15
		jb Up

	    mov si, offset NotesDown
		sub ax, 16
		jmp Choose

		Up:	
			mov si, offset NotesUp
			dec ax
			dec ax
			dec ax

		Choose:
			shl ax, 1
			add si, ax
			mov ax, [si]
			call PlayNote

		pop ax es ds

	ret
	endp
	        


	;========================================
	; Requires: defined PortbB and CmdReg
	;
	; Returns:  ----
	;
	; Damages:  al
	;========================================
	SetPause proc

		mov ax, P
		call PlayNote

	ret
	endp



	;========================================
	; Requires: defined PortbB and CmdReg
	;
	; Returns:  ----
	;
	; Damages:  al
	;========================================
	SetTimer proc

		in al, PortB 		
		or al, 00000011b
		out PortB, al		; Enabling second channel and speaker
		
		mov al, 10110110b	; Moving second channel to third mode
		out CmdReg, al

	ret
	endp



	;========================================
	; Requires: defined Gate2, note (freq) to play in ax
	;
	; Returns:  ----
	;
	; Damages:  ax
	;========================================
	PlayNote proc

		out Gate2, al
		mov al, ah
		out Gate2, al

	ret
	endp



	;========================================
	; Requires: defined Gate2
	;
	; Returns:  ----
	;
	; Damages:  ax, bx, cx, dx
	;========================================
	Waiting proc

        mov bx, cx

		mov ah, 86h
		
		mov cx, WaitHigh
		mov dx, WaitLow

		int 15h		

		mov cx, bx

	ret
	endp



    ;========================================
	; Requires: defined PortB
	;
	; Returns:  ----
	;
	; Damages:  al
	;========================================
	ResetTimer proc

		in al, PortB 		
		and al, 11111100b
		out PortB, al		; Enabling second channel and speaker

	ret
	endp


	NotesUp		dw C3_sh, E3_fl, P, F3_sh, G3_sh, B3_fl, P, C4_sh, E4_fl
	NotesDown	dw C3, D3, E3, F3, G3, A3, B3, C4, D4, E4