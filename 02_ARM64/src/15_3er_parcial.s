.data
src_text:
    .ascii "Hello, World!\n"
    text_len = . - src_text

.balign 4
len_copy:
    .word 5                    // 0 a 14

.bss
src_dest:
    .skip 32

.text
.global _start

_start:
    // Preparar parámetros para bytecopy
    ldr x0, =src_dest           // Dirección del destino
    ldr x1, =src_text           // Dirección del origen

    ldr x9, =len_copy           // Dirección de la cantidad
    ldr w2, [x9]               // Leer la cantidad a copiar

    bl bytecopy

    // Imprimir la cantidad copiada
    ldr x1, =src_dest
    ldr x9, =len_copy
    ldr w2, [x9]               // Recuperar la cantidad original

    bl print
    b exit

// X0 = dirección de dest
// X1 = dirección de src
// W2 = cantidad de bytes

bytecopy:
    sub w2, w2, #1             // Último índice válido

.Lwhile:
    cmp w2, #0
    b.lt .Lfin                 // Terminar si count < 0

    add x9, x1, x2             // Dirección de src[count]
    ldrb w3, [x9]              // Leer un byte

    add x10, x0, x2            // Dirección de dest[count]
    strb w3, [x10]             // Guardar el byte

    sub w2, w2, #1             // Disminuir el índice
    b .Lwhile

.Lfin:
    ret

// X1 = dirección del mensaje
// X2 = cantidad de bytes a imprimir

print:
    mov x0, #1                 // Salida estándar
    mov x8, #64                // syscall write
    svc #0
    ret

exit:
    mov x0, #0                 // Código de salida
    mov x8, #93                // syscall exit
    svc #0