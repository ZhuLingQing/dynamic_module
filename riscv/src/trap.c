/*
 * Copyright (c) 2012-2021 Andes Technology Corporation
 * All rights reserved.
 *
 */

#include <stdio.h>
#include "core_v5.h"
#if defined(DV_TEST_EN) || defined(LEMUR_TEST_EN)
#include "middleware/test_report/gf_test_result.h"
#endif

typedef struct
{
    union
    {
        struct
        {
            long x1;
            long x4;
            long x5;
            long x6;
            long x7;
            long x10;
            long x11;
            long x12;
            long x13;
            long x14;
            long x15;
            long x16;
            long x17;
            long x28;
            long x29;
            long x30;
            long x31;
        };
        long caller_regs[17];
    };
    long mepc;
    long mstatus;
    long mxstatus;
#ifdef __riscv_flen
#if __riscv_flen == 64
    long long fp_caller_regs[20];
#else
    long fp_caller_regs[20];
#endif
    int fcsr;
#endif
} SAVED_CONTEXT;

void (*overrided_trap_handler)(long cause, long epc, long *reg) = 0;

void RegistTrapHandler(void (*fp)(long cause, long epc, long *reg)) { overrided_trap_handler = fp; }

__attribute__((weak)) void PlicInterruptHandler(void) {}
__attribute__((weak)) void MtimeInterruptHandler(void) {}

__attribute__((weak)) void mswi_handler(void)
{
    // clear_csr(NDS_MIE, MIP_MSIP);
}

__attribute__((weak)) void syscall_handler(long n, long a0, long a1, long a2, long a3)
{
    /*printf("syscall #%ld (a0:0x%lx,a1:0x%lx, a2:0x%lx, a3:0x%lx)\n", n, a0, a1,
           a2, a3);*/
}

__attribute__((weak)) long except_handler(long cause, long epc, long *reg)
{
    /* Unhandled Trap */
    /*printf("Unhandled Trap : mcause = 0x%x, mepc = 0x%x\n", (unsigned int)cause,
           (unsigned int)epc);*/
    if (overrided_trap_handler) overrided_trap_handler(cause, epc, reg);
    while (1)
        ;
    return epc;
}

__attribute__((interrupt("machine"), aligned(4))) void trap_handler(unsigned long mcause, SAVED_CONTEXT *context)
{
    /* Do your trap handling */
    if ((mcause & MCAUSE_INT) && ((mcause & MCAUSE_CAUSE) == IRQ_M_EXT))
    {
        /* Machine-level interrupt from PLIC */
        PlicInterruptHandler();
    }
    else if ((mcause & MCAUSE_INT) && ((mcause & MCAUSE_CAUSE) == IRQ_M_TIMER))
    {
        /* Machine timer interrupt */
        MtimeInterruptHandler();
    }
    else if ((mcause & MCAUSE_INT) && ((mcause & MCAUSE_CAUSE) == IRQ_M_SOFT))
    {
        /* Machine SWI interrupt */
        mswi_handler();
    }
    else if (!(mcause & MCAUSE_INT) && ((mcause & MCAUSE_CAUSE) == TRAP_M_ECALL))
    {
        /* Machine Syscal call */
#ifdef __riscv_32e
        syscall_handler(context->x5, context->x10, context->x11, context->x12, context->x13);
#else
        syscall_handler(context->x17, context->x10, context->x11, context->x12, context->x13);
#endif
        context->mepc += 4;
    }
    else
    {
        /* Unhandled Trap */
        context->mepc = except_handler(mcause, context->mepc, context->caller_regs);
    }
}

void __attribute__((naked,weak)) default_irq_handler(void)
{
    __asm__ volatile(
        "nop"
    );
}