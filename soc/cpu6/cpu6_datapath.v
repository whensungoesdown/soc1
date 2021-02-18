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
		      input  [`CPU6_ALUCONTROL_SIZE-1:0] alucontrolE,
                      input  [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
		      input  [`CPU6_XLEN-1:0] pcE,
                      output [`CPU6_XLEN-1:0] pcnextE,
                      output pcsrcE,
		      input  [`CPU6_XLEN-1:0] instrE,


                      input  [`CPU6_LSWIDTH_SIZE-1:0] lswidthE,
                      input  loadsignextE,

                      input  luiE, // instruction lui
                      input  auipcE, // instruction auipc
                      input  [`CPU6_XLEN-1:0] pc_auipcE, // pcE value for auipc instruction
                      // csr
                      input  csrE, // csr enable
                      input  csr_rs1uimmE, // uimm: rs1 field as uimm
                      input  [`CPU6_CSR_WSC_SIZE-1:0] csr_wscE, // CSRRW CSRRS CSRRC
   
                      output [`CPU6_XLEN-1:0] csr_mtvec,
                      output [`CPU6_XLEN-1:0] csr_mepc,
                      
                      input  [`CPU6_XLEN-1:0] excp_mepc,
                      input  excp_mepc_ena,
                      
                      // empty pipeline req ack
                      input  empty_pipeline_reqE,
                      output empty_pipeline_ackW,
                      //
  
		      output [`CPU6_XLEN-1:0] dataaddrM,
		      output [`CPU6_XLEN-1:0] writedataM,
		      input  [`CPU6_XLEN-1:0] readdata_rawM,
                      output memwriteM,

                      input  tmr_irq_r,
                      input  ext_irq_r,
                      output csr_mtie_r,
                      output csr_meie_r,
                      output csr_mstatus_mie_r,
                      input  mret_ena,

                      input  shft_enE,
                      input  shft_lrE
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
   wire [`CPU6_XLEN-1:0] alushftoutM;
   wire [`CPU6_RFIDX_WIDTH-1:0] writeregM;
   wire regwriteM;
   wire memtoregM;
   wire [`CPU6_XLEN-1:0] pcplus4M;
   wire jumpM;
   
   //wire [`CPU6_XLEN-1:0] alu_memM;
   wire [`CPU6_XLEN-1:0] rdM;

   wire [`CPU6_LSWIDTH_SIZE-1:0] lswidthM;
   wire loadsignextM;

   
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
   cpu6_mux2#(`CPU6_XLEN) srcbmux(
      .d0     (        forwardrs2_rs2E),
      .d1     (               signimmE),
      .s      (                alusrcE),
      .y      (               rs2_immE)
      );
   

   // too many mux, should be a better way

   wire [`CPU6_XLEN-1:0] forwardrs1_rs1_zeroE;
   wire [`CPU6_XLEN-1:0] forwardrs1_rs1_zero_pcE;

   cpu6_mux2#(`CPU6_XLEN) luimux(
      .d0     (forwardrs1_rs1E     ),
      .d1     (`CPU6_XLEN'b0       ),
      .s      (luiE                ),
      .y      (forwardrs1_rs1_zeroE)
      );
   
   cpu6_mux2#(`CPU6_XLEN) auipcmux(
      .d0     (forwardrs1_rs1_zeroE    ),
      .d1     (pc_auipcE               ), // pcE changes at the falling edge, due to the way that impements branch
      .s      (auipcE                  ),
      .y      (forwardrs1_rs1_zero_pcE )
      );

   
   cpu6_alu alu(
      //.a      (        forwardrs1_rs1E),
      .a      (forwardrs1_rs1_zero_pcE),
      .b      (rs2_immE               ),
      .control(alucontrolE            ),
      .y      (aluoutE                ),
      .zero   (zeroE                  )
      );

   wire [`CPU6_XLEN-1:0] alushftoutE;
   wire [`CPU6_XLEN-1:0] shft_outE;

   

   cpu6_shft shft(
      .rs1_data    (forwardrs1_rs1_zero_pcE),  // use the same as alu does
      .rs2_data    (rs2_immE               ),
      .shft_lr     (shft_lrE               ),
      .shft_out    (shft_outE              )
      );


   cpu6_mux2 #(`CPU6_XLEN) alushftmux(
      .d0  (aluoutE      ),
      .d1  (shft_outE    ),
      .s   (shft_enE     ),
      .y   (alushftoutE  )
      );
   
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


   wire empty_pipeline_reqM;
   
