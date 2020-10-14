`include "cpu6/defines.v"

module soc_top (
   input  clk,
   input  reset,
   output [2:0] vga_rgb,
   output vga_hsync,
   output vga_vsync
   );
   
   reg cpu_clk;
   reg vga_clk;
   
   wire vgaram_en;
   
   always @(posedge clk)
      begin
	 cpu_clk = ~cpu_clk;
	 vga_clk = ~vga_clk;
      end
   
   wire [`CPU6_XLEN-1:0] pc;
   wire [`CPU6_XLEN-1:0] instr;
   wire [`CPU6_XLEN-1:0] readdata;

   wire [`CPU6_XLEN-1:0] dataaddr;
   wire [`CPU6_XLEN-1:0] writedata;
   wire memwrite;
   
   // instantiate processor and memories
   cpu6_core core(cpu_clk, !reset, pc, instr, memwrite,
      dataaddr, writedata, readdata);


   // ram size 64k
   // 2-port ram, port a for instruction fetch, port b for memory read/write
   ram mem(pc[12:2], dataaddr[12:2], cpu_clk, 32'b0, writedata, 1'b0, !vgaram_en & memwrite, 
      instr, readdata);

   //pseudo_icache icache(pc[9:2], instr);
   //pseudo_dcache dcache(clk, memwrite, dataaddr[9:2],
   //			writedata, readdata);


   //
   //  text mode 80 * 25, character 8 * 16 pixels
   //
   
   assign vgaram_en = dataaddr[16];
   
   wire [10:0] vga_ramaddr_write;
   wire [7:0] vga_data_write;
   
   assign vga_ramaddr_write = dataaddr[10:0];
   assign vga_data_write = writedata[7:0];
   
   text80x25 textvga (
      .clk           (vga_clk       ),
      .vga_hsync     (vga_hsync     ),
      .vga_vsync     (vga_vsync     ),
      .vga_rgb       (vga_rgb       ),

      .write_address (vga_ramaddr_write    ),
      .write_data    (vga_data_write       ),
      .write_en      (vgaram_en & memwrite )
      );
  

 
   // vga ram size 64k

//   assign vgaram_en = dataaddr[16];
//   wire [7:0]  vga_data;
//   wire [15:0] vga_ramaddr;
//   wire [9:0]  vga_x;
//   wire [9:0]  vga_y;
//   wire vga_display;
//   
//   wire [15:0] vga_ramaddr_write;
//   wire [7:0] vga_data_write;
//   
//   assign vga_ramaddr_write = {1'b0, dataaddr[14:0]};
//   assign vga_data_write = writedata[7:0];
//   
//   assign vga_ramaddr = {1'b0, vga_y[8:2], vga_x[9:2]};
//   
//   vga640x480 vga(
//      .clk            (      vga_clk),
//      .vga_h_sync     (    vga_hsync),
//      .vga_v_sync     (    vga_vsync),
//      .inDisplayArea  (  vga_display),
//      .CounterX       (        vga_x),
//      .CounterY       (        vga_y)
//      );
//   
//   vgaram ram(vga_clk, vga_data_write, vga_ramaddr, vga_ramaddr_write, vgaram_en & memwrite, vga_data);
//
//   assign vga_rgb = {3{vga_display}} & vga_data[2:0];
   
endmodule // top
