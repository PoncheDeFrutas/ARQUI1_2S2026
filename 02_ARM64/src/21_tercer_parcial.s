.section .data
.align 4

a:
    .octa 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    // Numero de 128 bits

resultado:
    .skip 24                                    // Reservamos 192 bits para el resultado (128 bits + 64 bits)

.section .text
.global _start

_start:
    // Cargar el numero de 128 bits
    ldr x9, =a
    ldp x0, x1, [x9]           // X0 parte baja, X1 parte alta

    // Inicializar resultado en cero
    mov x4, #0                 // Parte baja del resultado
    mov x5, #0                 // Parte alta del resultado
    mov x6, #0                 // Bits adicionales por desbordamiento
    mov x7, #5                 // Contador para realizar 5 sumas

ciclo:
    // Sumar el numero original al resultado acumulado
    adds x4, x4, x0            // Sumamos la parte baja
    adcs x5, x5, x1            // Sumamos la parte alta con acarreo
    adc x6, x6, xzr            // Guardamos el acarreo adicional

    // Controlar las repeticiones
    subs x7, x7, #1            // Disminuimos el contador
    b.ne ciclo                 // Repetimos mientras no sea cero

    // Guardar resultado de 192 bits
    ldr x9, =resultado
    stp x4, x5, [x9]           // Guardamos los primeros 128 bits
    str x6, [x9, #16]          // Guardamos los bits adicionales

    // Finalizar
    mov x0, #0
    mov x8, #93
    svc #0