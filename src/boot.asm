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

xchg bx, bx;bochs调试器中设置断点,交换同一个寄存器就会卡在这里
mov si,booting
call print



; 阻塞程序
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
booting:
    db "Booting Onix...",10,13,0;10是换行符，13是将光标移到开头，0是结束


; 填充剩余空间
;$-$$表示当前位置与当前段的开始位置的偏移量
times 510-($-$$) db 0
; 主引导扇区的最后两个字节必须是0x55,0xaa，结束标志
db 0x55,0xaa