`include "defines.v"

module cpu6_hazardunit (
   input  [`CPU6_RFIDX_WIDTH-1:0] rs1idxE,
   input  [`CPU6_RFIDX_WIDTH-1:0] rs2idxE,
   input  [`CPU6_RFIDX_WIDTH-1:0] writeregM,
   input  regwriteM,
   output rs1forwardE,
   output rs2forwardE
   );
 
   wire rs1idxnozero = (rs1idxE != `CPU6_RFIDX_WIDTH'b0);
   wire rs2idxnozero = (rs2idxE != `CPU6_RFIDX_WIDTH'b0);

   wire rs1matchwritereg = (rs1idxE == writeregM);
   wire rs2matchwritereg = (rs2idxE == writeregM);
   
   assign rs1forwardE = (rs1idxnozero & rs1matchwritereg & regwriteM);
   assign rs2forwardE = (rs2idxnozero & rs2matchwritereg & regwriteM);
   
endmodule // cpu6_hazardunit
