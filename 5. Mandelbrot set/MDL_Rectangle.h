#include <stdio.h>
#include <time.h>
#include <immintrin.h>


#include "DSL.h"
#include "SdlFuncs.h"


#define NO_SSE  1
#define USE_SSE 2


double scale = 1.0;
double x_shift = -1.325;
double y_shift = 0;
double dscale = 0.05;

const double std_d = 1.0 / 800.0;
double d = std_d * scale;

const double std_dx = 0.1;
const double std_dy = 0.1;

double dx = std_dx / scale;
double dy = std_dy / scale;


const int num_iters = 256;

const char* ConsoleName = "Mandelbrot Map";


/*** Constant vectors ***/

const double border = 4.0;
const double quater = 0.25;
const double one    = 1.0;

vect_t ExpandBorder = FILL (border);
vect_t quater_v = FILL (quater);
vect_t one_v = FILL (one);

vect_t HALF_WIDTH  = FILL (WINDOW_HALF_WIDTH);
vect_t HALF_HEIGHT = FILL (WINDOW_HALF_HEIGHT);

double d_scale  = d * scale;
vect_t D_SCALE = FILL (d_scale);
vect_t Y_SHIFT = FILL (y_shift);



/*** Drawing Set ***/

void DrawMap (Application* App);

void CheckRectangleBorder (Application* App, double start_x, double start_y, double stop_x, double stop_y);

void CheckHorizontalBorder (Application* App, int start_x, int stop_x, int y, int* fill_colour);

void CheckVerticalBorder   (Application* App, int start_y, int stop_y, int x, int* fill_colour);

int CalculatePoint (Application* App, double x, double y);

int CalculatePointNoSSE (Application* App, double x, double y);



/*** Optimisations ***/

int CardioidCheck (vect_t xv, vect_t yv);

int BulbCheck 	  (vect_t xv, vect_t yv);



/*** Input ***/

void CheckInput (Application* App);

void ResizeMap (SDL_Keycode key);



/*** Output ***/

void ShowFps (Application* App, double fps);