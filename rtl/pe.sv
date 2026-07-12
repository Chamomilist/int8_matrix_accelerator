module pe #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 32
)(
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,

    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    input logic valid_in,

    output logic signed [DATA_WIDTH-1:0] a_out,
    output logic signed [DATA_WIDTH-1:0] b_out,
    output logic valid_out,

    output logic signed [ACC_WIDTH-1:0] result
);

logic signed [DATA_WIDTH-1:0] a_reg;
logic signed [DATA_WIDTH-1:0] b_reg;
logic valid_reg;

logic signed [(2*DATA_WIDTH)-1:0] product_out;

always_ff @(posedge clk) begin
    if (rst) begin
        a_reg     <= '0;
        b_reg     <= '0;
        valid_reg <= 1'b0;
    end
    else if (enable) begin
        a_reg     <= a_in;
        b_reg     <= b_in;
        valid_reg <= valid_in;
    end
end

assign a_out     = a_reg;
assign b_out     = b_reg;
assign valid_out = valid_reg;

mac #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
) u_mac (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .enable(enable && valid_reg),
    .a(a_reg),
    .b(b_reg),
    .product_out(product_out),
    .result(result)
);

endmodule
