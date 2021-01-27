`include "defines.v"

module cpu6_pipelinereg_exmem (
   input  clk,
   input  reset,
   input  flashM,

   input  [`CPU6_LSWIDTH_SIZE-1:0] lswidthE,
   input  loadsignextE,
   
   input  memwriteE,
   input  [`CPU6_XLEN-1:0] writedataE,
   input  [`CPU6_XLEN-1:0] aluoutE, // used in MEM, but also pass to WB
   input  [`CPU6_RFIDX_WIDTH-1:0] writeregE, // not used in MEM, pass to WB
   input  regwriteE, // not used in MEM, pass to WB
   input  memtoregE, // not used in MEM, pass to WB
   input  [`CPU6_XLEN-1:0] pcplus4E,  // used in MEM, jump need pc+4 in the very last, write to rd
   input  jumpE,     // used in MEM
   // csr
   input  csrE,
   input  [`CPU6_CSR_WSC_SIZE-1:0] csr_wscE,
   input  csr_rs1uimmE,
   input  [`CPU6_XLEN-1:0] forwardrs1_rs1E,
   input  [`CPU6_RFIDX_WIDTH-1:0] csr_rs1idx_uimmE,
   input  csr_rd_enE,
   input  csr_wr_enE,
   input  [`CPU6_CSR_SIZE-1:0] csr_idxE,
   //
   input  empty_pipeline_reqE,
   
   
   output [`CPU6_LSWIDTH_SIZE-1:0] lswidthM,
   output loadsignextM,
   output memwriteM,
   output [`CPU6_XLEN-1:0] writedataM,
   output [`CPU6_XLEN-1:0] aluoutM,
   output [`CPU6_RFIDX_WIDTH-1:0] writeregM,
   output regwriteM,
   output memtoregM,
   output [`CPU6_XLEN-1:0] pcplus4M,
   output jumpM,

   // csr
   output csrM,
   output [`CPU6_CSR_WSC_SIZE-1:0] csr_wscM,
   output csr_rs1uimmM,
   output [`CPU6_XLEN-1:0] csr_rs1M,
   output [`CPU6_RFIDX_WIDTH-1:0] csr_rs1idx_uimmM,
   output csr_rd_enM,
   output csr_wr_enM,
   output [`CPU6_CSR_SIZE-1:0] csr_idxM,
   //
   output empty_pipeline_reqM
);

   cpu6_dffr#(`CPU6_LSWIDTH_SIZE) lswidth_r({`CPU6_LSWIDTH_SIZE{~flashM}} & lswidthE, lswidthM, clk, reset);
   cpu6_dffr#(1) loadsignext_r({1{~flashM}} & loadsignextE, loadsignextM, clk, reset);
   
   cpu6_dffr#(1) memwrite_r({1{~flashM}} & memwriteE, memwriteM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) writedata_r({`CPU6_XLEN{~flashM}} & writedataE, writedataM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) aluout_r({`CPU6_XLEN{~flashM}} & aluoutE, aluoutM, clk, reset);
   cpu6_dffr#(`CPU6_RFIDX_WIDTH) writereg_r({`CPU6_RFIDX_WIDTH{~flashM}} & writeregE, writeregM, clk, reset);
   cpu6_dffr#(1) regwrite_r({1{~flashM}} & regwriteE, regwriteM, clk, reset);
   cpu6_dffr#(1) memtoreg_r({1{~flashM}} & memtoregE, memtoregM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) pcplus4_r({`CPU6_XLEN{~flashM}} & pcplus4E, pcplus4M, clk, reset);
   cpu6_dffr#(1) jump_r({1{~flashM}} & jumpE, jumpM, clk, reset);

   // csr
   cpu6_dffr#(1) csr_r({1{~flashM}} & csrE, csrM, clk, reset);
   cpu6_dffr#(`CPU6_CSR_WSC_SIZE) csr_wsc_r({`CPU6_CSR_WSC_SIZE{~flashM}} & csr_wscE, csr_wscM, clk, reset);
   cpu6_dffr#(1) csr_rs1uimm({1{~flashM}} & csr_rs1uimmE, csr_rs1uimmM, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) csr_rs1({`CPU6_XLEN{~flashM}} & forwardrs1_rs1E, csr_rs1M, clk, reset);
   cpu6_dffr#(`CPU6_RFIDX_WIDTH) csr_rs1idx_uimm_r({`CPU6_RFIDX_WIDTH{~flashM}} & csr_rs1idx_uimmE, csr_rs1idx_uimmM, clk, reset);
   cpu6_dffr#(1) csr_rd_en_r({1{~flashM}} & csr_rd_enE, csr_rd_enM, clk, reset);
   cpu6_dffr#(1) csr_wr_en_r({1{~flashM}} & csr_wr_enE, csr_wr_enM, clk, reset);
   cpu6_dffr#(`CPU6_CSR_SIZE) csr_idx_r({`CPU6_CSR_SIZE{~flashM}} & csr_idxE, csr_idxM, clk, reset);
   //
   cpu6_dffr#(1) empty_pipeline_req_r({1{~flashM}} & empty_pipeline_reqE, empty_pipeline_reqM, clk, reset);
   
endmodule // cpu6_pipelinereg_exmem
