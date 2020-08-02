`include "defines.v"

`define MAINDEC_CONTROL_SIZE          13


`define MAINDEC_CONTROL_ALUSRC_RS2     1'b0
`define MAINDEC_CONTROL_ALUSRC_IMM     1'b1

// aluop:                   00: add
//                          01: sub
//                          11: other

// alusrc:                   0: rs2
//                           1: imm

// regdst:                   0: rs2
//                           1: rd

module cpu6_maindec (
		     input  [`CPU6_OPCODE_SIZE-1:0] op,
                     input  [`CPU6_FUNCT3_SIZE-1:0] funct3,
                     input  [`CPU6_FUNCT7_SIZE-1:0] funct7,
		     output memtoreg,
		     output memwrite,
		     output [`CPU6_BRANCHTYPE_SIZE-1:0]branchtype,
		     output alusrc,
		     output regwrite,
		     output jump,
		     output [`CPU6_ALU_OP_SIZE-1:0] aluop,
                     output [`CPU6_IMMTYPE_SIZE-1:0] immtype
		     );

   wire [`MAINDEC_CONTROL_SIZE-1:0] controls;
   
   assign memtoreg = controls[12];
   assign memwrite = controls[11];
   assign branchtype = controls[10:8];
   assign alusrc = controls[7];
   assign regwrite = controls[6];
   assign jump = controls[5];
   assign aluop = controls[4:3];
   assign immtype = controls[2:0];



   wire op_i_arithmatic = (op == `CPU6_OPCODE_SIZE'b0010011);
   wire op_r_instructions = (op == `CPU6_OPCODE_SIZE'b0110011);
   wire op_b_branch = (op == `CPU6_OPCODE_SIZE'b1100011);

   wire funct3_000 = (funct3 == `CPU6_FUNCT3_SIZE'b000);
   wire funct3_001 = (funct3 == `CPU6_FUNCT3_SIZE'b001);
   //wire funct3_010 = (funct3 == 3'b010);
   //wire funct3_011 = (funct3 == 3'b011);
   //wire funct3_100 = (funct3 == 3'b100);
   //wire funct3_101 = (funct3 == 3'b101);
   //wire funct3_110 = (funct3 == 3'b110);
   //wire funct3_111 = (funct3 == 3'b111);

   wire funct7_0000000 = (funct7 == `CPU6_FUNCT7_SIZE'b0000000);
   wire funct7_0100000 = (funct7 == `CPU6_FUNCT7_SIZE'b0100000);
   // ...

   // all 0, invalid instruction, when flash pipeline
   // because CPU6_BRANCHTYPE_NOBRANCH is actually 010
   // Make sure no memory write, no register write, no branch, no jump
   //wire rv32_invalid = (op == `CPU6_OPCODE_SIZE'b0000000);

   wire rv32_lw = (op == `CPU6_OPCODE_SIZE'b0000011);
   wire rv32_sw = (op == `CPU6_OPCODE_SIZE'b0100011);
   
   wire rv32_addi = op_i_arithmatic & funct3_000;

   wire rv32_add = op_r_instructions & funct3_000 & funct7_0000000;
   wire rv32_sub = op_r_instructions & funct3_000 & funct7_0100000;
   
   wire rv32_beq = op_b_branch & funct3_000;
   wire rv32_bne = op_b_branch & funct3_001;
   
   wire rv32_jalr = (op == `CPU6_OPCODE_SIZE'b01100111) & funct3_000; // jalr i-type
   //wire rv32_jal = (op == `CPU6_OPCODE_SIZE'b01110011);
   
//   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_invalid_controls = {
//				    1'b0, // memtoreg: no
//				    1'b0, // memwrite: no
//				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
//				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
//				    1'b0, // regwrite: yes
//				    1'b0, // jump: no
//				    `CPU6_ALU_OP_ADD, // aluop: add
//				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R 
//				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lw_controls = {
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALU_OP_ADD, // aluop: add
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sw_controls = {
				    1'b0, // memtoreg: no
				    1'b1, // memwrite: yes
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALU_OP_ADD, // aluop: add
				    `CPU6_IMMTYPE_S // immtype: CPU6_IMMTYPE_S     
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_addi_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALU_OP_ADD, // aluop: add
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_add_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALU_OP_ADD, // aluop: add
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sub_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALU_OP_SUB, // aluop: sub
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_beq_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BEQ, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALU_OP_SUB, // aluop: sub
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_bne_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BNE, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALU_OP_SUB, // aluop: sub
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B 
				    };

   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_jalr_controls = {
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b1, // jump: yes
				    `CPU6_ALU_OP_ADD, // aluop: add
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   
   assign controls = //({`MAINDEC_CONTROL_SIZE{rv32_invalid}} & rv32_invalid_controls)
                     ({`MAINDEC_CONTROL_SIZE{rv32_lw}} & rv32_lw_controls)
                   | ({`MAINDEC_CONTROL_SIZE{rv32_sw}} & rv32_sw_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_addi}} & rv32_addi_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_add}} & rv32_add_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_sub}} & rv32_sub_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_beq}} & rv32_beq_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_bne}} & rv32_bne_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_jalr}} & rv32_jalr_controls)
		     ;
