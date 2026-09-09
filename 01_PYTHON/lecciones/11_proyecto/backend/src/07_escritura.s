// Escribe resultados de calculos en un archivo.

.data

output_path:
    .asciz "src/output.txt"

msg_result:
    .ascii "Suma: "
    msg_result_len = . - msg_result

newline:
    .ascii "\n"

err_open_output:
    .ascii "Error al abrir el archivo de salida\n"
    len_err_open_output = . - err_open_output

err_write:
    .ascii "Error al escribir el archivo\n"
    len_err_write = . - err_write

.bss

num_buffer:
    .skip 32

.text

.include "04_itoa.s"

// Escribe todos los bytes solicitados.
// Entrada:
//          x0 = descriptor de archivo
//          x1 = direccion del buffer
//          x2 = longitud
write_all:
    mov x9, x0

write_all_loop:
    cbz x2, write_all_done
    mov x0, x9
    mov x8, #64
    svc #0

    cmp x0, #0
    ble write_error
    add x1, x1, x0
    sub x2, x2, x0
    b write_all_loop

write_all_done:
    ret

// Coordina la escritura de todos los resultados.
// Entrada:
//          x0 = suma
write_results:
    stp x0, x30, [sp, #-16]!

    bl write_open_file

    ldr x0, [sp]
    bl write_sum

    // bl write_max
    // bl write_min

    bl write_close_file

    ldp x0, x30, [sp], #16
    ret

// Abre src/output.txt y guarda su descriptor.
// Salida:
//          x19 = descriptor de archivo
write_open_file:

    mov x0, #-100
    ldr x1, =output_path
    mov x2, #(1 | 64 | 512)
    mov x3, #420
    mov x8, #56
    svc #0

    cmp x0, #0
    blt write_open_error
    mov x19, x0
    ret

// Cierra el archivo de salida.
// Entrada:
//          x19 = descriptor de archivo
write_close_file:
    mov x0, x19
    mov x8, #57
    svc #0
    cmp x0, #0
    blt write_error
    ret

// Escribe la linea "Suma: <valor>".
// Entrada:
//          x0 = suma
write_sum:
    stp x0, x30, [sp, #-16]!

    mov x0, x19
    ldr x1, =msg_result
    mov x2, msg_result_len
    bl write_all

    ldr x0, [sp]
    bl write_uint

    mov x0, x19
    ldr x1, =newline
    mov x2, #1
    bl write_all

    ldp x0, x30, [sp], #16
    ret

// Convierte y escribe un entero sin signo.
// Entrada:
//          x0 = entero sin signo
write_uint:
    str x30, [sp, #-16]!

    ldr x1, =num_buffer
    add x1, x1, #32
    bl uint_to_ascii

    mov x2, x1
    mov x1, x0
    mov x0, x19
    bl write_all

    ldr x30, [sp], #16
    ret

write_open_error:
    ldr x1, =err_open_output
    mov x2, len_err_open_output
    b write_print_error

write_error:
    ldr x1, =err_write
    mov x2, len_err_write

write_print_error:
    mov x0, #2
    mov x8, #64
    svc #0

write_exit_error:
    mov x0, #1
    mov x8, #93
    svc #0
