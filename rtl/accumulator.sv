`timescale 1ns / 1ps

module accumulator #(
    parameter int DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,
    input logic signed [DATA_WIDTH-1:0] data_in,

    output logic signed [DATA_WIDTH-1:0] acc_out
);

  always_ff @(posedge clk) begin
    if (rst) acc_out <= '0;
    else if (clear) acc_out <= '0;
    else if (enable) acc_out <= acc_out + data_in;
  end

endmodule
