[org 0x7c00]
; 设置屏幕模式为文本模式，清除屏幕
mov ax, 3
int 0x10

; 设置段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00


mov si,booting
call print


mov edi, 0x1000;读取的目标内存
mov ecx, 2;起始扇区
mov bl, 4;扇区数量
call read_disk

cmp word [0x1000], 0x55aa ;比较0x1000的位置是不是0x55aa,即是否加载Loader
jnz error
jmp 0:0x1008 ;这里是打印字符串的位置  ;做个标记----------------- ，这里动过



; 阻塞程序
jmp $
read_disk:
    ;设置读写扇区的数量
    mov dx, 0x1f2;读取扇区数量的端口
    mov al, bl
    out dx, al

    inc dx;0x1f3
    mov al, cl;起始扇区的前8位
    out dx, al
    
    inc dx;0x1f4
    shr ecx, 8
    mov al, cl;起始扇区的中8位
    out dx, al

    inc dx;0x1f5
    shr ecx, 8
    mov al, cl;起始扇区的高8位
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111;将高4位置为0

    mov al, 0b1110_0000;
    or al, cl
    out dx, al; 主盘-LBA模式
    
    inc dx;0x1f7
    mov al, 0x20;读硬盘
    out dx, al

    xor ecx, ecx;清空ecx
    mov cl, bl;得到读写扇区的数量

    .read:
        push cx; 保存cx
        call .waits;等待数据准备完毕
        call .reads;读取一个扇区
        pop cx; 恢复cx
        loop .read
    
    ret
    
    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2
            jmp $+2;一点点延迟
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret
    
    .reads:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区256字
        .readw:
            in ax,dx
            jmp $+2
            jmp $+2;一点点延迟
            jmp $+2
            mov [edi], ax ;将ax里的字写入目标内存
            add edi, 2  ;这里的操作系统是是16位的，所有一个字是由两个字节构成 ,目标内存指针+2，指向下一个字
            loop .readw
        ret

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
booting:
    db "Booting Onix...",10,13,0;10是换行符，13是将光标移到开头，0是结束

error:
    mov si, .msg ;将msg移动到si里面
    call print
    hlt;让 CPU 停止
    jmp $
    .msg db "Booting Error!!!",10,13,0


; 填充剩余空间
;$-$$表示当前位置与当前段的开始位置的偏移量
times 510 - ( $ - $$) db 0
; 主引导扇区的最后两个字节必须是0x55,0xaa，结束标志
db 0x55,0xaa