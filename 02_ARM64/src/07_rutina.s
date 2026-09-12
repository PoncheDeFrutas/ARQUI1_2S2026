.data

sum_text:
    .ascii "Suma: "
    sum_text_len = . - sum_text

sub_text:
    .ascii "Resta: "
    sub_text_len = . - sub_text

newline:
    .ascii "\n"

.bss

number:
    .skip 32

.text

.include "08_utils.s"
.include "06_itoa.s"

.global _start

_start:
    bl read_column_to_stack
    mov x24, x0             // inicio de los numeros
    mov x25, x1             // final de los numeros
    mov x27, #0             // suma
    mov x28, #0             // resta

read_numbers:
    cmp x24, x25
    beq print_sum
    ldr x10, [x24]
    add x27, x27, x10
    sub x28, x28, x10
    add x24, x24, #16
    b read_numbers

print_sum:
    ldr x1, =sum_text
    mov x2, sum_text_len
    bl print
    mov x0, x27
    bl print_number
    bl print_newline

    ldr x1, =sub_text
    mov x2, sub_text_len
    bl print
    mov x0, x28
    bl print_number
    bl print_newline

    mov x0, #0
    mov x8, #93
    svc #0

print_number:
    mov x9, x30
    ldr x1, =number
    add x1, x1, #32
    bl itoa
    mov x30, x9
    b print

print_newline:
    ldr x1, =newline
    mov x2, #1

print:
    mov x0, #1
    mov x8, #64
    svc #0
    ret
