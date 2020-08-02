`include "defines.v"

module cpu6_pipelinereg_exmem (
   input  clk,
   input  reset,
   input  flashM,
   input  memwriteE,
   input  [`CPU6_XLEN-1:0] writedataE,
   input  [`CPU6_XLEN-1:0] aluoutE, // used in MEM, but also pass to WB
   input  [`CPU6_RFIDX_WIDTH-1:0] writeregE, // not used in MEM, pass to WB
   input  regwriteE, // not used in MEM, pass to WB
   input  memtoregE, // not used in MEM, pass to WB
   input  [`CPU6_XLEN-1:0] pcplus4E,  // used in MEM, jump need pc+4 in the very last, write to rd
   input  jumpE,     // used in MEM
   output  memwriteM,
   output [`CPU6_XLEN-1:0] writedataM,
   output [`CPU6_XLEN-1:0] aluoutM,
   output [`CPU6_RFIDX_WIDTH-1:0] writeregM,
   output regwriteM,
   output memtoregM,
   output [`CPU6_XLEN-1:0] pcplus4M,
   output jumpM
);

   cpu6_dffr#(1) memwrite_r({1{~flashM}} & memwriteE, memwriteM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) writedata_r({`CPU6_XLEN{~flashM}} & writedataE, writedataM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) aluout_r({`CPU6_XLEN{~flashM}} & aluoutE, aluoutM, clk, reset);
   cpu6_dffr#(`CPU6_RFIDX_WIDTH) writereg_r({`CPU6_RFIDX_WIDTH{~flashM}} & writeregE, writeregM, clk, reset);
   cpu6_dffr#(1) regwrite_r({1{~flashM}} & regwriteE, regwriteM, clk, reset);
   cpu6_dffr#(1) memtoreg_r({1{~flashM}} & memtoregE, memtoregM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) pcplus4_r({`CPU6_XLEN{~flashM}} & pcplus4E, pcplus4M, clk, reset);
   cpu6_dffr#(1) jump_r({1{~flashM}} & jumpE, jumpM, clk, reset);
   
endmodule // cpu6_pipelinereg_exmem
