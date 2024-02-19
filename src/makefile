# 语法解释，用boot.bin依赖于boot.asm，下面是对应的输入到控制台里的参数
# 如果asm有任何更改，就会用下面的语句重新生bin文件
# 使用方法，直接使用make 开头名字即可
boot.bin:	boot.asm
	nasm -f bin boot.asm -o boot.bin

master.img:	boot.bin
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc

#代表clean块是伪目标，不检查文件，无论如何都会执行
.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.img

.PHONY: bochs
bochs:	master.img
	bochs -q