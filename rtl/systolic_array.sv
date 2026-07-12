module systolic_array #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 32,
    parameter int ROWS = 2,
    parameter int COLS = 2
)
(
    input logic clk,
    input logic rst,
    input logic clear,
    input logic enable,

    input logic signed [DATA_WIDTH-1:0] a_in [ROWS],
    input logic signed [DATA_WIDTH-1:0] b_in [COLS],
    input logic valid_in [ROWS],

    output logic signed [ACC_WIDTH-1:0] result [ROWS][COLS]
);

logic signed [DATA_WIDTH-1:0] a_bus [ROWS][COLS+1];
logic signed [DATA_WIDTH-1:0] b_bus [ROWS+1][COLS];

logic valid_bus [ROWS][COLS+1];

genvar i, j;

generate

    // Inject left-edge inputs
    for (i = 0; i < ROWS; i++) begin
        assign a_bus[i][0] = a_in[i];
        assign valid_bus[i][0] = valid_in[i];
    end

    // Inject top-edge inputs
    for (j = 0; j < COLS; j++) begin
        assign b_bus[0][j] = b_in[j];
    end

    // Instantiate PE array
    for (i = 0; i < ROWS; i++) begin : ROW_GEN
        for (j = 0; j < COLS; j++) begin : COL_GEN

            pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH))
            u_pe (
                .clk(clk),
                .rst(rst),
                .clear(clear),
                .enable(enable),

                .a_in(a_bus[i][j]),
                .b_in(b_bus[i][j]),
                .valid_in(valid_bus[i][j]),

                .a_out(a_bus[i][j+1]),
                .b_out(b_bus[i+1][j]),
                .valid_out(valid_bus[i][j+1]),

                .result(result[i][j])
            );

        end
    end

endgenerate

endmodule
