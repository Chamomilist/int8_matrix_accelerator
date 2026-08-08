`timescale 1ns / 1ps

module tb_top;

  parameter DATA_WIDTH = 8;
  parameter ACC_WIDTH = 32;
  parameter ROWS = 2;
  parameter COLS = 2;

  logic clk;
  logic rst;
  logic start;

  logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_a;
  logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_b;

  logic done;

  logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result;
  logic signed [ACC_WIDTH-1:0] expected[ROWS][COLS];
  int errors;

  int8_matmul_top #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH(ACC_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS)
  ) dut (

      .clk  (clk),
      .rst  (rst),
      .start(start),

      .matrix_a(matrix_a),
      .matrix_b(matrix_b),

      .done(done),

      .result(result)

  );

  always #5 clk = ~clk;

  task automatic check_element(input int label_i, input int label_j,
                               input logic signed [ACC_WIDTH-1:0] actual,
                               input logic signed [ACC_WIDTH-1:0] exp);
    if (actual !== exp) begin
      $display("FAIL | result[%0d][%0d] = %0d, expected %0d", label_i, label_j, actual, exp);
      errors++;
    end else begin
      $display("PASS | result[%0d][%0d] = %0d", label_i, label_j, actual);
    end
  endtask

  initial begin

    $dumpfile("results/top.vcd");
    $dumpvars(0, tb_top);

    clk = 0;
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

    // Golden 2x2 matmul reference. Indices are literal constants (not loop
    // variables) since this Icarus build cannot index a packed multi-dim
    // array with a variable -- same constraint matrix_buffer.sv works around.
    expected[0][0] = matrix_a[0][0] * matrix_b[0][0] + matrix_a[0][1] * matrix_b[1][0];
    expected[0][1] = matrix_a[0][0] * matrix_b[0][1] + matrix_a[0][1] * matrix_b[1][1];
    expected[1][0] = matrix_a[1][0] * matrix_b[0][0] + matrix_a[1][1] * matrix_b[1][0];
    expected[1][1] = matrix_a[1][0] * matrix_b[0][1] + matrix_a[1][1] * matrix_b[1][1];

    repeat (2) @(posedge clk);

    rst = 0;

    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    wait (done);

    repeat (3) @(posedge clk);

    $display("");
    $display("=================================");
    $display(" Accelerator Output");
    $display("=================================");

    $display("%0d %0d", result[0][0], result[0][1]);

    $display("%0d %0d", result[1][0], result[1][1]);

    $display("=================================");
    $display("");

    errors = 0;
    check_element(0, 0, result[0][0], expected[0][0]);
    check_element(0, 1, result[0][1], expected[0][1]);
    check_element(1, 0, result[1][0], expected[1][0]);
    check_element(1, 1, result[1][1], expected[1][1]);

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
