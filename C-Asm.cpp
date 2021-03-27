#include <stdio.h>

extern "C"
{
	int _MPrintf (char* format, ...);
}


const char* TestsFile = "Tests.txt";


int main ()
{
	printf ("\nHey! Here we're starting to play with a foreign func:\n");

	int arg_1 = 100;

	int arg_2 = 55;

	int result = arg_1 + arg_2;

	_MPrintf ("\nThank you for %s pretty interesting game, func%d%c\n", "that", result, '!');

	return 0;
}