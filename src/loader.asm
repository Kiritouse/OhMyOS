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
    ;实模式不能访问这么大的内存
    mov byte [0xb8000], 'P' ;在屏幕上写入字符
 ;前面的所有都是实模式
    jmp prepare_protected_mode
prepare_protected_mode:
    xchg bx, bx
    cli ;关闭中断

;打开A20线，操作0x92端口
    in al,  0x92
    or al ,0b10
    out 0x92, al

;加载 gdt
    lgdt [gdt_ptr]
;启动保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

;用跳转来刷新缓存
    jmp dword code_selector:protect_mode



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





[bits 32]
protect_mode:
    xchg bx,bx
    mov ax, data_selector
    mov ds, ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax ;将所有段寄存器都设置为数据段

    mov esp,    0x10000 ;设置栈顶

    ;可以直接操作1M以外的内存
    mov byte [0xb8000], 'P' ;在屏幕上写入字符

    mov byte [0x200000], 'p'
jmp $

;因为低两位为特权级和表示表指示符
;所以选择子需要左移3位 ，然后加上代码段和数据段的选择子
;这里代码段和数据段的索引是1和2
code_selector equ (1<<3) ;代码段选择子
data_selector equ (2<<3) ;数据段选择子
memory_base equ 0 ;内存基址
memory_limit  equ ((1024*1024*1024*4) /(1024*4) ) -1 ;4G/4K 内存界限

gdt_ptr:
    dw (gdt_end - gdt_base )-1 ;GDT的界限
    dd gdt_base ;GDT的基址
gdt_base:
    dd 0, 0 ;NULL描述符
gdt_code:
    dw memory_limit & 0xffff ;段界限
    dw memory_base & 0xffff ;段基址 0-15位
    db (memory_base >> 16) & 0xff ;段基址 16-23位
    ;存在dpl 0 -S段-代码-非依从-可读-没有被访问过
    db 0b_1_00_1_1_0_1_0  
    ;4k-32位-不是64位-段界限16~19位
    db 0b1_1_0_0_0000 | ((memory_limit >> 16) & 0x0f)
    db (memory_limit >> 24) & 0xff ;段界限 24-31位 

gdt_data:
    dw memory_limit & 0xffff ;段界限
    dw memory_base & 0xffff ;段基址 0-15位
    db (memory_base >> 16) & 0xff ;段基址 16-23位
     ;存在dpl 0 -S段-数据-非依从-可读-没有被访问过
    db 0b_1_00_1_0_0_1_0 
    ;4k-32位-不是64位-段界限16~19位
    db 0b1_1_0_0_0000 | ((memory_limit >> 16) & 0x0f)
    db (memory_limit >> 24) & 0xff ;段界限 24-31位 
gdt_end:

ards_count: 
    dw 0
ards_buffer:

