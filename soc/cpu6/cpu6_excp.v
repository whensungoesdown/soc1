`include "defines.v"

module cpu6_excp (
   input clk,
   input reset,
   input  [`CPU6_XLEN-1:0] excp_pc,
   input  excp_illinstr,
   output excp_flush_pc_ena,
   output [`CPU6_XLEN-1:0] excp_flush_pc,

   output [`CPU6_XLEN-1:0] excp_mepc,
   output excp_mepc_ena,

   input [`CPU6_XLEN-1:0] csr_mtvec
   );


   assign excp_flush_pc_ena = excp_illinstr
		       //|
		          ;

   assign excp_mepc = excp_pc;

   assign excp_mepc_ena = excp_flush_pc_ena;
   
   assign excp_flush_pc = csr_mtvec;

endmodule // cpu6_csr

   
