NO_SSE=1
USE_SSE=2

MDL: MDL_Classic.cpp SdlFuncs.cpp
	clear
	g++ -O3 -mavx2 -mavx MDL_Classic.cpp SdlFuncs.cpp -DOptimized=NO_SSE -lSDL2 -o bin/MDL_Classic.out
	bin/MDL_Classic.out

MDL_SSE: MDL_Classic.cpp SdlFuncs.cpp
	clear
	g++ -O3 -mavx2 -mavx MDL_Classic.cpp SdlFuncs.cpp -DOptimized=USE_SSE -lSDL2 -o bin/MDL_Classic.out
	bin/MDL_Classic.out

MDL_RECT: MDL_Rectangle.cpp SdlFuncs.cpp
	clear
	g++ -O3 -mavx2 -mavx MDL_Rectangle.cpp SdlFuncs.cpp -lSDL2 -o bin/MDL_Rectangle.out
	bin/MDL_Rectangle.out

MDL_RECT_SSE: MDL_Rectangle.cpp SdlFuncs.cpp
	clear
	g++ -O3 -mavx2 -mavx MDL_Rectangle.cpp SdlFuncs.cpp -DOptimized=USE_SSE -lSDL2 -o bin/MDL_Rectangle.out
	bin/MDL_Rectangle.out