module matrix_buffer #(parameter int DATA_WIDTH = 8)
(
    input logic clk,
    input logic rst,
    input logic start,

    // Unpacked array ports -> packed array ports
    // For better simulator compatibility

    input logic signed [1:0][1:0][DATA_WIDTH-1:0] matrix_a,
    input logic signed [1:0][1:0][DATA_WIDTH-1:0] matrix_b,

    output logic signed [1:0][DATA_WIDTH-1:0] a_out,
    output logic signed [1:0][DATA_WIDTH-1:0] b_out,


    output logic [1:0] valid, // Valid is now one bit per row instead of a single scalar
    output logic done
);

logic [1:0] cyc;
logic running;

always_ff @(posedge clk) begin

    if (rst) begin
        cyc <= 2'd0;
        running <= 1'b0;
        valid <= 2'b00;
        done <= 1'b0;
        a_out <= '0;
        b_out <= '0;
    end

    else begin

        if (start) begin
            cyc <= 2'd0;
            running <= 1'b1;
            done <= 1'b0;
        end

        else if (running) begin

            unique case (cyc)

                2'd0: begin
                    a_out[0] <= matrix_a[0][0];
                    b_out[0] <= matrix_b[0][0];
                    valid <= 2'b01; // row0 (first operands)
                end

                2'd1: begin
                    a_out[0] <= matrix_a[0][1];
                    a_out[1] <= matrix_a[1][0];
                    b_out[0] <= matrix_b[1][0];
                    b_out[1] <= matrix_b[0][1];
                    valid <= 2'b11; // row0 and row1 (middle operands)
                end

                2'd2: begin
                    a_out[1] <= matrix_a[1][1];
                    b_out[1] <= matrix_b[1][1];
                    valid <= 2'b10; // row1 (final operands)
                end

                default: valid <= 2'b00;

            endcase

            if (cyc == 2'd2) begin
                running <= 1'b0;
                done <= 1'b1;
            end

            else begin
                cyc <= cyc + 2'd1;
            end

        end

        else begin
            valid <= 2'b00;
        end

    end

end

endmodule
