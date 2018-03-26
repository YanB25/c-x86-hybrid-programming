# Linux下C和汇编混编方式
请求各位完善这份文档，为未来的学弟学妹带来帮助。  
关于完善这份文档见contribution guide。  
[toc]
关于Windows下的混编方法，见下Windows小节  
## 工具链
- GCC  
用于编译C代码,生成目标文件
- NASM  
用于编译汇编代码，生成目标文件
- ld  
linux下自带的链接工具。
- dd  
用于写入虚拟软盘
- bochs
虚拟机

## Usage guide
### Linux
编译和运行的方法
``` sh
# 清空所有的生成文件
make clean
# 编译生成所有需要的文件
make
# 将生成的文件写入到虚拟软盘中
make build
# 运行bochs虚拟机，执行OS.img中的代码
make run
```
### Windows
下载本repo并切换到`windows`分支。  
采用git客户端或于命令行输入。  
``` sh
$ git checkout windows
```
若报错，请先输入
``` sh
$ git fetch --all
```
并再次输入以上的命令行。  
# 混编方式
## 引导程序
引导程序如`loader.asm`所示．　　
引导程序先把内核载入到内存起始为`A100H`的地方．如文件的`.load_kernel:`标签处代码所示．
内核的位置并不一定要是`A100H`,其他允许的位置也行．　　
随后，通过`jmp 0xA100`，程序控制跳到了内核的代码处．　　

**注意，这个跳转能正确执行，要求＂内核的代码从其第一条指令处开始执行，能够正确地执行成功＂．换言之，内核的代码不应有文件头，因为文件头是不可执行的．**

细节：
loader.asm的开头[.BIT 16]告诉nasm生成16位代码.global _start　告诉链接器代码的入口地址在哪．

//TODO:(YB)上面这段话中，链接器部分存疑。
## 内核程序
内核程序如`kernel.c`所示．
**注意kernel.c开头的重要代码，这是程序正确运行的关键**．
其重要代码摘录如下
``` c
__asm__(".globl _start\n");
__asm__("_start:\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $main\n");
```
其中，`__asm__()`用于嵌入汇编代码．汇编代码以字符串的形式嵌入，并采用AT&T格式书写．注意每个字符串末尾的`\n`不可缺少．  

`.globl _start`和`_start:`只是为了让连接器知道程序的入口地址在哪．去掉这两句，连接器会默认入口地址在开头．去掉这两句后不影响程序的运行，但连接器会报出Warning.  

//TODO: （YB）上面这段话中，＂让连接器知道程序入口地址在哪＂的正确性待定．不加这两句，程序的确可以正确运行，但到底有何不同待定．  

`jmpl $0, $main`将把程序的控制权跳到`kernel.c`中的`main`函数．具体请见AT&T的语法．  

在`main`函数中，仅有以下的代码  
```c
int main() {
    clear_screen();
    hello_hybrid_programming();
    while(1) {}
    return 0;
}
```
其中`while(1) {}`相当于`jmp $`  
`clear_screen()`将清屏  
`hello_hybrid_programming()`将于屏幕上输出一个字符串.  

**这两个函数的声明(prototype)在utilities.h中．由于kernel.c 包含了utilities.h，故能保证编译通过．但这两个函数的定义（函数体）在汇编代码utilities.asm中书写，最终通过连接器链接在一起**．

## 汇编实现的Ｃ函数
### 返回方式
大体上跟直接写汇编是一样的。  

**特别注意函数的返回方式！**
函数的返回是通过以下代码做到的  
``` asm
    pop ecx
    jmp cx
```
由于`gcc`编译生成的C代码，在`call`时会将压入32位的返回地址，而
汇编代码的`ret`只会出栈16位的地址，所以此处需要有变通的方法。  
先`pop 32bit`把栈恢复到函数调用前的位置，再`jmp`到低16位处。

