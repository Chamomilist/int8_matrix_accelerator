// Integrates the standalone multiplier and accumulator modules into a single
// multiply-accumulate (MAC) unit used throughout the accelerator.

module mac #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 32
)(
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

assign product_out = a * b;

assign product_ext = {{(ACC_WIDTH-(2*DATA_WIDTH)){product_out[(2*DATA_WIDTH)-1]}}, product_out};

always_ff @(posedge clk) begin
    if (rst)
        result <= '0;
    else if (clear)
        result <= '0;
    else if (enable)
        result <= result + product_ext;
end

endmodule
