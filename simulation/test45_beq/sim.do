# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
add wave dut.pc
add wave dut.cpu_clk
add wave dut.u_lic.mtime_dfflr.qout
add wave dut.u_lic.mtimecmp_dfflr.qout
add wave dut.u_lic.lic_timer_interrupt
add wave dut.core.excp.excp_flush_pc
add wave dut.core.excp.excp_flush_pc_ena
add wave dut.core.pcnextF
add wave dut.core.pcF
add wave dut.core.stallF
add wave dut.u_uart.urx.rx_data_fresh
add wave dut.core.ext_irq_r
add wave dut.core.dp.csr.csr_mstatus_mie_r
add wave dut.cpu_clk
add wave dut.core.instr
add wave dut.core.instrF
add wave dut.core.dp.shft_enE
add wave dut.core.dp.shft_lrE
add wave dut.core.dp.shft_outE
add wave dut.core.dp.alusrcE

add wave dut.core.dp.rs2E
add wave dut.core.dp.rdM
add wave dut.core.dp.rs2forwardE

add wave dut.core.dp.forwardrs2_rs2E
add wave dut.core.dp.signimmE
add wave dut.core.dp.rs2_immE


add wave dut.core.dp.shft.rs1_data
add wave dut.core.dp.shft.rs2_data

add wave dut.core.dp.shft.shift16
add wave dut.core.dp.shft.shift4
add wave dut.core.dp.shft.shift1

add wave dut.core.excp_pc
add wave dut.core.dp.pc_auipcE
add wave dut.core.dp.pcE
add wave dut.core.pcF
add wave dut.core.pcnextF
add wave dut.core.pcsrcE
add wave dut.core.pcnextE
add wave dut.core.stallF
add wave dut.core.jump

run 20ms

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
