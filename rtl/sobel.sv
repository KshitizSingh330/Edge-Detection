module sobel (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire [7:0] p00, p01, p02,
    input  wire [7:0] p10, p11, p12,
    input  wire [7:0] p20, p21, p22,
    input  wire       v_in,
    input  wire       border_in,
    output reg  [7:0] mag,
    output reg        v_out,
    output reg        border_out
);
    // stage 1: positive and negative parts (each at most 1020, 10 bits)
    reg [9:0] gx_p, gx_n, gy_p, gy_n;
    reg       v1, b1;

    // stage 2: signed gradients (12 bits signed is plenty)
    reg signed [11:0] gx, gy;
    reg               v2, b2;

    // stage 3: absolute values added together
    reg [10:0] sum;
    reg        v3, b3;

    // absolute values (combinational, read from the stage 2 registers)
    wire [11:0] ax = gx[11] ? -gx : gx;
    wire [11:0] ay = gy[11] ? -gy : gy;

    always @(posedge clk) begin
        if (!rst_n) begin
            gx_p <= 0;  gx_n <= 0;  gy_p <= 0;  gy_n <= 0;
            gx   <= 0;  gy   <= 0;  sum  <= 0;  mag  <= 0;
            v1 <= 0;  v2 <= 0;  v3 <= 0;  v_out <= 0;
            b1 <= 0;  b2 <= 0;  b3 <= 0;  border_out <= 0;
        end
        else if (en) begin
            // stage 1: weighted sums of the right/left columns and bottom/top rows
            gx_p <= p02 + (p12 << 1) + p22;     // right column
            gx_n <= p00 + (p10 << 1) + p20;     // left column
            gy_p <= p20 + (p21 << 1) + p22;     // bottom row
            gy_n <= p00 + (p01 << 1) + p02;     // top row
            v1 <= v_in;  b1 <= border_in;

            // stage 2: subtract to get signed gradients
            gx <= $signed({2'b0, gx_p}) - $signed({2'b0, gx_n});
            gy <= $signed({2'b0, gy_p}) - $signed({2'b0, gy_n});
            v2 <= v1;  b2 <= b1;

            // stage 3: |Gx| + |Gy|
            sum <= ax[10:0] + ay[10:0];
            v3 <= v2;  b3 <= b2;

            // stage 4: saturate to 8 bits, force 0 on the border
            mag <= b3 ? 8'd0 : (sum > 11'd255 ? 8'd255 : sum[7:0]);
            v_out <= v3;  border_out <= b3;
        end
    end
endmodule