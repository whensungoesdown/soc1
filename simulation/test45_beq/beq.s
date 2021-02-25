beq x0 x0 reset
beq x0 x0 trap

reset:
nop
nop                # test: a jal right followed beq, but the beq is not the reset vector
nop
beq x0 x0 label0
label0:
beq x0 x0 label1
addi x5, x0, 0
nop
addi x6, x0 6
label1:
addi x5, x5, 5
nop
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