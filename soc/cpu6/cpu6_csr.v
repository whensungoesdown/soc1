`include "defines.v"

module cpu6_csr (
   input  clk,
   input  reset,

   input  csr_rd_en,
   input  csr_wr_en,
   input  [`CPU6_CSR_SIZE-1:0] csr_idx,
   output [`CPU6_XLEN-1:0] csr_read_dat,
   input  [`CPU6_XLEN-1:0] csr_write_dat,

   input  tmr_irq_r,

   input  [`CPU6_XLEN-1:0] excp_mepc,
   input  excp_mepc_ena,
   
   output [`CPU6_XLEN-1:0] csr_mtvec,
   output [`CPU6_XLEN-1:0] csr_mepc  // the current mepc output
   );


   //
   //  mtvec 
   //
   assign csr_mtvec = `CPU6_MTVEC_TRAP_BASE;

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
   
   //wire [`CPU6_XLEN-1:0] csr_mepc;
   assign csr_mepc = epc_r;

   
   //
   // 0x344 MRW mip  Machine interrupt pending
   //
   wire sel_mip = (csr_idx == 12'h344);
   wire rd_mip = sel_mip & csr_rd_en;

   wire mtip_r; // timer pending
   cpu6_dffr #(1) mtip_dffr(tmr_irq_r, mtip_r, clk, reset);

   wire [`CPU6_XLEN-1:0] mip_r;
   assign mip_r[31:8] = 24'b0;
   assign mip_r[7] = mtip_r;
   assign mip_r[6:0] = 7'b0;
   wire [`CPU6_XLEN-1:0] csr_mip = mip_r;
   

   
   //
   // 0x304 MRW mie Machine trap handler base address
   //
   wire sel_mie = (csr_idx == 12'h304);
   wire rd_mie = sel_mie & csr_rd_en;
   wire wr_mie = sel_mie & csr_wr_en;

   wire mtie_r; // timer enable
   wire mtie_nxt = csr_write_dat[7];
   cpu6_dfflr #(1) mtie_dfflr(wr_mie, mtie_nxt, mtie_r, clk, reset);
   wire [`CPU6_XLEN-1:0] mie_r;

   assign mie_r[31:8] = 24'b0;
   assign mie_r[7] = mtie_r;
   assign mie_r[6:0] = 7'b0;

   wire [`CPU6_XLEN-1:0] csr_mie = mie_r;

   
       

   
   assign csr_read_dat = `CPU6_XLEN'b0
			 | ({`CPU6_XLEN{rd_mepc}} & csr_mepc)
			 | ({`CPU6_XLEN{rd_mip }} & csr_mip )
                         | ({`CPU6_XLEN{rd_mie }} & csr_mie )
			    //| ({`CPU6_XLEN{rd_mtvec}} & csr_mtvec)
			    ; 

endmodule // cpu6_csr 
