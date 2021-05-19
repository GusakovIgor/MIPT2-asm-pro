#include "MDL_Classic.h"


int main()
{
	Application* App = (Application*) calloc (1, sizeof(Application));

	SDL_Init (App, ConsoleName);

	while (App->Running)
	{
		CheckInput (App);

		clock_t start = clock ();
		DrawMap (App);
		clock_t end = clock ();

		SDL_UpdateWindowSurface (App->Window);

		double drawing_time = ((double) (end - start)) / CLOCKS_PER_SEC;

		double fps = 1.0 / drawing_time;

		ShowFps (App, fps);
	}

	return 0;
}


/*** Drawing ***/

void DrawMap (Application* App)
{
	double d_scale  = d * scale;
	vect_t D_SCALE = FILL (d_scale);
	vect_t Y_SHIFT = FILL (y_shift);

	for (double y = 0.0; y < WINDOW_HEIGHT; y += num_dots)
	{
		for (double x = 0.0; x < WINDOW_WIDTH; x += 1)
		{
			#ifdef Optimised
				#if Optimised == USE_SSE
					CalculatePoint (App, x, y);
				#else
					num_dots = 1;
					CalculatePointNoSSE (App, (int) x, (int) y);
				#endif
			#else
				CalculatePoint (App, x, y);
			#endif
		}
	}
}


void CalculatePoint (Application* App, double x, double y, vect_t D_SCALE, vect_t Y_SHIFT)
{
	double d_scale  = d * scale;
	double cmp_results[num_dots] = {};	
	vect_t yv = {y, y + 1, y + 2, y + 3};
	vect_t yv_start = ADD (MUL (SUB (yv, HALF_HEIGHT), D_SCALE), Y_SHIFT);

	double x_start = (x - WINDOW_HALF_WIDTH) * d_scale + x_shift;
	vect_t xv_start = FILL (x_start);
	
	vect_t x_run = xv_start;
	vect_t y_run = yv_start;
	

	int counter = 0;
	// // Optimisation 1 (Cardioid & Bulb check)

	// counter = CardioidCheck (x_run, y_run);
	// if (counter == 0)
	// {
	// 	counter = BulbCheck (x_run, y_run);
	// }

	// // end of optimisation


	int N[num_dots] = {num_iters, num_iters, num_iters, num_iters};

	while (counter < num_iters)
	{
		vect_t x_run_sq = MUL (x_run, x_run);
		vect_t y_run_sq = MUL (y_run, y_run);
		vect_t xy       = MUL (x_run, y_run);

		vect_t r_sq = ADD (x_run_sq, y_run_sq);

		STORE (cmp_results, CMP (r_sq, ExpandBorder, _CMP_GT_OQ));

		for (int i = 0; i < num_dots; i++)
		{
			if (N[i] == num_iters && cmp_results[i])
			{
				N[i] = counter;
			}
		}

		if (N[0] != num_iters && N[1] != num_iters && N[2] != num_iters && N[3] != num_iters)
		{
			break;
		}

		x_run = ADD (SUB (x_run_sq, y_run_sq), xv_start);
		y_run = ADD (ADD (xy, xy), yv_start);

		counter++;
	}

	for (int i = 0; i < num_dots; i++)
	{
		double I = sqrtf ( sqrtf ((double)N[i] / (double) num_iters)) * 255;

		char c = (char) I;

		#ifndef Optimised
			uint64_t colour = (N[i] < num_iters) ? GetColour (App->Surface->format, 255 - c, c % 2 * 64, c, 255) : 0;
			RedrawPixel (App->Surface, x, y + i, colour);
		#endif
	}
}

