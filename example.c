#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "hamming.h"

void hamming_example() {
    uint64_t a = 0;
    uint64_t b = 255;
    printf("%zu\n", hamming_64(a, b));  // 8

    uint64_t a2[2] = { 25234235, 2555 };
    uint64_t b2[2] = { 25522348832, 255434 };
    printf("%d\n", (char) hamming_64n(a2, b2, 2));  // 25
    printf("%d\n", (char) hamming_128(a2, b2));  // Should be the same

    unsigned char s1[] = { 255, 255, 255, 255, 255, 255, 255, 255,
                           255, 255 };
    unsigned char s2[] = { 255, 255, 255, 255, 255, 255, 255, 255,
                              0,  3 };
    printf("%zu\n", hamming(s1, s2, 10));  // 14
}

void hamming_benchmark() {
    size_t BENCHMARK_TOTAL_SIZE = 100000;
    size_t BENCHMARK_ARRAY_SIZE = 8;  // 512 bits

    uint64_t array[BENCHMARK_TOTAL_SIZE][BENCHMARK_ARRAY_SIZE];

    printf("Populating array with %zu elements...\n", BENCHMARK_TOTAL_SIZE);

    clock_t start_1 = clock();
    for (size_t i = 0; i < BENCHMARK_TOTAL_SIZE; i++) {
        for (size_t j = 0; j < BENCHMARK_ARRAY_SIZE; j++) {
            array[i][j] = rand();
        }
    }
    clock_t end_1 = clock();
    printf("Populated array with %zu elements in %f seconds.\n",
            BENCHMARK_TOTAL_SIZE,
            (double)(end_1 - start_1) / CLOCKS_PER_SEC
    );

    printf("Calculating %zu hamming distances...\n", BENCHMARK_TOTAL_SIZE);
    clock_t start_2 = clock();
    for (size_t i = 0; i < BENCHMARK_TOTAL_SIZE; i++) {
        hamming_64n(array[0], array[i], 8);
    }
    clock_t end_2 = clock();
    printf("Calculated %zu hamming distances in %f seconds.\n",
            BENCHMARK_TOTAL_SIZE,
            (double)(end_2 - start_2) / CLOCKS_PER_SEC
    );
}

int main(int argc, char* argv[]) {
    puts("#### Hamming Distance ####");

    puts("Example:");
    hamming_example();

    puts("Benchmark:");
    hamming_benchmark();

    return 0;
}
