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



/*** Drawing Set ***/

void DrawMap (Application* App);

void CalculatePoint (Application* App, double x, double y);

void CalculatePointNoSSE (Application* App, int x, int y);


/*** Optimisations ***/

int CardioidCheck (vect_t xv, vect_t yv);

int BulbCheck 	  (vect_t xv, vect_t yv);



/*** Input ***/

void CheckInput (Application* App);

void ResizeMap (SDL_Keycode key);



/*** Output ***/

void ShowFps (Application* App, double fps);