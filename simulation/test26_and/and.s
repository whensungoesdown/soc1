beq x0 x0 reset
beq x0 x0 trap

reset:
lui x5 0x12345
lui x6 0xfff00
and x5 x5 x6
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