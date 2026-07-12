`timescale 1ns/1ps

module tb_controller;

logic clk;
logic rst;

logic start;
logic buffer_done;

logic enable;
logic clear;
logic done;

controller dut (
    .clk(clk),
    .rst(rst),

    .start(start),
    .buffer_done(buffer_done),

    .enable(enable),
    .clear(clear),
    .done(done)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("results/controller.vcd");
    $dumpvars(0, tb_controller);

    clk = 0;

    rst = 1;
    start = 0;
    buffer_done = 0;

    repeat(2) @(posedge clk);

    rst = 0;

    //------------------------------------
    // IDLE
    //------------------------------------

    @(posedge clk);

    if(!clear) begin
        $display("FAIL | Controller not in IDLE");
        $finish;
    end

    //------------------------------------
    // LOAD
    //------------------------------------

    @(negedge clk);
    start = 1;

    @(posedge clk);

    //------------------------------------
    // COMPUTE
    //------------------------------------

    @(posedge clk);

    if(!enable) begin
        $display("FAIL | Enable not asserted");
        $finish;
    end

    //------------------------------------
    // FINISH
    //------------------------------------

    @(negedge clk);
    buffer_done = 1;

    @(posedge clk);
    @(posedge clk);

    if(!done) begin
        $display("FAIL | Done not asserted");
        $finish;
    end

    //------------------------------------
    // Return to IDLE
    //------------------------------------

    @(negedge clk);
    start = 0;
    buffer_done = 0;

    @(posedge clk);
    @(posedge clk);

    if(!clear) begin
        $display("FAIL | Controller did not return to IDLE");
        $finish;
    end

    $display("");
    $display("=========================");
    $display(" ALL TESTS PASSED ");
    $display("=========================");
    $display("");

    $finish;

end

endmodule
