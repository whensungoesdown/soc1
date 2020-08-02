`include "defines.v"

module cpu6_pipelinereg_idex (
   input  clk,
   input  reset,
   input  flash,

   input  memwrite,
 
   input  memtoreg,
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  alusrc,
   input  regwrite,
   input  jump,
   input  [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol,
   input  [`CPU6_IMMTYPE_SIZE-1:0] immtype,
   input  [`CPU6_XLEN-1:0] pc,
   input  [`CPU6_XLEN-1:0] instr,

   output memwriteE,
   
   output memtoregE,
   output [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
   output alusrcE,
   output regwriteE,
   output jumpE,
   output [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE,
   output [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
   output [`CPU6_XLEN-1:0] pcE,
   output [`CPU6_XLEN-1:0] instrE
   );

   cpu6_dffr#(1) memwrite_r({1{~flash}} & memwrite, memwriteE, clk, reset);
   
   cpu6_dffr#(1) memtoreg_r({1{~flash}} & memtoreg, memtoregE, clk, reset);
   cpu6_dffr#(`CPU6_BRANCHTYPE_SIZE) branchtype_r({`CPU6_BRANCHTYPE_SIZE{~flash}} & branchtype, branchtypeE, clk, reset);
   cpu6_dffr#(1) alusrc_r({1{~flash}} & alusrc, alusrcE, clk, reset);
   cpu6_dffr#(1) regwrite_r({1{~flash}} & regwrite, regwriteE, clk, reset);
   cpu6_dffr#(1) jump_r({1{~flash}} & jump, jumpE, clk, reset);
   cpu6_dffr#(`CPU6_ALU_CONTROL_SIZE) alucontrol_r({`CPU6_ALU_CONTROL_SIZE{~flash}} & alucontrol, alucontrolE, clk, reset);
   cpu6_dffr#(`CPU6_IMMTYPE_SIZE) immtype_r({`CPU6_IMMTYPE_SIZE{~flash}} & immtype, immtypeE, clk, reset);

   cpu6_dffr#(`CPU6_XLEN) pc_r({`CPU6_XLEN{~flash}} & pc, pcE, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) instr_r({`CPU6_XLEN{~flash}} & instr, instrE, clk, reset);
   
endmodule // cpu6_pipelinereg_idex
