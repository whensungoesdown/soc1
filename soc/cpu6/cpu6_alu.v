`include "defines.v"

module cpu6_alu (
	input  [`CPU6_XLEN-1:0] a,
	input  [`CPU6_XLEN-1:0] b,
	input  [`CPU6_ALU_CONTROL_SIZE-1:0] control,
	output [`CPU6_XLEN-1:0] y,
	output zero
	);
	
	wire control_add;
	wire control_sub;
	
	wire [`CPU6_XLEN-1:0] add_result;
	wire [`CPU6_XLEN-1:0] sub_result;
	
	
	assign control_add = (control[`CPU6_ALU_CONTROL_SIZE-1:0] == `CPU6_ALU_CONTROL_SIZE'b010);
	assign control_sub = (control[`CPU6_ALU_CONTROL_SIZE-1:0] == `CPU6_ALU_CONTROL_SIZE'b110);
	
	assign add_result = a + b;
	assign sub_result = a - b;
	
	assign y = ({`CPU6_XLEN{control_add}} & add_result)
	         | ({`CPU6_XLEN{control_sub}} & sub_result)
		    ;
		
	assign zero = (control_add & (add_result == `CPU6_XLEN'b0))
	            | (control_sub & (sub_result == `CPU6_XLEN'b0))
		       ;
	
endmodule
