beq x0 x0 reset
beq x0 x0 trap

reset:
addi x3 x0 0x8    # enable interrupt
nop               #csrrw x0 mstatus x3 (csrw mstatus rs)
addi x5 x0 0
addi x5 x5 1
addi x5 x5 2
addi x5 x5 3
addi x5 x5 4
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
      


