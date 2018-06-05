#include <stddef.h>
#include <stdint.h>


size_t hamming_64(uint64_t a, uint64_t b);
size_t hamming_64n(uint64_t a[], uint64_t b[], size_t size);
size_t hamming_128(uint64_t a[2], uint64_t b[2]);
size_t hamming(unsigned char a[], unsigned char b[], size_t size);
