## simulation test framework

Testbenches are all based on soc_top.
run_all_tests.sh records all the test simulation to run,
not inlcuding soc1.

To add new test case, create the similiar testbench file in ../tb/
e.g. test1_addi uses ../tb/test1_addi_soc_top_tb.v
The file name is stored in files.f

To add signals, add stuff in sim.do.

Each new test case has its own ram.mif as the cpu memory
in their directory.

In testbench, if the case succeed, $display "simluation SUCCESS"
or "simluation FAILED". The run_all_tests.sh will grep "simluation"
to show the result.

e.g.

```````````````````````````
[uty@u simulation]$ ./run_all_tests.sh
run tests
# test1_addi simulation SUCCESS
```````````````````````````
