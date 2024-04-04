
#include "core_v5.h"

	.globl riscv_vector_table
	.globl m_trap_entry_baremetal

	.section .text, "ax"
	.p2align 7
	/* vectore table for Vectored PLIC */
riscv_vector_table:
	.word	m_trap_entry_baremetal // 0
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 5
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 10
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 15
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 20
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 25
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 30
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 35
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 40
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 45
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 50
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.word	default_irq_handler // 55
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler
	.word	default_irq_handler

	.section .text
	.align 6

m_trap_entry_baremetal:
	addi sp, sp, -32*REGBYTES

	/* Save caller registers */
	STORE x1, 0*REGBYTES(sp)
	STORE x4, 1*REGBYTES(sp)
	STORE x5, 2*REGBYTES(sp)
	STORE x6, 3*REGBYTES(sp)
	STORE x7, 4*REGBYTES(sp)
	STORE x10, 5*REGBYTES(sp)
	STORE x11, 6*REGBYTES(sp)
	STORE x12, 7*REGBYTES(sp)
	STORE x13, 8*REGBYTES(sp)
	STORE x14, 9*REGBYTES(sp)
	STORE x15, 10*REGBYTES(sp)
#ifndef __riscv_32e
	STORE x16, 11*REGBYTES(sp)
	STORE x17, 12*REGBYTES(sp)
	STORE x28, 13*REGBYTES(sp)
	STORE x29, 14*REGBYTES(sp)
	STORE x30, 15*REGBYTES(sp)
	STORE x31, 16*REGBYTES(sp)
#endif

	/* Save mstatus and mepc */
	csrr t0, mepc
	csrr t1, mstatus
	csrr t2, mxstatus

	STORE t0, 17*REGBYTES(sp)
	STORE t1, 18*REGBYTES(sp)
	STORE t2, 19*REGBYTES(sp)

	/* Call trap handler */
	csrr a0, mcause
	mv   a1, sp
	call trap_handler

	/* Disable interrupt */
	csrrci a5, mstatus, MSTATUS_MIE

	/* Restore mstatus and mepc */
	LOAD t0, 17*REGBYTES(sp)
	LOAD t1, 18*REGBYTES(sp)
	LOAD t2, 19*REGBYTES(sp)

	csrw mepc, t0
	csrw mstatus, t1
	csrw mxstatus, t2

	/* Restore caller registers */
	LOAD x1, 0*REGBYTES(sp)
	LOAD x4, 1*REGBYTES(sp)
	LOAD x5, 2*REGBYTES(sp)
	LOAD x6, 3*REGBYTES(sp)
	LOAD x7, 4*REGBYTES(sp)
	LOAD x10, 5*REGBYTES(sp)
	LOAD x11, 6*REGBYTES(sp)
	LOAD x12, 7*REGBYTES(sp)
	LOAD x13, 8*REGBYTES(sp)
	LOAD x14, 9*REGBYTES(sp)
	LOAD x15, 10*REGBYTES(sp)
#ifndef __riscv_32e
	LOAD x16, 11*REGBYTES(sp)
	LOAD x17, 12*REGBYTES(sp)
	LOAD x28, 13*REGBYTES(sp)
	LOAD x29, 14*REGBYTES(sp)
	LOAD x30, 15*REGBYTES(sp)
	LOAD x31, 16*REGBYTES(sp)
#endif

	addi sp, sp, 32*REGBYTES
	mret
