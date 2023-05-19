/*
 * start.s
 * 
 * Copyright(c) 2023 Lu Hui <luhux76@gmail.com>
 *
 * some code from mainline uboot:
 *
 * armboot - Startup Code for OMAP3530/ARM Cortex CPU-core
 *
 * Copyright (c) 2004	Texas Instruments <r-woodruff2@ti.com>
 *
 * Copyright (c) 2001	Marius Gröger <mag@sysgo.de>
 * Copyright (c) 2002	Alex Züpke <azu@sysgo.de>
 * Copyright (c) 2002	Gary Jennejohn <garyj@denx.de>
 * Copyright (c) 2003	Richard Woodruff <r-woodruff2@ti.com>
 * Copyright (c) 2003	Kshitij <kshitij@ti.com>
 * Copyright (c) 2006-2008 Syed Mohammed Khasim <x0khasim@ti.com>
 *
 * some code from https://github.com/xboot/xboot/blob/master/src/arch/arm32/mach-v831/start.S
 * Copyright(c) 2007-2022 Jianjun Jiang <8192542@qq.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

_start:
	b reset
	.byte 'e', 'G', 'O', 'N', '.', 'B', 'T', '0'
	.long 0, __spl_size
	.byte 'S', 'P', 'L', 2
	.long 0, 0
	.long 0, 0, 0, 0, 0, 0, 0, 0	/* 0x20 - dram size, 0x28 - boot type */
	.long 0, 0, 0, 0, 0, 0, 0, 0	/* 0x40 - boot params */

reset:
	/*
	* disable interrupts (FIQ and IRQ), also set the cpu to SVC32 mode,
	* except if in HYP mode already
	*/
	mrs	r0, cpsr
	and	r1, r0, #0x1f		@ mask mode bits
	teq	r1, #0x1a		@ test for HYP mode
	bicne	r0, r0, #0x1f		@ clear all mode bits
	orrne	r0, r0, #0x13		@ set SVC mode
	orr	r0, r0, #0xc0		@ disable FIQ and IRQ
	msr	cpsr,r0

	/*
	* disable MMU stuff and caches
	*/
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #0x00002000	@ clear bits 13 (--V-)
	bic	r0, r0, #0x00000007	@ clear bits 2:0 (-CAM)
	orr	r0, r0, #0x00000002	@ set bit 1 (--A-) Align
	orr	r0, r0, #0x00000800	@ set bit 11 (Z---) BTB
	bic	r0, r0, #0x00001000	@ clear bit 12 (I) I-cache
	mcr	p15, 0, r0, c1, c0, 0

	/* setup sp: SRAM end */
	ldr sp, =0x41000

	/* init uart */
	bl sys_uart_init

loop:
	mov r0, #'v'
	bl sys_uart_putc
	mov r0, #'8'
	bl sys_uart_putc
	mov r0, #'5'
	bl sys_uart_putc
	mov r0, #'x'
	bl sys_uart_putc
	mov r0, #'\n'
	bl sys_uart_putc
	mov r0, #'\r'
	bl sys_uart_putc
	b loop