//
// pipeline EXMEM
   
   cpu6_pipelinereg_exmem pipelinereg_exmem(
      .clk                  (~clk  ), 
      .reset                (reset ),
      .flashM               (1'b0  ),
      
      .lswidthE             (lswidthE           ),
      .loadsignextE         (loadsignextE       ),
      
      .memwriteE            (memwriteE ),
      .writedataE           (writedataE),
      .alushftoutE          (alushftoutE        ), // used in MEM, but also pass to WB
      .writeregE            (writeregE          ), // not used in MEM, pass to WB
      .regwriteE            (regwriteE          ), // not used in MEM, pass to WB
      .memtoregE            (memtoregE          ), // not used in MEM, pass to WB
      .pcplus4E             (pcplus4E           ),  // used in MEM, jump need pc+4 in the very last, write to rd
      .jumpE                (jumpE              ),     // used in MEM
      // for csr
      .csrE                 (csrE      ),
      .csr_wscE             (csr_wscE  ),
      .csr_rs1uimmE         (csr_rs1uimmE    ), // use 'rs1' or 'rs1idx as uimm'
      .forwardrs1_rs1E      (forwardrs1_rs1E ),
      .csr_rs1idx_uimmE     (csr_rs1idx_uimmE),
      .csr_rd_enE           (csr_rd_enE      ),
      .csr_wr_enE           (csr_wr_enE      ),
      .csr_idxE             (csr_idxE        ),
      //
      .empty_pipeline_reqE  (empty_pipeline_reqE),
      
      .lswidthM             (lswidthM           ),
      .loadsignextM         (loadsignextM       ),
      
      .memwriteM            (memwriteM          ),
      .writedataM           (writedataM         ),
      .alushftoutM          (alushftoutM        ),
      .writeregM            (writeregM          ),
      .regwriteM            (regwriteM          ),
      .memtoregM            (memtoregM          ),
      .pcplus4M             (pcplus4M           ),
      .jumpM                (jumpM              ),
      // for csr
      .csrM                 (csrM            ),
      .csr_wscM             (csr_wscM        ),
      .csr_rs1uimmM         (csr_rs1uimmM    ), // use 'rs1' or 'rs1idx as uimm'
      .csr_rs1M             (csr_rs1M        ), // solved data hazard
      .csr_rs1idx_uimmM     (csr_rs1idx_uimmM),
      .csr_rd_enM           (csr_rd_enM      ),
      .csr_wr_enM           (csr_wr_enM      ),
      .csr_idxM             (csr_idxM        ),
      //
      .empty_pipeline_reqM  (empty_pipeline_reqM)
      );
//
//
   



   
//      
//  MEM
//



   // csr
   
   wire [`CPU6_XLEN-1:0] csr_write_datM;
   wire [`CPU6_XLEN-1:0] csr_datM;
   

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
      .csr_write_dat (csr_write_datM),

      .mret_ena          (mret_ena         ),
      
      .tmr_irq_r         (tmr_irq_r        ),
      .ext_irq_r         (ext_irq_r        ),
      .csr_mtie_r        (csr_mtie_r       ),
      .csr_meie_r        (csr_meie_r       ),
      .csr_mstatus_mie_r (csr_mstatus_mie_r),
      
      .excp_mepc     (excp_mepc     ),
      .excp_mepc_ena (excp_mepc_ena ),

      .csr_mtvec     (csr_mtvec     ),
      .csr_mepc      (csr_mepc      )
      );
   
   // 
   // csrM, csr_wcsM, csr_read_datM,
   // according to csrM, csr_wcsM, detemine what should put into rdM
   //
   // for csrrw, csr_read_datM --> rdM
   
 
   assign dataaddrM = alushftoutM;
       
   // memtoreg: 1 means it's a LW, data comes from memory,
   // otherwise the alu_mem comes from ALU
   // LW: load data from memory to rd.  add rd, rs1, rs2: ALU output to rd
   // this should be in WB, now, mark it as in MEM
   //cpu6_mux2#(`CPU6_XLEN) resmux(aluoutM, readdataM, memtoregM, alu_memM);
   
   // if 1==jumpE, this is a jump instruction, pc+4=>rd
   // if 0==jumpE, rd either comes from alu (e.g add) or mem (LW instruction)
   //cpu6_mux2#(`CPU6_XLEN) jumpmux(alu_memM, pcplus4M, jumpM, rdM);


   // todo
   wire [`CPU6_XLEN-1:0] readdataM;
   wire [`CPU6_XLEN-1:0] readdata_wM;
   wire [`CPU6_XLEN-1:0] readdata_hM;
   wire [`CPU6_XLEN-1:0] readdata_bM;
   wire [`CPU6_XLEN-1:0] readdata_huM;
   wire [`CPU6_XLEN-1:0] readdata_buM;

   wire load_wM;
   wire load_hM;
   wire load_bM;
   wire load_huM;
   wire load_buM;

   assign readdata_wM  = readdata_rawM;
   assign readdata_hM  = {{16{readdata_rawM[15]}}, readdata_rawM[15:0]}; 
   assign readdata_bM  = {{24{readdata_rawM[7]}}, readdata_rawM[7:0]}; 
   assign readdata_huM = {16'b0, readdata_rawM[15:0]}; 
   assign readdata_buM = {24'b0, readdata_rawM[7:0]}; 
   
   assign load_wM = (lswidthM == `CPU6_LSWIDTH_W);
   assign load_hM = ((lswidthM == `CPU6_LSWIDTH_H) && (loadsignextM == 1'b1));
   assign load_bM = ((lswidthM == `CPU6_LSWIDTH_B) && (loadsignextM == 1'b1));
   assign load_huM = ((lswidthM == `CPU6_LSWIDTH_H) && (loadsignextM == 1'b0));
   assign load_buM = ((lswidthM == `CPU6_LSWIDTH_B) && (loadsignextM == 1'b0));
   
   dp_mux5ds #(`CPU6_XLEN) loadwidth_mux (
      .dout (readdataM   ),
      .in0  (readdata_wM ),
      .in1  (readdata_hM ),
      .in2  (readdata_bM ),
      .in3  (readdata_huM),
      .in4  (readdata_buM),
      .sel0_l (~load_wM  ),
      .sel1_l (~load_hM  ),
      .sel2_l (~load_bM  ),
      .sel3_l (~load_huM ),
      .sel4_l (~load_buM )
      );

   assign rdM = csrM      ? csr_read_datM    :
		jumpM     ? pcplus4M         :
		memtoregM ? readdataM        :
		            alushftoutM ;



   
//   
//  pipeline MEMWB


   wire empty_pipeline_reqW;

   cpu6_pipelinereg_memwb pipeline_memwb(
      .clk           (~clk      ),
      .reset         (reset     ),
      .flashW        (1'b0      ),
      .regwriteM           (regwriteM     ),
      .writeregM           (writeregM     ),
      .rdM                 (rdM           ),
      .empty_pipeline_reqM (empty_pipeline_reqM),
      
      .regwriteW           (regwriteW     ),
      .writeregW           (writeregW     ),
      .rdW                 (rdW           ),
      .empty_pipeline_reqW (empty_pipeline_reqW)
      );

   assign empty_pipeline_ackW = empty_pipeline_reqW;
      
//    
endmodule // cpu6_datapath
