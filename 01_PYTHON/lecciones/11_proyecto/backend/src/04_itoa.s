// Convierte un entero sin signo a ASCII.
// Entrada:
//          x0 = numero
//          x1 = fin del buffer
// Salida:
//          x0 = inicio del texto
//          x1 = longitud.

uint_to_ascii:
    mov x2, #10
    cbnz x0, uint_to_ascii_loop

    sub x0, x1, #1
    mov w3, '0'
    strb w3, [x0]
    mov x1, #1
    ret

uint_to_ascii_loop:
    mov x5, x1

uint_to_ascii_digits:
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    sub x1, x1, #1
    add x4, x4, '0'
    strb w4, [x1]
    mov x0, x3
    cbnz x0, uint_to_ascii_digits

    mov x0, x1
    sub x1, x5, x1
    ret
