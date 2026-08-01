.data
msg: .ascii "Hello, World!\n"
    msg_len = . - msg

.text
.global _start

_start:
    mov x0, #1
    ldr x1, =msg
    mov x2, msg_len
    mov x8, #64
    svc #0

    mov x0, #0
    mov x8, #93
    svc #0
