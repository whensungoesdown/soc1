`include "defines.v"

module cpu6_pipelinereg_d (
   input  clk,
   input  reset,
   input  [`CPU6_XLEN-1:0] pc,
   input  [`CPU6_XLEN-1:0] instr,
   output [`CPU6_XLEN-1:0] pcD,
   output [`CPU6_XLEN-1:0] instrD
   );

   // differenct from MIPS, RISC-V counts branch begin at pc, not pc+4
   // so we keep pc in the pipeline register
   
   cpu6_dffr#(`CPU6_XLEN) pc_r(pc, pcD, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) instr_r(instr, instrD, clk, reset);
   
endmodule // cpu6_pipelinereg_d

   
