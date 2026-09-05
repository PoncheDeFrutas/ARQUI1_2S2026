.data
msg_if: .ascii "x es mayor que 10\n"
    msg_if_len = . - msg_if

msg_else: .ascii "x es menor o igual que 10\n"
    msg_else_len = . - msg_else

.text
.global _start
_start:

    mov x0, #5
    mov x10, #10
    // if (x > 10) {}
    cmp x0, x10
    b.gt if
else:
    ldr x1, =msg_else            // dirección del mensaje
    mov x2, msg_else_len         // longitud del mensaje
    bl print
    b finif
if:
    ldr x1, =msg_if            // dirección del mensaje
    mov x2, msg_if_len         // longitud del mensaje
    bl print

finif:
    // exit(0)
    mov x0, #0              // código de salida
    mov x8, #93             // syscall de salida
    svc #0                  // ejecutar syscall

print:
    // X1 = dirección del mensaje
    // X2 = longitud del mensaje
    // write(1, dirección, longitud)
    mov x0, #1              // stdout
    mov x8, #64             // syscall de escritura
    svc #0                  // ejecutar syscall
    ret
