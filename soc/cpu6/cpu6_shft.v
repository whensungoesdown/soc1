`include "defines.v"

module cpu6_shft(
   input  [`CPU6_XLEN-1:0] rs1_data,
   input  [`CPU6_XLEN-1:0] rs2_data,
   input  shft_lr, // 0: left shift, 1: right shift
   input  shft_la, // 0: logical shift, 1: arithmetic shift 
   output [`CPU6_XLEN-1:0] shft_out 
   );

   wire [1:0] shift16; // [16, 0] shift
   wire [3:0] shift4;  // [12, 8, 4, 0] shift
   wire [3:0] shift1;  // [3, 2, 1, 0] shift


   wire [15:0] extendbit;
   
   wire [`CPU6_XLEN-1:0] rshifterinput;
   wire [`CPU6_XLEN-1:0] rshifterinput_b1;

   wire [`CPU6_XLEN-1:0] lshifterinput;
   wire [`CPU6_XLEN-1:0] lshifterinput_b1;

   wire [`CPU6_XLEN-1:0] lshift16;
   wire [`CPU6_XLEN-1:0] rshift16;
   wire [`CPU6_XLEN-1:0] lshift4;
   wire [`CPU6_XLEN-1:0] rshift4;
   wire [`CPU6_XLEN-1:0] lshift1;
   wire [`CPU6_XLEN-1:0] rshift1;

   // buffered output of the respective mux
   wire [`CPU6_XLEN-1:0] rshift16_b1;
   wire [`CPU6_XLEN-1:0] rshift4_b1;

   wire [`CPU6_XLEN-1:0] lshift16_b1;
   wire [`CPU6_XLEN-1:0] lshift4_b1;
   

   assign extendbit = {16{shft_la & rs1_data[31]}};

   assign rshifterinput[31:0] = rs1_data[31:0];
   assign lshifterinput[31:0] = rs1_data[31:0];
				
   assign shift16[1] = rs2_data[4];
   assign shift16[0] = ~rs2_data[4];

   assign shift4[0] = (~rs2_data[3] & ~rs2_data[2]);
   assign shift4[1] = (~rs2_data[3] &  rs2_data[2]);
   assign shift4[2] = ( rs2_data[3] & ~rs2_data[2]);
   assign shift4[3] = ( rs2_data[3] &  rs2_data[2]);

   assign shift1[0] = (~rs2_data[1] & ~rs2_data[0]);
   assign shift1[1] = (~rs2_data[1] &  rs2_data[0]);
   assign shift1[2] = ( rs2_data[1] & ~rs2_data[0]);
   assign shift1[3] = ( rs2_data[1] &  rs2_data[0]);


   // mux betweenn left and right

   dp_mux2es #(32) mux_shiftout(
      .dout(shft_out[31:0]  ),
      .in0 (lshift1[31:0]   ),
      .in1 (rshift1[31:0]   ),
      .sel (shft_lr         )
      );

   // right shift muxes
   mux2ds #(32) mux_right16(
      .dout  (rshift16[31:0]        ),
      .in0   ({extendbit[15:0], rshifterinput_b1[31:16]}),
      .in1   (rshifterinput_b1[31:0]),
      .sel0  (shift16[1]            ),
      .sel1  (shift16[0]            )   
      );


   mux4ds #(32) mux_right4(
      .dout  (rshift4[31:0]         ),
      .in0   ({extendbit[15: 4], rshift16_b1[31:12]}),
      .in1   ({extendbit[15: 8], rshift16_b1[31: 8]}),
      .in2   ({extendbit[15:12], rshift16_b1[31: 4]}),
      .in3   (rshift16_b1[31:0] ),
      .sel0  (shift4[3]         ),
      .sel1  (shift4[2]         ),
      .sel2  (shift4[1]         ),
      .sel3  (shift4[0]         )
      );

   mux4ds #(32) mux_right1 (
      .dout  (rshift1[31:0]          ),
      .in0   ({extendbit[15:13], rshift4_b1[31:3]}),
      .in1   ({extendbit[15:14], rshift4_b1[31:2]}),
      .in2   ({extendbit[15], rshift4_b1[31:1]}),
      .in3   (rshift4_b1[31:0]  ),
      .sel0  (shift1[3]         ),
      .sel1  (shift1[2]         ),
      .sel2  (shift1[1]         ),
      .sel3  (shift1[0]         )
      );

   // buffer signals to right muxes

   dp_buffer #(32) buf_rshiftin(
      .dout (rshifterinput_b1[31:0] ),
      .in   (rshifterinput[31:0]    )
      );
   dp_buffer #(32) buf_rshift16(
      .dout (rshift16_b1[31:0] ),
      .in   (rshift16[31:0]    )
      );
   dp_buffer #(32) buf_rshift4(
      .dout (rshift4_b1[31:0]  ),
      .in   (rshift4[31:0]     )
      );

   
   // left shift muxes
   mux2ds #(32) mux_left16(
      .dout  (lshift16[31:0]                      ),
      .in0   ({lshifterinput_b1[15:0], {16{1'b0}}}),
      .in1   (lshifterinput_b1[31:0]              ),
      .sel0  (shift16[1]                          ),
      .sel1  (shift16[0]                          )
      );

   mux4ds #(32) mux_left4(
      .dout  (lshift4[31:0]                       ),
      .in0   ({lshift16_b1[19:0], {12{1'b0}}}    ),
      .in1   ({lshift16_b1[23:0], {8{1'b0}}}      ),
      .in2   ({lshift16_b1[27:0], {4{1'b0}}}      ),
      .in3   (lshift16_b1[31:0]                   ),
      .sel0  (shift4[3]                           ),
      .sel1  (shift4[2]                           ),
      .sel2  (shift4[1]                           ),
      .sel3  (shift4[0]                           )
      );

   mux4ds #(32) mux_left1(
      .dout  (lshift1[31:0]                       ),
      .in0   ({lshift4_b1[28:0], {3{1'b0}}}       ),
      .in1   ({lshift4_b1[29:0], {2{1'b0}}}       ),
      .in2   ({lshift4_b1[30:0], {1{1'b0}}}       ),
      .in3   (lshift4_b1[31:0]                    ),
      .sel0  (shift1[3]                           ),
      .sel1  (shift1[2]                           ),
      .sel2  (shift1[1]                           ),
      .sel3  (shift1[0]                           )
      );

   // buffer signals to left muxes
   
   dp_buffer #(32) buf_lshiftin(
      .dout  (lshifterinput_b1[31:0] ),
      .in    (lshifterinput[31:0]    )
      );
   dp_buffer #(32) buf_lshift16(
      .dout  (lshift16_b1[31:0]      ),
      .in    (lshift16[31:0]         )
      );
   dp_buffer #(32) buf_lshift4(
      .dout  (lshift4_b1[31:0]       ),
      .in    (lshift4[31:0]          )
      );
   
endmodule // cpu6_shft
