#include "MDL_Rectangle.h"


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

	SDL_DestroyWindow (App->Window);

	free (App);

	return 0;
}


/*** Drawing ***/

void DrawMap (Application* App)
{
	double start_x = 0.0;
	double start_y = 0.0;

	double stop_x = WINDOW_HALF_WIDTH;
	double stop_y = WINDOW_HALF_HEIGHT;

	CheckRectangleBorder (App, start_x, start_y, stop_x, stop_y);

	start_x = WINDOW_HALF_WIDTH;
	start_y = WINDOW_HALF_HEIGHT;

	stop_x = WINDOW_WIDTH;
	stop_y = WINDOW_HEIGHT;

	CheckRectangleBorder (App, start_x, start_y, stop_x, stop_y);

	start_x = 0.0;
	start_y = WINDOW_HALF_HEIGHT;

	stop_x = WINDOW_HALF_WIDTH;
	stop_y = WINDOW_HEIGHT;

	CheckRectangleBorder (App, start_x, start_y, stop_x, stop_y);

	start_x = WINDOW_HALF_WIDTH;
	start_y = 0.0;

	stop_x = WINDOW_WIDTH;
	stop_y = WINDOW_HALF_HEIGHT;

	CheckRectangleBorder (App, start_x, start_y, stop_x, stop_y);
}


void CheckRectangleBorder (Application* App, double start_x, double start_y, double stop_x, double stop_y)
{
	int fill_colour = -2;
	double x = 0.0;
	double y = 0.0;

	if (stop_x - start_x <= 5)
	{
		for (int x = start_x; x < stop_x; x++)
		{
			for (int y = start_y; y < stop_y; y += num_dots)
			{
				#ifndef Optimized
					CalculatePointNoSSE (App, x, y);
				#else
					if (y > stop_y - 4)
					{
						y = stop_y - 4;
					}
					CalculatePoint (App, x, y);
				#endif
			}
		}
		return;
	}

	x = start_x;
	CheckVerticalBorder (App, start_y, stop_y, x, &fill_colour);

	x = stop_x;
	CheckVerticalBorder (App, start_y, stop_y, x, &fill_colour);

	y = start_y;
	CheckHorizontalBorder (App, start_x, stop_x, y, &fill_colour);

	y = stop_y;
	CheckHorizontalBorder (App, start_x, stop_x, y, &fill_colour);
	
	if (fill_colour != -1)
	{
		FillRectangle (App, start_x, start_y, stop_x, stop_y);
	}
	else
	{
		double delta_x = floor ((stop_x - start_x) / 2.0);	// 10.0
		double delta_y = floor ((stop_y - start_y) / 2.0);	// 7

		CheckRectangleBorder (App, start_x, 			start_y, 			stop_x - delta_x, 	stop_y - delta_y);	// ( 0, 0) -> (10, 8)
		CheckRectangleBorder (App, start_x + delta_x, 	start_y, 			stop_x, 			stop_y - delta_y);	// (10, 0) -> (20, 8)

		CheckRectangleBorder (App, start_x, 			start_y + delta_y, 	stop_x - delta_x, 	stop_y);	// ( 0, 7) -> (10, 15)
		CheckRectangleBorder (App, start_x + delta_x,	start_y + delta_y, 	stop_x, 			stop_y);	// (10, 7) -> (20, 15)
	}
}


void CheckHorizontalBorder (Application* App, int start_x, int stop_x, int y, int* fill_colour)
{
	if (*fill_colour == -1)
	{
		return;
	}

	int new_colour  = 0;

	for (int x = start_x; x < stop_x; x++)
	{
		new_colour = CalculatePointNoSSE (App, x, y);
		
		if (*fill_colour != new_colour)
		{
			*fill_colour = -1;
			break;
		}
	}
}

void CheckVerticalBorder (Application* App, int start_y, int stop_y, int x, int* fill_colour)
{
	if (*fill_colour == -1)
	{
		return;
	}

	int new_colour  = 0;

	for (int y = start_y; y < stop_y; y += num_dots)
	{
		#ifndef Optimized
			new_colour = CalculatePointNoSSE (App, x, y);
		#else
			if (y > stop_y - 4)
			{
				y = stop_y - 4;
			}
			new_colour = CalculatePoint (App, x, y);
		#endif

		if (*fill_colour == -2 && new_colour != -1)
		{
			*fill_colour = new_colour;
		}

		if (*fill_colour != new_colour)
		{
			*fill_colour = -1;
			break;
		}	
	}
}


int CalculatePoint (Application* App, double x, double y)
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
	 // Optimisation 1 (Cardioid & Bulb check)

	counter = CardioidCheck (x_run, y_run);
	if (counter == 0)
	{
		counter = BulbCheck (x_run, y_run);
	}

	// end of optimisation 


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

	int num_colours = 0;
	unsigned char prev_colour = 0;
	uint64_t dot_colour = 0;

	for (int i = 0; i < num_dots; i++)
	{
		double I = sqrtf ( sqrtf ((double)N[i] / (double) num_iters)) * 255;

		unsigned char c = (unsigned char) I;

		if (c != prev_colour || num_colours == 0)
		{
			prev_colour = c;
			num_colours++;
		}

		dot_colour = (N[i] < num_iters) ? GetColour (App->Surface->format, 255 - c, c % 2 * 64, c, 255) : GetColour (App->Surface->format, 0, 0, 0, 255);

		// dot_colour = GetColour (App->Surface->format, 0, 0, 255, 255);

		RedrawPixel (App->Surface, x, y + i, dot_colour);
	}

	return (num_colours == 1) ? dot_colour : -1;
}

int CalculatePointNoSSE (Application* App, double x, double y)
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

	uint64_t colour = (N < num_iters) ? GetColour (App->Surface->format, 255 - c, c % 2 * 64, c, 255) : GetColour (App->Surface->format, 0, 0, 0, 255);
	// colour = GetColour (App->Surface->format, 0, 0, 255, 255);
	RedrawPixel (App->Surface, x, y, colour);

	return colour;
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
				ResizeMap (event.key.keysym.sym);
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