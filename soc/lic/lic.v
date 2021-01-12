`include "../cpu6/defines.v"

module lic (
   input  clk,
   input  reset,
   output [`CPU6_XLEN-1:0] lic_mtime_read,
   input  [`CPU6_XLEN-1:0] lic_mtime_write,
   input  lic_mtime_write_ena,
   
   output [`CPU6_XLEN-1:0] lic_mtimecmp_read,
   input  [`CPU6_XLEN-1:0] lic_mtimecmp_write,
   input  lic_mtimecmp_write_ena,

   input  csr_mtie_r,
   output lic_tmr_irq_r
   );


   wire [`CPU6_XLEN-1:0] mtime;
   wire [`CPU6_XLEN-1:0] mtime_plus1;
   wire [`CPU6_XLEN-1:0] mtime_nxt;

   wire lic_timer_interrupt;

   assign lic_mtime_read = mtime;
   assign mtime_plus1 = mtime + `CPU6_XLEN'b1;
   assign mtime_nxt = lic_mtime_write_ena ? lic_mtime_write : mtime_plus1;
  
   //assign lic_timer_interrupt = 1'b0;


   // change back to RISC-V specification
   // A timer interrupt is pending when mtime < lic_mtimecmp_read
   // if mtime or mtimecmp are not reset in trap handler, the pending
   // keeps on. Then mstatus.mie will also keeps zero, global interrupt
   // disabled.
   assign lic_timer_interrupt = (mtime < lic_mtimecmp_read) ? 1'b0 : 1'b1;
   assign lic_tmr_irq_r = lic_timer_interrupt & csr_mtie_r;

   // Different from the RISC-V specification.
   // the lic_timer_interrupt decides mtip machine timer interrupt pending
   // bit, the pending bit only set when mtime equals mtimecmp, only for
   // one cycle.
   // However, the specification says, the pending is posted until
   // mtimecmp > mtime      
   //assign lic_timer_interrupt = (mtime == lic_mtimecmp_read) ? 1'b1 : 1'b0;
   
   cpu6_dfflr #(`CPU6_XLEN) mtime_dfflr(
      .lden     (1'b1        ),
      .dnxt     (mtime_nxt          ),
      .qout     (mtime              ),
      .clk      (clk         ),
      .rst      (reset       )
      );    

   cpu6_dfflr #(`CPU6_XLEN) mtimecmp_dfflr(
      .lden     (lic_mtimecmp_write_ena),
      .dnxt     (lic_mtimecmp_write    ),
      .qout     (lic_mtimecmp_read     ),
      .clk      (clk         ),
      .rst      (reset       )
      );
  
endmodule // lic
