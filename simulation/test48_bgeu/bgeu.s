beq x0 x0 reset
beq x0 x0 trap

reset:
addi x8, x0, 0
addi x6, x0, 1
addi x7, x0, 0
bgeu x6 x7 target0
addi x8, x0, 1

target0:
addi x6, x0, 0
addi x7, x0, 0
bgeu x6 x7 target1
addi x8, x0, 2

target1:
lui x6, 0xfff
lui x7, 0xfff
addi x6, x6, 1
bgeu x6 x7 target2
addi x8, x0, 3

target2:
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