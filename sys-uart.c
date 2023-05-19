/*
 * sys-uart.c
 * some code from xboot: https://github.com/xboot/xboot/blob/master/src/arch/arm32/mach-v831/sys-uart.c
 *
 * Copyright(c) 2007-2023 Jianjun Jiang <8192542@qq.com>
 * Official site: http://xboot.org
 * Mobile phone: +86-18665388956
 * QQ: 8192542
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

#include <stdint.h>
#include <io.h>

#define UART0_BASE   0x02500000
#define CCMU_BASE    0x02001000
#define UART_BGR_REG 0x090C
#define GPIO_BASE    0x02000000
#define PH_CFG1      0x0154

void sys_uart_init(void)
{
	uint32_t val;

	/* open clock gate for uart0 */
	val = read32(CCMU_BASE + UART_BGR_REG);
	val |= (1 << 0);
	write32(CCMU_BASE + UART_BGR_REG, val);

	/* deassert uart0 reset */
	val = read32(CCMU_BASE + UART_BGR_REG);
	val |= (1 << 16);
	write32(CCMU_BASE + UART_BGR_REG, val);

	/* configure gpio function to uart0 */
	val = read32(GPIO_BASE + PH_CFG1);
	val &= ~(0xFF);
	val |= 0b01010101;
	write32(GPIO_BASE + PH_CFG1, val);

	/* Config uart0 to 115200-8-1-0 */
	uint32_t addr = UART0_BASE;
	write32(addr + 0x04, 0x0);
	write32(addr + 0x08, 0xf7);
	write32(addr + 0x10, 0x0);
	val = read32(addr + 0x0c);
	val |= (1 << 7);
	write32(addr + 0x0c, val);
	write32(addr + 0x00, 0xd & 0xff);
	write32(addr + 0x04, (0xd >> 8) & 0xff);
	val = read32(addr + 0x0c);
	val &= ~(1 << 7);
	write32(addr + 0x0c, val);
	val = read32(addr + 0x0c);
	val &= ~0x1f;
	val |= (0x3 << 0) | (0 << 2) | (0x0 << 3);
	write32(addr + 0x0c, val);
}

void sys_uart_putc(char c)
{
	uint32_t addr = UART0_BASE;

	while ((read32(addr + 0x7c) & (0x1 << 1)) == 0) ;
	write32(addr + 0x00, c);
}
