module bintogray(g,b,clk);
  parameter n=4;
  input [n-1:0]b;
  input clk;
  output reg [n-1:0]g;
  always @ (posedge clk)
  begin
    g = ({1'b0,b[3:1]}^ b);
  end 
endmodule
  