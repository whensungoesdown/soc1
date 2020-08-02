`include "defines.v"

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

// Verilog module DFF with Load-enable, no reset	

module cpu6_dffl # ( parameter DW = 32) (
	input  lden,
	input  [DW-1:0] dnxt,
	output [DW-1:0] qout,
	input  clk
);
	reg [DW-1:0] qout_r;
	
	always @(posedge clk)
	begin : dffl_proc
		if (lden == 1'b1)
			qout_r <= #1 dnxt;
	end
	
	assign qout = qout_r;

endmodule

module cpu6_dfflr # ( parameter DW = 32) (
	input  lden,
	input  [DW-1:0] dnxt,
	output [DW-1:0] qout,
	input  clk,
	input  rst
);
	reg [DW-1:0] qout_r;
	
	always @(posedge clk or posedge rst)
	begin : dffl_proc
		if (rst == 1'b1)
			qout_r <= {DW{1'b0}};
		else if (lden == 1'b1)
			qout_r <= #1 dnxt;
	end
	
	assign qout = qout_r;

endmodule

module cpu6_dffr # (parameter DW = 32) (
	input  [DW-1:0] dnxt,
	output [DW-1:0] qout,
	
	input  clk,
	input  rst
);

reg [DW-1:0] qout_r;

always @(posedge clk or posedge rst)
begin : DFFR_PROC
	if (rst == 1'b1)
		qout_r <= {DW{1'b0}};
	else
		qout_r <= #1 dnxt;
end

assign qout = qout_r;

endmodule
