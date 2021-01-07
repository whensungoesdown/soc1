`include "cpu6/defines.v"

module soc_top (
   input  clk,
   input  reset,
   output [2:0] vga_rgb,
   output vga_hsync,
   output vga_vsync,
   input  uart_rxd,
   output uart_txd
   );
   
   reg cpu_clk;
   reg vga_clk;
   
   
   always @(posedge clk)
      begin
	 cpu_clk = ~cpu_clk;
	 vga_clk = ~vga_clk;
      end
   
   wire [`CPU6_XLEN-1:0] pc;
   wire [`CPU6_XLEN-1:0] instr;
   wire [`CPU6_XLEN-1:0] ram_readdata;
   wire [`CPU6_XLEN-1:0] readdata;

   wire [`CPU6_XLEN-1:0] dataaddr;
   wire [`CPU6_XLEN-1:0] writedata;
   wire memwrite;

   wire lic_timer_interrupt;
   wire ext_irq_r;
   
   // instantiate processor and memories
   //cpu6_core core(cpu_clk, !reset, pc, instr, memwrite,
   //   dataaddr, writedata, readdata, lic_timer_interrupt);

   cpu6_core core (
      .clk           (cpu_clk       ),
      .reset         (!reset        ),
      .pcF           (pc            ),
      .instr         (instr         ),
      .memwriteM     (memwrite      ),
      .dataaddr      (dataaddr      ),
      .writedata     (writedata     ),
      .readdata      (readdata      ),
      
      .tmr_irq_r     (lic_timer_interrupt),
      .ext_irq_r     (ext_irq_r     )
      );

   wire vgaram_ena;
   wire device_ena;
   wire ram_ena;

   assign ram_ena = !vgaram_ena & !device_ena;

   // ram size 64k
   // 2-port ram, port a for instruction fetch, port b for memory read/write
   ram mem(pc[12:2], dataaddr[12:2], cpu_clk, 32'b0, writedata, 1'b0, ram_ena & memwrite, 
      instr, ram_readdata);

   //pseudo_icache icache(pc[9:2], instr);
   //pseudo_dcache dcache(clk, memwrite, dataaddr[9:2],
   //			writedata, readdata);


   //
   //  text mode 80 * 25, character 8 * 16 pixels
   //
   
   //assign vgaram_en = dataaddr[16];
   assign vgaram_ena = (dataaddr[`CPU6_XLEN-1:16] == 16'b0000000000000001);
   
   wire [8:0] vga_ramaddr_write;
   wire [`CPU6_XLEN-1:0] vga_data_write;
   
   assign vga_ramaddr_write = dataaddr[10:2];
   assign vga_data_write = writedata;
   
   text80x25 textvga (
      .clk           (vga_clk       ),
      .vga_hsync     (vga_hsync     ),
      .vga_vsync     (vga_vsync     ),
      .vga_rgb       (vga_rgb       ),

      .write_address (vga_ramaddr_write    ),
      .write_data    (vga_data_write       ),
      .write_en      (vgaram_ena & memwrite )
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
   


   wire [`CPU6_XLEN-1:0] lic_mtime_read;
   wire [`CPU6_XLEN-1:0] lic_mtime_write;
   wire lic_mtime_write_ena;
   wire [`CPU6_XLEN-1:0] lic_mtimecmp_read;
   wire [`CPU6_XLEN-1:0] lic_mtimecmp_write;
   wire lic_mtimecmp_write_ena;

   wire lic_mtime_ena;
   wire lic_mtimecmp_ena;
   
   assign device_ena = (dataaddr[`CPU6_XLEN-1:17] == 15'b000000000000001);

   assign lic_mtime_ena = (dataaddr[`CPU6_XLEN-1:0] == 32'h00020000);
   assign lic_mtime_write = writedata;
   assign lic_mtime_write_ena = (lic_mtime_ena & memwrite);
   
   assign lic_mtimecmp_ena = (dataaddr[`CPU6_XLEN-1:0] == 32'h00020008);
   assign lic_mtimecmp_write = writedata;
   assign lic_mtimecmp_write_ena = (lic_mtimecmp_ena & memwrite); 


   lic u_lic (
      .clk                    (cpu_clk     ),
      .reset                  (!reset      ),
      .lic_mtime_read         (lic_mtime_read        ),
      .lic_mtime_write        (lic_mtime_write       ),
      .lic_mtime_write_ena    (lic_mtime_write_ena   ),
      .lic_mtimecmp_read      (lic_mtimecmp_read     ),
      .lic_mtimecmp_write     (lic_mtimecmp_write    ),
      .lic_mtimecmp_write_ena (lic_mtimecmp_write_ena),
      .lic_timer_interrupt    (lic_timer_interrupt   )
      );



   //
   // uart
   //

   wire uart_ena = (dataaddr[`CPU6_XLEN-1:0] == 32'h00021000);
   wire [`CPU6_XLEN-1:0] uart_readdata;

   wire [7:0] rx_data;
   wire rx_data_fresh;
   wire [7:0] uart_rx;

   wire [7:0] tx_data;
   wire tx_data_valid;
   wire tx_data_ack;

   assign uart_readdata = {23'h0, uart_rx};

   assign tx_data = writedata[7:0];
   assign tx_data_valid = (uart_ena & memwrite);

   assign ext_irq_r = rx_data_fresh;
   
   cpu6_dfflr#(8) uart_rx_reg(
      .lden       (rx_data_fresh   ),
      .dnxt       (rx_data         ),
      .qout       (uart_rx         ),
      .clk        (cpu_clk         ),
      .rst        (!reset          )
      );
   
   uart u_uart (
      .clk          (cpu_clk      ),
      .rst          (!reset       ),
      .tx_data      (tx_data      ),
      .tx_data_valid(tx_data_valid),
      .tx_data_ack  (tx_data_ack  ),
      .txd          (uart_txd     ),
      .rx_data      (rx_data      ),
      .rx_data_fresh(rx_data_fresh),
      .rxd          (uart_rxd     )  // uty: test
      );
      


   assign readdata = lic_mtime_ena      ? lic_mtime_read      :
		     lic_mtimecmp_ena   ? lic_mtimecmp_read   :
		     uart_ena           ? uart_readdata       :
                                   // textram write only, no data read out
		     ram_readdata; // default
endmodule // top
