#ifndef _INTERRUPT_H_
#define _INTERRUPT_H_

/*
 * Inline nested interrupt entry/exit macros
 */
/* Save/Restore macro */

#define SAVE_CSR(r) \
    long __##r;     \
    riscv_csr_read(r, __##r);
#define RESTORE_CSR(r) riscv_csr_write(r, __##r);

#if SUPPORT_PFT_ARCH
#define SAVE_MXSTATUS() SAVE_CSR(mxstatus)
#define RESTORE_MXSTATUS() RESTORE_CSR(mxstatus)
#else
#define SAVE_MXSTATUS()
#define RESTORE_MXSTATUS()
#endif

#if 0  // def __riscv_flen
#define SAVE_FCSR() int __fcsr = read_fcsr();
#define RESTORE_FCSR() write_fcsr(__fcsr);
#else
#define SAVE_FCSR()
#define RESTORE_FCSR()
#endif

#ifdef __riscv_dsp
#define SAVE_UCODE() SAVE_CSR(NDS_UCODE)
#define RESTORE_UCODE() RESTORE_CSR(NDS_UCODE)
#else
#define SAVE_UCODE()
#define RESTORE_UCODE()
#endif

/* Nested IRQ entry macro : Save CSRs and enable global interrupt. */
#define NESTED_IRQ_ENTER() \
    SAVE_CSR(mepc)         \
    SAVE_CSR(mstatus)      \
    SAVE_MXSTATUS()        \
    SAVE_FCSR()            \
    SAVE_UCODE()           \
    riscv_csr_write(mstatus, MSTATUS_MIE);

/* Nested IRQ exit macro : Restore CSRs */
#define NESTED_IRQ_EXIT()                     \
    riscv_csr_clr_bits(mstatus, MSTATUS_MIE); \
    RESTORE_CSR(mstatus)                      \
    RESTORE_CSR(mepc)                         \
    RESTORE_MXSTATUS()                        \
    RESTORE_FCSR()                            \
    RESTORE_UCODE()

#define NESTED_VPLIC_COMPLETE_INTERRUPT(irq) \
    do                                       \
    {                                        \
        csr_clr_bits_mie(MIP_MEIP);          \
        __nds__plic_complete_interrupt(irq); \
        __asm volatile("fence io, io");      \
        csr_set_bits_mie(MIP_MEIP);          \
    } while (0)

#ifdef __cplusplus
extern "C"
{
#endif

    void RegistTrapHandler(void (*fp)(long cause, long epc, long *reg));

#ifdef __cplusplus
}
#endif

#endif
