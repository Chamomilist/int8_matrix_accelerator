`timescale 1ns/1ps

module tb_mac;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;

    // Number of clock cycles from applying MAC inputs
    // to observing a valid accumulated result.
    localparam int MAC_LATENCY = 1;

    logic clk;
    logic rst;
    logic clear;
    logic enable;

    logic signed [DATA_WIDTH-1:0] a;
    logic signed [DATA_WIDTH-1:0] b;

    logic signed [(2*DATA_WIDTH)-1:0] product_out;
    logic signed [ACC_WIDTH-1:0] result;

    integer expected;

    mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(a),
        .b(b),
        .product_out(product_out),
        .result(result)
    );

    always #5 clk = ~clk;

    task mac_step;
        input signed [DATA_WIDTH-1:0] in_a;
        input signed [DATA_WIDTH-1:0] in_b;
        begin

            @(negedge clk);
            a = in_a;
            b = in_b;

            expected = expected + (in_a * in_b);

            repeat (MAC_LATENCY) @(posedge clk);
            #1;

            if (product_out !== (in_a * in_b)) begin
                $display("FAIL | Product Expected %0d Got %0d",
                         (in_a * in_b), product_out);
                $finish;
            end

            if (result !== expected) begin
                $display("FAIL | Result Expected %0d Got %0d",
                         expected, result);
                $finish;
            end

            $display("PASS | %0d x %0d = %0d | Acc = %0d",
                     in_a, in_b, product_out, result);

        end
    endtask

    initial begin

        $dumpfile("results/mac.vcd");
        $dumpvars(0, tb_mac);

        clk = 0;
        rst = 1;
        clear = 0;
        enable = 0;

        a = 0;
        b = 0;

        expected = 0;

        repeat (2) @(posedge clk);

        rst = 0;
        enable = 1;

        mac_step(2,3);
        mac_step(4,5);
        mac_step(-2,8);

        @(negedge clk);
        clear = 1;

        @(posedge clk);
        #1;

        clear = 0;
        expected = 0;

        if (result !== 0) begin
            $display("FAIL | Clear failed");
            $finish;
        end

        mac_step(10,10);
        mac_step(-5,-4);

        @(negedge clk);
        enable = 0;
        a = 7;
        b = 7;

        @(posedge clk);
        #1;

        if (result !== expected) begin
            $display("FAIL | Enable failed");
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
