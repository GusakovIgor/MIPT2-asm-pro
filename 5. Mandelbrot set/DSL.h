/*** DSL Parameters ***/

typedef __m256d vect_t;

#ifdef Optimized
	int num_dots = 4;
#else
	int num_dots = 1;
#endif

/*** Arithmetic functions ***/

#define ADD(left, right)			\
	_mm256_add_pd (left, right)

#define SUB(left, right)			\
	_mm256_sub_pd (left, right)

#define MUL(left, right)			\
	_mm256_mul_pd (left, right)

#define DIV(left, right)			\
	_mm256_div_pd (left, right)


#define FILL(value)					\
	_mm256_broadcast_sd (&value)

#define CMP(left, right, compare)			\
	_mm256_cmp_pd (left, right, compare)

#define STORE(destination, sse_variable)			\
	_mm256_store_pd (destination, sse_variable)