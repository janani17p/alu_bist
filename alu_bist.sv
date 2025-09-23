

Write a synthesizable module named alu_bist_top with this exact interface:

module alu_bist_top(
    input  clk,
    input  reset,        // active high async reset
    input  bist_start,   // start pulse
    output reg bist_done,
    output reg bist_pass,
    output reg bist_fail
);


Behavior

Implement a small BIST controller with three states: IDLE, RUN, DONE.

On reset high, go to IDLE and drive bist_done=0, bist_pass=0, bist_fail=0.

On a rising edge of bist_start in IDLE, enter RUN, clear a cycle counter to zero.

In RUN, increment the counter each clk. After exactly 256 cycles, enter DONE.

In DONE, drive bist_done=1, bist_pass=1, bist_fail=0 and hold these until reset.

Use only synchronous logic for state and counters with always @(posedge clk or posedge reset).

Detect the rising edge of bist_start with a registered previous value.

Keep all signal and port names exactly as specified.

Coding rules

Verilog 2001 only. No SystemVerilog features.

Use parameters for state encodings and a 9 bit counter for the 256 cycle run.

Plain ASCII. No comments. No headers. No markdown. Output only the module and endmodule.

Output format
Return only the Verilog source for alu_bist_top that compiles under iverilog.