### 汇编取得参数的方式
在C中有代码`my_add(4, 5)`，汇编取得参数4和5的方式如下。  
``` nasm
    mov ax, [bp + 6]
    mov cx, [bp + 10]
```
其中`ax`和`cx`中的值即为函数的第1,2个参数。  
由于函数`call`是进栈4字节，`push bp`（见my_add源码）操作进栈2字节，所以`bp + 6`指向第一个参数。  

gcc 在传参时默认做提升（见gcc文档），参数都被看作32位。 故下一个参数的位置在`bp + (6+4)`.  

具体见`x86调用协定`.

## 编译方式
对`makefile`比较了解的同学，可以直接阅读`Makefile`文件。  
不了解的同学，将以下提到的指令依次运行，即可完成编译运行操作。 
如果以下指令与`Makefile`文件有冲突，请以`Makefile`为准。   
### GCC 编译指令
``` sh
$ gcc -march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding -c kernel.c
```
<!-- tips:那个`\`号只是因为代码太长，看起来不好看，用来换行的。那个`>`是换行后`bash`自带的，不是让你输入的。   -->

- `-march=i386`使用intel 原始的i386架构
//TODO:(YB) 需要更多更具体的解释
- `-m16`
相当于在`kernel.c`程序的最前面加上`__asm__(".code16gcc\n")`指令。让GCC生成16位指令。注意：GCC实际上并不能（也没有）生成16位的代码。代码实际上仍是32位的。
//TODO:(yb) 需要更多的解释。需要解释代码的66/67头。需要一些博客的链接。
- `-mpreferred-stack-boundary=2`
栈对齐方式为2的2次方。
- `-ffreestanding`
GCC在编译时使用“自立”的环境。即，不使用任何标准库，且程序的入口地址不一定为"main"函数。
//TODO: (YB)关于程序的入口地址处存疑。需要更详细的解释。

### NASM编译指令
``` sh
$ nasm -f elf32 -o utilities.o utilities.asm
$ nasm -f elf32 -o loader.o loader.asm 
```
- `-f elf32`
等价于`-f elf`和`-elf`等（具体见nasm文档）。  
注意，此处的目的为生成目标文件。而目标文件一定不能为`.bin`和`.com`文件。此处选择了比较适用的32位`elf`文件。
### LD的链接指令
``` sh
$ ld -melf_i386 -N -Ttext 0xA100 --oformat binary -o kernel.bin kernel.o utilities.o 
$ ld -melf_i386 -N -Ttext 0x7c00 --oformat binary -o loader.bin loader.o
```
- `--oformat binary`
链接后最终产生二进制文件。该步能保证链接后产生的文件没有文件头。
注意：若产生的文件有文件头，本项目将无法运行。见以上关于“引导程序”的描述。
- `-N`
TODO:(YB) 待补充。  
- `-Ttext 0x7c00`
让Text段起始于0x7c00  
例如，`loader.asm`文件中，`global _start`使得`org`指令不合法
。此时关于偏移的计算不应再交由NASM完成，而应交由链接器完成。故此处明确告知链接器，起始地点为`0x7c00`  
TODO:(yb)此处需要更多的补充。新开一个section谈谈链接和地址的问题？
### 写入虚拟软盘的指令
``` sh
$ dd if=loader.bin of=OS.img conv=notrunc
$ dd if=kernel.bin of=OS.img conv=notrunc oflag=seek_bytes seek=512
```

### 运行指令
``` sh
$ bochs
```

## Contribution guide
1. 有新的修改可以pull request或私戳我拉collaborator.
1. 请求所有TODO能得到完善
在readme内搜索TODO即可找到todo内容。
1. 不确定的地方随意增加新的todo
每个TODO后请指出TODO列出者的名称，例如
    ``` markdown
    TODO:(YB) 这里的xxxx我不太确定
    ```
1. keep it simple
这份代码应该尽可能简单但能阐述清楚问题。  
1. keep it correct
每次修改后保证代码能正确运行。  
