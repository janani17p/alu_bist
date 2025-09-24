You are generating synthesizable Verilog for a module named alu_bist_top that must pass the provided testbench. Follow these exact interface and behavior rules.

Module interface
module alu_bist_top
input clk
input reset active high, synchronous
input bist_start one cycle pulse to begin BIST
output reg bist_done asserted when test sequence is finished, stays high until reset
output reg bist_pass latched high at completion if signature matches golden value, cleared only by reset
output reg bist_fail latched high at completion if signature mismatches, cleared only by reset

High level architecture
a. Instantiate a simple 16 bit ALU used as the unit under test. Support at least these ops controlled by a 3 bit op code
000 add, 001 sub, 010 xor, 011 and, 100 or, 101 not a, 110 increment a, 111 pass through a
b. Drive ALU operands and op code from an internal 16 bit LFSR based pattern generator. Use a primitive polynomial for 16 bits such as taps 16, 14, 13, 11 with xnor feedback.
c. Compress ALU outputs into a 16 bit MISR. Feed in the 16 bit ALU result and optionally zero extend flags into the MISR input word.
d. Run for PATTERN_COUNT patterns then compare MISR to a parameter GOLDEN_SIG.
e. When complete, set bist_done high and latch either bist_pass or bist_fail exclusively. Keep bist_done high until reset so the testbench wait on posedge works and the flags remain stable.

Control FSM
States IDLE, RUN, DONE
a. IDLE waits for a one cycle bist_start pulse. On start, clear MISR, seed LFSR to a nonzero SEED, clear cycle counter, clear pass and fail, deassert done.
b. RUN advances one pattern per clock. For each clock, update LFSR, apply operands to ALU, update MISR from ALU output. Stop when cycle counter reaches PATTERN_COUNT.
c. DONE assert bist_done and compute comparison once. Set pass if misr equals GOLDEN_SIG else set fail. Remain in DONE until reset.

Parameters
parameter integer PATTERN_COUNT default 512 and must complete well before 100 microseconds at 100 MHz
parameter [15:0] LFSR_SEED default 16 h1
parameter [15:0] GOLDEN_SIG default 16 h0000 as a placeholder. Also provide a task or initial block guarded by synthesis translate off that can print the MISR at end for testbench learning runs.

Reset behavior
Synchronous, active high. Reset clears FSM to IDLE, clears bist_done, pass, fail, resets LFSR to seed value and clears MISR.

Coding requirements
a. All sequential logic in always posedge clk blocks with nonblocking assignments
b. No delays and no unsized constants
c. Use separate combinational block for ALU function with a case on op code and a default that returns zero
d. Ensure pass and fail are never both one
e. Keep signals stable after DONE until reset
f. Comment the code clearly

Optional simulation aid
Inside translate off translate on, print the final MISR value with a $display so the user can set GOLDEN_SIG for their chosen PATTERN_COUNT and seed.

Deliverables
Provide a single file alu_bist_top.v that implements the above. Include a short header comment block describing parameters and how to update GOLDEN_SIG after a learning run.
