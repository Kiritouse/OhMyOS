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

; 0xb800，文本显示器的内存区域
mov ax, 0xb800
mov ds, ax

mov byte [0], 'H'

; 阻塞程序
jmp $

; 填充剩余空间
;$-$$表示当前位置与当前段的开始位置的偏移量
times 510-($-$$) db 0
; 主引导扇区的最后两个字节必须是0x55,0xaa，结束标志
db 0x55,0xaa