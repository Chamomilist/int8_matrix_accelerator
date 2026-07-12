// Integrates the standalone multiplier and accumulator modules into a single
// multiply-accumulate (MAC) unit used throughout the accelerator.

module mac #(parameter int DATA_WIDTH = 8, parameter int ACC_WIDTH  = 32)
(
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,

    input logic signed [DATA_WIDTH-1:0] a,
    input logic signed [DATA_WIDTH-1:0] b,

    output logic signed [(2*DATA_WIDTH)-1:0] product_out,
    output logic signed [ACC_WIDTH-1:0] result
);

assign product_out = a * b;

always_ff @(posedge clk) begin
    if (rst)
        result <= '0;
    else if (clear)
        result <= '0;
    else if (enable)
        result <= result + product_out;
end

endmodule
