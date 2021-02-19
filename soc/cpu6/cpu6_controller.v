`include "defines.v"

module cpu6_controller (
   input  [`CPU6_OPCODE_SIZE-1:0] op,
   input  [`CPU6_FUNCT3_SIZE-1:0] funct3,
   input  [`CPU6_FUNCT7_SIZE-1:0] funct7,


   // load store width and load signext
   output [`CPU6_LSWIDTH_SIZE-1:0] lswidth,
   output loadsignext,
   
   output lui,  // lui instruction
   output auipc,// auipc instruction
   output mret, // mret instruction
   // csr
   output csr, // csr enable
   output csr_rs1uimm, // 0: rs1   1: rs1idx as uimm
   output [`CPU6_CSR_WSC_SIZE-1:0] csr_wsc, //CSRRW CSRRS CSRRC
   //
   output memtoreg,			
   output memwrite,
   output [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   output alusrc,
   output regwrite,
   output jump,
   output [`CPU6_ALUCONTROL_SIZE-1:0] alucontrol,
   output [`CPU6_IMMTYPE_SIZE-1:0] immtype,
   output illinstr,

   output shft_en,
   output shft_lr, // shift left right
   output shft_la
);
   
   wire [`CPU6_ALUOP_SIZE-1:0] aluop;

   // risc-v
   // op determinss what to do, read from/to memory or
   // registers
   // funct3(mainly) funct7 determine alu operations for some instructions
   // aluop is the way that cpu6_maindec tells cpu6_aludec what
   //    alucontrol it should give
   
   cpu6_maindec md(
      .op        (op      ),
      .funct3    (funct3  ),
      .funct7    (funct7  ),

      .lswidth       (lswidth    ),
      .loadsignext   (loadsignext),
      .lui           (lui        ),
      .auipc         (auipc      ),
      .mret          (mret       ),
      // csr
      .csr           (csr        ),
      .csr_rs1uimm   (csr_rs1uimm),
      .csr_wsc       (csr_wsc    ),
      //
      .memtoreg      (memtoreg   ),
      .memwrite      (memwrite   ),
      .branchtype    (branchtype ),
      .alusrc        (alusrc     ),
      .regwrite      (regwrite   ),
      .jump          (jump       ),
      .aluop         (aluop      ),
      .immtype       (immtype    ),
      .illinstr      (illinstr   )
      );

   cpu6_aludec ad(
      .op              (op             ),
      .funct3          (funct3         ),
      .funct7          (funct7         ),
      .aluop           (aluop          ),
      .alucontrol      (alucontrol     ),
      .shft_en         (shft_en        ),
      .shft_lr         (shft_lr        ),
      .shft_la         (shft_la        )
      );

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
//
//csrrw   rd rs1       csr(imm12)   14..12=1
//csrrs   rd rs1       csr(imm12)   14..12=2
//csrrc   rd rs1       csr(imm12)   14..12=3
//csrrwi  rd uimm      csr(imm12)   14..12=5
//csrrsi  rd uimm      csr(imm12)   14..12=6
//csrrci  rd uimm      csr(imm12)   14..12=7
