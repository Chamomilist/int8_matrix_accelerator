`timescale 1ns / 1ps
module tb_top_scale;
  parameter DATA_WIDTH = 8;
  parameter ACC_WIDTH = 32;
  parameter ROWS = 4;
  parameter COLS = 4;

  logic clk, rst, start, done;
  logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_a, matrix_b;
  logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result;
  int errors;

  int8_matmul_top #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH(ACC_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS)
  ) dut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .matrix_a(matrix_a),
      .matrix_b(matrix_b),
      .done(done),
      .result(result)
  );

  always #5 clk = ~clk;

  task automatic check(input int i, input int j, input logic signed [ACC_WIDTH-1:0] act,
                       input logic signed [ACC_WIDTH-1:0] exp);
    if (act !== exp) begin
      $display("FAIL | [%0d][%0d]=%0d exp %0d", i, j, act, exp);
      errors++;
    end else $display("PASS | [%0d][%0d]=%0d", i, j, act);
  endtask

  initial begin
    clk = 0;
    errors = 0;
    rst = 1;
    start = 0;
    matrix_a[0][0] = 1;
    matrix_a[0][1] = 2;
    matrix_a[0][2] = 3;
    matrix_a[0][3] = 4;
    matrix_a[1][0] = 5;
    matrix_a[1][1] = 6;
    matrix_a[1][2] = 7;
    matrix_a[1][3] = 8;
    matrix_a[2][0] = 9;
    matrix_a[2][1] = 10;
    matrix_a[2][2] = 11;
    matrix_a[2][3] = 12;
    matrix_a[3][0] = 13;
    matrix_a[3][1] = 14;
    matrix_a[3][2] = 15;
    matrix_a[3][3] = 16;

    matrix_b[0][0] = 16;
    matrix_b[0][1] = 15;
    matrix_b[0][2] = 14;
    matrix_b[0][3] = 13;
    matrix_b[1][0] = 12;
    matrix_b[1][1] = 11;
    matrix_b[1][2] = 10;
    matrix_b[1][3] = 9;
    matrix_b[2][0] = 8;
    matrix_b[2][1] = 7;
    matrix_b[2][2] = 6;
    matrix_b[2][3] = 5;
    matrix_b[3][0] = 4;
    matrix_b[3][1] = 3;
    matrix_b[3][2] = 2;
    matrix_b[3][3] = 1;

    repeat (2) @(posedge clk);
    rst = 0;
    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;
    wait (done);
    repeat (3) @(posedge clk);

    check(0, 0, result[0][0], 32'sd80);
    check(0, 1, result[0][1], 32'sd70);
    check(0, 2, result[0][2], 32'sd60);
    check(0, 3, result[0][3], 32'sd50);
    check(1, 0, result[1][0], 32'sd240);
    check(1, 1, result[1][1], 32'sd214);
    check(1, 2, result[1][2], 32'sd188);
    check(1, 3, result[1][3], 32'sd162);
    check(2, 0, result[2][0], 32'sd400);
    check(2, 1, result[2][1], 32'sd358);
    check(2, 2, result[2][2], 32'sd316);
    check(2, 3, result[2][3], 32'sd274);
    check(3, 0, result[3][0], 32'sd560);
    check(3, 1, result[3][1], 32'sd502);
    check(3, 2, result[3][2], 32'sd444);
    check(3, 3, result[3][3], 32'sd386);

    if (errors == 0) begin
      $display("=========================");
      $display(" ALL TESTS PASSED ");
      $display("=========================");
    end
    $finish;
  end
endmodule
