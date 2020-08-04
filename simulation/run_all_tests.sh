#!/bin/bash
echo run tests

cd test1_addi
./simulate.sh | grep simulation
cd ..

cd test2_addi_cpu_clk_initial_1
./simulate.sh | grep simulation
cd ..
