# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
add wave dut.pc
add wave dut.cpu_clk
add wave dut.core.dp.regwriteM 
add wave dut.core.dp.writeregM
add wave dut.core.dp.rdM 
add wave dut.core.dp.csrM
add wave dut.core.dp.csr_rd_enM 
add wave dut.core.dp.csr_read_datM
add wave dut.core.dp.csr.epc_dfflr.qout
add wave dut.core.dp.regwriteW 
add wave dut.core.dp.writeregW
add wave dut.core.dp.rdW 
run 20ms

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
