# Drawing Mandlebrot set.

My program draws a Mandelbrot set, using SDL library.

It is implemented with 3 modes – drawing, not optimized and optimized. In the first mode you can see a picture of set and fps, two other modes don’t draw a picture but show you only fps.

Not optimized version counts each point separately, while the optimized version uses Intel Intrinsics for counting 4 points at a time. In drawing mode the best version is called (of course with SSE & AVX optimization it gets faster). There is also an algorithmic optimization, which is based on the idea that we can draw whole rectangles of points in one colour.
