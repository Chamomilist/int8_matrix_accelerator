`timescale 1ns/1ps

module tb_systolic_array;

parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;

localparam int ROWS = 2;
localparam int COLS = 2;

logic clk;
logic rst;
logic clear;
logic enable;

logic signed [DATA_WIDTH-1:0] a_in [ROWS];
logic signed [DATA_WIDTH-1:0] b_in [COLS];

logic valid_in [ROWS];

logic signed [ACC_WIDTH-1:0] result [ROWS][COLS];

systolic_array #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH),
    .ROWS(ROWS),
    .COLS(COLS)
) dut (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .enable(enable),

    .a_in(a_in),
    .b_in(b_in),
    .valid_in(valid_in),

    .result(result)
);

always #5 clk = ~clk;

task send_cycle;
    input signed [DATA_WIDTH-1:0] a0;
    input signed [DATA_WIDTH-1:0] a1;
    input signed [DATA_WIDTH-1:0] b0;
    input signed [DATA_WIDTH-1:0] b1;
begin

    @(negedge clk);

    a_in[0] = a0;
    a_in[1] = a1;

    b_in[0] = b0;
    b_in[1] = b1;

    valid_in[0] = 1;
    valid_in[1] = 1;

    @(negedge clk);

    valid_in[0] = 0;
    valid_in[1] = 0;

end
endtask

initial begin

    $dumpfile("results/systolic_array.vcd");
    $dumpvars(0,tb_systolic_array);

    clk = 0;

    rst = 1;
    clear = 0;
    enable = 0;

    a_in[0] = 0;
    a_in[1] = 0;

    b_in[0] = 0;
    b_in[1] = 0;

    valid_in[0] = 0;
    valid_in[1] = 0;

    repeat(2) @(posedge clk);

    rst = 0;
    enable = 1;

    send_cycle(2,4,3,5);

    repeat(6) @(posedge clk);

    $display("");
    $display("Result Matrix");
    $display("---------------------------");
    $display("%0d %0d", result[0][0], result[0][1]);
    $display("%0d %0d", result[1][0], result[1][1]);
    $display("---------------------------");

    $finish;

end

endmodule
