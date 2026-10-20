.section .data
.align 4
a:
    .octa 0x0000000000000001
b:
    .octa 0x0000000000000001

msg_iguales:
    .asciz "Los valores son iguales\n"
    msg_iguales_len = . - msg_iguales

msg_diferentes:
    .asciz "Los valores son diferentes\n"
    msg_diferentes_len = . - msg_diferentes

.section .text
.global _start
_start:
    ldr x4, =a
    ldp x1, x0, [x4]

    ldr x4, =b
    ldp x2, x3, [x4]

    cmp x0, x2
    b.ne diferentes

    cmp x1, x3
    b.ne diferentes

    ldr x1, =msg_iguales
    mov x2, msg_iguales_len
    b print

diferentes:
    ldr x1, =msg_diferentes
    mov x2, msg_diferentes_len
    b print

exit:
    mov x0, #0
    mov x8, #93
    svc 0

print:
    mov x0, #1
    mov x8, #64
    svc 0
    b exit