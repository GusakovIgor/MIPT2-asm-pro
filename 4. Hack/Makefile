run: out
	./CheckPassword.out

out: object
	gcc -no-pie -Wall -Wextra -pedantic -fsanitize=address bin/CheckPassword.o -o CheckPassword.out

object: CheckPassword.s
	nasm -f elf64 CheckPassword.s -o bin/CheckPassword.o

generate: Generator.cpp Input.txt
	g++ Generator.cpp -o bin/Generator.out
	bin/Generator.out