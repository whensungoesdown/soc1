## test12_exception_illinstr_mepc

When exception happens, the mepc is set with the faulting pc.

cpu6_excp is independent from pipelines, because it should control pipelines.

cpu6_csr is put at MEM stage. I tried to put cpu6_excp right next to cpu6_csr at MEM, but there are problems.

Pass exception signal all the way through pipelines makes it more difficult to understand.

Also, becasue decoding is at the frist stage, but rf read is at EX. and branch and jmps although handled at EX.

So the branch will take before the excep(MEM) set pc to mtvec.

To solve this, I should implement the missing ID stage, and handle branches and csrs all in it. 


-----------------------------------

Therefore, I guess excp module should be indenpend from all pipeline stages.

illegal instruction happens at IFID, instruction address misaligned happens at MEM.

------------------------------------

Another issue, the pcF works at clock falling edge, it needs to make address ready before the clock rising edge comes.
pcF updates too quick. When cpu6_excp gets pcF, it's already pointing to the next instruction.

One way is to make a copy of the previous pcF, like the following:

````````````
   wire excp_illinstr;
   wire excp_flush_pc_ena;
   wire [`CPU6_XLEN-1:0] excp_flush_pc;

   wire [`CPU6_XLEN-1:0] excp_mepc;
   wire excp_mepc_ena;

   wire [`CPU6_XLEN-1:0] excp_pc;

   cpu6_excp excp(
      .clk              (clk     ),
      .reset            (reset   ),
      .excp_pc          (excp_pc ),
      .excp_illinstr        (excp_illinstr    ),
      .excp_flush_pc_ena    (excp_flush_pc_ena),
      .excp_flush_pc        (excp_flush_pc    ),
      .excp_mepc            (excp_mepc        ),
      .excp_mepc_ena        (excp_mepc_ena    )
      );
       

   
   cpu6_hazardcontrol hazardcontrol(branchtype, jump, branchtypeE, jumpE, pcsrcE,
      hazard_stallF, flashE);


   assign stallF = hazard_stallF;// | excp_stallF;
   
   cpu6_dfflr#(`CPU6_XLEN) pcreg(!stallF, pcnextF, pcF, ~clk, reset);
   
   // It is a trick, pcF updated in the *falling edge* in order to be ahead of time,
   // so pcF is ready for the RAM when the rasing edge comes.
   // But other modules such as cpu6_excp still works on the rasing edge.
   // When excp sends the pcF to csr to write, the pcF is already updated in the previous
   // falling edge. So there have to be an extra pc to store the previous pcF value. 
   cpu6_dfflr#(`CPU6_XLEN) excp_pc_reg(!stallF, pcF, excp_pc, ~clk, reset);
   
   cpu6_adder pcadd4(pcF, 32'b100, pcplus4F); // next pc if no branch, no jump

````````````


Another way that I can think of is to make excp also works at the clock falling edge.
I tried. Turns out, even if I put pcF ready for cpu6_excp, but still the cpu6_csr module needs to wait for the upcomding raising edge.

Unless the cpu6_csr also works at falling edge, but this is too much. cpu6_csr is needed for csr instructions too.

-------------------------------

cpu6_excp sending in mepc doesn't go the same way as csr instructions do.

``````````````
module cpu6_csr (
   input  clk,
   input  reset,

   input  csr_rd_en,
   input  csr_wr_en,
   input  [`CPU6_CSR_SIZE-1:0] csr_idx,
   output [`CPU6_XLEN-1:0] csr_read_dat,
   input  [`CPU6_XLEN-1:0] csr_write_dat,

   input  [`CPU6_XLEN-1:0] excp_mepc,
   input  excp_mepc_ena
   );


   //
   // 0x341 MRW mepc  Machine exception program counter
   //
   wire sel_mepc = (csr_idx == 12'h341);
   wire rd_mepc = sel_mepc & csr_rd_en;
   //wire wr_mepc = sel_mepc & csr_wr_en;
   wire [`CPU6_XLEN-1:0] epc_r;
   //wire [`CPU6_XLEN-1:0] epc_nxt = {csr_write_dat[`CPU6_XLEN-1:1], 1'b0};

   // exception has high exception than csr instructions
   wire wr_mepc = excp_mepc_ena | (sel_mepc & csr_wr_en);
   wire [`CPU6_XLEN-1:0] epc_nxt = excp_mepc_ena ? excp_mepc : {csr_write_dat[`CPU6_XLEN-1:1], 1'b0};

   cpu6_2x_dfflr #(`CPU6_XLEN) epc_dfflr(wr_mepc, epc_nxt, epc_r, clk, reset);
   
   wire [`CPU6_XLEN-1:0] csr_mepc;
   assign csr_mepc = epc_r;

   

   assign csr_read_dat = `CPU6_XLEN'b0
			 | ({`CPU6_XLEN{rd_mepc}} & csr_mepc)
			    //| ({`CPU6_XLEN{rd_mtvec}} & csr_mtvec)
			    ; 

endmodule // cpu6_csr 

``````````````
It has excp_mepc and excp_mepc_ena. 

excp_mepc has higher priority than csr instructions.

If when encounter an exception at IFID while the MEM is handling a csrrw instruction, the mepc that cpu6_excp sends in takes over.

Suppose csrrw writes value_a to mepc, the next instruction is csrr, which reads mepc. The next instruction triggers exception. 
Then this csrr gets the **wrong** value. It should get value_a instead of getting the fauling pc.

-----------------------

`````````````````````````
CONTENT BEGIN


        0:              00000463;  --           beq x0 x0 8 <reset>
        1:              02000263;  --           beq x0 x0 36 <trap>

-- <reset>:
        2:              00100093;  --           addi x1 x0 1
        3:              00200113;  --           addi x2 x0 2
        4:              00300193;  --           addi x3 x0 3
        5:              00118213;  --           addi x4 x3 1
        6:              00120293;  --           addi x5 x4 1
        7:              00000000;  --           <------------- illegal instruction
        8:              00128313;  --           addi x6 x5 1

-- <loop_in_reset>:
        9:              00000063;  --           beq x0 x0 0 <loop_in_reset>

-- <trap>:
        a:              00a00313;  --           addi x6 x0 10
        b:              341021f3;  --           csrrs x3 mepc x0 (csrr rd mepc)
        c:              00000013;  --           nop
        d:              00000013;  --           nop
        e:              00000013;  --           nop
        f:              00000013;  --           nop <---- test mepc == 0x1c, x3 == 0x1c, x6 == 0xa

-- <loop_in_trap>:
        10:             00000063;  --           beq x0 x0 0 <loop_in_trap>



        [11..7FF]  :   00000013; -- nop
END;

`````````````````````````
