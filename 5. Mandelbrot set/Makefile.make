SDL: SdlFuncs.cpp
	clear
	g++ -Wall -Wextra -pedantic SdlFuncs.cpp -lSDL2 -o bin/SdlFuncs.out
	bin/SdlFuncs.out

MDL: Mandelbrot.cpp SdlFuncs.cpp
	clear
	g++ -Wall -Wextra -pedantic Mandelbrot.cpp SdlFuncs.cpp -lSDL2 -o bin/Mandelbrot.out
	bin/Mandelbrot.out