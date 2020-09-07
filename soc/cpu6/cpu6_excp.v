`include "defines.v"

module cpu6_excp (
   input clk,
   input reset,

   input illinstr,
   output excp_flush,
   output [`CPU6_XLEN-1:0] excp_flush_pc
   );


   assign excp_flush = illinstr
		       //|
		          ;
   
   assign excp_flush_pc = `CPU6_MTVEC_TRAP_BASE;
   
endmodule // cpu6_csr

   
