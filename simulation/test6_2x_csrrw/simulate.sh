#!/bin/bash
./clean.sh > /dev/null

vlib work
vmap work work

vlib altera_mf_ver
vmap altera_mf_ver altera_mf_ver

#vlog -work altera_mf_ver -f soc1.f
vlog -f files.f

#vlog -reportprogress 300 -work altera_mf_ver ~/intelFPGA_lite/19.1/quartus/eda/sim_lib/altera_mf.v -f soc1.f

vsim -c -do sim.do soc_top_tb -wlf result.wlf
