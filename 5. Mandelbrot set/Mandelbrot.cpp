#include "Mandelbrot.h"

int main()
{
	Application* App = (Application*) calloc (1, sizeof(Application));

	SDL_Init (App);

	float d = 1.0 / 800.0;
	float ROI_X = -1.325;
	float ROI_Y = 0;

	while (App->Running)
	{
		CheckInput (App);

		DrawMap (App);

		SDL_UpdateWindowSurface (App->Window);

		SDL_Delay (16);
	}

	return 0;
}



void DrawMap (Application* App)
{
	for (int y = 0; y < WINDOW_HEIGHT; y++)
	{
		float X0 = (0.0      - (float) WINDOW_WIDTH  / 2.0) * d  + ROI_X;
		float Y0 = ((float)y - (float) WINDOW_HEIGHT / 2.0) * d  + ROI_Y;

		for (int x = 0; x < WINDOW_WIDTH; x++, X0 += d) 
		{
			float X = X0;
			float Y = Y0;

			int N = 0;
			for (; N < 256; N++)
			{
				float X2 = X*X;
				float Y2 = Y*Y;
				float XY = X*Y;

				float R2 = X2 + Y2;

				if (R2 >= 100.f)
				{
					break;
				}

				X = X2 - Y2 + X0;
				Y = XY + XY + Y0;
			}

			float I = sqrtf ( sqrtf ((float)N / 256.f)) * 255.f;

			char c = (char) I;

			uint64_t colour = (N < 256) ? GetColour (App->Surface->format, 255 - c, c % 2 * 64, c, 255) : 0;

			RedrawPixel (App->Surface, x, y, colour);
		}
	}
}