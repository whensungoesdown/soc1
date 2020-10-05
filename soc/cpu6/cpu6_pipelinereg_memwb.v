`include "defines.v"

module cpu6_pipelinereg_memwb (
   input  clk,
   input  reset,
   input  flashW,
   input  regwriteM,
   input  [`CPU6_RFIDX_WIDTH-1:0] writeregM,
   input  [`CPU6_XLEN-1:0] rdM,
   input  empty_pipeline_reqM,
   
   output regwriteW,
   output [`CPU6_RFIDX_WIDTH-1:0] writeregW,
   output [`CPU6_XLEN-1:0] rdW,
   output empty_pipeline_reqW
   );

   cpu6_dffr#(1) regwrite_r({1{~flashW}} & regwriteM, regwriteW, clk, reset);
   cpu6_dffr#(`CPU6_RFIDX_WIDTH) writereg_r({`CPU6_RFIDX_WIDTH{~flashW}} & writeregM, writeregW, clk, reset);
   cpu6_dffr#(`CPU6_XLEN) rd_r({`CPU6_XLEN{~flashW}} & rdM, rdW, clk, reset);
   cpu6_dffr#(1) empty_pipeline_req_r({1{~flashW}} & empty_pipeline_reqM, empty_pipeline_reqW, clk, reset);
   
endmodule // cpu6_pipelinereg_memwb
