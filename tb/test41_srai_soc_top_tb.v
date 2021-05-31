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
	 //dut.u_uart.urx.rx_data_fresh <= 0; #140; dut.u_uart.urx.rx_data_fresh <= 1;
      end

   // generate clock to sequence tests
   always
      begin
	 clk <= 1; #5 ;clk <= 0; #5;
	 //dut.u_uart.urx.rx_data_fresh <= 1; #20; dut.u_uart.urx.rx_data_fresh <= 0; #20;
      end

   // check results
   always @(posedge clk)
      begin
	 if (1'b1 === dut.cpu_clk)
		begin
	    	$display("+");
	      // $display("lic.mtime %d", dut.u_lic.mtime_dfflr.qout);
	      // $display("lic.mtimecmp %d", dut.u_lic.mtimecmp_dfflr.qout);
	      // $display("csr.mie %x", dut.core.dp.csr.csr_mie);
	      // $display("csr.mtie_r %x", dut.core.dp.csr.csr_mtie_r);
	      // $display("lic.lic_timer_interrupt %x", dut.u_lic.lic_timer_interrupt);
	      // $display("excp.excp_flush_pc_ena %x", dut.core.excp.excp_flush_pc_ena);
	      // $display("excp.excp_flush_pc %x", dut.core.excp.excp_flush_pc);
	      // $display("core.pcnextF %x", dut.core.pcnextF);
	      // $display("core.pcreg %x", dut.core.pcreg.qout);
	      // $display("core.stallF %x", dut.core.stallF);
	       $display("core.alusrcE %x", dut.core.alusrcE);
	       $display("dp.alusrcE %x", dut.core.dp.alusrcE);
		end
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
	       $display("reg[4] %x", dut.core.dp.rf.regs[4].other_regs.rf_dffl.qout);
	       $display("reg[5] %x", dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout);
	       $display("reg[6] %x", dut.core.dp.rf.regs[6].other_regs.rf_dffl.qout);
	       $display("reg[7] %x", dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout);
	       $display("reg[8] %x", dut.core.dp.rf.regs[8].other_regs.rf_dffl.qout);
	       $display("reg[9] %x", dut.core.dp.rf.regs[9].other_regs.rf_dffl.qout);
	       $display("mepc %x", dut.core.dp.csr.epc_dfflr.qout);
	       $display("dp.pcE %x", dut.core.dp.pcE);
	       $display("dp.core.excp_illinstr %x", dut.core.excp_illinstr);
	       $display("lic.mtime %d", dut.u_lic.mtime_dfflr.qout);
	       $display("lic.mtimecmp %d", dut.u_lic.mtimecmp_dfflr.qout);
	       $display("csr.mie %x", dut.core.dp.csr.csr_mie);
	       $display("csr.mtie_r %x", dut.core.dp.csr.csr_mtie_r);
	       $display("lic.lic_timer_interrupt %x", dut.u_lic.lic_timer_interrupt);
	       $display("excp.excp_flush_pc_ena %x", dut.core.excp.excp_flush_pc_ena);
	       $display("excp.excp_flush_pc %x", dut.core.excp.excp_flush_pc);
	       $display("core.pcnextF %x", dut.core.pcnextF);
	       $display("core.pcF %x", dut.core.pcF);
	       $display("core.tmr_irq_r %x", dut.core.tmr_irq_r);
	       $display("core.ext_irq_r %x", dut.core.ext_irq_r);
	       $display("csr.mstatus.mie %x", dut.core.dp.csr.csr_mstatus_mie_r);
	       $display("dp.alu.control %x", dut.core.dp.alu.control);
	       $display("dp.shft_enE %x", dut.core.dp.shft_enE);
	       $display("dp.shft_lrE %x", dut.core.dp.shft_lrE);
	       $display("dp.shft_outE %x", dut.core.dp.shft_outE);
	       $display("dp.rs2forwardE %x", dut.core.dp.rs2forwardE);
	       $display("dp.rs2_immE %x", dut.core.dp.rs2_immE);
	       $display("core.alusrcE %x", dut.core.alusrcE);
	       $display("dp.alusrcE %x", dut.core.dp.alusrcE);
	       $display("dp.shft.shift16 %x", dut.core.dp.shft.shift16);
	       $display("dp.shft.shift4 %x", dut.core.dp.shft.shift4);
	       $display("dp.shft.shift1 %x", dut.core.dp.shft.shift1);
	       //$display("dp.shft.shift16[0] %x", dut.core.dp.shft.shift16[0]);
	       //$display("dp.shft.shift16[1] %x", dut.core.dp.shft.shift16[1]);
	       //$display("dp.shft.shift4[0] %x", dut.core.dp.shft.shift4[0]);
	       //$display("dp.shft.shift4[1] %x", dut.core.dp.shft.shift4[1]);
	       //$display("dp.shft.shift4[2] %x", dut.core.dp.shft.shift4[2]);
	       //$display("dp.shft.shift4[3] %x", dut.core.dp.shft.shift4[3]);
	       //$display("dp.shft.shift1[0] %x", dut.core.dp.shft.shift1[0]);
	       //$display("dp.shft.shift1[1] %x", dut.core.dp.shft.shift1[1]);
	       //$display("dp.shft.shift1[2] %x", dut.core.dp.shft.shift1[2]);
	       //$display("dp.shft.shift1[3] %x", dut.core.dp.shft.shift1[3]);
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



		if (32'h00000020 == dut.pc) 
		  begin
		     if (32'h0000002f == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000024 == dut.pc) 
		  begin
		     if (32'h00000002 == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end


		if (32'h00000030 == dut.pc) 
		  begin
		     if (32'hffff0f2f == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000034 == dut.pc) 
		  begin
		     if (32'hfffff0f2 == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000044 == dut.pc) 
		  begin
		     if (32'hfff87978 == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000048 == dut.pc) 
		  begin
		     if (32'hfffc3cbc == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000058 == dut.pc) 
		  begin
		     if (32'hfff0f2f0 == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h0000005c == dut.pc) 
		  begin
		     if (32'hfff0f2f0 == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h0000006c == dut.pc) 
		  begin
		     if (32'hffff8797 == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000070 == dut.pc) 
		  begin
		     if (32'hfffffc3c == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000080 == dut.pc) 
		  begin
		     if (32'hfffffff0 == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end


		if (32'h00000084 == dut.pc) 
		  begin
		     if (32'hffffffff == dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h00000094 == dut.pc) 
		  begin
		     if (32'hffffffff == dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test41_srai simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end

		if (32'h0000009c == dut.pc) 
		  begin
		     if (32'h00000000 == dut.core.dp.rf.regs[6].other_regs.rf_dffl.qout)
			begin
			   $display("test41_srai simulation SUCCESS");
			   $stop;
			end
		     else
			begin
			   $display("test41_srai simulation FAILED");
			   $stop;
			end
		  end
	       //if (32'h00000115 == dut.u_lic.mtime_dfflr.qout) $stop; 	

	    end

      end
endmodule
