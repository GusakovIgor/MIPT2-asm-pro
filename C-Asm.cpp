#include <stdio.h>
#include <stdlib.h>

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

	char* LongString = (char*) calloc (2000, sizeof(char));

	FILE* test = fopen ("Test.txt", "rb");

	fscanf (test, "%s", LongString);

	fclose (test);
	
	printf ("\n%s\n", LongString);

	//_MPrintf ("\nThank you for %s pretty %d%% interesting game, func%c\nbin: %b\noct: %o\nhex: %x\n%s", LongString, 100, '!', 100, 100, 100, "bye!\n");
	//_MPrintf ("\nThank you for %d%% good game%c\n", 100, '!' );//"my dear func");
	_MPrintf ("%s", LongString);
	return 0;