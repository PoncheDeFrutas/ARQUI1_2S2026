.section .data
NUMS:
    .word 10, 20, 30, 40, 200
    .rept 250
        .word 100
    .endr

.section .text
.global _start

_start:
    // obtener el inicio del arreglo
    ldr x0, =NUMS
    // decimos la cantidad de elementos 
    mov x1, #255

    bl operacion

    b exit

operacion:
    mov x2, x1      // copiar cantidad de elementos
    mov x3, #0     // numero mayor
    mov x4, #0     // la suma acumulada X

loop:
    ldr w5, [x0], #4 // lectura del contenido en x0, y nos movemos uno
    
    add x4, x4, x5 // suma acumulada => X = X + a

    cmp x5, x3        // comparación de x5 y x3
    b.ls next          // si x5 es menor vamos a next
    mov x3, x5        // sobre escribimos x3 con el valor de x5

next:
    subs x2, x2, #1
    b.ne loop

    mov x0, x3      // regresas el numero mayor en x0
    mov x2, x1      // cantidad de elementos
    udiv x1, x4, x2 // promedio = suma acumulada / cantidad de datos
    
    ret
 
exit:
    mov x0, #0
    mov x8, #93
    svc #0