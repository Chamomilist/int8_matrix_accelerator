`timescale 1ns / 1ps

module int8_matmul_top #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 32,
    parameter int ROWS = 2,
    parameter int COLS = 2
) (
    input logic clk,
    input logic rst,
    input logic start,

    input logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_a,
    input logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_b,

    output logic done,

    output logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result
);

  logic enable;
  logic clear;

  logic buffer_done;
  logic buffer_valid;

  logic signed [ROWS-1:0][DATA_WIDTH-1:0] a_bus;
  logic signed [COLS-1:0][DATA_WIDTH-1:0] b_bus;

  logic [ROWS-1:0] a_valid_bus;
  logic [COLS-1:0] b_valid_bus;

  controller #(
      .DRAIN_CYCLES(ROWS + COLS - 1)
  ) u_controller (

      .clk(clk),
      .rst(rst),

      .start(start),
      .buffer_done(buffer_done),

      .enable(enable),
      .clear (clear),
      .done  (done)

  );

  matrix_buffer #(
      .DATA_WIDTH(DATA_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS)
  ) u_matrix_buffer (

      .clk  (clk),
      .rst  (rst),
      .start(start),

      .matrix_a(matrix_a),
      .matrix_b(matrix_b),

      .a_out(a_bus),
      .b_out(b_bus),

      .valid(a_valid_bus),
      .b_valid(b_valid_bus),
      .done(buffer_done)

  );

  systolic_array #(
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH(ACC_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS)
  ) u_systolic_array (

      .clk(clk),
      .rst(rst),
      .clear(clear),
      .enable(enable),

      .a_in(a_bus),
      .b_in(b_bus),

      .a_valid_in(a_valid_bus),
      .b_valid_in(b_valid_bus),

      .result(result)

  );

  // Assertion: result must be fully defined (no X) whenever done is asserted
  always @(posedge clk) begin
    if (!rst && done) begin
      assert (^result !== 1'bx)
      else $error("int8_matmul_top: result contains X while done is asserted at time %0t", $time);
    end
  end

endmodule
