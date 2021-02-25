beq x0 x0 reset
beq x0 x0 trap

reset:
nop
nop        
nop
jal x1 label0
nop
nop
addi x6, x0, 6
label0:
addi x5, x0 5
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