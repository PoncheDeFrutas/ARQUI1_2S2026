.data

msg_input: 
    .ascii "Ingrese un dato: "
    msg_input_len = . - msg_input

msg_output:
    .ascii "Dato ingresado: "
    msg_output_len = . - msg_output

msg_error:
    .ascii "Error\n"
    msg_error_len = . - msg_error

.bss

input_buffer:
    .skip 64


.text
.global _start

_start:

main_loop:
    // Imprimir mensaje de entrada
    ldr x1, =msg_input            // dirección del mensaje de entrada
    mov x2, msg_input_len         // longitud del mensaje de entrada
    bl print                      // llamar a la función print

    // read(stdin, input_buffer, 64)
    mov x0, #0              // stdin
    ldr x1, =input_buffer   // dirección del buffer
    mov x2, #64             // tamaño a leer
    mov x8, #63             // syscall read
    svc #0                  // hacer la llamada al sistema

    // Verificar si hubo error al leer
    cmp x0, #0
    blt read_error

    // Imprimir mensaje de salida
    ldr x1, =msg_output     // dirección del mensaje de salida
    mov x2, msg_output_len  // longitud del mensaje de salida
    bl print                // llamar a la función print

    // Imprimir el buffer de entrada
    ldr x1, =input_buffer   // dirección del buffer de entrada
    mov x2, #64
    bl print
    b main_loop


read_error:
    ldr x1, =msg_error            // dirección del mensaje de error
    mov x2, msg_error_len         // longitud del mensaje de error
    bl print                      // llamar a la función print
    b main_loop                      // reiniciar el programa

print:
    // write(1, dirección, longitud)
    mov x0, #1              // stdout
    mov x8, #64             // syscall de escritura
    svc #0                  // ejecutar syscall
    ret                     // regresar