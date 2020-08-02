`include "defines.v"

module cpu6_immdec (
   input  [`CPU6_XLEN-1:0] instr,
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] immtype,
   output [`CPU6_XLEN-1:0] signimm
   );

   
   wire [`CPU6_XLEN-1:0] i_imm = {
			{`CPU6_XLEN-`CPU6_I_IMM_SIZE{instr[`CPU6_I_IMM_HIGH]}},
			instr[`CPU6_I_IMM_HIGH:`CPU6_I_IMM_LOW]
			};

   wire [`CPU6_XLEN-1:0] s_imm = {
			{`CPU6_XLEN-`CPU6_S_IMM_SIZE{instr[`CPU6_S_IMM2_HIGH]}},
			instr[`CPU6_S_IMM2_HIGH:`CPU6_S_IMM2_LOW],
			instr[`CPU6_S_IMM1_HIGH:`CPU6_S_IMM1_LOW]
			};

   wire [`CPU6_XLEN-1:0] b_imm = {
			 {`CPU6_XLEN-`CPU6_B_IMM_SIZE{instr[`CPU6_B_IMM_BIT12]}},
			 instr[`CPU6_B_IMM_BIT12],
			 instr[`CPU6_B_IMM_BIT11],
			 instr[`CPU6_B_IMM2_HIGH:`CPU6_B_IMM2_LOW],
			 instr[`CPU6_B_IMM1_HIGH:`CPU6_B_IMM1_LOW]
			 };

   assign signimm = ({`CPU6_XLEN{immtype == `CPU6_IMMTYPE_I}} & i_imm)
                  | ({`CPU6_XLEN{immtype == `CPU6_IMMTYPE_S}} & s_imm)
                  | ({`CPU6_XLEN{immtype == `CPU6_IMMTYPE_B}} & b_imm)
		     ;

endmodule // cpu6_immdec

