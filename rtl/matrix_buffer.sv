`timescale 1ns / 1ps

module matrix_buffer #(
    parameter int DATA_WIDTH = 8,
    parameter int ROWS       = 2,
    parameter int COLS       = 2
) (
    input logic clk,
    input logic rst,
    input logic start,

    // Packed array ports for simulator compatibility
    input logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_a,
    input logic signed [ROWS-1:0][COLS-1:0][DATA_WIDTH-1:0] matrix_b,

    output logic signed [ROWS-1:0][DATA_WIDTH-1:0] a_out,
    output logic signed [COLS-1:0][DATA_WIDTH-1:0] b_out,

    output logic [ROWS-1:0] valid,  // one bit per row (A operand)
    output logic [COLS-1:0] b_valid,  // one bit per column (B operand)
    output logic done
);

  localparam int TOTAL_CYCLES = ROWS + COLS - 1;
  localparam int CYC_WIDTH    = $clog2(TOTAL_CYCLES + 1);

  logic [CYC_WIDTH-1:0] cyc;
  logic running;

  // ---------------------------------------------------------------
  // Control: cycle counter / running / done. Row and column feed
  // logic below only reacts to cyc/running -- no per-size case list.
  // ---------------------------------------------------------------
  always_ff @(posedge clk) begin

    if (rst) begin
      cyc     <= '0;
      running <= 1'b0;
      done    <= 1'b0;
    end else if (start) begin
      cyc     <= '0;
      running <= 1'b1;
      done    <= 1'b0;
    end else if (running) begin
      if (cyc == TOTAL_CYCLES[CYC_WIDTH-1:0] - 1'b1) begin
        running <= 1'b0;
        done    <= 1'b1;
      end else begin
        cyc <= cyc + 1'b1;
      end
    end

  end

  genvar gi, gj;

  // ---------------------------------------------------------------
  // Row-skewed A feed: row i emits matrix_a[i][cyc-i] while
  // i <= cyc <= i+COLS-1, one row-relative element per cycle.
  // (Icarus requires the outer packed-array index to be a
  // compile-time constant, so the row index must come from a
  // genvar rather than a runtime loop variable.)
  // ---------------------------------------------------------------
  generate
    for (gi = 0; gi < ROWS; gi++) begin : A_ROW

      always_ff @(posedge clk) begin
        if (rst) begin
          a_out[gi] <= '0;
          valid[gi] <= 1'b0;
        end
            else if (running && cyc >= gi[CYC_WIDTH-1:0] && cyc < gi[CYC_WIDTH-1:0] + COLS[CYC_WIDTH-1:0]) begin
          a_out[gi] <= matrix_a[gi][cyc-gi[CYC_WIDTH-1:0]];
          valid[gi] <= 1'b1;
        end else begin
          valid[gi] <= 1'b0;
        end
      end

    end
  endgenerate

  // ---------------------------------------------------------------
  // Column-skewed B feed: column j emits matrix_b[cyc-j][j] while
  // j <= cyc <= j+ROWS-1. matrix_b is pre-transposed per column via
  // generate (fully constant-indexed) so the runtime row select
  // lands on the inner, not outer, index.
  // ---------------------------------------------------------------
  logic signed [COLS-1:0][ROWS-1:0][DATA_WIDTH-1:0] b_col;

  generate
    for (gj = 0; gj < COLS; gj++) begin : B_TRANSPOSE
      for (gi = 0; gi < ROWS; gi++) begin : B_TRANSPOSE_ROW
        assign b_col[gj][gi] = matrix_b[gi][gj];
      end
    end
  endgenerate

  generate
    for (gj = 0; gj < COLS; gj++) begin : B_COL

      always_ff @(posedge clk) begin
        if (rst) begin
          b_out[gj]   <= '0;
          b_valid[gj] <= 1'b0;
        end
            else if (running && cyc >= gj[CYC_WIDTH-1:0] && cyc < gj[CYC_WIDTH-1:0] + ROWS[CYC_WIDTH-1:0]) begin
          b_out[gj]   <= b_col[gj][cyc-gj[CYC_WIDTH-1:0]];
          b_valid[gj] <= 1'b1;
        end else begin
          b_valid[gj] <= 1'b0;
        end
      end

    end
  endgenerate

  // Assertion: valid/b_valid must never be asserted while in reset
  always @(posedge clk) begin
    #1;
    if (rst) begin
      assert (valid == '0 && b_valid == '0)
      else $error("matrix_buffer: valid/b_valid asserted during reset at time %0t", $time);
    end
  end

endmodule
