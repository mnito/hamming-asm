;;;;;;;;
; x86-64 hamming.asm
;
; Routines for calculating hamming distance
;
; nasm -f macho64 hamming.asm -o hamming.o (macOS)
;
; To run independently, uncomment "global start" and link with
; ld -lSystem hamming.o -o hamming (macOS)
;

BITS 64
default rel                             ; relative addressing

section .text

global _hamming_64
global _hamming_64n
global _hamming_128
global _hamming

; Compute hamming distance between 2 64-bit integers
_hamming_64:
        xor     rsi, rdi                ; xor bytes to reveal differences
        popcnt  rax, rsi                ; count 1s to count differences
        ret

; Internal loop for calculating hamming distance of larger values
__hamming_loop:                         ; internal
        mov     rdi, [r8]               ; set up arguments from memory
        mov     rsi, [r9]

        call     _hamming_64            ; compute hamming distance

        add     r10, rax                ; add to sum of distances

        add     r8, 8                   ; add 8 to get next value in memory
        add     r9, 8

        dec     rcx                     ; decrement rcx -- has total 64-bit segments
        jnz     __hamming_loop          ; keep looping if not 0

        cmp     rdx, 0                  ; rdx has amount of bytes remaining after 64-bit segments
        jnz     __hamming_loop_tail     ; read in the rest of the bytes carefully

        mov     rax, r10                ; return sum of distances
        ret

; Calculate hamming distance for remaining bytes
__hamming_loop_tail:                    ; internal
        mov     rcx, rdx                ; move remaining byte count to rcx for loop

        xor     rdi, rdi                ; zero out argument registers
        xor     rsi, rsi
        call    __hamming_loop_tail_bytes_to_int

        call    _hamming_64             ; final _hamming_64 call

        add     r10, rax                ; add last result to running sum
        mov     rax, r10                ; return sum in rax
        ret

; Convert remaining bytes to 64-bit integer for hamming call
__hamming_loop_tail_bytes_to_int:       ; internal
        movzx   rax, byte[r8]           ; move bytes to temporary registers
        movzx   rbx, byte[r9]

        shl     rdi, 8                  ; rdi << 8 | rax
        or      rdi, rax
        add     r8, 1                   ; go to next byte

        shl     rsi, 8                  ; rsi << 8 | rbx
        or      rsi, rbx
        add     r9, 1

        dec     rcx                     ; decrement counter for loop
        jnz     __hamming_loop_tail_bytes_to_int
        ret

; Calculate hamming distance between 2 n * 64-bit segments
_hamming_64n:
        mov     r8, rdi                 ; move memory addresses to other registers
        mov     r9, rsi
        xor     r10, r10                ; zero out r10 for sum in loop

        mov     rcx, rdx                ; move rdx to rcx for loop counter
        xor     rdx, rdx                ; zero out rdx (loop uses it to indicate extra bytes)

        cmp     rcx, 0
        jnz     __hamming_loop
        mov     rax, 0
        ret

; Calculate hamming distance between 2 128-bit segments
_hamming_128:
        mov     rdx, 2                  ; 2 64-bit segments
        call    _hamming_64n
        ret

; Calculate hamming distance between 2 n-sized byte arrays
_hamming:
        mov     rax, rdx                ; rdx has number of bytes -- set up for idiv
        xor     rdx, rdx                ; zero out other bytes for idiv call
        mov     rcx, 8                  ; divisor for idiv
        idiv    rcx                     ; divide number of bytes by 8
        mov     rcx, rax                ; move number of 64-bit segments to loop counter

        mov     r8, rdi                 ; set up memory for loop
        mov     r9, rsi
        xor     r10, r10                ; clear out for distances sum calculation

        cmp     rcx, 0
        jnz     __hamming_loop          ; enter loop
        mov     rax, 0                  ; return 0 if nothing to compute
        ret


; global start    ; _start
start:
        lea     r8, [s1]                ; load in address of s1
        lea     r9, [s2]                ; load in address of s2
        mov     rdi, [r10]              ; dereference s1 into first argument
        mov     rsi, [r11]              ; dereference s2 into second argument
        call    _hamming_64             ; result in rax

        lea     rdi, [s1]               ; _hamming_64n takes an address
        lea     rsi, [s2]
        mov     rdx, 2                  ; number of 64-bit segments
        call    _hamming_64n            ; should have same result as _hamming_128

        lea     rdi, [s1]               ; _hamming_128 takes an address
        lea     rsi, [s2]
        call    _hamming_128            ; will take into account 2 64-bit segments

        lea     rdi, [s1]
        lea     rsi, [s2]
        mov     rdx, 18                 ; will take into account 18 bytes
        call    _hamming

        xor     rdi, rdi                ; exit 0
        mov     rax, [exit]
        syscall
        ret

section .data

s1:
        db 255, 255, 255, 255, 255, 255, 255, 255
        db 255, 255, 255, 255, 255, 255, 255, 255
        db 255, 255, 255

s2:
        db 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0

exit:
        dq 0x2000001 ; 1
