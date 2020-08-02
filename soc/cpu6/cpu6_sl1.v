`include "defines.v"

// shift left

module cpu6_sl1  (
		  input  [`CPU6_XLEN-1:0] a,
		  output [`CPU6_XLEN-1:0] y
		  );

   assign y = {a[`CPU6_XLEN-2:0], 1'b0};

endmodule // cpu6_sl2
