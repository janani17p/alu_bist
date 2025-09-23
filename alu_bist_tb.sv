
`timescale 1ns / 1ps

module tb_alu_bist_top;

  reg clk;
  reg reset;
  reg bist_start;
  wire bist_done;
  wire bist_pass;
  wire bist_fail;

  alu_bist_top UUT (
    .clk(clk),
    .reset(reset),
    .bist_start(bist_start),
    .bist_done(bist_done),
    .bist_pass(bist_pass),
    .bist_fail(bist_fail)
  );

  // 100 MHz clock
  initial clk = 0;
  always #5 clk = ~clk;

  // safety timeout
  initial begin
    #100000;
    $display("Timeout waiting for bist_done");
    $finish;
  end

  initial begin
    // reset for two cycles
    reset = 1;
    bist_start = 0;
    repeat (2) @(posedge clk);
    reset = 0;

    // pulse bist_start
    @(posedge clk); bist_start = 1;
    @(posedge clk); bist_start = 0;

    // wait for completion
    @(posedge bist_done);

    if (bist_pass && !bist_fail)
      $display("PASS");
    else
      $display("FAIL");

    $display("Testbench ran successfully.");

    $finish;
  end

  // optional waves
  initial begin
    $dumpfile("bist.vcd");
    $dumpvars(0, tb_alu_bist_top);
  end

endmodule
