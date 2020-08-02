`include "../hdl/defines.v"

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module top_tb();

    reg clk;
    reg reset;

    //wire [`CPU6_XLEN-1:0] writedata, dataadr;
    //wire memwrite;

    // instantiate device to be tested
    top dut(clk, reset);

    // initialize test
    initial
    begin
      $display("Start ...");
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
