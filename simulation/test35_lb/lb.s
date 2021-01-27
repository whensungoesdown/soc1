beq x0 x0 reset
beq x0 x0 trap

reset:
lw x5 0x600(x0)
lb x5 0x600(x0)
lw x5 0x604(x0)
lb x5 0x604(x0)
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