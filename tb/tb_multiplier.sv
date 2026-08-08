`timescale 1ns / 1ps

module tb_multiplier;

  parameter DATA_WIDTH = 8;

  logic signed [DATA_WIDTH-1:0] a;
  logic signed [DATA_WIDTH-1:0] b;
  logic signed [(2*DATA_WIDTH)-1:0] product;

  multiplier #(
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .a(a),
      .b(b),
      .product(product)
  );

  task check;
    input signed [DATA_WIDTH-1:0] in_a;
    input signed [DATA_WIDTH-1:0] in_b;
    input signed [(2*DATA_WIDTH)-1:0] expected;
    begin
      a = in_a;
      b = in_b;
      #1;

      if (product !== expected) begin
        $display("FAIL | %0d x %0d = %0d (Expected %0d)", a, b, product, expected);
        $finish;
      end else begin
        $display("PASS | %0d x %0d = %0d", a, b, product);
      end
    end
  endtask

  initial begin

    $dumpfile("results/multiplier.vcd");
    $dumpvars(0, tb_multiplier);

    check(2, 3, 6);
    check(10, 10, 100);
    check(-5, 4, -20);
    check(5, -4, -20);
    check(-5, -4, 20);
    check(0, 127, 0);
    check(127, 127, 16129);
    check(-128, 1, -128);
    check(-128, -1, 128);
    check(127, -128, -16256);

    $display("\n=========================");
    $display(" ALL TESTS PASSED ");
    $display("=========================\n");

    $finish;

  end

endmodule
