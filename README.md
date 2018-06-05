# Hamming Distance Routines in x86-64 Assembly

To assemble (macOS):

```sh
nasm -f macho64 hamming.asm -o hamming.o
```

To compile with example/benchmark:

```sh
clang -Wall -pedantic -O3 hamming.o example.c -o hamming
```
