`include "defines.v"

module cpu6_branchdec (
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  zero,
   output branch
   );

  
   assign branch = ((branchtype == `CPU6_BRANCHTYPE_BEQ) & zero)
               | ((branchtype == `CPU6_BRANCHTYPE_BNE) & (~zero))
	;
   
endmodule // cpu6_branchdec
