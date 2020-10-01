## test8_csrrc

Nothing special, just like test7_csrrs.

One thing that test7 missed. mepc's last bit must be 0.

csrrs and csrrc provide rs1 as bit mask.

```````````````
CONTENT BEGIN

        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              01000093;  --           addi x1 x0 16
        3:              3410b173;  --           csrrc x2 mepc x1
        4:              00000013;  --           nop
        5:              00000013;  --           nop
        6:              00000013;  --           nop ; x2 should be 0, mepc should be 0xffffffee (mepc last bit must be 0)
        7:              00000013;  --           nop
        8:              341031f3;  --           csrrc x3 mepc x0
        9:              00000013;  --           nop
        a:              00000013;  --           nop
        b:              00000013;  --           nop
        c:              00000013;  --           nop ; x3 should be 0xffffffee, mepc should be 0xffffffee
        d:              00000013;  --           nop
        e:              00000013;  --           nop

-- <loop>:
        f:              00000063;  --           beq x0 x0 0 <loop>



        [10..7FF]  :   00000013; -- nop
END;
```````````````
