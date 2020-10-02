## test9_csrrwi test10_csrrsi  test11_csrrci

Very similiar tests.

**test9_csrrwi**
``````````````````````
CONTENT BEGIN

        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              02300193;  --           addi x3 x0 35
        3:              3411d173;  --           csrrwi x2 mepc x3
        4:              00000013;  --           nop
        5:              00000013;  --           nop
        6:              00000013;  --           nop
        7:              00000013;  --           nop ; test x2 == 0, mepc == 0x2
        8:              341fd173;  --           csrrwi x2 mepc x31
        9:              00000013;  --           nop
        a:              00000013;  --           nop
        b:              00000013;  --           nop
        c:              00000013;  --           nop ; test x2 == 0x2, mecp == 0x1e
        d:              00000013;  --           nop
        e:              00000013;  --           nop

-- <loop>:
        f:              00000063;  --           beq x0 x0 0 <loop>



        [10..7FF]  :   00000013; -- nop
END;
``````````````````````


**test10_csrrsi**
``````````````````````
CONTENT BEGIN

        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              01000293;  --           addi x5 x0 16
        3:              3412e173;  --           csrrsi x2 mepc x5
        4:              00000013;  --           nop
        5:              00000013;  --           nop
        6:              00000013;  --           nop
        7:              00000013;  --           nop ; x2 should be 0, mepc should be 0x4
        8:              341061f3;  --           csrrsi x3 mepc x0
        9:              00000013;  --           nop
        a:              00000013;  --           nop
        b:              00000013;  --           nop
        c:              00000013;  --           nop ; x3 should be 0x4, mepc should be 0x4 (csrrsi don't write csr when x0 is 0.)
        d:              00000013;  --           nop
        e:              00000013;  --           nop

-- <loop>:
        f:              00000063;  --           beq x0 x0 0 <loop>



        [10..7FF]  :   00000013; -- nop
END;
``````````````````````


**test11_csrrci**
```````````````
CONTENT BEGIN

        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              01000293;  --           addi x5 x0 16
        3:              3412f173;  --           csrrci x2 mepc x5
        4:              00000013;  --           nop
        5:              00000013;  --           nop
        6:              00000013;  --           nop
        7:              00000013;  --           nop ; x2 should be 0, mepc should be 0xfffffffa (mepc last bit must be 0)
        8:              341071f3;  --           csrrci x3 mepc x0
        9:              00000013;  --           nop
        a:              00000013;  --           nop
        b:              00000013;  --           nop
        c:              00000013;  --           nop ; x3 should be 0xfffffffa, mepc should be 0xfffffffa
        d:              00000013;  --           nop
        e:              00000013;  --           nop

-- <loop>:
        f:              00000063;  --           beq x0 x0 0 <loop>



        [10..7FF]  :   00000013; -- nop
END;
````````````````
