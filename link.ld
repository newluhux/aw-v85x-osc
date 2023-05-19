OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY
{
	sram : org = 0x20000, len = 128K
}

SECTIONS
{
	.boot :
	{
		PROVIDE(__spl_start = .);
		boot.o (.text*)
		*(.text*)
		PROVIDE(__spl_end = .);
	}
	PROVIDE(__spl_size = __spl_end - __spl_start);
}
