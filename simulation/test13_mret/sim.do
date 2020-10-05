# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
add wave dut.pc
add wave dut.cpu_clk
add wave dut.dataaddr
add wave dut.writedata
add wave dut.memwrite
add wave dut.vgaram_en
run 20ms

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
