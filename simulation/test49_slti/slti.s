beq x0 x0 reset
beq x0 x0 trap

reset:
addi x6, x0, 0
slti x5, x6, 1  
addi x6, x0, -5
slti x5, x6, 1
addi x6, x0, 5
slti x5, x6, 1 
addi x6, x0, -1
slti x5, x6, -2
addi x6, x0, -3
slti x5, x6, -2
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