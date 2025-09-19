module alu (
    input  wire [7:0] a,      // Operand a
    input  wire [7:0] b,      // Operand b
    input  wire [2:0] opcode,  // Operation selector
    output reg  [7:0] result   // Result of the operation
);

    always @(*) begin
        case (opcode)
            3'b000: result = a + b;             // Addition
            3'b001: result = a - b;             // Subtraction
            3'b010: result = a & b;             // Bitwise AND
            3'b011: result = a | b;             // Bitwise OR
            3'b100: result = a ^ b;             // Bitwise XOR
            3'b101: result = a << 1;            // Logical left shift
            3'b110: result = a >> 1;            // Logical right shift
            3'b111: result = a;                  // Pass-through
            default: result = 8'h00;             // Default case to avoid latches
        endcase
    end

endmodule

module bist_controller(
    input clk,
    input reset,
    input bist_start,
    input [7:0] alu_result,
    output reg bist_done,
    output reg bist_pass,
    output reg bist_fail,
    output reg [7:0] a,
    output reg [7:0] b,
    output reg [2:0] opcode
);

    // State Encoding
    typedef enum reg [2:0] {
        IDLE = 3'b000,
        APPLY_VECTOR = 3'b001,
        CHECK_RESULT = 3'b010,
        NEXT_VECTOR = 3'b011,
        DONE = 3'b100
    } state_t;

    state_t current_state, next_state;

    // Test Vector Definition
    reg [7:0] test_vectors_a [0:4];
    reg [7:0] test_vectors_b [0:4];
    reg [2:0] test_opcodes [0:4];
    reg [7:0] expected_results [0:4];
    integer vector_index;

    // Initializing test vectors
    initial begin
        test_vectors_a[0] = 8'd15; test_vectors_b[0] = 8'd10; test_opcodes[0] = 3'b000; expected_results[0] = 8'd25; // Addition
        test_vectors_a[1] = 8'd20; test_vectors_b[1] = 8'd10; test_opcodes[1] = 3'b001; expected_results[1] = 8'd10; // Subtraction
        test_vectors_a[2] = 8'd15; test_vectors_b[2] = 8'd3;  test_opcodes[2] = 3'b010; expected_results[2] = 8'd15; // AND
        test_vectors_a[3] = 8'd12; test_vectors_b[3] = 8'd5;  test_opcodes[3] = 3'b011; expected_results[3] = 8'd13; // OR
        test_vectors_a[4] = 8'd7;  test_vectors_b[4] = 8'd3;  test_opcodes[4] = 3'b100; expected_results[4] = 8'd4;  // XOR
    end

    // State Transition and Output Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            bist_done <= 0;
            bist_pass <= 0;
            bist_fail <= 0;
            vector_index <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        // Default outputs
        next_state = current_state;
        bist_done = 0;
        bist_pass = 1; // assume pass until a fail is detected
        bist_fail = 0;

        case (current_state)
            IDLE: begin
                if (bist_start) begin
                    vector_index = 0; // reset vector index
                    next_state = APPLY_VECTOR;
                end
            end

            APPLY_VECTOR: begin
                a = test_vectors_a[vector_index];
                b = test_vectors_b[vector_index];
                opcode = test_opcodes[vector_index];
                next_state = CHECK_RESULT;
            end

            CHECK_RESULT: begin
                if (alu_result != expected_results[vector_index]) begin
                    bist_fail = 1;
                    bist_pass = 0;
                    next_state = DONE; // Move to DONE state if there's a mismatch
                end else begin
                    next_state = NEXT_VECTOR; // Correct result, go to next vector
                end
            end

            NEXT_VECTOR: begin
                vector_index = vector_index + 1; // increment to next vector

                if (vector_index < 5) begin
                    next_state = APPLY_VECTOR; // More vectors to apply
                end else begin
                    next_state = DONE; // All vectors applied, go to DONE
                end
            end

            DONE: begin
                bist_done = 1; // Finalize BIST process
                if (bist_fail == 0) begin
                    bist_pass = 1; // All tests passed
                end
                next_state = IDLE; // Return to IDLE to wait for next start
            end

            default: next_state = IDLE; // Safety default state
        endcase
    end

endmodule

module alu_bist_top (
    input wire clk,
    input wire reset,
    input wire bist_start,
    output wire bist_done,
    output wire bist_pass,
    output wire bist_fail
);

// Internal wires to connect ALU and BIST controller
wire [31:0] a;                // Input A for ALU
wire [31:0] b;                // Input B for ALU
wire [3:0]  opcode;           // Operation code for ALU
wire [31:0] alu_result;       // Result output from ALU

// Instantiate the alu module
alu U_ALU (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(alu_result)
);

// Instantiate the bist_controller module
bist_controller U_BIST_CONTROLLER (
    .clk(clk),
    .reset(reset),
    .bist_start(bist_start),
    .a(a),
    .b(b),
    .opcode(opcode),
    .alu_result(alu_result),
    .bist_done(bist_done),
    .bist_pass(bist_pass),
    .bist_fail(bist_fail)
);

endmodule

module tb_alu_bist_top;

    // Clock and reset signals
    reg clk;
    reg reset;
    reg bist_start;

    // BIST outputs
    wire bist_done;
    wire bist_pass;
    wire bist_fail;

    // Instantiate the alu_bist_top module
    alu_bist_top UUT (
        .clk(clk),
        .reset(reset),
        .bist_start(bist_start),
        .bist_done(bist_done),
        .bist_pass(bist_pass),
        .bist_fail(bist_fail)
    );

    // Generate clock signal (100 MHz)
    always #5 clk = ~clk;

    // Testbench initial block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        bist_start = 0;

        // Apply reset for a few clock cycles
        #20; // Reset for 20 time units (4 clock cycles)
        reset = 0; // Release reset after 20 time units

        // Pulse the bist_start signal
        bist_start = 1;
        #10; // Wait for one clock cycle
        bist_start = 0;

        // Wait until bist_done is asserted
        wait(bist_done);

        // Check the results
        if (bist_pass) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end

        // End simulation
        $finish;
    end

endmodule
