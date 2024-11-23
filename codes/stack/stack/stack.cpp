#include <stdio.h>
#include <stdlib.h>

int g = 42; // ȫ�ֱ�����λ�����ݶΣ�.data �� .bss��

void nested_func(int param) {
    int nested_stack_var = 0; // �ֲ�������λ��ջ��
    printf("In nested_func:\n");
    printf("  Address of code (nested_func): %p\n", (void*)nested_func);
    printf("  Address of global variable g: %p\n", (void*)&g);
    printf("  Address of stack variable in nested_func: %p\n", (void*)&nested_stack_var);
    printf("  Address of parameter param: %p\n", (void*)&param);
    printf("  Approximate stack pointer: %p\n\n", (void*)&nested_stack_var);
}

void func1(int param1, int param2) {
    int func1_stack_var = 0; // �ֲ�������λ��ջ��
    printf("In func1:\n");
    printf("  Address of code (func1): %p\n", (void*)func1);
    printf("  Address of global variable g: %p\n", (void*)&g);
    printf("  Address of stack variable in func1: %p\n", (void*)&func1_stack_var);
    printf("  Address of parameter param1: %p\n", (void*)&param1);
    printf("  Address of parameter param2: %p\n", (void*)&param2);
    printf("  Approximate stack pointer: %p\n\n", (void*)&func1_stack_var);

    // ����Ƕ�׺���
    nested_func(param1 + param2);
}

int main() {
    printf("Address overview:\n");

    // ��ӡ�������ʼ��ַ
    printf("  Address of main (code segment): %p\n", (void*)main);

    // ��ӡȫ�ֱ��������ݶΣ�
    printf("  Address of global variable g (data segment): %p\n", (void*)&g);

    // ��ӡ������ַ
    void* heap_var = malloc(1);
    printf("  Address of heap variable (heap): %p\n", heap_var);
    free(heap_var);

    // ��ӡջ����ַ
    int main_stack_var = 0;
    printf("  Address of stack variable in main (stack): %p\n", (void*)&main_stack_var);
    printf("  Approximate stack pointer: %p\n\n", (void*)&main_stack_var);

    // ����һ��������������������
    func1(10, 20);

    return 0;
}
