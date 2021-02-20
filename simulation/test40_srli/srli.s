beq x0 x0 reset
beq x0 x0 trap

reset:
addi x5 x0 0x2f0
addi x6 x0 0x4
srli x5 x5 0x4
srli x7 x5 0x4

lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 0x4
srli x7 x5 0x4

addi x6 x0 0x1
lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 0x1
srli x7 x5 0x1

addi x6 x0 32
lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 32
srli x7 x5 32


addi x6 x0 0x5
lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 5
srli x7 x5 5

addi x6 x0 16
lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 16
srli x7 x5 16

addi x6 x0 31
lui x5 0xfff0f
addi x5 x5 0x2f0
srli x5 x5 31
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