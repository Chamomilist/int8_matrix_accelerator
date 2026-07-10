`timescale 1ns/1ps

module tb_accumulator;

    parameter DATA_WIDTH = 32;

    logic clk;
    logic rst;
    logic clear;
    logic enable;
    logic signed [DATA_WIDTH-1:0] data_in;
    logic signed [DATA_WIDTH-1:0] acc_out;

    accumulator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .data_in(data_in),
        .acc_out(acc_out)
    );

    always #5 clk = ~clk;

    task check;
        input signed [DATA_WIDTH-1:0] expected;
        begin
            if (acc_out !== expected) begin
                $display("FAIL | Expected = %0d | Got = %0d", expected, acc_out);
                $finish;
            end
            else begin
                $display("PASS | Accumulator = %0d", acc_out);
            end
        end
    endtask

    initial begin

        $dumpfile("results/accumulator.vcd");
        $dumpvars(0, tb_accumulator);

        clk = 0;
        rst = 1;
        clear = 0;
        enable = 0;
        data_in = 0;

        #10;
        rst = 0;
        check(0);

        enable = 1;

        data_in = 10;
        #10;
        check(10);

        data_in = 20;
        #10;
        check(30);

        data_in = -5;
        #10;
        check(25);

        clear = 1;
        #10;
        clear = 0;
        check(0);

        data_in = 15;
        #10;
        check(15);

        enable = 0;
        data_in = 100;
        #10;
        check(15);

        $display("\n=========================");
        $display(" ALL TESTS PASSED ");
        $display("=========================\n");

        $finish;

    end

endmodule
