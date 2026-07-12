module matrix_buffer #(parameter int DATA_WIDTH = 8)
(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input logic signed [DATA_WIDTH-1:0] matrix_a [2][2],
    input logic signed [DATA_WIDTH-1:0] matrix_b [2][2],

    output logic signed [DATA_WIDTH-1:0] a_out [2],
    output logic signed [DATA_WIDTH-1:0] b_out [2],

    output logic valid,
    output logic done
);

logic step;

always_ff @(posedge clk) begin

    if (rst) begin

        step  <= 1'b0;
        valid <= 1'b0;
        done  <= 1'b0;

        a_out[0] <= '0;
        a_out[1] <= '0;

        b_out[0] <= '0;
        b_out[1] <= '0;

    end

    else begin

        if(start) begin

            step  <= 1'b0;
            valid <= 1'b1;
            done  <= 1'b0;

        end

        else if(valid) begin

            if(step == 1'b0) begin

                a_out[0] <= matrix_a[0][0];
                a_out[1] <= matrix_a[1][0];

                b_out[0] <= matrix_b[0][0];
                b_out[1] <= matrix_b[0][1];

                step <= 1'b1;

            end

            else begin

                a_out[0] <= matrix_a[0][1];
                a_out[1] <= matrix_a[1][1];

                b_out[0] <= matrix_b[1][0];
                b_out[1] <= matrix_b[1][1];

                valid <= 1'b0;
                done  <= 1'b1;

            end

        end

    end

end

endmodule
