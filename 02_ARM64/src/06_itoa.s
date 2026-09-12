// x0 = numero, x1 = final del buffer
// salida: x1 = inicio del texto, x2 = longitud

itoa:
    mov x2, #0
    mov x3, #10
    mov x4, #0

    cmp x0, #0
    bge itoa_positive
    neg x0, x0
    mov x4, #1

itoa_positive:
    cbnz x0, itoa_read
    sub x1, x1, #1
    mov w5, '0'
    strb w5, [x1]
    mov x2, #1
    b itoa_sign

itoa_read:
    udiv x5, x0, x3
    msub x6, x5, x3, x0
    add x6, x6, '0'
    sub x1, x1, #1
    strb w6, [x1]
    add x2, x2, #1
    mov x0, x5
    cbnz x0, itoa_read

itoa_sign:
    cbz x4, itoa_end
    sub x1, x1, #1
    mov w5, '-'
    strb w5, [x1]
    add x2, x2, #1

itoa_end:
    ret
