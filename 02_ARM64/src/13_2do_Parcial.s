.section .data
array:
    .word 7, 3, 21, 10

num:
    .word 567890

.section .bss
final:
    .skip 20                // 5 enteros de 4 bytes
                            // 7, 3, 567890, 21, 0

.section .text
.global _start

_start:
    ldr x1, =array          // dirección del array original
    ldr x2, =final          // dirección del array destino
    mov x3, #2              // posición donde insertar
    ldr x4, =num            // dirección del nuevo elemento

    bl insert_array

    // terminar programa
    mov x0, #0
    mov x8, #93
    svc #0


insert_array:
    // x1 = puntero al array original
    // x2 = puntero al array final
    // x3 = posición de inserción
    // x4 = puntero al nuevo elemento
    mov x5, #0              // índice del array original

// copiar elementos antes de la posición de inserción
copy_before:
    cmp x5, x3
    bge insert_element

    ldr w6, [x1, x5, lsl #2]
    str w6, [x2, x5, lsl #2]

    add x5, x5, #1
    b copy_before


// insertar nuevo elemento
insert_element:
    ldr w6, [x4]
    str w6, [x2, x3, lsl #2]

// copiar elementos restantes desplazándolos una posición
copy_remaining:
    ldr w6, [x1, x5, lsl #2]

    add x7, x5, #1
    str w6, [x2, x7, lsl #2]

    cmp w6, #0
    beq end_insert

    add x5, x5, #1
    b copy_remaining


end_insert:
    ret