`include "defines.v"

module cpu6_adder (
		   input  [`CPU6_XLEN-1:0] a,
		   input  [`CPU6_XLEN-1:0] b,
		   output [`CPU6_XLEN-1:0] y
		   );
   assign y = a + b;

endmodule // cpu6_adder
