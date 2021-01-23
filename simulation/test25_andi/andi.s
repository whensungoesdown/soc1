beq x0 x0 reset
beq x0 x0 trap

reset:
addi x5 x0 0x7ff
andi x5 x5 0x7f0
andi x6 x5 0xf0
andi x6 x6 0x0
nop
nop
nop

loop_in_rest:
beq x0 x0 loop_in_rest

trap:
nop
nop
nop
nop
nop            # mret 30200073