`include "defines.v"

module cpu6_excp (
   input clk,
   input reset,
   input  [`CPU6_XLEN-1:0] excp_pc,

   input  excp_illinstr,
   input  tmr_irq_r,
   input  ext_irq_r,
   
   input  csr_mstatus_mie_r,

   output excp_flush_pc_ena,
   output [`CPU6_XLEN-1:0] excp_flush_pc,

   output [`CPU6_XLEN-1:0] excp_mepc,
   output excp_mepc_ena,

   input [`CPU6_XLEN-1:0] csr_mtvec
   );


   // this module should send out mcause 
   // for each exception and timer interrupt

   wire irq_req_raw = (
	               (tmr_irq_r & csr_mstatus_mie_r)
                      |(ext_irq_r & csr_mstatus_mie_r) // prevent reentry
	              //| (ext_irq_r & csr_meie_r & csr_mstatus_mie_r)
	);
   

   
   assign excp_flush_pc_ena = excp_illinstr
                            | irq_req_raw
		       //|
		          ;
   
   // only traps such as ebreak ecall resume at pc+4, exception re-execute pc
   // interrupts next instruction is not necessarily pc+4
   // for example, the interrupt happens on a beq.

   assign excp_mepc = excp_pc;

   assign excp_mepc_ena = excp_flush_pc_ena;
   
   assign excp_flush_pc = csr_mtvec;

endmodule // cpu6_csr

   
