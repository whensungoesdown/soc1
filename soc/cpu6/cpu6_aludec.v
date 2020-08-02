`include "defines.v"

module cpu6_aludec (
   input  [`CPU6_FUNCT3_SIZE-1:0] funct3,
   input  [`CPU6_FUNCT7_SIZE-1:0] funct7,
   input  [`CPU6_ALU_OP_SIZE-1:0] aluop,
   output [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol
   );
   
   wire aluop_00 = (aluop == 2'b00);
   wire aluop_01 = (aluop == 2'b01);

   assign alucontrol = ({3{aluop_00}} & 3'b010) // add (for lw/sw/addi)
                     | ({3{aluop_01}} & 3'b110);

endmodule // cpu6_aludec
 
