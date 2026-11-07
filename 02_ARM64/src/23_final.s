/*
Tenemos 10 elementos cargados en SP de tamaño quad (8 bytes cada uno).
Queremos saber cuantos numeros de ellos son negativos.
Tenemos que regresar el resultado en x0

se puede hacer como bloque o como función

izi pc
*/

.section .text
.global _start

_start:
    bl guardar_elementos
    b contar_negativos


contar_negativos:
    mov x0, #0          // contador
    mov x2, #10         // cantidad de elementos
    mov x3, sp          // apuntador al primer elemento

bucle:
    ldr x1, [x3], #8            // cargar el siguiente elemento y avanzar el puntero
    cmp x1, #0                  // comparar con 0
    bge siguiente               // si es mayor o igual a 0, saltar al siguiente

    add x0, x0, #1              // incrementar contador si es negativo

siguiente:
    subs x2, x2, #1              // decrementar el contador de elementos
    bne bucle                    // si no hemos terminado, repetir el bucle

    // salir del sistema
    mov x8, #93                  // syscall exit
    svc 0                        // llamar al sistema para salir


guardar_elementos:
    // Guardar 10 elementos en la pila (SP)
    sub sp, sp, #80              // reservar espacio para 10 elementos (10 * 8 bytes)
    mov x1, #5                   // primer elemento
    str x1, [sp]                 // guardar en SP
    mov x1, #-3                  // segundo elemento
    str x1, [sp, #8]             // guardar en SP + 8
    mov x1, #7                   // tercer elemento
    str x1, [sp, #16]            // guardar en SP + 16
    mov x1, #-1                  // cuarto elemento
    str x1, [sp, #24]            // guardar en SP + 24
    mov x1, #0                   // quinto elemento
    str x1, [sp, #32]            // guardar en SP + 32
    mov x1, #-4                  // sexto elemento
    str x1, [sp, #40]            // guardar en SP + 40
    mov x1, #2                   // séptimo elemento
    str x1, [sp, #48]            // guardar en SP + 48
    mov x1, #-6                  // octavo elemento
    str x1, [sp, #56]            // guardar en SP + 56
    mov x1, #3                   // noveno elemento
    str x1, [sp, #64]            // guardar en SP + 64
    mov x1, #-2                  // décimo elemento
    str x1, [sp, #72]            // guardar en SP + 72
    ret