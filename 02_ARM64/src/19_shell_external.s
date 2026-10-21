// El padre espera al hijo y continúa después de wait4

.data
program_path: .asciz "/bin/echo"
arg_one:      .asciz "hola"
arg_two:      .asciz "desde el hijo"
.balign 8
exec_argv:    .quad program_path, arg_one, arg_two, 0
empty_envp:   .quad 0                // Entorno vacío, terminado en NULL

parent_before:
    .ascii "Padre: voy a crear un hijo.\n"
    parent_before_len = . - parent_before
child_before:
    .ascii "Hijo: intentaré ejecutar /bin/echo.\n"
    child_before_len = . - child_before
parent_after:
    .ascii "Padre: el hijo terminó continúo aquí.\n"
    parent_after_len = . - parent_after
clone_error:
    .ascii "Error: clone no pudo crear el hijo.\n"
    clone_error_len = . - clone_error
exec_error:
    .ascii "Error: execve no pudo ejecutar /bin/echo.\n"
    exec_error_len = . - exec_error
wait_error:
    .ascii "Error: wait4 no pudo esperar al hijo.\n"
    wait_error_len = . - wait_error
child_error:
    .ascii "Padre: el hijo terminó con error continúo aquí.\n"
    child_error_len = . - child_error

.bss
.balign 4
child_status:
    .skip 4

.text
.global _start

_start:
    ldr x1, =parent_before
    mov x2, parent_before_len
    bl print

    // Primero usar con un hijo que imprime y sale aquí usa execve
    mov x0, #17                     // SIGCHLD para avisar al padre
    mov x1, #0                      // Usar la pila actual en el hijo
    mov x2, #0                      // parent_tid no se usa
    mov x3, #0                      // tls no se usa
    mov x4, #0                      // child_tid no se usa
    mov x8, #220                    // clone(flags, stack, ...)
    svc #0
    cmp x0, #0
    b.lt clone_failed               // Negativo: error
    cbz x0, child                   // Cero: estamos en el hijo

    mov x19, x0                     // Positivo: PID del hijo en el padre
wait_child:
    mov x0, x19
    ldr x1, =child_status           // Guardar aquí el estado del hijo
    mov x2, #0                      // Esperar hasta que termine
    mov x3, #0                      // No pedir datos de recursos
    mov x8, #260                    // wait4(pid, &status, 0, NULL)
    svc #0
    cmp x0, #-4                     // EINTR: repetir la espera
    b.eq wait_child
    cmp x0, #0
    b.lt wait_failed

    ldr x1, =child_status
    ldr w0, [x1]
    cbnz w0, child_failed           // Estado distinto de cero: error o señal
    ldr x1, =parent_after
    mov x2, parent_after_len
    bl print
    mov x0, #0
    b finish

child:
    ldr x1, =child_before
    mov x2, child_before_len
    bl print

    ldr x0, =program_path           // Ruta del programa
    ldr x1, =exec_argv              // Argumentos terminados en NULL
    ldr x2, =empty_envp             // Entorno terminado en NULL
    mov x8, #221                    // execve(path, argv, envp)
    svc #0                          // Si funciona, el hijo pasa a ejecutar /bin/echo

    // Si execve retorna, hubo un error
    mov x0, #2                      // stderr
    ldr x1, =exec_error
    mov x2, exec_error_len
    mov x8, #64
    svc #0
    mov x0, #1
    b finish

clone_failed:
    ldr x1, =clone_error
    mov x2, clone_error_len
    bl print
    mov x0, #1
    b finish

wait_failed:
    ldr x1, =wait_error
    mov x2, wait_error_len
    bl print
    mov x0, #1
    b finish

child_failed:
    ldr x1, =child_error
    mov x2, child_error_len
    bl print
    mov x0, #1

finish:
    mov x8, #93                     // exit(x0) en este proceso
    svc #0

// x1 = dirección, x2 = longitud
print:
    mov x0, #1
    mov x8, #64
    svc #0
    ret
