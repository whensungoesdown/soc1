#!/bin/bash
echo run tests
cd test1_addi
./simulate.sh | grep simulation
cd ..
