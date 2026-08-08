.global _start

_start:
    // exit(0)
    mov x0, #0              // código de salida
    mov x8, #93             // syscall de salida
    svc #0                  // ejecutar syscall

