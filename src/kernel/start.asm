[bits 32]

global _start

_start:
    mov byte [0xb8000], 'K' ;代表进入了内核
    jmp $;阻塞