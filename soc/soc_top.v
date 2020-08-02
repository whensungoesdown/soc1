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

	
	
	assign vgaram_en = dataaddr[16];
	
	
	// vga ram size 64k
   wire [7:0] vga_data;
   wire [15:0] vga_ramaddr;
	wire [9:0] vga_x;
	wire [9:0] vga_y;
   wire vga_display;
	
	wire [15:0] vga_ramaddr_write;
	wire [7:0] vga_data_write;
	
	assign vga_ramaddr_write = {1'b0, dataaddr[14:0]};
	assign vga_data_write = writedata[7:0];
	
	assign vga_ramaddr = {1'b0, vga_y[8:2], vga_x[9:2]};
   
   vga640x480 vga(vga_clk, vga_hsync, vga_vsync, vga_x, vga_y, vga_display);
   vgaram ram(vga_clk, vga_data_write, vga_ramaddr, vga_ramaddr_write, vgaram_en & memwrite, vga_data);

   assign vga_rgb = {3{vga_display}} & vga_data[2:0];
   
endmodule // top
