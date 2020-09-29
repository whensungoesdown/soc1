## Exception: illegal instruction

cpu6_excp is put at IFID stage, the first stage of pipeline.

After decoding, if it is a illegal instruction, the nextpcF is simply set to the exception handler,
which is from csr register mtvec. For now, mtvec is hardwired to 0x00000004.

0x00000000 is the reset vector.

`````````````
   //cpu6_mux2#(`CPU6_XLEN) pcnextmux(pcplus4F, pcnextE, pcsrcE, pcnextF);
   // 1. excp_flush has the highest priority. For example, illegal instruction, the excp module
   //    need to set pc to trap vector.
   // 2. There is a branch, the branch pc comes from EX stage because it needs calculation
   // 3. pc+4  
   assign pcnextF = 
		    excp_flush ? excp_flush_pc:
		    pcsrcE? pcnextE:
		    pcplus4F;
`````````````

This is easy because of the fact that the excp module is at the very first stage.

Later, module cpu6_excp should stay with cpu6_csr, the mtvec should read from it.


### test4_excption_illegal_instruction
````````````
CONTENT BEGIN


	0:		00000463;  --		beq x0 x0 8 <reset>
	1:		02000263;  --		beq x0 x0 36 <trap>

-- <reset>:
	2:		00100093;  --		addi x1 x0 1
	3:		00200113;  --		addi x2 x0 2
	4:		00300193;  --		addi x3 x0 3
	5:		00118213;  --		addi x4 x3 1
	6:		00120293;  --		addi x5 x4 1
	7:		00000000;  --		<------------- illegal instruction
	8:		00128313;  --		addi x6 x5 1

-- <loop_in_reset>:
	9:		00000063;  --		beq x0 x0 0 <loop_in_reset>

-- <trap>:
	a:		00a00313;  --		addi x6 x0 10
	b:		00000013;  --		nop
	c:		00000013;  --		nop
	d:		00000013;  --		nop
	e:		00000013;  --		nop
	f:		00000013;  --		nop

-- <loop_in_trap>:
	10:		00000063;  --		beq x0 x0 0 <loop_in_trap>



	[11..7FF]  :   00000013; -- nop
END;
````````````
