`timescale 1ns / 1ps

// Integrates the standalone multiplier and accumulator modules into a single
// multiply-accumulate (MAC) unit used throughout the accelerator.

module mac #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 32
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,

    input logic signed [DATA_WIDTH-1:0] a,
    input logic signed [DATA_WIDTH-1:0] b,

    output logic signed [(2*DATA_WIDTH)-1:0] product_out,
    output logic signed [ACC_WIDTH-1:0] result
);

  logic signed [ACC_WIDTH-1:0] product_ext;

  multiplier #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_multiplier (
      .a(a),
      .b(b),
      .product(product_out)
  );

  assign product_ext = {
    {(ACC_WIDTH - (2 * DATA_WIDTH)) {product_out[(2*DATA_WIDTH)-1]}}, product_out
  };

  accumulator #(
      .DATA_WIDTH(ACC_WIDTH)
  ) u_accumulator (
      .clk(clk),
      .rst(rst),
      .clear(clear),
      .enable(enable),
      .data_in(product_ext),
      .acc_out(result)
  );

endmodule
