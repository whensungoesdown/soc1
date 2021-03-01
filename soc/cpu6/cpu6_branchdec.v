`include "defines.v"

module cpu6_branchdec (
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  zero,
   input  lt,
   output branch
   );

  
   assign branch = ((branchtype == `CPU6_BRANCHTYPE_BEQ) & zero)
               | ((branchtype == `CPU6_BRANCHTYPE_BNE) & (~zero))
	       | ((branchtype == `CPU6_BRANCHTYPE_BLTU) & lt)
	       | ((branchtype == `CPU6_BRANCHTYPE_BGEU) & (~lt))
	;
   
endmodule // cpu6_branchdec
