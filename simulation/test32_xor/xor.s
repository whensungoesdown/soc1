beq x0 x0 reset
beq x0 x0 trap

reset:
addi x5 x0 -1
addi x6 x0 0x55
xor x5 x5 x6
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