module tff (q,qbar,t,clk,rst);
  input t,clk,rst;
  output reg q,qbar;
  reg x,y;
  always @ (posedge clk)
  begin
    if (rst)
      begin
    q <= 0;
    qbar <= 1;
      end
else
  begin
  x <= ~(clk & t & qbar);
  y <= ~(clk & t & q);
  q <= ~(x & qbar);
  qbar <= ~(y & q);
  end
  end
  endmodule
