#!/bin/bash
echo run tests

cd test1_addi
./simulate.sh | grep simulation
cd ..

cd test2_addi_cpu_clk_initial_1
./simulate.sh | grep simulation
cd ..

cd test3_bigloop
./simulate.sh | grep simulation
cd ..

cd test4_exception_illegal_instruction
./simulate.sh | grep simulation
cd ..
