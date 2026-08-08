`timescale 1ns / 1ps

module systolic_array #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 32,
    parameter int ROWS = 2,
    parameter int COLS = 2
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,


    // Packed array ports for better simulator compatibility
    input logic signed [ROWS-1:0][DATA_WIDTH-1:0] a_in,
    input logic signed [COLS-1:0][DATA_WIDTH-1:0] b_in,
    input logic [ROWS-1:0] a_valid_in,
    input logic [COLS-1:0] b_valid_in,

    output logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result

);

  // Internal buses converted to packed arrays too for the same reason
  logic signed [ROWS-1:0][COLS:0][DATA_WIDTH-1:0] a_bus;
  logic signed [ROWS:0][COLS-1:0][DATA_WIDTH-1:0] b_bus;

  // a_valid_bus propagates rightward along each row (with a_bus).
  // b_valid_bus propagates downward along each column (with b_bus),
  // tracked independently of a_valid_bus.
  logic a_valid_bus[ROWS][COLS+1];
  logic b_valid_bus[ROWS+1][COLS];

  genvar i, j;

  generate

    // Inject left-edge inputs
    for (i = 0; i < ROWS; i++) begin
      assign a_bus[i][0] = a_in[i];
      assign a_valid_bus[i][0] = a_valid_in[i];
    end

    // Inject top-edge inputs
    for (j = 0; j < COLS; j++) begin
      assign b_bus[0][j] = b_in[j];
      assign b_valid_bus[0][j] = b_valid_in[j];
    end

    // Instantiate PE array
    for (i = 0; i < ROWS; i++) begin : ROW_GEN
      for (j = 0; j < COLS; j++) begin : COL_GEN

        pe #(
            .DATA_WIDTH(DATA_WIDTH),
            .ACC_WIDTH (ACC_WIDTH)
        ) u_pe (
            .clk(clk),
            .rst(rst),
            .clear(clear),
            .enable(enable),

            .a_in(a_bus[i][j]),
            .b_in(b_bus[i][j]),
            .a_valid_in(a_valid_bus[i][j]),
            .b_valid_in(b_valid_bus[i][j]),

            .a_out(a_bus[i][j+1]),
            .b_out(b_bus[i+1][j]),
            .a_valid_out(a_valid_bus[i][j+1]),
            .b_valid_out(b_valid_bus[i+1][j]),

            .result(result[i][j])
        );

      end
    end

  endgenerate

endmodule
