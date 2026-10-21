// Compara argv[0] y llama a help, echo, clear o exit

.data
name_clear: .asciz "clear"
name_help:  .asciz "help"
name_echo:  .asciz "echo"
name_exit:  .asciz "exit"
name_other: .asciz "echoo"          // No debe coincidir con echo
word_hola:  .asciz "hola"
word_mundo: .asciz "mundo"

help_text:    .asciz "Internos: help, echo, clear, exit\n"
clear_text:   .asciz "\033[2J\033[H"
unknown_text: .asciz "Comando desconocido: "
space:        .asciz " "
newline:      .asciz "\n"

.balign 8
case_clear: .quad name_clear, 0
case_help:  .quad name_help, 0
case_echo:  .quad name_echo, word_hola, word_mundo, 0
case_other: .quad name_other, 0
case_exit:  .quad name_exit, 0

.text
.global _start

_start:
    ldr x0, =case_clear
    bl dispatch
    ldr x0, =case_help
    bl dispatch
    ldr x0, =case_echo
    bl dispatch
    ldr x0, =case_other
    bl dispatch
    ldr x0, =case_exit
    bl dispatch                      // exit termina el programa

    mov x0, #1                       // Se usa si exit retorna por error
    mov x8, #93
    svc #0

// x0 = argv devuelve 1 si reconoce el comando y 0 si no
dispatch:
    stp x19, x30, [sp, #-16]!        // Guardar X19 y la dirección de retorno
    mov x19, x0
    ldr x0, [x19]                    // Cargar el nombre de argv[0]
    cbz x0, unknown

    ldr x1, =name_help
    bl string_equal
    cbnz x0, do_help
    ldr x0, [x19]
    ldr x1, =name_echo
    bl string_equal
    cbnz x0, do_echo
    ldr x0, [x19]
    ldr x1, =name_clear
    bl string_equal
    cbnz x0, do_clear
    ldr x0, [x19]
    ldr x1, =name_exit
    bl string_equal
    cbnz x0, do_exit

unknown:
    ldr x1, =unknown_text
    bl print_z
    ldr x1, [x19]                    // Mostrar el nombre recibido
    cbz x1, unknown_newline
    bl print_z
unknown_newline:
    ldr x1, =newline
    bl print_z
    mov x0, #0
    b dispatch_done
do_help:
    bl builtin_help
    b recognized
do_echo:
    mov x0, x19                    // Pasar argv a echo
    bl builtin_echo
    b recognized
do_clear:
    bl builtin_clear
    b recognized
do_exit:
    bl builtin_exit

recognized:
    mov x0, #1
dispatch_done:
    ldp x19, x30, [sp], #16
    ret

// x0 y x1 = cadenas devuelve 1 si son iguales
string_equal:
compare_byte:
    ldrb w2, [x0]
    ldrb w3, [x1]
    cmp w2, w3
    b.ne unequal
    cbz w2, equal                   // Ambas cadenas llegaron al NUL
    add x0, x0, #1
    add x1, x1, #1
    b compare_byte
equal:
    mov x0, #1
    ret
unequal:
    mov x0, #0
    ret

builtin_help:
    ldr x1, =help_text
    b print_z                       // print_z retorna al llamador

builtin_clear:
    ldr x1, =clear_text
    b print_z                       // Enviar la secuencia ANSI al terminal

// x0 = argv imprime desde argv[1]
builtin_echo:
    stp x19, x30, [sp, #-16]!
    add x19, x0, #8                 // Comenzar en argv[1]
echo_word:
    ldr x1, [x19]
    cbz x1, echo_newline            // NULL indica el fin de argv
    bl print_z
    add x19, x19, #8
    ldr x0, [x19]
    cbz x0, echo_newline
    ldr x1, =space
    bl print_z
    b echo_word
echo_newline:
    ldr x1, =newline
    bl print_z
    ldp x19, x30, [sp], #16
    ret

builtin_exit:
    mov x0, #0
    mov x8, #93                     // exit(0)
    svc #0

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
    mov x8, #64                     // syscall write
    svc #0
    ret
