// Lee una columna de numeros y los guarda en el stack.
// Salida:
//          x0 = inicio de datos en stack
//          x1 = limite final de datos
//          x2 = cantidad de numeros guardados

.data

input_path:
    .asciz "src/lecturas.txt"

err_open_input:
    .ascii "Error al abrir el archivo de entrada\n"
    len_err_open_input = . - err_open_input

err_read:
    .ascii "Error al leer el archivo\n"
    len_err_read = . - err_read

.bss

read_buffer:
    .skip 4097

.text

.include "05_atoi.s"

read_column_to_stack:
    str x30, [sp, #-16]!
    mov x28, sp
    mov x22, #0

    bl read_open_file
    bl read_file
    bl read_close_file

    // Garantiza un fin de entrada aun si el archivo no contiene '$'.
    ldr x1, =read_buffer
    add x1, x1, x20
    mov w2, '$'
    strb w2, [x1]

    ldr x21, =read_buffer

read_process_line:
    bl atoi_csv
    cbz x7, read_after_column
    bl read_save_number

read_after_column:
    cmp w23, '$'
    beq read_done
    b read_process_line

read_done:
    mov x0, sp
    mov x1, x28
    mov x2, x22
    ldr x30, [x28]
    ret

// Abre src/lecturas.txt.
// Salida:
//          x19 = descriptor de archivo
read_open_file:
    mov x0, #-100
    ldr x1, =input_path
    mov x2, #0
    mov x8, #56
    svc #0

    cmp x0, #0
    blt read_open_error
    mov x19, x0
    ret

// Lee el contenido del archivo de entrada.
// Salida:
//          x20 = bytes leidos
read_file:
    mov x0, x19
    ldr x1, =read_buffer
    mov x2, #4096
    mov x8, #63
    svc #0

    cmp x0, #0
    blt read_file_error
    mov x20, x0
    ret

read_close_file:
    mov x0, x19
    mov x8, #57
    svc #0
    ret

// Guarda el valor convertido en el stack.
// Entrada:
//          x10 = valor convertido
read_save_number:
    sub sp, sp, #16
    str x10, [sp]
    add x22, x22, #1
    ret

read_open_error:
    ldr x1, =err_open_input
    mov x2, len_err_open_input
    b read_print_error

read_file_error:
    ldr x1, =err_read
    mov x2, len_err_read

read_print_error:
    mov x0, #2
    mov x8, #64
    svc #0

read_exit_error:
    mov x0, #1
    mov x8, #93
    svc #0
