`include "../soc/cpu6/defines.v"

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module soc_top_tb();

   reg clk;
   reg reset;

   wire [2:0] vga_rgb;
   wire vga_hsync;
   wire vga_vsync;

   //wire [`CPU6_XLEN-1:0] writedata, dataadr;
   //wire memwrite;

   // instantiate device to be tested
   soc_top dut(clk, reset, vga_rgb, vga_hsync, vga_vsync);

   // initialize test
   initial
      begin
	 $display("Start ...");
	 dut.cpu_clk = 0;
	 dut.vga_clk = 0;
	 reset <= 0; #22; reset <= 1;
      end

   // generate clock to sequence tests
   always
      begin
	 clk <= 1; #5 ;clk <= 0; #5;
      end

   // check results
   always @(posedge clk)
      begin
	 if (1'b1 === dut.cpu_clk)
	    $display("+");
      end
   
   always @(negedge clk)
      begin
	 if (1'b0 === dut.cpu_clk)
	    begin
	       $display("-");
	       $display("reset %b", reset);
	       $display("cpu_clk %b", dut.cpu_clk);
	       $display("pc %x", dut.pc);
	       $display("vga_rgb %b", vga_rgb);
	       $display("reg[1] %x", dut.core.dp.rf.regs[1].other_regs.rf_dffl.qout);
	       $display("reg[2] %x", dut.core.dp.rf.regs[2].other_regs.rf_dffl.qout);
	       $display("reg[3] %x", dut.core.dp.rf.regs[3].other_regs.rf_dffl.qout);
	       $display("dp.regwriteM %x", dut.core.dp.regwriteM);
	       $display("dp.writeregM %x", dut.core.dp.writeregM);
	       $display("dp.rdM %x", dut.core.dp.rdM);
	       $display("dp.regwriteW %x", dut.core.dp.regwriteW);
	       $display("dp.writeregW %x", dut.core.dp.writeregW);
	       $display("dp.rdW %x", dut.core.dp.rdW);
	       $display("dp.hazardunit.rs1idxE %x", dut.core.dp.hazardunit.rs1idxE);
	       $display("dp.rs1forwardE %x", dut.core.dp.rs1forwardE);
	       $display("csr.csr_idx %x", dut.core.dp.csr.csr_idx);
	       $display("csr.csr_read_dat %x", dut.core.dp.csr.csr_read_dat);
	       $display("csr.csr_write_dat %x", dut.core.dp.csr.csr_write_dat);
	       $display("mepc %x", dut.core.dp.csr.epc_dfflr.qout);
	       //$display("reg[5] %x", dut.core.dp.rf.rf_r[5]);
	       // if (memwrite) begin
	       //     if (dataadr === 84 & writedata === 7) begin
	       //         $display("Simulation succeeded");
	       //         $stop;
	       //     end else if (dataadr !== 80) begin
	       //         $display("Simulation failed");
	       //         $stop;
	       //     end
	       // end    

	       if (32'h0000001c === dut.pc) 	
		  begin
		     if (32'hffffffee === dut.core.dp.csr.epc_dfflr.qout)
			begin
			   //$display("test8_csrrc simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test8_csrrc simulation FAILED");
			   $stop;
			end
		  end

	       if (32'h00000030 === dut.pc) 	
		  begin
		     if (32'hffffffee === dut.core.dp.rf.regs[3].other_regs.rf_dffl.qout
			&& 32'hffffffee === dut.core.dp.csr.epc_dfflr.qout)
			begin
			   $display("test8_csrrc simulation SUCCESS");
			   $stop;
			end
		     else
			begin
			   $display("test7_csrrc simulation FAILED");
			   $stop;
			end
		  end

	    end

      end
endmodule
