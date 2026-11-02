module gauss3x3 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire [7:0] p00, p01, p02,
    input  wire [7:0] p10, p11, p12,
    input  wire [7:0] p20, p21, p22,
    input  wire       v_in,
    input  wire       border_in,
    output reg  [7:0] pix_out,
    output reg        v_out,
    output reg        border_out
);
    reg [11:0] s0, s1, s2;   // weighted row sums
    reg        v1, b1;       // valid and border flags, delayed with the data

    always @(posedge clk) begin
        if (!rst_n) begin
            s0 <= 0;  s1 <= 0;  s2 <= 0;
            v1 <= 0;  b1 <= 0;
            pix_out <= 0;  v_out <= 0;  border_out <= 0;
        end
        else if (en) begin
            // stage 1: weighted sum of each row (weights 1,2,1)
            s0 <= p00 + (p01 << 1) + p02;
            s1 <= p10 + (p11 << 1) + p12;
            s2 <= p20 + (p21 << 1) + p22;
            v1 <= v_in;
            b1 <= border_in;

            // stage 2: combine rows with weights 1,2,1, divide by 16
            pix_out    <= b1 ? 8'd0 : ((s0 + (s1 << 1) + s2) >> 4);
            v_out      <= v1;
            border_out <= b1;
        end
    end
endmodule