beq x0 x0 reset
beq x0 x0 trap

reset:
addi x6, x0, 0
addi x7, x0, 1
slt x5, x6, x7 
addi x6, x0, -5
slt x5, x6, x7
addi x6, x0, 5
slt x5, x6, x7
addi x6, x0, -1
addi x7, x0, -2
slt x5, x6, x7
addi x6, x0, -3
slt x5, x6, x7
nop
nop
nop

loop_in_reset:
beq x0 x0 loop_in_reset

trap:
nop
nop
nop
nop
nop            # mret 30200073