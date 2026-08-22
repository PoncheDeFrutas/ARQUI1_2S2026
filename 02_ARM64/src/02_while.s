.global _start

_start:

    mov x0, #0
    mov x1, #100
    mov x2, #5
    // while (x < 100) {}
while:
    cmp x0, x1
    b.ge finWhile
    add x0, x0, #1
    b while
finWhile:
    // exit(0)
    mov x0, #0              // código de salida
    mov x8, #93             // syscall de salida
    svc #0                  // ejecutar syscall

// x = 0
// while(x < 10)
    //x += 1
