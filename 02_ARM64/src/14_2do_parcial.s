.section .data
array:
    .word 7, 3, 21, 10, 0

num:
    .word 567890

.section .text
.global _start

_start:
    ldr x1, =array
    ldr x3, =num

    ldr w5, [x1, #8]

    // insertar 567890
    ldr w4, [x3]

    str w4, [x1, #8]

    ldr w2, [x1, #12]

    // pegar 21
    str w5, [x1, #12]

    // pegar 10
    str w2, [x1, #16]

    mov x0, #0
    mov x8, #93
    svc #0