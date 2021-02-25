beq x0 x0 reset
beq x0 x0 trap

reset:
jal x1 label0

label0:
jal x1 label1
nop
nop
label1:
jal x1 label2
label2:
addi x6, x0 5
addi x5, x0, 0
label3:
addi x5, x5, 1
beq x5, x6, exit
jal x1 label3
exit:
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