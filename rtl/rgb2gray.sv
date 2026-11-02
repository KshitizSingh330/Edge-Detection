module rgb2gray (
  input logic clk, rst_n, en,
  input logic [23:0] rgb,
  input logic v_in,
  output logic v_out,
  output logic [7:0] gray
);

  wire [15:0] r = {8'b0, rgb[23:16]};
  wire [15:0] g = {8'b0, rgb[15:8]};
  wire [15:0] b = {8'b0, rgb[7:0]};
  wire [15:0] sum = (r<<6)+(r<<3)+(r<<2)+r
                    + (g<<7)+(g<<4)+(g<<2)+(g<<1)
                    + (b<<4)+(b<<3)+(b<<2)+b;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      gray <= 8'b0;
      v_out <= 1'b0;
    end
    else begin
      gray <= sum[15:8];
      v_out <= v_in;
    end
  end
endmodule