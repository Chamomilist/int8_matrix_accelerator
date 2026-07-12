module controller (
    input  logic clk,
    input  logic rst,

    input  logic start,
    input  logic buffer_done,

    output logic enable,
    output logic clear,
    output logic done
);

typedef enum logic [2:0] {
    IDLE,
    LOAD,
    COMPUTE,
    FINISH
} state_t;

state_t state, next_state;

always_ff @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

always_comb begin

    next_state = state;

    enable = 1'b0;
    clear  = 1'b0;
    done   = 1'b0;

    case(state)

        IDLE: begin
            clear = 1'b1;

            if(start)
                next_state = LOAD;
        end

        LOAD: begin
            enable = 1'b1;
            next_state = COMPUTE;
        end

        COMPUTE: begin
            enable = 1'b1;

            if(buffer_done)
                next_state = FINISH;
        end

        FINISH: begin
            done = 1'b1;

            if(!start)
                next_state = IDLE;
        end

    endcase

end

endmodule
