`include "defines.v"

module cpu6_datapath (
		      input  clk,
		      input  reset,
                      input  memwriteE,
		      input  memtoregE,
		      input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
		      input  alusrcE,
		      input  regwriteE,
		      input  jumpE,
		      input  [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE,
                      input  [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
		      input  [`CPU6_XLEN-1:0] pcE,
                      output [`CPU6_XLEN-1:0] pcnextE,
                      output pcsrcE,
		      input  [`CPU6_XLEN-1:0] instrE,
                      // csr
                      input  csrE, // csr enable
                      input  csr_rs1uimmE, // uimm: rs1 field as uimm
                      input  [`CPU6_CSR_WSC_SIZE-1:0] csr_wscE, // CSRRW CSRRS CSRRC
                      //
		      output [`CPU6_XLEN-1:0] dataaddrM,
		      output [`CPU6_XLEN-1:0] writedataM,
		      input  [`CPU6_XLEN-1:0] readdataM,
                      output memwriteM
		      );

   wire [`CPU6_XLEN-1:0] aluoutE;

  
   // writeregE shoudl be writeregW, later 
   wire [`CPU6_RFIDX_WIDTH-1:0] writeregE = instrE[`CPU6_RD_HIGH:`CPU6_RD_LOW];
   wire [`CPU6_XLEN-1:0] writedataE;

   wire [`CPU6_XLEN-1:0] pcnextbrE;
   wire [`CPU6_XLEN-1:0] pcplus4E;
   wire [`CPU6_XLEN-1:0] pcbranchE;

   wire [`CPU6_XLEN-1:0] signimmE; 
   wire [`CPU6_XLEN-1:0] signimmshE;
   
   wire [`CPU6_XLEN-1:0] rs1E;  // should be D, later
   wire [`CPU6_XLEN-1:0] rs2E;
   wire [`CPU6_XLEN-1:0] rs2_immE; // should be D, later
   wire [`CPU6_XLEN-1:0] forwardrs1_rs1E;
   wire [`CPU6_XLEN-1:0] forwardrs2_rs2E;
   wire rs1forwardE;
   wire rs2forwardE;

   wire branchE;
   wire zeroE;

// IFID pipeline should not be here   
//   wire [`CPU6_XLEN-1:0] pcD;
//   wire [`CPU6_XLEN-1:0] instrD;
//   
//   cpu6_pipelinereg_d pipelinereg_d (clk, reset,
//      pc, instr,
//      pcD, instrD);
   

   //wire writedataM;
   wire [`CPU6_XLEN-1:0] aluoutM;
   wire [`CPU6_RFIDX_WIDTH-1:0] writeregM;
   wire regwriteM;
   wire memtoregM;
   wire [`CPU6_XLEN-1:0] pcplus4M;
   wire jumpM;
   
   //wire [`CPU6_XLEN-1:0] alu_memM;
   wire [`CPU6_XLEN-1:0] rdM;


   
   wire [`CPU6_RFIDX_WIDTH-1:0] writeregW;
   wire regwriteW;
   wire [`CPU6_XLEN-1:0] rdW;


   
//
//  EX
//

   // csr
   wire csr_rd_enE;
   wire csr_wr_enE;
   wire [`CPU6_CSR_SIZE-1:0] csr_idxE;
   wire [`CPU6_RFIDX_WIDTH-1:0] csr_rdidxE;
   wire [`CPU6_RFIDX_WIDTH-1:0] csr_rs1idx_uimmE;
   wire csr_rdidx_x0E;
   wire csr_rs1idx_uimm_0E;
   //wire csr_read_datE;
   //wire csr_write_datE;

   
   assign csr_idxE = instrE[`CPU6_I_IMM_HIGH:`CPU6_I_IMM_LOW];
   
   assign csr_rdidxE = instrE[`CPU6_RD_HIGH:`CPU6_RD_LOW];
   assign csr_rdidx_x0E = (csr_rdidxE == 12'h000);
   
   assign csr_rs1idx_uimmE = instrE[`CPU6_RS1_HIGH:`CPU6_RS1_LOW];
   assign csr_rs1idx_uimm_0E = (csr_rs1idx_uimmE == 12'h000);
   
   assign csr_rd_enE = (csrE & (~csr_rdidx_x0E));
   
   assign csr_wr_enE = (csrE & ((~csr_rs1idx_uimm_0E) | (csr_wscE == `CPU6_CSR_WSC_W)));
   //
   
   
   // decode imm
   cpu6_immdec immdec(instrE, immtypeE, signimmE);

   // decode branch
   cpu6_branchdec branchdec(branchtypeE, zeroE, branchE);
   
   // next PC logic
   //cpu6_dffr#(`CPU6_XLEN) pcreg(stallF, pcnext, pc, clk, reset);
   
   cpu6_adder pcadd1(pcE, 32'b100, pcplus4E); // jump instruction need this to load it to rd
   cpu6_sl1 immsh(signimmE, signimmshE);
   // risc-v counts begin at the current branch instruction
   cpu6_adder pcadd2(pcE, signimmshE, pcbranchE);
   // branch desides if to take next instruction or branch to pcbranch
   // pcnextbr means pc next br 
   cpu6_mux2#(`CPU6_XLEN) pcbrmux(pcplus4E, pcbranchE, branchE, pcnextbrE);
   // pcnext is the final pc
   // jump address is from alu
   cpu6_mux2#(`CPU6_XLEN) pcmux(pcnextbrE, aluoutE, jumpE, pcnextE);
   
   //assign pcsrcE = branchE | jumpE;
   assign pcsrcE = (branchtypeE != `CPU6_BRANCHTYPE_NOBRANCH) | jumpE;  

   // register file logic
   cpu6_regfile rf(instrE[`CPU6_RS1_HIGH:`CPU6_RS1_LOW],
                   instrE[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
                   rs1E, rs2E, 
                   regwriteW,
		   writeregW, rdW,
		   clk, reset);





   cpu6_hazardunit hazardunit(instrE[`CPU6_RS1_HIGH:`CPU6_RS1_LOW],
                              instrE[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
                              writeregM,
                              regwriteM,
                              rs1forwardE,
                              rs2forwardE);

   

   // now we only have forwarded value from MEM, no WB stage
   cpu6_mux2#(`CPU6_XLEN) forwardrs1mux(rs1E, rdM, rs1forwardE, forwardrs1_rs1E);
   cpu6_mux2#(`CPU6_XLEN) forwardrs2mux(rs2E, rdM, rs2forwardE, forwardrs2_rs2E);
   
   // SW: rs2 contains data to write to memory
   //assign writedataE = rs2E;
   assign writedataE = forwardrs2_rs2E;
   
   // rd <-- mem/reg
   // when write to rs2?
   // only mips need to determine write-register, MIPS LW use rt(rs2) as the destination register
   // but other type instruction use rd
   
   //cpu6_mux2#(`CPU6_RFIDX_WIDTH) wrmux(instr[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
   //				       instr[`CPU6_RD_HIGH:`CPU6_RD_LOW],
   //				       regdst, writereg);
   


   //cpu6_signext se(instr[`CPU6_IMM_HIGH:`CPU6_IMM_LOW], signimm);

   // ALU logic
   //cpu6_mux2#(`CPU6_XLEN) srcbmux(rs2E, signimmE, alusrcE, rs2_immE);
   //cpu6_alu alu(rs1E, rs2_immE, alucontrolE, aluoutE, zeroE);
   cpu6_mux2#(`CPU6_XLEN) srcbmux(forwardrs2_rs2E, signimmE, alusrcE, rs2_immE);
   cpu6_alu alu(forwardrs1_rs1E, rs2_immE, alucontrolE, aluoutE, zeroE);
	





   
   // csr
   wire csrM;
   wire [`CPU6_CSR_WSC_SIZE-1:0] csr_wscM;
   wire csr_rs1uimmM;
   wire [`CPU6_XLEN-1:0] csr_rs1M;
   wire csr_rd_enM;
   wire csr_wr_enM;
   wire [`CPU6_CSR_SIZE-1:0] csr_idxM;
   //wire [`CPU6_RFIDX_WIDTH-1:0] csr_rdidxM;
   wire [`CPU6_RFIDX_WIDTH-1:0] csr_rs1idx_uimmM;
   //wire csr_rdidx_x0M;
   //wire csr_rs1idx_uimm_0M;
   wire [`CPU6_XLEN-1:0] csr_read_datM;

   
//
// pipeline EXMEM
   
   cpu6_pipelinereg_exmem pipelinereg_exmem(
      .clk         (~clk  ), 
      .reset       (reset ),
      .flashM      (1'b0  ),
      .memwriteE   (memwriteE ),
      .writedataE  (writedataE),
      .aluoutE     (aluoutE   ), // used in MEM, but also pass to WB
      .writeregE   (writeregE ), // not used in MEM, pass to WB
      .regwriteE   (regwriteE ), // not used in MEM, pass to WB
      .memtoregE   (memtoregE ), // not used in MEM, pass to WB
      .pcplus4E    (pcplus4E  ),  // used in MEM, jump need pc+4 in the very last, write to rd
      .jumpE       (jumpE     ),     // used in MEM
      // for csr
      .csrE        (csrE      ),
      .csr_wscE    (csr_wscE  ),
      .csr_rs1uimmE     (csr_rs1uimmE    ), // use 'rs1' or 'rs1idx as uimm'
      .forwardrs1_rs1E  (forwardrs1_rs1E ),
      .csr_rs1idx_uimmE (csr_rs1idx_uimmE),
      .csr_rd_enE       (csr_rd_enE      ),
      .csr_wr_enE       (csr_wr_enE      ),
      .csr_idxE         (csr_idxE        ),
      //.csr_read_datE    (csr_read_datE   ),
      //
      
      .memwriteM   (memwriteM ),
      .writedataM  (writedataM),
      .aluoutM     (aluoutM   ),
      .writeregM   (writeregM ),
      .regwriteM   (regwriteM ),
      .memtoregM   (memtoregM ),
      .pcplus4M    (pcplus4M  ),
      .jumpM       (jumpM     ),
      // for csr
      .csrM        (csrM      ),
      .csr_wscM    (csr_wscM  ),
      .csr_rs1uimmM      (csr_rs1uimmM    ), // use 'rs1' or 'rs1idx as uimm'
      .csr_rs1M          (csr_rs1M        ), // solved data hazard
      .csr_rs1idx_uimmM  (csr_rs1idx_uimmM),
      .csr_rd_enM        (csr_rd_enM      ),
      .csr_wr_enM        (csr_wr_enM      ),
      .csr_idxM          (csr_idxM        )
      //.csr_read_datM     (csr_read_datM   )
      //
      );
//
//
   



   
//      
//  MEM
//



   // csr
   
   wire [`CPU6_XLEN-1:0] csr_write_datM;
   wire [`CPU6_XLEN-1:0] csr_datM;
   
   //assign csr_write_datM = csr_rs1M;

   // todo
   assign csr_datM = (csr_rs1uimmM == `CPU6_CSR_RS1) ? csr_rs1M:
		                                       csr_rs1idx_uimmM; // zero extend to CPU6_XLEN
		                                       
   assign csr_write_datM = (csr_wscM == `CPU6_CSR_WSC_C) ? (~csr_datM) :
			                                   csr_datM;
   
   cpu6_csr csr(
      .clk           (clk  ),
      .reset         (reset),
      .csr_rd_en     (csr_rd_enM),
      .csr_wr_en     (csr_wr_enM),
      .csr_idx       (csr_idxM),
      .csr_read_dat  (csr_read_datM),
      .csr_write_dat (csr_write_datM)
      );

   // 
   // csrM, csr_wcsM, csr_read_datM,
   // according to csrM, csr_wcsM, detemine what should put into rdM
   //
   // for csrrw, csr_read_datM --> rdM
   
   
   assign dataaddrM = aluoutM;
       
   // memtoreg: 1 means it's a LW, data comes from memory,
   // otherwise the alu_mem comes from ALU
   // LW: load data from memory to rd.  add rd, rs1, rs2: ALU output to rd
   // this should be in WB, now, mark it as in MEM
   //cpu6_mux2#(`CPU6_XLEN) resmux(aluoutM, readdataM, memtoregM, alu_memM);
   
   // if 1==jumpE, this is a jump instruction, pc+4=>rd
   // if 0==jumpE, rd either comes from alu (e.g add) or mem (LW instruction)
   //cpu6_mux2#(`CPU6_XLEN) jumpmux(alu_memM, pcplus4M, jumpM, rdM);


   assign rdM = csrM      ? csr_read_datM  :
		jumpM     ? pcplus4M       :
		memtoregM ? readdataM      :
		            aluoutM        ;



   
//   
//  pipeline MEMWB

   cpu6_pipelinereg_memwb pipeline_memwb(~clk, reset,
      1'b0,
      regwriteM,
      writeregM,
      rdM,
      regwriteW,
      writeregW,
      rdW);
      
//    
endmodule // cpu6_datapath
