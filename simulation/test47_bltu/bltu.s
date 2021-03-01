beq x0 x0 reset
beq x0 x0 trap

reset:
addi x6, x0, 0
addi x7, x0, 0
bltu x6, x7, error

lui x6, 0xfff
lui x7, 0xfff
addi x6, x6, 1
bltu x6, x7, error

addi x6, x0, 0
addi x7, x0, 1
bltu x6, x7 exit

error:
addi x8 x0, 8
exit:
addi x5, x0, 5 
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