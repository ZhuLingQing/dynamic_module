#include "kernel_def.h"
#include <stdio.h>

static int kernel_sum(long a, long b, long *c)
{
    printf("This is %s()\n", __FUNCTION__);
    if (!c) return 1;
    *c = a + b;
    return 0;
}

KERNEL_REGISTER(kernel_sum)
