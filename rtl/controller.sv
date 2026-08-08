module controller #(
    parameter int DRAIN_CYCLES = 3
)  // Extra cycles for the array pipeline to drain
(
    input logic clk,
    input logic rst,

    input logic start,
    input logic buffer_done,

    output logic enable,
    output logic clear,
    output logic done
);

  typedef enum logic [2:0] {
    IDLE,
    LOAD,
    COMPUTE,
    DRAIN,
    FINISH
  } state_t;

  state_t state, next_state;

  logic [$clog2(DRAIN_CYCLES+1)-1:0] drain_cnt;  // Counter for the DRAIN state

  always_ff @(posedge clk) begin

    if (rst) begin
      state <= IDLE;
      drain_cnt <= '0;
    end else begin
      state <= next_state;
      if (state == COMPUTE && next_state == DRAIN) drain_cnt <= '0;
      else if (state == DRAIN) drain_cnt <= drain_cnt + 1'b1;
    end
  end


  always_comb begin

    next_state = state;
    enable = 1'b0;
    clear = 1'b0;
    done = 1'b0;

    case (state)

      IDLE: begin  // Wait for a new operation
        if (start) next_state = LOAD;
      end

      LOAD: begin  // Clear accumulators and begin computation
        enable = 1'b1;
        clear = 1'b1;
        next_state = COMPUTE;
      end

      COMPUTE: begin  // Process incoming matrix data
        enable = 1'b1;
        if (buffer_done) next_state = DRAIN;
      end

      DRAIN: begin  // Keep the pipeline running until empty
        enable = 1'b1;
        if (drain_cnt == DRAIN_CYCLES[$bits(drain_cnt)-1:0] - 1'b1) next_state = FINISH;
      end

      FINISH: begin  // Hold done until the next start
        done = 1'b1;
        if (!start) next_state = IDLE;
      end

    endcase

  end

  // Assertion: FSM must never enter an undefined/illegal state
  always @(posedge clk) begin
    if (!rst) begin
      assert (state == IDLE || state == LOAD || state == COMPUTE ||
                state == DRAIN || state == FINISH)
      else $error("controller: illegal state %0d at time %0t", state, $time);
    end
  end

endmodule
