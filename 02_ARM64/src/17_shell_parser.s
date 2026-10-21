.data
line_buffer:
    .asciz "echo hola mundo"          // Buffer que vamos a modificar
argc_text:   .asciz "argc = "
argv_text:   .asciz "argv["
equals_text: .asciz "] = "
null_text:   .asciz "NULL\n"
newline:     .asciz "\n"
limit_error: .asciz "Error: máximo 16 argumentos\n"

.bss
.balign 8
argv:
    .skip 136                       // 16 punteros y un NULL final
digits:
    .skip 2                         // Para mostrar números de 0 a 16

.text
.global _start

_start:
    ldr x0, =line_buffer
    ldr x1, =argv
    mov x2, #16
    bl parse_line                   // x0 = argc o -1 si hay más de 16 palabras
    cmp x0, #0
    b.lt too_many

    mov x19, x0                     // Guardar argc
    ldr x20, =argv
    mov x21, #0                     // Índice de argv

    ldr x1, =argc_text
    bl print_z
    mov x0, x19
    bl print_0_to_16
    ldr x1, =newline
    bl print_z

show_arg:
    cmp x21, x19
    b.eq show_null
    ldr x1, =argv_text
    bl print_z
    mov x0, x21
    bl print_0_to_16
    ldr x1, =equals_text
    bl print_z
    ldr x1, [x20]                   // Cargar la dirección de argv[i]
    bl print_z
    ldr x1, =newline
    bl print_z
    add x20, x20, #8                // Siguiente puntero
    add x21, x21, #1
    b show_arg

show_null:
    ldr x0, [x20]                   // Comprobar argv[argc] = NULL
    cbnz x0, bad_null
    ldr x1, =argv_text
    bl print_z
    mov x0, x21
    bl print_0_to_16
    ldr x1, =equals_text
    bl print_z
    ldr x1, =null_text
    bl print_z
    mov x0, #0
    mov x8, #93                     // syscall exit
    svc #0

too_many:
    ldr x1, =limit_error
    bl print_z
bad_null:
    mov x0, #1
    mov x8, #93                     // syscall exit
    svc #0

// x0 = buffer, x1 = argv, x2 = máximo regresa argc o -1
parse_line:
    mov x3, x0                     // Posición actual del buffer
    mov x4, #0                     // Cantidad de argumentos
    mov x5, x1                     // Siguiente posición de argv

skip_separators:
    ldrb w6, [x3]
    cbz w6, parse_done
    cmp w6, #' '
    b.eq erase_separator
    cmp w6, #9                     // Tabulación
    b.eq erase_separator

    cmp x4, x2
    b.ge parse_overflow             // Dejar espacio para el NULL final
    str x3, [x5]                   // Guardar la dirección de la palabra
    add x5, x5, #8
    add x4, x4, #1

scan_word:
    ldrb w6, [x3]
    cbz w6, parse_done
    cmp w6, #' '
    b.eq erase_separator
    cmp w6, #9
    b.eq erase_separator
    add x3, x3, #1
    b scan_word

erase_separator:
    strb wzr, [x3]                 // Terminar la palabra con NUL
    add x3, x3, #1
    b skip_separators

parse_done:
    str xzr, [x5]                  // argv[argc] = NULL
    mov x0, x4
    ret

parse_overflow:
    str xzr, [x5]                  // Mantener argv terminado en NULL
    mov x0, #-1
    ret

// x0 = número entre 0 y 16
print_0_to_16:
    mov x3, x0
    ldr x1, =digits
    mov x2, #1
    cmp x3, #10
    b.lt one_digit
    mov w4, #'1'
    strb w4, [x1]
    sub x3, x3, #10
    add x1, x1, #1
    mov x2, #2
one_digit:
    add w4, w3, #'0'
    strb w4, [x1]
    cmp x2, #2
    b.ne write_digits
    sub x1, x1, #1                  // Volver al primer dígito
write_digits:
    mov x0, #1
    mov x8, #64                     // syscall write
    svc #0
    ret

// x1 = cadena terminada en NUL
print_z:
    mov x2, #0
    mov x3, x1
count_bytes:
    ldrb w4, [x3]
    cbz w4, write_text
    add x3, x3, #1
    add x2, x2, #1
    b count_bytes
write_text:
    mov x0, #1
    mov x8, #64
    svc #0
    ret
