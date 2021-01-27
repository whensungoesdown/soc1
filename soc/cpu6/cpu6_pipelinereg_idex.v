`include "defines.v"

module cpu6_pipelinereg_idex (
   input  clk,
   input  reset,
   input  flash,

   input  [`CPU6_LSWIDTH_SIZE-1:0] lswidth,
   input  loadsignext,

   input  lui,
   input  auipc,
   input  [`CPU6_XLEN-1:0] pc_auipc,
   // csr
   input  csr,
   input  csr_rs1uimm,
   input  [`CPU6_CSR_WSC_SIZE-1:0] csr_wsc,
   //
   input  memwrite,
 
   input  memtoreg,
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  alusrc,
   input  regwrite,
   input  jump,
   input  [`CPU6_ALUCONTROL_SIZE-1:0] alucontrol,
   input  [`CPU6_IMMTYPE_SIZE-1:0] immtype,
   input  [`CPU6_XLEN-1:0] pc,
   input  [`CPU6_XLEN-1:0] instrF,
   input  empty_pipeline_req,


   output [`CPU6_LSWIDTH_SIZE-1:0] lswidthE,
   output loadsignextE,
   output luiE,
   output auipcE,
   output [`CPU6_XLEN-1:0] pc_auipcE,
   // csr
   output csrE,
   output csr_rs1uimmE,
   output [`CPU6_CSR_WSC_SIZE-1:0] csr_wscE,
   //
   output memwriteE,
   
   output memtoregE,
   output [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
   output alusrcE,
   output regwriteE,
   output jumpE,
   output [`CPU6_ALUCONTROL_SIZE-1:0] alucontrolE,
   output [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
   output [`CPU6_XLEN-1:0] pcE,
   output [`CPU6_XLEN-1:0] instrE,
   output empty_pipeline_reqE
   );

   cpu6_dffr#(`CPU6_LSWIDTH_SIZE) lswidth_r({`CPU6_LSWIDTH_SIZE{~flash}} & lswidth, lswidthE, clk, reset);
   cpu6_dffr#(1) loadsignext_r({1{~flash}} & loadsignext, loadsignextE, clk, reset);
   
   cpu6_dffr#(1) lui_r({1{~flash}} & lui, luiE, clk, reset);
   cpu6_dffr#(1) auipc_r({1{~flash}} & auipc, auipcE, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) pc_auipc_r({`CPU6_XLEN{~flash}} & pc_auipc, pc_auipcE, clk, reset);
   
   cpu6_dffr#(1) csr_r({1{~flash}} & csr, csrE, clk, reset);
   cpu6_dffr#(1) csr_rs1uimm_r({1{~flash}} & csr_rs1uimm, csr_rs1uimmE, clk, reset);
   cpu6_dffr#(`CPU6_CSR_WSC_SIZE) csr_wsc_r({`CPU6_CSR_WSC_SIZE{~flash}} & csr_wsc, csr_wscE, clk, reset);
   
   cpu6_dffr#(1) memwrite_r({1{~flash}} & memwrite, memwriteE, clk, reset);
   
   cpu6_dffr#(1) memtoreg_r({1{~flash}} & memtoreg, memtoregE, clk, reset);
   cpu6_dffr#(`CPU6_BRANCHTYPE_SIZE) branchtype_r({`CPU6_BRANCHTYPE_SIZE{~flash}} & branchtype, branchtypeE, clk, reset);
   cpu6_dffr#(1) alusrc_r({1{~flash}} & alusrc, alusrcE, clk, reset);
   cpu6_dffr#(1) regwrite_r({1{~flash}} & regwrite, regwriteE, clk, reset);
   cpu6_dffr#(1) jump_r({1{~flash}} & jump, jumpE, clk, reset);
   cpu6_dffr#(`CPU6_ALUCONTROL_SIZE) alucontrol_r({`CPU6_ALUCONTROL_SIZE{~flash}} & alucontrol, alucontrolE, clk, reset);
   cpu6_dffr#(`CPU6_IMMTYPE_SIZE) immtype_r({`CPU6_IMMTYPE_SIZE{~flash}} & immtype, immtypeE, clk, reset);

   cpu6_dffr#(`CPU6_XLEN) pc_r({`CPU6_XLEN{~flash}} & pc, pcE, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) instr_r({`CPU6_XLEN{~flash}} & instrF, instrE, clk, reset);
   cpu6_dffr#(1) empty_pipeline_r({1{~flash}} & empty_pipeline_req, empty_pipeline_reqE, clk, reset);
   
endmodule // cpu6_pipelinereg_idex
