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

cd test5_csrrw
./simulate.sh | grep simulation
cd ..

cd test6_2x_csrrw
./simulate.sh | grep simulation
cd ..

cd test7_csrrs
./simulate.sh | grep simulation
cd ..

cd test8_csrrc
./simulate.sh | grep simulation
cd ..

cd test9_csrrwi
./simulate.sh | grep simulation
cd ..

cd test10_csrrsi
./simulate.sh | grep simulation
cd ..

cd test11_csrrci
./simulate.sh | grep simulation
cd ..
