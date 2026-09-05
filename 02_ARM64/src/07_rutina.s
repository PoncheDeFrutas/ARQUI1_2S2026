.data
msg_result:
    .ascii "Suma: "
    msg_result_len = . - msg_result

newline:
    .ascii "\n"

.bss

num_buffer:
    .skip 32

.text

.include "06_utils.s"

.global _start

_start:
    // Leer la unica columna del archivo.
    bl read_column_to_stack


    //X22 cuantos numeros fueron = n

    // guardar salidas de utils
    mov x24, x0             // puntero actual para recorrer stack
    mov x25, x1             // limite final

    // suma total
    mov x28, #0

sum_loop:
    cmp x24, x25
    beq print_result

    ldr x10, [x24]

    //OPERACION A CAMBIAR O LOGICA A CAMBIAR
    add x28, x28, x10
    //////////

    // corrimiento en el stack
    add x24, x24, #16

    b sum_loop

print_result:
    mov x0, #1
    ldr x1, =msg_result
    mov x2, msg_result_len
    mov x8, #64
    svc #0

    //mover resultado a x0
    mov x0, x28
    bl print_uint

    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0

    b exit_ok

print_uint:
    ldr x1, =num_buffer
    add x1, x1, #31

    mov w2, #0
    strb w2, [x1]

    mov x3, #10
    mov x4, #0

    cmp x0, #0
    bne convert_loop

    // guardan en caso es 0
    sub x1, x1, #1
    mov w2, '0'
    strb w2, [x1]
    mov x4, #1
    b write_number


convert_loop:
    udiv x5, x0, x3
    msub x6, x5, x3, x0

    add x6, x6, '0'

    sub x1, x1, #1
    strb w6, [x1]

    add x4, x4, #1

    mov x0, x5
    cbnz x0, convert_loop

write_number:
    mov x0, #1
    mov x2, x4
    mov x8, #64
    svc #0

    ret

exit_ok:
    mov x0, #0
    mov x8, #93
    svc #0
