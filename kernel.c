__asm__(".globl _start\n");
__asm__("_start:\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $main\n");

#include "utilities.h"
int main() {
    clear_screen();
    hello_hybrid_programming();
    my_add(4, 5);
    while(1) {}
    return 0;
}