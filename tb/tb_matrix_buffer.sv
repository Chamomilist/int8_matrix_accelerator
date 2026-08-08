`timescale 1ns / 1ps

module tb_matrix_buffer;

  parameter DATA_WIDTH = 8;

  logic clk;
  logic rst;
  logic start;

  // Packed array ports, matching matrix_buffer's packed port declarations
  logic signed [1:0][1:0][DATA_WIDTH-1:0] matrix_a;
  logic signed [1:0][1:0][DATA_WIDTH-1:0] matrix_b;

  logic signed [1:0][DATA_WIDTH-1:0] a_out;
  logic signed [1:0][DATA_WIDTH-1:0] b_out;

  logic [1:0] valid;
  logic [1:0] b_valid;
  logic done;

  int errors;

  matrix_buffer #(
      .DATA_WIDTH(DATA_WIDTH),
      .ROWS(2),
      .COLS(2)
  ) dut (

      .clk  (clk),
      .rst  (rst),
      .start(start),

      .matrix_a(matrix_a),
      .matrix_b(matrix_b),

      .a_out(a_out),
      .b_out(b_out),

      .valid(valid),
      .b_valid(b_valid),
      .done(done)

  );

  always #5 clk = ~clk;

  task automatic check_cycle(
      input string label, input logic signed [DATA_WIDTH-1:0] exp_a0,
      input logic signed [DATA_WIDTH-1:0] exp_a1, input logic signed [DATA_WIDTH-1:0] exp_b0,
      input logic signed [DATA_WIDTH-1:0] exp_b1, input logic [1:0] exp_valid,
      input logic [1:0] exp_b_valid, input logic exp_done);
    if (a_out[0] !== exp_a0 || a_out[1] !== exp_a1 ||
        b_out[0] !== exp_b0 || b_out[1] !== exp_b1 ||
        valid    !== exp_valid || b_valid !== exp_b_valid || done !== exp_done) begin
      $display(
          "FAIL | %s: a_out=%0d %0d b_out=%0d %0d valid=%b b_valid=%b done=%b (expected a=%0d %0d b=%0d %0d valid=%b b_valid=%b done=%b)",
          label, a_out[0], a_out[1], b_out[0], b_out[1], valid, b_valid, done, exp_a0, exp_a1,
          exp_b0, exp_b1, exp_valid, exp_b_valid, exp_done);
      errors++;
    end else begin
      $display("PASS | %s", label);
    end
  endtask

  initial begin

    $dumpfile("results/matrix_buffer.vcd");
    $dumpvars(0, tb_matrix_buffer);

    clk = 0;
    errors = 0;

    rst = 1;
    start = 0;

    matrix_a[0][0] = 1;
    matrix_a[0][1] = 2;
    matrix_a[1][0] = 3;
    matrix_a[1][1] = 4;

    matrix_b[0][0] = 5;
    matrix_b[0][1] = 6;
    matrix_b[1][0] = 7;
    matrix_b[1][1] = 8;

    repeat (2) @(posedge clk);

    rst = 0;

    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    // Row-skewed schedule: row0 first, both rows in the middle, row1 last.
    // Expected values reference the matrix_a/matrix_b elements directly
    // rather than hardcoding the skew as magic numbers.

    @(posedge clk);
    #1;
    check_cycle("cycle0", matrix_a[0][0], '0, matrix_b[0][0], '0, 2'b01, 2'b01, 1'b0);

    @(posedge clk);
    #1;
    check_cycle("cycle1", matrix_a[0][1], matrix_a[1][0], matrix_b[1][0], matrix_b[0][1], 2'b11,
                2'b11, 1'b0);

    @(posedge clk);
    #1;
    check_cycle("cycle2", matrix_a[0][1], matrix_a[1][1], matrix_b[1][0], matrix_b[1][1], 2'b10,
                2'b10, 1'b1);

    @(posedge clk);
    #1;
    check_cycle("idle", matrix_a[0][1], matrix_a[1][1], matrix_b[1][0], matrix_b[1][1], 2'b00,
                2'b00, 1'b1);

    if (errors == 0) begin
      $display("");
      $display("=========================");
      $display(" ALL TESTS PASSED ");
      $display("=========================");
      $display("");
    end

    $finish;

  end

endmodule
