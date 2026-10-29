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

    // Multiplicar por 4 mediante corrimientos
    lsl x4, x0, #2             // Desplazamos la parte baja 2 bits
    lsr x7, x0, #62            // Recuperamos los bits que salen de X0

    lsl x5, x1, #2             // Desplazamos la parte alta 2 bits
    orr x5, x5, x7             // Unimos los bits provenientes de X0

    lsr x6, x1, #62            // Guardamos los bits de desbordamiento

    // Sumar el numero original para obtener a * 5
    adds x4, x4, x0            // Sumamos la parte baja
    adcs x5, x5, x1            // Sumamos la parte alta con acarreo
    adc x6, x6, xzr            // Guardamos el ultimo acarreo

    // Guardar resultado de 192 bits
    ldr x9, =resultado
    stp x4, x5, [x9]           // Guardamos los primeros 128 bits
    str x6, [x9, #16]          // Guardamos los bits adicionales

    // Finalizar
    mov x0, #0
    mov x8, #93
    svc #0