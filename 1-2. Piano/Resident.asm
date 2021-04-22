	Toxic proc

		push ax bx si di ds es

		call GetCode
		call ShowNumber

		cmp al, 30
		je StopPiano

		cmp al, 31
		je StartPiano

		cmp al, 3
		jae CheckPress_h
		jmp CheckRelease_l
	
		CheckPress_h:
			cmp al, 11
			jbe Press
	        jmp CheckRelease_l
		
		CheckRelease_l:
			cmp al, 131
			jae CheckRelease_h
			jmp CheckUpPress_l

		CheckRelease_h:
			cmp al, 139
			jbe Release
			jmp CheckUpPress_l



		CheckUpPress_l:
			cmp al, 16
			jae CheckUpPress_h
			jmp CheckUpRelease_l
		
		CheckUpPress_h:
			cmp al, 25
			jbe Press
			jmp CheckUpRelease_l
		
		CheckUpRelease_l:
			cmp al, 144
			jae CheckUpRelease_h
			jmp StdEnd

		CheckUpRelease_h:
			cmp al, 153
			jbe Release
			jmp StdEnd


		StartPiano:
			call SetTimer
			jmp SpecialEnd

		StopPiano:
			call ResetTimer
			jmp SpecialEnd



		Press:
			call SetNote
			call DrawKeyPress
			jmp SpecialEnd

		Release:
			call SetPause
			call DrawKeys
			jmp SpecialEnd


		
		SpecialEnd:	
			call TalkToPorts

			pop es ds di si bx ax
			iret		; InteraptReturn - returning taking into account offset and segment (and pop flags from stack)

		StdEnd:	
			pop es ds di si bx ax

		db 0eah 	; Calling jump far that requires adresses after it
old_ofs dw 0		; Here they are! Adresses
old_seg	dw 0        ; We put them in the beggining of program

	endp



	;==================================================================
	; Requires: ----
	;
	; Returns:  Scancode of last pressed key in ax
	;
	; Damages:  ax
	;==================================================================
	GetCode proc

		in al, 60h       ; Reading Keyboard Port (returns most recent scancode)
		xor ah, ah

	ret
	endp
	


	;==================================================================
	; Requires: ----
	;
	; Returns:  Turning off some features of Keyboard, and turning on keyboard
	;	    	also telling Interrupt Controller that interrupt ended
	;
	; Damages:  al
	;==================================================================	
	TalkToPorts proc

		in al, 61h      ; Reading Keyboard Command Lines
		or al, 80h 		; Turn 4-7 bits of 61 PPI port to 1
		out 61h, al
		and al, 7Fh		; Enable keyboard (turn 7-th bit of 61 PPI port to 0) 
		out 61h, al

		mov al, 20h     ; Sending End-of-Interrupt signal
		out 20h, al     ; to the Interrupt controller

	ret
	endp



    ;==================================================================
	; Requires: standart BIOS segment in es, offset to memory that contains info 
	;	    	about what to do after keyboard interrupt in bx
	;
	; Returns:  instead of standart function, "Toxic" will be called
	;			to process keyboard interrupt
	;
	; Damages:  ax
	;==================================================================
	ChangeIntFunc proc

		cli					; Disable system interrupts

		mov ax, es:[bx]
		mov old_ofs, ax		; Moving offset of old function that used to execute at 9-th interrupt
		mov ax, es:[bx + 2]
		mov old_seg, ax		; Moving code segment in which this function is 

		mov es:[bx], offset Toxic
									;
		mov ax, cs          		; <---- If we enter something here without disabling system interrupts 
									; 		some random code (with offset Toxic from standart BIOS segment) will execute
		mov es:[bx + 2], ax
		
		sti					; Enable system interrupts

	ret
	endp



	;==================================================================
	; Requires: End_of_Prog label after "Toxic" function that will process interrupt
	;
	; Returns:  Making programm resident (not deleting it from memory)
	;	    	so code of "Toxic" function can be executed after programs end
	;
	; Damages:  ax, dx
	;==================================================================
	LoadProg proc

		mov ax, 3100h				; Make program resident, so it will stay in memory and execute 
		mov dx, offset End_of_Prog	; Label where resident code ends (it's in Main.asm) 
		shr dx, 4					; Division by 16 (it needs for 31 func of 21 interrupt)
		inc dx
		int 21h

	ret
	endp