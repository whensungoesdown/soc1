`include "defines.v"

module cpu6_hazardcontrol (
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  jump,
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
   input  jumpE,
   input  pcsrcE,
   output stallF,
   output flashE
   );
 
   assign stallF = (((branchtype != `CPU6_BRANCHTYPE_NOBRANCH) | jump) & !pcsrcE);
   assign flashE = (((branchtypeE != `CPU6_BRANCHTYPE_NOBRANCH) | jumpE));
   
endmodule // cpu6_hazardcontrol
