/*
 * Copyright (c) 2017 Andes Technology Corporation
 * All rights reserved.
 *
 * This file defines the reset/nmi/trap handlers, the reset initialization code
 * and the trap entry table for Vectored-PLIC.
 *
 * Please note that the code in this file is to facilitate AndesCore processor
 * verification and it is NOT a goal for this code to be used in production.
 * For sample production version of start.S, please find it in Andes Startup
 * demos.
 */

#include "core_v5.h"

	//.section .init
	//.extern vector_table
	.globl _start
	.type _start,@function

	.section .text.startup, "ax"
_start:

#ifdef __riscv_flen
 	/* Initialize floating point register */
	#tzhu: this mustn't be comment, otherwise fld/fsd will cause exception.
 	csrr	x15, misa
 	srli	x15, x15, 5
 	andi	x15, x15, 1
 	beqz	x15, 1f
	csrw	mstatus, x15

	/* Set mstatus.FS */
	li	x14, 0x1 << 13
	csrs	mstatus, x14

	/* Set mstatus.VS */
	li	x14, 0x1 << 9
	csrs	mstatus, x14
#endif

	
	/* Initialize global pointer */
	.option push
	.option norelax
	la gp, __global_pointer$
	.option pop

	/* Initialize stack pointer */
	la t0, _stack
	mv sp, t0

#ifdef __nds_execit
	/* Check HW for CoDense */
	csrr	a0, mmsc_cfg
	li	a1, (1 << 3)
	and	a2, a0, a1
	beqz	a2, 1f
	/* Initialize the table base of CoDense instruction */
	la	a0, _ITB_BASE_
	csrw	uitb, a0
1:
#endif

#ifdef __riscv_flen
	/* Enable FPU */
	li t0, MSTATUS_FS
	csrrs t0, mstatus, t0

	/* Initialize FCSR */
	fscsr zero
#endif

_init_mtvec:
	/* Initial machine trap-vector Base */
	// la t0, m_trap_entry
	csrr t1, mmsc_cfg
	srli t1, t1, 0xc
	andi t1, t1, 0x1
	beqz t1, _mtvec_set
	/* Enable Vectored PLIC */
	csrr t1, 0x7d0
	ori  t1, t1, 0x2
	csrw 0x7d0, t1
	la t0, riscv_vector_table
_mtvec_set:
	csrw mtvec, t0
1:
	/* System reset handler */
	call reset_handler

	/* Infinite loop, if returned accidently */
1:	j 1b

	.weak __platform_init
__platform_init:
	ret

	.p2align 3
__global_pointer_addr:
	.dword	__global_pointer$

	.weak nmi_handler
nmi_handler:
1:	j 1b
