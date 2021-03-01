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

cd test25_andi
./simulate.sh | grep simulation
cd ..

cd test26_and
./simulate.sh | grep simulation
cd ..

cd test27_ori
./simulate.sh | grep simulation
cd ..

cd test28_or
./simulate.sh | grep simulation
cd ..

cd test29_sltiu
./simulate.sh | grep simulation
cd ..

cd test30_sltu
./simulate.sh | grep simulation
cd ..

cd test31_xori
./simulate.sh | grep simulation
cd ..

cd test32_xor
./simulate.sh | grep simulation
cd ..

cd test33_lh
./simulate.sh | grep simulation
cd ..

cd test34_lhu
./simulate.sh | grep simulation
cd ..

cd test35_lb
./simulate.sh | grep simulation
cd ..

cd test36_lbu
./simulate.sh | grep simulation
cd ..

cd test37_srl
./simulate.sh | grep simulation
cd ..

cd test38_sra
./simulate.sh | grep simulation
cd ..

cd test39_sll
./simulate.sh | grep simulation
cd ..

cd test40_srli
./simulate.sh | grep simulation
cd ..

cd test41_srai
./simulate.sh | grep simulation
cd ..

cd test42_slli
./simulate.sh | grep simulation
cd ..

cd test43_jal
./simulate.sh | grep simulation
cd ..

cd test44_beq_jal
./simulate.sh | grep simulation
cd ..

cd test45_beq
./simulate.sh | grep simulation
cd ..

cd test46_jal2
./simulate.sh | grep simulation
cd ..

cd test47_bltu
./simulate.sh | grep simulation
cd ..

cd test48_bgeu
./simulate.sh | grep simulation
cd ..

cd test49_slti
./simulate.sh | grep simulation
cd ..
