Write a synthesizable Verilog module named alu with the following specification:
Inputs:
a[7:0], b[7:0] (operands)
opcode[2:0] (selects operation)
Output:
result[7:0]
Behavior:
000: Addition (a + b)
001: Subtraction (a - b)
010: Bitwise AND
011: Bitwise OR
100: Bitwise XOR
101: Logical left shift a << 1
110: Logical right shift a >> 1
111: Pass-through (result = a)

Use a combinational always block (always @(*)) with a case statement.
Ensure default case assigns result = 8'h00 to avoid latches.
Write a synthesizable Verilog module named bist_controller that performs Built-In Self-Test (BIST) for the ALU.
Inputs:
clk (clock)
reset (active-high synchronous reset)
bist_start (start signal)
alu_result[7:0] (result from ALU)
Outputs:
bist_done (asserts high when all test vectors are applied)
bist_pass (high if all tests pass)
bist_fail (high if any test fails)
a[7:0], b[7:0], opcode[2:0] (drives ALU inputs during BIST)
Behavior:
Use a finite state machine with states: IDLE → APPLY_VECTOR → CHECK_RESULT → NEXT_VECTOR → DONE.
Generate at least 5 test vectors that cover addition, subtraction, AND, OR, and XOR.
Compare alu_result against the expected result for each vector.
If any mismatch is found, set bist_fail=1 and bist_pass=0.
When all vectors are done, assert bist_done=1.
Do not use #delay. The design must be synthesizable.
Write a synthesizable Verilog top-level module named alu_bist_top.
Inputs:
clk, reset, bist_start
Outputs:
bist_done, bist_pass, bist_fail
Internal Wiring:
Instantiate the alu module.
Instantiate the bist_controller module.
Connect a, b, opcode outputs of bist_controller to alu inputs.
Connect alu.result to bist_controller.alu_result.
Use named port mapping for clarity.

