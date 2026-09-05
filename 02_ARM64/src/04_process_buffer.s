.data

filename:
    .asciz "src/lecturas.csv"

err_open:
    .ascii "Error: no se pudo abrir lecturas.csv\n"
    err_open_len = . - err_open

err_read:
    .ascii "Error: no se pudo leer lecturas.csv\n"
    err_read_len = . - err_read

.bss
buffer:
    .skip 4096

.text

.global _start

_start:
    // OPENAT(AT_FDCWD, "lecturas.csv", O_RDONLY, 0)
    mov x0, #-100       // AT_FDCWD (Directorio actual)
    ldr x1, =filename   // Dirección del nombre del archivo
    mov x2, #0          // O_RDONLY
    mov x3, #0          // Modo
    mov x8, #56         // syscall openat
    svc #0

    // Verificar si hubo error al abrir el archivo
    cmp x0, #0
    blt open_error

    // Guardar el descriptor de archivo en x19
    mov x19, x0

read_loop:
    // Leer bloque del archivo
    // READ(x19, buffer, 4096)
    mov x0, x19        // Descriptor de archivo
    ldr x1, =buffer    // Dirección del buffer
    mov x2, #4096      // Tamaño a leer
    mov x8, #63        // syscall read
    svc #0

    // Verificar si hubo error al leer
    cmp x0, #0
    blt read_error

    cbz x0, close_file

    // Guardar el número de bytes leídos en x20
    mov x20, x0

    ldr x21, =buffer     // Dirección del buffer
    mov x22, x20         // Cantidad de bytes leídos

process_buffer:
    cbz x22, read_loop   // si ya no tenemos bytes, volvemos aleer

    // Leemos el contenido de la dirección actual.
    ldrb w23, [x21, #0]   // Cargar el byte actual en w23

    // Si es $ finalizamos la rectura
    cmp w23, '$'
    beq close_file

    // imprimir el caracter
    // write(STDOUT, x21, 1)
    mov x0, #1          // STDOUT
    mov x1, x21         // Dirección del caracter (ya avanzamos el puntero)
    mov x2, #1          // Cantidad de bytes a escribir
    mov x8, #64         // syscall write
    svc #0

    add x21, x21, #1     // Avanzar el puntero
    sub x22, x22, #1     // Decrementamos el contador de bytes leídos
    b process_buffer     // Volvemos a procesar el buffer

open_error:
    mov x0, #1          // STDOUT
    ldr x1, =err_open   // Dirección del mensaje de error
    mov x2, err_open_len // Longitud del mensaje
    mov x8, #64         // syscall write
    svc #0

    // Exit
    mov x0, #1
    mov x8, #93
    svc #0

read_error:
    mov x0, #1          // STDOUT
    ldr x1, =err_read   // Dirección del mensaje de error
    mov x2, err_read_len // Longitud del mensaje
    mov x8, #64         // syscall write
    svc #0

    // Exit
    mov x0, #2
    mov x8, #93
    svc #0

close_file:
    // close(x19)
    mov x0, x19         // Descriptor de archivo
    mov x8, #57         // syscall close
    svc #0

    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
