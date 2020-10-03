`include "defines.v"

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
