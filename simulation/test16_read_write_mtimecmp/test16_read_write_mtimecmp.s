beq x0 x0 reset
beq x0 x0 trap
                           
reset:                           
lw x6 0x610(x0)
lw x5 0x61c(x0)
sw x5 0(x6)
lw x5 0x620(x0)
sw x5 4(x6)
lw x5 0x624(x0)
sw x5 8(x6)
nop
lw x6 0x614(x0)
lw x7 0x628(x0)
lw x5 0x0(x7)
lw x9 0x62c(x0)
add x5 x5 x9
sw x5 0(x6)
nop
nop
addi x5 x0 0x5
sw x5 0x0(x7)
lw x5 0x0(x7)
add x5 x5 x9
sw x5 4(x6)
nop
nop
nop
nop
nop

               

loop_in_reset:           
beq x0 x0 loop_in_reset




trap:                     
lw x6 0x614(x0)
addi x5 x0 4
sw x5 0(x6)
nop
nop
nop
                           
loop_in_trap:                          
beq x0 x0 loop_in_trap
