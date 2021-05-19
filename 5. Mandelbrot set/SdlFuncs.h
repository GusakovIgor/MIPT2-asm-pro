#include <SDL2/SDL.h>
#include <assert.h>

struct Application
{
	bool Running;
	SDL_Window* Window;
	SDL_Surface* Surface;
};

const int MAX_TITLE_SIZE = 20;
const int WINDOW_WIDTH  = 1280;
const int WINDOW_HEIGHT = 960;
const double WINDOW_HALF_WIDTH  = (double) WINDOW_WIDTH  / 2.0;
const double WINDOW_HALF_HEIGHT = (double) WINDOW_HEIGHT / 2.0;


/*** Initialization ***/

void SDL_Init 	   (Application* App, const char* filename);
void CreateWindow  (Application* App, const char* filename);
void CreateSurface (Application* App);


/*** Working with Scene ***/

void PrepareScene (Application* App);

void PresentScene (Application* App);


/*** Drawing ***/

uint32_t GetColour (SDL_PixelFormat* fmt, uint32_t red, uint32_t green, uint32_t blue, uint32_t alpha);

void RedrawPixel (SDL_Surface* Surface, int x, int y, uint32_t value);

uint32_t GetPixel (SDL_Surface* Surface, int x, int y);

void FillRectangle (Application* App, int start_x, int start_y, int stop_x, int stop_y);