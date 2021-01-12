beq x0 x0 reset
beq x0 x0 trap

reset:
addi x3 x0 0x8    # enable interrupt
nop               # csrrw x0 mstatus x3 (csrw mstatus rs)
lw x7 1584(x0)    # set mtimecmp to 255
addi x5 x0 255
sw x5 0(x7)
addi x3 x0 255    # enable timer
nop               # 30419073;  --           csrrw x0 x3 (csrw mie rs)
nop               # 304021f3;  --           csrrs x3 x0 (csrr rd mie)
addi x5 x0 0
addi x5 x5 1
addi x5 x5 2
addi x5 x5 3
addi x5 x5 4
nop
nop
nop
addi x3 x0 0x0

loop_in_rest:
beq x0 x0 loop_in_rest

trap:
nop               # 344021f3;  --           csrrs x3 mip x0 (csrr rd mip)
lw x7 1576(x0)    # set mtime to 0
sw x0 0(x7)
nop               # 344021f3;  --           csrrs x3 mip x0 (csrr rd mip)
nop
nop
nop
nop            # mret 30200073