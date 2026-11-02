module threshold (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire [7:0] mag,
    input  wire [7:0] thresh,
    input  wire       v_in,
    output reg  [7:0] edge_px,
    output reg        v_out
);

    always @(posedge clk) begin
        if (!rst_n) begin
            edge_px <= 8'h00;
            v_out   <= 1'b0;
        end else if (en) begin
            edge_px <= (mag > thresh) ? 8'hFF : 8'h00; // strictly greater
            v_out   <= v_in;
        end
    end

endmodule