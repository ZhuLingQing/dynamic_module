#ifndef _KERNEL_DEF_H_
#define _KERNEL_DEF_H_

typedef int (*kernel_fp)(long , long, long *);

typedef struct {
    const char *name;
    kernel_fp entry;
}kernel_reg_t;

#define KERNEL_REGISTER(name) \
    static const kernel_reg_t __kernel_reg_##name = {#name, name};\
    volatile const long __kernel_reg_##name##_ptr \
    __attribute__((section(".kernel_reg")))= (long)&__kernel_reg_##name;

static inline const kernel_reg_t **kernel_table_entry() {
    extern char __kernel_reg_entry;
    return (const kernel_reg_t **)&__kernel_reg_entry;
}

static inline kernel_fp kernel_find( const char *name ) {
    const kernel_reg_t **kernel = kernel_table_entry();
    while (*kernel)
    {
        if (0 == strcmp((*kernel)->name, name)) return (*kernel)->entry;
        kernel++;
    }
    return 0;
}

#endif // _KERNEL_DEF_H_
