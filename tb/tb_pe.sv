`timescale 1ns / 1ps

module tb_pe;

  parameter DATA_WIDTH = 8;
  parameter ACC_WIDTH = 32;

  // Number of clock cycles from applying a valid operand pair
  // to observing a valid accumulated result.
  localparam int PE_LATENCY = 2;

  logic clk;
  logic rst;
  logic clear;
  logic enable;

  logic signed [DATA_WIDTH-1:0] a_in;
  logic signed [DATA_WIDTH-1:0] b_in;
  logic a_valid_in;
  logic b_valid_in;

  logic signed [DATA_WIDTH-1:0] a_out;
  logic signed [DATA_WIDTH-1:0] b_out;
  logic a_valid_out;
  logic b_valid_out;

  logic signed [ACC_WIDTH-1:0] result;

  integer expected;

  pe #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .clear(clear),
      .enable(enable),

      .a_in(a_in),
      .b_in(b_in),
      .a_valid_in(a_valid_in),
      .b_valid_in(b_valid_in),

      .a_out(a_out),
      .b_out(b_out),
      .a_valid_out(a_valid_out),
      .b_valid_out(b_valid_out),

      .result(result)
  );

  always #5 clk = ~clk;

  task send_operand;
    input signed [DATA_WIDTH-1:0] in_a;
    input signed [DATA_WIDTH-1:0] in_b;
    begin

      @(negedge clk);

      a_in       = in_a;
      b_in       = in_b;
      a_valid_in = 1'b1;
      b_valid_in = 1'b1;

      @(negedge clk);

      a_valid_in = 1'b0;
      b_valid_in = 1'b0;

    end
  endtask

  task check_result;
    input signed [DATA_WIDTH-1:0] in_a;
    input signed [DATA_WIDTH-1:0] in_b;
    begin

      expected = expected + (in_a * in_b);

      repeat (PE_LATENCY) @(posedge clk);
      #1;

      if (a_out !== in_a) begin
        $display("FAIL | a_out Expected %0d Got %0d", in_a, a_out);
        $finish;
      end

      if (b_out !== in_b) begin
        $display("FAIL | b_out Expected %0d Got %0d", in_b, b_out);
        $finish;
      end

      if (result !== expected) begin
        $display("FAIL | Result Expected %0d Got %0d", expected, result);
        $finish;
      end

      $display("PASS | %0d x %0d -> Acc=%0d", in_a, in_b, result);

    end
  endtask

  initial begin

    $dumpfile("results/pe.vcd");
    $dumpvars(0, tb_pe);

    clk        = 0;

    rst        = 1;
    clear      = 0;
    enable     = 0;

    a_in       = 0;
    b_in       = 0;
    a_valid_in = 0;
    b_valid_in = 0;

    expected   = 0;

    repeat (2) @(posedge clk);

    rst    = 0;
    enable = 1;

    send_operand(2, 3);
    check_result(2, 3);

    send_operand(4, 5);
    check_result(4, 5);

    send_operand(-2, 8);
    check_result(-2, 8);

    @(negedge clk);
    clear = 1;

    @(posedge clk);
    #1;

    clear = 0;
    expected = 0;

    if (result !== 0) begin
      $display("FAIL | Clear");
      $finish;
    end

    send_operand(10, 10);
    check_result(10, 10);

    send_operand(-5, -4);
    check_result(-5, -4);

    @(negedge clk);

    enable = 0;

    a_in = 8;
    b_in = 8;
    a_valid_in = 1;
    b_valid_in = 1;

    repeat (PE_LATENCY) @(posedge clk);
    #1;

    if (result !== expected) begin
      $display("FAIL | Enable");
      $finish;
    end

    $display("");
    $display("=========================");
    $display(" ALL TESTS PASSED ");
    $display("=========================");
    $display("");

    $finish;

  end

endmodule
