// x21, direccion de donde empezamos a leer

atoi_csv:
    mov x10, #0             // resultado = 0
    mov x5, #10             // base 10
    mov x7, #0              // bandera de numero activo

atoi_loop:
    ldrb w23, [x21], #1

    // verificar si es digito
    cmp w23, '0'
    blt atoi_done

    cmp w23, '9'
    bgt atoi_done

    // convertir ASCII a numero
    sub w23, w23, '0'

    // resultado = resultado * 10
    mov x4, x10
    mul x10, x4, x5

    // resultado = resultado + digito
    add x10, x10, x23

    // marcar numero activo
    mov x7, #1

    b atoi_loop

atoi_done:
    ret
