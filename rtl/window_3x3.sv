module window_3x3 #(
    parameter W  = 64,
    parameter H  = 64,
    parameter DW = 8
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          en,
    input  wire [DW-1:0] pix_in,
    input  wire          v_in,    // 1 = real pixel; flush also uses v_in=1 with pix_in=0
    input  wire          sof,     // start of frame: reset counters
    output reg  [DW-1:0] p00, p01, p02,
    output reg  [DW-1:0] p10, p11, p12,
    output reg  [DW-1:0] p20, p21, p22,
    output reg           v_out,
    output reg           border   // 1 = centre pixel is on the image border
);
    wire [DW-1:0] row1;           // pixel 1 row up
    wire [DW-1:0] row2;           // pixel 2 rows up

    line_buffer #(W, DW) lb1 (clk, rst_n, en & v_in, pix_in, row1);
    line_buffer #(W, DW) lb2 (clk, rst_n, en & v_in, row1,   row2);

    // shift registers: [0] = oldest (left), [2] = newest (right)
    always @(posedge clk) begin
        if (en & v_in) begin
            {p00, p01, p02} <= {p01, p02, row2};
            {p10, p11, p12} <= {p11, p12, row1};
            {p20, p21, p22} <= {p21, p22, pix_in};
        end
    end

    // position counters (see below) set v_out and border
endmodule