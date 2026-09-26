.section .data
array:
    .word #7, #3, #21, #10

num:
    .word #567890

.section .bss
final:
    .skip #20

.section .text
.global _start

_start:
    ldr x1, =array
    ldr x2, =final
    ldr x3, =num

    // copiar 7
    ldr w4, [x1, #0]
    str w4, [x2, #0]

    // copiar 3
    ldr w4, [x1, #4]
    str w4, [x2, #4]

    // insertar 567890
    ldr w4, [x3]
    str w4, [x2, #8]

    // copiar 21
    ldr w4, [x1, #8]
    str w4, [x2, #12]

    // copiar 10
    ldr w4, [x1, #12]
    str w4, [x2, #16]

    mov x0, #0
    mov x8, #93
    svc #0