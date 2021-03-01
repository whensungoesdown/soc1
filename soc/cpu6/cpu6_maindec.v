`include "defines.v"

`define MAINDEC_CONTROL_SIZE          24


`define MAINDEC_CONTROL_ALUSRC_RS2     1'b0
`define MAINDEC_CONTROL_ALUSRC_IMM     1'b1

// aluop:                   00: lw sw
//                          01: branch
//                          10: arithmetic 

// alusrc:                   0: rs2
//                           1: imm

// regdst:                   0: rs2
//                           1: rd

module cpu6_maindec (
		     input  [`CPU6_OPCODE_SIZE-1:0] op,
                     input  [`CPU6_FUNCT3_SIZE-1:0] funct3,
                     input  [`CPU6_FUNCT7_SIZE-1:0] funct7,
 
                     output [`CPU6_LSWIDTH_SIZE-1:0] lswidth,
                     output loadsignext,
   
                     output jal,
                     output lui,
                     output auipc,
                     output mret, // later there will be URET SRET MRET 
                     // csr
                     output csr, // csr enable
                     output csr_rs1uimm, // 0: rs1   1: rs1idx as uimm
                     output [`CPU6_CSR_WSC_SIZE-1:0] csr_wsc, //CSRRW CSRRS CSRRC
                     //
		     output memtoreg,
		     output memwrite,
		     output [`CPU6_BRANCHTYPE_SIZE-1:0]branchtype,
		     output alusrc,
		     output regwrite,
		     output jump,
		     output [`CPU6_ALUOP_SIZE-1:0] aluop,
                     output [`CPU6_IMMTYPE_SIZE-1:0] immtype,
                     output illinstr
		     );

   wire [`MAINDEC_CONTROL_SIZE-1:0] controls;

   assign lswidth = controls[23:22];
   assign loadsignext = controls[21];
   assign jal = controls[20];
   assign lui = controls[19];
   assign auipc = controls[18];
   assign mret = controls[17];
   assign csr = controls[16];
   assign csr_rs1uimm = controls[15];
   assign csr_wsc = controls[14:13];
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
   wire funct3_010 = (funct3 == `CPU6_FUNCT3_SIZE'b010);
   wire funct3_011 = (funct3 == `CPU6_FUNCT3_SIZE'b011);
   wire funct3_100 = (funct3 == `CPU6_FUNCT3_SIZE'b100);
   wire funct3_101 = (funct3 == `CPU6_FUNCT3_SIZE'b101);
   wire funct3_110 = (funct3 == `CPU6_FUNCT3_SIZE'b110);
   wire funct3_111 = (funct3 == `CPU6_FUNCT3_SIZE'b111);

   wire funct7_0000000 = (funct7 == `CPU6_FUNCT7_SIZE'b0000000);
   wire funct7_0100000 = (funct7 == `CPU6_FUNCT7_SIZE'b0100000);
   wire funct7_0011000 = (funct7 == `CPU6_FUNCT7_SIZE'b0011000);
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
   wire rv32_bltu = op_b_branch & funct3_110;
   wire rv32_bgeu = op_b_branch & funct3_111;
   
   wire rv32_jalr = (op == `CPU6_OPCODE_SIZE'b1100111) & funct3_000; // jalr i-type
   wire rv32_jal  = (op == `CPU6_OPCODE_SIZE'b1101111); // jal j-type

   wire rv32_csrrw = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_001;
   wire rv32_csrrs = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_010;
   wire rv32_csrrc = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_011;
   wire rv32_csrrwi = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_101;
   wire rv32_csrrsi = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_110;
   wire rv32_csrrci = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_111;
   
   wire rv32_mret = (op == `CPU6_OPCODE_SIZE'b1110011) & funct3_000 & funct7_0011000;

   wire rv32_lui = (op == `CPU6_OPCODE_SIZE'b0110111);
   wire rv32_auipc = (op == `CPU6_OPCODE_SIZE'b0010111);

   wire rv32_andi = op_i_arithmatic & funct3_111;
   wire rv32_and  = op_r_instructions & funct3_111 & funct7_0000000;
   wire rv32_ori  = op_i_arithmatic & funct3_110;
   wire rv32_or   = op_r_instructions & funct3_110 & funct7_0000000;
   wire rv32_sltiu= op_i_arithmatic & funct3_011;
   wire rv32_sltu = op_r_instructions & funct3_011 & funct7_0000000;
   wire rv32_xori = op_i_arithmatic & funct3_100;
   wire rv32_xor  = op_r_instructions & funct3_100 & funct7_0000000;

   wire rv32_lh  = ((op == `CPU6_OPCODE_SIZE'b0000011) & funct3_001);
   wire rv32_lhu = ((op == `CPU6_OPCODE_SIZE'b0000011) & funct3_101);
   wire rv32_lb  = ((op == `CPU6_OPCODE_SIZE'b0000011) & funct3_000);
   wire rv32_lbu = ((op == `CPU6_OPCODE_SIZE'b0000011) & funct3_100);

   wire rv32_srl  = op_r_instructions & funct3_101 & funct7_0000000;
   wire rv32_sra  = op_r_instructions & funct3_101 & funct7_0100000;
   wire rv32_sll  = op_r_instructions & funct3_001 & funct7_0000000;
   
   // shamt must less than 32, otherwise illeagl instruction
   wire rv32_srli  = op_i_arithmatic & funct3_101 & funct7_0000000; 
   wire rv32_srai  = op_i_arithmatic & funct3_101 & funct7_0100000; // shamt must less than 32
   wire rv32_slli  = op_i_arithmatic & funct3_001 & funct7_0000000; // shamt must less than 32
   
   assign illinstr = ~(rv32_lw | rv32_sw
		     | rv32_addi
		     | rv32_add | rv32_sub
		     | rv32_beq | rv32_bne | rv32_bltu | rv32_bgeu
		     | rv32_jalr | rv32_jal
		     | rv32_csrrw | rv32_csrrs | rv32_csrrc
		     | rv32_csrrwi | rv32_csrrsi | rv32_csrrci
		     | rv32_mret
		     | rv32_lui | rv32_auipc
		     | rv32_andi| rv32_and
		     | rv32_ori | rv32_or
		     | rv32_sltiu | rv32_sltu
		     | rv32_xori | rv32_xor
		     | rv32_lh | rv32_lhu | rv32_lb | rv32_lbu
		     | rv32_srl| rv32_sra | rv32_sll
		     | rv32_srli| rv32_srai | rv32_slli
		     );


   
//   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_invalid_controls = {
//                                  2'b00, // ignore, (load store width 32)
//                                  1'b0,  // ignore, (load zero extent)   
//                                  1'b0, // jal: no
//				    1'b0, // lui: no
//				    1'b0, // auipc: no
//				    1'b0, // mret: no
//				    1'b0, // csr: no
//				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
//				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
//				    1'b0, // memtoreg: no
//				    1'b0, // memwrite: no
//				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
//				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
//				    1'b0, // regwrite: yes
//				    1'b0, // jump: no
//				    2'b00, // aluop: ignore
//				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R 
//				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lw_controls = {
                                    2'b00, // load store width 32
                                    1'b0,  // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sw_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b1, // memwrite: yes
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_S // immtype: CPU6_IMMTYPE_S     
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_addi_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_add_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sub_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_beq_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BEQ, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALUOP_BRANCH, // aluop: branch
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_bne_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BNE, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALUOP_BRANCH, // aluop: branch
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_bltu_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BLTU, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALUOP_BRANCH, // aluop: branch
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_bgeu_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_BGEU, // branch
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    `CPU6_ALUOP_BRANCH, // aluop: branch
				    `CPU6_IMMTYPE_B // immtype: CPU6_IMMTYPE_B 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_jalr_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b1, // jump: yes
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwswjalr
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_jal_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                  1'b1, // jal: yes
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b1, // jump: yes
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwswjalr
				    `CPU6_IMMTYPE_J // immtype: CPU6_IMMTYPE_J 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrw_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrs_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_S, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrc_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    `CPU6_CSR_WSC_C, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrwi_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_UIMM, // csr_rs1uimm: 1 uimm
				    `CPU6_CSR_WSC_W, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrsi_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_UIMM, // csr_rs1uimm: 1 uimm
				    `CPU6_CSR_WSC_S, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_csrrci_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b1, // csr: yes
				    `CPU6_CSR_UIMM, // csr_rs1uimm: 1 uimm
				    `CPU6_CSR_WSC_C, // csr_wsc: CSRW
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_mret_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b1, // mret: yes
				    1'b0, // csr: no
				    1'b0, // 
				    2'b00,//
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b0, // regwrite: no
				    1'b0, // jump: no
				    2'b00, // aluop: ignore
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lui_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b1, // lui: yes
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    1'b0, // csr
				    2'b00,// csr
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: LWSWJALR
				    `CPU6_IMMTYPE_U // immtype: CPU6_IMMTYPE_U 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_auipc_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b1, // auipc: yes
				    1'b0, // mret: no
				    1'b0, // csr: no
				    1'b0, // csr
				    2'b00,// csr
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lw sw jalr
				    `CPU6_IMMTYPE_U // immtype: CPU6_IMMTYPE_U 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_andi_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b00, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };
   

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_and_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_ori_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b00, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_or_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sltiu_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b00, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sltu_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_xori_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b00, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I    
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_xor_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lh_controls = {
                                    `CPU6_LSWIDTH_H, // load store width 16
                                    1'b1,  // load sign extend   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lhu_controls = {
                                    `CPU6_LSWIDTH_H, // load store width 16
                                    1'b0,  // load zero extend   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lb_controls = {
                                    `CPU6_LSWIDTH_B, // load store width 8
                                    1'b1,  // load sign extend   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_lbu_controls = {
                                    `CPU6_LSWIDTH_B, // load store width 8
                                    1'b0,  // load zero extend   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b1, // memtoreg: yes
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc: imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_LWSWJALR, // aluop: lwsw
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_srl_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sra_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_sll_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_RS2, // alusrc: rs2
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_R // immtype: CPU6_IMMTYPE_R, no imm 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_srli_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc(also for shft): imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };
   
   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_srai_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc(also for shft): imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
				    `CPU6_IMMTYPE_I // immtype: CPU6_IMMTYPE_I 
				    };

   wire [`MAINDEC_CONTROL_SIZE-1:0] rv32_slli_controls = {
                                    2'b00,// ignore, (load store width 32)
                                    1'b0, // ignore, (load zero extent)   
                                    1'b0, // jal: no
				    1'b0, // lui: no
				    1'b0, // auipc: no
				    1'b0, // mret: no
				    1'b0, // csr: no
				    `CPU6_CSR_RS1, // csr_rs1uimm: 0 rs1
				    2'b0, // csr_wsc: ignore
				    1'b0, // memtoreg: no
				    1'b0, // memwrite: no
				    `CPU6_BRANCHTYPE_NOBRANCH, // branch: no
				    `MAINDEC_CONTROL_ALUSRC_IMM, // alusrc(also for shft): imm
				    1'b1, // regwrite: yes
				    1'b0, // jump: no
				    `CPU6_ALUOP_ARITHMETIC, // aluop: arithmetic
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
		   | ({`MAINDEC_CONTROL_SIZE{rv32_bltu}} & rv32_bltu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_bgeu}} & rv32_bgeu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_jalr}} & rv32_jalr_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_jal}} & rv32_jal_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrw}} & rv32_csrrw_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrs}} & rv32_csrrs_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrc}} & rv32_csrrc_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrwi}} & rv32_csrrwi_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrsi}} & rv32_csrrsi_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_csrrci}} & rv32_csrrci_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_mret}} & rv32_mret_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_lui}} & rv32_lui_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_auipc}} & rv32_auipc_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_andi}} & rv32_andi_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_and}} & rv32_and_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_ori}} & rv32_ori_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_or}} & rv32_or_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_sltiu}} & rv32_sltiu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_sltu}} & rv32_sltu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_xori}} & rv32_xori_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_xor}} & rv32_xor_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_lh}} & rv32_lh_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_lhu}} & rv32_lhu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_lb}} & rv32_lb_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_lbu}} & rv32_lbu_controls)
		   | ({`MAINDEC_CONTROL_SIZE{rv32_srl}} & rv32_srl_controls) // further decoding in aludec
		   | ({`MAINDEC_CONTROL_SIZE{rv32_sra}} & rv32_sra_controls) // further decoding in aludec
		   | ({`MAINDEC_CONTROL_SIZE{rv32_sll}} & rv32_sll_controls) // further decoding in aludec
		   | ({`MAINDEC_CONTROL_SIZE{rv32_srli}} & rv32_srli_controls) // further decoding in aludec
		   | ({`MAINDEC_CONTROL_SIZE{rv32_srai}} & rv32_srai_controls) // further decoding in aludec
		   | ({`MAINDEC_CONTROL_SIZE{rv32_slli}} & rv32_slli_controls) // further decoding in aludec
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
