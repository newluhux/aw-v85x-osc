#ifndef _IO_H_

static inline __attribute__((__always_inline__))
uint32_t read32(uint32_t addr)
{
	return (*((volatile uint32_t *)(addr)));
}

static inline __attribute__((__always_inline__))
void write32(uint32_t addr, uint32_t value)
{
	*((volatile uint32_t *)(addr)) = value;
}

#endif
