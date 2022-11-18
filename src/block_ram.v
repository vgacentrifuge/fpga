module block_ram (
    input  clk,
    input  we,
    input  addr,
    input  di,
    output dout
);
  reg [15:0] ram  [1023:0];
  reg [15:0] dout;

  always @(posedge clk) begin
    if (we) ram[addr] <= di;
    else dout <= ram[addr];
  end
endmodule