void CalculatePointNoSSE (Application* App, int x, int y)
{
	double X0 = (((double)x - (double) WINDOW_WIDTH  / 2.0) * d) * scale + x_shift;
	double Y0 = (((double)y - (double) WINDOW_HEIGHT / 2.0) * d) * scale + y_shift;

	double X = X0;
	double Y = Y0;

	int N = 0;
	while (N < 256)
	{
		double X2 = X*X;
		double Y2 = Y*Y;
		double XY = X*Y;

		double R2 = X2 + Y2;

		if (R2 >= 4.f)
		{
			break;
		}

		X = X2 - Y2 + X0;
		Y = XY + XY + Y0;

		N++;
	}


	double I = sqrtf ( sqrtf ((double)N / 256.f)) * 255.f;

	char c = (char) I;

	#ifndef Optimised
		uint64_t colour = (N < num_iters) ? GetColour (App->Surface->format, 255 - c, c % 2 * 64, c, 255) : 0;
		RedrawPixel (App->Surface, x, y, colour);
	#endif
}



int CardioidCheck (vect_t xv, vect_t yv)
{
	vect_t x_mqt = SUB (xv, quater_v);
	
	vect_t yv_sq = MUL (yv, yv);

	vect_t ro_sq = ADD (MUL (x_mqt, x_mqt), yv_sq);

	vect_t left  = MUL (ro_sq, ADD (ro_sq, x_mqt));

	vect_t right = MUL (yv_sq, quater_v);

	double cmp_results[num_dots] = {};
	STORE (cmp_results, CMP (left, right, _CMP_LE_OQ));


	int counter = 0;
	for (int i = 0; i < num_dots; i++)
	{
		if (cmp_results[i])
		{
			counter++;
		}
	}
	counter = (counter == num_dots) ? num_iters : 0;


	return counter;
}

int BulbCheck (vect_t xv, vect_t yv)
{
	vect_t x_po  = ADD (xv, one_v);
	
	vect_t yv_sq = MUL (yv, yv);

	vect_t left  = ADD (MUL (x_po, x_po), yv_sq);

	vect_t right = MUL (quater_v, quater_v);

	double cmp_results[num_dots] = {};
	STORE (cmp_results, CMP (left, right, _CMP_LE_OQ));


	int counter = 0;
	for (int i = 0; i < num_dots; i++)
	{
		if (cmp_results[i])
		{
			counter++;
		}
	}
	counter = (counter == num_dots) ? num_iters : 0;

	return counter;
}


/*** Input ***/

void CheckInput (Application* App)
{
	SDL_Event event;

	while (SDL_PollEvent(&event))
	{
		switch (event.type)
		{
			case SDL_QUIT:
				App->Running = false;
				break;

			case SDL_KEYDOWN:
				#ifndef Optimised
					ResizeMap (event.key.keysym.sym);
				#endif
				break;

			default:
				break;
		}
	}
}

void ResizeMap (SDL_Keycode key)
{
	switch (key)
	{
		case SDLK_EQUALS:
						if (scale <= 5*dscale)
						{
							dscale /= 5;
						}
						scale -= dscale;
						d_scale  = d * scale;
						D_SCALE = FILL (d_scale);
						break;

		case SDLK_MINUS:
						if (scale >= 5*dscale)
						{
							dscale *= 1.2;
						}
						scale += dscale;
						d_scale  = d * scale;
						D_SCALE = FILL (d_scale);
						break;

		case SDLK_RIGHT:
						x_shift += dx * scale;
						break;

		case SDLK_LEFT:
						x_shift -= dx * scale;
						break;

		case SDLK_UP:
						y_shift -= dy * scale;
						Y_SHIFT = FILL (y_shift);
						break;

		case SDLK_DOWN:
						y_shift += dy * scale;
						Y_SHIFT = FILL (y_shift);
						break;

		default:
						break;
	}
}

/*** Output ***/

void ShowFps (Application* App, double fps)
{
	char title[MAX_TITLE_SIZE] = "";

	#ifdef Optimised

		#if Optimised == USE_SSE
			const char* OptimizeName = "SSE";
		#else
			const char* OptimizeName = "SSE";
		#endif
	
	#else
		const char* OptimizeName = "";
	#endif

	if (fps <= 1.0)
	{
		snprintf (title, MAX_TITLE_SIZE, "FPS: %.3f", fps);
	}
	else
	{
		snprintf (title, MAX_TITLE_SIZE, "FPS: %.2f", fps);
	}

	SDL_SetWindowTitle (App->Window, title);
}