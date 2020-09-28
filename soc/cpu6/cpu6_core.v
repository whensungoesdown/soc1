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
   //wire regdst;
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


   wire illinstr;
   wire excp_flush;
   wire [`CPU6_XLEN-1:0] excp_flush_pc;
   

   cpu6_excp excp(
      .clk           (clk  ),
      .reset         (reset),
      .illinstr      (illinstr  ),
      .excp_flush    (excp_flush),
      .excp_flush_pc (excp_flush_pc)
      );
       

   
   cpu6_hazardcontrol hazardcontrol(branchtype, jump, branchtypeE, jumpE, pcsrcE,
      stallF, flashE);


   
   
   cpu6_dfflr#(`CPU6_XLEN) pcreg(!stallF, pcnextF, pcF, ~clk, reset);
   
   cpu6_adder pcadd4(pcF, 32'b100, pcplus4F); // next pc if no branch, no jump
   
   //cpu6_mux2#(`CPU6_XLEN) pcnextmux(pcplus4F, pcnextE, pcsrcE, pcnextF);
   // 1. excp_flush has the highest priority. For example, illegal instruction, the excp module
   //    need to set pc to trap vector.
   // 2. There is a branch, the branch pc comes from EX stage because it needs calculation
   // 3. pc+4  
   assign pcnextF = 
		    excp_flush ? excp_flush_pc:
		    pcsrcE? pcnextE:
		    pcplus4F;



   // csr
   wire csr;
   wire csr_rs1uimm;
   wire [`CPU6_CSR_WSC_SIZE-1:0] csr_wsc;

   // csr signal pass to datapath IDEX
   wire csrE;
   wire csr_rs1uimmE;
   wire [`CPU6_CSR_WSC_SIZE-1:0] csr_wscE;
   //


   
   cpu6_controller c(
      .op          (instr[`CPU6_OPCODE_HIGH:`CPU6_OPCODE_LOW]),
      .funct3      (instr[`CPU6_FUNCT3_HIGH:`CPU6_FUNCT3_LOW]),
      .funct7      (instr[`CPU6_FUNCT7_HIGH:`CPU6_FUNCT7_LOW]),
      // csr
      .csr         (csr            ),
      .csr_rs1uimm (csr_rs1uimm    ),
      .csr_wsc     (csr_wsc        ),
      //
      .memtoreg    (memtoreg       ),
      .memwrite    (memwrite       ),
      .branchtype  (branchtype     ),
      .alusrc      (alusrc         ),
      .regwrite    (regwrite       ),
      .jump        (jump           ),
      .alucontrol  (alucontrol     ),
      .immtype     (immtype        ),
      .illinstr    (illinstr       )
      );

   
   //
   // To flash the pipeline register, signal flashE. 
   // If no flash pipelinereg_idex, this branch instruction will go through the pipeline
   // twice, so it will branch twice, then the following instruction will also be
   // executed twice.
   // So, need flashE, but not by reset, set an flash signal, it makes a bubble into
   // pipeline_idex in the next clock cycle.
   //
   
   // todo
   cpu6_pipelinereg_idex pipelinereg_idex(
      .clk          (clk    ),
      .reset        (reset  ),
      .flash        (flashE ),
      // csr
      .csr          (csr    ),
      .csr_rs1uimm  (csr_rs1uimm    ),
      .csr_wsc      (csr_wsc        ),
      //
      .memwrite     (memwrite       ),
      .memtoreg     (memtoreg       ),
      .branchtype   (branchtype     ),
      .alusrc       (alusrc         ),
      .regwrite     (regwrite       ),
      .jump         (jump           ),
      .alucontrol   (alucontrol     ),
      .immtype      (immtype        ),
      .pc           (pcF     ),
      .instr        (instr   ),
      // csr
      .csrE         (csrE    ),
      .csr_rs1uimmE (csr_rs1uimmE   ),
      .csr_wscE     (csr_wscE       ),
      //
      .memwriteE    (memwriteE      ),
      .memtoregE    (memtoregE      ),
      .branchtypeE  (branchtypeE    ),
      .alusrcE      (alusrcE        ),
      .regwriteE    (regwriteE      ),
      .jumpE        (jumpE          ),
      .alucontrolE  (alucontrolE    ),
      .immtypeE     (immtypeE       ),
      .pcE          (pcE      ),
      .instrE       (instrE   )
      );
  
   cpu6_datapath dp(
      .clk          (clk      ),
      .reset        (reset    ),
      .memwriteE    (memwriteE    ),
      .memtoregE    (memtoregE    ),
      .branchtypeE  (branchtypeE  ),
      .alusrcE      (alusrcE      ),
      .regwriteE    (regwriteE    ),
      .jumpE        (jumpE        ),
      .alucontrolE  (alucontrolE  ),
      .immtypeE     (immtypeE     ),
      .pcE          (pcE      ),
      .pcnextE      (pcnextE  ),
      .pcsrcE       (pcsrcE   ),
      .instrE       (instrE   ),
      // csr
      .csrE         (csrE         ),
      .csr_rs1uimmE (csr_rs1uimmE ),
      .csr_wscE     (csr_wscE     ),
      //
      .dataaddrM    (dataaddr     ),
      .writedataM   (writedata    ),
      .readdataM    (readdata     ),
      .memwriteM    (memwriteM    )
      );
endmodule   
