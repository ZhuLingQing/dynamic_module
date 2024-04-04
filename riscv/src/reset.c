#include "riscv-csr.h"

extern void c_startup(void);
extern void system_init(void);
extern void __libc_init_array(void);

__attribute__((weak)) void reset_handler(void)
{
    extern int main(void);

    /*
     * Initialize LMA/VMA sections.
     * Relocation for any sections that need to be copied from LMA to VMA.
     */
    c_startup();

    /* Call platform specific hardware initialization */
    system_init();

    /* Do global constructors */
    __libc_init_array();

    long rc = main();
    csr_write_mscratch(rc);
    // tzhu: disable interrupt here
    csr_clr_bits_mstatus(MSTATUS_MIE_BIT_MASK);
    __asm__ volatile("wfi");
    
    exit(rc);
}

/*
 * When compiling C++ code with static objects, the compiler inserts
 * a call to __cxa_atexit() with __dso_handle as one of the arguments.
 * The dummy versions of these symbols should be provided.
 */
void __cxa_atexit(void (*arg1)(void*), void* arg2, void* arg3) {}

void* __dso_handle = (void*)&__dso_handle;
