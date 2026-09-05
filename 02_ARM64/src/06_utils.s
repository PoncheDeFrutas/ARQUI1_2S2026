// Utilidades para leer una columna de numeros.
//
// Salida:
//   x0 = inicio de datos en stack
//   x1 = limite final de datos
//   x2 = cantidad de numeros guardados

.data

filename:
    .asciz "src/lecturas.csv"

err_open:
    .ascii "Error al abrir el archivo\n"
    len_err_open = . - err_open

err_read:
    .ascii "Error al leer el archivo\n"
    len_err_read = . - err_read

.bss

buffer:
    .skip 4096

.text

.include "05_atoi.s"

read_column_to_stack:
    // guardar direccion de retorno
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x28 = limite superior de datos
    mov x28, sp

    mov x5, #10             // base 10
    mov x22, #0             // contador de numeros

    // abrir archivo
    bl utils_open_file

    // leer archivo
    bl utils_read_file

    // cerrar archivo
    bl utils_close_file

    // apuntar al inicio del buffer
    ldr x21, =buffer

utils_process_line:
    bl atoi_csv

    cbz x7, utils_after_column

    // guardar numero convertido
    bl utils_save_number

utils_after_column:
    cmp w23, '$'
    beq utils_done
    b utils_process_line

utils_done:
    mov x0, sp              // inicio de datos
    mov x1, x28             // limite final
    mov x2, x22             // cantidad de datos

    // recuperar direccion original de retorno
    // [X29, X30]
    ldr x30, [x29, #8]
    ret

// Abrir archivo
utils_open_file:
    mov x0, #-100
    ldr x1, =filename
    mov x2, #0
    mov x3, #0
    mov x8, #56
    svc #0

    cmp x0, #0
    blt utils_open_error

    mov x19, x0
    ret

// Leer archivo
utils_read_file:
    mov x0, x19
    ldr x1, =buffer
    mov x2, #4096
    mov x8, #63
    svc #0

    cmp x0, #0
    blt utils_read_error

    mov x20, x0
    ret

// Cerrar archivo
utils_close_file:
    mov x0, x19
    mov x8, #57
    svc #0
    ret

// Guardar numero en stack
utils_save_number:
    sub sp, sp, #16
    str x10, [sp]

    add x22, x22, #1
    ret

// Manejo de errrores
utils_open_error:
    mov x0, #1
    ldr x1, =err_open
    mov x2, len_err_open
    mov x8, #64
    svc #0
    b utils_exit_error

utils_read_error:
    mov x0, #1
    ldr x1, =err_read
    mov x2, len_err_read
    mov x8, #64
    svc #0
    b utils_exit_error

utils_exit_error:
    mov x0, #1
    mov x8, #93
    svc #0