endmodule

//opcodes-rv32i
//# format of a line in this file:
//# <instruction name> <args> <opcode>
//#
//# <opcode> is given by specifying one or more range/value pairs:
//# hi..lo=value or bit=value or arg=value (e.g. 6..2=0x45 10=1 rd=0)
//#
//# <args> is one of rd, rs1, rs2, rs3, imm20, imm12, imm12lo, imm12hi,
//# shamtw, shamt, rm
//
//beq     bimm12hi rs1 rs2 bimm12lo 14..12=0 6..2=0x18 1..0=3
//bne     bimm12hi rs1 rs2 bimm12lo 14..12=1 6..2=0x18 1..0=3
//blt     bimm12hi rs1 rs2 bimm12lo 14..12=4 6..2=0x18 1..0=3
//bge     bimm12hi rs1 rs2 bimm12lo 14..12=5 6..2=0x18 1..0=3
//bltu    bimm12hi rs1 rs2 bimm12lo 14..12=6 6..2=0x18 1..0=3
//bgeu    bimm12hi rs1 rs2 bimm12lo 14..12=7 6..2=0x18 1..0=3
//
//jalr    rd rs1 imm12              14..12=0 6..2=0x19 1..0=3
//
//jal     rd jimm20                          6..2=0x1b 1..0=3
//
//lui     rd imm20 6..2=0x0D 1..0=3
//auipc   rd imm20 6..2=0x05 1..0=3
//
//addi    rd rs1 imm12           14..12=0 6..2=0x04 1..0=3
//slli    rd rs1 31..26=0  shamt 14..12=1 6..2=0x04 1..0=3
//slti    rd rs1 imm12           14..12=2 6..2=0x04 1..0=3
//sltiu   rd rs1 imm12           14..12=3 6..2=0x04 1..0=3
//xori    rd rs1 imm12           14..12=4 6..2=0x04 1..0=3
//srli    rd rs1 31..26=0  shamt 14..12=5 6..2=0x04 1..0=3
//srai    rd rs1 31..26=16 shamt 14..12=5 6..2=0x04 1..0=3
//ori     rd rs1 imm12           14..12=6 6..2=0x04 1..0=3
//andi    rd rs1 imm12           14..12=7 6..2=0x04 1..0=3
//
//add     rd rs1 rs2 31..25=0  14..12=0 6..2=0x0C 1..0=3
//sub     rd rs1 rs2 31..25=32 14..12=0 6..2=0x0C 1..0=3
//sll     rd rs1 rs2 31..25=0  14..12=1 6..2=0x0C 1..0=3
//slt     rd rs1 rs2 31..25=0  14..12=2 6..2=0x0C 1..0=3
//sltu    rd rs1 rs2 31..25=0  14..12=3 6..2=0x0C 1..0=3
//xor     rd rs1 rs2 31..25=0  14..12=4 6..2=0x0C 1..0=3
//srl     rd rs1 rs2 31..25=0  14..12=5 6..2=0x0C 1..0=3
//sra     rd rs1 rs2 31..25=32 14..12=5 6..2=0x0C 1..0=3
//or      rd rs1 rs2 31..25=0  14..12=6 6..2=0x0C 1..0=3
//and     rd rs1 rs2 31..25=0  14..12=7 6..2=0x0C 1..0=3
//
//lb      rd rs1       imm12 14..12=0 6..2=0x00 1..0=3
//lh      rd rs1       imm12 14..12=1 6..2=0x00 1..0=3
//lw      rd rs1       imm12 14..12=2 6..2=0x00 1..0=3
//lbu     rd rs1       imm12 14..12=4 6..2=0x00 1..0=3
//lhu     rd rs1       imm12 14..12=5 6..2=0x00 1..0=3
//
//sb     imm12hi rs1 rs2 imm12lo 14..12=0 6..2=0x08 1..0=3
//sh     imm12hi rs1 rs2 imm12lo 14..12=1 6..2=0x08 1..0=3
//sw     imm12hi rs1 rs2 imm12lo 14..12=2 6..2=0x08 1..0=3
//
//fence       fm            pred succ     rs1 14..12=0 rd 6..2=0x03 1..0=3
//fence.i     imm12                       rs1 14..12=1 rd 6..2=0x03 1..0=3
