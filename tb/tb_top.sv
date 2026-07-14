`timescale 1ns/1ps

module tb_top;

parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;
parameter ROWS = 2;
parameter COLS = 2;

logic clk;
logic rst;
logic start;

// CHANGE: unpacked -> packed array declarations to match int8_matmul_top's
// new packed-array ports (unpacked array ports don't propagate through
// module boundaries correctly in Icarus).
logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_a;
logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_b;

logic done;

logic signed [ROWS-1:0][COLS-1:0][ACC_WIDTH-1:0] result;

int8_matmul_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH),
    .ROWS(ROWS),
    .COLS(COLS)
) dut (

    .clk(clk),
    .rst(rst),
    .start(start),

    .matrix_a(matrix_a),
    .matrix_b(matrix_b),

    .done(done),

    .result(result)

);

always #5 clk = ~clk;

initial begin

    $dumpfile("results/top.vcd");
    $dumpvars(0,tb_top);

    clk = 0;
    rst = 1;
    start = 0;

    matrix_a[0][0] = 1;
    matrix_a[0][1] = 2;
    matrix_a[1][0] = 3;
    matrix_a[1][1] = 4;

    matrix_b[0][0] = 5;
    matrix_b[0][1] = 6;
    matrix_b[1][0] = 7;
    matrix_b[1][1] = 8;

    repeat(2) @(posedge clk);

    rst = 0;

    @(negedge clk);
    start = 1;

    @(negedge clk);
    start = 0;

    wait(done);

    repeat(3) @(posedge clk);

    $display("");
    $display("=================================");
    $display(" Accelerator Output");
    $display("=================================");

    $display("%0d %0d",
             result[0][0],
             result[0][1]);

    $display("%0d %0d",
             result[1][0],
             result[1][1]);

    $display("=================================");
    $display("");

    $finish;

end

endmodule
