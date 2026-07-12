`timescale 1ns/1ps

module tb_matrix_buffer;

parameter DATA_WIDTH = 8;

logic clk;
logic rst;
logic start;

logic signed [DATA_WIDTH-1:0] matrix_a [2][2];
logic signed [DATA_WIDTH-1:0] matrix_b [2][2];

logic signed [DATA_WIDTH-1:0] a_out [2];
logic signed [DATA_WIDTH-1:0] b_out [2];

logic valid;
logic done;

matrix_buffer #(
    .DATA_WIDTH(DATA_WIDTH)
) dut (

    .clk(clk),
    .rst(rst),
    .start(start),

    .matrix_a(matrix_a),
    .matrix_b(matrix_b),

    .a_out(a_out),
    .b_out(b_out),

    .valid(valid),
    .done(done)

);

always #5 clk = ~clk;

initial begin

    $dumpfile("results/matrix_buffer.vcd");
    $dumpvars(0,tb_matrix_buffer);

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

    repeat(4) @(posedge clk);

    $display("");
    $display("Cycle 1");
    $display("A = %0d %0d", matrix_a[0][0], matrix_a[1][0]);
    $display("B = %0d %0d", matrix_b[0][0], matrix_b[0][1]);

    $display("");

    $display("Cycle 2");
    $display("A = %0d %0d", matrix_a[0][1], matrix_a[1][1]);
    $display("B = %0d %0d", matrix_b[1][0], matrix_b[1][1]);

    $display("");

    $display("Done = %0d",done);

    $finish;

end

endmodule
