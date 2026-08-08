`timescale 1ns / 1ps

module tb_systolic_array;

  parameter DATA_WIDTH = 8;
  parameter ACC_WIDTH = 32;

  localparam int ROWS = 2;
  localparam int COLS = 2;

  logic clk;
  logic rst;
  logic clear;
  logic enable;

  logic signed [ROWS-1:0][DATA_WIDTH-1:0] a_in;
  logic signed [COLS-1:0][DATA_WIDTH-1:0] b_in;

  logic [ROWS-1:0] a_valid_in;
  logic [COLS-1:0] b_valid_in;

  logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result;

  int errors;

  systolic_array #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH(ACC_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS)
  ) dut (
      .clk(clk),
      .rst(rst),
      .clear(clear),
      .enable(enable),

      .a_in(a_in),
      .b_in(b_in),
      .a_valid_in(a_valid_in),
      .b_valid_in(b_valid_in),

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

    $dumpfile("results/systolic_array.vcd");
    $dumpvars(0, tb_systolic_array);

    clk = 0;
    errors = 0;

    rst = 1;
    clear = 0;
    enable = 0;

    a_in = '0;
    b_in = '0;
    a_valid_in = '0;
    b_valid_in = '0;

    repeat (2) @(posedge clk);

    rst = 0;
    enable = 1;

    // Row-staggered feed matching the skew matrix_buffer produces for a real
    // 2x2 matmul: A = [[1,2],[3,4]], B = [[5,6],[7,8]] -> [[19,22],[43,50]]

    @(negedge clk);
    a_in[0] = 1;
    b_in[0] = 5;
    a_valid_in = 2'b01;
    b_valid_in = 2'b01;

    @(negedge clk);
    a_in[0] = 2;
    a_in[1] = 3;
    b_in[0] = 7;
    b_in[1] = 6;
    a_valid_in = 2'b11;
    b_valid_in = 2'b11;

    @(negedge clk);
    a_in[1] = 4;
    b_in[1] = 8;
    a_valid_in = 2'b10;
    b_valid_in = 2'b10;

    @(negedge clk);
    a_valid_in = 2'b00;
    b_valid_in = 2'b00;

    repeat (3) @(posedge clk);

    $display("");
    $display("Result Matrix");
    $display("---------------------------");

    check_element(0, 0, result[0][0], 32'sd19);
    check_element(0, 1, result[0][1], 32'sd22);
    check_element(1, 0, result[1][0], 32'sd43);
    check_element(1, 1, result[1][1], 32'sd50);

    $display("---------------------------");
    $display("");

    if (errors == 0) begin
      $display("=========================");
      $display(" ALL TESTS PASSED ");
      $display("=========================");
    end

    $finish;

  end

endmodule
