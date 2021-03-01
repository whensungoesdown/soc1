#!/bin/bash
echo run tests

cd soc1
./clean.sh
cd ..

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

cd test26_and
./clean.sh
cd ..

cd test27_ori
./clean.sh
cd ..

cd test28_or
./clean.sh
cd ..

cd test29_sltiu
./clean.sh
cd ..

cd test30_sltu
./clean.sh
cd ..

cd test31_xori
./clean.sh
cd ..

cd test32_xor
./clean.sh
cd ..

cd test33_lh
./clean.sh
cd ..

cd test34_lhu
./clean.sh
cd ..

cd test35_lb
./clean.sh
cd ..

cd test36_lbu
./clean.sh
cd ..

cd test37_srl
./clean.sh
cd ..

cd test38_sra
./clean.sh
cd ..

cd test39_sll
./clean.sh
cd ..

cd test40_srli
./clean.sh
cd ..

cd test41_srai
./clean.sh
cd ..

cd test42_slli
./clean.sh
cd ..

cd test43_jal
./clean.sh
cd ..

cd test44_beq_jal
./clean.sh
cd ..

cd test45_beq
./clean.sh
cd ..

cd test46_jal2
./clean.sh
cd ..

cd test47_bltu
./clean.sh
cd ..

cd test48_bgeu
./clean.sh
cd ..
