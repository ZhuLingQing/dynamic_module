#include <stdio.h>
#include "kernel_def.h"

int main() {
    printf ("test load module[%s]...\n", __TIME__);

    const kernel_reg_t **kernel = kernel_table_entry();
    if (!kernel) { printf("No kernel found\n"); return 1; }
    else printf("Kernel found @%p\n", kernel);
    
    int idx = 0;
    while (kernel[idx])
    {
        printf("Kernel-%d: %s @%p\n", idx, kernel[idx]->name, kernel[idx]->entry);
        idx++;
    }
    printf("%d Kernel found\n", idx);
    
    long c;
    kernel_fp fp_mul = kernel_find("kernel_mul");
    if (0 != fp_mul(10, 20, &c)) printf("kernel_mul failed\n");
    if ( c != 10 * 20 ) printf("kernel_mul wrong\n");

    kernel_fp fp_sum = kernel_find("kernel_sum");
    if (0 != fp_sum(10, 20, &c)) printf("kernel_sum failed\n");
    if ( c != 10 + 20 ) printf("kernel_sum wrong\n");
    
    return 0;
}
