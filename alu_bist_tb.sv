`timescale 1ns / 1ps

module tb_alu_bist_top;

  reg  clk;
  reg  reset;
  reg  bist_start;
  wire bist_done;
  wire bist_pass;
  wire bist_fail;

  // Unit under test
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

  // Optional waves
  initial begin
    $dumpfile("bist.vcd");
    $dumpvars(0, tb_alu_bist_top);
  end

  // Drive and checks with watchdog
  initial begin : MAIN
    fork
      // Watchdog that hard fails after 100 us
      begin : WATCHDOG
        #100_000;
        $fatal(1, "Timeout waiting for bist_done");
      end

      // Stimulus and result checks
      begin : STIM_AND_CHECKS
        // Reset for two cycles
        reset      = 1;
        bist_start = 0;
        repeat (2) @(posedge clk);
        reset = 0;

        // One cycle start pulse
        @(posedge clk); bist_start = 1;
        @(posedge clk); bist_start = 0;

        // Wait until done goes high
        wait (bist_done);

        // Enforce exactly one of pass or fail
        if ((bist_pass ^ bist_fail) !== 1'b1)
          $fatal(1, "pass and fail not mutually exclusive");

        // Final verdict
        if (bist_pass && !bist_fail) begin
          $display("PASS");
          $display("Testbench ran successfully.");
          disable WATCHDOG;
          disable MAIN;
        end
        else begin
          $display("FAIL");
          $fatal(1, "BIST reported fail");
        end
      end
    join_any
    // If either branch finishes, kill the other
    disable fork;
  end

  // Optional live view
  initial
    $monitor("%0t ns  done=%0b pass=%0b fail=%0b",
             $time, bist_done, bist_pass, bist_fail);

endmodule
