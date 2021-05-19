#include "SdlFuncs.h"


/*** Initialization ***/

void SDL_Init (Application* App, const char* filename)
{
	App->Running = true;

	CreateWindow (App, filename);

	SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");

	CreateSurface (App);
}

void CreateWindow (Application* App, const char* filename)
{
	int WindowFlags = 0;

	App->Window = SDL_CreateWindow(filename, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, WindowFlags);

	if (!App->Window)
	{
		system ("clear");
		printf ("Failed to create %d x %d window:\n%s\n\n", WINDOW_WIDTH, WINDOW_HEIGHT, SDL_GetError());
		App->Running = false;
	}
}

void CreateSurface (Application* App)
{
	App->Surface = SDL_GetWindowSurface (App->Window);

	if (!App->Surface)
	{
		printf ("\n\nCan't get surface from window:\n%s\n\n", SDL_GetError());
		assert (!"Surface from window");
	}
}


/*** Drawing ***/

uint32_t GetColour (SDL_PixelFormat* fmt, uint32_t red, uint32_t green, uint32_t blue, uint32_t alpha)
{
	uint32_t colour = 0;

	colour += red   << fmt->Rshift;
	colour += green << fmt->Gshift;
	colour += blue  << fmt->Bshift;
	colour += alpha << 24;

	return colour;
}

void RedrawPixel (SDL_Surface* Surface, int x, int y, uint32_t value)
{
	uint32_t* pixel = (uint32_t*)((uint8_t*)Surface->pixels + y * Surface->pitch + x * Surface->format->BytesPerPixel);

	*pixel = value;
}

uint32_t GetPixel (SDL_Surface* Surface, int x, int y)
{
	uint32_t* pixel = (uint32_t*)((uint8_t*)Surface->pixels + y * Surface->pitch + x * Surface->format->BytesPerPixel);

	return *pixel;
}


void FillRectangle (Application* App, int start_x, int start_y, int stop_x, int stop_y)
{
	uint32_t colour = GetPixel (App->Surface, start_x, start_y);

	// colour = GetColour (App->Surface->format, 0, 255, 0, 255);

	for (int y = start_y; y < stop_y; y++)
	{
		for (int x = start_x; x < stop_x; x++)
		{
			RedrawPixel (App->Surface, x, y, colour);
		}
	}
}