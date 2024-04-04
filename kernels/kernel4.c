#include "kernel_def.h"
#include <stdio.h>

static int kernel_div(long a, long b, long *c)
{
    printf("This is %s()\n", __FUNCTION__);
    if (!c) return 1;
    if (b == 0) return 2;
    *c = a / b;
    return 0;
}

KERNEL_REGISTER(kernel_div)
