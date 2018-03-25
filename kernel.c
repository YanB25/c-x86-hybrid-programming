__asm__(".globl _start\n");
__asm__("_start:\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $main\n");

#include "utilities.h"
int main() {
    clear_screen(); // 清屏
    hello_hybrid_programming(); // 在屏幕上输出 hello hybrid programming
    // 计算4加5
    // 设置断点可知，在调用下列函数的前后
    // 栈能正确恢复
    // 且ax中保存着正确的返回值（9）
    // 且bx, si, di等被调用者保留寄存器的值未变
    my_add(4, 5);
    while(1) {}
    return 0;
}