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

cd test12_exception_illinstr_mepc
./simulate.sh | grep simulation
cd ..

cd test13_mret
./simulate.sh | grep simulation
cd ..

cd test14_excp_write_mepc_finish_in_time
./simulate.sh | grep simulation
cd ..

cd test15_read_mtime
./simulate.sh | grep simulation
cd ..

cd test16_read_write_mtimecmp
./simulate.sh | grep simulation
cd ..

cd test17_read_write_mtime
./simulate.sh | grep simulation
cd ..

cd test18_read_write_csr_mie
./simulate.sh | grep simulation
cd ..

cd test19_timer
./simulate.sh | grep simulation
cd ..

cd test20_mstatus_mie
./simulate.sh | grep simulation
cd ..

cd test21_add1to4_interrupt
./simulate.sh | grep simulation
cd ..

cd test22_mip.MTIP
./simulate.sh | grep simulation
cd ..

cd test23_lui
./simulate.sh | grep simulation
cd ..

cd test24_auipc
./simulate.sh | grep simulation
cd ..
