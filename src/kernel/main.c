#include <ohmyos/ohmyos.h>
int magic = OHMYOS_MAGIC;
char message[] = "hello,ohmyos!!!"; //.data段中
char buf[1024]; //.bss段中
void kernel_init(){
        char *video=(char *) 0xb8000; //文本显示器的内存位置,只有操作系统才能访问
        for(int i = 0;i<sizeof(message);i++){
            video[i*2]=message[i];         
        }
}