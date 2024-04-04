/*
 * Copyright (c) 2012-2021 Andes Technology Corporation
 * All rights reserved.
 *
 */

#include "core_v5.h"

// RISC-V CSR definitions and access classes
#include "riscv-csr.h"
#include "riscv-interrupts.h"

extern void reset_vector(void);

#define RISCV_MTVEC_MODE_VECTORED 1

static volatile uint64_t ecall_count = 0;

/* This must be a leaf function, no child function */
void __platform_init(void) __attribute__((naked));
void __platform_init(void) {}

void c_startup(void)
{
#define MEMCPY(des, src, n) __builtin_memcpy((des), (src), (n))
#define MEMSET(s, c, n) __builtin_memset((s), (c), (n))
    /* Data section initialization */
    extern char _edata, _end;
    unsigned int size;

    /* Clear bss section */
    size = &_end - &_edata;
    MEMSET(&_edata, 0, size);
}

void system_init(void)
{
    csr_clr_bits_mstatus(MSTATUS_MIE_BIT_MASK);
    csr_write_mie(0);

#ifdef __VECTORED_ISR__
    // Setup the IRQ handler entry point, set the mode to vectored
    csr_write_mtvec((uint_xlen_t)riscv_mtvec_table | RISCV_MTVEC_MODE_VECTORED);
#endif

    // Enable MIE.MTI
    csr_set_bits_mie(MIE_MTI_BIT_MASK);

    /* Enable the Machine-External bit in MIE */
    csr_set_bits_mie(MIE_MEI_BIT_MASK);

    /* Enable Machine software Interrupt */
    csr_set_bits_mie(MIE_MSI_BIT_MASK);

    // Global interrupt enable
    csr_set_bits_mstatus(MSTATUS_MIE_BIT_MASK);

    return;
}
#pragma GCC pop_options
