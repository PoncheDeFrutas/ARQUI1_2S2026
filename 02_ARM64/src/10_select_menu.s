.data

msg_menu:
    .ascii "Seleccione una opción:\n1. Opcion1 1\n2. Opcion2 2\n3. Salir\n"
    msg_menu_len = . - msg_menu

msg_opcion:
    .ascii "Ingrese una opción: "
    msg_opcion_len = . - msg_opcion

msg_error:
    .ascii "Opción inválida\n"
    msg_error_len = . - msg_error

msg_hola:
    .ascii "Hola\n"
    msg_hola_len = . - msg_hola

msg_mundo:
    .ascii "Mundo\n"
    msg_mundo_len = . - msg_mundo

msg_adios:
    .ascii "Adiós\n"
    msg_adios_len = . - msg_adios

.bss

input_buffer:
    .skip 64

.text
.global _start

_start:
    // imprimir el menu
    ldr x1, =msg_menu
    mov x2, msg_menu_len
    bl print

    // imprimir mensaje de opcion
    ldr x1, =msg_opcion
    mov x2, msg_opcion_len
    bl print

    // read(stdin, input_buffer, 64)
    mov x0, #0              // stdin
    ldr x1, =input_buffer   // dirección del buffer
    mov x2, #64             // tamaño a leer
    mov x8, #63             // syscall read
    svc #0                  // hacer la llamada al sistema

    // comparación
    cmp x0, #0
    blt error

    // cargar el dato
    ldr x1, =input_buffer
    ldrb w0, [x1]           // cargar el primer byte del buffer

    // comparar
    cmp w0, '1'
    beq opcion1

    cmp w0, '2'
    beq opcion2

    cmp w0, '3'
    beq exit

opcion1:
    ldr x1, =msg_hola
    mov x2, msg_hola_len
    bl print
    b _start


opcion2:
    ldr x1, =msg_mundo
    mov x2, msg_mundo_len
    bl print
    b _start

exit:
    ldr x1, =msg_adios
    mov x2, msg_adios_len
    bl print

    // exit(0)
    mov x0, #0
    mov x8, #93             // syscall exit
    svc 0

print:
    mov x0, #1              // stdout
    mov x8, #64             // syscall de escritura
    svc 0
    ret

error:
    ldr x1, =msg_error
    mov x2, msg_error_len
    bl print
    b _start
