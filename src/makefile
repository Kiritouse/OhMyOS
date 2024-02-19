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

# 总的来说，这行代码的作用是读取 /dev/sdb 设备的前 512 字节的数据，并将这些数据写入 tmp.bin 文件。
# tmp.bin不可读取，但是usb.bin可读取
# 将boot.bin的数据写入到usb.bin里面，但是不能覆盖掉usb.bin
# 的后面的主引导扇区里面的硬盘分区表的信息
# 该信息在446B之后，所以我们使用bs=446 count=1来指定dd命令只写入前446B的数据
# 这段 `makefile` 代码定义了一个名为 `usb` 的伪目标，用于将 `boot.bin` 文件写入到 `/dev/sdb` 设备（通常是一个 USB 设备）。
# 以下是每行代码的解释：
# 1. `.PHONY: usb`：声明 `usb` 是一个伪目标。
# 2. `usb: boot.bin /dev/sdb`：定义了 `usb` 伪目标的依赖。这意味着在执行 `usb` 目标之前，`make` 命令会检查 `boot.bin` 文件和 `/dev/sdb` 设备。
# 3. `sudo dd if=/dev/sdb of=tmp.bin bs=512 count=1 conv=notrunc`：从 `/dev/sdb` 设备读取前 512 字节的数据，并将这些数据写入 `tmp.bin` 文件。
# 4. `cp tmp.bin usb.bin`：复制 `tmp.bin` 文件到 `usb.bin` 文件。
# 5. `sudo rm tmp.bin`：删除 `tmp.bin` 文件。
# 6. `dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc`：从 `boot.bin` 文件读取前 446 字节的数据，并将这些数据写入 `usb.bin` 文件。这会覆盖 `usb.bin` 文件的前 446 字节的数据。
# 7. `sudo dd if=usb.bin of=/dev/sdb bs=512 count=1 conv=notrunc`：将 `usb.bin` 文件的内容写入到 `/dev/sdb` 设备。这会覆盖 `/dev/sdb` 设备的前 512 字节的数据。
# 8. `rm usb.bin`：删除 `usb.bin` 文件。
# 总的来说，这段代码的作用是将 `boot.bin` 文件的前 446 字节的数据写入到 `/dev/sdb` 设备的前 446 字节的位置，而保留 `/dev/sdb` 设备的其他数据。这通常用于安装引导加载程序到 USB 设备。
.PHONY: usb
usb:	boot.bin /dev/sdb
	sudo dd if=/dev/sdb of=tmp.bin bs=512 count=1 conv=notrunc 
	cp tmp.bin usb.bin 
	sudo rm tmp.bin
	dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=usb.bin of=/dev/sdb bs=512 count=1 conv=notrunc
	rm usb.bin

.PHONY: bochs
bochs:	master.img
	bochs -q