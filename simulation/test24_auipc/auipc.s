beq x0 x0 reset
beq x0 x0 trap

reset:
auipc x5 0x12345
addi x3 x5 5
nop
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