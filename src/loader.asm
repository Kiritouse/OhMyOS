[org 0x1000]

dw 0x55aa;魔数，用于判断错误



;打印字符串
mov si, loading 
call print
xchg bx, bx;断点
detect_memory:
    ; 将ebx置0
    xor ebx, ebx
    ;将段寄存器置为0，特殊寄存器不能直接xor为0，所以需要先赋值给ax
    mov ax, 0
    mov es, ax 
    mov edi, ards_buffer ;存储结构体的内存位置

    mov edx, 0x534d4150 ;将edx置为"SMAP",固定签名
.next:
    ;子功能号
    mov eax, 0xe820
    ; ards 结构的大小
    mov ecx, 20
    ;调用 0x15 系统调用
    int 0x15
    ;如果CF置位，表示出错
    jc error
    ;否则将缓存指针指向下一个结构体
    add di, cx
    ;将结构体数量+1
    inc word [ards_count]
    cmp ebx, 0
    jnz .next ;如果不是0继续检测
    mov si, detecting
    call print
    xchg bx, bx
    ;结构体数量
    mov cx, [ards_count]
    ;结构体指针
    mov si, 0
.show:
    mov eax, [ards_buffer+si]
    mov ebx, [ards_buffer+si+8]
    mov edx, [ards_buffer+si+16]
    add si, 20
    xchg bx, bx
    loop .show

    

jmp error
;阻塞
jmp $

print:
    mov ah,0x0e
.next:
    mov al,[si]
    cmp al,0
    jz  .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
loading:
    db "Loading Onix...",10,13,0;10是换行符，13是将光标移到开头，0是结束
detecting:
    db "Detecting Memory success...",10,13,0

error:
    mov si, .msg ;将msg移动到si里面
    call print
    hlt;让 CPU 停止
    jmp $
    .msg db "Loading Error!!!",10,13,0

ards_count:
    dw 0
ards_buffer:

