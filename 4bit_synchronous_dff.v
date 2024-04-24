module bit_syn_j(q,clk,rst);
  input clk,rst;
  output [3:0]q;
  wire [3:0]q;
  dfflop s1 (q[3],(~q[0]),clk,rst);
  dfflop s2 (q[2],q[3],clk,rst);
  dfflop s3 (q[1],q[2],clk,rst);
  dfflop s4 (q[0],q[1],clk,rst);
endmodule
  
  
module dfflop(q,d,clk,rst);
  input d,clk,rst;
  output reg q;
  always @ (posedge clk)
  begin
    if(rst)
      q<=0;
    else
      q<=d;
  end
endmodule


  
  
