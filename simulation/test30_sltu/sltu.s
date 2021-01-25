beq x0 x0 reset
beq x0 x0 trap

reset:
addi x6, x0, 0
addi x7, x0, 1
sltu x5, x6, x7 
addi x6, x0, -5
sltu x5, x6, x7
addi x6, x0, 5
sltu x5, x6, x7
addi x6, x0, -1
addi x7, x0, -2
sltu x5, x6, x7
addi x6, x0, -3
sltu x5, x6, x7
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