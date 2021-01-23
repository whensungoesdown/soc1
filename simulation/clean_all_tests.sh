#!/bin/bash
echo run tests

cd test1_addi
./clean.sh
cd ..

cd test2_addi_cpu_clk_initial_1
./clean.sh
cd ..

cd test3_bigloop
./clean.sh
cd ..

cd test4_exception_illegal_instruction
./clean.sh
cd ..

cd test5_csrrw
./clean.sh
cd ..

cd test6_2x_csrrw
./clean.sh
cd ..

cd test7_csrrs
./clean.sh
cd ..

cd test8_csrrc
./clean.sh
cd ..

cd test9_csrrwi
./clean.sh
cd ..

cd test10_csrrsi
./clean.sh
cd ..

cd test11_csrrci
./clean.sh
cd ..

cd test12_exception_illinstr_mepc
./clean.sh
cd ..

cd test13_mret
./clean.sh
cd ..

cd test14_excp_write_mepc_finish_in_time
./clean.sh
cd ..

cd test15_read_mtime
./clean.sh
cd ..

cd test16_read_write_mtimecmp
./clean.sh
cd ..

cd test17_read_write_mtime
./clean.sh
cd ..

cd test18_read_write_csr_mie
./clean.sh
cd ..

cd test19_timer
./clean.sh
cd ..

cd test20_mstatus_mie
./clean.sh
cd ..

cd test21_add1to4_interrupt
./clean.sh
cd ..

cd test22_mip.MTIP
./clean.sh
cd ..

cd test23_lui
./clean.sh
cd ..

cd test24_auipc
./clean.sh
cd ..

cd test25_andi
./clean.sh
cd ..
