## This folder contains MPrintf - my version of printf from stdio.h

This description is copy of my notion [paper](https://www.notion.so/Printf-e87e012efd874328a32bbd6919af804c)

Before we start, we've got a few files here. What do they mean?

- In MPrintf.s you can find realization of MPrintf function
- Call_C_Printf.s contains calling standart printf from assempber programm
- And there is a programm in C-Asm.cpp that parsing tests.txt file and outputs everything form there with MPrintf and with standart printf for comparision

## So, idea of printf:

- We've got *format string*, this is string like that `"Good %s is written here%c"`.
- It can have *specificators.* In example, here we can see 2 of them: `%s` and `%c`

		| %c | single character
		
		| %s | character string

		| %d | signed integer

		| %o | converts unsigned integer to the octal number

		| %x | converts unsigned integer to the hexadecimal number

		| %b | converts unsigned integer to the binary number

- It's more of them in real printf, but MPrintf understands only those 6
- And if you need `'%'` symbol in your output, you should type `"%%"` on the place you need it in format string

## Realization of MPrintf:

- Everything is organized in such a way, that all arguments lia on the stack (first arg on the top).
- We will have pointer on the format string in `rsi`, pointer to allocated `Output` buffer in `rdi` and pointer on stack in `rbp`.
- In `r8` we will count number of symbols in `Output`.
- We will go by the format string and copy all symbols, which are not specifiers.
- If we met specifier we call `SpecProc` function.
    - `SpecProc`
        - Main idea is `JumpTable`.
        - `JumpTable` - array with adresses of functions that corresponding to letters (you can index in that array by letter codes).
        - For example, `StringArgOut` corresponding to `'s'`, and `BadFormat` corresponding to `'p'`.
        - We reading a letter and call corresponding function.
- After we iterated over entire format string we call `PrintOutput`, that printing `Output` buffer with `syscall`
- Returning back (cleaning everything up by the way)

## Buffer overflow protection:

- It's really simple. If buffer is filled, we will put it on the screen, and start filling buffer again:
    - We will check buffer after processing each new argument
    - If buffer is full (`r8 > Outsize - 10`), print it out and move pointer on buffer to its beginning
    - We subtract 10 from `Outsize` just in case

## Call C from Assembly:

- We need rax zeroed cause it tels `printf` how many vector registers used
- The order of registers that reading like args first:
    - `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`

## Call Assembly from C

- Cool Unit testing for MPrintf

## Refatoring:

- ~~Process call of `MPrintf` in `_MPrintf` (there is return adress after pushed registers)~~
- `~~rdx → rbp~~`
- "~~Make `.NumInChar` some kind of jump table (array with possible symbols "0123...9ab...f")~~
- ~~Make everything in functions.~~
- ~~Convertation for 2, 8, 16 with binary operations~~
- Fence macroses with nop (find out what is nop...)
- ~~Delete jmp from `.BadFormat`~~
- ~~Add makefile~~
- ~~Process errors like in libc (not exit every time)~~

[About stack in asm](https://it-black.ru/stek-v-assembler/)

[About shr, shl commands](https://programm.ws/page.php?id=134)
