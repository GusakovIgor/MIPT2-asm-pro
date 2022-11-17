#include <stdio.h>

typedef long long int ll;

const int NUM_SYMBOLS = 1047492;

const char* FileName = "Input.txt";

int main ()
{
	FILE* file = fopen (FileName, "w");
	
	char symbol = 0;
	for (ll i = 0; i < NUM_SYMBOLS - 1; i++)
	{
		symbol = (i == '\n') ? '*' : 32 + i % (127 - 32);
		fputc (symbol, file);
	}

	fputc ('\n', file);

	fclose (file);

	return 0;
}