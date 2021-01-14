## Interrupt

Currently, soc1 only has two interrupts; they are the timer (tmr_irq_r) and external (ext_irq_r) interrupts. There is no general interrupt controller yet, and the only external interrupt is the one from UART when receiving a new byte.

The corresponding CSR registers implemented are the following:
- **mip.MTIP** (machine timer interrupt pending)
- **mie.MTIE** (machine timer interrupt enable)
- **mstatus.MIE** (machine interrupt enable)

mstatus.MIE is the global interrupt enable bit. When either the timer or external interrupt triggers the interrupt handler, the bit is set to 0, disabled. It is primarily used to guarantee atomicity for interrupt handlers.

"An interrupt *i* will be taken if bit *i* is set in both **mip** and **mie**, and if interrupts are globally enabled."

Timer pending will be cleared when **mtime** is less than **mtimecmp**. Otherwise, the timer interrupt will repeatedly kick in.

There is no interrupt priority yet. If the timer burst when the interrupt handler is processing an external interrupt, it keeps pending and gets processed after the external interrupt.
