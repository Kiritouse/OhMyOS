# 语法解释，用boot.bin依赖于boot.asm，下面是对应的输入到控制台里的参数
# 如果asm有任何更改，就会用下面的语句重新生bin文件
# 使用方法，直接使用make 开头名字即可
# 符合这种.bin和.asm的都来进行编译
# $<代表 输入的文件，$@代表输出的文件
BUILD:=../build
SRC:=.

# 内核的起始地址
ENTRYPOINT:=0x10000
CFLAGS:= -m32 #表示32位的程序
CFLAGS+= -fno-builtin #表示不使用gcc内建函数,而是使用自己的函数
CFLAGS+= -nostdinc #表示不使用标准库
CFLAGS+= -fno-pic #表示不使用位置无关代码 position independent code 
CFLAGS+= -fno-pie #表示不使用位置无关的可执行文件
CFLAGS+= -nostdlib #表示不使用标准库
CFLAGS+= -fno-stack-protector #表示不使用栈保护
CFLAGS:= $(strip ${CFLAGS})  #去掉多余的空格

DEBUG:= -g
INCLUDE:=-I$(SRC)/include

$(BUILD)/boot/%.bin:	$(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@)) 
	nasm -f bin $< -o $@

$(BUILD)/kernel/%.o:	$(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@)) 
	nasm -f elf32 $(DEBUG) $< -o $@

$(BUILD)/kernel/%.o:	$(SRC)/kernel/%.c
	$(shell mkdir -p $(dir $@)) 
	gcc $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD)/kernel.bin:	$(BUILD)/kernel/start.o \
	 $(BUILD)/kernel/main.o 

	$(shell mkdir -p $(dir $@)) 
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

$(BUILD)/system.bin:	$(BUILD)/kernel.bin
	objcopy -O binary $< $@ 

$(BUILD)/system.map:	$(BUILD)/kernel.bin
	nm $< | sort > $@
	
 

$(BUILD)/master.img:	$(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map \
	
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

#最后一个代表从seek=2即从第二个扇区开始写，写上4个扇区

# 总的来说，这行代码的作用是读取 /dev/sdb  设备的前 512 字节的数据，并将这些数据写入 tmp.bin 文件。
# tmp.bin不可读取，但是usb.bin可读取
# 将boot.bin的数据写入到usb.bin里面，但是不能覆盖掉usb.bin
# 的后面的主引导扇区里面的硬盘分区表的信息
# 该信息在446B之后，所以我们使用bs=446 count=1来指定dd命令只写入前446B的数据
# 这段 `makefile` 代码定义了一个名为 `usb` 的伪目标，用于将 `boot.bin` 文件写入到 `/dev/sdb` 设备（通常是一个 USB 设备）。
# 以下是每行代码的解释：
# 1. `.PHONY: usb`：声明 `usb` 是一个伪目标。
# 2. `usb: boot.bin /dev/sdb`：定义了 `usb` 伪目标的依赖。这意味着在执行 `usb` 目标之前，`make` 命令会检查 `boot.bin` 文件和 `/dev/sdb` 设备。
# 3. `sudo dd if=/dev/sdb of=tmp.bin bs=512 count=1 conv=notrunc`：从 `/dev/sdb` 设备读取前 512 字节的数据，并将这些数据写入 `tmp.bin` 文件。
# 4. `cp tmp.bin usb. bin`：复制 `tmp.bin` 文件到 `usb.bin` 文件。
# 5. `sudo rm tmp.bin`：删除 `tmp.bin` 文件。
# 6. `dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc`：从 `boot.bin` 文件读取前 446 字节的数据，并将这些数据写入 `usb.bin` 文件。这会覆盖 `usb.bin` 文件的前 446 字节的数据。
# 7. `sudo dd if=usb.bin of=/dev/sdb bs=512 count=1 conv=notrunc`：将 `usb.bin` 文件的内容写入到 `/dev/sdb` 设备。这会覆盖 `/dev/sdb` 设备的前 512 字节的数据。
# 8. `rm usb.bin`：删除 `usb.bin` 文件。
# 总的来说，这段代码的作用是将 `boot.bin` 文件的前 446 字节的数据写入到 `/dev/sdb` 设备的前 446 字节的位置，而保留 `/dev/sdb` 设备的其他数据。这通常用于安装引导加载程序到 USB 设备。
.PHONY: usb
usb:	$(BUILD)/boot/boot.bin /dev/sdb
	sudo dd if=/dev/sdb of=tmp.bin bs=512 count=1 conv=notrunc 
	cp tmp.bin usb.bin 
	sudo rm tmp.bin
	dd if=$(BUILD)/boot/boot.bin of=usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=usb.bin of=/dev/sdb bs=512 count=1 conv=notrunc
	rm usb.bin
#代表clean块是伪目标，不检查文件，无论如何都会执行
test:$(BUILD)/master.img


.PHONY: clean
clean:
	rm -rf $(BUILD)
	



.PHONY: bochs
bochs:	$(BUILD)/master.img
	bochs -q