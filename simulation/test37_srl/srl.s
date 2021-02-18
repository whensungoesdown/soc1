beq x0 x0 reset
beq x0 x0 trap

reset:
addi x5 x0 0x2f0
addi x6 x0 0x4
srl x5 x5 x6
srl x7 x5 x6

lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
srl x7 x5 x6

addi x6 x0 0x1
lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
srl x7 x5 x6

addi x6 x0 32
lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
srl x7 x5 x6

addi x6 x0 0x5
lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
srl x7 x5 x6

addi x6 x0 16
lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
srl x7 x5 x6

addi x6 x0 31
lui x5 0xfff0f
addi x5 x5 0x2f0
srl x5 x5 x6
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