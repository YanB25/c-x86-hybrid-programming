[BITS 16]
global clear_screen
global hello_hybrid_programming
global my_add

clear_screen:
    ; 清屏
    mov ax, 03h
    int 10h
    pop ecx
    jmp cx

hello_hybrid_programming:
    ; 在屏幕上打印 hello hybrid programming
    mov ah, 13H
    mov al, 1
    mov bl, 0FH
    mov bh, 0
    mov dh, 5
    mov dl, 5
    mov bp, helloStr
    mov cx, length
    int 10H

    pop ecx
    jmp cx

my_add:
    ;将参数一和参数二相加，再返回
    push bp
    mov bp, sp
    sub sp, 0 ; 如果要在栈上分配空间，把这句的0改成所分配的字节数

    mov ax, [bp + 6]
    add ax, [bp + 10]
    
    pop bp

    pop ecx
    jmp cx

helloStr db "hello hybrid programming!"
length equ $ - helloStr