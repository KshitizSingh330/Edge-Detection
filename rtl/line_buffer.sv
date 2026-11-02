module line_buffer #(parameter W=64, DW=8) (
  input  wire clk, rst_n, en,
  input  wire [DW-1:0] din,
  output reg  [DW-1:0] dout
);
  reg [DW-1:0] mem [0:W-1];
  reg [$clog2(W)-1:0] ptr;

  assign dout <= mem[ptr];

  always @(posedge clk) begin
    if (!rst_n) ptr <= 0;
    else if (en) begin
      mem[ptr] <= din;
      ptr      <= (ptr == W - 1) ? 0 : ptr + 1;
    end
  end
endmodule