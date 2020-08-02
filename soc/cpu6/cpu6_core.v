`include "defines.v"

module cpu6_core (
		  input  clk,
		  input  reset,
   
		  output [`CPU6_XLEN-1:0] pcF,
		  input  [`CPU6_XLEN-1:0] instr,
                  // write back to memory
		  output memwriteM,
		  output [`CPU6_XLEN-1:0] dataaddr,
		  output [`CPU6_XLEN-1:0] writedata,
                  // fetch data
		  input  [`CPU6_XLEN-1:0] readdata
);

   wire memwrite;
   wire memtoreg;
   wire alusrc;
   wire regdst;
   wire regwrite;
   wire jump;
   wire [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype;
   wire zero;

   wire [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol;
   wire [`CPU6_IMMTYPE_SIZE-1:0] immtype;

   wire memwriteE;
   wire memtoregE;
   wire [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE;
   wire alusrcE;
   wire regwriteE;
   wire jumpE;
   wire [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE;
   wire [`CPU6_IMMTYPE_SIZE-1:0] immtypeE;
   wire [`CPU6_XLEN-1:0] instrE;


   wire [`CPU6_XLEN-1:0] pcplus4F;
   wire [`CPU6_XLEN-1:0] pcnextF;

   wire [`CPU6_XLEN-1:0] pcE;
   wire [`CPU6_XLEN-1:0] pcnextE;
   wire pcsrcE;


   wire stallF;
   wire flashE;


   
   cpu6_hazardcontrol hazardcontrol(branchtype, jump, branchtypeE, jumpE, pcsrcE,
      stallF, flashE);


   
   
   cpu6_dfflr#(`CPU6_XLEN) pcreg(!stallF, pcnextF, pcF, ~clk, reset);
   
   cpu6_adder pcadd4(pcF, 32'b100, pcplus4F); // next pc if no branch, no jump
   cpu6_mux2#(`CPU6_XLEN) pcnextmux(pcplus4F, pcnextE, pcsrcE, pcnextF);  
   
   cpu6_controller c(instr[`CPU6_OPCODE_HIGH:`CPU6_OPCODE_LOW],
		     instr[`CPU6_FUNCT3_HIGH:`CPU6_FUNCT3_LOW],
		     instr[`CPU6_FUNCT7_HIGH:`CPU6_FUNCT7_LOW],
		     memtoreg, memwrite, branchtype,
		     alusrc, regwrite, jump,
		     alucontrol, immtype);

   
   //
   // currently, it's 2 stages pipeline
   // Need to flashE, but not by using reset, reset will even flash 
   // the current ongoing instruction. it's too fast
   // If no flash pipelinereg_idex, this branch instruction will go through the pipeline
   // twice, so it will branch twice, then the following instruction will also be
   // executed twice.
   // So, need flashE, but not by reset, set an flash signal, it makes a bubble into
   // pipeline_idex in the next clock cycle.
   //
   cpu6_pipelinereg_idex pipelinereg_idex(clk, reset,
      flashE,
      memwrite,
      memtoreg, branchtype, alusrc, regwrite, jump, alucontrol, immtype,
      pcF, instr,
      memwriteE,
      memtoregE, branchtypeE, alusrcE, regwriteE, jumpE, alucontrolE, immtypeE,
      pcE, instrE);
  
   cpu6_datapath dp(clk, reset, memwriteE, memtoregE, branchtypeE,
		    alusrcE, regwriteE, jumpE,
		    alucontrolE, immtypeE, pcE, pcnextE, pcsrcE, instrE,
		    dataaddr, writedata, readdata, memwriteM);
endmodule   
