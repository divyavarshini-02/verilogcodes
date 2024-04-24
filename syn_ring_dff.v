module bit_syn(q,clk,pset);
  input clk,pset;
  output [3:0]q;
  wire [3:0]q;
  dfflop s1 (q[3],q[0],clk,pset);
  dfflop s2 (q[2],q[3],clk,(pset));
  dfflop s3 (q[1],q[2],clk,pset);
  dfflop s4 (q[0],q[1],clk,(~pset));
endmodule
  
  
module dfflop(q,d,clk,pset);
  input d,clk,pset;
  output reg q;
  always @ (posedge pset)
  begin
   q<=0;
  end
  always @ (negedge pset)
  begin
    q<=1;
  end
 always @ (posedge clk)
  begin 
     q<=d;
  end
endmodule




