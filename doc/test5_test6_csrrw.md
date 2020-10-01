## Add csr registers, cpu6_csr module

For now, only implemted mepc, 0x341.

Another csr register mtvec is hardwired in cpu6_excp.v.

Later cpu6_excp and cpu6_csr should merge into one module, something like CLINT or CLIC.

```````````````````````
module cpu6_csr (
   input  clk,
   input  reset,

   input  csr_rd_en,
   input  csr_wr_en,
   input  [`CPU6_CSR_SIZE-1:0] csr_idx,
   output [`CPU6_XLEN-1:0] csr_read_dat,
   input  [`CPU6_XLEN-1:0] csr_write_dat
   );
```````````````````````

### test5_csrrw
````````````````````
CONTENT BEGIN

        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              01000093;  --           addi x1 x0 16
        3:              34109173;  --           csrrw x2 mepc x1
        4:              00000013;  --           nop
        5:              00000013;  --           nop
        6:              00000013;  --           nop
        7:              00000013;  --           nop ; x2 == 0
        8:              34109173;  --           csrrw x2 mepc x1
        9:              00000013;  --           nop
        a:              00000013;  --           nop
        b:              00000013;  --           nop
        c:              00000013;  --           nop ; x2 = 0x10
        d:              00000013;  --           nop
        e:              00000013;  --           nop

-- <loop>:
        f:              00000063;  --           beq x0 x0 0 <loop>



        [10..7FF]  :   00000013; -- nop
END;
``````````````````````````````
There is a data hazard between "addi x1 x0 16" and "csrrw x2 mepc x1", x1 value needs forwarding to csrrw.
Since module cpu6_csr is put at MEM stage of the pipelines, so for "csrrw x2 mepc x1", the csr data read and write
happens at MEM (pc+2), and the result can be observed at pc+3.


### test5_2x_csrrw
Similiar test case, just two csrrw instructions right next to each other.
`````````````````
CONTENT BEGIN


        0:              00000013;  --           nop
        1:              00000013;  --           nop
        2:              01000093;  --           addi x1 x0 16
        3:              001081b3;  --           add x3 x1 x1
        4:              34119173;  --           csrrw x2 mepc x3
        5:              34109173;  --           csrrw x2 mepc x1
        6:              00000013;  --           nop
        7:              00000013;  --           nop  <---- showing mepc as 0x20 here, showing x3 as 0x20 here
        8:              00000013;  --           nop  <---- showing mepc as 0x10 here, showing x2 as 0x20 (updated in previous one cycle)
        9:              00000013;  --           nop

-- 00000028 <loop>:
        a:              00000063;  --           beq x0 x0 0 <loop>



        [b..7FF]  :   00000013; -- nop
`````````````````
