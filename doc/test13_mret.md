## test13_mret

Found a problem. When the mret is decoded in the IFID stage,
the pcF will be filled with mepc. I choose to do this at IFID stage
rather than do it in a later stage such as EX or MEM.

The problem is that the instruction right before mret may not
be finished in time. For example, if this instruction is csrrw which
updates mepc, the mret will still use the old mepc.

Such as the flowing code that tries to return from the trap handler.
````````````````````
<trap>:
00a00313;  --           addi x6 x0 10
341021f3;  --           csrrs x3 mepc x0 (csrr rd mepc)
00418193;  --           addi x3 x3 4
34119073;  --           csrrw x0 mepc x3 (csrw mepc rs)
30200073;  --           mret
```````````````````````````
To solve this problem, I come up with this empty pipeline
mechanism. It is not flushing the pipeline. It is to wait for the
instructions that already in the pipeline to finish.

There is a signal empty_pipeline_req that will be passed all the
way through pipelines.

empty_pipeline_req-->empty_pipeline_reqE-->empty_pipeline_reqM
-->empty_pipeline_reqW

Then, at the last pipeline stage, W, signal empty_pipeline_ackW.

In the IFID stage, the logic is the following:

assign empty_pipeline_stallF =   empty_pipeline_req
                               & (~empty_pipeline_ackW);

The pcF is stalled until the empty_pipeline_ackW is signaled.


`````````
CONTENT BEGIN


        0:              00000463;  --           beq x0 x0 8 <reset>
        1:              02000263;  --           beq x0 x0 36 <trap>

-- <reset>:
        2:              00100093;  --           addi x1 x0 1
        3:              00200113;  --           addi x2 x0 2
        4:              00300193;  --           addi x3 x0 3
        5:              00118213;  --           addi x4 x3 1
        6:              00120293;  --           addi x5 x4 1
        7:              00000000;  --           <------------- illegal instruction
        8:              00128313;  --           addi x6 x5 1      ; should return here <---- test mepc == 0x20, x3 == 0x20, x6 == 0xa

-- <loop_in_reset>:
        9:              00000063;  --           beq x0 x0 0 <loop_in_reset>

-- <trap>:
        a:              00a00313;  --           addi x6 x0 10
        b:              341021f3;  --           csrrs x3 mepc x0 (csrr rd mepc)
        c:              00418193;  --           addi x3 x3 4
        d:              34119073;  --           csrrw x0 mepc x3 (csrw mepc rs)
        e:              30200073;  --           mret
        f:              00000013;  --           nop  ; should never be here

-- <loop_in_trap>:
        10:             00000063;  --           beq x0 x0 0 <loop_in_trap>


        [11..7FF]  :   00000013; -- nop
END;
`````````
