.text

.include "06_lectura.s"
.include "07_escritura.s"

.global _start

_start:
    bl read_column_to_stack

    mov x24, x0     // direccion de inicio de datos en stack
    mov x25, x1     // direccion de limite final de datos en stack
    mov x28, #0     // suma acumulada

process_stack_loop:
    cmp x24, x25
    bhs process_stack_done

    ldr x0, [x24]   // cargar valor actual
    bl add_to_sum   // acumular valor actual en la suma

    //AQUI AGREGAR OTRAS ETIQUETAS CON FUNCIONES QUE NECESITEN
    // MAXIMO
    // MINIMO
    // ETC.

    add x24, x24, #16
    b process_stack_loop

process_stack_done:
    mov x0, x28
    bl write_results

    mov x0, #0
    mov x8, #93
    svc #0

// Acumula el valor actual en la suma.
// Entrada:
//          x0 = valor actual
// Estado:
//          x28 = suma acumulada
add_to_sum:
    add x28, x28, x0
    ret
