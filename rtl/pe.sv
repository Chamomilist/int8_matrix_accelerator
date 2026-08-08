`timescale 1ns / 1ps

module pe #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 32
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,

    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    input logic a_valid_in,
    input logic b_valid_in,

    output logic signed [DATA_WIDTH-1:0] a_out,
    output logic signed [DATA_WIDTH-1:0] b_out,
    output logic a_valid_out,
    output logic b_valid_out,

    output logic signed [ACC_WIDTH-1:0] result
);

  logic signed [DATA_WIDTH-1:0] a_reg;
  logic signed [DATA_WIDTH-1:0] b_reg;
  logic a_valid_reg;
  logic b_valid_reg;

  logic signed [(2*DATA_WIDTH)-1:0] product_out;

  always_ff @(posedge clk) begin
    if (rst) begin
      a_reg       <= '0;
      b_reg       <= '0;
      a_valid_reg <= 1'b0;
      b_valid_reg <= 1'b0;
    end else if (enable) begin
      a_reg       <= a_in;
      b_reg       <= b_in;
      a_valid_reg <= a_valid_in;
      b_valid_reg <= b_valid_in;
    end
  end

  assign a_out       = a_reg;
  assign b_out       = b_reg;
  assign a_valid_out = a_valid_reg;
  assign b_valid_out = b_valid_reg;

  mac #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH)
  ) u_mac (
      .clk(clk),
      .rst(rst),
      .clear(clear),
      .enable(enable && a_valid_reg && b_valid_reg),
      .a(a_reg),
      .b(b_reg),
      .product_out(product_out),
      .result(result)
  );

endmodule
