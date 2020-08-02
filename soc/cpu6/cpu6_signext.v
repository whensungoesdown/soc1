`include "defines.v"

module cpu6_signext (
		     input  [`CPU6_IMM_SIZE-1:0] a,
		     output [`CPU6_XLEN-1:0] y
		     );

   assign y = {{`CPU6_XLEN-`CPU6_IMM_SIZE{a[`CPU6_IMM_SIZE-1]}}, a};

endmodule // cpu6_signext

