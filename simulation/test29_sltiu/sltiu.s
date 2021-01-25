beq x0 x0 reset
beq x0 x0 trap

reset:
addi x6, x0, 0
sltiu x5, x6, 1   #SEQZ rd, rs
addi x6, x0, -5
sltiu x5, x6, 1   #SEQZ rd, rs
addi x6, x0, 5
sltiu x5, x6, 1   #SEQZ rd, rs
addi x6, x0, -1
sltiu x5, x6, -2
addi x6, x0, -3
sltiu x5, x6, -2
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