# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
add wave dut.pc
add wave dut.cpu_clk
add wave dut.core.dp.instrE
run 500ns

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
