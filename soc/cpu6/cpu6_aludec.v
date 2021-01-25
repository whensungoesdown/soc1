`include "defines.v"

module cpu6_aludec (
   input  [`CPU6_OPCODE_SIZE-1:0] op,
   input  [`CPU6_FUNCT3_SIZE-1:0] funct3,
   input  [`CPU6_FUNCT7_SIZE-1:0] funct7,
   input  [`CPU6_ALUOP_SIZE-1:0] aluop,
   output [`CPU6_ALUCONTROL_SIZE-1:0] alucontrol
   );
   
   wire aluop_00 = (aluop == `CPU6_ALUOP_LWSWJALR);
   wire aluop_01 = (aluop == `CPU6_ALUOP_BRANCH);
   wire aluop_10 = (aluop == `CPU6_ALUOP_ARITHMETIC);

   wire op_0010011 = (op == `CPU6_OPCODE_SIZE'b0010011);
   wire op_0110011 = (op == `CPU6_OPCODE_SIZE'b0110011);
   
   wire funct3_000 = (funct3 == `CPU6_FUNCT3_SIZE'b000);
//   wire funct3_010 = (funct3 == `CPU6_FUNCT3_SIZE'b010);
   wire funct3_011 = (funct3 == `CPU6_FUNCT3_SIZE'b011); // SLTIU SLTU
//   wire funct3_100 = (funct3 == `CPU6_FUNCT3_SIZE'b011);
   wire funct3_110 = (funct3 == `CPU6_FUNCT3_SIZE'b110);
   wire funct3_111 = (funct3 == `CPU6_FUNCT3_SIZE'b111);
   

   wire funct7_0000000 = (funct7 == `CPU6_FUNCT7_SIZE'b0000000);
   wire funct7_0100000 = (funct7 == `CPU6_FUNCT7_SIZE'b0100000);


   wire rv32_addi = op_0010011 & funct3_000;
   wire rv32_add  = op_0110011 & funct3_000 & funct7_0000000;
   wire rv32_sub  = op_0110011 & funct3_000 & funct7_0100000;
   
   assign alucontrol = ({`CPU6_ALUCONTROL_SIZE{aluop_00}} & `CPU6_ALUCONTROL_ADD) // add (for lw/sw/jalr/lui)
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_01}} & `CPU6_ALUCONTROL_SUB) // sub (for branch)
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & rv32_add}} & `CPU6_ALUCONTROL_ADD ) // add
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & rv32_addi}} & `CPU6_ALUCONTROL_ADD ) // addi
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & rv32_sub}} & `CPU6_ALUCONTROL_SUB ) // sub 
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & funct3_111}} & `CPU6_ALUCONTROL_AND ) // andi and 
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & funct3_110}} & `CPU6_ALUCONTROL_OR ) // ori or 
                     | ({`CPU6_ALUCONTROL_SIZE{aluop_10 & funct3_011}} & `CPU6_ALUCONTROL_SLT ) // sltu or  sltiu
			;

endmodule // cpu6_aludec
 
