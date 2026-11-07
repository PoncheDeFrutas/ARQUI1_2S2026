/*
Tenemos 10 elementos cargados en SP de tamaño word (4 bytes cada uno).
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
    ldr w1, [x3], #4            // cargar el siguiente elemento y avanzar el puntero
    /*
    otras formas de cargar el dato
    ldr w1, [x3]                 // cargar el siguiente elemento
    add x3, x3, #4               // avanzar el puntero

    ldr w1, [x3, x2, lsl #2]     // cargar el siguiente elemento usando un desplazamiento
    add x2, x2, #1               // avanzar el puntero

    */
    cmp w1, #0                  // comparar con 0
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
    mov w1, #5                   // primer elemento
    str w1, [sp]                 // guardar en SP
    mov w1, #-3                  // segundo elemento
    str w1, [sp, #4]             // guardar en SP + 4
    mov w1, #7                   // tercer elemento
    str w1, [sp, #8]             // guardar en SP + 8
    mov w1, #-1                  // cuarto elemento
    str w1, [sp, #12]            // guardar en SP + 24
    mov w1, #0                   // quinto elemento
    str w1, [sp, #16]            // guardar en SP + 32
    mov w1, #-4                  // sexto elemento
    str w1, [sp, #20]            // guardar en SP + 40
    mov w1, #2                   // séptimo elemento
    str w1, [sp, #24]            // guardar en SP + 48
    mov w1, #-6                  // octavo elemento
    str w1, [sp, #28]            // guardar en SP + 56
    mov w1, #3                   // noveno elemento
    str w1, [sp, #32]            // guardar en SP + 64
    mov w1, #-2                  // décimo elemento
    str w1, [sp, #36]            // guardar en SP + 72
    ret