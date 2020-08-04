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
      	dut.cpu_clk = 1;
	dut.vga_clk = 1;
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
        $display("+");
    end
    
    always @(negedge clk)
    begin
        $display("-");
	$display("pc %x", dut.pc);
	$display("vga_rgb %b", vga_rgb);
	$display("cpu_clk %b", dut.cpu_clk);
        // if (memwrite) begin
        //     if (dataadr === 84 & writedata === 7) begin
        //         $display("Simulation succeeded");
        //         $stop;
        //     end else if (dataadr !== 80) begin
        //         $display("Simulation failed");
        //         $stop;
        //     end
        // end    
    end
endmodule
